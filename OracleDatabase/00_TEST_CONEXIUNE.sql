-- =====================================================
-- TEST CONEXIUNE ORACLE
-- =====================================================
-- 
-- Rulează acest script pentru a testa conexiunea
--
-- =====================================================

SET SERVEROUTPUT ON;

PROMPT =====================================================
PROMPT TEST CONEXIUNE
PROMPT =====================================================
PROMPT

-- Verificare utilizator curent
SELECT 
    'Utilizator: ' || USER AS Info
FROM DUAL;

SELECT 
    'Schema: ' || SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') AS Info
FROM DUAL;

SELECT 
    'Container: ' || SYS_CONTEXT('USERENV', 'CON_NAME') AS Info
FROM DUAL;

SELECT 
    'Database: ' || SYS_CONTEXT('USERENV', 'DB_NAME') AS Info
FROM DUAL;

PROMPT
PROMPT ✅ Conexiune activă!
PROMPT =====================================================

