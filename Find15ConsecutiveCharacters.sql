USE [FergusonAccounting]
GO

SELECT 
       [FileName]
      ,[PRODUCT.VENDOR_CODE]
      ,[PRODUCT.FEI_MASTER_PRODUCT_CODE]
  FROM [dbo].[EDI_HEADER_ALL_DETAIL]
WHERE [PRODUCT.VENDOR_CODE] LIKE '[A-Za-z0-9][A-Za-z0-9][A-Za-z0-9][A-Za-z0-9][A-Za-z0-9][A-Za-z0-9][A-Za-z0-9][A-Za-z0-9][A-Za-z0-9][A-Za-z0-9][A-Za-z0-9][A-Za-z0-9][A-Za-z0-9][A-Za-z0-9][A-Za-z0-9]'
GO


