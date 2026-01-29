-- =====================================================
-- FIX GRANT SELECT - ORCLPDB
-- =====================================================
-- Rulează acest script pentru a verifica schema și a face grant-urile corecte
-- =====================================================

-- 1. Verifică schema tabelelor OLTP
SELECT DISTINCT OWNER, TABLE_NAME 
FROM ALL_TABLES 
WHERE TABLE_NAME IN ('UTILIZATORI', 'ROLURI', 'BANCI', 'APLICATII', 'APPLICATION_BANKS', 'MANDATE')
ORDER BY OWNER, TABLE_NAME;

-- 2. Dacă vezi schema (de ex. SYS sau alt nume), rulează grant-urile de mai jos
-- Înlocuiește <SCHEMA> cu schema reală din rezultatul de mai sus

-- Exemplu dacă schema este SYS:
-- GRANT SELECT ON SYS.UTILIZATORI TO moneyshop_dw_user;
-- GRANT SELECT ON SYS.ROLURI TO moneyshop_dw_user;
-- GRANT SELECT ON SYS.APLICATII TO moneyshop_dw_user;
-- GRANT SELECT ON SYS.BANCI TO moneyshop_dw_user;
-- GRANT SELECT ON SYS.APPLICATION_BANKS TO moneyshop_dw_user;
-- GRANT SELECT ON SYS.MANDATE TO moneyshop_dw_user;

-- SAU dacă schema este alt nume (de ex. MONEYSHOP sau utilizatorul tău curent):
-- Verifică utilizatorul curent:
SELECT USER FROM DUAL;

-- Apoi folosește schema respectivă în grant-uri

