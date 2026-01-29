SET SERVEROUTPUT ON;
CREATE OR REPLACE TYPE t_varray_nume AS VARRAY(100) OF VARCHAR2(100);
/
CREATE OR REPLACE TYPE t_nested_table_id AS TABLE OF NUMBER;
/
CREATE OR REPLACE PROCEDURE SP_PROCESARE_COLECTII (
p_id_utilizator IN NUMBER,
p_rezultat OUT VARCHAR2
)
IS
v_nume_banci t_varray_nume := t_varray_nume();
v_id_aplicatii t_nested_table_id := t_nested_table_id();
TYPE t_assoc_array IS TABLE OF NUMBER INDEX BY VARCHAR2(50);
v_sume_pe_status t_assoc_array;
v_contor NUMBER := 0;
v_nume_banca VARCHAR2(200);
v_id_aplicatie NUMBER;
v_status VARCHAR2(50);
v_suma NUMBER;
BEGIN
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('Procesare colecții pentru utilizator: ' || p_id_utilizator);
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('1. Populare VARRAY cu nume bănci...');
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
DBMS_OUTPUT.PUT_LINE('   Adăugat în VARRAY: ' || rec.Name);
END LOOP;
DBMS_OUTPUT.PUT_LINE('   Total bănci în VARRAY: ' || v_nume_banci.COUNT);
DBMS_OUTPUT.PUT_LINE('2. Populare NESTED TABLE cu ID-uri aplicații...');
FOR rec IN (
SELECT Id
FROM APLICATII
WHERE UserId = p_id_utilizator
) LOOP
v_id_aplicatii.EXTEND;
v_id_aplicatii(v_id_aplicatii.COUNT) := rec.Id;
DBMS_OUTPUT.PUT_LINE('   Adăugat în NESTED TABLE: ' || rec.Id);
END LOOP;
DBMS_OUTPUT.PUT_LINE('   Total aplicații în NESTED TABLE: ' || v_id_aplicatii.COUNT);
DBMS_OUTPUT.PUT_LINE('3. Populare ASSOCIATIVE ARRAY cu sume pe status...');
FOR rec IN (
SELECT Status, SUM(NVL(SumaAprobata, 0)) AS SumaTotala
FROM APLICATII
WHERE UserId = p_id_utilizator
GROUP BY Status
) LOOP
v_sume_pe_status(rec.Status) := rec.SumaTotala;
DBMS_OUTPUT.PUT_LINE('   Adăugat în ASSOCIATIVE ARRAY: ' || rec.Status || ' = ' || rec.SumaTotala);
END LOOP;
DBMS_OUTPUT.PUT_LINE('   Total statusuri în ASSOCIATIVE ARRAY: ' || v_sume_pe_status.COUNT);
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('Procesare VARRAY:');
IF v_nume_banci.COUNT > 0 THEN
FOR i IN 1..v_nume_banci.COUNT LOOP
DBMS_OUTPUT.PUT_LINE('   Banca ' || i || ': ' || v_nume_banci(i));
END LOOP;
ELSE
DBMS_OUTPUT.PUT_LINE('   VARRAY este gol');
END IF;
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('Procesare NESTED TABLE:');
IF v_id_aplicatii.COUNT > 0 THEN
FOR i IN 1..v_id_aplicatii.COUNT LOOP
DBMS_OUTPUT.PUT_LINE('   Aplicație ' || i || ': ID = ' || v_id_aplicatii(i));
END LOOP;
ELSE
DBMS_OUTPUT.PUT_LINE('   NESTED TABLE este gol');
END IF;
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('Procesare ASSOCIATIVE ARRAY:');
IF v_sume_pe_status.COUNT > 0 THEN
v_status := v_sume_pe_status.FIRST;
WHILE v_status IS NOT NULL LOOP
DBMS_OUTPUT.PUT_LINE('   Status: ' || v_status || ' = ' || v_sume_pe_status(v_status));
v_status := v_sume_pe_status.NEXT(v_status);
END LOOP;
ELSE
DBMS_OUTPUT.PUT_LINE('   ASSOCIATIVE ARRAY este gol');
END IF;
p_rezultat := 'VARRAY: ' || v_nume_banci.COUNT || ' bănci, ' ||
'NESTED TABLE: ' || v_id_aplicatii.COUNT || ' aplicații, ' ||
'ASSOCIATIVE ARRAY: ' || v_sume_pe_status.COUNT || ' statusuri';
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('Rezultat: ' || p_rezultat);
DBMS_OUTPUT.PUT_LINE('========================================');
EXCEPTION
WHEN NO_DATA_FOUND THEN
p_rezultat := 'Nu s-au găsit date pentru utilizatorul ' || p_id_utilizator;
DBMS_OUTPUT.PUT_LINE('EROARE: ' || p_rezultat);
WHEN OTHERS THEN
p_rezultat := 'EROARE: ' || SQLERRM;
DBMS_OUTPUT.PUT_LINE('EROARE: ' || p_rezultat);
RAISE;
END;
/
DECLARE
v_rezultat VARCHAR2(500);
BEGIN
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('TESTARE PROCEDURĂ SP_PROCESARE_COLECTII');
DBMS_OUTPUT.PUT_LINE('');
SP_PROCESARE_COLECTII(1, v_rezultat);
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('Rezultat final: ' || v_rezultat);
END;
/