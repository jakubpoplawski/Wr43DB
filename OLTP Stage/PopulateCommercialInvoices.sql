DROP PROCEDURE IF EXISTS [dbo].[PopulateCommercialInvoices]
GO

CREATE PROCEDURE [dbo].[PopulateCommercialInvoices] @end INT
--  This stored procedure populates Documents with Commercial Invoices
--  and generates from 1 to 5 lines of random products in the offer
--  of randomly selected Vendor to randomly selected Warehouse. 
--
--  The procedure creates a random date between 2019-01-01 to 2022-12-31 in work hours 
--  from 9 am to 21 pm, picks a random Vendor and Warehouse. It picks an Employee 
--  working in that Warehouse and asigns him to that Commercial Invoice.
--
--  The procedure then generates from 1 to 5 Document Lines for this Commercial Invoice
--  with Products available at selected Vendor.
--
--  The procedure takes @end parameter as input, which specifies the number of generated
--  Invoices.
--
--  Jakub Poplawski
AS
	DECLARE @iterator INT
	DECLARE @line_iterator INT
	DECLARE @line_number INT

	--  Document Header parameters
	DECLARE @DocumentDate DATETIME
	DECLARE @EmployeeID INT
	--DECLARE @ClientID INT --AssociatedPersonID
	DECLARE @VendorID INT --OriginalPlaceID AssociatedPlaceID
	DECLARE @WarehouseID INT --DestinationPlaceID AssociatedPlaceID
	--DocumentType

	--  Document Lines parameters
	DECLARE @ProductID INT
	DECLARE @Quantity INT
	DECLARE @DocumentHeaderID INT
	DECLARE @ProductName VARCHAR(100)
	
	SET @iterator = 1

	SET @line_iterator = 1
	
	WHILE @iterator <= @end

	BEGIN 
	--  Random day between 2019-01-01 and 2022-12-31
	--  DATEDIFF(d, '2019-01-01', '2022-12-31') creates a span of 1460 days between 2019-01-01 and 2022-12-31
	--  * RAND(CHECKSUM(NEWID())) picks a random section of that span which next is rounded to a full day.
	SELECT @DocumentDate = (SELECT DATEADD(d, ROUND(DATEDIFF(d, '2019-01-01', '2022-12-31') * RAND(CHECKSUM(NEWID())), 0), 
	--  Random hour between 9:00 and 17:00
	--  %43200 generates time in a span of 8 hours (28800 s)
	--  + 32400 moves the generated span to 9:00.
	--  Declared start date 2019-01-01.
	DATEADD(s, ABS(CHECKSUM(NEWID()))%28800 + 32400, '2019-01-01')))

	SELECT @VendorID = (SELECT TOP 1 ID FROM AssociatedPlaces WHERE PlaceType='Vendor' ORDER BY NEWID())
	SELECT @WarehouseID = (SELECT TOP 1 ID FROM AssociatedPlaces WHERE PlaceType='Warehouse' ORDER BY NEWID())
	SELECT @EmployeeID = (SELECT TOP 1 ID FROM Employees WHERE (AssociatedPlaceID=@WarehouseID) AND (ContractStart<@DocumentDate) ORDER BY NEWID())

	INSERT INTO DocumentHeaders(DocumentDate, EmployeeID, OriginalPlaceID, DestinationPlaceID, DocumentType)
		VALUES(@DocumentDate, @EmployeeID, @VendorID, @WarehouseID, 'CommercialInvoice')
	SELECT @DocumentHeaderID = (SELECT MAX(ID) FROM DocumentHeaders)

	SET @line_iterator = 1
	SET @line_number = FLOOR(RAND()*(5-3+1)+3)
	PRINT 'Commercial Invoice nr. ' + CAST(@DocumentHeaderID AS VARCHAR(30)) + ' created.'
	
		WHILE @line_iterator <= @line_number
		BEGIN
		SELECT @ProductID = (SELECT TOP 1 ID FROM Products ORDER BY NEWID())
		--SELECT @ProductID = (SELECT TOP 1 ProductID FROM PlaceProducts WHERE AssociatedPlaceID=@VendorID ORDER BY NEWID())
		SELECT @DocumentHeaderID = (SELECT MAX(ID) FROM DocumentHeaders)
		SELECT @Quantity = (SELECT ABS(CHECKSUM(NEWID()))%10 + 10)
		SELECT @ProductName = (SELECT ProductName FROM Products WHERE ID = @ProductID)

		IF EXISTS (SELECT ProductID FROM DocumentLines WHERE (ProductID = @ProductID) AND (DocumentHeaderID = @DocumentHeaderID))
			BEGIN
				UPDATE DocumentLines
				SET Quantity = Quantity + @Quantity
				WHERE (ProductID = @ProductID) AND (DocumentHeaderID = @DocumentHeaderID);
				PRINT 'Additional quantity of '+ CAST(@ProductName AS VARCHAR(100)) + ' added to Commercial Invoice nr. ' + CAST(@DocumentHeaderID AS VARCHAR(30)) + '.'
			END
		ELSE
			BEGIN
				INSERT INTO DocumentLines(DocumentHeaderID, ProductID, Quantity)
					VALUES(@DocumentHeaderID, @ProductID, @Quantity)
				PRINT CAST(@ProductName AS VARCHAR(100)) + ' added to Commercial Invoice nr. ' + CAST(@DocumentHeaderID AS VARCHAR(30)) + '.'
			END
		SET @line_iterator = @line_iterator + 1
		END
	SET @iterator = @iterator + 1
	END