CREATE TABLE AddDate.FactsDocumentLines (
LineID INT
,DateID INT
,DocumentID INT
,ProductID INT
,Quantity INT
,DocumentSellPrice decimal(7, 2)
,DocumentPurchasePrice decimal(7, 2)
,VendorID INT
,WarehouseID INT
,ShopID INT
,DocumentType varchar(50)
);