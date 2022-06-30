DECLARE @StartDate DATE = '20000101', @NumberOfYears INT = 100;

-- prevent set or regional settings from interfering with 
-- interpretation of dates / literals

SET DATEFIRST 7;
SET DATEFORMAT mdy;
SET LANGUAGE US_ENGLISH;

DECLARE @CutoffDate DATE = DATEADD(YEAR, @NumberOfYears, @StartDate);

-- this is just a holding table for intermediate calculations:

CREATE TABLE #dim
(
  [date]       DATE PRIMARY KEY, 
  [fiscaldate] AS DATEADD(MONTH, 5, [date]),
  [day]        AS DATEPART(DAY,      [date]),
  [month]      AS DATEPART(MONTH,    [date]),
  FirstOfMonth AS CONVERT(DATE, DATEADD(MONTH, DATEDIFF(MONTH, 0, [date]), 0)),
  [MonthName]  AS DATENAME(MONTH,    [date]),
  [week]       AS DATEPART(WEEK,     [date]),
  [ISOweek]    AS DATEPART(ISO_WEEK, [date]),
  [DayOfWeek]  AS DATEPART(WEEKDAY,  [date]),
  [quarter]    AS DATEPART(QUARTER,  [date]),
  [fiscalquarter] AS DATEPART(QUARTER, DATEADD(MONTH, 5, [date])),
  [year]       AS DATEPART(YEAR,     [date]),
  [fiscalyear] AS DATEPART(YEAR, DATEADD(MONTH, 5, [date])),
  FirstOfYear  AS CONVERT(DATE, DATEADD(YEAR,  DATEDIFF(YEAR,  0, [date]), 0)),
  FirstOfFiscalYear AS CONVERT(DATE, DATEADD(YEAR, DATEDIFF(YEAR, 0, DATEADD(MONTH, 5, [date])), 0)),
  Style112     AS CONVERT(CHAR(8),   [date], 112),
  FiscalStyle112 AS CONVERT(CHAR(8), DATEADD(MONTH, 5, [date]), 112),
  Style101     AS CONVERT(CHAR(10),  [date], 101),
  FiscalStyle101 AS CONVERT(CHAR(10), DATEADD(MONTH, 5, [date]), 101)
);

-- use the catalog views to generate as many rows as we need

INSERT #dim([date]) 
SELECT d
FROM
(
  SELECT d = DATEADD(DAY, rn - 1, @StartDate)
  FROM 
  (
    SELECT TOP (DATEDIFF(DAY, @StartDate, @CutoffDate)) 
      rn = ROW_NUMBER() OVER (ORDER BY s1.[object_id])
    FROM sys.all_objects AS s1
    CROSS JOIN sys.all_objects AS s2
    -- on my system this would support > 5 million days
    ORDER BY s1.[object_id]
  ) AS x
) AS y;

CREATE TABLE dbo.CalendarDim
(
  DateKey             INT         NOT NULL PRIMARY KEY,
  [Date]              DATE        NOT NULL,
  [Day]               TINYINT     NOT NULL,
  BusinessDayOfMonth TINYINT	  NOt NULL,
  DaySuffix           CHAR(2)     NOT NULL,
  [Weekday]           TINYINT     NOT NULL,
  WeekDayName         VARCHAR(10) NOT NULL,
  IsWeekend           BIT         NOT NULL,
  IsHoliday           BIT         NOT NULL,
  HolidayText         VARCHAR(64) SPARSE,
  DOWInMonth          TINYINT     NOT NULL,
  [DayOfYear]         SMALLINT    NOT NULL,
  [DayOfFiscalYear]	  SMALLINT	  NOT NULL,
  WeekOfMonth         TINYINT     NOT NULL,
  WeekOfYear          TINYINT     NOT NULL,
  FiscalWeekOfYear	  TINYINT	  NOT NULL,
  ISOWeekOfYear       TINYINT     NOT NULL,
  [Month]             TINYINT     NOT NULL,
  FiscalMonth		  TINYINT	  NOT NULL,
  [MonthName]         VARCHAR(10) NOT NULL,
  [Quarter]           TINYINT     NOT NULL,
  FiscalQuarter		  TINYINT	  NOT NULL,
  QuarterName         VARCHAR(6)  NOT NULL,
  FiscalQuarterName	  VARCHAR(6)  NOT NULL,
  [Year]              INT         NOT NULL,
  FiscalYear		  INT		  NOT NULL,
  MMYYYY              CHAR(6)     NOT NULL,
  FiscalMMYYYY		  CHAR(6)     NOT NULL,
  MonthYear           CHAR(7)     NOT NULL,
  FirstDayOfMonth     DATE        NOT NULL,
  --FirstBusinessDayOfMonth	 DATE        NOT NULL,
  LastDayOfMonth      DATE        NOT NULL,
  --LastBusinessDayOfMonth	DATE        NOT NULL,
  FirstDayOfQuarter   DATE        NOT NULL,
  FirstDayOfFiscalQuarter	DATE	NOT NULL,
  LastDayOfQuarter    DATE        NOT NULL,
  LastDayOfFiscalQuarter	DATE	NOT NULL,
  FirstDayOfYear      DATE        NOT NULL,
  FirstDayOfFiscalYear	DATE	NOT NULL,
  LastDayOfYear       DATE        NOT NULL,
  LastDayOfFiscalYear	DATE	NOT NULL,
  FirstDayOfNextMonth DATE        NOT NULL,
  FirstDayOfNextYear  DATE        NOT NULL,
);
GO

-- create other useful index(es) here

INSERT dbo.CalendarDim WITH (TABLOCKX)
SELECT
  DateKey       = CONVERT(INT, Style112),
  [Date]        = [date],
  [Day]         = CONVERT(TINYINT, [day]),
  BusinessDayOfMonth = 0,
  DaySuffix     = CONVERT(CHAR(2), CASE WHEN [day] / 10 = 1 THEN 'th' ELSE 
                  CASE RIGHT([day], 1) WHEN '1' THEN 'st' WHEN '2' THEN 'nd' 
	              WHEN '3' THEN 'rd' ELSE 'th' END END),
  [Weekday]     = CONVERT(TINYINT, [DayOfWeek]),
  [WeekDayName] = CONVERT(VARCHAR(10), DATENAME(WEEKDAY, [date])),
  [IsWeekend]   = CONVERT(BIT, CASE WHEN [DayOfWeek] IN (1,7) THEN 1 ELSE 0 END),
  [IsHoliday]   = CONVERT(BIT, 0),
  HolidayText   = CONVERT(VARCHAR(64), NULL),
  [DOWInMonth]  = CONVERT(TINYINT, ROW_NUMBER() OVER 
                  (PARTITION BY FirstOfMonth, [DayOfWeek] ORDER BY [date])),
  [DayOfYear]   = CONVERT(SMALLINT, DATEPART(DAYOFYEAR, [date])),
  [DayOfFiscalYear] = CONVERT(SMALLINT, DATEPART(DAYOFYEAR, [fiscaldate])),
  WeekOfMonth   = CONVERT(TINYINT, DENSE_RANK() OVER 
                  (PARTITION BY [year], [month] ORDER BY [week])),
  WeekOfYear    = CONVERT(TINYINT, [week]),
  FiscalWeekOfYear = DATEPART(WEEK, [fiscaldate]),
  ISOWeekOfYear = CONVERT(TINYINT, ISOWeek),
  [Month]       = CONVERT(TINYINT, [month]),
  FiscalMonth   = CONVERT(TINYINT, MONTH([fiscaldate])),
  [MonthName]   = CONVERT(VARCHAR(10), [MonthName]),
  [Quarter]     = CONVERT(TINYINT, [quarter]),
  [FiscalQuarter] = CONVERT(TINYINT, DATEPART(QUARTER,[fiscaldate])),
  QuarterName   = CONVERT(VARCHAR(6), CASE [quarter] WHEN 1 THEN 'First' 
                  WHEN 2 THEN 'Second' WHEN 3 THEN 'Third' WHEN 4 THEN 'Fourth' END), 
  FiscalQuarterName = CONVERT(VARCHAR(6), CASE DATEPART(QUARTER,[fiscaldate])
				  WHEN 1 THEN 'First' WHEN 2 THEN 'Second' WHEN 3 THEN 'Third' WHEN 4 THEN 'Fourth' END),
  [Year]        = [year],
  [FiscalYear] = DATEPART(YEAR,[fiscaldate]),
  MMYYYY        = CONVERT(CHAR(6), LEFT(Style101, 2)    + LEFT(Style112, 4)),
  FiscalMMYYYY  = CONVERT(CHAR(6), LEFT(FiscalStyle101, 2)    + LEFT(FiscalStyle112, 4)),
  MonthYear     = CONVERT(CHAR(7), LEFT([MonthName], 3) + LEFT(Style112, 4)),
  FirstDayOfMonth     = FirstOfMonth,
  --FirstBusinessDayOfMonth = FirstOfMonth,
  LastDayOfMonth      = MAX([date]) OVER (PARTITION BY [year], [month]),
  --LastBusinessDayOfMonth = MAX([date]) OVER (PARTITION BY [year], [month]),
  FirstDayOfQuarter   = MIN([date]) OVER (PARTITION BY [year], [quarter]),
  FirstDayOfFiscalQuarter = MIN([date]) OVER (PARTITION BY [fiscalyear], [fiscalquarter]),
  LastDayOfQuarter    = MAX([date]) OVER (PARTITION BY [year], [quarter]),
  LastDayOfFiscalQuarter = MAX([date]) OVER (PARTITION BY [fiscalyear], [fiscalquarter]),
  FirstDayOfYear      = FirstOfYear,
  FirstDayOfFiscalYear = FirstOfFiscalYear,
  LastDayOfYear       = MAX([date]) OVER (PARTITION BY [year]),
  LastDayOfFiscalYear = MAX([date]) OVER (PARTITION BY [fiscalyear]),
  FirstDayOfNextMonth = DATEADD(MONTH, 1, FirstOfMonth),
  FirstDayOfNextYear  = DATEADD(YEAR,  1, FirstOfYear)
FROM #dim
OPTION (MAXDOP 1);

;WITH x AS 
(
  SELECT DateKey, [Date], IsHoliday, HolidayText, FirstDayOfYear,
    DOWInMonth, [MonthName], [WeekDayName], [Day],
    LastDOWInMonth = ROW_NUMBER() OVER 
    (
      PARTITION BY FirstDayOfMonth, [Weekday] 
      ORDER BY [Date] DESC
    )
  FROM dbo.CalendarDim
)
UPDATE x SET IsHoliday = 1, HolidayText = CASE
  WHEN ([MonthName] = 'December' AND [WeekDayName] = 'Friday' AND [Day] = 31) 
    OR ([MonthName] = 'January' AND [WeekDayName] = 'Monday' AND [Day] = 2) 
    OR ([MonthName] = 'January' AND [WeekDayName] NOT IN('Saturday','Sunday') AND [Day] = 1)
	THEN 'New Year''s Day' --First day of the year or closest weekday
  WHEN ([LastDOWInMonth] = 1 AND [MonthName] = 'May' AND [WeekDayName] = 'Monday')
    THEN 'Memorial Day'              -- (last Monday in May)
  WHEN ([MonthName] = 'July' AND [WeekDayName] = 'Friday' AND [Day] = 3) 
    OR ([MonthName] = 'July' AND [WeekDayName] = 'Monday' AND [Day] = 5)
	OR ([MonthName] = 'July' AND [WeekDayName] NOT IN('Saturday','Sunday') AND [Day] = 4)
    THEN 'Independence Day'          -- (July 4th or closest weekday)
  WHEN ([DOWInMonth] = 1 AND [MonthName] = 'September' AND [WeekDayName] = 'Monday')
    THEN 'Labour Day'                -- (first Monday in September)
  WHEN ([DOWInMonth] = 4 AND [MonthName] = 'November' AND [WeekDayName] = 'Thursday')
    THEN 'Thanksgiving Day'          -- Thanksgiving Day (fourth Thursday in November)
  WHEN ([MonthName] = 'December' AND [WeekDayName] = 'Friday' AND [Day] = 24)
    OR ([MonthName] = 'December' AND [WeekDayName] = 'Monday' AND [Day] = 26)
    OR ([MonthName] = 'December' AND [WeekDayName] NOT IN('Saturday','Sunday') AND [Day] = 25)
    THEN 'Christmas Day'
  END
WHERE 
  ([MonthName] = 'December' AND [WeekDayName] = 'Friday' AND [Day] = 31)
  OR ([MonthName] = 'January' AND [WeekDayName] = 'Monday' AND [Day] = 2)
  OR ([MonthName] = 'January' AND [WeekDayName] NOT IN('Saturday','Sunday') AND [Day] = 1)
  OR ([LastDOWInMonth] = 1 AND [MonthName] = 'May' AND [WeekDayName] = 'Monday')
  OR ([MonthName] = 'July' AND [WeekDayName] = 'Friday' AND [Day] = 3) 
  OR ([MonthName] = 'July' AND [WeekDayName] = 'Monday' AND [Day] = 5)
  OR ([MonthName] = 'July' AND [WeekDayName] NOT IN('Saturday','Sunday') AND [Day] = 4)
  OR ([DOWInMonth] = 1 AND [MonthName] = 'September' AND [WeekDayName] = 'Monday')
  OR ([DOWInMonth] = 4 AND [MonthName] = 'November' AND [WeekDayName] = 'Thursday')
  OR ([MonthName] = 'December' AND [WeekDayName] = 'Friday' AND [Day] = 24)
  OR ([MonthName] = 'December' AND [WeekDayName] = 'Monday' AND [Day] = 26)
  OR ([MonthName] = 'December' AND [WeekDayName] NOT IN('Saturday','Sunday') AND [Day] = 25);

;WITH T AS
	(SELECT BusinessDayOfMonth, [Year], [Month], [Date], IsHoliday, IsWeekend,
		BusDay = CONVERT(TINYINT, DENSE_RANK() OVER( PARTITION BY [Year], [Month] ORDER BY [Date]))
	 FROM dbo.CalendarDim
	 WHERE IsHoliday = 0 AND IsWeekend = 0)
UPDATE T SET BusinessDayOfMonth = BusDay

--;WITH U AS
--	(SELECT BusinessDayOfMonth, [Year], [Month], [Date],
--		FirBusDay = MIN([Date]) OVER( PARTITION BY [Year], [Month] ORDER BY BusinessDayOfMonth),
--		LastBusDay = MAX([Date]) OVER( PARTITION BY [Year], [Month] ORDER BY BusinessDayOfMonth)
--	 FROM dbo.CalendarDim
--	 WHERE BusinessDayOfMonth <> 0)
--UPDATE U SET FirstBusinessDayOfMonth = FirBusDay, LastBusinessDayOfMonth = LastBusDay