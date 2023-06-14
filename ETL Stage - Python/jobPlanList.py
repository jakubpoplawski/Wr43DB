"""jobPlanLists.py stores a List of dictionaries in which table related 
parameters of the ETL job are stored.

List of tables in the Job Plan:
Dim related: Products, Shops, Warehouses, Vendors 
Fact related: Commercial Invoices, Freight Invoices

Dictionary of parameters of a single table:
source_name, 
source_query, lookup_query, lookup_column, 
staging_table, staging_schema,
staging_query, warehouse_schema, warehouse_table
"""

job_plan = [
# Products
    {"source_name": "Products",
    "source_query": """
SELECT
Products.ID AS 'ProductID'
,Manufacturers.Name AS 'ManufacturerName'
,ProductName
,Categories.Name AS 'CategoryName'
,Subcategories.Name AS 'SubcategoryName'
,PurchasePrice AS 'CurrentPurchasePrice'
,SellPrice AS 'CurrentSellPrice' 
FROM Products
INNER JOIN Manufacturers ON Manufacturers.ID = Products.ManufacturerID
INNER JOIN Subcategories ON Subcategories.ID = Products.SubcategoryID
INNER JOIN Categories ON Subcategories.CategoryID = Categories.ID
""", 
    "lookup_query": """
SELECT 
ProductID
FROM Upload.ProductsLookups
""",
    "lookup_column": "ProductID", 
    "lookup_table": "ProductsLookups",
    "staging_table": "Products",
    "staging_schema": "Upload",
    "staging_query": """
SELECT 
ProductID
,ManufacturerName
,ProductName
,CategoryName
,SubcategoryName
,CurrentPurchasePrice
,CurrentSellPrice
FROM Upload.Products
""",
    "warehouse_schema": "Dim",
    "warehouse_table": "Products"   
    },
# Shops
    {"source_name": "Shops",
    "source_query": """
SELECT
ID AS 'ShopID'
,Name
,Country
,City
,Street
,TelephoneTo
,PlaceType
,PostCode
FROM AssociatedPlaces
WHERE PlaceType = 'Shop'
""", 
    "lookup_query": """
SELECT 
ShopID
FROM Upload.ShopsLookups
""",
    "lookup_column": "ShopID", 
    "lookup_table": "ShopsLookups",
    "staging_table": "Shops",
    "staging_schema": "Upload",
    "staging_query": """
SELECT 
ShopID
,Name
,Country
,City
,Street
,TelephoneTo
,PlaceType
,PostCode
FROM Upload.Shops
""",
    "warehouse_schema": "Dim",
    "warehouse_table": "Shops"     
    },
# Warehouses
    {"source_name": "Warehouses",
    "source_query": """
SELECT
ID AS 'WarehouseID'
,Name
,Country
,City
,Street
,TelephoneTo
,PlaceType
,PostCode
FROM AssociatedPlaces
WHERE PlaceType = 'Warehouse'
""", 
    "lookup_query": """
SELECT 
WarehouseID
FROM Upload.WarehousesLookups
""",
    "lookup_column": "WarehouseID", 
    "lookup_table": "WarehousesLookups",
    "staging_table": "Warehouses",
    "staging_schema": "Upload",
    "staging_query": """
SELECT 
WarehouseID
,Name
,Country
,City
,Street
,TelephoneTo
,PlaceType
,PostCode
FROM Upload.Warehouses
""",
    "warehouse_schema": "Dim",
    "warehouse_table": "Warehouses"     
    },
# Vendors
    {"source_name": "Vendors",
    "source_query": """
SELECT
ID AS 'VendorID'
,Name
,Country
,City
,Street
,TelephoneTo
,NIP
,PlaceType
,PostCode
FROM AssociatedPlaces
WHERE PlaceType = 'Vendor'
""", 
    "lookup_query": """
SELECT 
VendorID
FROM Upload.VendorsLookups
""",
    "lookup_column": "VendorID", 
    "lookup_table": "VendorsLookups",
    "staging_table": "Vendors",
    "staging_schema": "Upload",
    "staging_query": """
SELECT 
VendorID
,Name
,Country
,City
,Street
,TelephoneTo
,NIP
,PlaceType
,PostCode
FROM Upload.Vendors
""",
    "warehouse_schema": "Dim",
    "warehouse_table": "Vendors"     
    },
# Commercial Invoices
    {"source_name": "Commercial Invoices",
    "source_query": """
SELECT
DocumentLines.ID AS 'LineID'
,DocumentHeaders.ID AS 'DocumentID'
,CAST(CONVERT(VARCHAR(10), DocumentHeaders.DocumentDate, 112) AS INT) 
AS 'DateID'
,ProductID
,Quantity
,Products.PurchasePrice AS 'DocumentPurchasePrice'
,Products.SellPrice AS 'DocumentSellPrice'
,DocumentHeaders.OriginalPlaceID AS 'VendorID'
,DocumentHeaders.DestinationPlaceID AS 'WarehouseID'
,NULL AS 'ShopID'
,DocumentHeaders.DocumentType
FROM DocumentLines
INNER JOIN DocumentHeaders 
ON DocumentHeaders.ID = DocumentLines.DocumentHeaderID
INNER JOIN Products
ON Products.ID = DocumentLines.ProductID
WHERE DocumentHeaders.DocumentType = 'CommercialInvoice'
""", 
    "lookup_query": """
SELECT 
LineID
FROM Upload.FactsCommercialInvoicesLookups
""",
    "lookup_column": "LineID", 
    "lookup_table": "FactsCommercialInvoicesLookups",
    "staging_table": "FactsCommercialInvoices",
    "staging_schema": "Upload",    
    "staging_query": """
SELECT 
LineID
,DocumentID
,ProductID
,Quantity
,DocumentPurchasePrice
,DocumentSellPrice
,DateID
,VendorID
,WarehouseID
,ShopID
,DocumentType
FROM Upload.FactsCommercialInvoices
""",
    "warehouse_schema": "Fact",
    "warehouse_table": "DocumentLines"
    },
# Freight Invoices
    {"source_name": "Freight Invoices",
    "source_query": """
SELECT
DocumentLines.ID AS 'LineID'
,DocumentHeaders.ID AS 'DocumentID'
,CAST(CONVERT(VARCHAR(10), DocumentHeaders.DocumentDate, 112) AS INT) 
AS 'DateID'
,ProductID
,Quantity
,Products.PurchasePrice AS 'DocumentPurchasePrice'
,Products.SellPrice AS 'DocumentSellPrice'
,NULL AS 'VendorID'
,DocumentHeaders.OriginalPlaceID AS 'WarehouseID'
,DocumentHeaders.DestinationPlaceID AS 'ShopID'
,DocumentHeaders.DocumentType
FROM DocumentLines
INNER JOIN DocumentHeaders 
ON DocumentHeaders.ID = DocumentLines.DocumentHeaderID
INNER JOIN Products
ON Products.ID = DocumentLines.ProductID
WHERE DocumentHeaders.DocumentType = 'FreightInvoice'
""", 
    "lookup_query": """
SELECT 
LineID
FROM Upload.FactsFreightInvoicesLookups
""",
    "lookup_column": "LineID", 
    "lookup_table": "FactsFreightInvoicesLookups",
    "staging_table": "FactsFreightInvoices",
    "staging_schema": "Upload",    
    "staging_query": """
SELECT 
LineID
,DocumentID
,ProductID
,Quantity
,DocumentPurchasePrice
,DocumentSellPrice
,DateID
,VendorID
,WarehouseID
,ShopID
,DocumentType
FROM Upload.FactsFreightInvoices
""",
    "warehouse_schema": "Fact",
    "warehouse_table": "DocumentLines"
    }   
]

truncate_query = """
TRUNCATE TABLE Upload.FactsCommercialInvoices

TRUNCATE TABLE Upload.FactsFreightInvoices

TRUNCATE TABLE Upload.Products

TRUNCATE TABLE Upload.Shops

TRUNCATE TABLE Upload.Vendors

TRUNCATE TABLE Upload.Warehouses
"""
