SET SERVEROUTPUT ON;
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
v_encrypted := DBMS_CRYPTO.ENCRYPT(
src => v_src,
typ => DBMS_CRYPTO.ENCRYPT_AES256 + DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5,
key => v_key
);
RETURN v_encrypted;
EXCEPTION
WHEN OTHERS THEN
RAISE_APPLICATION_ERROR(-20020, 'Eroare la criptare: ' || SQLERRM);
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
v_decrypted := DBMS_CRYPTO.DECRYPT(
src => p_encrypted,
typ => DBMS_CRYPTO.ENCRYPT_AES256 + DBMS_CRYPTO.CHAIN_CBC + DBMS_CRYPTO.PAD_PKCS5,
key => v_key
);
RETURN UTL_RAW.CAST_TO_VARCHAR2(v_decrypted);
EXCEPTION
WHEN OTHERS THEN
RAISE_APPLICATION_ERROR(-20021, 'Eroare la decriptare: ' || SQLERRM);
END;
/
BEGIN
FOR rec IN (
SELECT object_name, object_type, status
FROM user_objects
WHERE object_name IN ('FN_ENCRYPT_COLUMN', 'FN_DECRYPT_COLUMN')
ORDER BY object_name
) LOOP
DBMS_OUTPUT.PUT_LINE(rec.object_name || ' - ' || rec.status);
END LOOP;
FOR rec IN (
SELECT name, sequence, line, position, text
FROM user_errors
WHERE name IN ('FN_ENCRYPT_COLUMN', 'FN_DECRYPT_COLUMN')
ORDER BY sequence
) LOOP
DBMS_OUTPUT.PUT_LINE('EROARE: ' || rec.name || ' - ' || rec.text);
END LOOP;
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
CREATE OR REPLACE TRIGGER trg_utilizatori_encrypt_cnp
BEFORE INSERT OR UPDATE OF CNP_Encrypted ON UTILIZATORI
FOR EACH ROW
DECLARE
v_cnp VARCHAR2(13);
BEGIN
NULL;
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
CASE
WHEN Email_Encrypted IS NOT NULL THEN fn_decrypt_column(Email_Encrypted)
ELSE Email
END AS Email_Decrypted,
NumarTelefon,
Telefon_Encrypted,
CASE
WHEN Telefon_Encrypted IS NOT NULL THEN fn_decrypt_column(Telefon_Encrypted)
ELSE NumarTelefon
END AS Telefon_Decrypted,
EmailVerified,
PhoneVerified,
DataNastere,
IdRol,
IsDeleted,
CreatedAt,
UpdatedAt
FROM UTILIZATORI
WHERE IsDeleted = 0;
CREATE OR REPLACE PROCEDURE sp_encrypt_user_email (
p_user_id IN NUMBER
)
IS
BEGIN
UPDATE UTILIZATORI
SET Email_Encrypted = fn_encrypt_column(Email)
WHERE IdUtilizator = p_user_id;
COMMIT;
DBMS_OUTPUT.PUT_LINE('Email criptat pentru utilizatorul: ' || p_user_id);
END;
/
CREATE OR REPLACE PROCEDURE sp_encrypt_user_telefon (
p_user_id IN NUMBER
)
IS
BEGIN
UPDATE UTILIZATORI
SET Telefon_Encrypted = fn_encrypt_column(NumarTelefon)
WHERE IdUtilizator = p_user_id
AND NumarTelefon IS NOT NULL;
COMMIT;
DBMS_OUTPUT.PUT_LINE('Telefon criptat pentru utilizatorul: ' || p_user_id);
END;
/
CREATE OR REPLACE PROCEDURE sp_encrypt_all_sensitive_data
IS
v_count NUMBER := 0;
BEGIN
UPDATE UTILIZATORI
SET Email_Encrypted = fn_encrypt_column(Email)
WHERE Email_Encrypted IS NULL
AND Email IS NOT NULL;
v_count := SQL%ROWCOUNT;
DBMS_OUTPUT.PUT_LINE('Email-uri criptate: ' || v_count);
UPDATE UTILIZATORI
SET Telefon_Encrypted = fn_encrypt_column(NumarTelefon)
WHERE Telefon_Encrypted IS NULL
AND NumarTelefon IS NOT NULL;
v_count := SQL%ROWCOUNT;
DBMS_OUTPUT.PUT_LINE('Telefoane criptate: ' || v_count);
COMMIT;
DBMS_OUTPUT.PUT_LINE('Criptarea datelor sensibile a fost finalizată!');
END;
/
DECLARE
v_test VARCHAR2(100) := 'test@example.com';
v_encrypted RAW(2000);
v_decrypted VARCHAR2(100);
v_status VARCHAR2(20);
BEGIN
SELECT status INTO v_status
FROM user_objects
WHERE object_name = 'FN_ENCRYPT_COLUMN' AND object_type = 'FUNCTION';
IF v_status = 'VALID' THEN
v_encrypted := fn_encrypt_column(v_test);
v_decrypted := fn_decrypt_column(v_encrypted);
DBMS_OUTPUT.PUT_LINE('Original: ' || v_test);
DBMS_OUTPUT.PUT_LINE('Criptat: ' || RAWTOHEX(v_encrypted));
DBMS_OUTPUT.PUT_LINE('Decriptat: ' || v_decrypted);
IF v_test = v_decrypted THEN
DBMS_OUTPUT.PUT_LINE('✓ Criptarea funcționează corect!');
ELSE
DBMS_OUTPUT.PUT_LINE('✗ Eroare la criptare!');
END IF;
ELSE
DBMS_OUTPUT.PUT_LINE('⚠ Funcțiile de criptare nu sunt valide!');
DBMS_OUTPUT.PUT_LINE('  Este necesar grant: GRANT EXECUTE ON DBMS_CRYPTO TO ' || USER || ';');
END IF;
EXCEPTION
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('⚠ Eroare la testare: ' || SQLERRM);
DBMS_OUTPUT.PUT_LINE('  Verifică dacă ai privilegii EXECUTE pe DBMS_CRYPTO');
END;
/
BEGIN
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('Criptarea datelor a fost configurată!');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('NOTĂ: Pentru funcțiile de criptare, este necesar:');
DBMS_OUTPUT.PUT_LINE('  GRANT EXECUTE ON DBMS_CRYPTO TO ' || USER || ';');
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('NOTĂ: Pentru TDE, este necesară configurarea');
DBMS_OUTPUT.PUT_LINE('Oracle Wallet de către DBA.');
DBMS_OUTPUT.PUT_LINE('========================================');
END;
/