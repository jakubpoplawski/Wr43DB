DROP PROCEDURE IF EXISTS [dbo].[SetMemberDiscount]
GO

CREATE PROCEDURE [dbo].[SetMemberDiscount] @ClientID INT
--  This stored procedure checks if a new insert into DocumentHeaders table
--  is a Receipt. If it is a Receipt it calculates the sum of TotalAmount
--  of all Receipts present in DocumentHeaders table.
--
--  The sum of TotalAmount is the basis for the new value of Loyality Discount.
--  Tresholds are hardcoded in the procedure. After finding the appropriate value
--  the procedure updates the column LoyalityDiscountValueID.
--  
--  The input of the procedure is a value obtained from TR_SetMemberDiscount
--  trigger. The trigger gives as an output the AssociatedPersonID value of
--  a client that is a member of the Loyality Program present in MembersLists
--  table.
--
--  Jakub Poplawski
AS
BEGIN
	DECLARE @DocumentHeaderID INT
	DECLARE @DiscountValue INT
	
	DECLARE @TotalPurchaseValue DECIMAL(17,2)

	SELECT @TotalPurchaseValue = (SELECT SUM(TotalAmount) FROM DocumentHeaders 
									WHERE AssociatedPersonID = @ClientID AND DocumentType = 'Receipt')
	
	PRINT CAST(@TotalPurchaseValue AS VARCHAR)

	IF (SELECT @TotalPurchaseValue) >= 10000
	BEGIN
	SET @DiscountValue = 1
	END
	IF (SELECT @TotalPurchaseValue) >= 20000
	BEGIN
	SET @DiscountValue = 2
	END
	IF (SELECT @TotalPurchaseValue) >= 40000
	BEGIN
	SET @DiscountValue = 3
	END
	IF (SELECT @TotalPurchaseValue) >= 80000
	BEGIN
	SET @DiscountValue = 4
	END
	IF (SELECT @TotalPurchaseValue) >= 160000
	BEGIN
	SET @DiscountValue = 5
	END

	PRINT CAST(@DiscountValue AS VARCHAR)

	UPDATE MembersLists
		SET LoyalityDiscountValueID = @DiscountValue
		WHERE AssociatedPersonID = @ClientID 
END