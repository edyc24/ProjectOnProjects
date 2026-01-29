-- =====================================================
-- FUNCȚIE PL/SQL CU 3 TABELE + TRATARE EXCEPȚII
-- Proiect SBD - Cerința 9.3
-- =====================================================

SET SERVEROUTPUT ON;

-- Definire excepții proprii
CREATE OR REPLACE FUNCTION FN_CALCUL_STATISTICI_UTILIZATOR (
    p_id_utilizator IN NUMBER
) RETURN VARCHAR2
IS
    -- Excepții proprii
    ex_utilizator_inexistent EXCEPTION;
    ex_date_insuficiente EXCEPTION;
    
    PRAGMA EXCEPTION_INIT(ex_utilizator_inexistent, -20001);
    PRAGMA EXCEPTION_INIT(ex_date_insuficiente, -20002);
    
    -- Variabile pentru rezultate
    v_nume_complet VARCHAR2(200);
    v_numar_aplicatii NUMBER := 0;
    v_suma_totala NUMBER := 0;
    v_scoring_mediu NUMBER := 0;
    v_numar_banci NUMBER := 0;
    v_rezultat VARCHAR2(1000);
    
    -- Variabile pentru verificări
    v_utilizator_exista NUMBER := 0;
    v_aplicatii_exista NUMBER := 0;
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Calcul statistici pentru utilizator: ' || p_id_utilizator);
    DBMS_OUTPUT.PUT_LINE('========================================');
    
    -- Verificare existență utilizator
    SELECT COUNT(*) INTO v_utilizator_exista
    FROM UTILIZATORI
    WHERE IdUtilizator = p_id_utilizator
    AND IsDeleted = 0;
    
    IF v_utilizator_exista = 0 THEN
        RAISE ex_utilizator_inexistent;
    END IF;
    
    -- Interogare SQL care folosește 3 tabele într-o singură comandă:
    -- UTILIZATORI, APLICATII, APPLICATION_BANKS
    SELECT 
        u.Nume || ' ' || u.Prenume AS NumeComplet,
        COUNT(DISTINCT a.Id) AS NumarAplicatii,
        SUM(NVL(a.SumaAprobata, 0)) AS SumaTotala,
        AVG(a.Scoring) AS ScoringMediu,
        COUNT(DISTINCT ab.BankId) AS NumarBanci
    INTO 
        v_nume_complet,
        v_numar_aplicatii,
        v_suma_totala,
        v_scoring_mediu,
        v_numar_banci
    FROM UTILIZATORI u
    LEFT JOIN APLICATII a ON u.IdUtilizator = a.UserId
    LEFT JOIN APPLICATION_BANKS ab ON a.Id = ab.ApplicationId
    WHERE u.IdUtilizator = p_id_utilizator
    AND u.IsDeleted = 0
    GROUP BY u.IdUtilizator, u.Nume, u.Prenume;
    
    -- Verificare date suficiente
    IF v_numar_aplicatii = 0 THEN
        RAISE ex_date_insuficiente;
    END IF;
    
    -- Construire rezultat
    v_rezultat := 'Utilizator: ' || v_nume_complet || ' | ' ||
                  'Aplicații: ' || v_numar_aplicatii || ' | ' ||
                  'Suma totală: ' || TO_CHAR(v_suma_totala, '999,999,999.00') || ' | ' ||
                  'Scoring mediu: ' || NVL(TO_CHAR(ROUND(v_scoring_mediu, 2)), 'N/A') || ' | ' ||
                  'Bănci: ' || v_numar_banci;
    
    DBMS_OUTPUT.PUT_LINE('Rezultat: ' || v_rezultat);
    DBMS_OUTPUT.PUT_LINE('========================================');
    
    RETURN v_rezultat;
    
EXCEPTION
    -- Tratare excepție 1: Utilizator inexistent
    WHEN ex_utilizator_inexistent THEN
        DBMS_OUTPUT.PUT_LINE('EROARE: Utilizatorul cu ID ' || p_id_utilizator || ' nu există sau este șters!');
        RETURN 'EROARE: Utilizator inexistent (ID: ' || p_id_utilizator || ')';
    
    -- Tratare excepție 2: Date insuficiente
    WHEN ex_date_insuficiente THEN
        DBMS_OUTPUT.PUT_LINE('EROARE: Utilizatorul nu are aplicații!');
        RETURN 'EROARE: Date insuficiente - utilizatorul nu are aplicații';
    
    -- Tratare excepție 3: NO_DATA_FOUND (predefinită)
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('EROARE: Nu s-au găsit date pentru utilizator!');
        RETURN 'EROARE: Date negăsite pentru utilizator (ID: ' || p_id_utilizator || ')';
    
    -- Tratare excepție 4: TOO_MANY_ROWS (predefinită)
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('EROARE: S-au găsit mai multe înregistrări decât așteptat!');
        RETURN 'EROARE: Date duplicate pentru utilizator (ID: ' || p_id_utilizator || ')';
    
    -- Tratare excepție 5: OTHERS (toate celelalte)
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EROARE NEAȘTEPTATĂ: ' || SQLCODE || ' - ' || SQLERRM);
        RETURN 'EROARE: ' || SQLCODE || ' - ' || SUBSTR(SQLERRM, 1, 200);
END;
/

-- Testare funcție cu toate cazurile
DECLARE
    v_rezultat VARCHAR2(1000);
    v_id_utilizator_valid NUMBER;
    v_id_utilizator_inexistent NUMBER := 99999;
    v_id_utilizator_fara_aplicatii NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('TESTARE FUNCȚIE FN_CALCUL_STATISTICI_UTILIZATOR');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test 1: Utilizator valid cu aplicații
    DBMS_OUTPUT.PUT_LINE('TEST 1: Utilizator valid cu aplicații');
    BEGIN
        SELECT IdUtilizator INTO v_id_utilizator_valid
        FROM (
            SELECT u.IdUtilizator
            FROM UTILIZATORI u
            INNER JOIN APLICATII a ON u.IdUtilizator = a.UserId
            WHERE u.IsDeleted = 0
            AND ROWNUM = 1
        );
        
        v_rezultat := FN_CALCUL_STATISTICI_UTILIZATOR(v_id_utilizator_valid);
        DBMS_OUTPUT.PUT_LINE('Rezultat: ' || v_rezultat);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Nu există utilizatori cu aplicații pentru test!');
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test 2: Utilizator inexistent
    DBMS_OUTPUT.PUT_LINE('TEST 2: Utilizator inexistent');
    v_rezultat := FN_CALCUL_STATISTICI_UTILIZATOR(v_id_utilizator_inexistent);
    DBMS_OUTPUT.PUT_LINE('Rezultat: ' || v_rezultat);
    
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test 3: Utilizator fără aplicații
    DBMS_OUTPUT.PUT_LINE('TEST 3: Utilizator fără aplicații');
    BEGIN
        SELECT IdUtilizator INTO v_id_utilizator_fara_aplicatii
        FROM (
            SELECT u.IdUtilizator
            FROM UTILIZATORI u
            WHERE u.IsDeleted = 0
            AND NOT EXISTS (
                SELECT 1 FROM APLICATII a WHERE a.UserId = u.IdUtilizator
            )
            AND ROWNUM = 1
        );
        
        v_rezultat := FN_CALCUL_STATISTICI_UTILIZATOR(v_id_utilizator_fara_aplicatii);
        DBMS_OUTPUT.PUT_LINE('Rezultat: ' || v_rezultat);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Nu există utilizatori fără aplicații pentru test!');
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Toate testele au fost executate!');
    
END;
/

