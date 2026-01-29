SET SERVEROUTPUT ON;
CREATE OR REPLACE PACKAGE PKG_MONEYSHOP AS
PROCEDURE SP_PROCESARE_COLECTII (
p_id_utilizator IN NUMBER,
p_rezultat OUT VARCHAR2
);
PROCEDURE SP_PROCESARE_CURSOARE (
p_id_rol IN NUMBER,
p_rezultat OUT VARCHAR2
);
FUNCTION FN_CALCUL_STATISTICI_UTILIZATOR (
p_id_utilizator IN NUMBER
) RETURN VARCHAR2;
PROCEDURE SP_ACTUALIZARE_APLICATIE (
p_id_aplicatie IN NUMBER,
p_nou_status IN VARCHAR2,
p_suma_aprobata IN NUMBER DEFAULT NULL
);
PROCEDURE SP_CREARE_APLICATIE (
p_id_utilizator IN NUMBER,
p_type_credit IN VARCHAR2,
p_tip_operatiune IN VARCHAR2,
p_salariu_net IN NUMBER,
p_id_aplicatie OUT NUMBER
);
FUNCTION FN_INSERARE_MESAJ (
p_mesaj IN VARCHAR2,
p_tip_mesaj IN VARCHAR2 DEFAULT 'I',
p_creat_de IN VARCHAR2 DEFAULT USER
) RETURN NUMBER;
END PKG_MONEYSHOP;
/
CREATE OR REPLACE PACKAGE BODY PKG_MONEYSHOP AS
TYPE t_varray_nume IS VARRAY(100) OF VARCHAR2(100);
TYPE t_nested_table_id IS TABLE OF NUMBER;
TYPE t_assoc_array IS TABLE OF NUMBER INDEX BY VARCHAR2(50);
PROCEDURE SP_PROCESARE_COLECTII (
p_id_utilizator IN NUMBER,
p_rezultat OUT VARCHAR2
)
IS
v_nume_banci t_varray_nume := t_varray_nume();
v_id_aplicatii t_nested_table_id := t_nested_table_id();
v_sume_pe_status t_assoc_array;
v_contor NUMBER := 0;
BEGIN
DBMS_OUTPUT.PUT_LINE('PKG_MONEYSHOP.SP_PROCESARE_COLECTII - Utilizator: ' || p_id_utilizator);
FOR rec IN (
SELECT DISTINCT b.Name
FROM BANCI b
INNER JOIN APPLICATION_BANKS ab ON b.Id = ab.BankId
INNER JOIN APLICATII a ON ab.ApplicationId = a.Id
WHERE a.UserId = p_id_utilizator
AND ROWNUM <= 100
) LOOP
v_nume_banci.EXTEND;
v_nume_banci(v_nume_banci.COUNT) := rec.Name;
END LOOP;
FOR rec IN (
SELECT Id
FROM APLICATII
WHERE UserId = p_id_utilizator
) LOOP
v_id_aplicatii.EXTEND;
v_id_aplicatii(v_id_aplicatii.COUNT) := rec.Id;
END LOOP;
FOR rec IN (
SELECT Status, SUM(NVL(SumaAprobata, 0)) AS SumaTotala
FROM APLICATII
WHERE UserId = p_id_utilizator
GROUP BY Status
) LOOP
v_sume_pe_status(rec.Status) := rec.SumaTotala;
END LOOP;
p_rezultat := 'VARRAY: ' || v_nume_banci.COUNT || ' bănci, ' ||
'NESTED TABLE: ' || v_id_aplicatii.COUNT || ' aplicații, ' ||
'ASSOCIATIVE ARRAY: ' || v_sume_pe_status.COUNT || ' statusuri';
EXCEPTION
WHEN OTHERS THEN
p_rezultat := 'EROARE: ' || SQLERRM;
DECLARE
v_cod_mesaj NUMBER;
BEGIN
v_cod_mesaj := FN_INSERARE_MESAJ('EROARE SP_PROCESARE_COLECTII: ' || SQLERRM, 'E');
END;
RAISE;
END SP_PROCESARE_COLECTII;
PROCEDURE SP_PROCESARE_CURSOARE (
p_id_rol IN NUMBER,
p_rezultat OUT VARCHAR2
)
IS
CURSOR c_utilizatori_rol (p_rol_id NUMBER) IS
SELECT IdUtilizator, Nume, Prenume, Email
FROM UTILIZATORI
WHERE IdRol = p_rol_id
AND IsDeleted = 0
ORDER BY Nume, Prenume;
v_id_utilizator NUMBER;
v_nume VARCHAR2(100);
v_prenume VARCHAR2(100);
v_email VARCHAR2(255);
v_total_utilizatori NUMBER := 0;
v_total_aplicatii NUMBER := 0;
BEGIN
DBMS_OUTPUT.PUT_LINE('PKG_MONEYSHOP.SP_PROCESARE_CURSOARE - Rol: ' || p_id_rol);
OPEN c_utilizatori_rol(p_id_rol);
LOOP
FETCH c_utilizatori_rol INTO v_id_utilizator, v_nume, v_prenume, v_email;
EXIT WHEN c_utilizatori_rol%NOTFOUND;
v_total_utilizatori := v_total_utilizatori + 1;
FOR rec_aplicatie IN (
SELECT Id, Status, SumaAprobata
FROM APLICATII
WHERE UserId = v_id_utilizator
) LOOP
v_total_aplicatii := v_total_aplicatii + 1;
END LOOP;
END LOOP;
CLOSE c_utilizatori_rol;
p_rezultat := 'Procesați ' || v_total_utilizatori || ' utilizatori, ' ||
v_total_aplicatii || ' aplicații';
EXCEPTION
WHEN OTHERS THEN
IF c_utilizatori_rol%ISOPEN THEN
CLOSE c_utilizatori_rol;
END IF;
p_rezultat := 'EROARE: ' || SQLERRM;
DECLARE
v_cod_mesaj NUMBER;
BEGIN
v_cod_mesaj := FN_INSERARE_MESAJ('EROARE SP_PROCESARE_CURSOARE: ' || SQLERRM, 'E');
END;
RAISE;
END SP_PROCESARE_CURSOARE;
FUNCTION FN_CALCUL_STATISTICI_UTILIZATOR (
p_id_utilizator IN NUMBER
) RETURN VARCHAR2
IS
ex_utilizator_inexistent EXCEPTION;
ex_date_insuficiente EXCEPTION;
PRAGMA EXCEPTION_INIT(ex_utilizator_inexistent, -20001);
PRAGMA EXCEPTION_INIT(ex_date_insuficiente, -20002);
v_nume_complet VARCHAR2(200);
v_numar_aplicatii NUMBER := 0;
v_suma_totala NUMBER := 0;
v_scoring_mediu NUMBER := 0;
v_numar_banci NUMBER := 0;
v_rezultat VARCHAR2(1000);
v_utilizator_exista NUMBER := 0;
BEGIN
SELECT COUNT(*) INTO v_utilizator_exista
FROM UTILIZATORI
WHERE IdUtilizator = p_id_utilizator
AND IsDeleted = 0;
IF v_utilizator_exista = 0 THEN
RAISE ex_utilizator_inexistent;
END IF;
SELECT
u.Nume || ' ' || u.Prenume,
COUNT(DISTINCT a.Id),
SUM(NVL(a.SumaAprobata, 0)),
AVG(a.Scoring),
COUNT(DISTINCT ab.BankId)
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
IF v_numar_aplicatii = 0 THEN
RAISE ex_date_insuficiente;
END IF;
v_rezultat := 'Utilizator: ' || v_nume_complet || ' | ' ||
'Aplicații: ' || v_numar_aplicatii || ' | ' ||
'Suma totală: ' || TO_CHAR(v_suma_totala, '999,999,999.00') || ' | ' ||
'Scoring mediu: ' || NVL(TO_CHAR(ROUND(v_scoring_mediu, 2)), 'N/A') || ' | ' ||
'Bănci: ' || v_numar_banci;
RETURN v_rezultat;
EXCEPTION
WHEN ex_utilizator_inexistent THEN
DECLARE
v_cod_mesaj NUMBER;
BEGIN
v_cod_mesaj := FN_INSERARE_MESAJ('Utilizator inexistent: ' || p_id_utilizator, 'E');
END;
RETURN 'EROARE: Utilizator inexistent (ID: ' || p_id_utilizator || ')';
WHEN ex_date_insuficiente THEN
DECLARE
v_cod_mesaj NUMBER;
BEGIN
v_cod_mesaj := FN_INSERARE_MESAJ('Date insuficiente pentru utilizator: ' || p_id_utilizator, 'W');
END;
RETURN 'EROARE: Date insuficiente - utilizatorul nu are aplicații';
WHEN OTHERS THEN
DECLARE
v_cod_mesaj NUMBER;
BEGIN
v_cod_mesaj := FN_INSERARE_MESAJ('EROARE FN_CALCUL_STATISTICI: ' || SQLERRM, 'E');
END;
RETURN 'EROARE: ' || SQLCODE || ' - ' || SUBSTR(SQLERRM, 1, 200);
END FN_CALCUL_STATISTICI_UTILIZATOR;
PROCEDURE SP_ACTUALIZARE_APLICATIE (
p_id_aplicatie IN NUMBER,
p_nou_status IN VARCHAR2,
p_suma_aprobata IN NUMBER DEFAULT NULL
)
IS
BEGIN
DBMS_OUTPUT.PUT_LINE('PKG_MONEYSHOP.SP_ACTUALIZARE_APLICATIE - Aplicație: ' || p_id_aplicatie);
UPDATE APLICATII
SET Status = p_nou_status,
SumaAprobata = NVL(p_suma_aprobata, SumaAprobata),
UpdatedAt = SYSTIMESTAMP
WHERE Id = p_id_aplicatie;
IF SQL%ROWCOUNT = 0 THEN
RAISE_APPLICATION_ERROR(-20010, 'Aplicația cu ID ' || p_id_aplicatie || ' nu există!');
END IF;
COMMIT;
DECLARE
v_cod_mesaj NUMBER;
BEGIN
v_cod_mesaj := FN_INSERARE_MESAJ('Aplicație actualizată: ' || p_id_aplicatie || ' -> Status: ' || p_nou_status, 'I');
END;
EXCEPTION
WHEN OTHERS THEN
ROLLBACK;
DECLARE
v_cod_mesaj NUMBER;
BEGIN
v_cod_mesaj := FN_INSERARE_MESAJ('EROARE SP_ACTUALIZARE_APLICATIE: ' || SQLERRM, 'E');
END;
RAISE;
END SP_ACTUALIZARE_APLICATIE;
PROCEDURE SP_CREARE_APLICATIE (
p_id_utilizator IN NUMBER,
p_type_credit IN VARCHAR2,
p_tip_operatiune IN VARCHAR2,
p_salariu_net IN NUMBER,
p_id_aplicatie OUT NUMBER
)
IS
BEGIN
DBMS_OUTPUT.PUT_LINE('PKG_MONEYSHOP.SP_CREARE_APLICATIE - Utilizator: ' || p_id_utilizator);
INSERT INTO APLICATII (
UserId,
Status,
TypeCredit,
TipOperatiune,
SalariuNet,
CreatedAt,
UpdatedAt
) VALUES (
p_id_utilizator,
'INREGISTRAT',
p_type_credit,
p_tip_operatiune,
p_salariu_net,
SYSTIMESTAMP,
SYSTIMESTAMP
)
RETURNING Id INTO p_id_aplicatie;
COMMIT;
DECLARE
v_cod_mesaj NUMBER;
BEGIN
v_cod_mesaj := FN_INSERARE_MESAJ('Aplicație creată: ' || p_id_aplicatie || ' pentru utilizator: ' || p_id_utilizator, 'I');
END;
EXCEPTION
WHEN OTHERS THEN
ROLLBACK;
DECLARE
v_cod_mesaj NUMBER;
BEGIN
v_cod_mesaj := FN_INSERARE_MESAJ('EROARE SP_CREARE_APLICATIE: ' || SQLERRM, 'E');
END;
RAISE;
END SP_CREARE_APLICATIE;
FUNCTION FN_INSERARE_MESAJ (
p_mesaj IN VARCHAR2,
p_tip_mesaj IN VARCHAR2 DEFAULT 'I',
p_creat_de IN VARCHAR2 DEFAULT USER
) RETURN NUMBER
IS
v_cod_mesaj NUMBER;
BEGIN
v_cod_mesaj := seq_mesaje.NEXTVAL;
INSERT INTO MESAJE (
cod_mesaj,
mesaj,
tip_mesaj,
creat_de,
creat_la
) VALUES (
v_cod_mesaj,
SUBSTR(p_mesaj, 1, 255),
p_tip_mesaj,
p_creat_de,
SYSDATE
);
COMMIT;
RETURN v_cod_mesaj;
EXCEPTION
WHEN OTHERS THEN
RETURN 0;
END FN_INSERARE_MESAJ;
END PKG_MONEYSHOP;
/
BEGIN
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('TESTARE PACHET PKG_MONEYSHOP');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('Pachetul a fost creat cu succes!');
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('Proceduri disponibile:');
DBMS_OUTPUT.PUT_LINE('  - PKG_MONEYSHOP.SP_PROCESARE_COLECTII');
DBMS_OUTPUT.PUT_LINE('  - PKG_MONEYSHOP.SP_PROCESARE_CURSOARE');
DBMS_OUTPUT.PUT_LINE('  - PKG_MONEYSHOP.SP_ACTUALIZARE_APLICATIE');
DBMS_OUTPUT.PUT_LINE('  - PKG_MONEYSHOP.SP_CREARE_APLICATIE');
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('Funcții disponibile:');
DBMS_OUTPUT.PUT_LINE('  - PKG_MONEYSHOP.FN_CALCUL_STATISTICI_UTILIZATOR');
DBMS_OUTPUT.PUT_LINE('  - PKG_MONEYSHOP.FN_INSERARE_MESAJ');
DBMS_OUTPUT.PUT_LINE('========================================');
END;
/