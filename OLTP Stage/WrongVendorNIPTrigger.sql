IF OBJECT_ID ('dbo.TR_WrongNIPNumber','TR') IS NOT NULL
   DROP TRIGGER [dbo].[TR_WrongNIPNumber];
GO
-- This trigger prevents a row from beeing inserted if NIP (VAT tax number) is less than 10 digits.
--
-- Jakub Poplawski
CREATE TRIGGER [dbo].[TR_WrongNIPNumber] ON [dbo].[AssociatedPlaces]
AFTER INSERT
AS
IF EXISTS (SELECT NIP
           FROM inserted
           WHERE (LEN(NIP) < 10 AND PlaceType = 'Vendor')
          )
	BEGIN
		RAISERROR ('This vendor''s NIP has not enough digits. Provide correct NIP in ten digit number format without dashes.', 16, 1);
		ROLLBACK TRANSACTION;
	END
IF EXISTS (SELECT NIP
           FROM inserted
           WHERE (LEN(NIP) > 10 AND PlaceType = 'Vendor')
          )
	BEGIN
		RAISERROR ('This vendor''s NIP has too many digits. Provide correct NIP in ten digit number format without dashes.', 16, 1);
		ROLLBACK TRANSACTION;
	END
IF EXISTS (SELECT NIP
           FROM inserted
           WHERE ((NIP IS NULL) AND PlaceType = 'Vendor')
          )
	BEGIN
		RAISERROR ('NIP has to be provided for a Vendor. Provide correct NIP in ten digit number format without dashes.', 16, 1);
		ROLLBACK TRANSACTION;
	END 
IF EXISTS (SELECT NIP
           FROM inserted
           WHERE (PlaceType = 'Shop' OR PlaceType = 'Warehouse')
          )
	BEGIN
		RAISERROR ('NIP was provided for the Organization''s Shop or Warehouse. Provide NIP only for Vendor partners.', 16, 1);
		ROLLBACK TRANSACTION;
	END 

