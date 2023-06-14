CREATE OR ALTER FUNCTION [dbo].[CurrentLoyalityDiscountMemberStatistics](@ClientID INT)
-- The function shows the statistcs for a single Client that is a Member 
-- of the Loyality Discount Program.
-- 
-- The function takes the AssocietedPersons.ID value of the Client as parameter.
--
-- Jakub Poplawski
RETURNS TABLE
AS
RETURN 
(
SELECT 
	AssociatedPersons.ID
	,AssociatedPersons.[Name] 
	,AssociatedPersons.Surname 
	,AssociatedPersons.DateOfBirth AS 'Birthday'
	,dbo.CalculateMembershipDiscount(GETDATE(), AssociatedPersons.ID) AS 'Current Discount Value'
	,(SELECT SUM(TotalAmount) FROM DocumentHeaders 
									WHERE AssociatedPersonID = AssociatedPersons.ID 
									AND DocumentType = 'Receipt' 
									AND DocumentDate < GETDATE()) AS 'Total Purchases Value'
	FROM AssociatedPersons
	INNER JOIN MembersLists ON MembersLists.AssociatedPersonID = AssociatedPersons.ID
	WHERE AssociatedPersons.ID = @ClientID
)
GO