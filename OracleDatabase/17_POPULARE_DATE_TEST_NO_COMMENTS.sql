SET SERVEROUTPUT ON;
DECLARE
v_count_roluri NUMBER;
v_count_utilizatori NUMBER;
v_count_banci NUMBER;
v_count_aplicatii NUMBER;
v_count_app_banks NUMBER;
v_count_documente NUMBER;
v_count_consenturi NUMBER;
v_count_mandate NUMBER;
BEGIN
SELECT COUNT(*) INTO v_count_roluri FROM ROLURI;
SELECT COUNT(*) INTO v_count_utilizatori FROM UTILIZATORI;
SELECT COUNT(*) INTO v_count_banci FROM BANCI;
SELECT COUNT(*) INTO v_count_aplicatii FROM APLICATII;
SELECT COUNT(*) INTO v_count_app_banks FROM APPLICATION_BANKS;
SELECT COUNT(*) INTO v_count_documente FROM DOCUMENTE;
SELECT COUNT(*) INTO v_count_consenturi FROM CONSENTURI;
SELECT COUNT(*) INTO v_count_mandate FROM MANDATE;
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('VERIFICARE DATE EXISTENTE');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('ROLURI: ' || v_count_roluri || ' (minim 5)');
DBMS_OUTPUT.PUT_LINE('UTILIZATORI: ' || v_count_utilizatori || ' (minim 5)');
DBMS_OUTPUT.PUT_LINE('BANCI: ' || v_count_banci || ' (minim 5)');
DBMS_OUTPUT.PUT_LINE('APLICATII: ' || v_count_aplicatii || ' (minim 5)');
DBMS_OUTPUT.PUT_LINE('APPLICATION_BANKS: ' || v_count_app_banks || ' (minim 10)');
DBMS_OUTPUT.PUT_LINE('DOCUMENTE: ' || v_count_documente || ' (minim 5)');
DBMS_OUTPUT.PUT_LINE('CONSENTURI: ' || v_count_consenturi || ' (minim 5)');
DBMS_OUTPUT.PUT_LINE('MANDATE: ' || v_count_mandate || ' (minim 5)');
DBMS_OUTPUT.PUT_LINE('========================================');
END;
/
BEGIN
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
DBMS_OUTPUT.PUT_LINE('✓ ROLURI verificate/inserate');
END;
/
DECLARE
v_count NUMBER;
BEGIN
SELECT COUNT(*) INTO v_count FROM BANCI;
IF v_count < 5 THEN
INSERT INTO BANCI (Name, CommissionPercent, Active) VALUES
('BCR', 2.5, 1);
INSERT INTO BANCI (Name, CommissionPercent, Active) VALUES
('BRD', 2.8, 1);
INSERT INTO BANCI (Name, CommissionPercent, Active) VALUES
('BT', 2.3, 1);
INSERT INTO BANCI (Name, CommissionPercent, Active) VALUES
('ING', 2.6, 1);
INSERT INTO BANCI (Name, CommissionPercent, Active) VALUES
('UniCredit', 2.7, 1);
INSERT INTO BANCI (Name, CommissionPercent, Active) VALUES
('Raiffeisen', 2.4, 1);
INSERT INTO BANCI (Name, CommissionPercent, Active) VALUES
('CEC Bank', 2.2, 1);
COMMIT;
DBMS_OUTPUT.PUT_LINE('✓ BANCI inserate: ' || (7 - v_count) || ' noi');
ELSE
DBMS_OUTPUT.PUT_LINE('✓ BANCI: ' || v_count || ' (suficiente)');
END IF;
END;
/
DECLARE
v_count NUMBER;
v_id_client NUMBER;
v_id_broker NUMBER;
v_id_admin NUMBER;
v_parola_hash VARCHAR2(255) := 'a665a45920422f9d417e4867efdc4fb8a04a1f3fff1fa07e998e86f7f7a27ae3';
BEGIN
SELECT COUNT(*) INTO v_count FROM UTILIZATORI;
SELECT IdRol INTO v_id_client FROM ROLURI WHERE NumeRol = 'CLIENT';
SELECT IdRol INTO v_id_broker FROM ROLURI WHERE NumeRol = 'BROKER';
SELECT IdRol INTO v_id_admin FROM ROLURI WHERE NumeRol = 'ADMIN';
IF v_count < 5 THEN
INSERT INTO UTILIZATORI (Nume, Prenume, Username, Email, Parola, DataNastere, IdRol, EmailVerified)
VALUES ('Popescu', 'Ion', 'popescu.ion', 'popescu.ion@email.com', v_parola_hash, DATE '1990-01-15', v_id_client, 1);
INSERT INTO UTILIZATORI (Nume, Prenume, Username, Email, Parola, DataNastere, IdRol, EmailVerified)
VALUES ('Ionescu', 'Maria', 'ionescu.maria', 'ionescu.maria@email.com', v_parola_hash, DATE '1985-03-20', v_id_client, 1);
INSERT INTO UTILIZATORI (Nume, Prenume, Username, Email, Parola, DataNastere, IdRol, EmailVerified)
VALUES ('Georgescu', 'Andrei', 'georgescu.andrei', 'georgescu.andrei@email.com', v_parola_hash, DATE '1992-07-10', v_id_client, 1);
INSERT INTO UTILIZATORI (Nume, Prenume, Username, Email, Parola, DataNastere, IdRol, EmailVerified)
VALUES ('Dumitrescu', 'Elena', 'dumitrescu.elena', 'dumitrescu.elena@email.com', v_parola_hash, DATE '1988-11-25', v_id_client, 1);
INSERT INTO UTILIZATORI (Nume, Prenume, Username, Email, Parola, DataNastere, IdRol, EmailVerified)
VALUES ('Marinescu', 'Constantin', 'marinescu.constantin', 'marinescu.constantin@email.com', v_parola_hash, DATE '1995-05-30', v_id_client, 1);
INSERT INTO UTILIZATORI (Nume, Prenume, Username, Email, Parola, DataNastere, IdRol, EmailVerified)
VALUES ('Broker', 'Agent1', 'broker.agent1', 'broker.agent1@moneyshop.ro', v_parola_hash, DATE '1980-02-14', v_id_broker, 1);
INSERT INTO UTILIZATORI (Nume, Prenume, Username, Email, Parola, DataNastere, IdRol, EmailVerified)
VALUES ('Broker', 'Agent2', 'broker.agent2', 'broker.agent2@moneyshop.ro', v_parola_hash, DATE '1982-06-18', v_id_broker, 1);
INSERT INTO UTILIZATORI (Nume, Prenume, Username, Email, Parola, DataNastere, IdRol, EmailVerified)
VALUES ('Admin', 'Sistem', 'admin.sistem', 'admin@moneyshop.ro', v_parola_hash, DATE '1975-09-12', v_id_admin, 1);
COMMIT;
DBMS_OUTPUT.PUT_LINE('✓ UTILIZATORI inserați: ' || (8 - v_count) || ' noi');
ELSE
DBMS_OUTPUT.PUT_LINE('✓ UTILIZATORI: ' || v_count || ' (suficiente)');
END IF;
END;
/
DECLARE
v_count NUMBER;
v_user_id NUMBER;
v_counter NUMBER := 0;
BEGIN
SELECT COUNT(*) INTO v_count FROM APLICATII;
IF v_count < 5 THEN
FOR rec_user IN (
SELECT IdUtilizator
FROM UTILIZATORI
WHERE IdRol = (SELECT IdRol FROM ROLURI WHERE NumeRol = 'CLIENT')
AND ROWNUM <= 10
) LOOP
FOR i IN 1..2 LOOP
IF v_count + v_counter >= 10 THEN
EXIT;
END IF;
INSERT INTO APLICATII (
UserId, Status, TypeCredit, TipOperatiune,
SalariuNet, Scoring, Dti, SumaAprobata, Comision,
CreatedAt, UpdatedAt
) VALUES (
rec_user.IdUtilizator,
CASE MOD(v_counter, 5)
WHEN 0 THEN 'INREGISTRAT'
WHEN 1 THEN 'IN_PROCESARE'
WHEN 2 THEN 'APROBAT'
WHEN 3 THEN 'REFUZAT'
ELSE 'ANULAT'
END,
CASE MOD(v_counter, 3)
WHEN 0 THEN 'IPOTECAR'
WHEN 1 THEN 'NEVOI_PERSONALE'
ELSE 'REFINANTARE'
END,
CASE MOD(v_counter, 2) WHEN 0 THEN 'NOU' ELSE 'REFINANTARE' END,
5000 + (v_counter * 500),
600 + (v_counter * 20),
30 + (v_counter * 5),
CASE WHEN MOD(v_counter, 5) = 2 THEN 50000 + (v_counter * 10000) ELSE NULL END,
CASE WHEN MOD(v_counter, 5) = 2 THEN (50000 + (v_counter * 10000)) * 0.025 ELSE NULL END,
SYSDATE - v_counter,
SYSDATE - v_counter + 5
);
v_counter := v_counter + 1;
END LOOP;
EXIT WHEN v_count + v_counter >= 10;
END LOOP;
COMMIT;
DBMS_OUTPUT.PUT_LINE('✓ APLICATII inserate: ' || v_counter || ' noi');
ELSE
DBMS_OUTPUT.PUT_LINE('✓ APLICATII: ' || v_count || ' (suficiente)');
END IF;
END;
/
DECLARE
v_count NUMBER;
v_app_id NUMBER;
v_bank_id NUMBER;
v_counter NUMBER := 0;
BEGIN
SELECT COUNT(*) INTO v_count FROM APPLICATION_BANKS;
IF v_count < 10 THEN
FOR rec_app IN (
SELECT Id FROM APLICATII WHERE ROWNUM <= 20
) LOOP
FOR rec_bank IN (
SELECT Id FROM BANCI WHERE ROWNUM <= 3
) LOOP
IF v_count + v_counter >= 20 THEN
EXIT;
END IF;
BEGIN
INSERT INTO APPLICATION_BANKS (
ApplicationId, BankId, Status, CreatedAt
) VALUES (
rec_app.Id,
rec_bank.Id,
CASE MOD(v_counter, 4)
WHEN 0 THEN 'PENDING'
WHEN 1 THEN 'APPROVED'
WHEN 2 THEN 'REJECTED'
ELSE 'CANCELLED'
END,
SYSDATE
);
v_counter := v_counter + 1;
EXCEPTION
WHEN DUP_VAL_ON_INDEX THEN
NULL;
END;
END LOOP;
EXIT WHEN v_count + v_counter >= 20;
END LOOP;
COMMIT;
DBMS_OUTPUT.PUT_LINE('✓ APPLICATION_BANKS inserate: ' || v_counter || ' noi');
ELSE
DBMS_OUTPUT.PUT_LINE('✓ APPLICATION_BANKS: ' || v_count || ' (suficiente)');
END IF;
END;
/
DECLARE
v_count NUMBER;
v_app_id NUMBER;
v_counter NUMBER := 0;
BEGIN
SELECT COUNT(*) INTO v_count FROM DOCUMENTE;
IF v_count < 5 THEN
FOR rec_app IN (
SELECT Id FROM APLICATII WHERE ROWNUM <= 10
) LOOP
IF v_count + v_counter >= 10 THEN
EXIT;
END IF;
INSERT INTO DOCUMENTE (
ApplicationId, TipDocument, NumeFisier, Path, SizeBytes, MimeType, CreatedAt
) VALUES (
rec_app.Id,
CASE MOD(v_counter, 4)
WHEN 0 THEN 'CI'
WHEN 1 THEN 'FLUTURAS'
WHEN 2 THEN 'EXTRAS_CONT'
ELSE 'CONTRACT'
END,
'document_' || rec_app.Id || '_' || v_counter || '.pdf',
'/documents/' || rec_app.Id || '/document_' || v_counter || '.pdf',
1024 * (100 + v_counter * 50),
'application/pdf',
SYSDATE
);
v_counter := v_counter + 1;
END LOOP;
COMMIT;
DBMS_OUTPUT.PUT_LINE('✓ DOCUMENTE inserate: ' || v_counter || ' noi');
ELSE
DBMS_OUTPUT.PUT_LINE('✓ DOCUMENTE: ' || v_count || ' (suficiente)');
END IF;
END;
/
DECLARE
v_count NUMBER;
v_user_id NUMBER;
v_counter NUMBER := 0;
BEGIN
SELECT COUNT(*) INTO v_count FROM CONSENTURI;
IF v_count < 5 THEN
FOR rec_user IN (
SELECT IdUtilizator
FROM UTILIZATORI
WHERE IdRol = (SELECT IdRol FROM ROLURI WHERE NumeRol = 'CLIENT')
AND ROWNUM <= 10
) LOOP
IF v_count + v_counter >= 10 THEN
EXIT;
END IF;
INSERT INTO CONSENTURI (
UserId, TipConsent, Status, DataConsent, IpAddress, CreatedAt
) VALUES (
rec_user.IdUtilizator,
CASE MOD(v_counter, 3)
WHEN 0 THEN 'PROCESARE_DATE'
WHEN 1 THEN 'MARKETING'
ELSE 'COMUNICARE_BANCI'
END,
'ACTIV',
SYSDATE,
'192.168.1.' || (100 + v_counter),
SYSDATE
);
v_counter := v_counter + 1;
END LOOP;
COMMIT;
DBMS_OUTPUT.PUT_LINE('✓ CONSENTURI inserate: ' || v_counter || ' noi');
ELSE
DBMS_OUTPUT.PUT_LINE('✓ CONSENTURI: ' || v_count || ' (suficiente)');
END IF;
END;
/
DECLARE
v_count NUMBER;
v_user_id NUMBER;
v_broker_id NUMBER;
v_counter NUMBER := 0;
BEGIN
SELECT COUNT(*) INTO v_count FROM MANDATE;
IF v_count < 5 THEN
FOR rec_user IN (
SELECT IdUtilizator
FROM UTILIZATORI
WHERE IdRol = (SELECT IdRol FROM ROLURI WHERE NumeRol = 'CLIENT')
AND ROWNUM <= 10
) LOOP
IF v_count + v_counter >= 10 THEN
EXIT;
END IF;
SELECT IdUtilizator INTO v_broker_id
FROM (
SELECT IdUtilizator
FROM UTILIZATORI
WHERE IdRol = (SELECT IdRol FROM ROLURI WHERE NumeRol = 'BROKER')
ORDER BY DBMS_RANDOM.VALUE
)
WHERE ROWNUM = 1;
INSERT INTO MANDATE (
UserId, BrokerId, Status, DataMandat, DataExpirare, CreatedAt
) VALUES (
rec_user.IdUtilizator,
v_broker_id,
CASE MOD(v_counter, 3)
WHEN 0 THEN 'ACTIV'
WHEN 1 THEN 'EXPIRAT'
ELSE 'REVOCAT'
END,
SYSDATE - (v_counter * 10),
SYSDATE - (v_counter * 10) + 30,
SYSDATE
);
v_counter := v_counter + 1;
END LOOP;
COMMIT;
DBMS_OUTPUT.PUT_LINE('✓ MANDATE inserate: ' || v_counter || ' noi');
ELSE
DBMS_OUTPUT.PUT_LINE('✓ MANDATE: ' || v_count || ' (suficiente)');
END IF;
END;
/
DECLARE
v_count_roluri NUMBER;
v_count_utilizatori NUMBER;
v_count_banci NUMBER;
v_count_aplicatii NUMBER;
v_count_app_banks NUMBER;
v_count_documente NUMBER;
v_count_consenturi NUMBER;
v_count_mandate NUMBER;
BEGIN
SELECT COUNT(*) INTO v_count_roluri FROM ROLURI;
SELECT COUNT(*) INTO v_count_utilizatori FROM UTILIZATORI;
SELECT COUNT(*) INTO v_count_banci FROM BANCI;
SELECT COUNT(*) INTO v_count_aplicatii FROM APLICATII;
SELECT COUNT(*) INTO v_count_app_banks FROM APPLICATION_BANKS;
SELECT COUNT(*) INTO v_count_documente FROM DOCUMENTE;
SELECT COUNT(*) INTO v_count_consenturi FROM CONSENTURI;
SELECT COUNT(*) INTO v_count_mandate FROM MANDATE;
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('VERIFICARE FINALĂ DATE TEST');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('Entități independente (minim 5):');
DBMS_OUTPUT.PUT_LINE('  ROLURI: ' || v_count_roluri || CASE WHEN v_count_roluri >= 5 THEN ' ✓' ELSE ' ✗' END);
DBMS_OUTPUT.PUT_LINE('  UTILIZATORI: ' || v_count_utilizatori || CASE WHEN v_count_utilizatori >= 5 THEN ' ✓' ELSE ' ✗' END);
DBMS_OUTPUT.PUT_LINE('  BANCI: ' || v_count_banci || CASE WHEN v_count_banci >= 5 THEN ' ✓' ELSE ' ✗' END);
DBMS_OUTPUT.PUT_LINE('  APLICATII: ' || v_count_aplicatii || CASE WHEN v_count_aplicatii >= 5 THEN ' ✓' ELSE ' ✗' END);
DBMS_OUTPUT.PUT_LINE('  DOCUMENTE: ' || v_count_documente || CASE WHEN v_count_documente >= 5 THEN ' ✓' ELSE ' ✗' END);
DBMS_OUTPUT.PUT_LINE('  CONSENTURI: ' || v_count_consenturi || CASE WHEN v_count_consenturi >= 5 THEN ' ✓' ELSE ' ✗' END);
DBMS_OUTPUT.PUT_LINE('  MANDATE: ' || v_count_mandate || CASE WHEN v_count_mandate >= 5 THEN ' ✓' ELSE ' ✗' END);
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('Tabele asociative (minim 10):');
DBMS_OUTPUT.PUT_LINE('  APPLICATION_BANKS: ' || v_count_app_banks || CASE WHEN v_count_app_banks >= 10 THEN ' ✓' ELSE ' ✗' END);
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('========================================');
IF v_count_roluri >= 5 AND v_count_utilizatori >= 5 AND v_count_banci >= 5
AND v_count_aplicatii >= 5 AND v_count_documente >= 5
AND v_count_consenturi >= 5 AND v_count_mandate >= 5
AND v_count_app_banks >= 10 THEN
DBMS_OUTPUT.PUT_LINE('✓ TOATE CERINȚELE SUNT ÎNDEPLINITE!');
ELSE
DBMS_OUTPUT.PUT_LINE('⚠ Unele cerințe nu sunt îndeplinite!');
END IF;
DBMS_OUTPUT.PUT_LINE('========================================');
END;
/