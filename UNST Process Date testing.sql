SELECT *
FROM dbo.UNST_ZNST 
WHERE
(SELECT COUNT(*) AS Expr1 
FROM dbo.CalendarDim 
WHERE (dbo.CalendarDim.Date Between dbo.UNST_ZNST.PROCESS_DATE AND GetDate()) AND (dbo.CalendarDim.IsWeekend = 0) AND (dbo.CalendarDim.IsHoliday = 0)) <= 5
ORDER BY PROCESS_DATE