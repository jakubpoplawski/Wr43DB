The repository documents the results of the SoftServe Academy Data Engineering course. The aim of the course group project was to familiarize ourselves with commercially used tools through creation of a database for a fictional Enterprise and through analysing the dummy data generated for it. 

The Enterprise was a multibranch nationwide shop that sells household appliances and audio/video devices. The Enterprise hired people nationwide in Shops and Warehouses. The Enterprise acquired goods from Vendors, stores them in Warehouses and sells at Shops. 

The Enterprise documented its work through a series of documents: when a good was acquired and transported to a Warehouse from a Vendor a Commercial Invoice was issued, when a good was transported from a Warehouse to a Shop a Freight Invoice was issued, when a good was sold at a Shop to a Client a Receipt was issued.

The Enterprise had a system of Discounts. A Product Discount that was issued by the management on certain products on certain time, and a Loyalty Discount that was issued for a registered Member of the Loyalty Discount Programme on basis of value of previous purchases. The later discount over-raided the Product Discount.

The Enterprise stored information about the Products. The Enterprise stored information about the Clients and Workers. The Enterprise stored the addresses of the Shops, Vendors, and Warehouses. The Enterprise stored information about the currently available Products at Shops, Vendors, and Warehouses.

The course consisted of three sprints that divided the work into:
1. Creation of the OLTP database and creation of the dummy data
2. Development of the ETL process and creation of the OLAP database
3. Reporting work


1. Creation of the OLTP database and creation of the dummy data
The goal of the sprint was to design a normalised database for transactional purposes. T-SQL scripts were created to generate dummy data and for basic handling of the data by the database to ensure its consistency. Stored procedures, views, and triggers were created in the process.

I was responsible for:
- Stored procedure to generate Commercial Invoices,
- Stored procedure to populate Vendors with their products,
- Trigger validating VAT tax code upon insert of Vendors into table storing their addresses,
- View summarizing Commercial Invoices for a given Warehouse,
- Customers' Loyalty Discount program,
- Vendors related tables,
- Function selecting an appropriate type of Discount on Receipt line,
- Table valued function summarizing the information about a selected Member of the Loyalty Discount program.


2. Development of the ETL process and creation of the OLAP database
OLAP database was created with an aim to gain insight into flow of the Products through the Warehouses of the Enterprise. 

The Fact table was created around the data from Commercial and Freigh Invoices. Dimensions tables described Date, Vendors, Products, Shops, and Warhouses. The Date table was created through a T-SQL script. 

2.1. ETL Process in SSIS
The goal of my ETL process was to provide data from OLTP database from the previous sprint to the OLAP database with an aim to analyse the flow of warehouse stock. The ETL process was created in Visual Studio SQL Server Integration Services.

The process extracted the data from the OLTP database into Staging tables. The data were aggregated and transformed through T-SQL queries. Staging databases was equipped in Look-up tables for comparison of uploaded data with the previously uploaded, thus enabling their incremental load.

The Staging tables were supported by Error tables that handled the Error outputs of the ETL process, providing error handling. The ETL process was logged by a txt file.

2.2. ETL Process in Python
After the course I have recreated the ETL process in Python using SQLAlchemy, logging and Pandas modules. The goal was to recreate all of the aspects of SSIS ETL Process in Python.

Four functions were created to model successive stages of the process. The clean_staging_tables() function was responsible for cleaning of Staging tables after previous load. The extract() function extracted data from the OLTP database and compared of it with the data in Look-up tables. Data that successfully passed extraction were loaded into Staging tables by staging_load() function. The warehouse_load() function was responsible for the transfer of data from Staging tables into OLAP database, relieving the OLTP-Staging connection. 

The functions were executed upon a iteration on a list of dictionaries that stored information about the tables handled by the ETL Process. The list of dictionaries was stored in a separate jobPlanList.py file, separating Table related parameters of the ETL Process from connection and logging related parameters stored in etlConfig.ini file.

Data modification were done through T-SQL queries and Pandas DataFrame related methods. Database connections were done through SQLAlchemy.

The ETL Process was equipped in error handling and logging created through logging module. The log was stored in etlJob_log.txt file.

The Python scripts are stored in a separate folder.


3. Reporting work
Reporting work was done in Power Bi and the scope of it were the analyses of Warehouse stocks of Products. The flow of Products was analysed through Commercial Invoices and Freight Invoices issued upon arrival and shipping of the Products in the Warehouse. 

A report summarizing the number of issued Invoices and Products in a single Warehouse was created. Second report concerned the change of value of the Products stored in the Warehouse. The third report showed the change in quantity of a single type of Product in a selected Warehouse. The last report showed the structure of products supplied to the selected Warehouse by the Vendors. 

T-SQL, Power Query and basic DAX were used to build the reports.



Hope you enjoy reading the code.

Regards,
jp

jakubpoplawski@live.com
