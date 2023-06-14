DROP PROCEDURE IF EXISTS [dbo].[PopulateVendorProducts]
GO

CREATE PROCEDURE [dbo].[PopulateVendorProducts]
-- This stored procedure populates Vendors with the products they sell. 
-- Products table is the source table. 
--
-- The procedure goes through all the products stored in Products and appends 
-- them to random Vendors, to prevent from selling by the Organization 
-- products that were never available at any Vendor. 
--
-- On second firing the procedure appends additional products to randomly 
-- selected Vendor's offer, if they were not avaiable before.
--
-- If the procedure finds the product in the offer of that Vendor it adds 
-- the generated quantity of that product to the already available quantity 
-- of that product in the offer.
--
-- The procedure does not take any arguments.
--
-- Jakub Poplawski
AS
	DECLARE @iterator INT
	DECLARE @end INT

	DECLARE @ProductID INT
	DECLARE @AssociatedPlaceID INT
	DECLARE @Quantity INT

	DECLARE @ProductName VARCHAR(100)
	DECLARE @AssocietedPlaceName VARCHAR(30)
	
	SET @iterator = (SELECT min(ID) FROM Products)
	-- The function stops the WHILE loop after finishing the list of products 
	-- available in the Products table.
	SET @end = (SELECT max(ID) FROM Products)

	WHILE @iterator <= @end
	BEGIN
	SELECT @ProductID = (SELECT ID FROM Products WHERE ID=@iterator)
	-- The procedure checks if there is no gaps in the identity index.
	IF (@ProductID IS NOT NULL)
	BEGIN
		SELECT @AssociatedPlaceID = (SELECT TOP 1 ID FROM AssociatedPlaces WHERE PlaceType='Vendor' ORDER BY NEWID())
		SELECT @Quantity = (SELECT ABS(CHECKSUM(NEWID()))%400 + 100)

		SELECT @ProductName = (SELECT ProductName FROM Products WHERE ID = @ProductID)
		SELECT @AssocietedPlaceName = (SELECT Name FROM AssociatedPlaces WHERE ID = @AssociatedPlaceID)

		IF EXISTS (SELECT ProductID FROM PlaceProducts WHERE (AssociatedPlaceID = @AssociatedPlaceID) AND (ProductID = @ProductID))
		-- If the selected product exists in the offer, 
		-- the procedure adds the generated quantity to the existing offer.
		BEGIN
			UPDATE PlaceProducts
			SET Quantity = Quantity + @Quantity
			WHERE (ProductID = @ProductID) AND (AssociatedPlaceID = @AssociatedPlaceID);
			PRINT CAST(@ProductName AS VARCHAR(100)) + ' already exists in ' + CAST(@AssocietedPlaceName AS VARCHAR(30)) + '''s offer. Added additional quantity.'
		END
		ELSE
		-- If the selected product does not exist in the offer,
		-- it is added to the Vendor's offer.
		BEGIN
			INSERT INTO PlaceProducts
			(
				ProductID,
				AssociatedPlaceID,
				Quantity
			)
			VALUES(@ProductID, @AssociatedPlaceID, @Quantity)
			PRINT CAST(@ProductName AS VARCHAR(100)) + ' added to ' + CAST(@AssocietedPlaceName AS VARCHAR(30)) + '''s offer.'
		END
		PRINT CAST(@iterator AS VARCHAR(30)) + ' Iteration'
		SET @iterator = @iterator + 1
	END
	-- If there is a gap in IDs, the procedure skips that number.
	ELSE
		BEGIN
		SET @iterator = @iterator + 1
		END
	END
