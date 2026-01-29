-- =====================================================
-- TRIGGERI LMD CU INSERARE ÎN MESAJE (VERSIUNE CORECTĂ)
-- Proiect SBD - Cerința 9.4, 9.5, 10
-- =====================================================

SET SERVEROUTPUT ON;

-- Verificare schema curentă și identificare schema tabelelor
DECLARE
    v_current_schema VARCHAR2(128);
    v_table_owner VARCHAR2(128);
    v_table_exists NUMBER;
BEGIN
    SELECT SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') INTO v_current_schema FROM DUAL;
    DBMS_OUTPUT.PUT_LINE('Schema curentă: ' || v_current_schema);
    
    -- Verifică proprietarul tabelei APLICATII
    SELECT COUNT(*), MAX(owner) INTO v_table_exists, v_table_owner
    FROM all_tables
    WHERE table_name = 'APLICATII';
    
    IF v_table_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Tabelul APLICATII nu există! Rulează mai întâi 03_CREATE_TABLES.sql');
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('Proprietar tabele: ' || v_table_owner);
    DBMS_OUTPUT.PUT_LINE('');
    
    IF v_current_schema != v_table_owner THEN
        DBMS_OUTPUT.PUT_LINE('⚠ ATENȚIE: Schema curentă (' || v_current_schema || 
                            ') diferă de proprietarul tabelelor (' || v_table_owner || ')');
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('Soluții:');
        DBMS_OUTPUT.PUT_LINE('1. Conectează-te ca utilizator: ' || v_table_owner);
        DBMS_OUTPUT.PUT_LINE('2. SAU rulează: ALTER SESSION SET CURRENT_SCHEMA = ' || v_table_owner);
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('Încercăm să setăm schema automat...');
        
        BEGIN
            EXECUTE IMMEDIATE 'ALTER SESSION SET CURRENT_SCHEMA = ' || v_table_owner;
            DBMS_OUTPUT.PUT_LINE('✓ Schema setată la: ' || v_table_owner);
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('✗ Nu s-a putut seta schema automat: ' || SQLERRM);
                DBMS_OUTPUT.PUT_LINE('');
                DBMS_OUTPUT.PUT_LINE('Te rog să te conectezi manual ca: ' || v_table_owner);
                RAISE_APPLICATION_ERROR(-20002, 'Nu se pot crea triggeri - schema incorectă!');
        END;
    ELSE
        DBMS_OUTPUT.PUT_LINE('✓ Schema corectă!');
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- =====================================================
-- TRIGGER LMD LA NIVEL DE COMANDĂ (BEFORE INSERT)
-- =====================================================
CREATE OR REPLACE TRIGGER trg_aplicatii_before_insert
BEFORE INSERT ON APLICATII
DECLARE
    v_count NUMBER;
BEGIN
    -- Verificare dacă există cel puțin un utilizator activ
    SELECT COUNT(*) INTO v_count
    FROM UTILIZATORI
    WHERE IsDeleted = 0;
    
    IF v_count = 0 THEN
        INSERT INTO MESAJE (
            cod_mesaj,
            mesaj,
            tip_mesaj,
            creat_de,
            creat_la
        ) VALUES (
            seq_mesaje.NEXTVAL,
            'ATENȚIONARE: Nu există utilizatori activi în sistem!',
            'W',
            USER,
            SYSDATE
        );
        COMMIT;
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Nu ridicăm excepții în trigger la nivel de comandă
        NULL;
END;
/

-- =====================================================
-- TRIGGER LMD LA NIVEL DE LINIE (BEFORE UPDATE)
-- =====================================================
CREATE OR REPLACE TRIGGER trg_aplicatii_before_update
BEFORE UPDATE ON APLICATII
FOR EACH ROW
DECLARE
    v_mesaj VARCHAR2(255);
BEGIN
    -- Verificare schimbare status
    IF :OLD.Status != :NEW.Status THEN
        v_mesaj := 'Status aplicație ' || :NEW.Id || ' schimbat de la ' || 
                   :OLD.Status || ' la ' || :NEW.Status;
        
        INSERT INTO MESAJE (
            cod_mesaj,
            mesaj,
            tip_mesaj,
            creat_de,
            creat_la
        ) VALUES (
            seq_mesaje.NEXTVAL,
            v_mesaj,
            'I',
            USER,
            SYSDATE
        );
    END IF;
    
    -- Verificare validare scoring
    IF :NEW.Scoring IS NOT NULL AND (:NEW.Scoring < 300 OR :NEW.Scoring > 850) THEN
        INSERT INTO MESAJE (
            cod_mesaj,
            mesaj,
            tip_mesaj,
            creat_de,
            creat_la
        ) VALUES (
            seq_mesaje.NEXTVAL,
            'EROARE: Scoring invalid pentru aplicația ' || :NEW.Id || 
            ' (valoare: ' || :NEW.Scoring || ', trebuie între 300-850)',
            'E',
            USER,
            SYSDATE
        );
        
        RAISE_APPLICATION_ERROR(-20020, 'Scoring invalid! Trebuie să fie între 300 și 850.');
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Re-ridicăm excepția pentru a opri operația
        RAISE;
END;
/

-- =====================================================
-- TRIGGER LMD LA NIVEL DE LINIE (AFTER INSERT)
-- =====================================================
CREATE OR REPLACE TRIGGER trg_aplicatii_after_insert
AFTER INSERT ON APLICATII
FOR EACH ROW
BEGIN
    INSERT INTO MESAJE (
        cod_mesaj,
        mesaj,
        tip_mesaj,
        creat_de,
        creat_la
    ) VALUES (
        seq_mesaje.NEXTVAL,
        'Aplicație nouă creată: ID=' || :NEW.Id || 
        ', Utilizator=' || :NEW.UserId || 
        ', Status=' || :NEW.Status,
        'I',
        USER,
        SYSDATE
    );
    
EXCEPTION
    WHEN OTHERS THEN
        -- Nu ridicăm excepții în trigger AFTER pentru a nu bloca INSERT-ul
        NULL;
END;
/

-- =====================================================
-- TRIGGER LMD LA NIVEL DE LINIE (AFTER DELETE)
-- =====================================================
CREATE OR REPLACE TRIGGER trg_aplicatii_after_delete
AFTER DELETE ON APLICATII
FOR EACH ROW
BEGIN
    INSERT INTO MESAJE (
        cod_mesaj,
        mesaj,
        tip_mesaj,
        creat_de,
        creat_la
    ) VALUES (
        seq_mesaje.NEXTVAL,
        'Aplicație ștearsă: ID=' || :OLD.Id || 
        ', Utilizator=' || :OLD.UserId || 
        ', Status=' || :OLD.Status,
        'W',
        USER,
        SYSDATE
    );
    
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/

-- =====================================================
-- TRIGGER LMD PENTRU UTILIZATORI (cu inserare mesaje)
-- =====================================================
CREATE OR REPLACE TRIGGER trg_utilizatori_varsta_mesaje
BEFORE INSERT OR UPDATE OF DataNastere ON UTILIZATORI
FOR EACH ROW
BEGIN
    IF :NEW.DataNastere > ADD_MONTHS(SYSDATE, -216) THEN
        INSERT INTO MESAJE (
            cod_mesaj,
            mesaj,
            tip_mesaj,
            creat_de,
            creat_la
        ) VALUES (
            seq_mesaje.NEXTVAL,
            'EROARE: Utilizator ' || :NEW.IdUtilizator || 
            ' are vârsta mai mică de 18 ani!',
            'E',
            USER,
            SYSDATE
        );
        COMMIT;
        
        RAISE_APPLICATION_ERROR(-20005, 'Utilizatorul trebuie să aibă minim 18 ani');
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;
/

-- Verificare triggeri creați
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('VERIFICARE TRIGGERI CREAȚI');
    DBMS_OUTPUT.PUT_LINE('========================================');
    
    DECLARE
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM user_triggers
        WHERE trigger_name IN ('TRG_APLICATII_BEFORE_INSERT',
                               'TRG_APLICATII_BEFORE_UPDATE',
                               'TRG_APLICATII_AFTER_INSERT',
                               'TRG_APLICATII_AFTER_DELETE',
                               'TRG_UTILIZATORI_VARSTA_MESAJE');
        
        DBMS_OUTPUT.PUT_LINE('Număr triggeri creați: ' || v_count);
        
        IF v_count = 5 THEN
            DBMS_OUTPUT.PUT_LINE('✓ TOȚI TRIGGERII AU FOST CREAȚI CU SUCCES!');
        ELSE
            DBMS_OUTPUT.PUT_LINE('⚠ Doar ' || v_count || ' din 5 triggeri au fost creați!');
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('Lista triggeri:');
        FOR rec IN (
            SELECT trigger_name, status, table_name
            FROM user_triggers
            WHERE trigger_name IN ('TRG_APLICATII_BEFORE_INSERT',
                                   'TRG_APLICATII_BEFORE_UPDATE',
                                   'TRG_APLICATII_AFTER_INSERT',
                                   'TRG_APLICATII_AFTER_DELETE',
                                   'TRG_UTILIZATORI_VARSTA_MESAJE')
            ORDER BY trigger_name
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('  ✓ ' || rec.trigger_name || ' (' || rec.status || ') - ' || rec.table_name);
        END LOOP;
    END;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Toți triggerii inserează mesaje în tabelul MESAJE!');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

