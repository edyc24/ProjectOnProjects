SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE SP_PROCESARE_CURSOARE (
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
v_aplicatii_aprobate NUMBER := 0;
BEGIN
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('Procesare cursoare pentru rol: ' || p_id_rol);
DBMS_OUTPUT.PUT_LINE('========================================');
OPEN c_utilizatori_rol(p_id_rol);
LOOP
FETCH c_utilizatori_rol INTO v_id_utilizator, v_nume, v_prenume, v_email;
EXIT WHEN c_utilizatori_rol%NOTFOUND;
v_total_utilizatori := v_total_utilizatori + 1;
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('Utilizator ' || v_total_utilizatori || ': ' ||
v_nume || ' ' || v_prenume || ' (' || v_email || ')');
FOR rec_aplicatie IN (
SELECT
a.Id,
a.Status,
a.TypeCredit,
a.SumaAprobata,
a.Scoring,
a.CreatedAt
FROM APLICATII a
WHERE a.UserId = v_id_utilizator
ORDER BY a.CreatedAt DESC
) LOOP
v_total_aplicatii := v_total_aplicatii + 1;
IF rec_aplicatie.Status = 'APROBAT' THEN
v_aplicatii_aprobate := v_aplicatii_aprobate + 1;
END IF;
DBMS_OUTPUT.PUT_LINE('  → Aplicație ID: ' || rec_aplicatie.Id ||
', Status: ' || rec_aplicatie.Status ||
', Tip: ' || NVL(rec_aplicatie.TypeCredit, 'N/A') ||
', Suma: ' || NVL(TO_CHAR(rec_aplicatie.SumaAprobata), 'N/A') ||
', Scoring: ' || NVL(TO_CHAR(rec_aplicatie.Scoring), 'N/A'));
END LOOP;
IF v_total_aplicatii = 0 THEN
DBMS_OUTPUT.PUT_LINE('  → Nu are aplicații');
END IF;
END LOOP;
CLOSE c_utilizatori_rol;
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('REZUMAT:');
DBMS_OUTPUT.PUT_LINE('  Total utilizatori procesați: ' || v_total_utilizatori);
DBMS_OUTPUT.PUT_LINE('  Total aplicații găsite: ' || v_total_aplicatii);
DBMS_OUTPUT.PUT_LINE('  Aplicații aprobate: ' || v_aplicatii_aprobate);
DBMS_OUTPUT.PUT_LINE('========================================');
p_rezultat := 'Procesați ' || v_total_utilizatori || ' utilizatori, ' ||
v_total_aplicatii || ' aplicații (' || v_aplicatii_aprobate || ' aprobate)';
EXCEPTION
WHEN OTHERS THEN
IF c_utilizatori_rol%ISOPEN THEN
CLOSE c_utilizatori_rol;
END IF;
p_rezultat := 'EROARE: ' || SQLERRM;
DBMS_OUTPUT.PUT_LINE('EROARE: ' || p_rezultat);
RAISE;
END;
/
DECLARE
v_rezultat VARCHAR2(500);
v_id_rol_client NUMBER;
BEGIN
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('TESTARE PROCEDURĂ SP_PROCESARE_CURSOARE');
DBMS_OUTPUT.PUT_LINE('');
SELECT IdRol INTO v_id_rol_client
FROM ROLURI
WHERE NumeRol = 'CLIENT';
SP_PROCESARE_CURSOARE(v_id_rol_client, v_rezultat);
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('Rezultat final: ' || v_rezultat);
EXCEPTION
WHEN NO_DATA_FOUND THEN
DBMS_OUTPUT.PUT_LINE('EROARE: Rolul CLIENT nu a fost găsit!');
WHEN OTHERS THEN
DBMS_OUTPUT.PUT_LINE('EROARE: ' || SQLERRM);
END;
/