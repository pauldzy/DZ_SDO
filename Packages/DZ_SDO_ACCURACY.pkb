CREATE OR REPLACE PACKAGE BODY dz_sdo_accuracy
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION hausdorff_distance(
       p_input_1           IN  MDSYS.SDO_GEOMETRY
      ,p_input_2           IN  MDSYS.SDO_GEOMETRY
   ) RETURN NUMBER
   AS
      num_one NUMBER;
      num_two NUMBER;
      
   BEGIN
      
      hausdorff_distance(
          p_input_1           => p_input_1
         ,p_input_2           => p_input_2
         ,p_conflation_dist_1 => num_one
         ,p_conflation_dist_2 => num_two
      );
      
      IF num_two > num_one
      THEN
         RETURN num_two;
         
      ELSE
         RETURN num_one;
         
      END IF;
   
   END hausdorff_distance;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE hausdorff_distance(
       p_input_1           IN  MDSYS.SDO_GEOMETRY
      ,p_input_2           IN  MDSYS.SDO_GEOMETRY
      ,p_conflation_dist_1 OUT NUMBER
      ,p_conflation_dist_2 OUT NUMBER
      ,p_tolerance         IN  NUMBER DEFAULT 0.05
   )
   AS
      sdo_input_1     MDSYS.SDO_GEOMETRY := p_input_1;
      sdo_input_2     MDSYS.SDO_GEOMETRY := p_input_2;
      ary_nodes_1     MDSYS.SDO_GEOMETRY_ARRAY;
      ary_nodes_2     MDSYS.SDO_GEOMETRY_ARRAY;
      ary_segments_1  MDSYS.SDO_GEOMETRY_ARRAY;
      ary_segments_2  MDSYS.SDO_GEOMETRY_ARRAY;
      num_distance    NUMBER;
      num_shortest_1  NUMBER := 999999999;
      num_shortest_2  NUMBER := 999999999;
      num_hausdorff_1 NUMBER := 0;
      num_hausdorff_2 NUMBER := 0;
      num_tolerance   NUMBER := p_tolerance;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF sdo_input_1 IS NULL
      OR sdo_input_2 IS NULL
      THEN
         RAISE_APPLICATION_ERROR(-20001,'input geometries cannot be NULL');
         
      END IF;
      
      IF sdo_input_1.get_gtype NOT IN (2,6)
      THEN
         RAISE_APPLICATION_ERROR(-20001,'input geometry one must be linestring');
         
      END IF;
      
      IF sdo_input_2.get_gtype NOT IN (2,6)
      THEN
         RAISE_APPLICATION_ERROR(-20001,'input geometry two must be linestring');
         
      END IF;
      
      IF num_tolerance IS NULL
      THEN
         num_tolerance := 0.05;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Break input geometries into parts
      --------------------------------------------------------------------------
      dz_sdo_dissect.deconstruct_multistring(
          p_input   => sdo_input_1
         ,p_nodes   => ary_nodes_1
         ,p_edges   => ary_segments_1
      );
      
      dz_sdo_dissect.deconstruct_multistring(
          p_input   => sdo_input_2
         ,p_nodes   => ary_nodes_2
         ,p_edges   => ary_segments_2
      );
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Measure each side 1 node against each side 2 edge 
      --------------------------------------------------------------------------
      FOR i IN 1 .. ary_nodes_1.COUNT
      LOOP
         num_shortest_1 := 9999999999;
         FOR j IN 1 .. ary_segments_2.COUNT
         LOOP
            num_distance := MDSYS.SDO_GEOM.SDO_DISTANCE(
                ary_nodes_1(i)
               ,ary_segments_2(j)
               ,num_tolerance
            );
            
            IF num_distance < num_shortest_1
            THEN
               num_shortest_1 := num_distance;
               
            END IF;
            
         END LOOP;
         
         IF num_shortest_1 > num_hausdorff_1
         THEN
            num_hausdorff_1 := num_shortest_1;
            
         END IF;
         
      END LOOP;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Measure each side 2 node against each side 1 edge 
      --------------------------------------------------------------------------
      FOR i IN 1 .. ary_nodes_2.COUNT
      LOOP
         num_shortest_2 := 9999999999;
         FOR j IN 1 .. ary_segments_1.COUNT
         LOOP
            num_distance := MDSYS.SDO_GEOM.SDO_DISTANCE(
                ary_nodes_2(i)
               ,ary_segments_1(j)
               ,num_tolerance
            );
            
            IF num_distance < num_shortest_2
            THEN
               num_shortest_2 := num_distance;
               
            END IF;
            
         END LOOP;
         
         IF num_shortest_2 > num_hausdorff_2
         THEN
            num_hausdorff_2 := num_shortest_2;
            
         END IF;
         
      END LOOP;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Return the results
      --------------------------------------------------------------------------
      p_conflation_dist_1 := num_hausdorff_1;
      p_conflation_dist_2 := num_hausdorff_2;
      
   END hausdorff_distance;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE hausdorff_distance_plus(
       p_input_1           IN  MDSYS.SDO_GEOMETRY
      ,p_input_2           IN  MDSYS.SDO_GEOMETRY
      ,p_hausdorff_to      OUT NUMBER
      ,p_hausdorff_from    OUT NUMBER
      ,p_between_starts    OUT NUMBER
      ,p_between_ends      OUT NUMBER
      ,p_start1_to_2       OUT NUMBER
      ,p_end1_to_2         OUT NUMBER
      ,p_start2_to_1       OUT NUMBER
      ,p_end2_to_1         OUT NUMBER
      ,p_tolerance         IN  NUMBER DEFAULT 0.05
   )
   AS
      num_1s_to_2s  NUMBER;
      num_1s_to_2e  NUMBER;
      num_1e_to_2s  NUMBER;
      num_1e_to_2e  NUMBER;
      num_tolerance NUMBER := p_tolerance;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Get the Hausdorff first
      --------------------------------------------------------------------------
      IF num_tolerance IS NULL
      THEN
         num_tolerance := 0.05;
      
      END IF;
      
      hausdorff_distance(
          p_input_1           => p_input_1
         ,p_input_2           => p_input_2
         ,p_conflation_dist_1 => p_hausdorff_to
         ,p_conflation_dist_2 => p_hausdorff_from
         ,p_tolerance         => num_tolerance
      );
   
      --------------------------------------------------------------------------
      -- Step 20
      -- Get the distances between nearest endpoints
      --------------------------------------------------------------------------
      num_1s_to_2s := MDSYS.SDO_GEOM.SDO_DISTANCE(
          dz_sdo_util.get_start_point(p_input_1)
         ,dz_sdo_util.get_start_point(p_input_2)
         ,num_tolerance
      );
      num_1s_to_2e := MDSYS.SDO_GEOM.SDO_DISTANCE(
          dz_sdo_util.get_start_point(p_input_1)
         ,dz_sdo_util.get_end_point(p_input_2)
         ,num_tolerance
      );
      num_1e_to_2s := MDSYS.SDO_GEOM.SDO_DISTANCE(
          dz_sdo_util.get_end_point(p_input_1)
         ,dz_sdo_util.get_start_point(p_input_2)
         ,num_tolerance
      );
      num_1e_to_2e := MDSYS.SDO_GEOM.SDO_DISTANCE(
          dz_sdo_util.get_end_point(p_input_1)
         ,dz_sdo_util.get_end_point(p_input_2)
         ,num_tolerance
      );
      
      IF num_1s_to_2s < num_1s_to_2e
      THEN
         p_between_starts := num_1s_to_2s;
         p_between_ends := num_1e_to_2e;
         
      ELSE
         p_between_starts := num_1s_to_2e;
         p_between_ends := num_1e_to_2s;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Get the distances between endpoints and the other line
      --------------------------------------------------------------------------
      p_start1_to_2 := MDSYS.SDO_GEOM.SDO_DISTANCE(
          dz_sdo_util.get_start_point(p_input_1)
         ,p_input_2
         ,num_tolerance
      );
      p_end1_to_2 := MDSYS.SDO_GEOM.SDO_DISTANCE(
          dz_sdo_util.get_end_point(p_input_1)
         ,p_input_2
         ,num_tolerance
      );
      p_start2_to_1 := MDSYS.SDO_GEOM.SDO_DISTANCE(
          dz_sdo_util.get_start_point(p_input_2)
         ,p_input_1
         ,num_tolerance
      );
      p_end2_to_1 := MDSYS.SDO_GEOM.SDO_DISTANCE(
          dz_sdo_util.get_end_point(p_input_2)
         ,p_input_1
         ,num_tolerance
      );
   
   END hausdorff_distance_plus;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION coefficient_arial_corresp(
       p_input_1       IN  MDSYS.SDO_GEOMETRY
      ,p_input_2       IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance     IN  NUMBER DEFAULT 0.05
      ,p_srid          IN  NUMBER DEFAULT NULL
   ) RETURN NUMBER
   AS
     sdo_input_1           MDSYS.SDO_GEOMETRY := p_input_1;
     sdo_input_2           MDSYS.SDO_GEOMETRY := p_input_2;
     sdo_intersection_geom MDSYS.SDO_GEOMETRY;
     sdo_union_geom        MDSYS.SDO_GEOMETRY;
     sdo_intersection_area NUMBER;
     sdo_union_area        NUMBER;
     num_tolerance         NUMBER := p_tolerance;
     num_srid              NUMBER := p_srid;
     str_validate          VARCHAR2(4000 Char);
     
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF num_tolerance IS NULL
      THEN
         num_tolerance := 0.05;
         
      END IF;
      
      IF sdo_input_1 IS NULL
      THEN
         RAISE_APPLICATION_ERROR(-20001,'input geometry 1 is NULL');
         
      END IF;
      
      IF sdo_input_2 IS NULL
      THEN
         RAISE_APPLICATION_ERROR(-20001,'input geometry 2 is NULL');
         
      END IF;
      
      IF sdo_input_1.get_gtype NOT IN (3,7)
      THEN
         RAISE_APPLICATION_ERROR(-20001,'input geometry 1 must be polygon');
         
      END IF;
      
      IF sdo_input_2.get_gtype NOT IN (3,7)
      THEN
         RAISE_APPLICATION_ERROR(-20001,'input geometry 2 must be polygon');
         
      END IF;
      
      IF sdo_input_1.SDO_SRID <> sdo_input_2.SDO_SRID
      THEN
         RAISE_APPLICATION_ERROR(-20001,'geometries must use the same coordinate system');
         
      END IF;
      
      IF num_srid IS NOT NULL
      AND num_srid <> sdo_input_1.SDO_SRID
      THEN
         sdo_input_1 := MDSYS.SDO_CS.TRANSFORM(sdo_input_1,num_srid);
         sdo_input_2 := MDSYS.SDO_CS.TRANSFORM(sdo_input_2,num_srid);
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Validate the geometries
      --------------------------------------------------------------------------
      str_validate := MDSYS.SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(
          sdo_input_1
         ,num_tolerance
      );
      
      IF str_validate != 'TRUE'
      THEN
         RAISE_APPLICATION_ERROR(-20001,'input geometry 1: ' || str_validate);
         
      END IF;
      
      str_validate := MDSYS.SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(
          sdo_input_2
         ,num_tolerance
      );
      
      IF str_validate != 'TRUE'
      THEN
         RAISE_APPLICATION_ERROR(-20001,'input geometry 2: ' || str_validate);
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Do the intersection
      --------------------------------------------------------------------------
      sdo_intersection_geom := MDSYS.SDO_GEOM.SDO_INTERSECTION(
          sdo_input_1
         ,sdo_input_2
         ,num_tolerance
      );
      
      IF sdo_intersection_geom IS NULL
      OR sdo_intersection_geom.get_gtype() IN (1,2,5,6)
      THEN
         RETURN 0;
         
      END IF;
      
      sdo_intersection_area := MDSYS.SDO_GEOM.SDO_AREA(
          sdo_intersection_geom
         ,num_tolerance
      );
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Do the union
      --------------------------------------------------------------------------
      sdo_union_geom := MDSYS.SDO_GEOM.SDO_UNION(
          sdo_input_1
         ,sdo_input_2
         ,num_tolerance
      );
      
      IF sdo_union_geom IS NULL
      OR sdo_union_geom.get_gtype() IN (1,2,5,6)
      THEN
         RAISE_APPLICATION_ERROR(
             -20001
            ,'error evaluating geometries via SDO_UNION'
         );
         
      END IF;
      
      sdo_union_area := MDSYS.SDO_GEOM.SDO_AREA(
          sdo_union_geom
         ,num_tolerance
      );
      
      IF sdo_union_area = 0
      THEN
         RAISE_APPLICATION_ERROR(
             -20001
            ,'evaluating geometries via SDO_UNION returned zero area'
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Return the coefficient
      --------------------------------------------------------------------------
      RETURN sdo_intersection_area/sdo_union_area;
      
   END coefficient_arial_corresp;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION buffer_overlay_statistics(
       p_input_1    IN  MDSYS.SDO_GEOMETRY
      ,p_input_2    IN  MDSYS.SDO_GEOMETRY
      ,p_buffer_amt IN  NUMBER
      ,p_tolerance  IN  NUMBER DEFAULT 0.05
      ,p_params     IN  VARCHAR2 DEFAULT NULL
   ) RETURN NUMBER
   AS
      sdo_buffer_1  MDSYS.SDO_GEOMETRY;
      sdo_buffer_2  MDSYS.SDO_GEOMETRY;
      num_area_2    NUMBER;
      sdo_intersect MDSYS.SDO_GEOMETRY;
      num_area_int  NUMBER;
      num_tolerance NUMBER := p_tolerance;
      num_ecode     NUMBER;
      str_message   VARCHAR2(4000 Char);
      
   BEGIN
   
      IF p_input_1 IS NULL
      THEN
         RETURN NULL;
         
      END IF;
      
      IF p_input_2 IS NULL
      THEN
         RETURN 0;
         
      END IF;
      
      IF p_input_1.get_gtype() NOT IN (2,6)
      THEN
         RAISE_APPLICATION_ERROR(
             -20001
            ,'input 1 must be single linestring'
         );
      
      END IF;
      
      IF p_input_2.get_gtype() NOT IN (2,6)
      THEN
         RAISE_APPLICATION_ERROR(
             -20001
            ,'input 2 must be single linestring'
         );
      
      END IF;
      
      IF num_tolerance IS NULL
      THEN
         num_tolerance := 0.05;
         
      END IF;
      
      dz_sdo_main.safe_buffer(
          p_input         => p_input_1
         ,p_distance      => p_buffer_amt
         ,p_tolerance     => num_tolerance
         ,p_params        => p_params
         ,p_output        => sdo_buffer_1
         ,p_sqlcode       => num_ecode
         ,p_sqlerrm       => str_message
      );
      
      IF num_ecode <> 0
      THEN
         RAISE_APPLICATION_ERROR(-20001,str_message);
         
      END IF;
      
      dz_sdo_main.safe_buffer(
          p_input         => p_input_2
         ,p_distance      => p_buffer_amt
         ,p_tolerance     => num_tolerance
         ,p_params        => p_params
         ,p_output        => sdo_buffer_2
         ,p_sqlcode       => num_ecode
         ,p_sqlerrm       => str_message
      );
      
      IF num_ecode <> 0
      THEN
         RAISE_APPLICATION_ERROR(-20001,str_message);
         
      END IF;
      
      num_area_2 := MDSYS.SDO_GEOM.SDO_AREA(
          sdo_buffer_2
         ,num_tolerance
      );
      
      sdo_intersect := dz_sdo_util.scrub_polygons(
         MDSYS.SDO_GEOM.SDO_INTERSECTION(
             sdo_buffer_1
            ,sdo_buffer_2
            ,num_tolerance
         )
      );
      
      IF sdo_intersect IS NULL
      THEN
         RETURN 0;
      
      END IF;
      
      num_area_int := MDSYS.SDO_GEOM.SDO_AREA(
          sdo_intersect
         ,num_tolerance
      );
      
      RETURN num_area_int / num_area_2;
   
   END buffer_overlay_statistics;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION linear_direction_relate(
       p_parent        IN  MDSYS.SDO_GEOMETRY
      ,p_child         IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance     IN  NUMBER DEFAULT 0.05
      ,p_determine     IN  VARCHAR2 DEFAULT NULL
   ) RETURN VARCHAR2
   AS
      sdo_input_1      MDSYS.SDO_GEOMETRY;
      sdo_input_2      MDSYS.SDO_GEOMETRY;
      num_tolerance    NUMBER := p_tolerance;
      str_relate       VARCHAR2(4000 Char);
      num_meas_start_2 NUMBER;
      num_meas_end_2   NUMBER;
      lrs_input_1      MDSYS.SDO_GEOMETRY;
      sdo_start_2      MDSYS.SDO_GEOMETRY;
      sdo_end_2        MDSYS.SDO_GEOMETRY;
      str_determine    VARCHAR2(4000 Char) := UPPER(p_determine);
      str_is_loop_1    VARCHAR2(5 Char);
      str_is_loop_2    VARCHAR2(5 Char);
      
   BEGIN
   
      IF p_parent IS NULL
      THEN
         RETURN NULL;
         
      END IF;
      
      IF p_child IS NULL
      THEN
         RETURN NULL;
         
      END IF;
   
      IF p_parent.get_gtype() <> 2
      THEN
         RAISE_APPLICATION_ERROR(
             -20001
            ,'parent geometry must be single linestrings'
         );
         
      END IF;
      
      IF p_child.get_gtype() <> 2
      THEN
         RAISE_APPLICATION_ERROR(
             -20001
            ,'child geometry must be single linestrings'
         );
         
      END IF;
      
      IF num_tolerance IS NULL
      THEN
         num_tolerance := 0.05;
      
      END IF;
   
      sdo_input_1 := dz_sdo_util.downsize_2d(p_parent);
      sdo_input_2 := dz_sdo_util.downsize_2d(p_child);
      
      str_relate := MDSYS.SDO_GEOM.RELATE(
          sdo_input_1
         ,'DETERMINE'
         ,sdo_input_2
         ,num_tolerance
      );
      
      IF str_relate NOT IN (
          'COVERS'
         ,'CONTAINS'
         ,'EQUAL'
         ,'INSIDE'
         ,'COVEREDBY'
         ,'OVERLAPBDYINTERSECT'
      )
      THEN
         IF str_determine = 'DETERMINE'
         THEN
            RETURN str_relate;
            
         ELSE
            RETURN 'FALSE';
         
         END IF;
         
      END IF;
      
      str_is_loop_1 := dz_sdo_util.is_closed_loop(sdo_input_1);
      str_is_loop_2 := dz_sdo_util.is_closed_loop(sdo_input_2);
      
      IF str_relate IN ('INSIDE','COVEREDBY')
      OR ( str_is_loop_2 = 'TRUE' AND str_is_loop_1 = 'FALSE' )
      THEN
         -- Reverse the relationship
         sdo_input_1 := dz_sdo_util.downsize_2d(p_child);
         sdo_input_2 := dz_sdo_util.downsize_2d(p_parent);
         str_is_loop_1 := dz_sdo_util.is_closed_loop(sdo_input_1);
         str_is_loop_2 := dz_sdo_util.is_closed_loop(sdo_input_2);
      
      ELSIF str_relate = 'OVERLAPBDYINTERSECT'
      THEN
         NULL;
      
      END IF;
      
      IF str_is_loop_1 = 'TRUE'
      THEN
         -- Reorient parent to match the start of 2
         sdo_input_1 := dz_sdo_main.reorient_geometry_ring(
             p_input   => sdo_input_1
            ,p_vertice => dz_sdo_util.get_start_point(sdo_input_2)
         );
      
      END IF;
      
      lrs_input_1 := MDSYS.SDO_LRS.CONVERT_TO_LRS_GEOM(
          sdo_input_1
         ,0
         ,100
      );
      
      dz_sdo_main.reasonable_endpoints(
          p_input       => sdo_input_2
         ,p_start_point => sdo_start_2
         ,p_end_point   => sdo_end_2
      );
      
      num_meas_start_2 := MDSYS.SDO_LRS.GET_MEASURE(
         dz_sdo_geodetic.dz_project_pt(
             p_geom_segment => lrs_input_1
            ,p_point        => sdo_start_2
         )
      );
         
      num_meas_end_2 := MDSYS.SDO_LRS.GET_MEASURE(
         dz_sdo_geodetic.dz_project_pt(
             p_geom_segment => lrs_input_1
            ,p_point        => sdo_end_2
         )
      );
      
      --dbms_output.put_line(dz_sdo_sqltext.sdo2sql(sdo_input_2));
      --dbms_output.put_line(dz_sdo_sqltext.sdo2sql(lrs_input_1));
      --dbms_output.put_line(dz_sdo_sqltext.sdo2sql(sdo_start_2));
      --dbms_output.put_line(dz_sdo_sqltext.sdo2sql(sdo_end_2));
      --dbms_output.put_line(num_meas_start_2);
      --dbms_output.put_line(num_meas_end_2);
      
      IF num_meas_start_2 < num_meas_end_2
      THEN
         IF str_determine = 'DETERMINE'
         THEN
            RETURN str_relate || ' SAME DIRECTION';
         
         ELSE
            RETURN 'TRUE';
            
         END IF;
      
      ELSE
         IF str_determine = 'DETERMINE'
         THEN
            RETURN str_relate || ' REVERSE DIRECTION';
            
         ELSE
            RETURN 'FALSE';
         
         END IF;
         
      END IF;     
   
   END linear_direction_relate;
 
END dz_sdo_accuracy;
/

