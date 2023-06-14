DROP VIEW IF EXISTS [dbo].[VW_ProductsOverview]
GO

CREATE VIEW [dbo].[VW_ProductsOverview]
AS
SELECT 
Dim.Dates.TheDate
,Dim.Dates.TheMonth
,Dim.Dates.TheYear
,Dim.Products.ProductName AS 'Product Name'
,Quantity
,Dim.Vendors.[Name] AS 'Vendor Name'
,Dim.Warehouses.[Name] AS 'Warehouse Name'
,Dim.Shops.[Name] AS 'Shop Name'
,DocumentType 
FROM Fact.DocumentLines
INNER JOIN Dim.Dates ON Fact.DocumentLines.DateID = Dim.Dates.DateID
INNER JOIN Dim.Products ON Fact.DocumentLines.ProductID = Dim.Products.ProductID
LEFT JOIN Dim.Vendors ON Fact.DocumentLines.VendorID = Dim.Vendors.VendorID
LEFT JOIN Dim.Warehouses ON Fact.DocumentLines.WarehouseID = Dim.Warehouses.WarehouseID
LEFT JOIN Dim.Shops ON Fact.DocumentLines.ShopID = Dim.Shops.ShopID
