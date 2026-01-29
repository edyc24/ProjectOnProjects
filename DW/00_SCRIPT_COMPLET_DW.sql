-- =====================================================
-- SCRIPT COMPLET DW - MONEYSHOP
-- =====================================================
-- Descriere: Script unificat pentru crearea completă a Data Warehouse
-- Notă: Rulează scripturile în ordinea corectă
-- =====================================================

SET SERVEROUTPUT ON;
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS.FF';

BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('SCRIPT COMPLET DW - MONEYSHOP');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('NOTĂ: Acest script este un wrapper care');
    DBMS_OUTPUT.PUT_LINE('      rulează toate scripturile în ordine.');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Pentru execuție completă, rulează:');
    DBMS_OUTPUT.PUT_LINE('  1. 01_CREATE_DW_SCHEMA.sql (ca SYSDBA)');
    DBMS_OUTPUT.PUT_LINE('  2. 02_POPULATE_OLTP_TEST_DATA.sql (în OLTP)');
    DBMS_OUTPUT.PUT_LINE('  3. 03-12 scripturile în schema DW');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Sau rulează fiecare script individual.');
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- Acest script servește doar ca documentație
-- Rulează scripturile individuale în ordinea indicată

