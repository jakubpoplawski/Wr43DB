CREATE TABLE KubaDWWr43.Dim.Products (
ProductID int PRIMARY KEY
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
CREATE TABLE KubaDWWr43.Dim.Warehouses (
WarehouseID int PRIMARY KEY
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
CREATE TABLE KubaDWWr43.Dim.Shops (
ShopID int PRIMARY KEY
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
CREATE TABLE KubaDWWr43.Dim.Vendors (
VendorID int PRIMARY KEY
,Name varchar(30)
,Country varchar(30)
,City varchar(30)
,Street varchar(30)
,TelephoneTo varchar(30)
,NIP varchar(30)
,PlaceType varchar(50)
,PostCode varchar(30)
);

CREATE TABLE KubaDWWr43.Fact.DocumentLines (
LineID INT PRIMARY KEY
,DateID INT FOREIGN KEY REFERENCES Dim.Dates(DateID)
,DocumentID INT
,ProductID INT FOREIGN KEY REFERENCES Dim.Products(ProductID)
,Quantity INT
,DocumentSellPrice decimal(7, 2)
,DocumentPurchasePrice decimal(7, 2)
,VendorID INT FOREIGN KEY REFERENCES Dim.Vendors(VendorID)
,WarehouseID INT FOREIGN KEY REFERENCES Dim.Warehouses(WarehouseID)
,ShopID INT FOREIGN KEY REFERENCES Dim.Shops(ShopID)
,DocumentType varchar(50)
);