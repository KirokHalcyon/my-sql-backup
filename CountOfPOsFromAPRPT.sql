
SELECT 
    TrilAcctName,
    Count(PO_Num) As CountOfPO_Num,
    PO_Type,
    Sum(DaysOnHold) As SumOfDaysOnHold,
    CurrentStatus
FROM dbo.APRPT

GROUP BY TrilAcctName,
PO_Type,
CurrentStatus