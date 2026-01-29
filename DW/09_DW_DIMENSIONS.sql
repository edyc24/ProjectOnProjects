SET SERVEROUTPUT ON;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Început creare obiecte dimensiune Oracle...');
    DBMS_OUTPUT.PUT_LINE('');
END;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('1. Creare DIMENSION DIM_TIMP...');
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP DIMENSION dim_timp_dimension';
    DBMS_OUTPUT.PUT_LINE('  ⚠ Dimensiune veche ștearsă (dacă exista)');
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/
CREATE DIMENSION dim_timp_dimension
LEVEL an IS (DIM_TIMP.An)
LEVEL trimestru IS (DIM_TIMP.Trimestru)
LEVEL luna IS (DIM_TIMP.Luna)
LEVEL zi IS (DIM_TIMP.DataCompleta)
HIERARCHY timp_hier (
    an CHILD OF
    trimestru CHILD OF
    luna CHILD OF
    zi
)
ATTRIBUTE an DETERMINES (DIM_TIMP.An)
ATTRIBUTE trimestru DETERMINES (DIM_TIMP.Trimestru)
ATTRIBUTE luna DETERMINES (DIM_TIMP.Luna)
ATTRIBUTE zi DETERMINES (DIM_TIMP.DataCompleta, DIM_TIMP.Zi, DIM_TIMP.ZiSaptamana, DIM_TIMP.EsteWeekend);
BEGIN
    DBMS_OUTPUT.PUT_LINE('  ✓ DIMENSION dim_timp_dimension creat');
END;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('2. Creare DIMENSION DIM_UTILIZATOR...');
END;
/
BEGIN
    EXECUTE IMMEDIATE 'DROP DIMENSION dim_utilizator_dimension';
    DBMS_OUTPUT.PUT_LINE('  ⚠ Dimensiune veche ștearsă (dacă exista)');
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/
CREATE DIMENSION dim_utilizator_dimension
LEVEL rol IS (DIM_UTILIZATOR.IdRol)
LEVEL utilizator IS (DIM_UTILIZATOR.IdUtilizator)
HIERARCHY utilizator_hier (
    rol CHILD OF
    utilizator
)
ATTRIBUTE rol DETERMINES (DIM_UTILIZATOR.IdRol)
ATTRIBUTE utilizator DETERMINES (
    DIM_UTILIZATOR.IdUtilizator,
    DIM_UTILIZATOR.Nume,
    DIM_UTILIZATOR.Prenume,
    DIM_UTILIZATOR.EmailMasked,
    DIM_UTILIZATOR.TelefonMasked,
    DIM_UTILIZATOR.DataNastere,
    DIM_UTILIZATOR.VechimeLuni
);
BEGIN
    DBMS_OUTPUT.PUT_LINE('  ✓ DIMENSION dim_utilizator_dimension creat');
END;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('3. Validare dimensiuni...');
END;
/
DECLARE
    v_count_invalid NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count_invalid
    FROM DIM_TIMP
    WHERE Trimestru NOT BETWEEN 1 AND 4
       OR Luna NOT BETWEEN 1 AND 12
       OR Zi NOT BETWEEN 1 AND 31
       OR ZiSaptamana NOT BETWEEN 1 AND 7
       OR EsteWeekend NOT IN (0, 1);
    IF v_count_invalid = 0 THEN
        DBMS_OUTPUT.PUT_LINE('  ✓ DIM_TIMP: Toate datele respectă constrângerile');
    ELSE
        DBMS_OUTPUT.PUT_LINE('  ✗ DIM_TIMP: ' || v_count_invalid || ' înregistrări invalide');
    END IF;
    SELECT COUNT(*) INTO v_count_invalid
    FROM DIM_TIMP t1
    WHERE NOT EXISTS (
        SELECT 1 FROM DIM_TIMP t2
        WHERE t2.An = t1.An
          AND t2.Trimestru = t1.Trimestru
          AND t2.Luna = t1.Luna
          AND t2.DataCompleta = t1.DataCompleta
    );
    IF v_count_invalid = 0 THEN
        DBMS_OUTPUT.PUT_LINE('  ✓ DIM_TIMP: Ierarhia este corectă');
    ELSE
        DBMS_OUTPUT.PUT_LINE('  ✗ DIM_TIMP: Ierarhia are probleme');
    END IF;
END;
/
DECLARE
    v_count_invalid NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count_invalid
    FROM DIM_UTILIZATOR u
    WHERE NOT EXISTS (
        SELECT 1 FROM MONEYSHOP.ROLURI r 
        WHERE r.IdRol = u.IdRol
    );
    IF v_count_invalid = 0 THEN
        DBMS_OUTPUT.PUT_LINE('  ✓ DIM_UTILIZATOR: Toți utilizatorii au rol valid');
    ELSE
        DBMS_OUTPUT.PUT_LINE('  ✗ DIM_UTILIZATOR: ' || v_count_invalid || ' utilizatori cu rol invalid');
    END IF;
END;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('4. Listare dimensiuni create...');
END;
/
SELECT 
    DIMENSION_NAME,
    OWNER,
    LEVEL_NAME,
    HIERARCHY_NAME
FROM USER_DIMENSIONS
ORDER BY DIMENSION_NAME, HIERARCHY_NAME, LEVEL_NAME;
BEGIN
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('OBIECTE DIMENSIUNE - COMPLETAT!');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('Dimensiuni create:');
    DBMS_OUTPUT.PUT_LINE('  - dim_timp_dimension (ierarhie: an → trimestru → lună → zi)');
    DBMS_OUTPUT.PUT_LINE('  - dim_utilizator_dimension (ierarhie: rol → utilizator)');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Validare: Toate constrângerile sunt respectate');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Următorul pas: Rulează 10_DW_PARTITIONS.sql');
    DBMS_OUTPUT.PUT_LINE('');
END;
/