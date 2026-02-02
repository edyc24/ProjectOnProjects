-- =====================================================
-- POPULARE AUDIT_LOG - MoneyShop
-- Script pentru adăugare date de test în tabela AUDIT_LOG
-- =====================================================

SET SERVEROUTPUT ON;

PROMPT =====================================================
PROMPT POPULARE AUDIT_LOG
PROMPT =====================================================
PROMPT

-- Verificare existență tabel
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM user_tables
    WHERE table_name = 'AUDIT_LOG';
    
    IF v_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('❌ Tabelul AUDIT_LOG nu există!');
        DBMS_OUTPUT.PUT_LINE('   Rulează mai întâi: @03_CREATE_TABLES.sql');
        RAISE_APPLICATION_ERROR(-20000, 'Tabelul AUDIT_LOG nu există');
    ELSE
        DBMS_OUTPUT.PUT_LINE('✅ Tabelul AUDIT_LOG există');
    END IF;
END;
/

-- Verificare număr înregistrări existente
DECLARE
    v_count_before NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count_before FROM AUDIT_LOG;
    DBMS_OUTPUT.PUT_LINE('📊 Înregistrări existente: ' || v_count_before);
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- =====================================================
-- INSERARE DATE DE TEST
-- =====================================================

PROMPT Inserare date în AUDIT_LOG...
PROMPT

BEGIN
    -- 1. INSERT pe UTILIZATORI
    INSERT INTO AUDIT_LOG (
        TableName, 
        Operation, 
        UserId, 
        OldValues, 
        NewValues, 
        IpAddress, 
        Timestamp
    ) VALUES (
        'UTILIZATORI',
        'INSERT',
        1,
        NULL,
        '{"IdUtilizator":1,"Username":"client1","Nume":"Popescu","Prenume":"Ion","Email":"ion.popescu@email.com","IdRol":1}',
        '192.168.1.100',
        SYSTIMESTAMP - INTERVAL '5' DAY
    );
    
    -- 2. UPDATE pe UTILIZATORI
    INSERT INTO AUDIT_LOG (
        TableName, 
        Operation, 
        UserId, 
        OldValues, 
        NewValues, 
        IpAddress, 
        Timestamp
    ) VALUES (
        'UTILIZATORI',
        'UPDATE',
        1,
        '{"IdUtilizator":1,"Email":"ion.popescu@old.com","NumarTelefon":"0712345678"}',
        '{"IdUtilizator":1,"Email":"ion.popescu@email.com","NumarTelefon":"0712345679"}',
        '192.168.1.100',
        SYSTIMESTAMP - INTERVAL '4' DAY
    );
    
    -- 3. INSERT pe APLICATII
    INSERT INTO AUDIT_LOG (
        TableName, 
        Operation, 
        UserId, 
        OldValues, 
        NewValues, 
        IpAddress, 
        Timestamp
    ) VALUES (
        'APLICATII',
        'INSERT',
        1,
        NULL,
        '{"Id":1,"UserId":1,"Status":"INREGISTRAT","TypeCredit":"IPOTECAR","Scoring":750,"Dti":35}',
        '192.168.1.100',
        SYSTIMESTAMP - INTERVAL '3' DAY
    );
    
    -- 4. UPDATE pe APLICATII (schimbare status)
    INSERT INTO AUDIT_LOG (
        TableName, 
        Operation, 
        UserId, 
        OldValues, 
        NewValues, 
        IpAddress, 
        Timestamp
    ) VALUES (
        'APLICATII',
        'UPDATE',
        1,
        '{"Id":1,"Status":"INREGISTRAT","Scoring":750}',
        '{"Id":1,"Status":"IN_PROCESARE","Scoring":780}',
        '192.168.1.101',
        SYSTIMESTAMP - INTERVAL '2' DAY
    );
    
    -- 5. INSERT pe APLICATII (a doua aplicație)
    INSERT INTO AUDIT_LOG (
        TableName, 
        Operation, 
        UserId, 
        OldValues, 
        NewValues, 
        IpAddress, 
        Timestamp
    ) VALUES (
        'APLICATII',
        'INSERT',
        2,
        NULL,
        '{"Id":2,"UserId":2,"Status":"INREGISTRAT","TypeCredit":"NEPERSONALIZAT","Scoring":800,"Dti":30}',
        '192.168.1.102',
        SYSTIMESTAMP - INTERVAL '1' DAY
    );
    
    -- 6. UPDATE pe APLICATII (aprobare)
    INSERT INTO AUDIT_LOG (
        TableName, 
        Operation, 
        UserId, 
        OldValues, 
        NewValues, 
        IpAddress, 
        Timestamp
    ) VALUES (
        'APLICATII',
        'UPDATE',
        1,
        '{"Id":1,"Status":"IN_PROCESARE","SumaAprobata":null}',
        '{"Id":1,"Status":"APROBAT","SumaAprobata":150000,"RecommendedLevel":"RIDICAT"}',
        '192.168.1.50',
        SYSTIMESTAMP - INTERVAL '12' HOUR
    );
    
    -- 7. INSERT pe CONSENTURI
    INSERT INTO AUDIT_LOG (
        TableName, 
        Operation, 
        UserId, 
        OldValues, 
        NewValues, 
        IpAddress, 
        Timestamp
    ) VALUES (
        'CONSENTURI',
        'INSERT',
        1,
        NULL,
        '{"Id":1,"UserId":1,"ConsentType":"GDPR","Status":"granted","Scope":"credit_eligibility_only"}',
        '192.168.1.100',
        SYSTIMESTAMP - INTERVAL '6' HOUR
    );
    
    -- 8. INSERT pe MANDATE
    INSERT INTO AUDIT_LOG (
        TableName, 
        Operation, 
        UserId, 
        OldValues, 
        NewValues, 
        IpAddress, 
        Timestamp
    ) VALUES (
        'MANDATE',
        'INSERT',
        1,
        NULL,
        '{"Id":1,"UserId":1,"BrokerId":6,"Status":"ACTIVE","StartDate":"2024-01-15","EndDate":"2025-01-15"}',
        '192.168.1.100',
        SYSTIMESTAMP - INTERVAL '4' HOUR
    );
    
    -- 9. DELETE pe APLICATII (anulare)
    INSERT INTO AUDIT_LOG (
        TableName, 
        Operation, 
        UserId, 
        OldValues, 
        NewValues, 
        IpAddress, 
        Timestamp
    ) VALUES (
        'APLICATII',
        'DELETE',
        3,
        '{"Id":3,"UserId":3,"Status":"INREGISTRAT","TypeCredit":"PERSONALIZAT"}',
        NULL,
        '192.168.1.103',
        SYSTIMESTAMP - INTERVAL '2' HOUR
    );
    
    -- 10. UPDATE pe UTILIZATORI (schimbare parolă)
    INSERT INTO AUDIT_LOG (
        TableName, 
        Operation, 
        UserId, 
        OldValues, 
        NewValues, 
        IpAddress, 
        Timestamp
    ) VALUES (
        'UTILIZATORI',
        'UPDATE',
        2,
        '{"IdUtilizator":2,"Parola":"hash_old_123"}',
        '{"IdUtilizator":2,"Parola":"hash_new_456","UpdatedAt":"' || TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || '"}',
        '192.168.1.102',
        SYSTIMESTAMP - INTERVAL '1' HOUR
    );
    
    -- 11. INSERT pe DOCUMENTE
    INSERT INTO AUDIT_LOG (
        TableName, 
        Operation, 
        UserId, 
        OldValues, 
        NewValues, 
        IpAddress, 
        Timestamp
    ) VALUES (
        'DOCUMENTE',
        'INSERT',
        1,
        NULL,
        '{"Id":1,"ApplicationId":1,"DocumentType":"CI","FileName":"ci_scan.pdf","FileSize":245678,"Status":"UPLOADED"}',
        '192.168.1.100',
        SYSTIMESTAMP - INTERVAL '30' MINUTE
    );
    
    -- 12. UPDATE pe DOCUMENTE (validare)
    INSERT INTO AUDIT_LOG (
        TableName, 
        Operation, 
        UserId, 
        OldValues, 
        NewValues, 
        IpAddress, 
        Timestamp
    ) VALUES (
        'DOCUMENTE',
        'UPDATE',
        1,
        '{"Id":1,"Status":"UPLOADED","ValidatedBy":null}',
        '{"Id":1,"Status":"VALIDAT","ValidatedBy":6,"ValidatedAt":"' || TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS') || '"}',
        '192.168.1.50',
        SYSTIMESTAMP - INTERVAL '15' MINUTE
    );
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('✅ 12 înregistrări inserate cu succes!');
    DBMS_OUTPUT.PUT_LINE('');
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('❌ Eroare la inserare: ' || SQLERRM);
        RAISE;
END;
/

-- =====================================================
-- VERIFICARE FINALĂ
-- =====================================================

PROMPT =====================================================
PROMPT VERIFICARE FINALĂ
PROMPT =====================================================
PROMPT

SELECT 
    COUNT(*) AS TotalInregistrari,
    COUNT(DISTINCT TableName) AS TabeleAuditate,
    COUNT(DISTINCT Operation) AS TipuriOperatii,
    COUNT(DISTINCT UserId) AS UtilizatoriUnici
FROM AUDIT_LOG;

PROMPT
PROMPT Ultimele 5 înregistrări:
PROMPT

SELECT 
    Id,
    TableName,
    Operation,
    UserId,
    IpAddress,
    TO_CHAR(Timestamp, 'DD-MM-YYYY HH24:MI:SS') AS DataOra
FROM (
    SELECT * FROM AUDIT_LOG
    ORDER BY Timestamp DESC
)
WHERE ROWNUM <= 5;

PROMPT
PROMPT Statistici pe tipuri de operații:
PROMPT

SELECT 
    Operation,
    COUNT(*) AS Numar
FROM AUDIT_LOG
GROUP BY Operation
ORDER BY Operation;

PROMPT
PROMPT Statistici pe tabele:
PROMPT

SELECT 
    TableName,
    COUNT(*) AS NumarOperatii,
    COUNT(DISTINCT UserId) AS UtilizatoriUnici
FROM AUDIT_LOG
GROUP BY TableName
ORDER BY NumarOperatii DESC;

PROMPT
PROMPT =====================================================
PROMPT ✅ POPULARE COMPLETĂ!
PROMPT =====================================================
PROMPT

