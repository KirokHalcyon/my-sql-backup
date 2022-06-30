SELECT 
	POA_PendingLog.POANum AS PendingPOANum, 
	TrilAcctName AS PendingTrilAcctName, 
	OwnerID AS PendingOwnerID, 
	PendingDate, 
	OrigPOA_Amt AS PendingOrigPOA_Amt, 
	CurrPOA_Amt AS PendingCurrPOA_Amt, 
	(CurrPOA_Amt - OrigPOA_Amt) AS POA_AmtDifference
FROM 
	POA_PendingLog
WHERE
	POANum NOT IN(SELECT INVOICE FROM POA_ZOAP WHERE [STATUS] <> 'Done') AND (CurrPOA_Amt - OrigPOA_Amt) <> 0