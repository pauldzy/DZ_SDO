CREATE OR REPLACE PACKAGE BODY dz_sdo_geodetic
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION dz_project_pt(
       p_geom_segment  IN  MDSYS.SDO_GEOMETRY
      ,p_point         IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance     IN  NUMBER DEFAULT 0.00000001
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
       num_srid          NUMBER;
       num_tolerance     NUMBER := p_tolerance;
       num_thresh_meters NUMBER := 0.05;
       num_distance_tol  NUMBER := 0.00000001;
       num_distance      NUMBER;
       sdo_geom_segment  MDSYS.SDO_GEOMETRY;
       sdo_point_input   MDSYS.SDO_GEOMETRY;
       sdo_output        MDSYS.SDO_GEOMETRY;
       
   BEGIN
   
      IF p_geom_segment IS NULL
      OR p_point IS NULL
      THEN
         RETURN NULL;
         
      END IF;
      
      IF num_tolerance IS NULL
      THEN
         num_tolerance := 0.00000001;
         
      END IF;
      
      num_srid := p_geom_segment.SDO_SRID;
      
      IF num_srid NOT IN (8265,4269,8307,4326)
      THEN
         RETURN MDSYS.SDO_LRS.PROJECT_PT(
             geom_segment => p_geom_segment
            ,point        => p_point
            ,tolerance    => num_tolerance
         );
      
      END IF;
      
      num_distance := MDSYS.SDO_GEOM.SDO_DISTANCE(
          geom1   => p_geom_segment
         ,geom2   => p_point
         ,tol     => num_distance_tol
         ,unit    => 'UNIT=M'
      );
      --dbms_output.put_line(num_distance);
      
      IF num_distance > num_thresh_meters
      THEN
         RETURN MDSYS.SDO_LRS.PROJECT_PT(
             geom_segment => p_geom_segment
            ,point        => p_point
            ,tolerance    => num_tolerance
         );
      
      END IF;
      
      sdo_geom_segment := p_geom_segment;
      sdo_geom_segment.SDO_SRID := NULL;
      
      sdo_point_input  := p_point;
      sdo_point_input.SDO_SRID := NULL;
      
      sdo_output := MDSYS.SDO_LRS.PROJECT_PT(
          geom_segment => sdo_geom_segment
         ,point        => sdo_point_input
         ,tolerance    => num_tolerance
      );
      
      sdo_output.SDO_SRID := num_srid;
      
      RETURN sdo_output;
   
   END dz_project_pt;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION dz_relate(
       p_geom1 IN  MDSYS.SDO_GEOMETRY
      ,p_mask  IN  VARCHAR2
      ,p_geom2 IN  MDSYS.SDO_GEOMETRY
      ,p_tol   IN  NUMBER
   ) RETURN VARCHAR2
   AS
      num_srid          NUMBER;
      sdo_geom1         MDSYS.SDO_GEOMETRY;
      sdo_geom2         MDSYS.SDO_GEOMETRY;
      num_distance      NUMBER;
      num_thresh_meters NUMBER := 0.05;
      
   BEGIN
   
      IF p_geom1 IS NULL
      OR p_geom2 IS NULL
      THEN
         RETURN NULL;
         
      END IF;
      
      num_srid := p_geom1.SDO_SRID;
      
      IF num_srid NOT IN (8265,4269,8307,4326)
      THEN
         RETURN MDSYS.SDO_GEOM.RELATE(
             geom1    => p_geom1
            ,mask     => p_mask
            ,geom2    => p_geom2
            ,tol      => p_tol
         );
      
      END IF;
      
      num_distance := MDSYS.SDO_GEOM.SDO_DISTANCE(
          geom1   => p_geom1
         ,geom2   => p_geom2
         ,tol     => p_tol
         ,unit    => 'UNIT=M'
      );
      
      IF num_distance > num_thresh_meters
      THEN
         RETURN MDSYS.SDO_GEOM.RELATE(
             geom1    => p_geom1
            ,mask     => p_mask
            ,geom2    => p_geom2
            ,tol      => p_tol
         );
      
      END IF;
      
      sdo_geom1 := p_geom1;
      sdo_geom1.SDO_SRID := NULL;
      
      sdo_geom2 := p_geom2;
      sdo_geom2.SDO_SRID := NULL;
      
      RETURN MDSYS.SDO_GEOM.RELATE(
          geom1    => sdo_geom1
         ,mask     => p_mask
         ,geom2    => sdo_geom2
         ,tol      => p_tol
      );
      
   END dz_relate;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION dz_desparate_intersection(
       p_geom1    IN  MDSYS.SDO_GEOMETRY
      ,p_geom2    IN  MDSYS.SDO_GEOMETRY
      ,p_tol1     IN  NUMBER
      ,p_tol2     IN  NUMBER
      ,p_tol3     IN  NUMBER
      ,p_alt_srid IN  NUMBER
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      sdo_output  MDSYS.SDO_GEOMETRY;
      sdo_input1  MDSYS.SDO_GEOMETRY;
      sdo_input2  MDSYS.SDO_GEOMETRY;
      num_srid    NUMBER;
      
   BEGIN
   
      sdo_output := dz_sdo_util.scrub_polygons(
         MDSYS.SDO_GEOM.SDO_INTERSECTION(
             geom1  => p_geom1
            ,geom2  => p_geom2
            ,tol    => p_tol1
         )
      );
      
      IF sdo_output IS NOT NULL
      THEN
         RETURN sdo_output;
       
      END IF;
      
      sdo_output := dz_sdo_util.scrub_polygons(
         MDSYS.SDO_GEOM.SDO_INTERSECTION(
             geom1  => p_geom1
            ,geom2  => p_geom2
            ,tol    => p_tol2
         )
      );
      
      IF sdo_output IS NOT NULL
      THEN
         RETURN sdo_output;
       
      END IF;
      
      sdo_output := dz_sdo_util.scrub_polygons(
         MDSYS.SDO_GEOM.SDO_INTERSECTION(
             geom1  => p_geom1
            ,geom2  => p_geom2
            ,tol    => p_tol3
         )
      );
      
      IF sdo_output IS NOT NULL
      THEN
         RETURN sdo_output;
       
      END IF;
      
      num_srid   := p_geom1.SDO_SRID;
      sdo_input1 := MDSYS.SDO_CS.TRANSFORM(p_geom1,p_alt_srid);
      sdo_input2 := MDSYS.SDO_CS.TRANSFORM(p_geom2,p_alt_srid);
      
      sdo_output := dz_sdo_util.scrub_polygons(
         MDSYS.SDO_GEOM.SDO_INTERSECTION(
             geom1  => sdo_input1
            ,geom2  => sdo_input2
            ,tol    => p_tol1
         )
      );
      
      IF sdo_output IS NOT NULL
      THEN
         sdo_output := MDSYS.SDO_CS.TRANSFORM(sdo_output,num_srid);
      
      END IF;
      
      RETURN sdo_output;

   END dz_desparate_intersection;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION dz_srid_intersection(
       p_geom1    IN  MDSYS.SDO_GEOMETRY
      ,p_geom2    IN  MDSYS.SDO_GEOMETRY
      ,p_tol      IN  NUMBER
      ,p_srid     IN  NUMBER
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      sdo_output  MDSYS.SDO_GEOMETRY;
      sdo_input1  MDSYS.SDO_GEOMETRY;
      sdo_input2  MDSYS.SDO_GEOMETRY;
      num_srid    NUMBER;
      
   BEGIN
   
      num_srid   := p_geom1.SDO_SRID;
      sdo_input1 := MDSYS.SDO_CS.TRANSFORM(p_geom1,p_srid);
      sdo_input2 := MDSYS.SDO_CS.TRANSFORM(p_geom2,p_srid);
      
      sdo_output := dz_sdo_util.scrub_polygons(
         MDSYS.SDO_GEOM.SDO_INTERSECTION(
             geom1  => sdo_input1
            ,geom2  => sdo_input2
            ,tol    => p_tol
         )
      );
      
      IF sdo_output IS NOT NULL
      THEN
         sdo_output := MDSYS.SDO_CS.TRANSFORM(sdo_output,num_srid);
      
      END IF;
      
      RETURN sdo_output;
   
   END dz_srid_intersection;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION dz_desparate_relate(
       p_geom1    IN  MDSYS.SDO_GEOMETRY
      ,p_geom2    IN  MDSYS.SDO_GEOMETRY
      ,p_tol      IN  NUMBER
      ,p_alt_srid IN  NUMBER
   ) RETURN VARCHAR2
   AS
      num_srid   NUMBER;
      str_relate VARCHAR2(255 Char);
      sdo_geom1  MDSYS.SDO_GEOMETRY;
      sdo_geom2  MDSYS.SDO_GEOMETRY;
      
   BEGIN
   
      IF p_geom1 IS NULL
      OR p_geom2 IS NULL
      THEN
         RETURN NULL;
         
      END IF;
      
      str_relate := MDSYS.SDO_GEOM.RELATE(
          geom1 => p_geom1
         ,mask  => 'DETERMINE'
         ,geom2 => p_geom2
         ,tol   => p_tol
      );
      
      IF str_relate NOT IN ('TOUCH','DISJOINT')
      THEN
         RETURN str_relate;
         
      END IF;
      
      num_srid := p_geom1.SDO_SRID;
      
      sdo_geom1 := MDSYS.SDO_CS.TRANSFORM(p_geom1,p_alt_srid);
      sdo_geom2 := MDSYS.SDO_CS.TRANSFORM(p_geom2,p_alt_srid);
      
      str_relate := MDSYS.SDO_GEOM.RELATE(
          geom1 => sdo_geom1
         ,mask  => 'DETERMINE'
         ,geom2 => sdo_geom2
         ,tol   => p_tol
      );
   
      RETURN str_relate;
   
   END dz_desparate_relate;

END dz_sdo_geodetic;
/

