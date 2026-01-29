SET SERVEROUTPUT ON;
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'YYYY-MM-DD HH24:MI:SS.FF';
BEGIN
    BEGIN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURRENT_SCHEMA = moneyshop_dw_user';
        DBMS_OUTPUT.PUT_LINE('✓ Schema setată la moneyshop_dw_user');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('⚠ Nu s-a putut seta schema (poate utilizatorul nu există sau ești deja conectat)');
    END;
    DBMS_OUTPUT.PUT_LINE('Schema curentă: ' || SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA'));
    DBMS_OUTPUT.PUT_LINE('Început creare tabele DW...');
    DBMS_OUTPUT.PUT_LINE('');
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE DIM_TIMP CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE('⚠ Tabel DIM_TIMP șters (dacă exista)');
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/
CREATE TABLE DIM_TIMP (
    IdTimp NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    DataCompleta DATE NOT NULL UNIQUE,
    An NUMBER(4) NOT NULL,
    Trimestru NUMBER(1) NOT NULL,
    Luna NUMBER(2) NOT NULL,
    Saptamana NUMBER(2) NOT NULL,
    Zi NUMBER(2) NOT NULL,
    ZiSaptamana NUMBER(1) NOT NULL,
    EsteWeekend NUMBER(1) NOT NULL,
    CONSTRAINT chk_trimestru CHECK (Trimestru BETWEEN 1 AND 4),
    CONSTRAINT chk_luna CHECK (Luna BETWEEN 1 AND 12),
    CONSTRAINT chk_zi CHECK (Zi BETWEEN 1 AND 31),
    CONSTRAINT chk_zi_saptamana CHECK (ZiSaptamana BETWEEN 1 AND 7),
    CONSTRAINT chk_weekend CHECK (EsteWeekend IN (0, 1))
);
CREATE INDEX idx_dim_timp_data ON DIM_TIMP(DataCompleta);
CREATE INDEX idx_dim_timp_an_trim ON DIM_TIMP(An, Trimestru);
BEGIN
    DBMS_OUTPUT.PUT_LINE('✓ Tabel DIM_TIMP creat');
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE DIM_UTILIZATOR CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE('⚠ Tabel DIM_UTILIZATOR șters (dacă exista)');
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/
CREATE TABLE DIM_UTILIZATOR (
    IdUtilizator NUMBER PRIMARY KEY,
    Nume VARCHAR2(100) NOT NULL,
    Prenume VARCHAR2(100) NOT NULL,
    EmailMasked VARCHAR2(255),
    TelefonMasked VARCHAR2(20),
    IdRol NUMBER NOT NULL,
    DataNastere DATE,
    VechimeLuni NUMBER,
    CreatedAt TIMESTAMP
);
CREATE INDEX idx_dim_utilizator_rol ON DIM_UTILIZATOR(IdRol);
BEGIN
    DBMS_OUTPUT.PUT_LINE('✓ Tabel DIM_UTILIZATOR creat');
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE DIM_BANCA CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE('⚠ Tabel DIM_BANCA șters (dacă exista)');
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/
CREATE TABLE DIM_BANCA (
    IdBanca NUMBER PRIMARY KEY,
    Name VARCHAR2(200) NOT NULL,
    CommissionPercent NUMBER(5,2) NOT NULL,
    Active NUMBER(1) NOT NULL,
    CreatedAt TIMESTAMP
);
BEGIN
    DBMS_OUTPUT.PUT_LINE('✓ Tabel DIM_BANCA creat');
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE DIM_TIP_CREDIT CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE('⚠ Tabel DIM_TIP_CREDIT șters (dacă exista)');
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/
CREATE TABLE DIM_TIP_CREDIT (
    IdTipCredit NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    TypeCredit VARCHAR2(50) NOT NULL,
    TipOperatiune VARCHAR2(50) NOT NULL,
    Descriere VARCHAR2(200),
    CONSTRAINT chk_type_credit CHECK (TypeCredit IN ('IPOTECAR', 'NEVOI_PERSONALE', 'REFINANTARE')),
    CONSTRAINT chk_tip_operatiune CHECK (TipOperatiune IN ('NOU', 'REFINANTARE')),
    CONSTRAINT uk_tip_credit UNIQUE (TypeCredit, TipOperatiune)
);
BEGIN
    DBMS_OUTPUT.PUT_LINE('✓ Tabel DIM_TIP_CREDIT creat');
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE DIM_STATUS CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE('⚠ Tabel DIM_STATUS șters (dacă exista)');
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/
CREATE TABLE DIM_STATUS (
    IdStatus NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Status VARCHAR2(50) NOT NULL UNIQUE,
    Descriere VARCHAR2(200),
    Categorie VARCHAR2(50) NOT NULL,
    CONSTRAINT chk_status CHECK (Status IN ('INREGISTRAT', 'IN_PROCESARE', 'APROBAT', 'REFUZAT', 'ANULAT')),
    CONSTRAINT chk_categorie CHECK (Categorie IN ('IN_PROCES', 'FINALIZAT', 'ANULAT'))
);
BEGIN
    DBMS_OUTPUT.PUT_LINE('✓ Tabel DIM_STATUS creat');
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE DIM_BROKER CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE('⚠ Tabel DIM_BROKER șters (dacă exista)');
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/
CREATE TABLE DIM_BROKER (
    IdBroker NUMBER PRIMARY KEY,
    Nume VARCHAR2(100) NOT NULL,
    Prenume VARCHAR2(100) NOT NULL,
    EmailMasked VARCHAR2(255),
    CreatedAt TIMESTAMP
);
BEGIN
    DBMS_OUTPUT.PUT_LINE('✓ Tabel DIM_BROKER creat');
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE FACT_APLICATII_CREDIT CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE('⚠ Tabel FACT_APLICATII_CREDIT șters (dacă exista)');
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/
CREATE TABLE FACT_APLICATII_CREDIT (
    IdFact NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    IdUtilizator NUMBER NOT NULL,
    IdBanca NUMBER NOT NULL,
    IdTimp NUMBER NOT NULL,
    IdTipCredit NUMBER NOT NULL,
    IdStatus NUMBER NOT NULL,
    IdBroker NUMBER,
    SumaAprobata NUMBER(18,2) DEFAULT 0,
    Comision NUMBER(18,2) DEFAULT 0,
    Scoring NUMBER(5,2),
    Dti NUMBER(5,2),
    NumărAplicatii NUMBER DEFAULT 1,
    DurataProcesare NUMBER,
    SalariuNet NUMBER(18,2),
    SoldTotal NUMBER(18,2)
);
BEGIN
    DBMS_OUTPUT.PUT_LINE('✓ Tabel FACT_APLICATII_CREDIT creat');
END;
/
INSERT INTO DIM_TIP_CREDIT (TypeCredit, TipOperatiune, Descriere) VALUES
('IPOTECAR', 'NOU', 'Credit ipotecar nou');
INSERT INTO DIM_TIP_CREDIT (TypeCredit, TipOperatiune, Descriere) VALUES
('IPOTECAR', 'REFINANTARE', 'Refinanțare credit ipotecar');
INSERT INTO DIM_TIP_CREDIT (TypeCredit, TipOperatiune, Descriere) VALUES
('NEVOI_PERSONALE', 'NOU', 'Credit de nevoi personale nou');
INSERT INTO DIM_TIP_CREDIT (TypeCredit, TipOperatiune, Descriere) VALUES
('NEVOI_PERSONALE', 'REFINANTARE', 'Refinanțare credit de nevoi personale');
INSERT INTO DIM_TIP_CREDIT (TypeCredit, TipOperatiune, Descriere) VALUES
('REFINANTARE', 'NOU', 'Refinanțare credit nou');
INSERT INTO DIM_TIP_CREDIT (TypeCredit, TipOperatiune, Descriere) VALUES
('REFINANTARE', 'REFINANTARE', 'Refinanțare credit de refinanțare');
COMMIT;
BEGIN
    DBMS_OUTPUT.PUT_LINE('✓ DIM_TIP_CREDIT populat cu ' || SQL%ROWCOUNT || ' înregistrări');
END;
/
INSERT INTO DIM_STATUS (Status, Descriere, Categorie) VALUES
('INREGISTRAT', 'Aplicație înregistrată', 'IN_PROCES');
INSERT INTO DIM_STATUS (Status, Descriere, Categorie) VALUES
('IN_PROCESARE', 'Aplicație în procesare', 'IN_PROCES');
INSERT INTO DIM_STATUS (Status, Descriere, Categorie) VALUES
('APROBAT', 'Aplicație aprobată', 'FINALIZAT');
INSERT INTO DIM_STATUS (Status, Descriere, Categorie) VALUES
('REFUZAT', 'Aplicație refuzată', 'FINALIZAT');
INSERT INTO DIM_STATUS (Status, Descriere, Categorie) VALUES
('ANULAT', 'Aplicație anulată', 'ANULAT');
COMMIT;
BEGIN
    DBMS_OUTPUT.PUT_LINE('✓ DIM_STATUS populat cu ' || SQL%ROWCOUNT || ' înregistrări');
END;
/
DECLARE
    v_start_date DATE := TO_DATE('2020-01-01', 'YYYY-MM-DD');
    v_end_date DATE := TO_DATE('2030-12-31', 'YYYY-MM-DD');
    v_current_date DATE;
    v_counter NUMBER := 0;
BEGIN
    v_current_date := v_start_date;
    WHILE v_current_date <= v_end_date LOOP
        INSERT INTO DIM_TIMP (
            DataCompleta, An, Trimestru, Luna, Saptamana, Zi,
            ZiSaptamana, EsteWeekend
        ) VALUES (
            v_current_date,
            EXTRACT(YEAR FROM v_current_date),
            CEIL(TO_NUMBER(TO_CHAR(v_current_date, 'MM'))/3),
            EXTRACT(MONTH FROM v_current_date),
            TO_NUMBER(TO_CHAR(v_current_date, 'WW')),
            EXTRACT(DAY FROM v_current_date),
            TO_NUMBER(TO_CHAR(v_current_date, 'D')),
            CASE WHEN TO_NUMBER(TO_CHAR(v_current_date, 'D')) IN (1, 7) THEN 1 ELSE 0 END
        );
        v_current_date := v_current_date + 1;
        v_counter := v_counter + 1;
        IF MOD(v_counter, 365) = 0 THEN
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('   Generat ' || v_counter || ' zile...');
        END IF;
    END LOOP;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('✓ DIM_TIMP populat cu ' || v_counter || ' zile (2020-2030)');
END;
/
DECLARE
    v_count_timp NUMBER;
    v_count_utilizator NUMBER;
    v_count_banca NUMBER;
    v_count_tip_credit NUMBER;
    v_count_status NUMBER;
    v_count_broker NUMBER;
    v_count_fact NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count_timp FROM DIM_TIMP;
    SELECT COUNT(*) INTO v_count_utilizator FROM DIM_UTILIZATOR;
    SELECT COUNT(*) INTO v_count_banca FROM DIM_BANCA;
    SELECT COUNT(*) INTO v_count_tip_credit FROM DIM_TIP_CREDIT;
    SELECT COUNT(*) INTO v_count_status FROM DIM_STATUS;
    SELECT COUNT(*) INTO v_count_broker FROM DIM_BROKER;
    SELECT COUNT(*) INTO v_count_fact FROM FACT_APLICATII_CREDIT;
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('CREARE TABELE DW - COMPLETAT!');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Tabele create:');
    DBMS_OUTPUT.PUT_LINE('  - DIM_TIMP: ' || v_count_timp || ' zile');
    DBMS_OUTPUT.PUT_LINE('  - DIM_UTILIZATOR: ' || v_count_utilizator || ' utilizatori');
    DBMS_OUTPUT.PUT_LINE('  - DIM_BANCA: ' || v_count_banca || ' bănci');
    DBMS_OUTPUT.PUT_LINE('  - DIM_TIP_CREDIT: ' || v_count_tip_credit || ' tipuri');
    DBMS_OUTPUT.PUT_LINE('  - DIM_STATUS: ' || v_count_status || ' statusuri');
    DBMS_OUTPUT.PUT_LINE('  - DIM_BROKER: ' || v_count_broker || ' brokeri');
    DBMS_OUTPUT.PUT_LINE('  - FACT_APLICATII_CREDIT: ' || v_count_fact || ' fapte');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Următorul pas: Rulează 04_ETL_EXTRACT.sql');
    DBMS_OUTPUT.PUT_LINE('');
END;
/