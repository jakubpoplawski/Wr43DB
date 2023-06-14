DROP VIEW IF EXISTS [dbo].[VW_WarehouseVendorsStatistics]
GO

CREATE VIEW [dbo].[VW_WarehouseVendorsStatistics]
AS
SELECT
Dim.Vendors.[Name] AS 'Vendor Name'
,Dim.Warehouses.[Name] AS 'Warehouse Name'
,ProductName AS 'Product Name'
,Dim.Products.CategoryName AS 'Category Name'
,Dim.Products.SubcategoryName AS 'Subcategory Name'
,Quantity
FROM Fact.DocumentLines
INNER JOIN Dim.Products ON Fact.DocumentLines.ProductID = Dim.Products.ProductID
INNER JOIN Dim.Vendors ON Fact.DocumentLines.VendorID = Dim.Vendors.VendorID
INNER JOIN Dim.Warehouses ON Fact.DocumentLines.WarehouseID = Dim.Warehouses.WarehouseID
WHERE Fact.DocumentLines.DocumentType = 'CommercialInvoice'
GO
