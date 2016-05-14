CREATE OR REPLACE PACKAGE dz_sdo_geodetic
AUTHID CURRENT_USER
AS
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION dz_project_pt(
       p_geom_segment  IN  MDSYS.SDO_GEOMETRY
      ,p_point         IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance     IN  NUMBER DEFAULT 0.00000001
   ) RETURN MDSYS.SDO_GEOMETRY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION dz_relate(
       p_geom1 IN  MDSYS.SDO_GEOMETRY
      ,p_mask  IN  VARCHAR2
      ,p_geom2 IN  MDSYS.SDO_GEOMETRY
      ,p_tol   IN  NUMBER
   ) RETURN VARCHAR2;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION dz_desparate_intersection(
       p_geom1    IN  MDSYS.SDO_GEOMETRY
      ,p_geom2    IN  MDSYS.SDO_GEOMETRY
      ,p_tol1     IN  NUMBER
      ,p_tol2     IN  NUMBER
      ,p_tol3     IN  NUMBER
      ,p_alt_srid IN  NUMBER
   ) RETURN MDSYS.SDO_GEOMETRY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION dz_srid_intersection(
       p_geom1    IN  MDSYS.SDO_GEOMETRY
      ,p_geom2    IN  MDSYS.SDO_GEOMETRY
      ,p_tol      IN  NUMBER
      ,p_srid     IN  NUMBER
   ) RETURN MDSYS.SDO_GEOMETRY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION dz_desparate_relate(
       p_geom1    IN  MDSYS.SDO_GEOMETRY
      ,p_geom2    IN  MDSYS.SDO_GEOMETRY
      ,p_tol      IN  NUMBER
      ,p_alt_srid IN  NUMBER
   ) RETURN VARCHAR2;
   
END dz_sdo_geodetic;
/

GRANT EXECUTE ON dz_sdo_geodetic TO PUBLIC;

