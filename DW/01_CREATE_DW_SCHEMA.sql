DECLARE
    v_is_cdb VARCHAR2(3);
    v_container_name VARCHAR2(128);
BEGIN
    SELECT CDB INTO v_is_cdb FROM V$DATABASE;
    SELECT SYS_CONTEXT('USERENV', 'CON_NAME') INTO v_container_name FROM DUAL;
    DBMS_OUTPUT.PUT_LINE('Tip database: ' || CASE WHEN v_is_cdb = 'YES' THEN 'CDB' ELSE 'Non-CDB' END);
    DBMS_OUTPUT.PUT_LINE('Container: ' || v_container_name);
    IF v_is_cdb = 'YES' AND v_container_name = 'CDB$ROOT' THEN
        DBMS_OUTPUT.PUT_LINE('⚠ Ești în CDB ROOT. Trebuie să fii într-un PDB!');
        DBMS_OUTPUT.PUT_LINE('   Rulează: ALTER SESSION SET CONTAINER = XEPDB1; (sau numele PDB-ului tău)');
    END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'CREATE TABLESPACE moneyshop_dw_ts
        DATAFILE ''moneyshop_dw_ts.dbf'' SIZE 500M
        AUTOEXTEND ON NEXT 100M MAXSIZE 2G
        EXTENT MANAGEMENT LOCAL
        SEGMENT SPACE MANAGEMENT AUTO';
    DBMS_OUTPUT.PUT_LINE('✓ Tablespace MONEYSHOP_DW_TS creat cu succes');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -1543 THEN
            DBMS_OUTPUT.PUT_LINE('⚠ Tablespace MONEYSHOP_DW_TS există deja');
        ELSE
            DBMS_OUTPUT.PUT_LINE('⚠ Eroare la creare tablespace: ' || SQLERRM);
        END IF;
END;
/
DECLARE
    v_is_cdb VARCHAR2(3);
    v_container_name VARCHAR2(128);
    v_user_name VARCHAR2(128) := 'moneyshop_dw_user';
BEGIN
    SELECT CDB INTO v_is_cdb FROM V$DATABASE;
    SELECT SYS_CONTEXT('USERENV', 'CON_NAME') INTO v_container_name FROM DUAL;
    IF v_is_cdb = 'YES' AND v_container_name = 'CDB$ROOT' THEN
        DBMS_OUTPUT.PUT_LINE('⚠ EROARE: Nu poți crea utilizator local în CDB ROOT!');
        DBMS_OUTPUT.PUT_LINE('   Soluție: ALTER SESSION SET CONTAINER = XEPDB1; (sau numele PDB-ului)');
        DBMS_OUTPUT.PUT_LINE('   Apoi rulează din nou acest script.');
        RAISE_APPLICATION_ERROR(-20001, 'Trebuie să fii într-un PDB pentru a crea utilizator local');
    END IF;
    BEGIN
        EXECUTE IMMEDIATE 'CREATE USER ' || v_user_name || ' IDENTIFIED BY "MoneyShopDW2025!"
            DEFAULT TABLESPACE moneyshop_dw_ts
            TEMPORARY TABLESPACE temp
            QUOTA UNLIMITED ON moneyshop_dw_ts';
        DBMS_OUTPUT.PUT_LINE('✓ Utilizator ' || v_user_name || ' creat cu succes');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -1920 THEN
                DBMS_OUTPUT.PUT_LINE('⚠ Utilizator ' || v_user_name || ' există deja');
            ELSIF SQLCODE = -65096 THEN
                DBMS_OUTPUT.PUT_LINE('⚠ EROARE: Oracle CDB necesită prefix C## pentru utilizatori comuni');
                DBMS_OUTPUT.PUT_LINE('   Sau creează utilizator local într-un PDB');
                DBMS_OUTPUT.PUT_LINE('   Soluție: ALTER SESSION SET CONTAINER = XEPDB1;');
                RAISE;
            ELSE
                DBMS_OUTPUT.PUT_LINE('⚠ Eroare la creare utilizator: ' || SQLERRM);
                RAISE;
            END IF;
    END;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'GRANT CONNECT, RESOURCE TO moneyshop_dw_user';
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO moneyshop_dw_user';
    EXECUTE IMMEDIATE 'GRANT CREATE TABLE TO moneyshop_dw_user';
    EXECUTE IMMEDIATE 'GRANT CREATE VIEW TO moneyshop_dw_user';
    EXECUTE IMMEDIATE 'GRANT CREATE PROCEDURE TO moneyshop_dw_user';
    EXECUTE IMMEDIATE 'GRANT CREATE SEQUENCE TO moneyshop_dw_user';
    EXECUTE IMMEDIATE 'GRANT CREATE DIMENSION TO moneyshop_dw_user';
    EXECUTE IMMEDIATE 'GRANT CREATE MATERIALIZED VIEW TO moneyshop_dw_user';
    DBMS_OUTPUT.PUT_LINE('✓ Privilegii de bază acordate');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('⚠ Eroare la grant privilegii: ' || SQLERRM);
END;
/
DECLARE
    v_oltp_schema VARCHAR2(128);
    v_table_count NUMBER;
    v_user_name VARCHAR2(128) := 'moneyshop_dw_user';
BEGIN
    SELECT OWNER INTO v_oltp_schema
    FROM (
        SELECT OWNER, COUNT(*) as cnt
        FROM ALL_TABLES
        WHERE TABLE_NAME IN ('UTILIZATORI', 'ROLURI', 'BANCI', 'APLICATII', 'APPLICATION_BANKS', 'MANDATE')
        GROUP BY OWNER
        ORDER BY cnt DESC
    )
    WHERE ROWNUM = 1;
    DBMS_OUTPUT.PUT_LINE('✓ Schema OLTP detectată: ' || v_oltp_schema);
    BEGIN
        EXECUTE IMMEDIATE 'GRANT SELECT ON ' || v_oltp_schema || '.UTILIZATORI TO ' || v_user_name;
        EXECUTE IMMEDIATE 'GRANT SELECT ON ' || v_oltp_schema || '.ROLURI TO ' || v_user_name;
        EXECUTE IMMEDIATE 'GRANT SELECT ON ' || v_oltp_schema || '.APLICATII TO ' || v_user_name;
        EXECUTE IMMEDIATE 'GRANT SELECT ON ' || v_oltp_schema || '.BANCI TO ' || v_user_name;
        EXECUTE IMMEDIATE 'GRANT SELECT ON ' || v_oltp_schema || '.APPLICATION_BANKS TO ' || v_user_name;
        EXECUTE IMMEDIATE 'GRANT SELECT ON ' || v_oltp_schema || '.MANDATE TO ' || v_user_name;
        DBMS_OUTPUT.PUT_LINE('✓ Privilegii SELECT pe tabele OLTP acordate');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('⚠ Eroare la grant SELECT: ' || SQLERRM);
            DBMS_OUTPUT.PUT_LINE('   Schema detectată: ' || v_oltp_schema);
    END;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('⚠ EROARE: Nu s-au găsit tabelele OLTP!');
        DBMS_OUTPUT.PUT_LINE('   Verifică că ai rulat OracleDatabase/03_CREATE_TABLES.sql');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('⚠ Eroare la detectare schema OLTP: ' || SQLERRM);
END;
/
BEGIN
    EXECUTE IMMEDIATE 'ALTER SESSION SET CURRENT_SCHEMA = moneyshop_dw_user';
    DBMS_OUTPUT.PUT_LINE('✓ Schema curentă setată la moneyshop_dw_user');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('⚠ Eroare la setare schema: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('⚠ Poți continua manual cu: ALTER SESSION SET CURRENT_SCHEMA = moneyshop_dw_user');
END;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('SCHEMA DW CREATĂ CU SUCCES!');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Utilizator: moneyshop_dw_user');
    DBMS_OUTPUT.PUT_LINE('Tablespace: moneyshop_dw_ts');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Următorul pas: Rulează 02_POPULATE_OLTP_TEST_DATA.sql');
    DBMS_OUTPUT.PUT_LINE('(dacă nu ai deja date în OLTP)');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Sau conectează-te ca moneyshop_dw_user pentru următoarele scripturi');
    DBMS_OUTPUT.PUT_LINE('');
END;
/