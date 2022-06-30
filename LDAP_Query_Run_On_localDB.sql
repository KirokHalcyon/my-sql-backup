--This part is needed once - not sure exactly what it changes
/**
USE [master]
GO
sp_configure 'show advanced options',1
GO
reconfigure with override
GO
sp_configure 'Ad Hoc Distributed Queries',1
GO
reconfigure with override
GO
**/

/* Look for a person by Username*/
SELECT *
FROM 
OPENROWSET('ADSDSOObject','adsdatasource' ,
'SELECT  Name, displayName, givenname,distinguishedName, SAMAccountName, mail, department, manager, title
    FROM ''LDAP://DC=DS,DC=WOLSELEY,DC=COM'' 
    WHERE sAMAccountName = ''AAJ5744'' or sAMAccountName = ''AAD1013'' ')
GO

/* Look for all persons in departments*/
SELECT *
FROM 
OPENROWSET('ADSDSOObject','adsdatasource' ,
'SELECT  Name, displayName, givenname,distinguishedName, SAMAccountName, mail, department, manager, title
    FROM ''LDAP://DC=DS,DC=WOLSELEY,DC=COM'' 
    WHERE mail = ''*'' and (department = ''0266*'' or department = ''9114*'' or department = ''9115*'' or department = ''9116*'' or department = ''9117*'' or department = ''9118*'' ) ')
GO



/* Look for all persons in departments*/
SELECT *
FROM 
OPENROWSET('ADSDSOObject','adsdatasource' ,
'SELECT  Name, displayName, givenname,distinguishedName, SAMAccountName, mail, department, manager, title
    FROM ''LDAP://DC=DS,DC=WOLSELEY,DC=COM'' 
    WHERE manager = ''CN=AAA7469 Kurtvin Brown,OU=Users,OU=Ferguson,OU=WOS Operating Companies,DC=DS,DC=WOLSELEY,DC=COM''')
GO

--CN=AAA7469 Kurtvin Brown,OU=Users,OU=Ferguson,OU=WOS Operating Companies,DC=DS,DC=WOLSELEY,DC=COM