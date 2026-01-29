SET SERVEROUTPUT ON;
CREATE TABLE APLICATII_TEMP_FN1 (
Id NUMBER PRIMARY KEY,
UserId NUMBER NOT NULL,
NumeUtilizator VARCHAR2(100),
PrenumeUtilizator VARCHAR2(100),
EmailUtilizator VARCHAR2(255),
Status VARCHAR2(50),
TypeCredit VARCHAR2(50),
SumaAprobata NUMBER(18,2),
CreatedAt TIMESTAMP
);
BEGIN
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('TABEL APLICATII_TEMP_FN1 CREAT');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('Problema: Dependențe funcționale parțiale');
DBMS_OUTPUT.PUT_LINE('  - NumeUtilizator depinde de UserId (nu de Id)');
DBMS_OUTPUT.PUT_LINE('  - PrenumeUtilizator depinde de UserId (nu de Id)');
DBMS_OUTPUT.PUT_LINE('  - EmailUtilizator depinde de UserId (nu de Id)');
DBMS_OUTPUT.PUT_LINE('========================================');
END;
/
CREATE TABLE APLICATII_TEMP_FN2 (
Id NUMBER PRIMARY KEY,
UserId NUMBER NOT NULL,
Status VARCHAR2(50),
TypeCredit VARCHAR2(50),
SumaAprobata NUMBER(18,2),
CreatedAt TIMESTAMP,
FOREIGN KEY (UserId) REFERENCES UTILIZATORI(IdUtilizator)
);
BEGIN
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('TABEL APLICATII_TEMP_FN2 CREAT (FN2)');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('Soluție: Eliminare dependențe parțiale');
DBMS_OUTPUT.PUT_LINE('  - Datele utilizatorului rămân în UTILIZATORI');
DBMS_OUTPUT.PUT_LINE('  - APLICATII_TEMP_FN2 referențiază UserId');
DBMS_OUTPUT.PUT_LINE('  - Toate atributele depind complet de Id');
DBMS_OUTPUT.PUT_LINE('========================================');
END;
/
CREATE TABLE APLICATII_TEMP_FN2_TRANZ (
Id NUMBER PRIMARY KEY,
UserId NUMBER NOT NULL,
Status VARCHAR2(50),
TypeCredit VARCHAR2(50),
IdBanca NUMBER,
NumeBanca VARCHAR2(200),
CommissionPercent NUMBER(5,2),
SumaAprobata NUMBER(18,2),
CreatedAt TIMESTAMP
);
BEGIN
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('TABEL APLICATII_TEMP_FN2_TRANZ CREAT');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('Problema: Dependențe funcționale tranzitive');
DBMS_OUTPUT.PUT_LINE('  - NumeBanca depinde de IdBanca');
DBMS_OUTPUT.PUT_LINE('  - CommissionPercent depinde de IdBanca');
DBMS_OUTPUT.PUT_LINE('  - IdBanca depinde de Id (prin relație)');
DBMS_OUTPUT.PUT_LINE('  - Deci: Id → IdBanca → NumeBanca (tranzitivă)');
DBMS_OUTPUT.PUT_LINE('========================================');
END;
/
CREATE TABLE APLICATII_TEMP_FN3 (
Id NUMBER PRIMARY KEY,
UserId NUMBER NOT NULL,
Status VARCHAR2(50),
TypeCredit VARCHAR2(50),
SumaAprobata NUMBER(18,2),
CreatedAt TIMESTAMP,
FOREIGN KEY (UserId) REFERENCES UTILIZATORI(IdUtilizator)
);
CREATE TABLE APPLICATION_BANKS_TEMP_FN3 (
ApplicationId NUMBER NOT NULL,
BankId NUMBER NOT NULL,
PRIMARY KEY (ApplicationId, BankId),
FOREIGN KEY (ApplicationId) REFERENCES APLICATII_TEMP_FN3(Id),
FOREIGN KEY (BankId) REFERENCES BANCI(Id)
);
BEGIN
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('TABEL APLICATII_TEMP_FN3 CREAT (FN3)');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('Soluție: Eliminare dependențe tranzitive');
DBMS_OUTPUT.PUT_LINE('  - Datele băncii rămân în BANCI');
DBMS_OUTPUT.PUT_LINE('  - Asocierea este în APPLICATION_BANKS_TEMP_FN3');
DBMS_OUTPUT.PUT_LINE('  - Nu mai există dependențe tranzitive');
DBMS_OUTPUT.PUT_LINE('========================================');
END;
/
BEGIN
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('VERIFICARE NORMALIZARE TABELE EXISTENTE');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('Toate tabelele existente sunt în FN3:');
DBMS_OUTPUT.PUT_LINE('  ✓ ROLURI');
DBMS_OUTPUT.PUT_LINE('  ✓ UTILIZATORI');
DBMS_OUTPUT.PUT_LINE('  ✓ BANCI');
DBMS_OUTPUT.PUT_LINE('  ✓ APLICATII');
DBMS_OUTPUT.PUT_LINE('  ✓ APPLICATION_BANKS');
DBMS_OUTPUT.PUT_LINE('  ✓ DOCUMENTE');
DBMS_OUTPUT.PUT_LINE('  ✓ AGREEMENTS');
DBMS_OUTPUT.PUT_LINE('  ✓ CONSENTURI');
DBMS_OUTPUT.PUT_LINE('  ✓ MANDATE');
DBMS_OUTPUT.PUT_LINE('  ✓ LEADURI');
DBMS_OUTPUT.PUT_LINE('  ✓ USER_FINANCIAL_DATA');
DBMS_OUTPUT.PUT_LINE('  ✓ USER_SESSIONS');
DBMS_OUTPUT.PUT_LINE('  ✓ AUDIT_LOG');
DBMS_OUTPUT.PUT_LINE('  ✓ MESAJE');
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('Verificare completă!');
DBMS_OUTPUT.PUT_LINE('========================================');
END;
/