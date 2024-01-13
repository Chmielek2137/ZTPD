set serveroutput on size 30000;

--1
CREATE TYPE samochod AS OBJECT (
    marka VARCHAR2(20),
    model VARCHAR2(20),
    kilometry NUMBER,
    data_produkcji DATE,
    cena NUMBER(10,2)
);

desc samochod;

create table samochody of samochod;

INSERT INTO samochody VALUES (NEW samochod('Volkswagen', 'Passat', '999999', TO_DATE('17/12/1999', 'DD/MM/YYYY'), 5000));
INSERT INTO samochody VALUES (NEW samochod('Opel', 'Astra', '500000', date '1992-04-06', 2500));
INSERT INTO samochody VALUES (NEW samochod('Fiat', 'Cinquecento', '382145', date '1997-12-22', 3500));

--2
CREATE TYPE wlasciciel AS OBJECT (
    imie VARCHAR2(100),
    nazwisko VARCHAR2(100),
    auto samochod
)

create table wlasciciele of wlasciciel;

INSERT INTO wlasciciele VALUES (new wlasciciel('JAN', 'KOWALSKI', NEW samochod('FORD', 'MONDEO', '80000', date '2002-02-12', 55000)));
INSERT INTO wlasciciele VALUES (new wlasciciel('ADAM', 'NOWAK', NEW samochod('SKODA', 'FABIA', '180000', date '2015-02-12', 82000)));

--3
ALTER TYPE samochod REPLACE AS OBJECT (
    marka VARCHAR2(20),
    model VARCHAR2(20),
    kilometry NUMBER,
    data_produkcji DATE,
    cena NUMBER(10,2),
    MEMBER FUNCTION wartosc RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY samochod AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
    BEGIN
        RETURN floor(cena * power(0.9, EXTRACT (YEAR FROM CURRENT_DATE) - EXTRACT (YEAR FROM data_produkcji)));
    END wartosc;
END;

--4
ALTER TYPE samochod ADD MAP MEMBER FUNCTION odwzoruj 
RETURN NUMBER CASCADE INCLUDING TABLE DATA;

CREATE OR REPLACE TYPE BODY samochod AS
    MEMBER FUNCTION wartosc RETURN NUMBER IS
    BEGIN
        RETURN floor(cena * power(0.9, EXTRACT (YEAR FROM CURRENT_DATE) - EXTRACT (YEAR FROM data_produkcji)));
    END wartosc;
	
	MAP MEMBER FUNCTION odwzoruj RETURN NUMBER IS  
	BEGIN 
		RETURN TRUNC(kilometry/10000) + EXTRACT (YEAR FROM data_produkcji);
	END odwzoruj; 
END;

--5
--Miałem już typ właściciel bo myślałem że wcześniej powinien być żeby stworzyć tablicę 
CREATE TYPE wlasciciel2 AS OBJECT (
    imie VARCHAR2(100),
    nazwisko VARCHAR2(100)
)

ALTER TYPE samochod 
ADD ATTRIBUTE (wlasciciel REF wlasciciel2) CASCADE;

create table wlasciciele2 of wlasciciel2;

INSERT INTO wlasciciele2 VALUES (new wlasciciel2('JANUSZ', 'NOSACZ'));
INSERT INTO wlasciciele2 VALUES (new wlasciciel2('PATRYK', 'CHMIELECKI'));

UPDATE samochody s
SET s.wlasciciel = (
	SELECT REF(w) FROM wlasciciele2 w
	WHERE w.imie = 'JANUSZ')
WHERE s.model = 'Passat';

UPDATE samochody s
SET s.wlasciciel = (
	SELECT REF(w) FROM wlasciciele2 w
	WHERE w.imie = 'PATRYK')
WHERE s.model = 'Astra';

--7
DECLARE
	TYPE t_books is VARRAY(15) OF VARCHAR2(25);
	my_books t_books := t_books('');
BEGIN
	my_books(1) := 'Limes inferior';
	my_books.EXTEND(11);
	
	FOR i IN 2..12 LOOP
		my_books(i) := 'BOOK_' || i;
	END LOOP;
	
	FOR i IN my_books.FIRST()..my_books.LAST() LOOP
		DBMS_OUTPUT.PUT_LINE(my_books(i));
	END LOOP;
	
	my_books.TRIM(3);
	
	FOR i IN my_books.FIRST()..my_books.LAST() LOOP
		DBMS_OUTPUT.PUT_LINE(my_books(i));
	END LOOP;
	
	DBMS_OUTPUT.PUT_LINE('Limit: ' || my_books.LIMIT()); 
	DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || my_books.COUNT());
	
	my_books.DELETE(); 

	DBMS_OUTPUT.PUT_LINE('Limit: ' || my_books.LIMIT()); 
	DBMS_OUTPUT.PUT_LINE('Liczba elementow: ' || my_books.COUNT());
END;

--9
DECLARE
	TYPE t_miesiace IS TABLE OF VARCHAR2(20);
	moje_miesiace t_miesiace := t_miesiace();
BEGIN
	moje_miesiace.EXTEND(4);
	moje_miesiace(1) := 'STYCZEŃ';
	moje_miesiace(2) := 'LUTY';
	moje_miesiace(3) := 'MARZEC';
	moje_miesiace(4) := 'KWIECIEN';
	
	moje_miesiace.EXTEND(8);
	
	FOR i IN 5..12 LOOP 
		moje_miesiace(i) := 'MIESIAC_' || i; 
	END LOOP;
	
	FOR i IN moje_miesiace.FIRST()..moje_miesiace.LAST() LOOP 
		DBMS_OUTPUT.PUT_LINE(moje_miesiace(i)); 
	END LOOP;
END;

--11
CREATE TYPE KOSZYK_PRODUKTOW AS TABLE OF VARCHAR2(20); 
 
CREATE TYPE ZAKUP AS OBJECT ( 
  id_zakupu NUMBER, 
  produkty KOSZYK_PRODUKTOW ); 
 
CREATE TABLE zakupy OF ZAKUP 
NESTED TABLE produkty STORE AS tab_produkty; 

INSERT INTO zakupy VALUES
(ZAKUP(1, KOSZYK_PRODUKTOW('Pieluszki', 'Piwo')));
INSERT INTO zakupy VALUES
(ZAKUP(2, KOSZYK_PRODUKTOW('Orzeszki', 'Piwo')));
INSERT INTO zakupy VALUES
(ZAKUP(3, KOSZYK_PRODUKTOW('Cola', 'Chleb')));
INSERT INTO zakupy VALUES
(ZAKUP(4, KOSZYK_PRODUKTOW('Orzeszki', 'Cola')));

SELECT z.id_zakupu, p.*
FROM zakupy z, TABLE(z.produkty) p
WHERE p.column_value = 'Chleb';

SELECT p.*
FROM zakupy z, TABLE(z.produkty) p;

SELECT * FROM TABLE(SELECT z.produkty FROM zakupy z WHERE id_zakupu =2);

INSERT INTO TABLE (SELECT z.produkty FROM zakupy z WHERE id_zakupu =4)
VALUES ('Chleb');

DELETE FROM zakupy z
WHERE z.id_zakupu in (SELECT z.id_zakupu
    FROM zakupy z, TABLE(z.produkty) p
    WHERE p.column_value = 'Chleb');
	
--14
DECLARE 
  tamburyn instrument;   
  cymbalki instrument; 
  trabka instrument; 
  saksofon instrument_dety; 
BEGIN 
  tamburyn := instrument('tamburyn','brzdek-brzdek'); 
  cymbalki := instrument_dety('cymbalki','ding-ding','metalowe'); 
  trabka   := instrument_dety('trabka','tra-ta-ta','metalowa');
  DBMS_OUTPUT.PUT_LINE( trabka.graj() );
  --saksofon := instrument('saksofon','tra-taaaa'); -- nie zadziała
  --saksofon := TREAT( instrument('saksofon','tra-taaaa') AS instrument_dety); -- nie zadziała
END; 







--22
CREATE TYPE KSIAZKI_TAB AS TABLE OF VARCHAR2(30);

CREATE TYPE PISARZ AS OBJECT ( 
  id_pisarza NUMBER, 
  nazwisko VARCHAR2(30), 
  data_ur DATE,
  ksiazki KSIAZKI_TAB,
  MEMBER FUNCTION ile_ksiazek RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY PISARZ AS
	MEMBER FUNCTION ile_ksiazek RETURN NUMBER IS
	BEGIN
		RETURN ksiazki.COUNT();
	END ile_ksiazek;
END;


CREATE TYPE KSIAZKA AS OBJECT ( 
  id_ksiazki NUMBER, 
  autor REF PISARZ,
  tytul VARCHAR2(30), 
  data_wyd DATE,
  MEMBER FUNCTION jaki_wiek RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY KSIAZKA AS
	MEMBER FUNCTION jaki_wiek RETURN NUMBER IS
	BEGIN
		RETURN EXTRACT (YEAR FROM CURRENT_DATE) - EXTRACT (YEAR FROM data_wyd);
	END jaki_wiek;
END;


CREATE OR REPLACE VIEW PISARZE_V OF PISARZ
WITH OBJECT IDENTIFIER (id_pisarza)
AS SELECT id_pisarza, nazwisko, data_ur, 
CAST(MULTISET( SELECT TYTUL FROM KSIAZKI WHERE id_pisarza=P.id_pisarza ) AS 
KSIAZKI_TAB )
FROM PISARZE P;



CREATE OR REPLACE VIEW KSIAZKI_V OF KSIAZKA
WITH OBJECT IDENTIFIER (id_ksiazki)
AS SELECT ID_KSIAZKI, MAKE_REF(PISARZE_V, id_pisarza), TYTUL, DATA_WYDANIE
from KSIAZKI;

SELECT * FROM PISARZE_V;
SELECT p.nazwisko, p.ile_ksiazek() FROM PISARZE_V p;
SELECT * FROM KSIAZKI_V;
SELECT k.tytul, k.jaki_wiek() FROM KSIAZKI_V k;

--23

CREATE TYPE AUTO AS OBJECT ( 
  MARKA VARCHAR2(20), 
  MODEL VARCHAR2(20), 
  KILOMETRY NUMBER, 
  DATA_PRODUKCJI DATE, 
  CENA NUMBER(10,2), 
  MEMBER FUNCTION WARTOSC RETURN NUMBER 
); 

ALTER TYPE AUTO NOT FINAL CASCADE;

CREATE OR REPLACE TYPE BODY AUTO AS 
  MEMBER FUNCTION WARTOSC RETURN NUMBER IS 
    WIEK NUMBER; 
    WARTOSC NUMBER; 
  BEGIN 
    WIEK := ROUND(MONTHS_BETWEEN(SYSDATE,DATA_PRODUKCJI)/12); 
    WARTOSC := CENA - (WIEK * 0.1 * CENA); 
    IF (WARTOSC < 0) THEN 
      WARTOSC := 0; 
    END IF; 
    RETURN WARTOSC; 
  END WARTOSC; 
END; 
 
CREATE TABLE AUTA OF AUTO; 
 
INSERT INTO AUTA VALUES (AUTO('FIAT','BRAVA',60000,DATE '1999-11-30',25000)); 
INSERT INTO AUTA VALUES (AUTO('FORD','MONDEO',80000,DATE '1997-05-10',45000)); 
INSERT INTO AUTA VALUES (AUTO('MAZDA','123',12000,DATE '2020-09-22',52000));  


CREATE TYPE AUTO_OSOBOWE UNDER AUTO (
	LICZBA_MIEJSC NUMBER,
	KLIMATYZACJA NUMBER(1),
	OVERRIDING MEMBER FUNCTION WARTOSC RETURN NUMBER
);

CREATE TYPE AUTO_CIEZAROWE UNDER AUTO (
	LADOWNOSC NUMBER,
	OVERRIDING MEMBER FUNCTION WARTOSC RETURN NUMBER
);

CREATE OR REPLACE TYPE BODY AUTO_OSOBOWE AS 
  OVERRIDING MEMBER FUNCTION WARTOSC RETURN NUMBER IS 
	WARTOSC NUMBER;
  BEGIN 
	WARTOSC := (SELF AS AUTO).WARTOSC();
	IF (KLIMATYZACJA == 1) THEN 
		WARTOSC := WARTOSC * 1.5;
	END IF;
	RETURN WARTOSC;
  END; 
END; 

CREATE OR REPLACE TYPE BODY AUTO_CIEZAROWE AS 
  OVERRIDING MEMBER FUNCTION WARTOSC RETURN NUMBER IS 
	WARTOSC NUMBER;
  BEGIN 
	WARTOSC := (SELF AS AUTO).WARTOSC();
	IF (LADOWNOSC >= 10) THEN 
		WARTOSC := WARTOSC * 2;
	END IF;
	RETURN WARTOSC;
  END; 
END; 


INSERT INTO AUTA VALUES (AUTO_OSOBOWE('OS_1','model1',60000,DATE '2018-11-30',25000, 4, 1)); 
INSERT INTO AUTA VALUES (AUTO_OSOBOWE('OS_2','model2',35000,DATE '2020-11-30',50000, 4, 0)); 
INSERT INTO AUTA VALUES (AUTO_CIEZAROWE('CIEZ_1','model3',100000,DATE '2017-05-10',90000, 8)); 
INSERT INTO AUTA VALUES (AUTO_CIEZAROWE('CIEZ_2','model4',120000,DATE '2022-05-10',120000, 12)); 

select a.marka, a.wartosc() from auta a;





