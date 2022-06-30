SELECT TERMS, ACCOUNT_NAME, VENDOR_NK, ALPHA, VENDOR_NAME, ADDRESS1,
(
  SELECT 
    CASE 
    WHEN 
    (
      ACCOUNT_NAME NOT IN
      (
        SELECT ana_ACCOUNT_NAME
        FROM [dbo].DWFEI_ACCOUNT_NAME_ACCESS
        WHERE ana_ACCESS = 'N' OR ana_REPORT = 'N'
      ) 
      AND ACCOUNT_NUMBER_NK NOT IN ('390', '396', '664', '703', '1314') 
      AND ACCOUNT_NUMBER_NK NOT IN 
      ( 
        SELECT bl_branchid
        FROM [DS\7mag].branches_logons
        WHERE bl_branchid <> bl_branchtid
      )
    ) 
    THEN 
      'Y' 
    ELSE 
      'N' 
    END AS Expr1
) AS 'LOGON ACTIVE?',
(
  SELECT 
    CASE 
    WHEN DELETE_DATE IS NULL 
    THEN 
      'Y' 
    WHEN DELETE_DATE IS NOT NULL 
    THEN 
      'N' 
    END AS Expr1
) AS 'VENDOR ACTIVE?',
(
  SELECT 
    CASE 
    WHEN 
    (
      (
        ASCII(UPPER(LEFT(ISNULL(ALPHA, '..'), 1))) BETWEEN 48 AND 57 
        OR ASCII(UPPER(LEFT(ISNULL(ALPHA, '..'), 1))) BETWEEN 65 AND 90
      ) 
      AND 
      (
        (
          UPPER(LEFT(ISNULL(ALPHA, '..'), 2)) <> 'ZZ'
        )
      )
    ) 
    THEN 
      '<not hidden>' 
    ELSE 
      'HIDDEN' 
    END AS Expr1
) AS 'HIDE STATUS?', 
ISNULL(MASTER_VENDOR_PPQ_GK, 0) AS 'MASTER_VENDOR_GK'
FROM dbo.DWFEI_BRANCH_VENDOR_DIMENSION
WHERE (AP_DIV = 1)

UNION

SELECT TOP (100) PERCENT TERMS, ACCOUNT_NAME, VENDOR_NK, ALPHA, VENDOR_NAME, ADDRESS1,
(
  SELECT
    CASE 
    WHEN 
    (
      ACCOUNT_NAME NOT IN
      (
        SELECT ana_ACCOUNT_NAME
        FROM [dbo].DWFEI_ACCOUNT_NAME_ACCESS
        WHERE ana_ACCESS = 'N' OR ana_REPORT = 'N'
      ) 
      AND ACCOUNT_NUMBER_NK NOT IN ('390', '396', '664', '703', '1314') 
      AND ACCOUNT_NUMBER_NK NOT IN
      (
        SELECT bl_branchid
        FROM [DS\7mag].branches_logons
        WHERE bl_branchid <> bl_branchtid
      )
    ) 
    THEN 
      'Y' 
    ELSE 
      'N' 
    END AS Expr1
) AS 'LOGON ACTIVE?',
(
  SELECT 
    CASE 
    WHEN DELETE_DATE IS NULL 
    THEN 
      'Y' 
    WHEN DELETE_DATE IS NOT NULL 
    THEN 
      'N' 
    END AS Expr1
) AS 'VENDOR ACTIVE?',
(
  SELECT 
    CASE 
    WHEN 
    (
      (
        ASCII(UPPER(LEFT(ISNULL(ALPHA, '..'), 1))) BETWEEN 48 AND 57 
        OR ASCII(UPPER(LEFT(ISNULL(ALPHA, '..'), 1))) BETWEEN 65 AND 90
      ) 
      AND 
      (
        (
          UPPER(LEFT(ISNULL(ALPHA, '..'), 2)) <> 'ZZ'
        )
      )
    ) 
    THEN 
      '<not hidden>' 
    ELSE 
      'HIDDEN' 
    END AS Expr1
) AS 'HIDE STATUS?', 
ISNULL(MASTER_VENDOR_VIP_GK, 0) AS 'MASTER_VENDOR_GK'
FROM dbo.DWFEI_BRANCH_VENDOR_DIMENSION AS DWFEI_BRANCH_VENDOR_DIMENSION_1
WHERE (AP_DIV = 1)
ORDER BY TERMS, ACCOUNT_NAME, VENDOR_NK, ALPHA, 'MASTER_VENDOR_GK'