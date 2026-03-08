-- 1. Tabelul JOBURI
CREATE TABLE JOBURI (
    id_job INTEGER CONSTRAINT pk_joburi PRIMARY KEY,
    nume_job VARCHAR2(50) NOT NULL,
    salariu_minim NUMBER(10, 2),
    salariu_maxim NUMBER(10, 2),
    CONSTRAINT ck_salarii CHECK (salariu_maxim > salariu_minim)
);

-- 2. Tabelul DEPARTAMENTE
CREATE TABLE DEPARTAMENTE (
    id_departament INTEGER CONSTRAINT pk_departamente PRIMARY KEY,
    nume_departament VARCHAR2(50) NOT NULL,
    id_manager INTEGER 
);

-- 3. Tabelul ANGAJATI
CREATE TABLE ANGAJATI (
    id_angajat INTEGER CONSTRAINT pk_angajati PRIMARY KEY,
    id_departament INTEGER ,
    id_job INTEGER ,
    id_manager INTEGER,
    nume_familie VARCHAR2(50) NOT NULL,
    prenume VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) CONSTRAINT unq_email NOT NULL,
    nr_telefon VARCHAR2(15) NOT NULL,
    salariu NUMBER(10, 2) CONSTRAINT ck_salariu_pozitiv CHECK (salariu > 0),
    data_angajare DATE NOT NULL,
    CONSTRAINT fk_ang_dept FOREIGN KEY (id_departament) REFERENCES DEPARTAMENTE(id_departament),
    CONSTRAINT fk_ang_job FOREIGN KEY (id_job) REFERENCES JOBURI(id_job) ON DELETE SET NULL,
    CONSTRAINT fk_ang_mgr FOREIGN KEY (id_manager) REFERENCES ANGAJATI(id_angajat)
);

ALTER TABLE DEPARTAMENTE ADD CONSTRAINT fk_dept_mgr FOREIGN KEY (id_manager) REFERENCES ANGAJATI(id_angajat);

-- 4. Tabelul CLIENTI
CREATE TABLE CLIENTI (
    id_client INTEGER CONSTRAINT pk_clienti PRIMARY KEY,
    nume VARCHAR2(50) NOT NULL,
    prenume VARCHAR2(50) NOT NULL,
    nr_telefon VARCHAR2(15) NOT NULL,
    achitare_reparatie VARCHAR2(15),
    CONSTRAINT ck_telefon_prefix CHECK (nr_telefon LIKE '+40%')
);

-- 5. Tabelul MARCI
CREATE TABLE MARCI (
    id_marca INTEGER CONSTRAINT pk_marci PRIMARY KEY,
    denumire_marca VARCHAR2(50) NOT NULL,
    an_fabricatie NUMBER(4) NOT NULL,
    capacitate_motor NUMBER(5) NOT NULL, 
    CONSTRAINT ck_motor CHECK (capacitate_motor > 0),
    CONSTRAINT ck_an CHECK (an_fabricatie > 2000)
);

-- 6. Tabelul AUTOVEHICULE
CREATE TABLE AUTOVEHICULE (
    id_autovehicul INTEGER CONSTRAINT pk_auto PRIMARY KEY,
    numar_inmatriculare VARCHAR2(15) CONSTRAINT unq_nr_inmat UNIQUE NOT NULL,
    tip_autovehicul VARCHAR2(15) NOT NULL CONSTRAINT ck_tip CHECK (tip_autovehicul IN ('Sedan', 'SUV', 'Duba')),
    cutie_viteze VARCHAR2(15) CONSTRAINT ck_cutie CHECK (cutie_viteze IN ('Manuala', 'Automata')),
    pret_reparatie NUMBER(10, 2) NOT NULL,
    data_intrare DATE NOT NULL,
    data_iesire DATE,
    id_marca INTEGER NOT NULL,
    id_client INTEGER NOT NULL,
    CONSTRAINT fk_auto_marca FOREIGN KEY (id_marca) REFERENCES MARCI(id_marca),
    CONSTRAINT fk_auto_client FOREIGN KEY (id_client) REFERENCES CLIENTI(id_client) ON DELETE CASCADE,
    CONSTRAINT ck_date CHECK (data_iesire >= data_intrare)
);

-- 7. Tabelul PIESE
CREATE TABLE PIESE (
    id_piesa INTEGER CONSTRAINT pk_piese PRIMARY KEY,
    denumire_piesa VARCHAR2(50) NOT NULL,
    stoc_disponibil NUMBER(4) CONSTRAINT ck_stoc CHECK (stoc_disponibil >= 0),
    pret_piesa NUMBER(10, 2) NOT NULL
    CONSTRAINT ck_pret CHECK (pret_piesa > 0)
);

-- 8. Tabelul de legătură ANGAJATI_AUTOVEHICULE
CREATE TABLE ANGAJATI_AUTOVEHICULE (
    id_angajat INTEGER,
    id_autovehicul INTEGER,
    data_reparatie DATE NOT NULL,
    descriere_problema VARCHAR2(100) NOT NULL,
    CONSTRAINT pk_ang_auto PRIMARY KEY (id_angajat, id_autovehicul),
    CONSTRAINT fk_link_ang FOREIGN KEY (id_angajat) REFERENCES ANGAJATI(id_angajat),
    CONSTRAINT fk_link_auto FOREIGN KEY (id_autovehicul) REFERENCES AUTOVEHICULE(id_autovehicul)
);

-- 9. Tabelul de legătură AUTOVEHICULE_PIESE 
CREATE TABLE AUTOVEHICULE_PIESE (
    id_autovehicul INTEGER,
    id_piesa INTEGER,
    cantitate_utilizata NUMBER(4) NOT NULL,
    CONSTRAINT pk_auto_piesa PRIMARY KEY (id_autovehicul, id_piesa),
    CONSTRAINT fk_link_v_auto FOREIGN KEY (id_autovehicul) REFERENCES AUTOVEHICULE(id_autovehicul),
    CONSTRAINT fk_link_piesa FOREIGN KEY (id_piesa) REFERENCES PIESE(id_piesa),
    CONSTRAINT ck_cantitate CHECK (cantitate_utilizata > 0)
);

-- Permitem ștergerea automată a reparațiilor când se șterge o mașină
ALTER TABLE ANGAJATI_AUTOVEHICULE DROP CONSTRAINT FK_LINK_AUTO;
ALTER TABLE ANGAJATI_AUTOVEHICULE 
ADD CONSTRAINT FK_LINK_AUTO 
FOREIGN KEY (id_autovehicul) 
REFERENCES AUTOVEHICULE(id_autovehicul) 
ON DELETE CASCADE;

-- Permitem ștergerea automată a pieselor folosite când se șterge o mașină
ALTER TABLE AUTOVEHICULE_PIESE DROP CONSTRAINT FK_LINK_V_AUTO;
ALTER TABLE AUTOVEHICULE_PIESE 
ADD CONSTRAINT FK_LINK_V_AUTO 
FOREIGN KEY (id_autovehicul) 
REFERENCES AUTOVEHICULE(id_autovehicul) 
ON DELETE CASCADE;


--Populare tabele
-- 1. Inserare JOBURI
INSERT INTO JOBURI VALUES (1, 'Manager Service', 7000, 12000);
INSERT INTO JOBURI VALUES (2, 'Mecanic Sef', 5000, 8500);
INSERT INTO JOBURI VALUES (3, 'Mecanic Junior', 3000, 4500);
INSERT INTO JOBURI VALUES (4, 'Electrician Auto', 4500, 7500);
INSERT INTO JOBURI VALUES (5, 'Tinichigiu', 4000, 7000);
INSERT INTO JOBURI VALUES (6, 'Vopsitor', 4000, 7000);
INSERT INTO JOBURI VALUES (7, 'Receptioner', 3000, 5000);
INSERT INTO JOBURI VALUES (8, 'Diagnostician', 5000, 9000);
INSERT INTO JOBURI VALUES (9, 'Ucenic', 2200, 2800);
INSERT INTO JOBURI VALUES (10, 'Magazioner', 3500, 6000);

-- 2. Inserare DEPARTAMENTE 
INSERT INTO DEPARTAMENTE (id_departament, nume_departament) VALUES (10, 'Administrativ');
INSERT INTO DEPARTAMENTE (id_departament, nume_departament) VALUES (20, 'Mecanica');
INSERT INTO DEPARTAMENTE (id_departament, nume_departament) VALUES (30, 'Electrica Auto');
INSERT INTO DEPARTAMENTE (id_departament, nume_departament) VALUES (40, 'Vopsitorie');
INSERT INTO DEPARTAMENTE (id_departament, nume_departament) VALUES (50, 'Tinichigerie');
INSERT INTO DEPARTAMENTE (id_departament, nume_departament) VALUES (60, 'Relatii Clienti');

-- 3. Inserare ANGAJATI
INSERT INTO ANGAJATI VALUES (101, 60, 7, NULL, 'Popa', 'Alexandra', 'alexandra.p@gmail.com', '0721131561', 10000, TO_DATE('2020-01-01', 'YYYY-MM-DD'));
INSERT INTO ANGAJATI VALUES (102, 20, 2, 102, 'Popescu', 'Andrei', 'andrei.p@gmail.com', '0722422892', 7500, TO_DATE('2020-03-15', 'YYYY-MM-DD'));
INSERT INTO ANGAJATI VALUES (103, 20, 3, 102, 'Ionescu', 'Mihai', 'mihai.i@gmail.com', '0721233883', 4000, TO_DATE('2021-05-10', 'YYYY-MM-DD'));
INSERT INTO ANGAJATI VALUES (104, 30, 4, NULL, 'Radu', 'George', 'george.r@gmail.com', '0724746244', 6500, TO_DATE('2021-06-01', 'YYYY-MM-DD'));
INSERT INTO ANGAJATI VALUES (105, 50, 5, NULL, 'Dumitru', 'Stefan', 'stefan.d@gmail.com', '0725759505', 5500, TO_DATE('2022-02-20', 'YYYY-MM-DD'));
INSERT INTO ANGAJATI VALUES (106, 40, 6, NULL, 'Stoica', 'Alex', 'alex.s@gmail.com', '0726062866', 5800, TO_DATE('2022-03-01', 'YYYY-MM-DD'));
INSERT INTO ANGAJATI VALUES (107, 60, 7, 101, 'Lazar', 'Elena', 'elena.l@gmail.com', '0727097527', 4500, TO_DATE('2023-01-10', 'YYYY-MM-DD'));
INSERT INTO ANGAJATI VALUES (108, 30, 8, 104, 'Pavel', 'Andrei', 'andrei.p@gmail.com', '0729488018', 7000, TO_DATE('2019-12-01', 'YYYY-MM-DD'));
INSERT INTO ANGAJATI VALUES (109, 20, 9, 102, 'Enache', 'Cristian', 'cristi.e@gmail.com', '0729391909', 2500, TO_DATE('2023-08-15', 'YYYY-MM-DD'));
INSERT INTO ANGAJATI VALUES (110, 10, 1, NULL, 'Marin', 'Daniel', 'daniel.m@gmail.com', '0735284010', 5000, TO_DATE('2022-11-11', 'YYYY-MM-DD'));
INSERT INTO ANGAJATI VALUES (111, 10, 10, 110, 'Dinu', 'Robert', 'robert.d@gmail.com', '0737884250', 4500, TO_DATE('2020-10-11', 'YYYY-MM-DD'));


UPDATE DEPARTAMENTE SET id_manager = 110 WHERE id_departament = 10;
UPDATE DEPARTAMENTE SET id_manager = 101 WHERE id_departament = 60;
UPDATE DEPARTAMENTE SET id_manager = 104 WHERE id_departament = 30;
UPDATE DEPARTAMENTE SET id_manager = 102 WHERE id_departament = 20;
UPDATE DEPARTAMENTE SET id_manager = 106 WHERE id_departament = 40;
UPDATE DEPARTAMENTE SET id_manager = 105 WHERE id_departament = 50;


-- 4. Inserare CLIENTI 
INSERT INTO CLIENTI VALUES (1, 'Vasile', 'Ion', '+40715411091', 'Achitat');
INSERT INTO CLIENTI VALUES (2, 'Georgescu', 'Ana', '+40728322012', 'Restant');
INSERT INTO CLIENTI VALUES (3, 'Stan', 'Cristina', '+40733733603', 'Achitat');
INSERT INTO CLIENTI VALUES (4, 'Dinu', 'Robert', '+40745844884', 'Achitat');
INSERT INTO CLIENTI VALUES (5, 'Oprea', 'Marian', '+40755835535', 'Restant');
INSERT INTO CLIENTI VALUES (6, 'Constantin', 'Laura', '+40763166246', 'Achitat');
INSERT INTO CLIENTI VALUES (7, 'Matei', 'Cosmin', '+40736770177', 'Achitat');
INSERT INTO CLIENTI VALUES (8, 'Dima', 'Simona', '+40788578801', 'Restant');
INSERT INTO CLIENTI VALUES (9, 'Nistor', 'Adrian', '+40790399799', 'Achitat');
INSERT INTO CLIENTI VALUES (10, 'Iancu', 'Victor', '+40710561019', 'Achitat');

-- 5. Inserare MARCI
INSERT INTO MARCI VALUES (1, 'Dacia', 2022, 1500);
INSERT INTO MARCI VALUES (2, 'Toyota', 2021, 2000);
INSERT INTO MARCI VALUES (3, 'Volkswagen', 2019, 1600);
INSERT INTO MARCI VALUES (4, 'Ford', 2020, 1200);
INSERT INTO MARCI VALUES (5, 'BMW', 2022, 3000);
INSERT INTO MARCI VALUES (6, 'Mercedes', 2023, 2500);
INSERT INTO MARCI VALUES (7, 'Audi', 2021, 2000);
INSERT INTO MARCI VALUES (8, 'Hyundai', 2022, 1400);
INSERT INTO MARCI VALUES (9, 'Renault', 2021, 1500);
INSERT INTO MARCI VALUES (10, 'Volvo', 2022, 2000);

-- 6. Inserare AUTOVEHICULE
INSERT INTO AUTOVEHICULE VALUES (1, 'DJ 01 ABC', 'Sedan', 'Manuala', 1500, TO_DATE('2024-01-01', 'YYYY-MM-DD'), TO_DATE('2024-01-05', 'YYYY-MM-DD'), 1, 1);
INSERT INTO AUTOVEHICULE VALUES (2, 'DJ 02 XYZ', 'SUV', 'Automata', 3000, TO_DATE('2024-01-10', 'YYYY-MM-DD'), NULL, 2, 2);
INSERT INTO AUTOVEHICULE VALUES (3, 'B 03 PRO', 'Sedan', 'Manuala', 1000, TO_DATE('2024-01-12', 'YYYY-MM-DD'), TO_DATE('2024-01-14', 'YYYY-MM-DD'), 3, 3);
INSERT INTO AUTOVEHICULE VALUES (4, 'GJ 04 DUB', 'Duba', 'Manuala', 4500, TO_DATE('2024-01-15', 'YYYY-MM-DD'), NULL, 4, 4);
INSERT INTO AUTOVEHICULE VALUES (5, 'B 05 BMW', 'Sedan', 'Automata', 2000, TO_DATE('2024-01-20', 'YYYY-MM-DD'), TO_DATE('2024-01-25', 'YYYY-MM-DD'), 5, 5);
INSERT INTO AUTOVEHICULE VALUES (6, 'OT 06 MER', 'SUV', 'Automata', 5000, TO_DATE('2024-02-01', 'YYYY-MM-DD'), TO_DATE('2024-02-10', 'YYYY-MM-DD'), 6, 6);
INSERT INTO AUTOVEHICULE VALUES (7, 'B 07 AUD', 'Sedan', 'Automata', 3500, TO_DATE('2024-02-05', 'YYYY-MM-DD'), NULL, 7, 7);
INSERT INTO AUTOVEHICULE VALUES (8, 'B 08 HYU', 'Sedan', 'Manuala', 1200, TO_DATE('2024-02-10', 'YYYY-MM-DD'), TO_DATE('2024-02-12', 'YYYY-MM-DD'), 8, 8);
INSERT INTO AUTOVEHICULE VALUES (9, 'TM 09 REN', 'Sedan', 'Manuala', 900, TO_DATE('2024-02-15', 'YYYY-MM-DD'), TO_DATE('2024-02-16', 'YYYY-MM-DD'), 9, 9);
INSERT INTO AUTOVEHICULE VALUES (10, 'TM 10 VOL', 'SUV', 'Automata', 2800, TO_DATE('2024-02-20', 'YYYY-MM-DD'), NULL, 10, 10);

-- 7. Inserare PIESE
INSERT INTO PIESE VALUES (1, 'Filtru Ulei', 50, 60);
INSERT INTO PIESE VALUES (2, 'Ulei Motor 5W30', 100, 45);
INSERT INTO PIESE VALUES (3, 'Placute Frana', 30, 250);
INSERT INTO PIESE VALUES (4, 'Baterie 75Ah', 15, 600);
INSERT INTO PIESE VALUES (5, 'Bec H7', 200, 25);
INSERT INTO PIESE VALUES (6, 'Kit Distributie', 10, 1200);
INSERT INTO PIESE VALUES (7, 'Amortizor Fata', 12, 450);
INSERT INTO PIESE VALUES (8, 'Lichid Parbriz', 150, 15);
INSERT INTO PIESE VALUES (9, 'Bujie Iridium', 60, 85);
INSERT INTO PIESE VALUES (10, 'Filtru Aer', 40, 75);

-- 8. ANGAJATI_AUTOVEHICULE
INSERT INTO ANGAJATI_AUTOVEHICULE VALUES (102, 1, TO_DATE('2024-01-02', 'YYYY-MM-DD'), 'Schimb ulei si filtre');
INSERT INTO ANGAJATI_AUTOVEHICULE VALUES (103, 1, TO_DATE('2024-01-02', 'YYYY-MM-DD'), 'Verificare directie');
INSERT INTO ANGAJATI_AUTOVEHICULE VALUES (104, 2, TO_DATE('2024-01-11', 'YYYY-MM-DD'), 'Diagnoza electrica');
INSERT INTO ANGAJATI_AUTOVEHICULE VALUES (102, 3, TO_DATE('2024-01-13', 'YYYY-MM-DD'), 'Inlocuire placute frana');
INSERT INTO ANGAJATI_AUTOVEHICULE VALUES (105, 4, TO_DATE('2024-01-16', 'YYYY-MM-DD'), 'Tinichigerie prag');
INSERT INTO ANGAJATI_AUTOVEHICULE VALUES (106, 4, TO_DATE('2024-01-18', 'YYYY-MM-DD'), 'Vopsire completa');
INSERT INTO ANGAJATI_AUTOVEHICULE VALUES (102, 5, TO_DATE('2024-01-21', 'YYYY-MM-DD'), 'Revizie generala');
INSERT INTO ANGAJATI_AUTOVEHICULE VALUES (103, 5, TO_DATE('2024-01-22', 'YYYY-MM-DD'), 'Schimb bujii');
INSERT INTO ANGAJATI_AUTOVEHICULE VALUES (102, 6, TO_DATE('2024-02-02', 'YYYY-MM-DD'), 'Schimb distributie');
INSERT INTO ANGAJATI_AUTOVEHICULE VALUES (104, 7, TO_DATE('2024-02-06', 'YYYY-MM-DD'), 'Schimb baterie');
INSERT INTO ANGAJATI_AUTOVEHICULE VALUES (102, 8, TO_DATE('2024-02-11', 'YYYY-MM-DD'), 'Revizie ulei');
INSERT INTO ANGAJATI_AUTOVEHICULE VALUES (103, 9, TO_DATE('2024-02-15', 'YYYY-MM-DD'), 'Schimb filtre');
INSERT INTO ANGAJATI_AUTOVEHICULE VALUES (102, 10, TO_DATE('2024-02-21', 'YYYY-MM-DD'), 'Schimb amortizoare');
INSERT INTO ANGAJATI_AUTOVEHICULE VALUES (109, 1, TO_DATE('2024-01-03', 'YYYY-MM-DD'), 'Curatare motor');
INSERT INTO ANGAJATI_AUTOVEHICULE VALUES (109, 3, TO_DATE('2024-01-13', 'YYYY-MM-DD'), 'Asistenta mecanic junior');
INSERT INTO ANGAJATI_AUTOVEHICULE VALUES (104, 10, TO_DATE('2024-02-22', 'YYYY-MM-DD'), 'Testare senzori');
INSERT INTO ANGAJATI_AUTOVEHICULE VALUES (103, 7, TO_DATE('2024-02-07', 'YYYY-MM-DD'), 'Verificare mecanica');
INSERT INTO ANGAJATI_AUTOVEHICULE VALUES (105, 10, TO_DATE('2024-02-23', 'YYYY-MM-DD'), 'Verificare caroserie');
INSERT INTO ANGAJATI_AUTOVEHICULE VALUES (106, 7, TO_DATE('2024-02-08', 'YYYY-MM-DD'), 'Retus vopsea');
INSERT INTO ANGAJATI_AUTOVEHICULE VALUES (104, 6, TO_DATE('2024-02-03', 'YYYY-MM-DD'), 'Resetare computer bord');

-- 9. AUTOVEHICULE_PIESE
INSERT INTO AUTOVEHICULE_PIESE VALUES (1, 1, 1);
INSERT INTO AUTOVEHICULE_PIESE VALUES (1, 2, 5);
INSERT INTO AUTOVEHICULE_PIESE VALUES (1, 10, 1);
INSERT INTO AUTOVEHICULE_PIESE VALUES (3, 3, 2);
INSERT INTO AUTOVEHICULE_PIESE VALUES (5, 1, 1);
INSERT INTO AUTOVEHICULE_PIESE VALUES (5, 2, 6);
INSERT INTO AUTOVEHICULE_PIESE VALUES (5, 9, 4);
INSERT INTO AUTOVEHICULE_PIESE VALUES (6, 6, 1);
INSERT INTO AUTOVEHICULE_PIESE VALUES (7, 4, 1);
INSERT INTO AUTOVEHICULE_PIESE VALUES (8, 1, 1);
INSERT INTO AUTOVEHICULE_PIESE VALUES (8, 2, 4);
INSERT INTO AUTOVEHICULE_PIESE VALUES (9, 10, 1);
INSERT INTO AUTOVEHICULE_PIESE VALUES (10, 7, 2);
INSERT INTO AUTOVEHICULE_PIESE VALUES (2, 5, 2);
INSERT INTO AUTOVEHICULE_PIESE VALUES (4, 8, 3);
INSERT INTO AUTOVEHICULE_PIESE VALUES (6, 2, 7);
INSERT INTO AUTOVEHICULE_PIESE VALUES (7, 5, 1);
INSERT INTO AUTOVEHICULE_PIESE VALUES (3, 2, 4);
INSERT INTO AUTOVEHICULE_PIESE VALUES (10, 8, 2);
INSERT INTO AUTOVEHICULE_PIESE VALUES (5, 5, 4);


COMMIT;

--Capitolul 3 
--f)
-- 1. Vizualizare Compusă (permite LMD)
CREATE OR REPLACE VIEW V_PIESE_STOC AS
SELECT id_piesa, denumire_piesa, stoc_disponibil
FROM PIESE
WHERE stoc_disponibil < 20;

-- 2. Vizualizare Complexă 
CREATE OR REPLACE VIEW V_TOP_REPARATII AS
SELECT numar_inmatriculare, pret_reparatie,
       RANK() OVER (ORDER BY pret_reparatie DESC) as clasament
FROM AUTOVEHICULE;











