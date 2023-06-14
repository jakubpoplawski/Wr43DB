CREATE OR ALTER FUNCTION [dbo].[CalculateMembershipDiscount](@EventDate DATETIME, @ClientID INT)
-- The function calculates the total sum of purchases for a Client and utilizing
-- iteration through the table of set Discounts it selects the one below the set
-- threshold.
-- 
-- The function takes the currently needed date (issue date of a document, current date etc.)
-- and the AssocietedPersons.ID value of the Client as parameters.
--
-- Jakub Poplawski
RETURNS DECIMAL(7,2)
BEGIN
	DECLARE @PriceModifier DECIMAL(7,2)
	DECLARE @CurrentTotalPurchaseValue DECIMAL(8,2)
	DECLARE @Threshold DECIMAL(8,2)

	SELECT @CurrentTotalPurchaseValue = (SELECT SUM(TotalAmount) FROM DocumentHeaders 
									WHERE AssociatedPersonID = @ClientID 
									AND DocumentType = 'Receipt' 
									AND DocumentDate < @EventDate)
	
	DECLARE @Iterator INT
	DECLARE @Finish INT

	SET @Iterator= (SELECT MIN(ID) FROM LoyalityDiscountValues)
	SET @Finish = (SELECT MAX(ID) FROM LoyalityDiscountValues)
	SET @PriceModifier = NULL

	WHILE @Iterator <= @Finish
	BEGIN
		IF (@Iterator IS NOT NULL)
		BEGIN
			SET @Threshold = (SELECT Threshold FROM LoyalityDiscountValues WHERE ID = @Iterator)

			IF (SELECT @CurrentTotalPurchaseValue) >= @Threshold
			BEGIN
				SELECT @PriceModifier = (SELECT PriceModifier FROM LoyalityDiscountValues WHERE Threshold = @Threshold)
			END
			SET @Iterator = @Iterator + 1
		END
		ELSE
		BEGIN
			SET @Iterator = @Iterator + 1
		END
	END
RETURN @PriceModifier
END