USE [SharedServices]
GO

SELECT [POANum]
      ,[TrilAcctName]
      ,[OwnerID]
      ,[PendingDate]
      ,[OrigPOA_Amt]
      ,[CurrPOA_Amt]
      ,[AmtAllocated]
  FROM [dbo].[POA_PendingLog]
  WHERE
	AmtAllocated <> 0 or AmtAllocated <> NULL
GO


