USE [SharedServices]
GO

SELECT COUNT([POA_Num]) AS CountOfPOANum
      ,[TrilAcctName]
      ,SUM([OrigPOA_Amt]) AS SumOfOrigPOA_Amt
      ,SUM([CurrPOA_Amt]) AS SumOfCurrPOA_Amt
      ,[OwnerID]
      ,[POA_DoneMonthNum]
      ,[POA_DoneMonth]
      ,[POA_DoneWeek]
  FROM [dbo].[POA_BasicReporting]
  WHERE CurrStatus = 'Done'
  GROUP BY TrilAcctName, OwnerID, [POA_DoneYear], [POA_DoneMonthNum], [POA_DoneMonth], [POA_DoneWeek]
  ORDER BY TrilAcctName, OwnerID
GO


