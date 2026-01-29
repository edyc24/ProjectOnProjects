-- =====================================================
-- Gestiunea Utilizatorilor și Resurselor Computaționale
-- MoneyShop - Oracle Database 19c+
-- =====================================================

SET SERVEROUTPUT ON;

-- =====================================================
-- 1. Matrici Proces-Utilizator
-- =====================================================

-- Tabelă pentru definirea proceselor
CREATE TABLE PROCESE (
    IdProces NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    NumeProces VARCHAR2(100) NOT NULL UNIQUE,
    Descriere VARCHAR2(500),
    TipProces VARCHAR2(50) NOT NULL, -- 'READ', 'WRITE', 'DELETE', 'ADMIN'
    CreatedAt TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT chk_tip_proces CHECK (TipProces IN ('READ', 'WRITE', 'DELETE', 'ADMIN', 'EXECUTE'))
);

COMMENT ON TABLE PROCESE IS 'Tabela pentru definirea proceselor din sistem';
COMMENT ON COLUMN PROCESE.TipProces IS 'Tipul procesului: READ, WRITE, DELETE, ADMIN, EXECUTE';

-- Tabelă pentru matricea proces-utilizator
CREATE TABLE PROCES_UTILIZATOR (
    Id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    IdProces NUMBER NOT NULL,
    IdUtilizator NUMBER NOT NULL,
    Status VARCHAR2(50) DEFAULT 'ACTIV',
    DataAsignare TIMESTAMP DEFAULT SYSTIMESTAMP,
    DataExpirare TIMESTAMP,
    CreatedAt TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT fk_proc_util_proces FOREIGN KEY (IdProces) REFERENCES PROCESE(IdProces),
    CONSTRAINT fk_proc_util_user FOREIGN KEY (IdUtilizator) REFERENCES UTILIZATORI(IdUtilizator),
    CONSTRAINT chk_proc_util_status CHECK (Status IN ('ACTIV', 'INACTIV', 'EXPIRAT')),
    CONSTRAINT uk_proc_util UNIQUE (IdProces, IdUtilizator)
);

COMMENT ON TABLE PROCES_UTILIZATOR IS 'Matricea proces-utilizator: ce procese poate executa fiecare utilizator';

-- Inserare procese standard
INSERT INTO PROCESE (NumeProces, Descriere, TipProces) VALUES ('VIEW_OWN_APPLICATIONS', 'Vizualizare propriile aplicații', 'READ');
INSERT INTO PROCESE (NumeProces, Descriere, TipProces) VALUES ('CREATE_APPLICATION', 'Creare aplicație nouă', 'WRITE');
INSERT INTO PROCESE (NumeProces, Descriere, TipProces) VALUES ('UPDATE_OWN_APPLICATION', 'Actualizare propria aplicație', 'WRITE');
INSERT INTO PROCESE (NumeProces, Descriere, TipProces) VALUES ('DELETE_OWN_APPLICATION', 'Ștergere propria aplicație', 'DELETE');
INSERT INTO PROCESE (NumeProces, Descriere, TipProces) VALUES ('VIEW_ALL_APPLICATIONS', 'Vizualizare toate aplicațiile (broker)', 'READ');
INSERT INTO PROCESE (NumeProces, Descriere, TipProces) VALUES ('PROCESS_APPLICATION', 'Procesare aplicație (broker)', 'WRITE');
INSERT INTO PROCESE (NumeProces, Descriere, TipProces) VALUES ('VIEW_USERS', 'Vizualizare utilizatori (admin)', 'READ');
INSERT INTO PROCESE (NumeProces, Descriere, TipProces) VALUES ('MANAGE_USERS', 'Gestionare utilizatori (admin)', 'ADMIN');
INSERT INTO PROCESE (NumeProces, Descriere, TipProces) VALUES ('VIEW_REPORTS', 'Vizualizare rapoarte', 'READ');
INSERT INTO PROCESE (NumeProces, Descriere, TipProces) VALUES ('EXECUTE_ADMIN_PROC', 'Executare proceduri admin', 'EXECUTE');

COMMIT;

-- =====================================================
-- 2. Matrici Entitate-Proces
-- =====================================================

-- Tabelă pentru matricea entitate-proces
CREATE TABLE ENTITATE_PROCES (
    Id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    NumeEntitate VARCHAR2(100) NOT NULL, -- Nume tabel sau entitate
    IdProces NUMBER NOT NULL,
    Permisiune VARCHAR2(50) NOT NULL, -- 'ALLOW', 'DENY'
    CreatedAt TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT fk_ent_proc_proces FOREIGN KEY (IdProces) REFERENCES PROCESE(IdProces),
    CONSTRAINT chk_permisiune CHECK (Permisiune IN ('ALLOW', 'DENY')),
    CONSTRAINT uk_ent_proc UNIQUE (NumeEntitate, IdProces)
);

COMMENT ON TABLE ENTITATE_PROCES IS 'Matricea entitate-proces: ce procese pot accesa ce entități';

-- Inserare reguli entitate-proces
-- CLIENT poate accesa doar propriile date
INSERT INTO ENTITATE_PROCES (NumeEntitate, IdProces, Permisiune)
SELECT 'UTILIZATORI', IdProces, 'ALLOW' FROM PROCESE WHERE NumeProces = 'VIEW_OWN_APPLICATIONS';

INSERT INTO ENTITATE_PROCES (NumeEntitate, IdProces, Permisiune)
SELECT 'APLICATII', IdProces, 'ALLOW' FROM PROCESE WHERE NumeProces IN ('VIEW_OWN_APPLICATIONS', 'CREATE_APPLICATION', 'UPDATE_OWN_APPLICATION', 'DELETE_OWN_APPLICATION');

-- BROKER poate accesa toate aplicațiile
INSERT INTO ENTITATE_PROCES (NumeEntitate, IdProces, Permisiune)
SELECT 'APLICATII', IdProces, 'ALLOW' FROM PROCESE WHERE NumeProces IN ('VIEW_ALL_APPLICATIONS', 'PROCESS_APPLICATION');

-- ADMIN poate accesa tot
INSERT INTO ENTITATE_PROCES (NumeEntitate, IdProces, Permisiune)
SELECT 'UTILIZATORI', IdProces, 'ALLOW' FROM PROCESE WHERE NumeProces IN ('VIEW_USERS', 'MANAGE_USERS');

INSERT INTO ENTITATE_PROCES (NumeEntitate, IdProces, Permisiune)
SELECT 'APLICATII', IdProces, 'ALLOW' FROM PROCESE WHERE NumeProces IN ('VIEW_ALL_APPLICATIONS', 'PROCESS_APPLICATION');

COMMIT;

-- =====================================================
-- 3. Matrici Entitate-Utilizator
-- =====================================================

-- Tabelă pentru matricea entitate-utilizator (privilegii directe)
CREATE TABLE ENTITATE_UTILIZATOR (
    Id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    NumeEntitate VARCHAR2(100) NOT NULL,
    IdUtilizator NUMBER NOT NULL,
    TipAcces VARCHAR2(50) NOT NULL, -- 'READ', 'WRITE', 'DELETE', 'ALL'
    ConditieWhere VARCHAR2(1000), -- Condiție WHERE pentru acces restricționat
    Status VARCHAR2(50) DEFAULT 'ACTIV',
    CreatedAt TIMESTAMP DEFAULT SYSTIMESTAMP,
    CONSTRAINT fk_ent_util_user FOREIGN KEY (IdUtilizator) REFERENCES UTILIZATORI(IdUtilizator),
    CONSTRAINT chk_tip_acces CHECK (TipAcces IN ('READ', 'WRITE', 'DELETE', 'ALL')),
    CONSTRAINT chk_ent_util_status CHECK (Status IN ('ACTIV', 'INACTIV', 'EXPIRAT'))
);

COMMENT ON TABLE ENTITATE_UTILIZATOR IS 'Matricea entitate-utilizator: acces direct la entități pentru utilizatori specifici';
COMMENT ON COLUMN ENTITATE_UTILIZATOR.ConditieWhere IS 'Condiție WHERE pentru restricționarea accesului (ex: UserId = :user_id)';

-- =====================================================
-- 4. Funcții pentru verificare acces
-- =====================================================

-- Funcție pentru verificare dacă utilizatorul poate executa un proces
CREATE OR REPLACE FUNCTION fn_utilizator_poate_proces (
    p_user_id IN NUMBER,
    p_nume_proces IN VARCHAR2
) RETURN NUMBER
IS
    v_count NUMBER;
    v_rol VARCHAR2(50);
BEGIN
    -- Verificare directă în matricea proces-utilizator
    SELECT COUNT(*) INTO v_count
    FROM PROCES_UTILIZATOR pu
    JOIN PROCESE p ON pu.IdProces = p.IdProces
    WHERE pu.IdUtilizator = p_user_id
      AND p.NumeProces = p_nume_proces
      AND pu.Status = 'ACTIV'
      AND (pu.DataExpirare IS NULL OR pu.DataExpirare > SYSTIMESTAMP);
    
    IF v_count > 0 THEN
        RETURN 1;
    END IF;
    
    -- Verificare bazată pe rol
    SELECT r.NumeRol INTO v_rol
    FROM UTILIZATORI u
    JOIN ROLURI r ON u.IdRol = r.IdRol
    WHERE u.IdUtilizator = p_user_id;
    
    -- Reguli bazate pe rol
    IF v_rol = 'ADMIN' THEN
        RETURN 1; -- Admin are acces la tot
    ELSIF v_rol = 'BROKER' AND p_nume_proces IN ('VIEW_ALL_APPLICATIONS', 'PROCESS_APPLICATION') THEN
        RETURN 1;
    ELSIF v_rol = 'CLIENT' AND p_nume_proces IN ('VIEW_OWN_APPLICATIONS', 'CREATE_APPLICATION', 'UPDATE_OWN_APPLICATION', 'DELETE_OWN_APPLICATION') THEN
        RETURN 1;
    END IF;
    
    RETURN 0;
END;
/

-- Funcție pentru verificare acces la entitate
CREATE OR REPLACE FUNCTION fn_utilizator_poate_entitate (
    p_user_id IN NUMBER,
    p_nume_entitate IN VARCHAR2,
    p_tip_acces IN VARCHAR2
) RETURN NUMBER
IS
    v_count NUMBER;
    v_rol VARCHAR2(50);
BEGIN
    -- Verificare directă în matricea entitate-utilizator
    SELECT COUNT(*) INTO v_count
    FROM ENTITATE_UTILIZATOR
    WHERE IdUtilizator = p_user_id
      AND NumeEntitate = p_nume_entitate
      AND (TipAcces = p_tip_acces OR TipAcces = 'ALL')
      AND Status = 'ACTIV';
    
    IF v_count > 0 THEN
        RETURN 1;
    END IF;
    
    -- Verificare prin procese
    SELECT COUNT(*) INTO v_count
    FROM PROCES_UTILIZATOR pu
    JOIN PROCESE p ON pu.IdProces = p.IdProces
    JOIN ENTITATE_PROCES ep ON p.IdProces = ep.IdProces
    WHERE pu.IdUtilizator = p_user_id
      AND ep.NumeEntitate = p_nume_entitate
      AND ep.Permisiune = 'ALLOW'
      AND pu.Status = 'ACTIV';
    
    IF v_count > 0 THEN
        RETURN 1;
    END IF;
    
    -- Verificare bazată pe rol
    SELECT r.NumeRol INTO v_rol
    FROM UTILIZATORI u
    JOIN ROLURI r ON u.IdRol = r.IdRol
    WHERE u.IdUtilizator = p_user_id;
    
    IF v_rol = 'ADMIN' THEN
        RETURN 1;
    END IF;
    
    RETURN 0;
END;
/

-- =====================================================
-- 5. Proceduri pentru gestionare utilizatori
-- =====================================================

-- Procedură pentru asignare proces utilizator
CREATE OR REPLACE PROCEDURE sp_asignare_proces_utilizator (
    p_user_id IN NUMBER,
    p_nume_proces IN VARCHAR2,
    p_data_expirare IN TIMESTAMP DEFAULT NULL
)
IS
    v_proces_id NUMBER;
BEGIN
    -- Obținere ID proces
    SELECT IdProces INTO v_proces_id
    FROM PROCESE
    WHERE NumeProces = p_nume_proces;
    
    -- Inserare sau actualizare
    MERGE INTO PROCES_UTILIZATOR pu
    USING (SELECT v_proces_id AS IdProces, p_user_id AS IdUtilizator FROM DUAL) src
    ON (pu.IdProces = src.IdProces AND pu.IdUtilizator = src.IdUtilizator)
    WHEN MATCHED THEN
        UPDATE SET 
            Status = 'ACTIV',
            DataExpirare = p_data_expirare,
            DataAsignare = SYSTIMESTAMP
    WHEN NOT MATCHED THEN
        INSERT (IdProces, IdUtilizator, Status, DataExpirare)
        VALUES (src.IdProces, src.IdUtilizator, 'ACTIV', p_data_expirare);
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Proces ' || p_nume_proces || ' asignat utilizatorului ' || p_user_id);
END;
/

-- Procedură pentru revocare proces utilizator
CREATE OR REPLACE PROCEDURE sp_revocare_proces_utilizator (
    p_user_id IN NUMBER,
    p_nume_proces IN VARCHAR2
)
IS
BEGIN
    UPDATE PROCES_UTILIZATOR pu
    SET Status = 'INACTIV'
    WHERE IdUtilizator = p_user_id
      AND IdProces = (SELECT IdProces FROM PROCESE WHERE NumeProces = p_nume_proces);
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Proces ' || p_nume_proces || ' revocat pentru utilizatorul ' || p_user_id);
END;
/

-- Procedură pentru inițializare procese bazate pe rol
CREATE OR REPLACE PROCEDURE sp_initializare_procese_rol (
    p_user_id IN NUMBER
)
IS
    v_rol VARCHAR2(50);
BEGIN
    -- Obținere rol utilizator
    SELECT r.NumeRol INTO v_rol
    FROM UTILIZATORI u
    JOIN ROLURI r ON u.IdRol = r.IdRol
    WHERE u.IdUtilizator = p_user_id;
    
    -- Asignare procese bazate pe rol
    IF v_rol = 'CLIENT' THEN
        sp_asignare_proces_utilizator(p_user_id, 'VIEW_OWN_APPLICATIONS', NULL);
        sp_asignare_proces_utilizator(p_user_id, 'CREATE_APPLICATION', NULL);
        sp_asignare_proces_utilizator(p_user_id, 'UPDATE_OWN_APPLICATION', NULL);
        sp_asignare_proces_utilizator(p_user_id, 'DELETE_OWN_APPLICATION', NULL);
    ELSIF v_rol = 'BROKER' THEN
        sp_asignare_proces_utilizator(p_user_id, 'VIEW_ALL_APPLICATIONS', NULL);
        sp_asignare_proces_utilizator(p_user_id, 'PROCESS_APPLICATION', NULL);
        sp_asignare_proces_utilizator(p_user_id, 'VIEW_REPORTS', NULL);
    ELSIF v_rol = 'ADMIN' THEN
        sp_asignare_proces_utilizator(p_user_id, 'VIEW_USERS', NULL);
        sp_asignare_proces_utilizator(p_user_id, 'MANAGE_USERS', NULL);
        sp_asignare_proces_utilizator(p_user_id, 'VIEW_ALL_APPLICATIONS', NULL);
        sp_asignare_proces_utilizator(p_user_id, 'EXECUTE_ADMIN_PROC', NULL);
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('Procese inițializate pentru utilizatorul ' || p_user_id || ' cu rolul ' || v_rol);
END;
/

-- =====================================================
-- 6. View-uri pentru raportare
-- =====================================================

-- View pentru procese utilizator
CREATE OR REPLACE VIEW vw_procese_utilizator AS
SELECT 
    u.IdUtilizator,
    u.Username,
    u.Email,
    r.NumeRol,
    p.NumeProces,
    p.TipProces,
    pu.Status,
    pu.DataAsignare,
    pu.DataExpirare
FROM UTILIZATORI u
JOIN ROLURI r ON u.IdRol = r.IdRol
LEFT JOIN PROCES_UTILIZATOR pu ON u.IdUtilizator = pu.IdUtilizator
LEFT JOIN PROCESE p ON pu.IdProces = p.IdProces
WHERE u.IsDeleted = 0
ORDER BY u.IdUtilizator, p.NumeProces;

-- =====================================================
-- 7. Inițializare procese pentru utilizatori existenți
-- =====================================================

-- Procedură pentru inițializare în masă
CREATE OR REPLACE PROCEDURE sp_initializare_procese_masa
IS
    v_count NUMBER := 0;
BEGIN
    FOR rec IN (SELECT IdUtilizator FROM UTILIZATORI WHERE IsDeleted = 0) LOOP
        BEGIN
            sp_initializare_procese_rol(rec.IdUtilizator);
            v_count := v_count + 1;
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Eroare la utilizatorul ' || rec.IdUtilizator || ': ' || SQLERRM);
        END;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Procese inițializate pentru ' || v_count || ' utilizatori');
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Gestiunea utilizatorilor configurată!');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Componente create:');
    DBMS_OUTPUT.PUT_LINE('  - Matrice proces-utilizator');
    DBMS_OUTPUT.PUT_LINE('  - Matrice entitate-proces');
    DBMS_OUTPUT.PUT_LINE('  - Matrice entitate-utilizator');
    DBMS_OUTPUT.PUT_LINE('  - Funcții de verificare acces');
    DBMS_OUTPUT.PUT_LINE('  - Proceduri de gestionare');
    DBMS_OUTPUT.PUT_LINE('========================================');
END;
/

