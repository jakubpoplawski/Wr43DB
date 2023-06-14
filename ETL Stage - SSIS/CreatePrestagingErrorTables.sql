--CREATE TABLE Upload.FactsDocumentLinesErrors (
--ID int
--,DocumentID int
--,ProductID int
--,Quantity int
--,DocumentPurchasePrice decimal(7, 2)
--,DocumentSellPrice decimal(7, 2)
--,DocumentDate date
--,OriginalPlaceID int
--,DestinationPlaceID int
--,DocumentType varchar(50)
--,ErrorCode int
--,ErrorColumn varchar(300)
--)

CREATE TABLE Upload.FactsCommercialInvoicesErrors (
LineID int
,DocumentID int
,ProductID int
,Quantity int
,DocumentPurchasePrice decimal(7, 2)
,DocumentSellPrice decimal(7, 2)
,DocumentDate date
,VendorID int
,WarehouseID int
,ShopID int --
,DocumentType varchar(50)
,ErrorCode int
,ErrorColumn varchar(300)
)

CREATE TABLE Upload.FactsFreightInvoicesErrors (
LineID int
,DocumentID int
,ProductID int
,Quantity int
,DocumentPurchasePrice decimal(7, 2)
,DocumentSellPrice decimal(7, 2)
,DocumentDate date
,VendorID int
,WarehouseID int
,ShopID int
,DocumentType varchar(50)
,ErrorCode int
,ErrorColumn varchar(300)
)


CREATE TABLE Upload.VendorsErrors (
VendorID int
,Name varchar(30)
,Country varchar(30)
,City varchar(30)
,Street varchar(30)
,TelephoneTo varchar(30)
,NIP varchar(30)
,PlaceType varchar(50)
,PostCode varchar(30)
,ErrorCode int
,ErrorColumn varchar(300)
);

CREATE TABLE Upload.WarehousesErrors (
WarehouseID int
,Name varchar(30)
,Country varchar(30)
,City varchar(30)
,Street varchar(30)
,TelephoneTo varchar(30)
,PlaceType varchar(50)
,PostCode varchar(30)
,ErrorCode int
,ErrorColumn varchar(300)
);

CREATE TABLE Upload.ShopsErrors (
ShopID int
,Name varchar(30)
,Country varchar(30)
,City varchar(30)
,Street varchar(30)
,TelephoneTo varchar(30)
,PlaceType varchar(50)
,PostCode varchar(30)
,ErrorCode int
,ErrorColumn varchar(300)
);

CREATE TABLE Upload.ProductsErrors (
ProductID int
,ManufacturerName varchar(100)
,ProductName varchar(100)
,CategoryName varchar(50)
,SubcategoryName varchar(50)
,CurrentPurchasePrice decimal(7, 2)
,CurrentSellPrice decimal(7, 2)
,ErrorCode int
,ErrorColumn varchar(300)
);
