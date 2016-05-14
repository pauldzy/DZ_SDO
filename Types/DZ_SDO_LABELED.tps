CREATE OR REPLACE TYPE dz_sdo_labeled FORCE
AUTHID CURRENT_USER
AS OBJECT (
    shape_label         VARCHAR2(4000 Char)
   ,shape               MDSYS.SDO_GEOMETRY
    
   ,CONSTRUCTOR FUNCTION dz_sdo_labeled
    RETURN SELF AS RESULT

);
/

GRANT EXECUTE ON dz_sdo_labeled TO public;

