-- =====================================================
-- VERIFICARE ROLURI ȘI PRIVILEGII
-- MoneyShop - Oracle Database
-- =====================================================

SET SERVEROUTPUT ON;
SET PAGESIZE 1000;
SET LINESIZE 200;

PROMPT =====================================================
PROMPT VERIFICARE ROLURI ȘI PRIVILEGII
PROMPT =====================================================
PROMPT

-- =====================================================
-- 1. Listare Roluri Create
-- =====================================================

PROMPT 1. ROLURI CREATE:
PROMPT =====================================================

SELECT 
    role AS NumeRol,
    password_required AS ParolaNecesara,
    authentication_type AS TipAutentificare
FROM user_roles
WHERE role LIKE '%MONEYSHOP%' OR role LIKE '%moneyshop%'
ORDER BY role;

PROMPT

-- =====================================================
-- 2. Privilegii Obiect pe Roluri
-- =====================================================

PROMPT 2. PRIVILEGII OBIECT (pe tabele/view-uri):
PROMPT =====================================================

SELECT 
    grantee AS Rol,
    table_name AS Obiect,
    privilege AS Privilegiu,
    grantable AS PoateDelega
FROM user_tab_privs
WHERE grantee LIKE '%MONEYSHOP%' OR grantee LIKE '%moneyshop%'
ORDER BY grantee, table_name, privilege;

PROMPT

-- =====================================================
-- 3. Privilegii pe Proceduri/Funcții
-- =====================================================

PROMPT 3. PRIVILEGII PE PROCEDURI/FUNCȚII:
PROMPT =====================================================

SELECT 
    grantee AS Rol,
    object_name AS Procedura_Functie,
    privilege AS Privilegiu,
    grantable AS PoateDelega
FROM user_proc_privs
WHERE grantee LIKE '%MONEYSHOP%' OR grantee LIKE '%moneyshop%'
ORDER BY grantee, object_name;

PROMPT

-- =====================================================
-- 4. Ierarhie Roluri (ce roluri sunt acordate altor roluri)
-- =====================================================

PROMPT 4. IERARHIE ROLURI:
PROMPT =====================================================

SELECT 
    grantee AS RolCarePrimeste,
    granted_role AS RolGrantat,
    admin_option AS AdminOption,
    default_role AS RolImplicit
FROM user_role_privs
WHERE grantee LIKE '%MONEYSHOP%' OR grantee LIKE '%moneyshop%'
   OR granted_role LIKE '%MONEYSHOP%' OR granted_role LIKE '%moneyshop%'
ORDER BY grantee, granted_role;

PROMPT

-- =====================================================
-- 5. Privilegii Sistem pe Roluri
-- =====================================================

PROMPT 5. PRIVILEGII SISTEM:
PROMPT =====================================================

SELECT 
    grantee AS Rol,
    privilege AS Privilegiu,
    admin_option AS AdminOption
FROM user_sys_privs
WHERE grantee LIKE '%MONEYSHOP%' OR grantee LIKE '%moneyshop%'
ORDER BY grantee, privilege;

PROMPT

-- =====================================================
-- 6. Rezumat - Număr Privilegii per Rol
-- =====================================================

PROMPT 6. REZUMAT - NUMĂR PRIVILEGII PER ROL:
PROMPT =====================================================

SELECT 
    grantee AS Rol,
    COUNT(DISTINCT table_name) AS NumarTabele,
    COUNT(DISTINCT privilege) AS NumarPrivilegii,
    LISTAGG(DISTINCT privilege, ', ') WITHIN GROUP (ORDER BY privilege) AS Privilegii
FROM user_tab_privs
WHERE grantee LIKE '%MONEYSHOP%' OR grantee LIKE '%moneyshop%'
GROUP BY grantee
ORDER BY grantee;

PROMPT

-- =====================================================
-- 7. Verificare Roluri Acordate Utilizatorilor
-- =====================================================

PROMPT 7. ROLURI ACORDATE UTILIZATORILOR:
PROMPT =====================================================

SELECT 
    grantee AS Utilizator,
    granted_role AS Rol,
    admin_option AS AdminOption,
    default_role AS RolImplicit
FROM user_role_privs
WHERE granted_role LIKE '%MONEYSHOP%' OR granted_role LIKE '%moneyshop%'
ORDER BY grantee, granted_role;

PROMPT

-- =====================================================
-- 8. Verificare Detaliată - Ce poate face fiecare rol
-- =====================================================

PROMPT 8. DETALII COMPLETE PER ROL:
PROMPT =====================================================

DECLARE
    v_role_name VARCHAR2(128);
BEGIN
    FOR rec_role IN (
        SELECT role
        FROM user_roles
        WHERE role LIKE '%MONEYSHOP%' OR role LIKE '%moneyshop%'
        ORDER BY role
    ) LOOP
        v_role_name := rec_role.role;
        
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('----------------------------------------');
        DBMS_OUTPUT.PUT_LINE('ROL: ' || v_role_name);
        DBMS_OUTPUT.PUT_LINE('----------------------------------------');
        
        -- Tabele accesibile
        DBMS_OUTPUT.PUT_LINE('Tabele accesibile:');
        FOR rec_table IN (
            SELECT DISTINCT table_name, privilege
            FROM user_tab_privs
            WHERE grantee = v_role_name
            ORDER BY table_name, privilege
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('  - ' || rec_table.table_name || ' (' || rec_table.privilege || ')');
        END LOOP;
        
        -- Proceduri accesibile
        DBMS_OUTPUT.PUT_LINE('Proceduri/Funcții accesibile:');
        FOR rec_proc IN (
            SELECT DISTINCT object_name, privilege
            FROM user_proc_privs
            WHERE grantee = v_role_name
            ORDER BY object_name
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('  - ' || rec_proc.object_name || ' (' || rec_proc.privilege || ')');
        END LOOP;
        
        -- Roluri moștenite
        DBMS_OUTPUT.PUT_LINE('Roluri moștenite:');
        FOR rec_inherited IN (
            SELECT granted_role
            FROM user_role_privs
            WHERE grantee = v_role_name
            ORDER BY granted_role
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('  - ' || rec_inherited.granted_role);
        END LOOP;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

PROMPT
PROMPT =====================================================
PROMPT VERIFICARE COMPLETĂ FINALIZATĂ!
PROMPT =====================================================
PROMPT

