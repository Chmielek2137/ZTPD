--1
--A
select lpad('-',2*(level-1),'|-') || t.owner||'.'||t.type_name||' (FINAL:'||t.final|| 
', INSTANTIABLE:'||t.instantiable||', ATTRIBUTES:'||t.attributes||', METHODS:'||t.methods||')' 
from   all_types t 
start with t.type_name = 'ST_GEOMETRY' 
connect by prior t.type_name = t.supertype_name  
       and prior t.owner = t.owner;

--B
select distinct m.method_name 
from   all_type_methods m 
where  m.type_name like 'ST_POLYGON' 
and    m.owner = 'MDSYS' 
order by 1;

--C
CREATE TABLE MYST_MAJOR_CITIES (
    FIPS_CNTRY VARCHAR2(2),
    CITY_NAME VARCHAR2(40),
    STGEOM ST_POINT
);

--D
INSERT INTO myst_major_cities (fips_cntry, city_name, stgeom)
SELECT fips_cntry, city_name, st_point(geom)
FROM ZTPD.MAJOR_CITIES;

--2
INSERT INTO myst_major_cities (fips_cntry, city_name, stgeom)
VALUES ('PL', 'Szczyrk', new st_point(19.036107, 49.718655, 8307));

--3
--A
CREATE TABLE MYST_COUNTRY_BOUNDARIES (
    FIPS_CNTRY VARCHAR2(2),
    CNTRY_NAME VARCHAR2(40),
    STGEOM ST_MULTIPOLYGON
);

--B
INSERT INTO myst_country_boundaries (fips_cntry, cntry_name, stgeom)
SELECT fips_cntry, cntry_name, st_multipolygon(geom)
FROM ZTPD.COUNTRY_BOUNDARIES;

--C
SELECT b.stgeom.st_geometrytype() TYP_OBIEKTU, count(*) as ILE
FROM myst_country_boundaries b
group by b.stgeom.st_geometrytype();

--D
SELECT b.stgeom.st_issimple() TYP_OBIEKTU
FROM myst_country_boundaries b;

--4
--A
SELECT b.cntry_name, count(*)
FROM myst_country_boundaries b, myst_major_cities c
WHERE b.stgeom.st_contains(c.stgeom)= 1
GROUP BY b.cntry_name;

--B
SELECT ca.cntry_name, cb.cntry_name
FROM myst_country_boundaries ca, myst_country_boundaries cb
WHERE cb.cntry_name = 'Czech Republic'
AND ca.stgeom.st_touches(cb.stgeom) = 1;

--C
SELECT distinct c.cntry_name, r.name
FROM myst_country_boundaries c, rivers r
WHERE c.cntry_name = 'Czech Republic'
AND c.stgeom.st_intersects(new st_linestring(r.geom)) = 1

--D
select treat(A.STGEOM.ST_UNION(B.STGEOM) as st_polygon).st_area() CZECHOSLOWACJA 
from   MYST_COUNTRY_BOUNDARIES A, MYST_COUNTRY_BOUNDARIES B 
where  A.CNTRY_NAME = 'Czech Republic' 
and    B.CNTRY_NAME = 'Slovakia';

--E
SELECT c.stgeom.st_geometrytype() as OBIEKT, c.stgeom.st_difference(st_geometry(w.GEOM)).st_geometrytype() as WEGRY_BEZ
FROM myst_country_boundaries c, water_bodies w
WHERE c.cntry_name = 'Hungary'
AND w.name = 'Balaton';

--5
--A
EXPLAIN PLAN FOR
SELECT b.cntry_name, count(*)
FROM myst_country_boundaries b, myst_major_cities c
WHERE SDO_WITHIN_DISTANCE(b.stgeom, c.stgeom, 'distance=100 unit=km') = 'TRUE'
AND b.cntry_name = 'Poland'
GROUP BY b.cntry_name;

select plan_table_output from table(dbms_xplan.display('plan_table',null,'basic'));

--B
insert into USER_SDO_GEOM_METADATA 
select 'MYST_MAJOR_CITIES', 'STGEOM',  
	 T.DIMINFO, T.SRID 
from   ALL_SDO_GEOM_METADATA T 
where  T.TABLE_NAME = 'MAJOR_CITIES';
  
insert into USER_SDO_GEOM_METADATA 
select 'MYST_COUNTRY_BOUNDARIES', 'STGEOM',  
	 T.DIMINFO, T.SRID 
from   ALL_SDO_GEOM_METADATA T 
where  T.TABLE_NAME = 'COUNTRY_BOUNDARIES';

--C
create index MYST_MAJOR_CITIES_IDX on 
       MYST_MAJOR_CITIES(STGEOM) 
indextype IS MDSYS.SPATIAL_INDEX; 

create index MYST_COUNTRY_BOUNDARIES_IDX on 
       MYST_COUNTRY_BOUNDARIES(STGEOM) 
indextype IS MDSYS.SPATIAL_INDEX; 

--D
EXPLAIN PLAN FOR
SELECT b.cntry_name, count(*)
FROM myst_country_boundaries b, myst_major_cities c
WHERE SDO_WITHIN_DISTANCE(b.stgeom, c.stgeom, 'distance=100 unit=km') = 'TRUE'
AND b.cntry_name = 'Poland'
GROUP BY b.cntry_name;

select plan_table_output from table(dbms_xplan.display('plan_table',null,'basic'));