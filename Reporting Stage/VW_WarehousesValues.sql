DROP VIEW IF EXISTS [dbo].[VW_WarehousesValues]
GO

CREATE VIEW [dbo].[VW_WarehousesValues]
AS
SELECT 
Dim.Dates.TheDate
,Dim.Dates.TheMonth
,Dim.Dates.TheYear
,Dim.Products.ProductName AS 'Product Name'
,Fact.DocumentLines.DocumentSellPrice AS 'Sell Price'
,Fact.DocumentLines.DocumentPurchasePrice AS 'Purchase Price'
,Quantity
,(Quantity * (Fact.DocumentLines.DocumentSellPrice - Fact.DocumentLines.DocumentPurchasePrice)) AS 'Profit'

-- Flow Profit Values: for Commercial Invoice with a plus and for Freight Invoice with a minus
,(CASE 
WHEN DocumentType = 'CommercialInvoice' 
THEN (Quantity * (Fact.DocumentLines.DocumentSellPrice - Fact.DocumentLines.DocumentPurchasePrice))
WHEN DocumentType = 'FreightInvoice' 
THEN (Quantity * (Fact.DocumentLines.DocumentSellPrice - Fact.DocumentLines.DocumentPurchasePrice)) * -1 END) AS 'Flow Profit'

-- Flow Purchase Values: for Commercial Invoice with a plus and for Freight Invoice with a minus
,(CASE 
WHEN DocumentType = 'CommercialInvoice' 
THEN (Quantity * Fact.DocumentLines.DocumentPurchasePrice)
WHEN DocumentType = 'FreightInvoice' 
THEN (Quantity * Fact.DocumentLines.DocumentPurchasePrice) * -1 END) AS 'Flow Purchase Value'

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
