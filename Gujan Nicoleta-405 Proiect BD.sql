-- Tabele

CREATE TABLE Profesori (
    ID_Profesor NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Nume VARCHAR2(50) NOT NULL,
    Prenume VARCHAR2(50) NOT NULL,
    CNP VARCHAR2(13) UNIQUE CHECK (LENGTH(CNP) = 13),
    Data_Nasterii DATE,
    Email VARCHAR2(100) UNIQUE NOT NULL, -- NOT NULL adăugat aici
    Telefon VARCHAR2(20)
);

CREATE TABLE Sali (
    ID_Sala NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Denumire VARCHAR2(50) NOT NULL UNIQUE,
    Capacitate NUMBER(3)
);

CREATE TABLE Materiale_Didactice (
    ID_Material NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Denumire VARCHAR2(100) NOT NULL,
    Descriere VARCHAR2(200),
    Tip VARCHAR2(50)
);

CREATE TABLE Cursuri (
    ID_Curs NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Denumire VARCHAR2(100) NOT NULL UNIQUE,
    Descriere VARCHAR2(200),
    Durata_Ore NUMBER(3),
    ID_Profesor NUMBER,
    ID_Sala NUMBER,
    FOREIGN KEY (ID_Profesor) REFERENCES Profesori(ID_Profesor),
    FOREIGN KEY (ID_Sala) REFERENCES Sali(ID_Sala)
);

CREATE TABLE Elevi (
    ID_Elev NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Nume VARCHAR2(50) NOT NULL,
    Prenume VARCHAR2(50) NOT NULL,
    CNP VARCHAR2(13) UNIQUE CHECK (LENGTH(CNP) = 13),
    Data_Nasterii DATE,
    Email VARCHAR2(100) UNIQUE,
    Telefon VARCHAR2(20)
);

CREATE TABLE Examene (
    ID_Examen NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ID_Curs NUMBER,
    Data_Examen DATE,
    FOREIGN KEY (ID_Curs) REFERENCES Cursuri(ID_Curs)
);

-- Tabel asociativ (many-to-many) intre Elevi si Cursuri
CREATE TABLE Inscrieri (
    ID_Inscriere NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ID_Elev NUMBER NOT NULL,
    ID_Curs NUMBER NOT NULL,
    Data_Inscriere DATE DEFAULT SYSDATE,
    Nota NUMBER(3, 2),
    Taxa NUMBER(10,2), -- Tip de date numeric pentru taxa
    FOREIGN KEY (ID_Elev) REFERENCES Elevi(ID_Elev),
    FOREIGN KEY (ID_Curs) REFERENCES Cursuri(ID_Curs),
    UNIQUE (ID_Elev, ID_Curs)
);

-- Tabel asociativ (many-to-many) intre Cursuri si Materiale Didactice
CREATE TABLE Cursuri_Materiale (
    ID_Curs NUMBER NOT NULL,
    ID_Material NUMBER NOT NULL,
    PRIMARY KEY (ID_Curs, ID_Material),
    FOREIGN KEY (ID_Curs) REFERENCES Cursuri(ID_Curs),
    FOREIGN KEY (ID_Material) REFERENCES Materiale_Didactice(ID_Material)
);

-- Tabel pentru Grupe
CREATE TABLE Grupe (
    ID_Grupa NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Nume_Grupa VARCHAR2(50) NOT NULL,
    Descriere VARCHAR2(200),
    ID_Curs NUMBER NOT NULL,
    FOREIGN KEY (ID_Curs) REFERENCES Cursuri(ID_Curs)
);

-- Tabel asociativ (many-to-many) intre Grupe si Elevi
CREATE TABLE Grupe_Elevi (
    ID_Grupa NUMBER NOT NULL,
    ID_Elev NUMBER NOT NULL,
    Data_Alocare DATE DEFAULT SYSDATE,
    PRIMARY KEY (ID_Grupa, ID_Elev),
    FOREIGN KEY (ID_Grupa) REFERENCES Grupe(ID_Grupa),
    FOREIGN KEY (ID_Elev) REFERENCES Elevi(ID_Elev)
);



INSERT INTO Profesori (Nume, Prenume, CNP, Data_Nasterii, Email, Telefon)
VALUES ('Popescu', 'Ion', '1800101123456', DATE '1980-01-01', 'ion.popescu@email.com', '0721111111');
 INSERT INTO Profesori (Nume, Prenume, CNP, Data_Nasterii, Email, Telefon)
VALUES ('Ionescu', 'Maria', '2900202234567', DATE '1990-02-02', 'maria.ionescu@email.com', '0733222222');
INSERT INTO Profesori (Nume, Prenume, CNP, Email, Telefon)
VALUES ('Georgescu', 'Andrei', '1750303345678', 'andrei.georgescu@email.com', '0744333333');
INSERT INTO Profesori (Nume, Prenume, CNP, Data_Nasterii, Email, Telefon)
VALUES ('Dumitrescu-Popa', 'Elena', '2850404456789', DATE '1985-04-04', 'elena.dumitrescu@email.com', '0755444444');
INSERT INTO Profesori (Nume, Prenume, CNP, Data_Nasterii, Email, Telefon)
VALUES ('Marinescu', 'Ana-Maria', '1920505567890', DATE '1992-05-05', 'ana.marinescu@email.com', '0766555555');
INSERT INTO Profesori (Nume, Prenume, CNP, Data_Nasterii, Email, Telefon)
VALUES ('Radu', 'Constantin', '1880606678901', DATE '1988-06-06', 'constantin.radu@email.com', '0777666666');
INSERT INTO Profesori (Nume, Prenume, CNP, Data_Nasterii, Email, Telefon)
VALUES ('Stoica', 'Ioana', '2950707789012', DATE '1995-07-07', 'ioana.stoica@altemail.com', '0788777777');
INSERT INTO Profesori (Nume, Prenume, CNP, Data_Nasterii, Email, Telefon)
VALUES ('Tudor', 'Alexandru', '1820808890123', DATE '1982-08-08', 'alexandru.tudor@email.com', '0799888888');
INSERT INTO Profesori (Nume, Prenume, CNP, Data_Nasterii, Email, Telefon)
VALUES ('Vasilescu', 'Gabriela', '2980909901234', DATE '1998-09-09', 'gabriela@vasilescu.ro', '0711999999');
INSERT INTO Profesori (Nume, Prenume, CNP, Data_Nasterii, Email, Telefon)
VALUES ('Ilie', 'Dan', '1701010012345', DATE '1970-10-10', 'dan.ilie@email.com', '0722000000');
INSERT INTO Profesori (Nume, Prenume, CNP, Data_Nasterii, Email, Telefon)
VALUES ('Petrescu', 'Laura', '2021111123456', DATE '2002-11-11', 'laura.petrescu@email.com', '+40733111111');
INSERT INTO Profesori (Nume, Prenume, CNP, Data_Nasterii, Email, Telefon)
VALUES ('Constantinescu', 'Mihai', '1651212234567', DATE '1965-12-12', 'mihai.constantinescu@email.com', '0744222222');

SELECT * FROM Profesori;

INSERT INTO Sali (Denumire, Capacitate) VALUES ('A101', 30);
INSERT INTO Sali (Denumire, Capacitate) VALUES ('B205', 50);
INSERT INTO Sali (Denumire, Capacitate) VALUES ('C001', 10);
INSERT INTO Sali (Denumire, Capacitate) VALUES ('Amfiteatru 1', 100);
INSERT INTO Sali (Denumire, Capacitate) VALUES ('D12', 25);
INSERT INTO Sali (Denumire, Capacitate) VALUES ('Lab20A', 20);
INSERT INTO Sali (Denumire, Capacitate) VALUES ('Sala Festiva', 999);
INSERT INTO Sali (Denumire, Capacitate) VALUES ('Cabinet Informatica', 35);
INSERT INTO Sali (Denumire, Capacitate) VALUES ('Sala de Consiliu', 15);
INSERT INTO Sali (Denumire, Capacitate) VALUES ('Sala 2', 60);

SELECT * FROM Sali;

INSERT INTO Materiale_Didactice (Denumire, Descriere, Tip) VALUES ('Manual de Matematica', 'Manual pentru clasa a IX-a', 'Manual');
INSERT INTO Materiale_Didactice (Denumire, Descriere, Tip) VALUES ('Culegere de exercitii Matematica', 'Exercitii pentru clasa a IX-a', 'Culegere');
INSERT INTO Materiale_Didactice (Denumire, Descriere, Tip) VALUES ('Tabla interactiva', 'Tabla interactiva pentru prezentari', 'Echipament');
INSERT INTO Materiale_Didactice (Denumire, Descriere, Tip) VALUES ('Proiector', 'Proiector pentru prezentari', 'Echipament');
INSERT INTO Materiale_Didactice (Denumire, Descriere, Tip) VALUES ('Set de instrumente geometrice', 'Compas, rigla, echer', 'Instrumente');
INSERT INTO Materiale_Didactice (Denumire, Descriere, Tip) VALUES ('Manual de Informatica', 'Manual pentru incepatori in programare', 'Manual');
INSERT INTO Materiale_Didactice (Denumire, Descriere, Tip) VALUES ('Culegere de probleme C++', 'Probleme practice de programare C++', 'Culegere');
INSERT INTO Materiale_Didactice (Denumire, Descriere, Tip) VALUES ('Laptop', 'Laptop pentru demonstratii', 'Echipament');
INSERT INTO Materiale_Didactice (Denumire, Descriere, Tip) VALUES ('Aplicatie software educationala', 'Aplicatie pentru simulari interactive', 'Software');
INSERT INTO Materiale_Didactice (Denumire, Descriere, Tip) VALUES ('Set de markere', 'Markere pentru tabla', 'Consumabile');

SELECT * FROM MATERIALE_DIDACTICE;

INSERT INTO Cursuri (Denumire, Descriere, Durata_Ore, ID_Profesor, ID_Sala)
VALUES ('Matematica Avansata', 'Curs de matematica pentru performanta', 60, 1, 1);
INSERT INTO Cursuri (Denumire, Descriere, Durata_Ore, ID_Profesor, ID_Sala)
VALUES ('Fizica Aplicata', 'Curs de fizica experimentala', 45, 2, 2);
INSERT INTO Cursuri (Denumire, Descriere, Durata_Ore, ID_Profesor, ID_Sala)
VALUES ('Chimie Organica', 'Curs de chimie organica pentru avansati', 50, 1, 3);
INSERT INTO Cursuri (Denumire, Descriere, Durata_Ore, ID_Profesor, ID_Sala)
VALUES ('Informatica Aplicata', 'Introducere in programare', 60, 2, 1);
INSERT INTO Cursuri (Denumire, Descriere, Durata_Ore, ID_Profesor, ID_Sala)
VALUES ('Biologie Celulara', 'Studiul celulelor', 40, 1, 2);
INSERT INTO Cursuri (Denumire, Descriere, Durata_Ore, ID_Profesor, ID_Sala)
VALUES ('Geografie Umana', 'Geografia populatiei', 45, 2, 3);
INSERT INTO Cursuri (Denumire, Descriere, Durata_Ore, ID_Profesor, ID_Sala)
VALUES ('Istoria Artei', 'Evolutia artei de-a lungul timpului', 50, 1, 1);
INSERT INTO Cursuri (Denumire, Descriere, Durata_Ore, ID_Profesor, ID_Sala)
VALUES ('Literatura Universala', 'Analiza operelor literare', 60, 2, 2);

INSERT INTO Cursuri (Denumire, Descriere, Durata_Ore, ID_Profesor, ID_Sala)
VALUES ('Economie Generala', 'Bazele economiei', 40, 1, 3);
INSERT INTO Cursuri (Denumire, Descriere, Durata_Ore, ID_Profesor, ID_Sala)
VALUES ('Psihologie Sociala', 'Comportamentul uman in societate', 45, 2, 1);

SELECT * FROM CURSURI;

INSERT INTO Elevi (Nume, Prenume, CNP, Data_Nasterii, Email, Telefon)
VALUES ('Ionescu', 'Andrei', '5011101123456', DATE '2001-01-01', 'andrei.ionescu@email.com', '0711111111');
INSERT INTO Elevi (Nume, Prenume, CNP, Data_Nasterii, Email, Telefon)
VALUES ('Popescu', 'Maria', '6020332234567', DATE '2002-02-02', 'maria.popescu@email.com', '0722222222');
INSERT INTO Elevi (Nume, Prenume, CNP, Email, Telefon)
VALUES ('Georgescu', 'Radu', '5037703345678', 'radu.georgescu@email.com', '0733333333');
INSERT INTO Elevi (Nume, Prenume, CNP, Data_Nasterii, Email, Telefon)
VALUES ('Dumitrescu-Ionescu', 'Ana', '6043304456789', DATE '2004-04-04', 'ana.dumitrescu@email.com', '0744444444');
INSERT INTO Elevi (Nume, Prenume, CNP, Data_Nasterii, Email, Telefon)
VALUES ('Marinescu', 'Ioan-Cristian', '5050885567890', DATE '2005-05-05', 'ioan.marinescu@email.com', '0755555555');
INSERT INTO Elevi (Nume, Prenume, CNP, Data_Nasterii, Email, Telefon)
VALUES ('Radulescu', 'Elena', '6060606678999', DATE '2006-06-06', 'elena.radulescu@email.com', '0766666666');
INSERT INTO Elevi (Nume, Prenume, CNP, Data_Nasterii, Email, Telefon)
VALUES ('Stoicescu', 'Mihai', '5070707789000', DATE '2007-07-07', 'mihai.stoicescu@altemail.com', '0777777777');
INSERT INTO Elevi (Nume, Prenume, CNP, Data_Nasterii, Email, Telefon)
VALUES ('Tudor', 'Alexandru', '6080808890122', DATE '2008-08-08', 'alexandru.tudor@email.com', '0788888888');
INSERT INTO Elevi (Nume, Prenume, CNP, Data_Nasterii, Email, Telefon)
VALUES ('Vasilescu', 'Gabriela', '5090909901211', DATE '2009-09-09', 'gabriela@vasilescu.net', '0799999999');
INSERT INTO Elevi (Nume, Prenume, CNP, Data_Nasterii, Email, Telefon)
VALUES ('Ilie', 'Dan', '6101010012322', DATE '2010-10-10', 'dan.ilie@email.com', '0700000000');
INSERT INTO Elevi (Nume, Prenume, CNP, Data_Nasterii, Email, Telefon)
VALUES ('Petrescu', 'Laura', '5111111124456', DATE '2011-11-11', 'laura.petrescu@email.com', '+40711111111');
INSERT INTO Elevi (Nume, Prenume, CNP, Data_Nasterii, Email, Telefon)
VALUES ('Constantinescu', 'Mihai', '6129910034567', DATE '2012-12-12', 'mihai.constantinescu@email.com', '0722222222');
INSERT INTO Elevi (Nume, Prenume, CNP, Data_Nasterii, Telefon)
VALUES ('Dumitru', 'Andreea', '6130101123466', DATE '2013-01-01', '0733333333');
INSERT INTO Elevi (Nume, Prenume, CNP, Data_Nasterii, Email, Telefon)
VALUES ('Georgescu', 'Constantin', '5140205534567', DATE '2014-02-02', 'constantin.g@email.com', '0744444444');
INSERT INTO Elevi (Nume, Prenume, CNP, Data_Nasterii, Email, Telefon)
VALUES ('Marinescu', 'Ioana', '6150303345688', DATE '2015-03-03', 'ioana.m@email.com', '0755555555');

SELECT * FROM Elevi;

INSERT INTO Examene (ID_Curs, Data_Examen) VALUES (1, DATE '2024-01-15');
INSERT INTO Examene (ID_Curs, Data_Examen) VALUES (2, DATE '2024-02-20');
INSERT INTO Examene (ID_Curs, Data_Examen) VALUES (3, DATE '2024-03-10');
INSERT INTO Examene (ID_Curs, Data_Examen) VALUES (1, DATE '2024-05-15');
INSERT INTO Examene (ID_Curs, Data_Examen) VALUES (4, DATE '2024-04-25');
INSERT INTO Examene (ID_Curs, Data_Examen) VALUES (5, DATE '2024-06-01');
INSERT INTO Examene (ID_Curs, Data_Examen) VALUES (1, DATE '2024-08-20');
INSERT INTO Examene (ID_Curs, Data_Examen) VALUES (6, DATE '2024-07-12');
INSERT INTO Examene (ID_Curs, Data_Examen) VALUES (7, DATE '2024-09-05');
INSERT INTO Examene (ID_Curs, Data_Examen) VALUES (8, DATE '2024-10-30');

SELECT * FROM Examene;

INSERT INTO Inscrieri (ID_Elev, ID_Curs, Nota, Taxa) VALUES (1, 1, 8.50, 500.00);
INSERT INTO Inscrieri (ID_Elev, ID_Curs, Nota, Taxa) VALUES (2, 2, 9.00, 750.50);
INSERT INTO Inscrieri (ID_Elev, ID_Curs, Nota, Taxa) VALUES (1, 3, 7.00, 600.00);
INSERT INTO Inscrieri (ID_Elev, ID_Curs, Nota, Taxa) VALUES (3, 1, 9.50, 500.00);
INSERT INTO Inscrieri (ID_Elev, ID_Curs, Nota, Taxa) VALUES (2, 3, 8.00, 600.00);
INSERT INTO Inscrieri (ID_Elev, ID_Curs, Nota, Taxa) VALUES (4, 4, 7.50, 800.00);
INSERT INTO Inscrieri (ID_Elev, ID_Curs, Nota, Taxa) VALUES (5, 1, 6.00, 500.00);
INSERT INTO Inscrieri (ID_Elev, ID_Curs, Nota, Taxa) VALUES (3, 2, 8.80, 750.50);
INSERT INTO Inscrieri (ID_Elev, ID_Curs, Nota, Taxa) VALUES (6, 5, 9.20, 900.00);
INSERT INTO Inscrieri (ID_Elev, ID_Curs, Nota, Taxa) VALUES (7, 3, 7.80, 600.00);
INSERT INTO Inscrieri (ID_Elev, ID_Curs, Nota, Taxa) VALUES (8, 6, 8.10, 1000.00);
INSERT INTO Inscrieri (ID_Elev, ID_Curs, Nota, Taxa) VALUES (9, 7, 9.90, 1200.00);

SELECT * FROM Inscrieri;

INSERT INTO Cursuri_Materiale (ID_Curs, ID_Material) VALUES (1, 1);
INSERT INTO Cursuri_Materiale (ID_Curs, ID_Material) VALUES (1, 2);
INSERT INTO Cursuri_Materiale (ID_Curs, ID_Material) VALUES (2, 3);
INSERT INTO Cursuri_Materiale (ID_Curs, ID_Material) VALUES (3, 1);
INSERT INTO Cursuri_Materiale (ID_Curs, ID_Material) VALUES (2, 4);
INSERT INTO Cursuri_Materiale (ID_Curs, ID_Material) VALUES (4, 5);
INSERT INTO Cursuri_Materiale (ID_Curs, ID_Material) VALUES (5, 6);
INSERT INTO Cursuri_Materiale (ID_Curs, ID_Material) VALUES (3, 7);
INSERT INTO Cursuri_Materiale (ID_Curs, ID_Material) VALUES (6, 8);
INSERT INTO Cursuri_Materiale (ID_Curs, ID_Material) VALUES (7, 9);

SELECT * FROM Cursuri_Materiale;

INSERT INTO Grupe (Nume_Grupa, Descriere, ID_Curs) VALUES ('Grupa A', 'Grupa de incepatori', 1);
INSERT INTO Grupe (Nume_Grupa, Descriere, ID_Curs) VALUES ('Grupa B', 'Grupa de avansati', 1);
INSERT INTO Grupe (Nume_Grupa, Descriere, ID_Curs) VALUES ('Grupa principala', 'Grupa standard', 2);
INSERT INTO Grupe (Nume_Grupa, Descriere, ID_Curs) VALUES ('Grupa X', 'Grupa de dimineata', 3);
INSERT INTO Grupe (Nume_Grupa, Descriere, ID_Curs) VALUES ('Grupa Y', 'Grupa de seara', 3);
INSERT INTO Grupe (Nume_Grupa, Descriere, ID_Curs) VALUES ('Grupa unica', 'Singura grupa disponibila', 4);
INSERT INTO Grupe (Nume_Grupa, Descriere, ID_Curs) VALUES ('Grupa alfa', 'Prima grupa formata', 5);
INSERT INTO Grupe (Nume_Grupa, Descriere, ID_Curs) VALUES ('Grupa beta', 'A doua grupa formata', 5);
INSERT INTO Grupe (Nume_Grupa, Descriere, ID_Curs) VALUES ('Grupa principala', 'Grupa standard', 6);
INSERT INTO Grupe (Nume_Grupa, Descriere, ID_Curs) VALUES ('Grupa 1', 'Grupa de studiu', 7);

SELECT * FROM Grupe;

INSERT INTO Grupe_Elevi (ID_Grupa, ID_Elev) VALUES (1, 1);
INSERT INTO Grupe_Elevi (ID_Grupa, ID_Elev) VALUES (1, 2);
INSERT INTO Grupe_Elevi (ID_Grupa, ID_Elev) VALUES (2, 3);
INSERT INTO Grupe_Elevi (ID_Grupa, ID_Elev) VALUES (3, 1);
INSERT INTO Grupe_Elevi (ID_Grupa, ID_Elev) VALUES (2, 4);
INSERT INTO Grupe_Elevi (ID_Grupa, ID_Elev) VALUES (4, 5);
INSERT INTO Grupe_Elevi (ID_Grupa, ID_Elev) VALUES (4, 2);
INSERT INTO Grupe_Elevi (ID_Grupa, ID_Elev) VALUES (5, 6);
INSERT INTO Grupe_Elevi (ID_Grupa, ID_Elev) VALUES (3, 7);
INSERT INTO Grupe_Elevi (ID_Grupa, ID_Elev) VALUES (1, 8);
INSERT INTO Grupe_Elevi (ID_Grupa, ID_Elev) VALUES (5, 9);
INSERT INTO Grupe_Elevi (ID_Grupa, ID_Elev) VALUES (2, 10);

SELECT * FROM Grupe_Elevi;


UPDATE ELEVI SET Nume = 'Popescu', Prenume = 'Andrei' WHERE ID_ELEV = 1;
SELECT * FROM ELEVI;

SELECT c.Denumire, COUNT(i.ID_Elev) AS "Numar Elevi Inscrisi Luna Curenta"
FROM Cursuri c
JOIN Inscrieri i ON c.ID_Curs = i.ID_Curs
WHERE TO_CHAR(i.Data_Inscriere, 'YYYY-MM') = TO_CHAR(SYSDATE, 'YYYY-MM')
GROUP BY c.Denumire;


SELECT * FROM ELEVI WHERE Nume = 'Popescu';

SELECT * FROM CURSURI WHERE Denumire != 'Matematica Avansata';

SELECT Denumire
FROM Cursuri
WHERE Durata_Ore > (SELECT AVG(Durata_Ore) FROM Cursuri);

SELECT * FROM Cursuri WHERE DESCRIERE LIKE '%Studiul celulelor%';


SELECT LOWER(Nume) AS LowercaseString FROM ELEVI;


SELECT UPPER(Nume) AS UppercaseString FROM PROFESORI;


SELECT LENGTH(DENUMIRE) AS StringLength FROM CURSURI;


SELECT ABS(CNP) AS AbsoluteValue FROM PROFESORI;


SELECT ROUND(Nota) AS RoundedValue FROM Inscrieri;


SELECT SYSDATE AS CurrentDateTime FROM dual;


SELECT TO_CHAR(DATA_NASTERII, 'YYYY-MM-DD') AS FormattedDate FROM PROFESORI;


SELECT MONTHS_BETWEEN(SYSDATE, DATA_EXAMEN) AS MonthsDifference FROM EXAMENE;


SELECT p.Nume, COUNT(c.ID_Curs)
AS NumarCursuri FROM PROFESORI p INNER JOIN CURSURI c ON p.ID_Profesor = c.ID_Profesor GROUP BY p.Nume HAVING COUNT(c.ID_Curs) > 2;


SELECT e.Nume, AVG(i.Nota) AS MedieNote FROM ELEVI e LEFT JOIN INSCRIERI i ON e.ID_Elev = i.ID_Elev GROUP BY e.Nume HAVING AVG(i.Nota) >= 7;



SELECT c.Denumire, SUM(i.Taxa) AS TotalTaxe FROM CURSURI c RIGHT JOIN INSCRIERI i ON c.ID_Curs = i.ID_Curs GROUP BY c.Denumire HAVING SUM(i.Taxa) > 500;

SELECT e.Nume, DECODE(i.taxa, 0, 'buget', 'taxa') AS tip_plata
FROM inscrieri i
JOIN ELEVI e ON i.ID_elev = e.ID_elev;



SELECT e.Nume, e.Prenume
FROM ELEVI e
JOIN INSCRIERI i ON e.ID_Elev = i.ID_Elev
WHERE i.ID_Curs = 1
MINUS
SELECT e.Nume, e.Prenume
FROM ELEVI e
JOIN INSCRIERI i ON e.ID_Elev = i.ID_Elev
JOIN Grupe_Elevi ge ON i.ID_Elev = ge.ID_Elev
WHERE i.ID_Curs = 1 AND ge.ID_Grupa IN (SELECT ID_Grupa FROM Grupe WHERE ID_Curs = 1);

SELECT e.Nume, e.Prenume
FROM ELEVI e
JOIN Inscrieri i ON e.ID_Elev = i.ID_Elev
WHERE i.ID_Curs = 1
INTERSECT
SELECT e.Nume, e.Prenume
FROM ELEVI e
JOIN INSCRIERI i ON e.ID_Elev = i.ID_Elev
WHERE i.ID_Curs = 2;

SELECT c.Denumire
FROM Cursuri c
WHERE NOT EXISTS (
    SELECT e.ID_Elev
    FROM Elevi e
    WHERE NOT EXISTS (
    	SELECT *
    	FROM Inscrieri i
    	WHERE i.ID_Elev = e.ID_Elev AND i.ID_Curs = c.ID_Curs
    )
    AND e.ID_Elev IN (
    	SELECT ge.ID_Elev
    	FROM Grupe_Elevi ge
    	WHERE ge.ID_Grupa = 1
    )
)
INTERSECT
SELECT c.Denumire
FROM Cursuri c;

SELECT c.Denumire
FROM Cursuri c
WHERE NOT EXISTS (
    SELECT i.ID_Elev
    FROM Inscrieri i
    WHERE i.ID_Curs = c.ID_Curs AND i.Nota <= 8
)
INTERSECT
SELECT c.Denumire
FROM Cursuri c
WHERE EXISTS (
    SELECT ge.ID_Grupa
    FROM Grupe_Elevi ge
    WHERE ge.ID_Elev = c.ID_SALA
    GROUP BY ge.ID_Grupa
    HAVING COUNT(*) = (SELECT COUNT(*) FROM Elevi e JOIN Inscrieri i ON e.ID_Elev = i.ID_Elev WHERE i.ID_Curs = c.ID_Curs)
);


SELECT p.Nume, p.Prenume
FROM Profesori p
JOIN Cursuri c ON p.ID_Profesor = c.ID_Profesor
WHERE c.ID_Curs IN (
    SELECT ID_Curs FROM Cursuri WHERE Durata_Ore > 2
)
INTERSECT
SELECT p.Nume, p.Prenume
FROM Profesori p
JOIN Cursuri c ON p.ID_Profesor = c.ID_Profesor
WHERE c.ID_Curs IN (
    SELECT ID_Curs FROM Cursuri WHERE Durata_Ore < 2
);



SELECT p.Nume, p.Prenume
FROM Profesori p
JOIN Cursuri c ON p.ID_Profesor = c.ID_Profesor
WHERE c.ID_Curs IN (
    SELECT ID_Curs FROM Cursuri WHERE Durata_Ore > 2
)
INTERSECT
SELECT p.Nume, p.Prenume
FROM Profesori p
JOIN Cursuri c ON p.ID_Profesor = c.ID_Profesor
WHERE c.ID_Curs IN (
    SELECT ID_Curs FROM Cursuri WHERE Durata_Ore < 2
);



SELECT c.DENUMIRE
FROM Cursuri c
WHERE c.Durata_Ore > 40
UNION
SELECT c.DENUMIRE
FROM Cursuri c
JOIN Inscrieri i ON c.ID_Curs = i.ID_Curs
GROUP BY c.ID_Curs, c.DENUMIRE
HAVING COUNT(*) > 8;


SELECT Nume, Data_nasterii FROM ELEVI
WHERE Data_nasterii = (SELECT MAX(Data_nasterii) FROM ELEVI);

--nume elevi ce nu sunt inscrisi la niciun curs
SELECT Nume FROM ELEVI
WHERE ID_Elev NOT IN (SELECT ID_Elev FROM INSCRIERI);

SELECT Nume FROM ELEVI
WHERE ID_Elev IN ( SELECT ID_Elev FROM INSCRIERI WHERE ID_curs IN (SELECT ID_Curs FROM CURSURI WHERE DENUMIRE = 'Fizica Aplicata'));

SELECT Nume, Data_nasterii FROM ELEVI
WHERE EXTRACT(YEAR FROM Data_nasterii) > (SELECT AVG(EXTRACT(YEAR FROM Data_nasterii)) 
FROM ELEVI); 

SELECT P.Nume, COUNT(C.ID_Curs) AS numar_cursuri 
FROM PROFESORI P
LEFT JOIN CURSURI C ON P.ID_Profesor = C.ID_Profesor
GROUP BY P.Nume;


SELECT Data_inscriere, COUNT(ID_Elev) AS numar_elevi 
FROM INSCRIERI 
GROUP BY Data_inscriere 
ORDER BY Data_inscriere;



SELECT e.Nume, e.Prenume, i.Data_Inscriere
FROM Elevi e
JOIN Inscrieri i ON e.ID_Elev = i.ID_Elev
JOIN Cursuri c ON i.ID_Curs = c.ID_Curs
WHERE c.Denumire = 'Istorie'
ORDER BY i.Data_Inscriere DESC;

--Trigger ca un elev sa nu se inscrie de mai multe ori la acelasi curs 

CREATE OR REPLACE TRIGGER trg_inscrieri_unicitate
BEFORE INSERT OR UPDATE ON Inscrieri
FOR EACH ROW
DECLARE
  v_nr_inscrieri NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_nr_Inscrieri
  FROM Inscrieri
  WHERE ID_Elev = :NEW.ID_Elev AND ID_Curs = :NEW.ID_Curs;

  IF v_nr_inscrieri > 0 THEN
    RAISE_APPLICATION_ERROR(-20002, 'Elevul este deja înscris la acest curs.');
  END IF;
END;
/

--Trigger care sa verifice daca un profesor poate preda mai mult de 3 cursuri simultan 
CREATE OR REPLACE TRIGGER trg_cursuri_profesor
BEFORE INSERT OR UPDATE ON Cursuri
FOR EACH ROW
DECLARE
  v_nr_cursuri NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_nr_cursuri
  FROM Cursuri
  WHERE ID_Profesor = :NEW.ID_Profesori;

  IF v_nr_cursuri >= 3 THEN
    RAISE_APPLICATION_ERROR(-20003, 'Un profesor nu poate preda mai mult de 3 cursuri.');
  END IF;
END;
/
UPDATE Elevi SET Email = 'test@gmail.com' WHERE ID_Elev = 1;
ALTER TABLE Sali ADD Etaj VARCHAR2(6);
