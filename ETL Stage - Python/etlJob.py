"""etlJob.py extracts the data from a OLTP database to the Staging area, 
and transfers it to OLAP Warehouse database for the purpose of analysis 
of the flow of the products observed through issued Commercial and 
Freigh Invoices. 

Basic aggregations and transformations are done through SQL queries on 
the Source OLTP database. Staging area stores information on previous uploads 
in Look-up tables, thus enables incremental upload. 

The script compares every upload with the look-ups and passes only new uploads 
to the Staging area and then for the upload to the OLAP Warehouse database.

The script is supported by jobPlanList.py which stores table related 
parameters of the job, and by etlConfig.ini which stores connection related 
and log related parameters.
"""

import pandas as pd
import sqlalchemy

import logging.config
import time
import psutil
import configparser

from jobPlanList import job_plan
from jobPlanList import truncate_query

# Logger initialisation and information level seting.
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

# Reading logger configuration from *.ini file.
config = configparser.ConfigParser()
config.read('etlConfig.ini')
job_config = config['ETL_Log_Job']
formatter = logging.Formatter(
    '%(levelname)s:  %(asctime)s:  %(process)s:  %(funcName)s:  %(message)s')

# Creation of the handler of the logs.
stream_handler = logging.StreamHandler()
file_handler = logging.FileHandler(job_config['log_name'])
file_handler.setFormatter(formatter)
logger.addHandler(file_handler)

# Source, Staging, and Warehouse databases credentials.
mssqlserver_user = job_config['mssqlserver_user']
mssqlserver_pass = job_config['mssqlserver_pass']
mssqlserver_servername = job_config['mssqlserver_servername']

source_database_name = job_config['source_database_name']
staging_database_name = job_config['staging_database_name']
warehouse_database_name = job_config['warehouse_database_name']

# Creation of engines for Source, Staging and Warehouse connections.
mssqlserver_source_uri = f"mssql+pyodbc://"\
                        f"{mssqlserver_user}:{mssqlserver_pass}"\
                        f"@{mssqlserver_servername}/{source_database_name}"\
                        f"?driver=SQL+Server"
mssqlserver_source_engine = sqlalchemy.create_engine(
                            mssqlserver_source_uri)

mssqlserver_staging_uri = f"mssql+pyodbc://"\
                        f"{mssqlserver_user}:{mssqlserver_pass}"\
                        f"@{mssqlserver_servername}/{staging_database_name}"\
                        f"?driver=SQL+Server"
mssqlserver_staging_engine = sqlalchemy.create_engine(
                            mssqlserver_staging_uri)

mssqlserver_warehouse_uri = f"mssql+pyodbc://"\
                        f"{mssqlserver_user}:{mssqlserver_pass}"\
                        f"@{mssqlserver_servername}/{warehouse_database_name}"\
                        f"?driver=SQL+Server"
mssqlserver_warehouse_engine = sqlalchemy.create_engine(
                            mssqlserver_warehouse_uri)


def clean_staging_tables(truncate_query, mssqlserver_staging_connection):
    """Function truncates Staging tables in the Staging database before next
    upload session.

    Args:
        truncate_query (str): Query for Staging tables cleaning. 
        mssqlserver_staging_connection (Connection): Staging database 
        Connection.
    """
    logger.info("Staging tables cleaning started.")
    
    try:    
        # Executing truncate table query stored with Job Plan.
        mssqlserver_truncate_query = sqlalchemy.text(truncate_query)
        mssqlserver_staging_connection.execution_options(
            autocommit=True).execute(mssqlserver_truncate_query)
    
        logger.info("Staging tables cleaned successfully.")
        
    except Exception as e:
        logger.error(e)        

    logger.info("Staging tables cleaning has ended.")


def extract(table_parameters_dict, mssqlserver_source_connection, 
            mssqlserver_staging_connection):
    """Function takes table parameters from the Job Plan list 
    and extracts data from the OLTP Source database tables to the Staging 
    tables in staging database. Source queries aggregate data and do basic 
    transformations on it.

    Args:
        table_parameters_dict (dict): parameters from the Job Plan dictionary; 
        takes source table name, source query from the Source database, 
        look-up query for incremental upload, look-up column name for 
        comparison with new upload from the source query, staging look-up 
        table name and staging table.
        mssqlserver_source_connection (Connection): OLTP database Connection.
        mssqlserver_staging_connection (Connection): Staging database 
        Connection.

    Returns:
        new_lookup_inserts: Look-up DataFrame for insert into Staging Look-up 
        tables.
        new_update_inserts: New inserts DataFrame for insert into Staging 
        and Warehouse tables.
    """
    
    logger.info(f'Start {table_parameters_dict["source_name"]}'\
                f' extract session.')
    
    # Look-up query for the creation of Look-up DataFrame.
    mssqlserver_lookup_query = table_parameters_dict["lookup_query"]
    try:
        # Query for the extraction and transformation 
        # from the source database for the creation of Source DataFrame.
        mssqlserver_source_query = table_parameters_dict["source_query"]

        # Upload of the Look-up table and Source query to the DataFrames.
        lookup_df = pd.read_sql(mssqlserver_lookup_query, 
                                mssqlserver_staging_connection)
        source_df = pd.read_sql(mssqlserver_source_query, 
                                mssqlserver_source_connection)

        # Extracting from both DataFrames LineID for comparison match-up.
        source_df_LookUpIDs = source_df[
            [table_parameters_dict["lookup_column"]]]
        lookup_df_LookUpIDs = lookup_df[
            [table_parameters_dict["lookup_column"]]]

        # Source LookUpIDs are _not_ in Look-up LookUpIDs.
        # Returns boolean values in rows for masking.
        differences = ~source_df_LookUpIDs.apply(
            tuple,1).isin(lookup_df_LookUpIDs.apply(tuple,1))

        # Masking the Source DataFrame with diffrence in LookUpIDs
        # for upload to Upload table and to Look-up table.
        new_update_inserts = source_df[differences]
        new_lookup_inserts = source_df[differences][[
            table_parameters_dict["lookup_column"]]]
        
        logger.info(f'Extraction session of '\
                    f'{table_parameters_dict["source_name"]} '\
                    f'completed successfully.')
        return new_lookup_inserts, new_update_inserts
    
    except ValueError as e:
        logger.error(e)

    logger.info(f'Extract session of {table_parameters_dict["source_name"]} '\
                f'has ended.')
    

def staging_load(new_lookup_inserts, new_update_inserts, 
                 table_parameters_dict, mssqlserver_staging_connection):
    """Function loads new inserts and look-up values into Staging tables.

    Args:
        new_lookup_inserts (DataFrame): New Look-up DataFrame for upload 
        from extract() function.
        new_update_inserts (DataFrame): New Insert DataFrame for upload 
        from extract() function.
        table_parameters_dict (dict): parameters from the Job Plan dictionary; 
        takes the table source name, staging schema, staging look-up table 
        name and staging table.
        mssqlserver_staging_connection (Connection): Staging database 
        Connection.
    """
    
    logger.info(f'Start {table_parameters_dict["source_name"]} '\
                f'staging load session.')
    
    try:
        # New inserts into Staging database.
        new_lookup_inserts.to_sql(
            schema=table_parameters_dict["staging_schema"], 
            name=table_parameters_dict["lookup_table"], 
            con=mssqlserver_staging_connection, chunksize=5000, index=False, 
            index_label=False, if_exists='append')

        new_update_inserts.to_sql(
            schema=table_parameters_dict["staging_schema"], 
            name=table_parameters_dict["staging_table"], 
            con=mssqlserver_staging_connection, chunksize=5000, index=False, 
            index_label=False, if_exists='append')
        
        logger.info(f'Staging load session of '\
                    f'{table_parameters_dict["source_name"]} '\
                    f'completed successfully.')
    
    except Exception as e:
        logger.error(e)

    logger.info(f'Staging load session of '\
                f'{table_parameters_dict["source_name"]} has ended.')


def warehouse_load(table_parameters_dict, mssqlserver_staging_connection, 
            mssqlserver_warehouse_connection):
    """The function reads data from the Staging tables and transfers it 
    to appropriate Warehouse table.

    Args:
        table_parameters_dict (dict): parameters from the Job Plan dictionary; 
        takes the table source name, staging query to collect the data, target 
        warehouse schema and warehouse table name for upload.
        mssqlserver_staging_connection (Connection): Staging database 
        Connection.
        mssqlserver_warehouse_connection (Connection): OLAP Warehouse database 
        Connection.
    """
    
    logger.info(f'Start {table_parameters_dict["source_name"]} '\
                f'warehouse load session.')
    
    try:
        # Query from a Staging table.
        mssqlserver_staging_query = table_parameters_dict["staging_query"]

        # Read the Staging table and upload it to the Warehouse database 
        # through DataFrame.
        staging_df = pd.read_sql(mssqlserver_staging_query, 
                                 mssqlserver_staging_connection)
        staging_df.to_sql(
            schema=table_parameters_dict["warehouse_schema"], 
            name=table_parameters_dict["warehouse_table"], 
            con=mssqlserver_warehouse_connection, chunksize=5000, index=False, 
            index_label=False, if_exists='append')
            
        logger.info(f'Warehouse load session of '\
                    f'{table_parameters_dict["source_name"]} '\
                    f'completed successfully.')    
    
    except Exception as e:
        logger.error(e)

    logger.info(f'Warehouse load session of '\
                f'{table_parameters_dict["source_name"]} has ended.')


def main():
    start = time.time()
    # Establishing connections with Source and Staging databases.
    mssqlserver_source_connection = mssqlserver_source_engine.connect()
    mssqlserver_staging_connection = mssqlserver_staging_engine.connect()

    # Cleaning staging tables before next upload.
    start1 = time.time()
    
    clean_staging_tables(truncate_query, mssqlserver_staging_connection)
    
    end1 = time.time() - start1
    logger.info(f'Cleaning staging tables CPU usage {psutil.cpu_percent()}%.')
    logger.info(f'Cleaning staging tables took: {end1} seconds.')    

    # Iteration through the job plan list to transfer data to Staging tables.
    # Job plan contains a list of dictionaries.
    # Each dictionary is a set of parameters for a single Dim or Fact table 
    # extraction.
    for table_parameters_dict in job_plan:
        start2 = time.time() 
           
        new_lookup_inserts, new_update_inserts = extract(
            table_parameters_dict, mssqlserver_source_connection, 
            mssqlserver_staging_connection)
        
        end2 = time.time() - start2
        logger.info(f'Extraction of {table_parameters_dict["source_name"]} '\
                    f'CPU usage {psutil.cpu_percent()}%.')
        logger.info(f'Extraction took: {end2} seconds.')  
        
        start3 = time.time()
        
        staging_load(new_lookup_inserts, new_update_inserts, 
                     table_parameters_dict, mssqlserver_staging_connection)
        
        end3 = time.time() - start3
        logger.info(f'Staging load of {table_parameters_dict["source_name"]} '\
                    f'CPU usage {psutil.cpu_percent()}%.')
        logger.info(f'Staging load took: {end3} seconds.')        

    # Source database connection closing.    
    mssqlserver_source_connection.close()
    mssqlserver_source_engine.dispose()

    # Establishing connection with the Warehouse database.
    mssqlserver_warehouse_connection = mssqlserver_warehouse_engine.connect()

    # Next iteration through the job plan list 
    # to transfer data from Staging tables to the Warehouse tables.        
    for table_parameters_dict in job_plan:
        start4 = time.time() 
           
        warehouse_load(table_parameters_dict, 
                       mssqlserver_staging_connection, 
                       mssqlserver_warehouse_connection)
        
        end4 = time.time() - start4
        logger.info(f'Warehouse load of '\
                    f'{table_parameters_dict["source_name"]} '\
                    f'CPU usage {psutil.cpu_percent()}%.')
        logger.info(f'Warehouse load took: {end4} seconds.') 

    # Staging database connection closing.         
    mssqlserver_staging_connection.close()
    mssqlserver_staging_engine.dispose()

    # Warehouse database connection closing.
    mssqlserver_warehouse_connection.close()
    mssqlserver_warehouse_engine.dispose()    
    
    end = time.time() - start
    
    # Appending the summary of the ETL session 
    # to the log file.
    logger.info(f'ETL Job took: {end} seconds.')
    logger.info('Session Summary:')
    logger.info(f'RAM memory {psutil.virtual_memory().percent}% used.')
    logger.info(f'CPU usage {psutil.cpu_percent()}%.')    
    

if __name__=="__main__":
    logger.info("ETL job initialised.")
    main()
