-- Options needed to set to not get interupted with regional data.
SET DATEFIRST  1, -- 1 = Monday, 7 = Sunday
    DATEFORMAT mdy, 
    LANGUAGE   US_ENGLISH;
-- assume the above is here in all subsequent code blocks.

DECLARE @StartDate  date = '20100101';

DECLARE @EndDate date = DATEADD(DAY, -1, DATEADD(YEAR, 30, @StartDate));

;WITH seq(n) AS 
(
  SELECT 0 UNION ALL SELECT n + 1 FROM seq
  WHERE n < DATEDIFF(DAY, @StartDate, @EndDate)
),
d(d) AS 
(
  SELECT DATEADD(DAY, n, @StartDate) FROM seq
),
src AS
(
  SELECT
	DateID			= CAST(CONVERT(VARCHAR(10), d, 112) AS INT),
    TheDate         = CONVERT(date, d),
    TheDay          = DATEPART(DAY,       d),
    TheDayName      = DATENAME(WEEKDAY,   d),
    TheWeek         = DATEPART(WEEK,      d),
    TheISOWeek      = DATEPART(ISO_WEEK,  d),
    TheDayOfWeek    = DATEPART(WEEKDAY,   d),
	TheWeekend		= CASE WHEN DATEPART(WEEKDAY,   d) = 6 OR DATEPART(WEEKDAY,   d) = 7 THEN 1 ELSE 0 END,
    TheMonth        = DATEPART(MONTH,     d),
    TheMonthName    = DATENAME(MONTH,     d),
    TheQuarter      = DATEPART(Quarter,   d),
    TheYear         = DATEPART(YEAR,      d),
    TheFirstOfMonth = DATEFROMPARTS(YEAR(d), MONTH(d), 1),
    TheLastOfYear   = DATEFROMPARTS(YEAR(d), 12, 31),
    TheDayOfYear    = DATEPART(DAYOFYEAR, d)
  FROM d
)
SELECT * INTO Dim.Dates FROM src
--SELECT * FROM src
  ORDER BY TheDate
  OPTION (MAXRECURSION 0);

CREATE UNIQUE CLUSTERED INDEX PK_DateDimension ON Dim.Dates(DateID);