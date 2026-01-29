-- =====================================================
-- Grant Privilegii pentru DBMS_CRYPTO
-- Oracle Database 19c+
-- =====================================================
-- 
-- IMPORTANT: Acest script trebuie executat de SYSDBA sau
-- un utilizator cu privilegii suficiente pentru a acorda
-- privilegii pe DBMS_CRYPTO.
--
-- =====================================================

-- Grant EXECUTE pe DBMS_CRYPTO pentru utilizatorul curent
-- Înlocuiește [nume_utilizator] cu numele utilizatorului tău
-- GRANT EXECUTE ON DBMS_CRYPTO TO [nume_utilizator];

-- Exemplu pentru utilizatorul sandbox_user:
-- GRANT EXECUTE ON DBMS_CRYPTO TO sandbox_user;

-- Verificare privilegii
SELECT * FROM user_tab_privs WHERE table_name = 'DBMS_CRYPTO';

-- După acordarea privilegiilor, recompilare funcții:
-- ALTER FUNCTION fn_encrypt_column COMPILE;
-- ALTER FUNCTION fn_decrypt_column COMPILE;

