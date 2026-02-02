-- =====================================================
-- VERIFICARE TABEL ROLURI (Aplicație)
-- MoneyShop - Oracle Database
-- =====================================================

SET SERVEROUTPUT ON;
SET PAGESIZE 1000;
SET LINESIZE 200;

PROMPT =====================================================
PROMPT VERIFICARE TABEL ROLURI (Aplicație)
PROMPT =====================================================
PROMPT

-- =====================================================
-- 1. Verificare Existență Tabel
-- =====================================================

DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM user_tables
    WHERE table_name = 'ROLURI';
    
    IF v_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('❌ Tabelul ROLURI nu există!');
        RAISE_APPLICATION_ERROR(-20000, 'Tabelul ROLURI nu există');
    ELSE
        DBMS_OUTPUT.PUT_LINE('✅ Tabelul ROLURI există');
    END IF;
END;
/

-- =====================================================
-- 2. Structura Tabelului
-- =====================================================

PROMPT
PROMPT 2. STRUCTURA TABELULUI ROLURI:
PROMPT =====================================================

SELECT 
    column_name AS Coloana,
    data_type AS TipDate,
    data_length AS Lungime,
    nullable AS Nullable,
    data_default AS ValoareDefault
FROM user_tab_columns
WHERE table_name = 'ROLURI'
ORDER BY column_id;

PROMPT

-- =====================================================
-- 3. Datele din Tabel
-- =====================================================

PROMPT 3. DATELE DIN TABELUL ROLURI:
PROMPT =====================================================

SELECT 
    IdRol AS ID,
    NumeRol AS NumeRol,
    Descriere AS Descriere,
    TO_CHAR(CreatedAt, 'DD-MM-YYYY HH24:MI:SS') AS DataCreare
FROM ROLURI
ORDER BY IdRol;

PROMPT

-- =====================================================
-- 4. Număr Utilizatori per Rol
-- =====================================================

PROMPT 4. NUMĂR UTILIZATORI PER ROL:
PROMPT =====================================================

SELECT 
    r.NumeRol AS Rol,
    r.Descriere AS Descriere,
    COUNT(u.IdUtilizator) AS NumarUtilizatori
FROM ROLURI r
LEFT JOIN UTILIZATORI u ON r.IdRol = u.IdRol
WHERE u.IsDeleted = 0 OR u.IsDeleted IS NULL
GROUP BY r.IdRol, r.NumeRol, r.Descriere
ORDER BY r.IdRol;

PROMPT

-- =====================================================
-- 5. Verificare Constrainte
-- =====================================================

PROMPT 5. CONSTRAINTE TABELULUI ROLURI:
PROMPT =====================================================

SELECT 
    constraint_name AS NumeConstraint,
    constraint_type AS Tip,
    search_condition AS Conditie
FROM user_constraints
WHERE table_name = 'ROLURI'
ORDER BY constraint_type, constraint_name;

PROMPT

-- =====================================================
-- 6. Verificare Indexuri
-- =====================================================

PROMPT 6. INDEXURI TABELULUI ROLURI:
PROMPT =====================================================

SELECT 
    index_name AS NumeIndex,
    column_name AS Coloana,
    column_position AS Pozitie
FROM user_ind_columns
WHERE table_name = 'ROLURI'
ORDER BY index_name, column_position;

PROMPT

-- =====================================================
-- 7. Verificare Corelație cu Rolurile Oracle
-- =====================================================

PROMPT 7. CORELAȚIE CU ROLURILE ORACLE:
PROMPT =====================================================

SELECT 
    r.NumeRol AS RolAplicatie,
    CASE 
        WHEN r.NumeRol = 'CLIENT' THEN 'c##moneyshop_client_role'
        WHEN r.NumeRol = 'BROKER' THEN 'c##moneyshop_broker_role'
        WHEN r.NumeRol = 'ADMIN' THEN 'c##moneyshop_admin_role'
        ELSE 'N/A'
    END AS RolOracle,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM user_roles 
            WHERE role = CASE 
                WHEN r.NumeRol = 'CLIENT' THEN 'C##MONEYSHOP_CLIENT_ROLE'
                WHEN r.NumeRol = 'BROKER' THEN 'C##MONEYSHOP_BROKER_ROLE'
                WHEN r.NumeRol = 'ADMIN' THEN 'C##MONEYSHOP_ADMIN_ROLE'
                ELSE NULL
            END
        ) THEN '✅ Există'
        ELSE '❌ Nu există'
    END AS StatusRolOracle
FROM ROLURI r
ORDER BY r.IdRol;

PROMPT

-- =====================================================
-- 8. Rezumat Final
-- =====================================================

PROMPT 8. REZUMAT:
PROMPT =====================================================

DECLARE
    v_total_roluri NUMBER;
    v_total_utilizatori NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_total_roluri FROM ROLURI;
    SELECT COUNT(*) INTO v_total_utilizatori FROM UTILIZATORI WHERE IsDeleted = 0;
    
    DBMS_OUTPUT.PUT_LINE('Total roluri în tabel: ' || v_total_roluri);
    DBMS_OUTPUT.PUT_LINE('Total utilizatori activi: ' || v_total_utilizatori);
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Roluri definite:');
    
    FOR rec IN (
        SELECT NumeRol, Descriere, COUNT(u.IdUtilizator) AS NumarUtilizatori
        FROM ROLURI r
        LEFT JOIN UTILIZATORI u ON r.IdRol = u.IdRol AND (u.IsDeleted = 0 OR u.IsDeleted IS NULL)
        GROUP BY r.IdRol, r.NumeRol, r.Descriere
        ORDER BY r.IdRol
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('  - ' || rec.NumeRol || ': ' || rec.NumarUtilizatori || ' utilizatori');
        DBMS_OUTPUT.PUT_LINE('    ' || rec.Descriere);
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

PROMPT
PROMPT Verificare completă finalizată!
PROMPT

