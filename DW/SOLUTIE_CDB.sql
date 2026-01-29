-- =====================================================
-- SOLUȚIE PENTRU CDB (Container Database)
-- =====================================================
-- Dacă nu ai PDB-uri, ai 2 opțiuni:
-- 1. Creează un PDB nou
-- 2. Folosește un utilizator comun cu prefixul C##
-- =====================================================

-- OPCIUNEA 1: Verifică ce PDB-uri există
SELECT PDB_NAME, STATUS FROM DBA_PDBS;

-- Dacă nu există PDB-uri, creează unul nou:
-- CREATE PLUGGABLE DATABASE MONEYSHOP_PDB
--     ADMIN USER moneyshop_admin IDENTIFIED BY "Admin123!"
--     FILE_NAME_CONVERT = ('/opt/oracle/oradata/XE/pdbseed/', '/opt/oracle/oradata/XE/moneyshop_pdb/');

-- Sau folosește OPCIUNEA 2 (mai simplu):

-- =====================================================
-- OPCIUNEA 2: Utilizator comun cu prefixul C##
-- =====================================================

-- Verifică prefixul necesar
SHOW PARAMETER COMMON_USER_PREFIX;

-- Creează utilizator comun (funcționează în CDB ROOT)
CREATE USER C##MONEYSHOP_DW_USER IDENTIFIED BY "MoneyShopDW2025!"
    DEFAULT TABLESPACE moneyshop_dw_ts
    TEMPORARY TABLESPACE temp
    QUOTA UNLIMITED ON moneyshop_dw_ts
    CONTAINER = ALL;

-- Grant privilegii
GRANT CONNECT, RESOURCE TO C##MONEYSHOP_DW_USER CONTAINER = ALL;
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE PROCEDURE,
      CREATE SEQUENCE, CREATE DIMENSION, CREATE MATERIALIZED VIEW 
      TO C##MONEYSHOP_DW_USER CONTAINER = ALL;

-- Grant SELECT pe tabelele OLTP (schema SYS)
GRANT SELECT ON SYS.UTILIZATORI TO C##MONEYSHOP_DW_USER;
GRANT SELECT ON SYS.ROLURI TO C##MONEYSHOP_DW_USER;
GRANT SELECT ON SYS.APLICATII TO C##MONEYSHOP_DW_USER;
GRANT SELECT ON SYS.BANCI TO C##MONEYSHOP_DW_USER;
GRANT SELECT ON SYS.APPLICATION_BANKS TO C##MONEYSHOP_DW_USER;
GRANT SELECT ON SYS.MANDATE TO C##MONEYSHOP_DW_USER;

-- Verifică
SELECT USERNAME FROM DBA_USERS WHERE USERNAME LIKE 'C##%';

