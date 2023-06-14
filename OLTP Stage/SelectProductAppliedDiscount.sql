CREATE OR ALTER FUNCTION [dbo].[SelectProductAppliedDiscount](@DocumentHeaderID INT, @ProductID INT)
-- This function selects the appropriate value of a discount for a product 
-- in DocumentLine.
--
-- The functions calculates the current total purchase value of the client
-- as on day of Document Date of the Document. Based on that it select appropriate
-- value of Loyality Program Discount.
--
-- If the DocumentType is a Receipt. If it is a Receipt it checks if 
-- a Product Discount is eligable. 
--
-- After that the function checks if the client is a member of 
-- the Loyality Program. Than it checks if he or she is a current member 
-- of that Program (as on day of Document Date). 
--
-- If so, the appropriate value of Loyality Discount is applied and 
-- overrides the applied Product Discount.
--
-- If the Document is not a Receipt NULL value of discount is applied.
--
-- Jakub Poplawski
RETURNS DECIMAL(32, 2) AS
BEGIN
	DECLARE @ReturnValue DECIMAL(32, 2)

	DECLARE @ClientID INT
	DECLARE @SelectedDiscountID INT
	DECLARE @ProductDiscountID INT
	DECLARE @DocumentDate DATETIME

	DECLARE @DiscountValue DECIMAL(32, 2)

	DECLARE @CurrentTotalPurchaseValue DECIMAL(32,2)

	SELECT @ClientID = (SELECT AssociatedPersonID FROM DocumentHeaders WHERE ID = @DocumentHeaderID)

	SELECT @DocumentDate = (SELECT DocumentDate FROM DocumentHeaders WHERE ID = @DocumentHeaderID)

	-- The function utilizes CalculateMembershipDiscount function to establish to appropriate Loyality Discount value.
	EXEC @DiscountValue = [dbo].[CalculateMembershipDiscount] @EventDate = @DocumentDate, @ClientID = @ClientID



	DECLARE @ProductDiscountStart DATETIME
	DECLARE @ProductDiscountEnd DATETIME

	DECLARE @MembershipDiscountStart DATETIME
	DECLARE @MembershipDiscountEnd DATETIME

	SET @DocumentDate = (SELECT DocumentDate FROM DocumentHeaders WHERE ID = @DocumentHeaderID)

	SET @ProductDiscountStart = (SELECT ProductDiscounts.DiscountStart FROM ProductDiscounts 
							INNER JOIN Products ON Products.ProductDiscountID = ProductDiscounts.ID 
							WHERE Products.ID = @ProductID)
	SET @ProductDiscountEnd = (SELECT ProductDiscounts.DiscountEnd FROM ProductDiscounts 
							INNER JOIN Products ON Products.ProductDiscountID = ProductDiscounts.ID 
							WHERE Products.ID = @ProductID)

	SET @MembershipDiscountStart = (SELECT StartDate FROM MembersLists WHERE AssociatedPersonID = @ClientID)
	SET @MembershipDiscountEnd = (SELECT ExpirationDate FROM MembersLists WHERE AssociatedPersonID = @ClientID)


	-- Function checks if the Document is a Receipt.
	IF (SELECT DocumentType FROM DocumentHeaders WHERE ID = @DocumentHeaderID) = 'Receipt'
	BEGIN
		-- Function checks if the product on the receipt has a discount.
		IF @DocumentDate BETWEEN @ProductDiscountStart AND @ProductDiscountEnd
		BEGIN
			SELECT @ProductDiscountID = (SELECT ProductDiscountID FROM Products WHERE ID = @ProductID)
			SELECT @SelectedDiscountID = (SELECT DiscountValueID FROM ProductDiscounts WHERE ID = @ProductDiscountID)
			SELECT @ReturnValue = (SELECT PriceModifier FROM ProductDiscountValues WHERE ID = @SelectedDiscountID)
		END
		-- Function checks if the Client is a member of the Loyality Program.
		IF EXISTS (SELECT AssociatedPersonID FROM MembersLists WHERE AssociatedPersonID = @ClientID) 
		BEGIN
			-- Function checks if the Client is a current member of the Loyality Program and sets 
			-- the value with accordance to the tresholds.
			IF @DocumentDate BETWEEN @MembershipDiscountStart AND @MembershipDiscountEnd
			BEGIN
				SELECT @ReturnValue = @DiscountValue
			END
		END
	END
	ELSE
	BEGIN
		-- If the Document is not a Receipt a null value is applied for the discount.
		SELECT @ReturnValue = NULL
	END
	RETURN @ReturnValue
	END