SET SERVEROUTPUT ON;
DECLARE
v_id_utilizator NUMBER;
v_rezultat VARCHAR2(500);
BEGIN
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('TEST 1: SP_PROCESARE_COLECTII');
DBMS_OUTPUT.PUT_LINE('========================================');
BEGIN
SELECT u.IdUtilizator INTO v_id_utilizator
FROM (
SELECT u.IdUtilizator, COUNT(a.Id) AS num_aplicatii
FROM UTILIZATORI u
INNER JOIN APLICATII a ON u.IdUtilizator = a.UserId
WHERE u.IsDeleted = 0
GROUP BY u.IdUtilizator
ORDER BY num_aplicatii DESC
)
WHERE ROWNUM = 1;
DBMS_OUTPUT.PUT_LINE('Utilizator găsit: ID = ' || v_id_utilizator);
DBMS_OUTPUT.PUT_LINE('');
PKG_MONEYSHOP.SP_PROCESARE_COLECTII(v_id_utilizator, v_rezultat);
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('✓ TEST REUȘIT!');
EXCEPTION
WHEN NO_DATA_FOUND THEN
DBMS_OUTPUT.PUT_LINE('⚠ NU EXISTĂ UTILIZATORI CU APLICAȚII!');
DBMS_OUTPUT.PUT_LINE('Rulează: 17_POPULARE_DATE_TEST.sql');
END;
END;
/
DECLARE
v_id_rol NUMBER;
v_rezultat VARCHAR2(500);
BEGIN
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('TEST 2: SP_PROCESARE_CURSOARE');
DBMS_OUTPUT.PUT_LINE('========================================');
BEGIN
SELECT IdRol INTO v_id_rol FROM ROLURI WHERE NumeRol = 'CLIENT';
DBMS_OUTPUT.PUT_LINE('Rol găsit: CLIENT (ID = ' || v_id_rol || ')');
DBMS_OUTPUT.PUT_LINE('');
PKG_MONEYSHOP.SP_PROCESARE_CURSOARE(v_id_rol, v_rezultat);
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('✓ TEST REUȘIT!');
EXCEPTION
WHEN NO_DATA_FOUND THEN
DBMS_OUTPUT.PUT_LINE('⚠ Rolul CLIENT nu există!');
END;
END;
/
DECLARE
v_id_utilizator NUMBER;
v_rezultat VARCHAR2(1000);
BEGIN
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('TEST 3: FN_CALCUL_STATISTICI_UTILIZATOR');
DBMS_OUTPUT.PUT_LINE('========================================');
BEGIN
SELECT u.IdUtilizator INTO v_id_utilizator
FROM (
SELECT u.IdUtilizator, COUNT(a.Id) AS num_aplicatii
FROM UTILIZATORI u
INNER JOIN APLICATII a ON u.IdUtilizator = a.UserId
WHERE u.IsDeleted = 0
GROUP BY u.IdUtilizator
ORDER BY num_aplicatii DESC
)
WHERE ROWNUM = 1;
DBMS_OUTPUT.PUT_LINE('Test cu utilizator valid: ID = ' || v_id_utilizator);
v_rezultat := PKG_MONEYSHOP.FN_CALCUL_STATISTICI_UTILIZATOR(v_id_utilizator);
DBMS_OUTPUT.PUT_LINE('Rezultat: ' || v_rezultat);
DBMS_OUTPUT.PUT_LINE('✓ TEST REUȘIT!');
EXCEPTION
WHEN NO_DATA_FOUND THEN
DBMS_OUTPUT.PUT_LINE('⚠ NU EXISTĂ UTILIZATORI CU APLICAȚII!');
END;
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('Test cu utilizator inexistent: ID = 99999');
v_rezultat := PKG_MONEYSHOP.FN_CALCUL_STATISTICI_UTILIZATOR(99999);
DBMS_OUTPUT.PUT_LINE('Rezultat: ' || v_rezultat);
DBMS_OUTPUT.PUT_LINE('✓ TEST EXCEPȚIE REUȘIT!');
END;
/
BEGIN
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('TEST 4: Verificare mesaje în MESAJE');
DBMS_OUTPUT.PUT_LINE('========================================');
DECLARE
v_count NUMBER;
BEGIN
SELECT COUNT(*) INTO v_count FROM MESAJE;
DBMS_OUTPUT.PUT_LINE('Număr mesaje în MESAJE: ' || v_count);
IF v_count > 0 THEN
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('Ultimele 5 mesaje:');
FOR rec IN (
SELECT cod_mesaj, mesaj, tip_mesaj, creat_la
FROM MESAJE
ORDER BY creat_la DESC
FETCH FIRST 5 ROWS ONLY
) LOOP
DBMS_OUTPUT.PUT_LINE('  [' || rec.tip_mesaj || '] ' ||
TO_CHAR(rec.creat_la, 'DD-MM-YYYY HH24:MI:SS') ||
' - ' || SUBSTR(rec.mesaj, 1, 60));
END LOOP;
ELSE
DBMS_OUTPUT.PUT_LINE('⚠ Nu există mesaje încă');
END IF;
END;
END;
/
BEGIN
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('TOATE TESTELE COMPLETATE!');
DBMS_OUTPUT.PUT_LINE('========================================');
END;
/