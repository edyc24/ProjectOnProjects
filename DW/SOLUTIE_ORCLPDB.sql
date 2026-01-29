-- =====================================================
-- SOLUȚIE COMPLETĂ PENTRU ORCLPDB
-- =====================================================

-- 1. Verifică că ești în ORCLPDB
SELECT SYS_CONTEXT('USERENV', 'CON_NAME') FROM DUAL;
-- Ar trebui să vezi: ORCLPDB

-- 2. Creează tablespace în ORCLPDB
CREATE TABLESPACE moneyshop_dw_ts
    DATAFILE 'moneyshop_dw_ts.dbf' SIZE 500M
    AUTOEXTEND ON NEXT 100M MAXSIZE 2G
    EXTENT MANAGEMENT LOCAL
    SEGMENT SPACE MANAGEMENT AUTO;

-- 3. Creează utilizatorul
CREATE USER moneyshop_dw_user IDENTIFIED BY "MoneyShopDW2025!"
    DEFAULT TABLESPACE moneyshop_dw_ts
    TEMPORARY TABLESPACE temp
    QUOTA UNLIMITED ON moneyshop_dw_ts;

-- 4. Grant privilegii
GRANT CONNECT, RESOURCE TO moneyshop_dw_user;
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE PROCEDURE,
      CREATE SEQUENCE, CREATE DIMENSION, CREATE MATERIALIZED VIEW 
      TO moneyshop_dw_user;

-- 5. Verifică unde sunt tabelele OLTP
-- Rulează această comandă pentru a vedea în ce schemă sunt tabelele
SELECT OWNER, TABLE_NAME 
FROM ALL_TABLES 
WHERE TABLE_NAME IN ('UTILIZATORI', 'ROLURI', 'BANCI', 'APLICATII', 'APPLICATION_BANKS', 'MANDATE')
ORDER BY OWNER, TABLE_NAME;

-- 6. Dacă tabelele sunt în CDB ROOT (SYS), trebuie să le copiezi în ORCLPDB
-- SAU să creezi tabelele direct în ORCLPDB

-- Verifică dacă tabelele există deja în ORCLPDB
SELECT COUNT(*) as tabel_count
FROM USER_TABLES
WHERE TABLE_NAME IN ('UTILIZATORI', 'ROLURI', 'BANCI', 'APLICATII', 'APPLICATION_BANKS', 'MANDATE');

-- Dacă nu există, trebuie să creezi tabelele în ORCLPDB
-- Rulează: @OracleDatabase/03_CREATE_TABLES.sql în ORCLPDB

-- 7. După ce tabelele există în ORCLPDB, grant SELECT
-- (înlocuiește OWNER cu schema corectă din rezultatul de la pasul 5)
-- GRANT SELECT ON <OWNER>.UTILIZATORI TO moneyshop_dw_user;
-- GRANT SELECT ON <OWNER>.ROLURI TO moneyshop_dw_user;
-- GRANT SELECT ON <OWNER>.APLICATII TO moneyshop_dw_user;
-- GRANT SELECT ON <OWNER>.BANCI TO moneyshop_dw_user;
-- GRANT SELECT ON <OWNER>.APPLICATION_BANKS TO moneyshop_dw_user;
-- GRANT SELECT ON <OWNER>.MANDATE TO moneyshop_dw_user;

-- 8. Verifică utilizatorul creat
SELECT USERNAME FROM DBA_USERS WHERE USERNAME = 'MONEYSHOP_DW_USER';

