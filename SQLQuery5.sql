USE [SharedServices]
GO

SELECT COUNT ([POANum]) AS CountOfPOANum
      ,[TrilAcctName]
      ,[OwnerID]
  FROM [dbo].[POA_PendingLog]
  GROUP BY TrilAcctName, OwnerID
  ORDER BY TrilAcctName, OwnerID
GO


