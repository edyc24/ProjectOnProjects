DECLARE
    v_schema_exists NUMBER;
    v_table_exists NUMBER;
    v_current_schema VARCHAR2(128);
BEGIN
    SELECT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') INTO v_current_schema FROM DUAL;
    DBMS_OUTPUT.PUT_LINE('Schema curentă: ' || v_current_schema);
    SELECT COUNT(*) INTO v_table_exists
    FROM USER_TABLES
    WHERE TABLE_NAME IN ('UTILIZATORI', 'ROLURI', 'BANCI', 'APLICATII');
    IF v_table_exists >= 4 THEN
        DBMS_OUTPUT.PUT_LINE('✓ Tabelele OLTP găsite în schema curentă');
    ELSE
        BEGIN
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURRENT_SCHEMA = MONEYSHOP';
            DBMS_OUTPUT.PUT_LINE('✓ Schema setată la MONEYSHOP');
            SELECT COUNT(*) INTO v_table_exists
            FROM ALL_TABLES
            WHERE OWNER = 'MONEYSHOP'
            AND TABLE_NAME IN ('UTILIZATORI', 'ROLURI', 'BANCI', 'APLICATII');
            IF v_table_exists < 4 THEN
                RAISE_APPLICATION_ERROR(-20001, 
                    'Eroare: Tabelele OLTP nu au fost găsite!' || CHR(10) ||
                    'Verifică:' || CHR(10) ||
                    '1. Schema OLTP există și se numește MONEYSHOP (sau modifică scriptul)' || CHR(10) ||
                    '2. Tabelele UTILIZATORI, ROLURI, BANCI, APLICATII există' || CHR(10) ||
                    '3. Rulează mai întâi OracleDatabase/03_CREATE_TABLES.sql pentru a crea tabelele');
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE_APPLICATION_ERROR(-20001, 
                    'Eroare: Nu s-a putut seta schema MONEYSHOP!' || CHR(10) ||
                    'Eroare: ' || SQLERRM || CHR(10) ||
                    'Soluție: Conectează-te direct ca utilizator al schemei OLTP sau modifică numele schemei în script');
        END;
    END IF;
END;
/
DECLARE
    v_count_users NUMBER;
    v_count_apps NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count_users FROM UTILIZATORI;
    SELECT COUNT(*) INTO v_count_apps FROM APLICATII;
    IF v_count_users >= 1000 AND v_count_apps >= 5000 THEN
        DBMS_OUTPUT.PUT_LINE('⚠ Există deja suficiente date în OLTP');
        DBMS_OUTPUT.PUT_LINE('   Utilizatori: ' || v_count_users);
        DBMS_OUTPUT.PUT_LINE('   Aplicații: ' || v_count_apps);
        DBMS_OUTPUT.PUT_LINE('   Scriptul va continua pentru a completa datele dacă e necesar');
    ELSE
        DBMS_OUTPUT.PUT_LINE('ℹ Generare date test OLTP...');
        DBMS_OUTPUT.PUT_LINE('   Utilizatori existente: ' || v_count_users);
        DBMS_OUTPUT.PUT_LINE('   Aplicații existente: ' || v_count_apps);
    END IF;
END;
/
INSERT INTO ROLURI (NumeRol, Descriere)
SELECT 'CLIENT', 'Utilizator standard care aplică pentru credite' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ROLURI WHERE NumeRol = 'CLIENT');
INSERT INTO ROLURI (NumeRol, Descriere)
SELECT 'BROKER', 'Broker autorizat care procesează cererile de credit' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ROLURI WHERE NumeRol = 'BROKER');
INSERT INTO ROLURI (NumeRol, Descriere)
SELECT 'ADMIN', 'Administrator cu acces complet la sistem' FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM ROLURI WHERE NumeRol = 'ADMIN');
COMMIT;
DECLARE
    v_id_client NUMBER;
    v_id_broker NUMBER;
    v_id_admin NUMBER;
BEGIN
    SELECT IdRol INTO v_id_client FROM ROLURI WHERE NumeRol = 'CLIENT';
    SELECT IdRol INTO v_id_broker FROM ROLURI WHERE NumeRol = 'BROKER';
    SELECT IdRol INTO v_id_admin FROM ROLURI WHERE NumeRol = 'ADMIN';
    DBMS_OUTPUT.PUT_LINE('✓ ID-uri roluri: CLIENT=' || v_id_client || ', BROKER=' || v_id_broker || ', ADMIN=' || v_id_admin);
END;
/
DECLARE
    v_id_client NUMBER;
    v_id_broker NUMBER;
    v_count_users NUMBER;
    v_target_users NUMBER := 1000;
    v_nume_list VARCHAR2(500) := 'Popescu,Ionescu,Popa,Radu,Stan,Constantinescu,Marinescu,Stoica,Nicolae,Florea';
    v_prenume_list VARCHAR2(500) := 'Ion,Maria,Gheorghe,Elena,Nicolae,Ana,Constantin,Mariana,Alexandru,Cristina';
    v_nume VARCHAR2(100);
    v_prenume VARCHAR2(100);
    v_email VARCHAR2(255);
    v_username VARCHAR2(50);
    v_parola_hash VARCHAR2(255) := 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3';
    v_data_nastere DATE;
    v_counter NUMBER := 0;
BEGIN
    SELECT IdRol INTO v_id_client FROM ROLURI WHERE NumeRol = 'CLIENT';
    SELECT IdRol INTO v_id_broker FROM ROLURI WHERE NumeRol = 'BROKER';
    SELECT COUNT(*) INTO v_count_users FROM UTILIZATORI;
    FOR i IN 1..50 LOOP
        v_nume := 'Broker' || i;
        v_prenume := 'Agent' || i;
        v_username := 'broker' || i;
        v_email := 'broker' || i || '@moneyshop.ro';
        v_data_nastere := ADD_MONTHS(SYSDATE, -ROUND(DBMS_RANDOM.VALUE(240, 840)));
        INSERT INTO UTILIZATORI (Nume, Prenume, Username, Email, Parola, DataNastere, IdRol, EmailVerified)
        VALUES (v_nume, v_prenume, v_username, v_email, v_parola_hash, v_data_nastere, v_id_broker, 1);
        v_counter := v_counter + 1;
    END LOOP;
    WHILE v_count_users + v_counter < v_target_users LOOP
        v_nume := 'Client' || (v_count_users + v_counter + 1);
        v_prenume := 'Test' || (v_count_users + v_counter + 1);
        v_username := 'client' || (v_count_users + v_counter + 1);
        v_email := 'client' || (v_count_users + v_counter + 1) || '@test.ro';
        v_data_nastere := ADD_MONTHS(SYSDATE, -ROUND(DBMS_RANDOM.VALUE(216, 816)));
        BEGIN
            INSERT INTO UTILIZATORI (Nume, Prenume, Username, Email, Parola, DataNastere, IdRol, EmailVerified)
            VALUES (v_nume, v_prenume, v_username, v_email, v_parola_hash, v_data_nastere, v_id_client, 1);
            v_counter := v_counter + 1;
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                NULL;
        END;
        IF MOD(v_counter, 100) = 0 THEN
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('   Generat ' || v_counter || ' utilizatori...');
        END IF;
    END LOOP;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✓ Generat ' || v_counter || ' utilizatori noi');
END;
/
INSERT INTO BANCI (Name, CommissionPercent, Active)
SELECT 'BCR', 2.5, 1 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM BANCI WHERE Name = 'BCR');
INSERT INTO BANCI (Name, CommissionPercent, Active)
SELECT 'BRD', 2.8, 1 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM BANCI WHERE Name = 'BRD');
INSERT INTO BANCI (Name, CommissionPercent, Active)
SELECT 'BT', 2.3, 1 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM BANCI WHERE Name = 'BT');
INSERT INTO BANCI (Name, CommissionPercent, Active)
SELECT 'ING', 2.6, 1 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM BANCI WHERE Name = 'ING');
INSERT INTO BANCI (Name, CommissionPercent, Active)
SELECT 'UniCredit', 2.7, 1 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM BANCI WHERE Name = 'UniCredit');
INSERT INTO BANCI (Name, CommissionPercent, Active)
SELECT 'Garanti BBVA', 2.4, 1 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM BANCI WHERE Name = 'Garanti BBVA');
COMMIT;
DECLARE
    v_id_client NUMBER;
    v_count_apps NUMBER;
    v_target_apps NUMBER := 5000;
    v_user_id NUMBER;
    v_status_list VARCHAR2(200) := 'INREGISTRAT,IN_PROCESARE,APROBAT,REFUZAT,ANULAT';
    v_type_credit_list VARCHAR2(200) := 'IPOTECAR,NEVOI_PERSONALE,REFINANTARE';
    v_tip_op_list VARCHAR2(100) := 'NOU,REFINANTARE';
    v_status VARCHAR2(50);
    v_type_credit VARCHAR2(50);
    v_tip_op VARCHAR2(50);
    v_salariu_net NUMBER;
    v_scoring NUMBER;
    v_dti NUMBER;
    v_suma_aprobata NUMBER;
    v_comision NUMBER;
    v_data_creare DATE;
    v_counter NUMBER := 0;
    CURSOR c_users IS SELECT IdUtilizator FROM UTILIZATORI WHERE IdRol = (SELECT IdRol FROM ROLURI WHERE NumeRol = 'CLIENT');
BEGIN
    SELECT IdRol INTO v_id_client FROM ROLURI WHERE NumeRol = 'CLIENT';
    SELECT COUNT(*) INTO v_count_apps FROM APLICATII;
    FOR user_rec IN c_users LOOP
        FOR i IN 1..DBMS_RANDOM.VALUE(1, 10) LOOP
            IF v_count_apps + v_counter >= v_target_apps THEN
                EXIT;
            END IF;
            v_status := CASE ROUND(DBMS_RANDOM.VALUE(1, 5))
                WHEN 1 THEN 'INREGISTRAT'
                WHEN 2 THEN 'IN_PROCESARE'
                WHEN 3 THEN 'APROBAT'
                WHEN 4 THEN 'REFUZAT'
                ELSE 'ANULAT'
            END;
            v_type_credit := CASE ROUND(DBMS_RANDOM.VALUE(1, 3))
                WHEN 1 THEN 'IPOTECAR'
                WHEN 2 THEN 'NEVOI_PERSONALE'
                ELSE 'REFINANTARE'
            END;
            v_tip_op := CASE ROUND(DBMS_RANDOM.VALUE(1, 2))
                WHEN 1 THEN 'NOU'
                ELSE 'REFINANTARE'
            END;
            v_salariu_net := ROUND(DBMS_RANDOM.VALUE(2000, 15000), 2);
            v_scoring := ROUND(DBMS_RANDOM.VALUE(300, 850), 2);
            v_dti := ROUND(DBMS_RANDOM.VALUE(0, 80), 2);
            IF v_status = 'APROBAT' THEN
                v_suma_aprobata := ROUND(DBMS_RANDOM.VALUE(10000, 200000), 2);
                v_comision := ROUND(v_suma_aprobata * 0.025, 2);
            ELSE
                v_suma_aprobata := NULL;
                v_comision := NULL;
            END IF;
            v_data_creare := SYSDATE - DBMS_RANDOM.VALUE(0, 730);
            INSERT INTO APLICATII (
                UserId, Status, TypeCredit, TipOperatiune,
                SalariuNet, Scoring, Dti, SumaAprobata, Comision,
                CreatedAt, UpdatedAt
            ) VALUES (
                user_rec.IdUtilizator, v_status, v_type_credit, v_tip_op,
                v_salariu_net, v_scoring, v_dti, v_suma_aprobata, v_comision,
                v_data_creare, v_data_creare + DBMS_RANDOM.VALUE(0, 30)
            );
            v_counter := v_counter + 1;
            IF MOD(v_counter, 500) = 0 THEN
                COMMIT;
                DBMS_OUTPUT.PUT_LINE('   Generat ' || v_counter || ' aplicații...');
            END IF;
        END LOOP;
        EXIT WHEN v_count_apps + v_counter >= v_target_apps;
    END LOOP;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✓ Generat ' || v_counter || ' aplicații noi');
END;
/
DECLARE
    v_count_assoc NUMBER;
    v_target_assoc NUMBER := 8000;
    v_app_id NUMBER;
    v_bank_id NUMBER;
    v_status_list VARCHAR2(100) := 'PENDING,APPROVED,REJECTED,CANCELLED';
    v_status VARCHAR2(50);
    v_counter NUMBER := 0;
    CURSOR c_apps IS SELECT Id FROM APLICATII;
    CURSOR c_banks IS SELECT Id FROM BANCI;
BEGIN
    SELECT COUNT(*) INTO v_count_assoc FROM APPLICATION_BANKS;
    FOR app_rec IN c_apps LOOP
        FOR i IN 1..DBMS_RANDOM.VALUE(1, 3) LOOP
            IF v_count_assoc + v_counter >= v_target_assoc THEN
                EXIT;
            END IF;
            SELECT Id INTO v_bank_id FROM (
                SELECT Id FROM BANCI ORDER BY DBMS_RANDOM.VALUE
            ) WHERE ROWNUM = 1;
            v_status := CASE ROUND(DBMS_RANDOM.VALUE(1, 4))
                WHEN 1 THEN 'PENDING'
                WHEN 2 THEN 'APPROVED'
                WHEN 3 THEN 'REJECTED'
                ELSE 'CANCELLED'
            END;
            BEGIN
                INSERT INTO APPLICATION_BANKS (ApplicationId, BankId, Status)
                VALUES (app_rec.Id, v_bank_id, v_status);
                v_counter := v_counter + 1;
            EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                    NULL;
            END;
        END LOOP;
        EXIT WHEN v_count_assoc + v_counter >= v_target_assoc;
        IF MOD(v_counter, 500) = 0 THEN
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('   Generat ' || v_counter || ' asocieri aplicație-bancă...');
        END IF;
    END LOOP;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✓ Generat ' || v_counter || ' asocieri aplicație-bancă noi');
END;
/
DECLARE
    v_count_mandates NUMBER;
    v_target_mandates NUMBER := 2000;
    v_user_id NUMBER;
    v_broker_id NUMBER;
    v_status VARCHAR2(50);
    v_counter NUMBER := 0;
    CURSOR c_users IS SELECT IdUtilizator FROM UTILIZATORI WHERE IdRol = (SELECT IdRol FROM ROLURI WHERE NumeRol = 'CLIENT');
    CURSOR c_brokers IS SELECT IdUtilizator FROM UTILIZATORI WHERE IdRol = (SELECT IdRol FROM ROLURI WHERE NumeRol = 'BROKER');
BEGIN
    SELECT COUNT(*) INTO v_count_mandates FROM MANDATE;
    FOR user_rec IN c_users LOOP
        IF DBMS_RANDOM.VALUE(1, 100) <= 30 THEN
            SELECT IdUtilizator INTO v_broker_id FROM (
                SELECT IdUtilizator FROM UTILIZATORI 
                WHERE IdRol = (SELECT IdRol FROM ROLURI WHERE NumeRol = 'BROKER')
                ORDER BY DBMS_RANDOM.VALUE
            ) WHERE ROWNUM = 1;
            v_status := CASE ROUND(DBMS_RANDOM.VALUE(1, 3))
                WHEN 1 THEN 'ACTIV'
                WHEN 2 THEN 'EXPIRAT'
                ELSE 'REVOCAT'
            END;
            BEGIN
                INSERT INTO MANDATE (UserId, BrokerId, Status, DataMandat)
                VALUES (user_rec.IdUtilizator, v_broker_id, v_status, SYSDATE - DBMS_RANDOM.VALUE(0, 365));
                v_counter := v_counter + 1;
            EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN
                    NULL;
            END;
            IF v_count_mandates + v_counter >= v_target_mandates THEN
                EXIT;
            END IF;
        END IF;
    END LOOP;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✓ Generat ' || v_counter || ' mandate noi');
END;
/
DECLARE
    v_count_users NUMBER;
    v_count_apps NUMBER;
    v_count_banks NUMBER;
    v_count_assoc NUMBER;
    v_count_mandates NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count_users FROM UTILIZATORI;
    SELECT COUNT(*) INTO v_count_apps FROM APLICATII;
    SELECT COUNT(*) INTO v_count_banks FROM BANCI;
    SELECT COUNT(*) INTO v_count_assoc FROM APPLICATION_BANKS;
    SELECT COUNT(*) INTO v_count_mandates FROM MANDATE;
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('GENERARE DATE TEST OLTP - COMPLETAT!');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Utilizatori: ' || v_count_users);
    DBMS_OUTPUT.PUT_LINE('Aplicații: ' || v_count_apps);
    DBMS_OUTPUT.PUT_LINE('Bănci: ' || v_count_banks);
    DBMS_OUTPUT.PUT_LINE('Asocieri aplicație-bancă: ' || v_count_assoc);
    DBMS_OUTPUT.PUT_LINE('Mandate: ' || v_count_mandates);
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Următorul pas: Conectează-te ca moneyshop_dw_user');
    DBMS_OUTPUT.PUT_LINE('              și rulează 03_CREATE_DW_TABLES.sql');
    DBMS_OUTPUT.PUT_LINE('');
END;
/