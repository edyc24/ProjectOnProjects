SET SERVEROUTPUT ON;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Început adăugare constrângeri DW...');
    DBMS_OUTPUT.PUT_LINE('');
END;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('1. Adăugare Foreign Keys...');
END;
/
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE FACT_APLICATII_CREDIT
        ADD CONSTRAINT fk_fact_utilizator 
        FOREIGN KEY (IdUtilizator) REFERENCES DIM_UTILIZATOR(IdUtilizator)';
    DBMS_OUTPUT.PUT_LINE('  ✓ fk_fact_utilizator');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -2275 THEN
            DBMS_OUTPUT.PUT_LINE('  ⚠ fk_fact_utilizator există deja');
        ELSE
            DBMS_OUTPUT.PUT_LINE('  ✗ Eroare fk_fact_utilizator: ' || SQLERRM);
        END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE FACT_APLICATII_CREDIT
        ADD CONSTRAINT fk_fact_banca 
        FOREIGN KEY (IdBanca) REFERENCES DIM_BANCA(IdBanca)';
    DBMS_OUTPUT.PUT_LINE('  ✓ fk_fact_banca');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -2275 THEN
            DBMS_OUTPUT.PUT_LINE('  ⚠ fk_fact_banca există deja');
        ELSE
            DBMS_OUTPUT.PUT_LINE('  ✗ Eroare fk_fact_banca: ' || SQLERRM);
        END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE FACT_APLICATII_CREDIT
        ADD CONSTRAINT fk_fact_timp 
        FOREIGN KEY (IdTimp) REFERENCES DIM_TIMP(IdTimp)';
    DBMS_OUTPUT.PUT_LINE('  ✓ fk_fact_timp');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -2275 THEN
            DBMS_OUTPUT.PUT_LINE('  ⚠ fk_fact_timp există deja');
        ELSE
            DBMS_OUTPUT.PUT_LINE('  ✗ Eroare fk_fact_timp: ' || SQLERRM);
        END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE FACT_APLICATII_CREDIT
        ADD CONSTRAINT fk_fact_tip_credit 
        FOREIGN KEY (IdTipCredit) REFERENCES DIM_TIP_CREDIT(IdTipCredit)';
    DBMS_OUTPUT.PUT_LINE('  ✓ fk_fact_tip_credit');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -2275 THEN
            DBMS_OUTPUT.PUT_LINE('  ⚠ fk_fact_tip_credit există deja');
        ELSE
            DBMS_OUTPUT.PUT_LINE('  ✗ Eroare fk_fact_tip_credit: ' || SQLERRM);
        END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE FACT_APLICATII_CREDIT
        ADD CONSTRAINT fk_fact_status 
        FOREIGN KEY (IdStatus) REFERENCES DIM_STATUS(IdStatus)';
    DBMS_OUTPUT.PUT_LINE('  ✓ fk_fact_status');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -2275 THEN
            DBMS_OUTPUT.PUT_LINE('  ⚠ fk_fact_status există deja');
        ELSE
            DBMS_OUTPUT.PUT_LINE('  ✗ Eroare fk_fact_status: ' || SQLERRM);
        END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE FACT_APLICATII_CREDIT
        ADD CONSTRAINT fk_fact_broker 
        FOREIGN KEY (IdBroker) REFERENCES DIM_BROKER(IdBroker)';
    DBMS_OUTPUT.PUT_LINE('  ✓ fk_fact_broker');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -2275 THEN
            DBMS_OUTPUT.PUT_LINE('  ⚠ fk_fact_broker există deja');
        ELSE
            DBMS_OUTPUT.PUT_LINE('  ✗ Eroare fk_fact_broker: ' || SQLERRM);
        END IF;
END;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('2. Adăugare Check Constraints...');
END;
/
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE FACT_APLICATII_CREDIT
        ADD CONSTRAINT chk_fact_scoring 
        CHECK (Scoring IS NULL OR (Scoring >= 300 AND Scoring <= 850))';
    DBMS_OUTPUT.PUT_LINE('  ✓ chk_fact_scoring');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -2275 THEN
            DBMS_OUTPUT.PUT_LINE('  ⚠ chk_fact_scoring există deja');
        ELSE
            DBMS_OUTPUT.PUT_LINE('  ✗ Eroare chk_fact_scoring: ' || SQLERRM);
        END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE FACT_APLICATII_CREDIT
        ADD CONSTRAINT chk_fact_dti 
        CHECK (Dti IS NULL OR (Dti >= 0 AND Dti <= 100))';
    DBMS_OUTPUT.PUT_LINE('  ✓ chk_fact_dti');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -2275 THEN
            DBMS_OUTPUT.PUT_LINE('  ⚠ chk_fact_dti există deja');
        ELSE
            DBMS_OUTPUT.PUT_LINE('  ✗ Eroare chk_fact_dti: ' || SQLERRM);
        END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE FACT_APLICATII_CREDIT
        ADD CONSTRAINT chk_fact_suma_aprobata 
        CHECK (SumaAprobata >= 0)';
    DBMS_OUTPUT.PUT_LINE('  ✓ chk_fact_suma_aprobata');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -2275 THEN
            DBMS_OUTPUT.PUT_LINE('  ⚠ chk_fact_suma_aprobata există deja');
        ELSE
            DBMS_OUTPUT.PUT_LINE('  ✗ Eroare chk_fact_suma_aprobata: ' || SQLERRM);
        END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE FACT_APLICATII_CREDIT
        ADD CONSTRAINT chk_fact_comision 
        CHECK (Comision >= 0)';
    DBMS_OUTPUT.PUT_LINE('  ✓ chk_fact_comision');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -2275 THEN
            DBMS_OUTPUT.PUT_LINE('  ⚠ chk_fact_comision există deja');
        ELSE
            DBMS_OUTPUT.PUT_LINE('  ✗ Eroare chk_fact_comision: ' || SQLERRM);
        END IF;
END;
/
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE FACT_APLICATII_CREDIT
        ADD CONSTRAINT chk_fact_durata_procesare 
        CHECK (DurataProcesare >= 0)';
    DBMS_OUTPUT.PUT_LINE('  ✓ chk_fact_durata_procesare');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE = -2275 THEN
            DBMS_OUTPUT.PUT_LINE('  ⚠ chk_fact_durata_procesare există deja');
        ELSE
            DBMS_OUTPUT.PUT_LINE('  ✗ Eroare chk_fact_durata_procesare: ' || SQLERRM);
        END IF;
END;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('3. Adăugare NOT NULL Constraints...');
END;
/
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE FACT_APLICATII_CREDIT
        MODIFY IdUtilizator NOT NULL';
    DBMS_OUTPUT.PUT_LINE('  ✓ IdUtilizator NOT NULL');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('  ✗ Eroare IdUtilizator NOT NULL: ' || SQLERRM);
END;
/
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE FACT_APLICATII_CREDIT
        MODIFY IdBanca NOT NULL';
    DBMS_OUTPUT.PUT_LINE('  ✓ IdBanca NOT NULL');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('  ✗ Eroare IdBanca NOT NULL: ' || SQLERRM);
END;
/
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE FACT_APLICATII_CREDIT
        MODIFY IdTimp NOT NULL';
    DBMS_OUTPUT.PUT_LINE('  ✓ IdTimp NOT NULL');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('  ✗ Eroare IdTimp NOT NULL: ' || SQLERRM);
END;
/
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE FACT_APLICATII_CREDIT
        MODIFY IdTipCredit NOT NULL';
    DBMS_OUTPUT.PUT_LINE('  ✓ IdTipCredit NOT NULL');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('  ✗ Eroare IdTipCredit NOT NULL: ' || SQLERRM);
END;
/
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE FACT_APLICATII_CREDIT
        MODIFY IdStatus NOT NULL';
    DBMS_OUTPUT.PUT_LINE('  ✓ IdStatus NOT NULL');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('  ✗ Eroare IdStatus NOT NULL: ' || SQLERRM);
END;
/
BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE FACT_APLICATII_CREDIT
        MODIFY SumaAprobata DEFAULT 0';
    DBMS_OUTPUT.PUT_LINE('  ✓ SumaAprobata DEFAULT 0');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('  ✗ Eroare SumaAprobata DEFAULT: ' || SQLERRM);
END;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('4. Verificare constrângeri...');
END;
/
SELECT 
    CONSTRAINT_NAME,
    CONSTRAINT_TYPE,
    TABLE_NAME,
    STATUS
FROM USER_CONSTRAINTS
WHERE TABLE_NAME IN ('FACT_APLICATII_CREDIT', 'DIM_UTILIZATOR', 'DIM_BANCA', 'DIM_TIMP', 'DIM_TIP_CREDIT', 'DIM_STATUS', 'DIM_BROKER')
ORDER BY TABLE_NAME, CONSTRAINT_TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('CONSTRÂNGERI DW - COMPLETAT!');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Constrângeri create:');
    DBMS_OUTPUT.PUT_LINE('  - 6 Foreign Keys');
    DBMS_OUTPUT.PUT_LINE('  - 5 Check Constraints');
    DBMS_OUTPUT.PUT_LINE('  - 5 NOT NULL Constraints');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Următorul pas: Rulează 08_DW_INDEXES.sql');
    DBMS_OUTPUT.PUT_LINE('');
END;
/