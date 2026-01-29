SET SERVEROUTPUT ON;
DECLARE
v_count_utilizatori NUMBER;
v_count_aplicatii NUMBER;
v_count_banci NUMBER;
v_count_app_banks NUMBER;
v_id_utilizator NUMBER;
BEGIN
SELECT COUNT(*) INTO v_count_utilizatori FROM UTILIZATORI;
SELECT COUNT(*) INTO v_count_aplicatii FROM APLICATII;
SELECT COUNT(*) INTO v_count_banci FROM BANCI;
SELECT COUNT(*) INTO v_count_app_banks FROM APPLICATION_BANKS;
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('VERIFICARE DATE EXISTENTE');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('Utilizatori: ' || v_count_utilizatori);
DBMS_OUTPUT.PUT_LINE('Aplicații: ' || v_count_aplicatii);
DBMS_OUTPUT.PUT_LINE('Bănci: ' || v_count_banci);
DBMS_OUTPUT.PUT_LINE('Asocieri aplicație-bancă: ' || v_count_app_banks);
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
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('✓ Utilizator cu aplicații găsit: ID = ' || v_id_utilizator);
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('Testează procedura cu:');
DBMS_OUTPUT.PUT_LINE('  PKG_MONEYSHOP.SP_PROCESARE_COLECTII(' || v_id_utilizator || ', v_rezultat);');
EXCEPTION
WHEN NO_DATA_FOUND THEN
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('⚠ NU EXISTĂ UTILIZATORI CU APLICAȚII!');
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('Soluție: Rulează scriptul de populare date:');
DBMS_OUTPUT.PUT_LINE('  17_POPULARE_DATE_TEST.sql');
END;
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('Utilizatori cu aplicații:');
FOR rec IN (
SELECT u.IdUtilizator, u.Nume || ' ' || u.Prenume AS NumeComplet, COUNT(a.Id) AS NumarAplicatii
FROM UTILIZATORI u
INNER JOIN APLICATII a ON u.IdUtilizator = a.UserId
WHERE u.IsDeleted = 0
GROUP BY u.IdUtilizator, u.Nume, u.Prenume
ORDER BY NumarAplicatii DESC
FETCH FIRST 10 ROWS ONLY
) LOOP
DBMS_OUTPUT.PUT_LINE('  ID: ' || rec.IdUtilizator || ' - ' || rec.NumeComplet ||
' (' || rec.NumarAplicatii || ' aplicații)');
END LOOP;
END;
/