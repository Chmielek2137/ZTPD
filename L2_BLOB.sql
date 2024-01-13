--1
CREATE TABLE MOVIES AS SELECT * FROM ZTPD.MOVIES;

--3
SELECT ID, TITLE FROM movies WHERE cover IS NULL;

--4
SELECT ID, TITLE, dbms_lob.getlength(cover) as FILESIZE FROM movies WHERE cover IS NOT NULL;

--5
SELECT ID, TITLE, dbms_lob.getlength(cover) as FILESIZE FROM movies WHERE cover IS NULL;
--zwrócona zostanie wartość null

--6
SELECT DIRECTORY_NAME, DIRECTORY_PATH FROM ALL_DIRECTORIES WHERE directory_name = 'TPD_DIR';

--7
UPDATE movies SET cover = EMPTY_BLOB(), mime_type = 'image/jpeg' where id = 66;

--8
SELECT ID, TITLE, dbms_lob.getlength(cover) as FILESIZE FROM movies WHERE id in (65,66);

--9
DECLARE
    lobd blob;
    fils BFILE := BFILENAME('TPD_DIR','escape.jpg');
BEGIN
    SELECT cover INTO lobd 
    FROM movies 
    where id=66
    FOR UPDATE;
    
    DBMS_LOB.fileopen(fils, DBMS_LOB.file_readonly); 
    DBMS_LOB.LOADFROMFILE(lobd,fils,DBMS_LOB.GETLENGTH(fils)); 
    DBMS_LOB.FILECLOSE(fils);
    COMMIT;
END;

--10
CREATE TABLE TEMP_COVERS (
    movie_id NUMBER(12),
    image BFILE,
    mime_type VARCHAR2(50) 
);

--11
DECLARE
    lobd blob;
    fils BFILE := BFILENAME('TPD_DIR','eagles.jpg');
BEGIN
	INSERT INTO TEMP_COVERS
	VALUES(65, fils, 'image/jpeg');
	commit;
END;

--12
SELECT movie_id, dbms_lob.getlength(image) as FILESIZE FROM temp_covers WHERE movie_id = 65;

--13
DECLARE
	fils BFILE;
	mime_t VARCHAR2(50);
	tmpblob BLOB;
BEGIN
	SELECT image, mime_type
	INTO fils, mime_t
	FROM TEMP_COVERS
	WHERE movie_id = 65;
	
	dbms_lob.createtemporary(tmpblob, TRUE);  
	
	DBMS_LOB.fileopen(fils, DBMS_LOB.file_readonly); 
	DBMS_LOB.LOADFROMFILE(tmpblob,fils,DBMS_LOB.GETLENGTH(fils)); 
	DBMS_LOB.FILECLOSE(fils);
	
	UPDATE movies
	SET cover = tmpblob, mime_type = mime_t
	where id = 65;

	dbms_lob.freetemporary(tmpblob); 
	COMMIT;
	
END;

--14
SELECT id, mime_type, dbms_lob.getlength(cover) as FILESIZE FROM movies WHERE id in (65,66);

--15
DROP TABLE movies;