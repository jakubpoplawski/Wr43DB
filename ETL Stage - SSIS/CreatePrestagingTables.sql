--CREATE TABLE Upload.DocumentLines (
--ID int
--,DocumentHeaderID int
--,ProductID int
--,Quantity int
----,AppliedDiscount decimal(7,2)
--);

--CREATE TABLE Upload.DocumentHeaders (
--ID int
--,DocumentDate datetime
--,TotalAmount int
----,EmployeeID int
----,AssociatedPersonID int
--,OriginalPlaceID int
--,DestinationPlaceID int
--,DocumentType varchar(50)
--);

CREATE TABLE Upload.Products (
ProductID int
,ManufacturerName varchar(100)
,ProductName varchar(100)
,CategoryName varchar(50)
,SubcategoryName varchar(50)
,CurrentPurchasePrice decimal(7, 2)
,CurrentSellPrice decimal(7, 2)
--,DefaultWarrantyDuration
--,ProductDiscountID int
);

--AssociatedPlaces
CREATE TABLE Upload.Warehouses (
WarehouseID int
,Name varchar(30)
,Country varchar(30)
,City varchar(30)
,Street varchar(30)
--,NIP varchar(30)
,TelephoneTo varchar(30)
,PlaceType varchar(50)
,PostCode varchar(30)
);

--AssociatedPlaces
CREATE TABLE Upload.Shops (
ShopID int
,Name varchar(30)
,Country varchar(30)
,City varchar(30)
,Street varchar(30)
--,NIP varchar(30)
,TelephoneTo varchar(30)
,PlaceType varchar(50)
,PostCode varchar(30)
);

--AssociatedPlaces
CREATE TABLE Upload.Vendors (
VendorID int
,Name varchar(30)
,Country varchar(30)
,City varchar(30)
,Street varchar(30)
,TelephoneTo varchar(30)
,NIP varchar(30)
,PlaceType varchar(50)
,PostCode varchar(30)
);

----Vendors and Warehouses together
--CREATE TABLE Upload.AssociatedPlaces (
--ID int
--,Name varchar(30)
--,Country varchar(30)
--,City varchar(30)
--,Street varchar(30)
--,TelephoneTo varchar(30)
--,NIP varchar(30)
--,PlaceType varchar(50)
--,PostCode varchar(30)
--);

--CREATE TABLE Upload.FactsDocumentLines (
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
--)

CREATE TABLE Upload.FactsCommercialInvoices (
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
)

CREATE TABLE Upload.FactsFreightInvoices (
LineID int
,DocumentID int
,ProductID int
,Quantity int
,DocumentPurchasePrice decimal(7, 2)
,DocumentSellPrice decimal(7, 2)
,DocumentDate date
,VendorID int --
,WarehouseID int
,ShopID int
,DocumentType varchar(50)
)

--MAX BYTES 75 || (4*5 (int) + 3 (date) 50+2 (varchar(50)))
--PRINT(4*5+3+52)
--10 MB = 10000000 Bytes (in decimal)
--10 MB = 10485760 Bytes (in binary)
--PRINT(10000000/75)
--PRINT(10485760/75)
--RESULTS:
--133333
--139810
