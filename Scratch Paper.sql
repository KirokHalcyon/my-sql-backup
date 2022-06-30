USE [SharedServices]
GO

SELECT 
       TrilAcctName
      ,POA_Associates.FullName
	  ,DATENAME(year, [PendingDate]) AS POA_PendingYear 
	  ,MONTH([PendingDate]) AS POA_PendingMonthNum 
	  ,DATENAME(month, [PendingDate]) AS POA_PendingMonth 
	  ,DATEPART(wk, [PendingDate]) AS POA_PendingWeek
      ,COUNT([POANum]) AS CountOfPendingPOA_Num
	  ,SUM(CurrPOA_Amt - OrigPOA_Amt) AS SumOfPOA_AmtAdjustment
  FROM [dbo].[POA_PendingLog] INNER JOIN POA_Associates ON POA_PendingLog.OwnerID = POA_Associates.UserID
  WHERE DATENAME(year, [PendingDate]) = 2018 AND MONTH([PendingDate]) = 1
  GROUP BY TrilAcctName, POA_Associates.FullName, DATENAME(year, [PendingDate]) ,MONTH([PendingDate]) ,DATENAME(month, [PendingDate]) ,DATEPART(wk, [PendingDate])
GO

USE [SharedServices]
GO

SELECT 
	 TrilAcctName
	,POA_Associates.FullName
	,POA_DoneYear
	,POA_DoneMonthNum
	,POA_DoneMonth
	,POA_DoneWeek
	,COUNT(POA_Num) AS CountOfDonePOA_Num
	,SUM(OrigPOA_Amt*-1) AS SumOfOrigPOA_Amt
FROM POA_BasicReporting INNER JOIN POA_Associates ON POA_BasicReporting.OwnerID = POA_Associates.UserID
WHERE POA_DoneYear = 2018 AND POA_DoneMonthNum = 1
GROUP BY TrilAcctName, POA_Associates.FullName, POA_DoneYear, POA_DoneMonthNum, POA_DoneMonth, POA_DoneWeek
GO

USE [SharedServices]
GO

SELECT 
	TrilAcctName
	,POA_Associates.FullName
	,DATENAME(year, [PendingDate]) AS POA_Year 
	,MONTH([PendingDate]) AS POA_MonthNum 
	,DATENAME(month, [PendingDate]) AS POA_Month 
	,DATEPART(wk, [PendingDate]) AS POA_Week
FROM [dbo].[POA_PendingLog] INNER JOIN POA_Associates ON POA_PendingLog.OwnerID = POA_Associates.UserID
WHERE DATENAME(year, [PendingDate]) = 2018 AND MONTH([PendingDate]) = 1

UNION

SELECT 
	TrilAcctName
	,POA_Associates.FullName
	,POA_DoneYear AS POA_Year
	,POA_DoneMonthNum AS POA_MonthNum 
	,POA_DoneMonth AS POA_Month 
	,POA_DoneWeek AS POA_Week
FROM POA_BasicReporting INNER JOIN POA_Associates ON POA_BasicReporting.OwnerID = POA_Associates.UserID
WHERE POA_DoneYear = 2018 AND POA_DoneMonthNum = 1

GO

--TempTrilUserCalendarDim
USE [SharedServices]
GO

SELECT
	TempTrilUserCalendarDim.TrilAcctName
	,TempTrilUserCalendarDim.FullName
	,TempTrilUserCalendarDim.POA_Year
	,TempTrilUserCalendarDim.POA_MonthNum
	,TempTrilUserCalendarDim.POA_Month
	,TempTrilUserCalendarDim.POA_Week
	,CountOfPendingPOA_Num
	,CountOfDonePOA_Num
	,SumOfPOA_AmtAdjustment
	,SumOfOrigPOA_Amt
FROM
(SELECT 
	TrilAcctName
	,POA_Associates.FullName
	,DATENAME(year, [PendingDate]) AS POA_Year 
	,MONTH([PendingDate]) AS POA_MonthNum 
	,DATENAME(month, [PendingDate]) AS POA_Month 
	,DATEPART(wk, [PendingDate]) AS POA_Week
FROM [dbo].[POA_PendingLog] INNER JOIN POA_Associates ON POA_PendingLog.OwnerID = POA_Associates.UserID
WHERE DATENAME(year, [PendingDate]) = 2018 AND MONTH([PendingDate]) = 1

UNION

SELECT 
	TrilAcctName
	,POA_Associates.FullName
	,POA_DoneYear AS POA_Year
	,POA_DoneMonthNum AS POA_MonthNum 
	,POA_DoneMonth AS POA_Month 
	,POA_DoneWeek AS POA_Week
FROM POA_BasicReporting INNER JOIN POA_Associates ON POA_BasicReporting.OwnerID = POA_Associates.UserID
WHERE POA_DoneYear = 2018 AND POA_DoneMonthNum = 1) AS TempTrilUserCalendarDim

LEFT JOIN 
(SELECT 
       TrilAcctName
      ,POA_Associates.FullName
	  ,DATENAME(year, [PendingDate]) AS POA_PendingYear 
	  ,MONTH([PendingDate]) AS POA_PendingMonthNum 
	  ,DATENAME(month, [PendingDate]) AS POA_PendingMonth 
	  ,DATEPART(wk, [PendingDate]) AS POA_PendingWeek
      ,COUNT([POANum]) AS CountOfPendingPOA_Num
	  ,SUM(CurrPOA_Amt - OrigPOA_Amt) AS SumOfPOA_AmtAdjustment
  FROM [dbo].[POA_PendingLog] INNER JOIN POA_Associates ON POA_PendingLog.OwnerID = POA_Associates.UserID
  WHERE DATENAME(year, [PendingDate]) = 2018 AND MONTH([PendingDate]) = 1
  GROUP BY TrilAcctName, POA_Associates.FullName, DATENAME(year, [PendingDate]) ,MONTH([PendingDate]) ,DATENAME(month, [PendingDate]) ,DATEPART(wk, [PendingDate]))
  AS POA_PendingSummary 
  ON POA_PendingSummary.TrilAcctName = TempTrilUserCalendarDim.TrilAcctName AND POA_PendingSummary.FullName = TempTrilUserCalendarDim.FullName AND POA_PendingSummary.POA_PendingMonthNum = TempTrilUserCalendarDim.POA_MonthNum AND POA_PendingSummary.POA_PendingWeek = TempTrilUserCalendarDim.POA_Week AND POA_PendingSummary.POA_PendingYear = TempTrilUserCalendarDim.POA_Year
LEFT JOIN
(SELECT 
	 TrilAcctName
	,POA_Associates.FullName
	,POA_DoneYear
	,POA_DoneMonthNum
	,POA_DoneMonth
	,POA_DoneWeek
	,COUNT(POA_Num) AS CountOfDonePOA_Num
	,SUM(OrigPOA_Amt*-1) AS SumOfOrigPOA_Amt
FROM POA_BasicReporting INNER JOIN POA_Associates ON POA_BasicReporting.OwnerID = POA_Associates.UserID
WHERE POA_DoneYear = 2018 AND POA_DoneMonthNum = 1
GROUP BY TrilAcctName, POA_Associates.FullName, POA_DoneYear, POA_DoneMonthNum, POA_DoneMonth, POA_DoneWeek)
AS POA_DoneSummary
ON POA_DoneSummary.TrilAcctName = TempTrilUserCalendarDim.TrilAcctName AND POA_DoneSummary.FullName = TempTrilUserCalendarDim.FullName AND POA_DoneSummary.POA_DoneMonthNum = TempTrilUserCalendarDim.POA_MonthNum AND POA_DoneSummary.POA_DoneWeek = TempTrilUserCalendarDim.POA_Week AND POA_DoneSummary.POA_DoneYear = TempTrilUserCalendarDim.POA_Year
GO

USE [SharedServices]
GO
SELECT *
FROM CalendarDim
--WHERE [Date] >=DATEADD(month,-12,DATEADD(day,DATEDIFF(day,0,GETDATE()),0)) AND [Date] <=DATEADD(day,DATEDIFF(day,0,GETDATE()),0)
WHERE (((CalendarDim.[Date])>=DateAdd(month,DateDiff(month,'1/1/1901',GetDate()),'1/1/1900') And (CalendarDim.[Date])<DateAdd(month,DateDiff(month,'1/1/1900',GetDate()),'1/1/1900')))
GO

USE [SharedServices]
GO
SELECT COUNT(POA_Num) AS CountOfPOA_NumInserted, TrilAcctName, CONVERT(DATE,[InsertDate]) AS InsertDate, SUM(OrigPOA_Amt) AS SumOfOrigPOA_Amt
FROM POA_BasicReporting
GROUP BY TrilAcctName, InsertDate
GO

USE [SharedServices]
GO
SELECT COUNT([POANum]) AS CountOfPendingClicks
      ,TrilAcctName
	  ,CONVERT(date,[PendingDate]) AS PendingDate
      ,POA_Associates.FullName
	  ,SUM(CurrPOA_Amt)*-1 AS SumOfPendingCurrPOA_AmtClicked
	  ,SUM(AmtAllocated) AS SumOfAmtAllocated
FROM POA_PendingLog INNER JOIN POA_Associates ON POA_PendingLog.OwnerID = POA_Associates.UserID
GROUP BY TrilAcctName, POA_Associates.FullName, CONVERT(DATE, PendingDate)
ORDER BY PendingDate
GO

USE [SharedServices]
GO
SELECT COUNT(POA_Num) AS CountOfDonePOA_Num
	,TrilAcctName
	,POA_Associates.FullName
	,CONVERT(DATE, EndDate) AS CompletedDate 
	,SUM(CurrPOA_Amt*-1) AS SumOfFinalPOA_Amt
FROM POA_BasicReporting INNER JOIN POA_Associates ON POA_BasicReporting.OwnerID = POA_Associates.UserID
WHERE EndDate IS NOT NULL
GROUP BY TrilAcctName, POA_Associates.FullName, CONVERT(DATE, EndDate)
GO


USE [SharedServices]
GO
SELECT [Date], 
       WeekOfYear, 
       FiscalWeekOfYear, 
       Month, 
       FiscalMonth, 
       MonthName, 
       Quarter, 
       FiscalQuarter, 
       QuarterName, 
       FiscalQuarterName, 
       Year, 
       FiscalYear, 
       MMYYYY, 
       FiscalMMYYYY, 
       MonthYear
FROM CalendarDim
WHERE (((CalendarDim.[Date])>=DateAdd(month,DateDiff(month,'2/1/1901',GetDate()),'1/1/1900') 
AND (CalendarDim.[Date])<=GetDate()))

SELECT COUNT(POA_Num) AS CountOfPOA_NumInserted, 
       TrilAcctName, 
       CONVERT(date,[InsertDate]) AS InsertDate, 
       SUM(OrigPOA_Amt) AS SumOfOrigPOA_Amt
FROM POA_BasicReporting
WHERE (((InsertDate)>=DateAdd(month,DateDiff(month,'2/1/1901',GetDate()),'1/1/1900') 
AND (InsertDate)<=GetDate()))
GROUP BY TrilAcctName, CONVERT(date,[InsertDate])
ORDER BY InsertDate, TrilAcctName

SELECT COUNT([POANum]) AS CountOfPendingClicks, 
       TrilAcctName, 
       CONVERT(date,[PendingDate]) AS PendingDate, 
       SUM(CurrPOA_Amt)*-1 AS SumOfPendingCurrPOA_AmtClicked, 
       SUM(AmtAllocated) AS SumOfAmtAllocated
FROM POA_PendingLog 
WHERE (((PendingDate)>=DateAdd(month,DateDiff(month,'2/1/1901',GetDate()),'1/1/1900') 
AND (PendingDate)<=GetDate()))
GROUP BY TrilAcctName, CONVERT(date, PendingDate)
ORDER BY PendingDate, TrilAcctName

SELECT COUNT(POA_Num) AS CountOfDonePOA_Num, 
       TrilAcctName, 
       CONVERT(DATE, EndDate) AS CompletedDate, 
       SUM(CurrPOA_Amt*-1) AS SumOfFinalPOA_Amt
FROM POA_BasicReporting
WHERE EndDate IS NOT NULL AND (((EndDate)>=DateAdd(month,DateDiff(month,'2/1/1901',GetDate()),'1/1/1900') 
AND (EndDate)<=GetDate()))
GROUP BY TrilAcctName, CONVERT(date, EndDate)
ORDER BY CompletedDate, TrilAcctName

GO

USE [SharedServices]
GO
SELECT [Date], 
       WeekOfYear, 
       FiscalWeekOfYear, 
       Month, 
       FiscalMonth, 
       MonthName, 
       Quarter, 
       FiscalQuarter, 
       QuarterName, 
       FiscalQuarterName, 
       Year, 
       FiscalYear, 
       MMYYYY, 
       FiscalMMYYYY, 
       MonthYear
FROM CalendarDim 
INNER JOIN 
(SELECT COUNT(POA_Num) AS CountOfPOA_NumInserted, 
        TrilAcctName, 
        CONVERT(date,[InsertDate]) AS InsertDate, 
        SUM(OrigPOA_Amt) AS SumOfOrigPOA_Amt
FROM POA_BasicReporting
WHERE (((InsertDate)>=DateAdd(month,DateDiff(month,'2/1/1901',GetDate()),'1/1/1900') 
AND (InsertDate)<=GetDate()))
GROUP BY TrilAcctName, CONVERT(date,[InsertDate])
ORDER BY InsertDate, TrilAcctName) AS POA_Inserted
 ON CalendarDim.[Date] = POA_Inserted.InsertDate
INNER JOIN
(SELECT COUNT([POANum]) AS CountOfPendingClicks, 
        TrilAcctName, 
        CONVERT(date,[PendingDate]) AS PendingDate, 
        SUM(CurrPOA_Amt)*-1 AS SumOfPendingCurrPOA_AmtClicked, 
        SUM(AmtAllocated) AS SumOfAmtAllocated
FROM POA_PendingLog 
WHERE (((PendingDate)>=DateAdd(month,DateDiff(month,'2/1/1901',GetDate()),'1/1/1900') 
AND (PendingDate)<=GetDate()))
GROUP BY TrilAcctName, CONVERT(date, PendingDate)
ORDER BY PendingDate, TrilAcctName) AS POA_PendingClicked
ON CalendarDim.[Date] = POA_PendingClicked.PendingDate
INNER JOIN
(SELECT COUNT(POA_Num) AS CountOfDonePOA_Num, 
        TrilAcctName, 
        CONVERT(DATE, EndDate) AS CompletedDate, 
        SUM(CurrPOA_Amt*-1) AS SumOfFinalPOA_Amt
FROM POA_BasicReporting
WHERE EndDate IS NOT NULL AND (((EndDate)>=DateAdd(month,DateDiff(month,'2/1/1901',GetDate()),'1/1/1900') 
AND (EndDate)<=GetDate()))
GROUP BY TrilAcctName, CONVERT(date, EndDate)
ORDER BY CompletedDate, TrilAcctName) AS POA_Done
ON CalendarDim.[Date] = POA_Done.CompletedDate

GO

--       POA_Inserted.CountOfPOA_NumInserted,
--       POA_Inserted.SumOfOrigPOA_Amt,
--       POA_PendingClicked.CountOfPendingClicks,
--       POA_PendingClicked.SumOfPendingCurrPOA_AmtClicked,
--       POA_PendingClicked.SumOfAmtAllocated,
--       POA_Done.CountOfDonePOA_Num,
--       POA_Done.SumOfFinalPOA_Amt

USE [SharedServices]
GO

SELECT  TrilAcctName, 
        CONVERT(date,[InsertDate]) AS CombinedDate 
FROM POA_BasicReporting
WHERE (((InsertDate)>=DateAdd(month,DateDiff(month,'2/1/1901',GetDate()),'1/1/1900') 
AND (InsertDate)<=GetDate()))
GROUP BY TrilAcctName, CONVERT(date,[InsertDate])
UNION
SELECT  TrilAcctName, 
        CONVERT(date,[PendingDate]) AS CombinedDate
FROM POA_PendingLog 
WHERE (((PendingDate)>=DateAdd(month,DateDiff(month,'2/1/1901',GetDate()),'1/1/1900') 
AND (PendingDate)<=GetDate()))
GROUP BY TrilAcctName, CONVERT(date, PendingDate)
UNION
SELECT  TrilAcctName, 
        CONVERT(DATE, EndDate) AS CombinedDate
FROM POA_BasicReporting
WHERE EndDate IS NOT NULL AND (((EndDate)>=DateAdd(month,DateDiff(month,'2/1/1901',GetDate()),'1/1/1900') 
AND (EndDate)<=GetDate()))
GROUP BY TrilAcctName, CONVERT(date, EndDate)
ORDER BY TrilAcctName, CombinedDate 
GO

USE [SharedServices]
GO

SELECT TempAcctNDate.TrilAcctName,
       TempAcctNDate.CombinedDate,
       CalendarDim.WeekOfYear, 
       CalendarDim.FiscalWeekOfYear, 
       CalendarDim.Month, 
       CalendarDim.FiscalMonth, 
       CalendarDim.MonthNamE, 
       CalendarDim.Quarter, 
       CalendarDim.FiscalQuarter, 
       CalendarDim.QuarterName, 
       CalendarDim.FiscalQuarterName, 
       CalendarDim.Year, 
       CalendarDim.FiscalYear, 
       CalendarDim.MMYYYY, 
       CalendarDim.FiscalMMYYYY, 
       CalendarDim.MonthYear,
       POA_Inserted.CountOfPOA_NumInserted,
       POA_Inserted.SumOfOrigPOA_Amt,
       POA_PendingClicked.CountOfPendingClicks,
       POA_PendingClicked.SumOfPendingCurrPOA_AmtClicked,
       POA_PendingClicked.SumOfAmtAllocated,
       POA_Done.CountOfDonePOA_Num,
       POA_Done.SumOfFinalPOA_Amt
FROM 
(SELECT [Date], 
       WeekOfYear, 
       FiscalWeekOfYear, 
       Month, 
       FiscalMonth, 
       MonthName, 
       Quarter, 
       FiscalQuarter, 
       QuarterName, 
       FiscalQuarterName, 
       Year, 
       FiscalYear, 
       MMYYYY, 
       FiscalMMYYYY, 
       MonthYear
FROM CalendarDim
WHERE (((CalendarDim.[Date])>=DateAdd(month,DateDiff(month,'2/1/1901',GetDate()),'1/1/1900') 
AND (CalendarDim.[Date])<=GetDate())))  AS CalendarDim
INNER JOIN
(SELECT  TrilAcctName, 
        CONVERT(date,[InsertDate]) AS CombinedDate 
FROM POA_BasicReporting
WHERE (((InsertDate)>=DateAdd(month,DateDiff(month,'2/1/1901',GetDate()),'1/1/1900') 
AND (InsertDate)<=GetDate()))
GROUP BY TrilAcctName, CONVERT(date,[InsertDate])
UNION
SELECT  TrilAcctName, 
        CONVERT(date,[PendingDate]) AS CombinedDate
FROM POA_PendingLog 
WHERE (((PendingDate)>=DateAdd(month,DateDiff(month,'2/1/1901',GetDate()),'1/1/1900') 
AND (PendingDate)<=GetDate()))
GROUP BY TrilAcctName, CONVERT(date, PendingDate)
UNION
SELECT  TrilAcctName, 
        CONVERT(DATE, EndDate) AS CombinedDate
FROM POA_BasicReporting
WHERE EndDate IS NOT NULL AND (((EndDate)>=DateAdd(month,DateDiff(month,'2/1/1901',GetDate()),'1/1/1900') 
AND (EndDate)<=GetDate()))
GROUP BY TrilAcctName, CONVERT(date, EndDate)) AS TempAcctNDate
ON CalendarDim.[Date] = TempAcctNDate.CombinedDate
LEFT JOIN
(SELECT COUNT(POA_Num) AS CountOfPOA_NumInserted, 
        TrilAcctName, 
        CONVERT(date,[InsertDate]) AS InsertDate, 
        SUM(OrigPOA_Amt) AS SumOfOrigPOA_Amt
FROM POA_BasicReporting
WHERE (((InsertDate)>=DateAdd(month,DateDiff(month,'2/1/1901',GetDate()),'1/1/1900') 
AND (InsertDate)<=GetDate()))
GROUP BY TrilAcctName, CONVERT(date,[InsertDate])) AS POA_Inserted
ON TempAcctNDate.CombinedDate = POA_Inserted.InsertDate AND TempAcctNDate.TrilAcctName = POA_Inserted.TrilAcctName
LEFT JOIN
(SELECT COUNT([POANum]) AS CountOfPendingClicks, 
        TrilAcctName, 
        CONVERT(date,[PendingDate]) AS PendingDate, 
        SUM(CurrPOA_Amt)*-1 AS SumOfPendingCurrPOA_AmtClicked, 
        SUM(AmtAllocated) AS SumOfAmtAllocated
FROM POA_PendingLog 
WHERE (((PendingDate)>=DateAdd(month,DateDiff(month,'2/1/1901',GetDate()),'1/1/1900') 
AND (PendingDate)<=GetDate()))
GROUP BY TrilAcctName, CONVERT(date, PendingDate)) AS POA_PendingClicked
ON      TempAcctNDate.CombinedDate = POA_PendingClicked.PendingDate AND TempAcctNDate.TrilAcctName = POA_PendingClicked.TrilAcctName
LEFT JOIN
(SELECT COUNT(POA_Num) AS CountOfDonePOA_Num, 
        TrilAcctName, 
        CONVERT(DATE, EndDate) AS CompletedDate, 
        SUM(CurrPOA_Amt*-1) AS SumOfFinalPOA_Amt
FROM POA_BasicReporting
WHERE EndDate IS NOT NULL AND (((EndDate)>=DateAdd(month,DateDiff(month,'2/1/1901',GetDate()),'1/1/1900') 
AND (EndDate)<=GetDate()))
GROUP BY TrilAcctName, CONVERT(date, EndDate)) AS POA_Done
ON TempAcctNDate.CombinedDate = POA_Done.CompletedDate AND TempAcctNDate.TrilAcctName = POA_Done.TrilAcctName
GO