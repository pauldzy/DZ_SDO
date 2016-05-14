CREATE OR REPLACE TYPE dz_sdo_labeled_list FORCE                 
AS 
TABLE OF dz_sdo_labeled;
/

GRANT EXECUTE ON dz_sdo_labeled_list TO public;

