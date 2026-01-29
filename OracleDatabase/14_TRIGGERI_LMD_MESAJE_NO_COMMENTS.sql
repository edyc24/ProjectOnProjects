SET SERVEROUTPUT ON;
CREATE OR REPLACE TRIGGER trg_aplicatii_before_insert
BEFORE INSERT ON APLICATII
DECLARE
v_count NUMBER;
BEGIN
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
NULL;
END;
/
CREATE OR REPLACE TRIGGER trg_aplicatii_before_update
BEFORE UPDATE ON APLICATII
FOR EACH ROW
DECLARE
v_mesaj VARCHAR2(255);
BEGIN
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
RAISE;
END;
/
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
NULL;
END;
/
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
BEGIN
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('TRIGGERI LMD CU INSERARE ÎN MESAJE');
DBMS_OUTPUT.PUT_LINE('========================================');
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('Triggeri creați:');
DBMS_OUTPUT.PUT_LINE('  ✓ trg_aplicatii_before_insert (nivel comandă)');
DBMS_OUTPUT.PUT_LINE('  ✓ trg_aplicatii_before_update (nivel linie)');
DBMS_OUTPUT.PUT_LINE('  ✓ trg_aplicatii_after_insert (nivel linie)');
DBMS_OUTPUT.PUT_LINE('  ✓ trg_aplicatii_after_delete (nivel linie)');
DBMS_OUTPUT.PUT_LINE('  ✓ trg_utilizatori_varsta_mesaje (nivel linie)');
DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE('Toți triggerii inserează mesaje în tabelul MESAJE!');
DBMS_OUTPUT.PUT_LINE('========================================');
END;
/