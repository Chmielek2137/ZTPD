--1
--A
CREATE TABLE A6_LRS (
	GEOM SDO_GEOMETRY
);

--B
INSERT INTO a6_lrs
SELECT s.geom
FROM streets_and_railroads s, major_cities c
WHERE sdo_geom.sdo_distance(s.geom, c.geom, 0.001, 'unit=km') <= 10
AND c.city_name = 'Koszalin';

--C
SELECT sdo_geom.sdo_length(geom, 0.001, 'unit=km') distance, st_linestring(geom).st_numpoints() st_numpoionts
FROM a6_lrs;

--D
UPDATE a6_lrs 
SET geom = SDO_LRS.CONVERT_TO_LRS_GEOM(GEOM, 0, 276.681);

--E
INSERT INTO USER_SDO_GEOM_METADATA 
VALUES ('A6_LRS','GEOM', 
MDSYS.SDO_DIM_ARRAY( 
  MDSYS.SDO_DIM_ELEMENT('X', 12.603676, 26.369824, 1), 
  MDSYS.SDO_DIM_ELEMENT('Y', 45.8464, 58.0213, 1), 
  MDSYS.SDO_DIM_ELEMENT('M', 0, 300, 1) ), 
  8307); 
  
--F
CREATE INDEX a6_lrs_idx ON a6_lrs(geom) INDEXTYPE IS MDSYS.SPATIAL_INDEX;

--2
--A
select SDO_LRS.VALID_MEASURE(GEOM, 500) VALID_500
from   A6_LRS; 

--B
SELECT SDO_LRS.GEOM_SEGMENT_END_PT(GEOM) END_PT
from   A6_LRS; 

--C
select SDO_LRS.LOCATE_PT(GEOM, 150, 0) KM150 from A6_LRS; 

--D
select SDO_LRS.CLIP_GEOM_SEGMENT(GEOM, 120, 160) CLIPED from A6_LRS;

--E
select SDO_LRS.PROJECT_PT(A6.GEOM, C.GEOM) WJAZD_NA_A6 
from   A6_LRS A6, MAJOR_CITIES C where  C.CITY_NAME = 'Slupsk'; 

--F
SELECT sdo_geom.sdo_length(
		sdo_lrs.offset_geom_segment(a6.geom, m.diminfo, 50, 200, 50, 'unit=m arc_tolerance=1'), 
	1, 'unit=km') KOSZT
FROM a6_lrs a6, user_sdo_geom_metadata m 
WHERE m.table_name = 'A6_LRS' 
AND m.column_name = 'GEOM' 


