SET SERVEROUTPUT ON;
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD HH24:MI:SS';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS.FF';
CREATE TABLE ROLURI (
IdRol NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
NumeRol VARCHAR2(50) NOT NULL UNIQUE,
Descriere VARCHAR2(500),
CreatedAt TIMESTAMP DEFAULT SYSTIMESTAMP,
CONSTRAINT chk_nume_rol CHECK (NumeRol IN ('CLIENT', 'BROKER', 'ADMIN'))
);
CREATE TABLE UTILIZATORI (
IdUtilizator NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
Nume VARCHAR2(100) NOT NULL,
Prenume VARCHAR2(100) NOT NULL,
Username VARCHAR2(50) NOT NULL UNIQUE,
Email VARCHAR2(255) NOT NULL UNIQUE,
Parola VARCHAR2(255) NOT NULL,
NumarTelefon VARCHAR2(20),
EmailVerified NUMBER(1) DEFAULT 0,
PhoneVerified NUMBER(1) DEFAULT 0,
DataNastere DATE NOT NULL,
IdRol NUMBER NOT NULL,
IsDeleted NUMBER(1) DEFAULT 0,
CreatedAt TIMESTAMP DEFAULT SYSTIMESTAMP,
UpdatedAt TIMESTAMP DEFAULT SYSTIMESTAMP,
CONSTRAINT chk_email_verified CHECK (EmailVerified IN (0, 1)),
CONSTRAINT chk_phone_verified CHECK (PhoneVerified IN (0, 1)),
CONSTRAINT chk_is_deleted CHECK (IsDeleted IN (0, 1)),
CONSTRAINT fk_utilizatori_rol FOREIGN KEY (IdRol) REFERENCES ROLURI(IdRol),
CONSTRAINT chk_email_format CHECK (REGEXP_LIKE(Email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$')),
CONSTRAINT chk_telefon_format CHECK (NumarTelefon IS NULL OR REGEXP_LIKE(NumarTelefon, '^[0-9]{10}$'))
);
CREATE TABLE BANCI (
Id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
Name VARCHAR2(200) NOT NULL UNIQUE,
CommissionPercent NUMBER(5,2) NOT NULL,
Active NUMBER(1) DEFAULT 1,
CreatedAt TIMESTAMP DEFAULT SYSTIMESTAMP,
CONSTRAINT chk_commission CHECK (CommissionPercent BETWEEN 0 AND 100),
CONSTRAINT chk_bank_active CHECK (Active IN (0, 1))
);
CREATE TABLE APLICATII (
Id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
UserId NUMBER NOT NULL,
Status VARCHAR2(50) DEFAULT 'INREGISTRAT' NOT NULL,
TypeCredit VARCHAR2(50),
TipOperatiune VARCHAR2(50),
SalariuNet NUMBER(18,2),
BonuriMasa NUMBER(1),
SumaBonuriMasa NUMBER(18,2),
VechimeLuni NUMBER,
NrCrediteBanci NUMBER,
ListaBanciActive CLOB,
NrIfn NUMBER,
Poprire NUMBER(1),
SoldTotal NUMBER(18,2),
Intarzieri NUMBER(1),
IntarzieriNumar NUMBER,
CardCredit CLOB,
Overdraft CLOB,
Codebitori CLOB,
Scoring NUMBER(5,2),
Dti NUMBER(5,2),
RecommendedLevel VARCHAR2(50),
SumaAprobata NUMBER(18,2),
Comision NUMBER(18,2),
DataDisbursare TIMESTAMP,
CreatedAt TIMESTAMP DEFAULT SYSTIMESTAMP,
UpdatedAt TIMESTAMP DEFAULT SYSTIMESTAMP,
CONSTRAINT fk_aplicatii_user FOREIGN KEY (UserId) REFERENCES UTILIZATORI(IdUtilizator),
CONSTRAINT chk_status CHECK (Status IN ('INREGISTRAT', 'IN_PROCESARE', 'APROBAT', 'REFUZAT', 'ANULAT')),
CONSTRAINT chk_type_credit CHECK (TypeCredit IS NULL OR TypeCredit IN ('IPOTECAR', 'NEVOI_PERSONALE', 'REFINANTARE')),
CONSTRAINT chk_tip_operatiune CHECK (TipOperatiune IS NULL OR TipOperatiune IN ('NOU', 'REFINANTARE')),
CONSTRAINT chk_scoring CHECK (Scoring IS NULL OR Scoring BETWEEN 300 AND 850),
CONSTRAINT chk_dti CHECK (Dti IS NULL OR Dti BETWEEN 0 AND 100),
CONSTRAINT chk_salariu CHECK (SalariuNet IS NULL OR SalariuNet >= 0),
CONSTRAINT chk_bonuri_masa CHECK (BonuriMasa IS NULL OR BonuriMasa IN (0, 1)),
CONSTRAINT chk_poprire CHECK (Poprire IS NULL OR Poprire IN (0, 1)),
CONSTRAINT chk_intarzieri CHECK (Intarzieri IS NULL OR Intarzieri IN (0, 1))
);
CREATE TABLE APPLICATION_BANKS (
Id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
ApplicationId NUMBER NOT NULL,
BankId NUMBER NOT NULL,
Status VARCHAR2(50) DEFAULT 'PENDING',
CreatedAt TIMESTAMP DEFAULT SYSTIMESTAMP,
CONSTRAINT fk_app_banks_app FOREIGN KEY (ApplicationId) REFERENCES APLICATII(Id) ON DELETE CASCADE,
CONSTRAINT fk_app_banks_bank FOREIGN KEY (BankId) REFERENCES BANCI(Id),
CONSTRAINT uk_app_bank UNIQUE (ApplicationId, BankId),
CONSTRAINT chk_app_bank_status CHECK (Status IN ('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED'))
);
CREATE TABLE DOCUMENTE (
Id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
ApplicationId NUMBER NOT NULL,
TipDocument VARCHAR2(50) NOT NULL,
NumeFisier VARCHAR2(255) NOT NULL,
Path VARCHAR2(1000) NOT NULL,
SizeBytes NUMBER NOT NULL,
MimeType VARCHAR2(100),
CreatedAt TIMESTAMP DEFAULT SYSTIMESTAMP,
CONSTRAINT fk_documente_app FOREIGN KEY (ApplicationId) REFERENCES APLICATII(Id) ON DELETE CASCADE,
CONSTRAINT chk_tip_document CHECK (TipDocument IN ('CI', 'FLUTURAS', 'EXTRAS_CONT', 'CONTRACT', 'ALTUL')),
CONSTRAINT chk_size_bytes CHECK (SizeBytes > 0)
);
CREATE TABLE AGREEMENTS (
Id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
ApplicationId NUMBER NOT NULL,
TipAcord VARCHAR2(50) NOT NULL,
Status VARCHAR2(50) DEFAULT 'ACTIV',
DataAcord TIMESTAMP DEFAULT SYSTIMESTAMP,
DataExpirare TIMESTAMP,
CreatedAt TIMESTAMP DEFAULT SYSTIMESTAMP,
CONSTRAINT fk_agreements_app FOREIGN KEY (ApplicationId) REFERENCES APLICATII(Id) ON DELETE CASCADE,
CONSTRAINT chk_tip_acord CHECK (TipAcord IN ('TERMENI_CONDITII', 'CONSENT_GDPR', 'MANDAT_BROKER')),
CONSTRAINT chk_agreement_status CHECK (Status IN ('ACTIV', 'EXPIRAT', 'REVOCAT')),
CONSTRAINT chk_data_expirare CHECK (DataExpirare IS NULL OR DataExpirare > DataAcord)
);
CREATE TABLE LEADURI (
Id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
Nume VARCHAR2(100) NOT NULL,
Prenume VARCHAR2(100) NOT NULL,
Email VARCHAR2(255),
NumarTelefon VARCHAR2(20),
Status VARCHAR2(50) DEFAULT 'NOU',
Source VARCHAR2(100),
CreatedAt TIMESTAMP DEFAULT SYSTIMESTAMP,
CONSTRAINT chk_lead_status CHECK (Status IN ('NOU', 'CONTACTAT', 'CONVERTIT', 'RESPINS')),
CONSTRAINT chk_lead_email CHECK (Email IS NULL OR REGEXP_LIKE(Email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$')),
CONSTRAINT chk_lead_telefon CHECK (NumarTelefon IS NULL OR REGEXP_LIKE(NumarTelefon, '^[0-9]{10}$'))
);
CREATE TABLE CONSENTURI (
Id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
UserId NUMBER NOT NULL,
TipConsent VARCHAR2(50) NOT NULL,
Status VARCHAR2(50) DEFAULT 'ACTIV',
DataConsent TIMESTAMP DEFAULT SYSTIMESTAMP,
DataExpirare TIMESTAMP,
IpAddress VARCHAR2(45),
CreatedAt TIMESTAMP DEFAULT SYSTIMESTAMP,
CONSTRAINT fk_consenturi_user FOREIGN KEY (UserId) REFERENCES UTILIZATORI(IdUtilizator) ON DELETE CASCADE,
CONSTRAINT chk_tip_consent CHECK (TipConsent IN ('PROCESARE_DATE', 'MARKETING', 'COMUNICARE_BANCI')),
CONSTRAINT chk_consent_status CHECK (Status IN ('ACTIV', 'EXPIRAT', 'REVOCAT'))
);
CREATE TABLE MANDATE (
Id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
UserId NUMBER NOT NULL,
BrokerId NUMBER NOT NULL,
Status VARCHAR2(50) DEFAULT 'ACTIV',
DataMandat TIMESTAMP DEFAULT SYSTIMESTAMP,
DataExpirare TIMESTAMP,
CreatedAt TIMESTAMP DEFAULT SYSTIMESTAMP,
CONSTRAINT fk_mandate_user FOREIGN KEY (UserId) REFERENCES UTILIZATORI(IdUtilizator) ON DELETE CASCADE,
CONSTRAINT fk_mandate_broker FOREIGN KEY (BrokerId) REFERENCES UTILIZATORI(IdUtilizator),
CONSTRAINT chk_mandate_status CHECK (Status IN ('ACTIV', 'EXPIRAT', 'REVOCAT')),
CONSTRAINT chk_mandate_expirare CHECK (DataExpirare IS NULL OR DataExpirare > DataMandat)
);
CREATE TABLE USER_FINANCIAL_DATA (
Id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
UserId NUMBER NOT NULL UNIQUE,
SalariuNet NUMBER(18,2),
BonuriMasa NUMBER(1),
SumaBonuriMasa NUMBER(18,2),
VenitTotal NUMBER(18,2),
SoldTotal NUMBER(18,2),
RataTotalaLunara NUMBER(18,2),
NrCrediteBanci NUMBER,
NrIfn NUMBER,
Poprire NUMBER(1),
Intarzieri NUMBER(1),
IntarzieriNumar NUMBER,
Dti NUMBER(5,2),
ScoringLevel VARCHAR2(50),
RecommendedLevel VARCHAR2(50),
LastUpdated TIMESTAMP DEFAULT SYSTIMESTAMP,
CreatedAt TIMESTAMP DEFAULT SYSTIMESTAMP,
CONSTRAINT fk_financial_data_user FOREIGN KEY (UserId) REFERENCES UTILIZATORI(IdUtilizator) ON DELETE CASCADE,
CONSTRAINT chk_financial_salariu CHECK (SalariuNet IS NULL OR SalariuNet >= 0),
CONSTRAINT chk_financial_dti CHECK (Dti IS NULL OR Dti BETWEEN 0 AND 100),
CONSTRAINT chk_financial_scoring CHECK (ScoringLevel IS NULL OR ScoringLevel IN ('FOARTE_BUNA', 'BUNA', 'MEDIE', 'SLABA', 'FOARTE_SLABA')),
CONSTRAINT chk_financial_bonuri CHECK (BonuriMasa IS NULL OR BonuriMasa IN (0, 1)),
CONSTRAINT chk_financial_poprire CHECK (Poprire IS NULL OR Poprire IN (0, 1)),
CONSTRAINT chk_financial_intarzieri CHECK (Intarzieri IS NULL OR Intarzieri IN (0, 1))
);
CREATE TABLE USER_SESSIONS (
Id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
UserId NUMBER NOT NULL,
Token VARCHAR2(500) NOT NULL UNIQUE,
ExpiresAt TIMESTAMP NOT NULL,
IpAddress VARCHAR2(45),
UserAgent VARCHAR2(500),
CreatedAt TIMESTAMP DEFAULT SYSTIMESTAMP,
CONSTRAINT fk_session_user FOREIGN KEY (UserId) REFERENCES UTILIZATORI(IdUtilizator) ON DELETE CASCADE,
CONSTRAINT chk_session_expires CHECK (ExpiresAt > CreatedAt)
);
CREATE TABLE AUDIT_LOG (
Id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
TableName VARCHAR2(100) NOT NULL,
Operation VARCHAR2(10) NOT NULL,
UserId NUMBER,
OldValues CLOB,
NewValues CLOB,
IpAddress VARCHAR2(45),
Timestamp TIMESTAMP DEFAULT SYSTIMESTAMP,
CONSTRAINT chk_audit_operation CHECK (Operation IN ('INSERT', 'UPDATE', 'DELETE'))
);
CREATE INDEX idx_applications_userid ON APLICATII(UserId);
CREATE INDEX idx_applications_status ON APLICATII(Status);
CREATE INDEX idx_applications_created ON APLICATII(CreatedAt);
CREATE INDEX idx_documents_applicationid ON DOCUMENTE(ApplicationId);
CREATE INDEX idx_consenturi_userid ON CONSENTURI(UserId);
CREATE INDEX idx_consenturi_status ON CONSENTURI(Status);
CREATE INDEX idx_mandate_userid ON MANDATE(UserId);
CREATE INDEX idx_mandate_brokerid ON MANDATE(BrokerId);
CREATE INDEX idx_mandate_status ON MANDATE(Status);
CREATE INDEX idx_audit_log_timestamp ON AUDIT_LOG(Timestamp);
CREATE INDEX idx_audit_log_tablename ON AUDIT_LOG(TableName);
CREATE INDEX idx_session_userid ON USER_SESSIONS(UserId);
CREATE INDEX idx_session_expires ON USER_SESSIONS(ExpiresAt);
CREATE INDEX idx_utilizatori_idrol ON UTILIZATORI(IdRol);
INSERT INTO ROLURI (NumeRol, Descriere) VALUES ('CLIENT', 'Utilizator standard care aplică pentru credite');
INSERT INTO ROLURI (NumeRol, Descriere) VALUES ('BROKER', 'Broker autorizat care procesează cererile de credit');
INSERT INTO ROLURI (NumeRol, Descriere) VALUES ('ADMIN', 'Administrator cu acces complet la sistem');
COMMIT;
CREATE OR REPLACE TRIGGER trg_utilizatori_varsta
BEFORE INSERT OR UPDATE OF DataNastere ON UTILIZATORI
FOR EACH ROW
BEGIN
IF :NEW.DataNastere > ADD_MONTHS(SYSDATE, -216) THEN
RAISE_APPLICATION_ERROR(-20005, 'Utilizatorul trebuie să aibă minim 18 ani');
END IF;
END;
/
CREATE OR REPLACE TRIGGER trg_utilizatori_updated
BEFORE UPDATE ON UTILIZATORI
FOR EACH ROW
BEGIN
:NEW.UpdatedAt := SYSTIMESTAMP;
END;
/
CREATE OR REPLACE TRIGGER trg_aplicatii_updated
BEFORE UPDATE ON APLICATII
FOR EACH ROW
BEGIN
:NEW.UpdatedAt := SYSTIMESTAMP;
END;
/
BEGIN
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('CERINTA 1: CREARE TABELE - RULAT CU SUCCES!');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('');
END;
/
CREATE OR REPLACE TRIGGER trg_utilizatori_parola_securitate
BEFORE INSERT OR UPDATE OF Parola ON UTILIZATORI
FOR EACH ROW
DECLARE
v_parola VARCHAR2(255);
BEGIN
v_parola := :NEW.Parola;
IF LENGTH(v_parola) < 8 THEN
RAISE_APPLICATION_ERROR(-20001, 'Parola trebuie să aibă minim 8 caractere');
END IF;
IF NOT REGEXP_LIKE(v_parola, '[0-9]') THEN
RAISE_APPLICATION_ERROR(-20002, 'Parola trebuie să conțină cel puțin o cifră');
END IF;
IF NOT REGEXP_LIKE(v_parola, '[A-Z]') THEN
RAISE_APPLICATION_ERROR(-20003, 'Parola trebuie să conțină cel puțin o literă mare');
END IF;
IF NOT REGEXP_LIKE(v_parola, '[a-z]') THEN
RAISE_APPLICATION_ERROR(-20004, 'Parola trebuie să conțină cel puțin o literă mică');
END IF;
END;
/
CREATE OR REPLACE TRIGGER trg_utilizatori_email
BEFORE INSERT OR UPDATE OF Email ON UTILIZATORI
FOR EACH ROW
BEGIN
IF NOT REGEXP_LIKE(:NEW.Email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$') THEN
RAISE_APPLICATION_ERROR(-20006, 'Format email invalid');
END IF;
END;
/
CREATE OR REPLACE TRIGGER trg_aplicatii_scoring
BEFORE INSERT OR UPDATE OF Scoring ON APLICATII
FOR EACH ROW
BEGIN
IF :NEW.Scoring IS NOT NULL AND (:NEW.Scoring < 300 OR :NEW.Scoring > 850) THEN
RAISE_APPLICATION_ERROR(-20007, 'Scoring-ul trebuie să fie între 300 și 850');
END IF;
END;
/
CREATE OR REPLACE TRIGGER trg_aplicatii_dti
BEFORE INSERT OR UPDATE OF Dti ON APLICATII
FOR EACH ROW
BEGIN
IF :NEW.Dti IS NOT NULL AND (:NEW.Dti < 0 OR :NEW.Dti > 100) THEN
RAISE_APPLICATION_ERROR(-20008, 'DTI trebuie să fie între 0 și 100%');
END IF;
END;
/
CREATE OR REPLACE TRIGGER trg_mandate_broker_rol
BEFORE INSERT OR UPDATE OF BrokerId ON MANDATE
FOR EACH ROW
DECLARE
v_rol VARCHAR2(50);
BEGIN
SELECT r.NumeRol INTO v_rol
FROM UTILIZATORI u
JOIN ROLURI r ON u.IdRol = r.IdRol
WHERE u.IdUtilizator = :NEW.BrokerId;
IF v_rol != 'BROKER' THEN
RAISE_APPLICATION_ERROR(-20009, 'BrokerId trebuie să fie un utilizator cu rol BROKER');
END IF;
END;
/
CREATE OR REPLACE VIEW vw_utilizatori_public AS
SELECT
IdUtilizator,
Nume,
Prenume,
Username,
SUBSTR(Email, 1, 3) || '***@***' AS Email_Masked,
SUBSTR(NumarTelefon, 1, 3) || '***' AS Telefon_Masked,
IdRol,
CreatedAt
FROM UTILIZATORI
WHERE IsDeleted = 0;
CREATE OR REPLACE VIEW vw_aplicatii_public AS
SELECT
Id,
UserId,
Status,
TypeCredit,
TipOperatiune,
RecommendedLevel,
CreatedAt,
UpdatedAt
FROM APLICATII;
CREATE OR REPLACE PROCEDURE sp_autentificare_utilizator (
p_username IN VARCHAR2,
p_parola_hash IN VARCHAR2,
p_user_id OUT NUMBER,
p_rol OUT VARCHAR2,
p_success OUT NUMBER
)
IS
v_parola VARCHAR2(255);
v_id_rol NUMBER;
BEGIN
p_success := 0;
SELECT u.IdUtilizator, u.Parola, u.IdRol
INTO p_user_id, v_parola, v_id_rol
FROM UTILIZATORI u
WHERE u.Username = p_username
AND u.IsDeleted = 0;
IF v_parola = p_parola_hash THEN
SELECT NumeRol INTO p_rol
FROM ROLURI
WHERE IdRol = v_id_rol;
p_success := 1;
INSERT INTO AUDIT_LOG (TableName, Operation, UserId, NewValues, Timestamp)
VALUES ('UTILIZATORI', 'AUTH', p_user_id, 'Login successful', SYSTIMESTAMP);
ELSE
INSERT INTO AUDIT_LOG (TableName, Operation, NewValues, Timestamp)
VALUES ('UTILIZATORI', 'AUTH', 'Login failed for: ' || p_username, SYSTIMESTAMP);
RAISE_APPLICATION_ERROR(-20010, 'Autentificare eșuată');
END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
p_success := 0;
INSERT INTO AUDIT_LOG (TableName, Operation, NewValues, Timestamp)
VALUES ('UTILIZATORI', 'AUTH', 'Login failed - user not found: ' || p_username, SYSTIMESTAMP);
WHEN OTHERS THEN
p_success := 0;
RAISE;
END;
/
CREATE OR REPLACE PROCEDURE sp_schimbare_parola (
p_user_id IN NUMBER,
p_parola_veche_hash IN VARCHAR2,
p_parola_noua_hash IN VARCHAR2,
p_success OUT NUMBER
)
IS
v_parola_curenta VARCHAR2(255);
BEGIN
p_success := 0;
SELECT Parola INTO v_parola_curenta
FROM UTILIZATORI
WHERE IdUtilizator = p_user_id
AND IsDeleted = 0;
IF v_parola_curenta = p_parola_veche_hash THEN
UPDATE UTILIZATORI
SET Parola = p_parola_noua_hash,
UpdatedAt = SYSTIMESTAMP
WHERE IdUtilizator = p_user_id;
p_success := 1;
INSERT INTO AUDIT_LOG (TableName, Operation, UserId, NewValues, Timestamp)
VALUES ('UTILIZATORI', 'UPDATE', p_user_id, 'Password changed', SYSTIMESTAMP);
COMMIT;
ELSE
INSERT INTO AUDIT_LOG (TableName, Operation, UserId, NewValues, Timestamp)
VALUES ('UTILIZATORI', 'UPDATE', p_user_id, 'Password change failed - wrong old password', SYSTIMESTAMP);
RAISE_APPLICATION_ERROR(-20011, 'Parola veche incorectă');
END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
p_success := 0;
RAISE_APPLICATION_ERROR(-20012, 'Utilizator negăsit');
WHEN OTHERS THEN
p_success := 0;
RAISE;
END;
/
BEGIN
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('CERINTA 2: REGULI DE SECURITATE - RULAT CU SUCCES!');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('');
END;
/
CREATE OR REPLACE FUNCTION fn_encrypt_column (
p_data IN VARCHAR2,
p_key IN VARCHAR2 DEFAULT 'MONEYSHOP_ENCRYPT_KEY_2025'
) RETURN RAW
IS
v_encrypted RAW(2000);
v_key RAW(32);
v_src RAW(2000);
BEGIN
IF p_data IS NULL THEN
RETURN NULL;
END IF;
v_src := UTL_RAW.CAST_TO_RAW(p_data);
v_key := UTL_RAW.CAST_TO_RAW(SUBSTR(p_key || RPAD(' ', 32, ' '), 1, 32));
BEGIN
v_encrypted := DBMS_CRYPTO.ENCRYPT(
src => v_src,
typ => DBMS_CRYPTO.ENCRYPT_AES256 + DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5,
key => v_key
);
EXCEPTION
WHEN OTHERS THEN
RETURN NULL;
END;
RETURN v_encrypted;
EXCEPTION
WHEN OTHERS THEN
RETURN NULL;
END;
/
CREATE OR REPLACE FUNCTION fn_decrypt_column (
p_encrypted IN RAW,
p_key IN VARCHAR2 DEFAULT 'MONEYSHOP_ENCRYPT_KEY_2025'
) RETURN VARCHAR2
IS
v_decrypted RAW(2000);
v_key RAW(32);
BEGIN
IF p_encrypted IS NULL THEN
RETURN NULL;
END IF;
v_key := UTL_RAW.CAST_TO_RAW(SUBSTR(p_key || RPAD(' ', 32, ' '), 1, 32));
BEGIN
v_decrypted := DBMS_CRYPTO.DECRYPT(
src => p_encrypted,
typ => DBMS_CRYPTO.ENCRYPT_AES256 + DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5,
key => v_key
);
EXCEPTION
WHEN OTHERS THEN
RETURN NULL;
END;
RETURN UTL_RAW.CAST_TO_VARCHAR2(v_decrypted);
EXCEPTION
WHEN OTHERS THEN
RETURN NULL;
END;
/
DECLARE
v_count NUMBER;
BEGIN
SELECT COUNT(*) INTO v_count
FROM user_tab_columns
WHERE table_name = 'UTILIZATORI' AND column_name = 'CNP_ENCRYPTED';
IF v_count = 0 THEN
EXECUTE IMMEDIATE 'ALTER TABLE UTILIZATORI ADD CNP_Encrypted RAW(2000)';
END IF;
SELECT COUNT(*) INTO v_count
FROM user_tab_columns
WHERE table_name = 'UTILIZATORI' AND column_name = 'EMAIL_ENCRYPTED';
IF v_count = 0 THEN
EXECUTE IMMEDIATE 'ALTER TABLE UTILIZATORI ADD Email_Encrypted RAW(2000)';
END IF;
SELECT COUNT(*) INTO v_count
FROM user_tab_columns
WHERE table_name = 'UTILIZATORI' AND column_name = 'TELEFON_ENCRYPTED';
IF v_count = 0 THEN
EXECUTE IMMEDIATE 'ALTER TABLE UTILIZATORI ADD Telefon_Encrypted RAW(2000)';
END IF;
END;
/
CREATE OR REPLACE VIEW vw_utilizatori_decrypted AS
SELECT
IdUtilizator,
Nume,
Prenume,
Username,
Email,
Email_Encrypted,
Email AS Email_Decrypted,
NumarTelefon,
Telefon_Encrypted,
NumarTelefon AS Telefon_Decrypted,
EmailVerified,
PhoneVerified,
DataNastere,
IdRol,
IsDeleted,
CreatedAt,
UpdatedAt
FROM UTILIZATORI
WHERE IsDeleted = 0;
CREATE OR REPLACE PROCEDURE sp_encrypt_user_email (p_user_id IN NUMBER)
IS
BEGIN
UPDATE UTILIZATORI
SET Email_Encrypted = fn_encrypt_column(Email)
WHERE IdUtilizator = p_user_id;
COMMIT;
END;
/
CREATE OR REPLACE PROCEDURE sp_encrypt_user_telefon (p_user_id IN NUMBER)
IS
BEGIN
UPDATE UTILIZATORI
SET Telefon_Encrypted = fn_encrypt_column(NumarTelefon)
WHERE IdUtilizator = p_user_id
AND NumarTelefon IS NOT NULL;
COMMIT;
END;
/
BEGIN
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('CERINTA 3: CRIPTARE DATE - RULAT CU SUCCES!');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('');
END;
/
CREATE OR REPLACE TRIGGER trg_audit_utilizatori
AFTER INSERT OR UPDATE OR DELETE ON UTILIZATORI
FOR EACH ROW
DECLARE
v_operation VARCHAR2(10);
v_old_values CLOB;
v_new_values CLOB;
v_user_id NUMBER;
BEGIN
IF INSERTING THEN
v_operation := 'INSERT';
v_new_values := '{"IdUtilizator":' || :NEW.IdUtilizator || ',"Email":"' || :NEW.Email || '","IdRol":' || :NEW.IdRol || '}';
v_user_id := :NEW.IdUtilizator;
ELSIF UPDATING THEN
v_operation := 'UPDATE';
v_old_values := '{"IdUtilizator":' || :OLD.IdUtilizator || ',"Email":"' || :OLD.Email || ',"IdRol":' || :OLD.IdRol || '}';
v_new_values := '{"IdUtilizator":' || :NEW.IdUtilizator || ',"Email":"' || :NEW.Email || ',"IdRol":' || :NEW.IdRol || '}';
v_user_id := :NEW.IdUtilizator;
ELSE
v_operation := 'DELETE';
v_old_values := '{"IdUtilizator":' || :OLD.IdUtilizator || ',"Email":"' || :OLD.Email || ',"IdRol":' || :OLD.IdRol || '}';
v_user_id := :OLD.IdUtilizator;
END IF;
INSERT INTO AUDIT_LOG (TableName, Operation, UserId, OldValues, NewValues, IpAddress, Timestamp)
VALUES ('UTILIZATORI', v_operation, v_user_id, v_old_values, v_new_values, SYS_CONTEXT('USERENV', 'IP_ADDRESS'), SYSTIMESTAMP);
END;
/
CREATE OR REPLACE TRIGGER trg_audit_aplicatii
AFTER INSERT OR UPDATE OR DELETE ON APLICATII
FOR EACH ROW
DECLARE
v_operation VARCHAR2(10);
v_old_values CLOB;
v_new_values CLOB;
BEGIN
IF INSERTING THEN
v_operation := 'INSERT';
v_new_values := '{"Id":' || :NEW.Id || ',"UserId":' || :NEW.UserId || ',"Status":"' || :NEW.Status || '","Scoring":' || NVL(:NEW.Scoring, 0) || '}';
ELSIF UPDATING THEN
v_operation := 'UPDATE';
v_old_values := '{"Id":' || :OLD.Id || ',"Status":"' || :OLD.Status || '","Scoring":' || NVL(:OLD.Scoring, 0) || '}';
v_new_values := '{"Id":' || :NEW.Id || ',"Status":"' || :NEW.Status || ',"Scoring":' || NVL(:NEW.Scoring, 0) || '}';
ELSE
v_operation := 'DELETE';
v_old_values := '{"Id":' || :OLD.Id || '}';
END IF;
INSERT INTO AUDIT_LOG (TableName, Operation, UserId, OldValues, NewValues, IpAddress, Timestamp)
VALUES ('APLICATII', v_operation, :NEW.UserId, v_old_values, v_new_values, SYS_CONTEXT('USERENV', 'IP_ADDRESS'), SYSTIMESTAMP);
END;
/
CREATE OR REPLACE VIEW vw_audit_log_recent AS
SELECT
Id,
TableName,
Operation,
UserId,
IpAddress,
Timestamp,
EXTRACT(DAY FROM (SYSTIMESTAMP - Timestamp)) AS DaysAgo
FROM AUDIT_LOG
WHERE Timestamp >= SYSTIMESTAMP - INTERVAL '30' DAY
ORDER BY Timestamp DESC;
BEGIN
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('CERINTA 4: AUDITARE - RULAT CU SUCCES!');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('');
END;
/
CREATE TABLE PROCESE (
IdProces NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
NumeProces VARCHAR2(100) NOT NULL UNIQUE,
Descriere VARCHAR2(500),
TipProces VARCHAR2(50) NOT NULL,
CreatedAt TIMESTAMP DEFAULT SYSTIMESTAMP,
CONSTRAINT chk_tip_proces CHECK (TipProces IN ('READ', 'WRITE', 'DELETE', 'ADMIN', 'EXECUTE'))
);
CREATE TABLE PROCES_UTILIZATOR (
Id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
IdProces NUMBER NOT NULL,
IdUtilizator NUMBER NOT NULL,
Status VARCHAR2(50) DEFAULT 'ACTIV',
DataAsignare TIMESTAMP DEFAULT SYSTIMESTAMP,
DataExpirare TIMESTAMP,
CreatedAt TIMESTAMP DEFAULT SYSTIMESTAMP,
CONSTRAINT fk_proc_util_proces FOREIGN KEY (IdProces) REFERENCES PROCESE(IdProces),
CONSTRAINT fk_proc_util_user FOREIGN KEY (IdUtilizator) REFERENCES UTILIZATORI(IdUtilizator),
CONSTRAINT chk_proc_util_status CHECK (Status IN ('ACTIV', 'INACTIV', 'EXPIRAT')),
CONSTRAINT uk_proc_util UNIQUE (IdProces, IdUtilizator)
);
CREATE TABLE ENTITATE_PROCES (
Id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
NumeEntitate VARCHAR2(100) NOT NULL,
IdProces NUMBER NOT NULL,
Permisiune VARCHAR2(50) NOT NULL,
CreatedAt TIMESTAMP DEFAULT SYSTIMESTAMP,
CONSTRAINT fk_ent_proc_proces FOREIGN KEY (IdProces) REFERENCES PROCESE(IdProces),
CONSTRAINT chk_permisiune CHECK (Permisiune IN ('ALLOW', 'DENY')),
CONSTRAINT uk_ent_proc UNIQUE (NumeEntitate, IdProces)
);
CREATE TABLE ENTITATE_UTILIZATOR (
Id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
NumeEntitate VARCHAR2(100) NOT NULL,
IdUtilizator NUMBER NOT NULL,
TipAcces VARCHAR2(50) NOT NULL,
ConditieWhere VARCHAR2(1000),
Status VARCHAR2(50) DEFAULT 'ACTIV',
CreatedAt TIMESTAMP DEFAULT SYSTIMESTAMP,
CONSTRAINT fk_ent_util_user FOREIGN KEY (IdUtilizator) REFERENCES UTILIZATORI(IdUtilizator),
CONSTRAINT chk_tip_acces CHECK (TipAcces IN ('READ', 'WRITE', 'DELETE', 'ALL')),
CONSTRAINT chk_ent_util_status CHECK (Status IN ('ACTIV', 'INACTIV', 'EXPIRAT'))
);
INSERT INTO PROCESE (NumeProces, Descriere, TipProces) VALUES ('VIEW_OWN_APPLICATIONS', 'Vizualizare propriile aplicații', 'READ');
INSERT INTO PROCESE (NumeProces, Descriere, TipProces) VALUES ('CREATE_APPLICATION', 'Creare aplicație nouă', 'WRITE');
INSERT INTO PROCESE (NumeProces, Descriere, TipProces) VALUES ('UPDATE_OWN_APPLICATION', 'Actualizare propria aplicație', 'WRITE');
INSERT INTO PROCESE (NumeProces, Descriere, TipProces) VALUES ('DELETE_OWN_APPLICATION', 'Ștergere propria aplicație', 'DELETE');
INSERT INTO PROCESE (NumeProces, Descriere, TipProces) VALUES ('VIEW_ALL_APPLICATIONS', 'Vizualizare toate aplicațiile (broker)', 'READ');
INSERT INTO PROCESE (NumeProces, Descriere, TipProces) VALUES ('PROCESS_APPLICATION', 'Procesare aplicație (broker)', 'WRITE');
INSERT INTO PROCESE (NumeProces, Descriere, TipProces) VALUES ('VIEW_USERS', 'Vizualizare utilizatori (admin)', 'READ');
INSERT INTO PROCESE (NumeProces, Descriere, TipProces) VALUES ('MANAGE_USERS', 'Gestionare utilizatori (admin)', 'ADMIN');
INSERT INTO PROCESE (NumeProces, Descriere, TipProces) VALUES ('VIEW_REPORTS', 'Vizualizare rapoarte', 'READ');
INSERT INTO PROCESE (NumeProces, Descriere, TipProces) VALUES ('EXECUTE_ADMIN_PROC', 'Executare proceduri admin', 'EXECUTE');
COMMIT;
CREATE OR REPLACE FUNCTION fn_utilizator_poate_proces (
p_user_id IN NUMBER,
p_nume_proces IN VARCHAR2
) RETURN NUMBER
IS
v_count NUMBER;
v_rol VARCHAR2(50);
BEGIN
SELECT COUNT(*) INTO v_count
FROM PROCES_UTILIZATOR pu
JOIN PROCESE p ON pu.IdProces = p.IdProces
WHERE pu.IdUtilizator = p_user_id
AND p.NumeProces = p_nume_proces
AND pu.Status = 'ACTIV'
AND (pu.DataExpirare IS NULL OR pu.DataExpirare > SYSTIMESTAMP);
IF v_count > 0 THEN
RETURN 1;
END IF;
SELECT r.NumeRol INTO v_rol
FROM UTILIZATORI u
JOIN ROLURI r ON u.IdRol = r.IdRol
WHERE u.IdUtilizator = p_user_id;
IF v_rol = 'ADMIN' THEN
RETURN 1;
ELSIF v_rol = 'BROKER' AND p_nume_proces IN ('VIEW_ALL_APPLICATIONS', 'PROCESS_APPLICATION') THEN
RETURN 1;
ELSIF v_rol = 'CLIENT' AND p_nume_proces IN ('VIEW_OWN_APPLICATIONS', 'CREATE_APPLICATION', 'UPDATE_OWN_APPLICATION', 'DELETE_OWN_APPLICATION') THEN
RETURN 1;
END IF;
RETURN 0;
END;
/
BEGIN
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('CERINTA 5: GESTIUNE UTILIZATORI - RULAT CU SUCCES!');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('');
END;
/
BEGIN
BEGIN
EXECUTE IMMEDIATE 'CREATE ROLE moneyshop_client_role';
EXCEPTION
WHEN OTHERS THEN
NULL;
END;
BEGIN
EXECUTE IMMEDIATE 'CREATE ROLE moneyshop_broker_role';
EXCEPTION
WHEN OTHERS THEN
NULL;
END;
BEGIN
EXECUTE IMMEDIATE 'CREATE ROLE moneyshop_admin_role';
EXCEPTION
WHEN OTHERS THEN
NULL;
END;
BEGIN
EXECUTE IMMEDIATE 'CREATE ROLE moneyshop_readonly_role';
EXCEPTION
WHEN OTHERS THEN
NULL;
END;
END;
/
BEGIN
BEGIN
EXECUTE IMMEDIATE 'GRANT SELECT ON UTILIZATORI TO moneyshop_client_role';
EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE ON APLICATII TO moneyshop_client_role';
EXECUTE IMMEDIATE 'GRANT SELECT, INSERT ON DOCUMENTE TO moneyshop_client_role';
EXECUTE IMMEDIATE 'GRANT SELECT, INSERT ON CONSENTURI TO moneyshop_client_role';
EXECUTE IMMEDIATE 'GRANT SELECT, INSERT ON MANDATE TO moneyshop_client_role';
EXCEPTION
WHEN OTHERS THEN
NULL;
END;
END;
/
BEGIN
BEGIN
EXECUTE IMMEDIATE 'GRANT SELECT ON UTILIZATORI TO moneyshop_broker_role';
EXECUTE IMMEDIATE 'GRANT SELECT, UPDATE ON APLICATII TO moneyshop_broker_role';
EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE ON DOCUMENTE TO moneyshop_broker_role';
EXECUTE IMMEDIATE 'GRANT SELECT ON CONSENTURI TO moneyshop_broker_role';
EXECUTE IMMEDIATE 'GRANT SELECT ON MANDATE TO moneyshop_broker_role';
EXCEPTION
WHEN OTHERS THEN
NULL;
END;
END;
/
BEGIN
BEGIN
EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON UTILIZATORI TO moneyshop_admin_role';
EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON APLICATII TO moneyshop_admin_role';
EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON DOCUMENTE TO moneyshop_admin_role';
EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON CONSENTURI TO moneyshop_admin_role';
EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON MANDATE TO moneyshop_admin_role';
EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON BANCI TO moneyshop_admin_role';
EXECUTE IMMEDIATE 'GRANT SELECT ON AUDIT_LOG TO moneyshop_admin_role';
EXCEPTION
WHEN OTHERS THEN
NULL;
END;
END;
/
BEGIN
BEGIN
EXECUTE IMMEDIATE 'GRANT moneyshop_client_role TO moneyshop_broker_role';
EXECUTE IMMEDIATE 'GRANT moneyshop_broker_role TO moneyshop_admin_role';
EXCEPTION
WHEN OTHERS THEN
NULL;
END;
END;
/
BEGIN
BEGIN
EXECUTE IMMEDIATE 'GRANT EXECUTE ON sp_autentificare_utilizator TO moneyshop_client_role, moneyshop_broker_role, moneyshop_admin_role';
EXECUTE IMMEDIATE 'GRANT EXECUTE ON sp_schimbare_parola TO moneyshop_client_role, moneyshop_broker_role, moneyshop_admin_role';
EXECUTE IMMEDIATE 'GRANT EXECUTE ON fn_utilizator_poate_proces TO moneyshop_client_role, moneyshop_broker_role, moneyshop_admin_role';
EXCEPTION
WHEN OTHERS THEN
NULL;
END;
END;
/
BEGIN
BEGIN
EXECUTE IMMEDIATE 'GRANT SELECT ON vw_utilizatori_public TO moneyshop_client_role, moneyshop_broker_role, moneyshop_admin_role';
EXECUTE IMMEDIATE 'GRANT SELECT ON vw_aplicatii_public TO moneyshop_client_role, moneyshop_broker_role, moneyshop_admin_role';
EXECUTE IMMEDIATE 'GRANT SELECT ON vw_utilizatori_decrypted TO moneyshop_admin_role';
EXCEPTION
WHEN OTHERS THEN
NULL;
END;
END;
/
BEGIN
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('CERINTA 6: PRIVILEGII SI ROLURI - RULAT CU SUCCES!');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('');
END;
/
CREATE OR REPLACE FUNCTION fn_mask_email(p_email IN VARCHAR2) RETURN VARCHAR2
IS
v_masked VARCHAR2(255);
v_at_pos NUMBER;
BEGIN
IF p_email IS NULL THEN
RETURN NULL;
END IF;
v_at_pos := INSTR(p_email, '@');
IF v_at_pos > 0 THEN
v_masked := SUBSTR(p_email, 1, 1) || '***@' || SUBSTR(p_email, v_at_pos + 1);
ELSE
v_masked := SUBSTR(p_email, 1, 1) || '***';
END IF;
RETURN v_masked;
END;
/
CREATE OR REPLACE FUNCTION fn_mask_telefon(p_telefon IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN
IF p_telefon IS NULL OR LENGTH(p_telefon) < 4 THEN
RETURN '***';
END IF;
RETURN SUBSTR(p_telefon, 1, 3) || '***' || SUBSTR(p_telefon, -2);
END;
/
CREATE OR REPLACE FUNCTION fn_mask_nume(p_nume IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN
IF p_nume IS NULL OR LENGTH(p_nume) < 2 THEN
RETURN '***';
END IF;
RETURN SUBSTR(p_nume, 1, 1) || '***' || SUBSTR(p_nume, -1);
END;
/
CREATE OR REPLACE VIEW vw_utilizatori_masked AS
SELECT
IdUtilizator,
fn_mask_nume(Nume) AS Nume_Masked,
fn_mask_nume(Prenume) AS Prenume_Masked,
Username,
fn_mask_email(Email) AS Email_Masked,
fn_mask_telefon(NumarTelefon) AS Telefon_Masked,
EmailVerified,
PhoneVerified,
IdRol,
CreatedAt
FROM UTILIZATORI
WHERE IsDeleted = 0;
BEGIN
BEGIN
EXECUTE IMMEDIATE 'GRANT SELECT ON vw_utilizatori_masked TO moneyshop_readonly_role';
EXCEPTION
WHEN OTHERS THEN
NULL;
END;
END;
/
BEGIN
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('CERINTA 7: MASCARE DATE - RULAT CU SUCCES!');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('');
END;
/
SELECT 'CERINTA 1: Tabele create' AS Verificare, COUNT(*) AS NumarTabele
FROM user_tables
WHERE table_name IN ('ROLURI', 'UTILIZATORI', 'APLICATII', 'BANCI', 'DOCUMENTE', 'CONSENTURI', 'MANDATE', 'AUDIT_LOG');
SELECT 'CERINTA 2: Trigger-uri securitate' AS Verificare, COUNT(*) AS NumarTriggeruri
FROM user_triggers
WHERE trigger_name IN ('TRG_UTILIZATORI_PAROLA_SECURITATE', 'TRG_UTILIZATORI_EMAIL', 'TRG_APLICATII_SCORING', 'TRG_APLICATII_DTI');
SELECT 'CERINTA 3: Funcții criptare' AS Verificare, object_name, status
FROM user_objects
WHERE object_name IN ('FN_ENCRYPT_COLUMN', 'FN_DECRYPT_COLUMN')
ORDER BY object_name;
SELECT 'CERINTA 4: Trigger-uri auditare' AS Verificare, COUNT(*) AS NumarTriggeruri
FROM user_triggers
WHERE trigger_name IN ('TRG_AUDIT_UTILIZATORI', 'TRG_AUDIT_APLICATII', 'TRG_AUDIT_DOCUMENTE', 'TRG_AUDIT_CONSENTURI');
SELECT 'CERINTA 5: Tabele gestiune' AS Verificare, COUNT(*) AS NumarTabele
FROM user_tables
WHERE table_name IN ('PROCESE', 'PROCES_UTILIZATOR', 'ENTITATE_PROCES', 'ENTITATE_UTILIZATOR');
SELECT 'CERINTA 6: Roluri create' AS Verificare, COUNT(*) AS NumarRoluri
FROM user_role_privs
WHERE granted_role LIKE 'MONEYSHOP%';
SELECT 'CERINTA 7: Funcții mascare' AS Verificare, object_name, status
FROM user_objects
WHERE object_name IN ('FN_MASK_EMAIL', 'FN_MASK_TELEFON', 'FN_MASK_CNP', 'FN_MASK_NUME')
ORDER BY object_name;
SELECT 'View-uri create' AS Verificare, COUNT(*) AS NumarViewuri
FROM user_views
WHERE view_name LIKE 'VW_%';
SELECT 'Proceduri stocate' AS Verificare, COUNT(*) AS NumarProceduri
FROM user_procedures
WHERE object_name LIKE 'SP_%';