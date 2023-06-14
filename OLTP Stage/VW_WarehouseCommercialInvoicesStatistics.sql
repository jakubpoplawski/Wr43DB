DROP VIEW IF EXISTS [dbo].[VW_WarehouseCommercialInvoicesStatistics]
GO

CREATE VIEW [dbo].[VW_WarehouseCommercialInvoicesStatistics]
AS
--  This view presents basic statistics of Commercial Invoices from 
--  Warehouses' perspective. It shows values of producs ordered 
--  and calculates net worth of the Documents.
-- 
--  It also sums up the total and net values of products that went through
--  a specific Warehouse.
-- 
--  Jakub Poplawski
SELECT
	Warehouse.Name AS 'Warehouse Name'

	-- Proposed internal document identifier.
	,('Nr. ' + CAST(DocumentHeaders.ID AS VARCHAR) + '/' + 
		CONVERT(VARCHAR, DocumentHeaders.DocumentDate, 23)) AS 'Internal Document Number'
	,DocumentHeaders.DocumentDate AS 'Issued On'
	,Vendor.Name AS 'Vendor Name'
	,Products.ProductName AS 'Product Name'
	,DocumentLines.Quantity

	-- Single product statistics: single price, summary price of ordered quantity, net worth of that ordered quantity
	,Products.PurchasePrice AS 'Product Purchase Price'
	,(DocumentLines.Quantity * Products.PurchasePrice) AS 'Total Product Purchase Price'
	,(DocumentLines.Quantity * (Products.SellPrice - Products.PurchasePrice)) AS 'Total Product Net Worth' 

	-- Single invoice statistics: total cost of a single invoice and its net worth.
	,SUM(DocumentLines.Quantity * Products.PurchasePrice) 
		OVER (PARTITION BY DocumentHeaders.ID) AS 'Invoice Total Cost' 
	,SUM(DocumentLines.Quantity * (Products.SellPrice - Products.PurchasePrice)) 
		OVER (PARTITION BY DocumentHeaders.ID) AS 'Invoice Total Net Worth'

	-- Warehouse costs and net worth in a specified time frame.
	,SUM(DocumentLines.Quantity * Products.PurchasePrice) 
		OVER (PARTITION BY DocumentHeaders.DestinationPlaceID) AS 'Total Warehouse Cost' 
	,SUM(DocumentLines.Quantity * (Products.SellPrice - Products.PurchasePrice)) 
		OVER (PARTITION BY DocumentHeaders.DestinationPlaceID) AS 'Total Warehouse Net Worth'
	
	FROM DocumentLines
	INNER JOIN DocumentHeaders ON DocumentHeaders.ID = DocumentLines.DocumentHeaderID
	INNER JOIN Products ON Products.ID = DocumentLines.ProductID
	INNER JOIN AssociatedPlaces AS Vendor ON Vendor.ID = OriginalPlaceID
	INNER JOIN AssociatedPlaces AS Warehouse ON Warehouse.ID = DestinationPlaceID

	WHERE DocumentHeaders.DocumentType = 'CommercialInvoice'
WITH CHECK OPTION
GO