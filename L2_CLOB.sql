--1
CREATE TABLE dokumenty (
	id NUMBER(12) PRIMARY KEY,
	dokument CLOB
);

--2
DECLARE
	rep_num NUMBER := 10000;
	rep_txt VARCHAR(15) := 'Oto tekst. ';
	txtlob CLOB;
BEGIN
	FOR i IN 1 .. rep_num
	LOOP 
		txtlob := concat(txtlob, rep_txt);
	END LOOP;
	
	INSERT INTO dokumenty
	VALUES (1, txtlob);
END;

--3
select * from dokumenty;

select id, UPPER(dokument) from dokumenty;

select id, LENGTH(dokument) from dokumenty;

select id, DBMS_LOB.GETLENGTH(dokument) from dokumenty;

select id, SUBSTR(dokument, 5, 1000) from dokumenty;

select id, DBMS_LOB.SUBSTR(dokument, 1000, 5) from dokumenty;

--4
INSERT INTO dokumenty
VALUES (2, CLOB_EMPTY());

--5
INSERT INTO dokumenty
VALUES (3, NULL);
COMMIT;

--7
DECLARE 
	lobd CLOB;
	fils BFILE := BFILENAME('TPD_DIR','dokument.txt');
	dest_offset INTEGER := 1;
	src_offset INTEGER := 1;
	bfile_csid NUMBER := 0;
	lang_context INTEGER := 0;
	warning INTEGER := null;
BEGIN
	SELECT dokument INTO lobd 
    FROM dokumenty 
    where id = 2
    FOR UPDATE;
	
	DBMS_LOB.fileopen(fils, DBMS_LOB.file_readonly); 
    DBMS_LOB.LOADCLOBFROMFILE(lobd,fils,DBMS_LOB.GETLENGTH(fils), dest_offset, src_offset, bfile_csid, lang_context, warning); 
    DBMS_LOB.FILECLOSE(fils);
	COMMIT;
END;

--8
UPDATE dokumenty
SET dokument = TO_CLOB(BFILENAME('TPD_DIR','dokument.txt'))
WHERE id = 3;

--9
select * from dokumenty;

--10
select id, DBMS_LOB.GETLENGTH(dokument) from dokumenty;

--11
DROP TABLE dokumenty;

--12
CREATE OR REPLACE PROCEDURE clob_censor (cl in out CLOB, txt_to_replace VARCHAR2) 
IS
	dots VARCHAR(100);
	txt_len INTEGER := LENGTH(txt_to_replace);
	pos INTEGER := 1;
BEGIN
	dots := RPAD('.', 10, '.');
	
	WHILE NOT pos = 0 LOOP
		pos := DBMS_LOB.INSTR(cl, txt_to_replace, 1, 1);
		
		IF pos > 0 THEN
			dbms_lob.write(cl, txt_len, pos, dots);
		END IF;
	END LOOP;
END clob_censor;

--13
CREATE TABLE biographies AS
SELECT * FROM ZTPD.biographies;

DECLARE
    cl CLOB;
BEGIN
    SELECT bio
    INTO cl
    FROM biographies
    WHERE id = 1
    FOR UPDATE;
    
    clob_censor(cl, 'Cimrman');
	
	COMMIT;
END;

SELECT * FROM biographies;

--14
DROP TABLE BIOGRAPHIES;