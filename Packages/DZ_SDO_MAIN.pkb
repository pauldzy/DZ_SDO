CREATE OR REPLACE PACKAGE BODY dz_sdo_main 
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION mbr_sq_meters(
      p_input        IN MDSYS.SDO_GEOMETRY,
      p_tolerance    IN NUMBER DEFAULT 0.05
   ) RETURN NUMBER
   AS
   BEGIN

      IF p_input IS NULL
      OR p_input.get_gtype() = 1
      THEN
         RETURN 0;
         
      ELSE
         RETURN MDSYS.SDO_GEOM.SDO_AREA(
             MDSYS.SDO_GEOM.SDO_MBR(p_input)
            ,p_tolerance
         );
         
      END IF;

   END mbr_sq_meters;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION order_rings(
      p_input        IN MDSYS.SDO_GEOMETRY,
      p_direction    IN VARCHAR2 DEFAULT 'ASC'
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      ringcount        NUMBER;
      i                PLS_INTEGER;
      tmp              NUMBER;
      geo_temp         MDSYS.SDO_GEOMETRY;
      TYPE simple_array IS TABLE OF NUMBER
      INDEX BY PLS_INTEGER;
      ary_index        simple_array;
      ary_size         simple_array;

   BEGIN

      IF p_input.get_gtype() != 7
      THEN
         RETURN p_input;
         
      ELSE
         ringcount := MDSYS.SDO_UTIL.GETNUMELEM(p_input);
         
         IF ringcount = 1
         THEN
            RETURN MDSYS.SDO_UTIL.EXTRACT(p_input,1);
            
         END IF;

         -- Spin through and load the arrays
         FOR i in 1 .. ringcount
         LOOP
            ary_index(i) := i;
            ary_size(i)  := mbr_sq_meters(
               MDSYS.SDO_UTIL.EXTRACT(p_input,i)
            );
            
         END LOOP;

         -- Sort the arrays
         i := ary_index.COUNT-1;
         WHILE ( i > 0 )
         LOOP
            FOR j IN 1 .. i
            LOOP
               IF UPPER(p_direction) = 'DESC'
               THEN
                  IF ary_size(j) < ary_size(j+1)
                  THEN
                     tmp            := ary_size(j);
                     ary_size(j)    := ary_size(j+1);
                     ary_size(j+1)  := tmp;

                     tmp            := ary_index(j);
                     ary_index(j)   := ary_index(j+1);
                     ary_index(j+1) := tmp;

                  END IF;

               ELSE
                  IF ary_size(j) > ary_size(j+1)
                  THEN
                     tmp            := ary_size(j);
                     ary_size(j)    := ary_size(j+1);
                     ary_size(j+1)  := tmp;

                     tmp            := ary_index(j);
                     ary_index(j)   := ary_index(j+1);
                     ary_index(j+1) := tmp;
                     
                  END IF;

               END IF;

            END LOOP;

            i := i - 1;

         END LOOP;

         -- rebuild the geometry
         geo_temp := MDSYS.SDO_UTIL.EXTRACT(p_input,ary_index(1));
         FOR i IN 2 .. ary_index.COUNT
         LOOP
            geo_temp := MDSYS.SDO_UTIL.APPEND(
                geo_temp
               ,MDSYS.SDO_UTIL.EXTRACT(p_input,ary_index(i))
            );
            
         END LOOP;

         RETURN geo_temp;

     END IF;

   END order_rings;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION get_MBS(
      p_input        IN MDSYS.SDO_GEOMETRY
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
   --  Returns a minimum bounding SQUARE for specific sheeting usages
      x1       NUMBER;
      y1       NUMBER;
      x2       NUMBER;
      y2       NUMBER;
      xc       NUMBER;
      yc       NUMBER;
      w        NUMBER;
      h        NUMBER;
      x3       NUMBER;
      y3       NUMBER;
      x4       NUMBER;
      y4       NUMBER;

   BEGIN

      x1 := MDSYS.SDO_GEOM.SDO_MIN_MBR_ORDINATE(p_input,1);
      y1 := MDSYS.SDO_GEOM.SDO_MIN_MBR_ORDINATE(p_input,2);
      x2 := MDSYS.SDO_GEOM.SDO_MAX_MBR_ORDINATE(p_input,1);
      y2 := MDSYS.SDO_GEOM.SDO_MAX_MBR_ORDINATE(p_input,2);

      IF x1 > x2
      THEN
         w  := x1 - x2;
         xc := x2 + (w/2);
         
      ELSE
         w  := x2 - x1;
         xc := x1 + (w/2);
         
      END IF;

      IF y1 > y2
      THEN
         h  := y1 - y2;
         yc := y2 + (h/2);
         
      ELSE
         h  := y2 - y1;
         yc := y1 + (h/2);
         
      END IF;

      IF w > h
      THEN
         x3 := x1;
         x4 := x2;
         y3 := yc - (w/2);
         y4 := yc + (w/2);
         
      ELSE
         x3 := xc - (h/2);
         x4 := xc + (h/2);
         y3 := y1;
         y4 := y2;
         
      END IF;

      RETURN MDSYS.SDO_GEOMETRY(
          2003
         ,p_input.SDO_SRID
         ,NULL
         ,MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,3)
         ,MDSYS.SDO_ORDINATE_ARRAY(x3,y3,x4,y4)
      );

   END get_MBS;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION get_quad(
       p_input               IN  MDSYS.SDO_GEOMETRY
      ,p_grid_number         IN  NUMBER
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      -- return one of four quads of a MBS surrounding a geometry
      x1       NUMBER;
      y1       NUMBER;
      x2       NUMBER;
      y2       NUMBER;
      xc       NUMBER;
      yc       NUMBER;
      w        NUMBER;
      h        NUMBER;
      x3       NUMBER;
      y3       NUMBER;
      x4       NUMBER;
      y4       NUMBER;

   BEGIN

      x1 := MDSYS.SDO_GEOM.SDO_MIN_MBR_ORDINATE(p_input,1);
      y1 := MDSYS.SDO_GEOM.SDO_MIN_MBR_ORDINATE(p_input,2);
      x2 := MDSYS.SDO_GEOM.SDO_MAX_MBR_ORDINATE(p_input,1);
      y2 := MDSYS.SDO_GEOM.SDO_MAX_MBR_ORDINATE(p_input,2);

      IF x1 > x2
      THEN
         w  := x1 - x2;
         xc := x2 + (w/2);
         
      ELSE
         w  := x2 - x1;
         xc := x1 + (w/2);
         
      END IF;

      IF y1 > y2
      THEN
         h  := y1 - y2;
         yc := y2 + (h/2);
         
      ELSE
         h  := y2 - y1;
         yc := y1 + (h/2);
         
      END IF;


      IF p_grid_number = 0
      THEN
         x3 := x1;
         y3 := y1 + (h/2);
         x4 := x1 + (w/2);
         y4 := y2;
         
      ELSIF p_grid_number = 1
      THEN
         x3 := x1 + (w/2);
         y3 := y1 + (h/2);
         x4 := x2;
         y4 := y2;
         
      ELSIF p_grid_number = 2
      THEN
         x3 := x1;
         y3 := y1;
         x4 := x1 + (w/2);
         y4 := y1 + (h/2);
         
      ELSIF p_grid_number = 3
      THEN
         x3 := x1 + (w/2);
         y3 := y1;
         x4 := x2;
         y4 := y1 + (h/2);
         
      ELSIF p_grid_number = 4   -- 4 equals the left half
      THEN
         x3 := x1;
         y3 := y1;
         x4 := x1 + (w/2);
         y4 := y2;
         
      ELSIF p_grid_number = 5   -- 5 equals the right half
      THEN
         x3 := x1 + (w/2);
         y3 := y1;
         x4 := x2;
         y4 := y2;
         
      ELSIF p_grid_number = 6  -- 6 equals the bottom half
      THEN
         x3 := x1;
         y3 := y1 + (h/2);
         x4 := x2;
         y4 := y2;
         
      ELSIF p_grid_number = 7  -- 7 equals the top half
      THEN
         x3 := x1;
         y3 := y1;
         x4 := x2;
         y4 := y1 + (h/2); 
         
      END IF;

      RETURN MDSYS.SDO_GEOMETRY(
          2003
         ,p_input.SDO_SRID
         ,NULL
         ,MDSYS.SDO_ELEM_INFO_ARRAY(1,1003,3)
         ,MDSYS.SDO_ORDINATE_ARRAY(x3,y3,x4,y4)
      );

   END get_quad;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION ez_quads(
       p_input        IN  MDSYS.SDO_GEOMETRY
      ,p_grid         IN  VARCHAR2
      ,p_tolerance    IN  NUMBER DEFAULT 0.05
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      sdo_work      MDSYS.SDO_GEOMETRY;
      ary_grid      MDSYS.SDO_STRING2_ARRAY;
      num_chk       NUMBER;
      num_tolerance NUMBER := p_tolerance;
      
   BEGIN

      IF p_grid IS NULL
      THEN
         RAISE_APPLICATION_ERROR(-20001,'must provide a grid value');
      
      END IF;
      
      IF num_tolerance IS NULL
      THEN
         num_tolerance := 0.05;
      
      END IF;
      
      ary_grid := dz_sdo_util.gz_split(p_grid,NULL);

      sdo_work := get_mbs(p_input);

      FOR i IN 1 .. ary_grid.COUNT
      LOOP
         num_chk  := TO_NUMBER(ary_grid(i));
         
         IF num_chk < 0
         OR num_chk > 7
         THEN
            RAISE_APPLICATION_ERROR(-20001,'grids can only be between 0 and 3');
            
         END IF;
         
         sdo_work := get_quad(sdo_work,num_chk);

      END LOOP;

      RETURN MDSYS.SDO_GEOM.SDO_INTERSECTION(
          p_input
         ,sdo_work
         ,num_tolerance
      );

   END ez_quads;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION search_ordinates(
       p_input      IN  MDSYS.SDO_GEOMETRY
      ,p_value      IN  NUMBER
      ,p_position   IN  VARCHAR2 DEFAULT 'ALL'
      ,p_comparator IN  VARCHAR2 DEFAULT '='
   ) RETURN VARCHAR2
   AS
      int_dims    PLS_INTEGER;
      int_lrs     PLS_INTEGER;
      int_index   PLS_INTEGER;
      int_counter PLS_INTEGER;
      
   BEGIN
   
      int_dims := p_input.get_dims();
      int_lrs  := p_input.get_lrs_dim();

      IF p_input.SDO_POINT IS NOT NULL
      THEN
         IF p_position IN ('X','ALL')
         THEN
            IF p_comparator = '>'
            THEN
               IF p_input.SDO_POINT.X > p_value
               THEN
                  RETURN 'TRUE';
                  
               END IF;
               
            ELSIF p_comparator = '<'
            THEN
               IF p_input.SDO_POINT.X < p_value
               THEN
                  RETURN 'TRUE';
                  
               END IF;
               
            ELSE
               IF p_input.SDO_POINT.X = p_value
               THEN
                  RETURN 'TRUE';
                  
               END IF;
               
            END IF;
            
         END IF;

         IF p_position IN ('Y','ALL')
         THEN
            IF p_comparator = '>'
            THEN
               IF p_input.SDO_POINT.Y > p_value
               THEN
                  RETURN 'TRUE';
                  
               END IF;
               
            ELSIF p_comparator = '<'
            THEN
               IF p_input.SDO_POINT.Y < p_value
               THEN
                  RETURN 'TRUE';
                  
               END IF;
               
            ELSE
               IF p_input.SDO_POINT.Y = p_value
               THEN
                  RETURN 'TRUE';
                  
               END IF;
               
            END IF;
            
         END IF;

         IF int_dims > 2
         THEN
            IF p_position IN ('Z','ALL')
            THEN
               IF p_comparator = '>'
               THEN
                  IF p_input.SDO_POINT.Z > p_value
                  THEN
                     RETURN 'TRUE';
                     
                  END IF;
                  
               ELSIF p_comparator = '<'
               THEN
                  IF p_input.SDO_POINT.Z < p_value
                  THEN
                     RETURN 'TRUE';
                     
                  END IF;
                  
               ELSE
                  IF p_input.SDO_POINT.Z = p_value
                  THEN
                     RETURN 'TRUE';
                     
                  END IF;
                  
               END IF;
               
            END IF;
            
         END IF;

         RETURN 'FALSE';

      END IF;

      int_index   := 1;
      int_counter := p_input.SDO_ORDINATES.COUNT;
      WHILE int_index <= int_counter
      LOOP
         IF p_position IN ('X','ALL')
         THEN
            IF p_comparator = '>'
            THEN
               IF p_input.SDO_ORDINATES(int_index) > p_value
               THEN
                  RETURN 'TRUE';
                  
               END IF;
               
            ELSIF p_comparator = '<'
            THEN
               IF p_input.SDO_ORDINATES(int_index) < p_value
               THEN
                  RETURN 'TRUE';
                  
               END IF;
               
            ELSE
               IF p_input.SDO_ORDINATES(int_index) = p_value
               THEN
                  RETURN 'TRUE';
                  
               END IF;
               
            END IF;
            
         END IF;
         
         int_index := int_index + 1;

         IF int_index > int_counter
         THEN
            RETURN 'BAD';
            
         END IF;

         IF p_position IN ('Y','ALL')
         THEN
            IF p_comparator = '>'
            THEN
               IF p_input.SDO_ORDINATES(int_index) > p_value
               THEN
                  RETURN 'TRUE';
                  
               END IF;
               
            ELSIF p_comparator = '<'
            THEN
               IF p_input.SDO_ORDINATES(int_index) < p_value
               THEN
                  RETURN 'TRUE';
                  
               END IF;
               
            ELSE
               IF p_input.SDO_ORDINATES(int_index) = p_value
               THEN
                  RETURN 'TRUE';
                  
               END IF;
               
            END IF;
            
         END IF;
         int_index := int_index + 1;

         IF int_dims > 2
         THEN
            IF p_position IN ('Z','ALL')
            THEN
               IF p_comparator = '>'
               THEN
                  IF p_input.SDO_ORDINATES(int_index) > p_value
                  THEN
                     RETURN 'TRUE';
                     
                  END IF;
                  
               ELSIF p_comparator = '<'
               THEN
                  IF p_input.SDO_ORDINATES(int_index) < p_value
                  THEN
                     RETURN 'TRUE';
                     
                  END IF;
                  
               ELSE
                  IF p_input.SDO_ORDINATES(int_index) = p_value
                  THEN
                     RETURN 'TRUE';
                     
                  END IF;
                  
               END IF;
               
            END IF;
            
            int_index := int_index + 1;
            
         END IF;

         IF int_dims > 3
         THEN
            IF p_position IN ('M','ALL')
            THEN
               IF p_comparator = '>'
               THEN
                  IF p_input.SDO_ORDINATES(int_index) > p_value
                  THEN
                     RETURN 'TRUE';
                     
                  END IF;
                  
               ELSIF p_comparator = '<'
               THEN
                  IF p_input.SDO_ORDINATES(int_index) < p_value
                  THEN
                     RETURN 'TRUE';
                     
                  END IF;
                  
               ELSE
                  IF p_input.SDO_ORDINATES(int_index) = p_value
                  THEN
                     RETURN 'TRUE';
                     
                  END IF;
                  
               END IF;
               
            END IF;
            
            int_index := int_index + 1;
            
         END IF;

      END LOOP;

      RETURN 'FALSE';
      
   END search_ordinates;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION within_envelope(
       p_input      IN  MDSYS.SDO_GEOMETRY
      ,p_min_x      IN  NUMBER DEFAULT -180
      ,p_max_x      IN  NUMBER DEFAULT 180
      ,p_min_y      IN  NUMBER DEFAULT -90
      ,p_max_y      IN  NUMBER DEFAULT 90
   ) RETURN VARCHAR2
   AS
      int_dims    PLS_INTEGER;
      int_index   PLS_INTEGER;
      int_counter PLS_INTEGER;
      
   BEGIN
   
      IF p_input IS NULL
      THEN
         RETURN NULL;
         
      END IF;
   
      IF p_input.SDO_POINT IS NOT NULL
      THEN
         IF p_input.SDO_POINT.X < p_min_x
         THEN
            RETURN 'FALSE';
            
         END IF;
         
         IF p_input.SDO_POINT.X > p_max_x
         THEN
            RETURN 'FALSE';
            
         END IF;
         
         IF p_input.SDO_POINT.Y < p_min_y
         THEN
            RETURN 'FALSE';
            
         END IF;
         
         IF p_input.SDO_POINT.Y > p_max_y
         THEN
            RETURN 'FALSE';
            
         END IF;
         
         RETURN 'TRUE';
         
      END IF;

      int_index   := 1;
      int_counter := p_input.SDO_ORDINATES.COUNT;
      int_dims    := p_input.get_dims();
      
      WHILE int_index <= int_counter
      LOOP
         IF p_input.SDO_ORDINATES(int_index) < p_min_x
         THEN
            RETURN 'FALSE';
            
         END IF;
         
         IF p_input.SDO_ORDINATES(int_index) > p_max_x
         THEN
            RETURN 'FALSE';
            
         END IF;
         
         int_index := int_index + 1;

         IF p_input.SDO_ORDINATES(int_index) < p_min_y
         THEN
            RETURN 'FALSE';
            
         END IF;
         
         IF p_input.SDO_ORDINATES(int_index) > p_max_y
         THEN
            RETURN 'FALSE';
            
         END IF;
         
         int_index := int_index + 1;

         IF int_dims > 2
         THEN
            int_index := int_index + 1;
            
         END IF;

         IF int_dims > 3
         THEN
            int_index := int_index + 1;
            
         END IF;

      END LOOP;

      RETURN 'TRUE';
      
   END within_envelope;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION move_polygon_to_back(
       p_input      IN  MDSYS.SDO_GEOMETRY
      ,p_number     IN  NUMBER DEFAULT 1
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      int_polygon  PLS_INTEGER := p_number;
      int_elements PLS_INTEGER;
      sdo_output   MDSYS.SDO_GEOMETRY;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF int_polygon IS NULL
      THEN
         int_polygon := 1;
         
      END IF;
      
      IF p_input IS NULL
      THEN
         RETURN NULL;
         
      END IF;
      
      IF p_input.get_gtype != 7
      THEN
         RAISE_APPLICATION_ERROR(-20001,'input must be multi-polygon');
         
      END IF;
      
      int_elements := MDSYS.SDO_UTIL.GETNUMELEM(p_input);
      IF int_polygon > int_elements
      THEN
         RAISE_APPLICATION_ERROR(
             -20001
            ,'only ' || int_elements || ' in this polygon'
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Build the new polygon witout the requested poly
      --------------------------------------------------------------------------
      FOR i IN 1 .. int_elements
      LOOP
         IF i != int_polygon
         THEN
            IF sdo_output IS NULL
            THEN
               sdo_output := MDSYS.SDO_UTIL.EXTRACT(p_input,i);
               
            ELSE
               sdo_output := MDSYS.SDO_UTIL.APPEND(
                   sdo_output
                  ,MDSYS.SDO_UTIL.EXTRACT(p_input,i)
               );
               
            END IF;
            
         END IF;
         
      END LOOP;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Tack the requested poly on the backside
      --------------------------------------------------------------------------
      IF sdo_output IS NULL
      THEN
         sdo_output := MDSYS.SDO_UTIL.EXTRACT(
             p_input
            ,int_polygon
         );
         
      ELSE
         sdo_output := MDSYS.SDO_UTIL.APPEND(
             sdo_output
            ,MDSYS.SDO_UTIL.EXTRACT(
                 p_input
                ,int_polygon
             )
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Return results
      -------------------------------------------------------------------------- 
      RETURN sdo_output;
      
   END move_polygon_to_back;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION find_duplicate_points(
       p_input      IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance  IN  NUMBER DEFAULT 0.05
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      num_tolerance NUMBER := p_tolerance;
      int_dims      PLS_INTEGER;
      int_lrs       PLS_INTEGER;
      int_index     PLS_INTEGER;
      ary_nodes     MDSYS.SDO_GEOMETRY_ARRAY;
      ary_dups      MDSYS.SDO_GEOMETRY_ARRAY;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      int_dims := p_input.get_dims();
      int_lrs  := p_input.get_lrs_dim();
      
      IF num_tolerance IS NULL
      THEN
         num_tolerance := 0.05;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Break apart the geometry
      --------------------------------------------------------------------------
      dz_sdo_dissect.deconstruct_string(
          p_input  => p_input
         ,p_nodes  => ary_nodes
         ,p_edges  => ary_dups
      );
      ary_dups := MDSYS.SDO_GEOMETRY_ARRAY();

      --------------------------------------------------------------------------
      -- Step 30
      -- Find duplicate points
      --------------------------------------------------------------------------
      int_index := 1;
      FOR i IN 1 .. ary_nodes.COUNT
      LOOP
         FOR j IN 1 .. ary_nodes.COUNT
         LOOP
            IF i != j
            THEN
               IF MDSYS.SDO_GEOM.RELATE(
                   ary_nodes(i)
                  ,'EQUAL'
                  ,ary_nodes(j)
                  ,num_tolerance
               ) = 'EQUAL'
               THEN
                  ary_dups.EXTEND();
                  ary_dups(int_index) := ary_nodes(i);
                  int_index := int_index + 1;
                  
               END IF;
               
            END IF;
         
         END LOOP;
         
      END LOOP;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Gather results to return
      --------------------------------------------------------------------------
      IF ary_dups IS NULL
      OR ary_dups.COUNT = 0
      THEN
         RETURN NULL;
         
      ELSE
         RETURN dz_sdo_util.varray2sdo(
            p_input => ary_dups
         );
         
      END IF;
   
   END find_duplicate_points;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE break_string_at_point(
       p_input          IN  MDSYS.SDO_GEOMETRY
      ,p_break_vertices IN  NUMBER DEFAULT NULL
      ,p_first          OUT MDSYS.SDO_GEOMETRY
      ,p_second         OUT MDSYS.SDO_GEOMETRY
   )
   AS
       num_vertices       NUMBER;
       num_break_vertices NUMBER := p_break_vertices;
       int_parent         PLS_INTEGER;
       int_child          PLS_INTEGER;
       sdooa_temp         MDSYS.SDO_ORDINATE_ARRAY;
       
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF p_input.get_gtype() != 2
      THEN
          RAISE_APPLICATION_ERROR(-20001,'input must be single linestring');
          
      END IF;
      
      num_vertices := MDSYS.SDO_UTIL.GETNUMVERTICES(p_input);
      IF num_vertices = 2
      THEN
         p_first  := p_input;
         p_second := NULL;
         RETURN;
         
      END IF;
      
      IF num_break_vertices IS NULL
      THEN
         num_break_vertices := TRUNC(num_vertices/2 + 0.5);
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Initialize the linestring sdos
      --------------------------------------------------------------------------
      p_first  := MDSYS.SDO_GEOMETRY(
          p_input.SDO_GTYPE
         ,p_input.SDO_SRID
         ,NULL
         ,MDSYS.SDO_ELEM_INFO_ARRAY(1,2,1)
         ,NULL
      );
      p_second := MDSYS.SDO_GEOMETRY(
          p_input.SDO_GTYPE
         ,p_input.SDO_SRID
         ,NULL
         ,MDSYS.SDO_ELEM_INFO_ARRAY(1,2,1)
         ,NULL
      );
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Step through the parent
      --------------------------------------------------------------------------
      int_parent := 1;
      int_child  := 1;
      sdooa_temp := MDSYS.SDO_ORDINATE_ARRAY();
      
      FOR i IN 1 .. num_break_vertices
      LOOP
         sdooa_temp.EXTEND();
         sdooa_temp(int_child) := p_input.SDO_ORDINATES(int_parent);
         int_child  := int_child + 1;
         int_parent := int_parent + 1;
         
         sdooa_temp.EXTEND();
         sdooa_temp(int_child) := p_input.SDO_ORDINATES(int_parent);
         int_child  := int_child + 1;
         int_parent := int_parent + 1;
         
         IF p_input.get_dims() > 2
         THEN
            sdooa_temp.EXTEND();
            sdooa_temp(int_child) := p_input.SDO_ORDINATES(int_parent);
            int_child  := int_child + 1;
            int_parent := int_parent + 1;
            
         END IF;
         
         IF p_input.get_dims() > 3
         THEN
            sdooa_temp.EXTEND();
            sdooa_temp(int_child) := p_input.SDO_ORDINATES(int_parent);
            int_child  := int_child + 1;
            int_parent := int_parent + 1;
            
         END IF;
           
      END LOOP;
      
      p_first.SDO_ORDINATES := sdooa_temp;
      
      int_child  := 1;
      int_parent := int_parent - p_input.get_dims();
      sdooa_temp := MDSYS.SDO_ORDINATE_ARRAY();
      FOR i IN num_break_vertices .. num_vertices
      LOOP
         sdooa_temp.EXTEND();
         sdooa_temp(int_child) := p_input.SDO_ORDINATES(int_parent);
         int_child  := int_child + 1;
         int_parent := int_parent + 1;
         
         sdooa_temp.EXTEND();
         sdooa_temp(int_child) := p_input.SDO_ORDINATES(int_parent);
         int_child  := int_child + 1;
         int_parent := int_parent + 1;
         
         IF p_input.get_dims() > 2
         THEN
            sdooa_temp.EXTEND();
            sdooa_temp(int_child) := p_input.SDO_ORDINATES(int_parent);
            int_child  := int_child + 1;
            int_parent := int_parent + 1;
            
         END IF;
         
         IF p_input.get_dims() > 3
         THEN
            sdooa_temp.EXTEND();
            sdooa_temp(int_child) := p_input.SDO_ORDINATES(int_parent);
            int_child  := int_child + 1;
            int_parent := int_parent + 1;
            
         END IF;
         
         p_second.SDO_ORDINATES := sdooa_temp;
         
      END LOOP;
   
   END break_string_at_point;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION get_shortest_connecting_line(
       p_object_1    IN  MDSYS.SDO_GEOMETRY
      ,p_object_2    IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance   IN  NUMBER
      ,p_output_flag IN  VARCHAR2 DEFAULT 'LINE'
   ) RETURN MDSYS.SDO_GEOMETRY
   AS

      int_gtype_1          PLS_INTEGER;
      int_gtype_2          PLS_INTEGER;
      int_dims_1           PLS_INTEGER;
      int_dims_2           PLS_INTEGER;
      sdo_object_1         MDSYS.SDO_GEOMETRY;
      sdo_object_2         MDSYS.SDO_GEOMETRY;
      sdo_point_1          MDSYS.SDO_GEOMETRY := NULL;
      sdo_point_2          MDSYS.SDO_GEOMETRY := NULL;
      ary_segments_1       MDSYS.SDO_GEOMETRY_ARRAY;
      ary_segments_2       MDSYS.SDO_GEOMETRY_ARRAY;
      ary_bitbucket        MDSYS.SDO_GEOMETRY_ARRAY;
      num_current_distance NUMBER;
      sdo_closest_1        MDSYS.SDO_GEOMETRY;
      sdo_closest_2        MDSYS.SDO_GEOMETRY;
      num_closest_distance NUMBER;
      num_closest_index    PLS_INTEGER;
      sdo_closest_pt_1     MDSYS.SDO_GEOMETRY;
      sdo_closest_pt_2     MDSYS.SDO_GEOMETRY;
      sdo_closest_ln_1     MDSYS.SDO_GEOMETRY;
      sdo_closest_ln_2     MDSYS.SDO_GEOMETRY;

      FUNCTION get_closer_endpoint(
          p_input_1     IN  MDSYS.SDO_GEOMETRY
         ,p_input_2     IN  MDSYS.SDO_GEOMETRY
         ,p_tolerance   IN  NUMBER
      ) RETURN MDSYS.SDO_GEOMETRY
      AS
         sdo_start    MDSYS.SDO_GEOMETRY;
         sdo_stop     MDSYS.SDO_GEOMETRY;
         int_gtype    PLS_INTEGER;
         
      BEGIN
      
         int_gtype := p_input_1.get_gtype();
         IF int_gtype = 1
         THEN
            RETURN p_input_1;
            
         END IF;

         sdo_start  := MDSYS.SDO_LRS.GEOM_SEGMENT_START_PT(p_input_1);
         sdo_stop   := MDSYS.SDO_LRS.GEOM_SEGMENT_END_PT(p_input_1);

         IF MDSYS.SDO_GEOM.SDO_DISTANCE(
             p_input_2
            ,sdo_start
           ,p_tolerance
         ) < MDSYS.SDO_GEOM.SDO_DISTANCE(
             p_input_2
            ,sdo_stop
            ,p_tolerance
         )
         THEN
            RETURN sdo_start;
            
         ELSE
            RETURN sdo_stop;
            
         END IF;

      END get_closer_endpoint;

      FUNCTION get_closer_linepoint(
         p_input_line  IN MDSYS.SDO_GEOMETRY,
         p_input_point IN MDSYS.SDO_GEOMETRY,
         p_tolerance  IN NUMBER
      ) RETURN MDSYS.SDO_GEOMETRY
      AS
         num_measure NUMBER;
         int_gtype   PLS_INTEGER;
         
      BEGIN
      
         int_gtype := p_input_line.get_gtype();
         IF int_gtype = 1
         THEN
            RETURN p_input_line;
            
         END IF;
         
         num_measure := MDSYS.SDO_LRS.FIND_MEASURE(
             p_input_line
            ,p_input_point
            ,p_tolerance
         );
         
         RETURN MDSYS.SDO_LRS.LOCATE_PT(
             p_input_line
            ,num_measure
         );
         
      END get_closer_linepoint;

   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Check over object one and downsize if needed
      --------------------------------------------------------------------------
      int_gtype_1 := p_object_1.get_gtype();
      int_dims_1  := p_object_1.get_dims();
      IF int_dims_1 > 2
      THEN
         sdo_object_1 := dz_sdo_util.downsize_2d(p_object_1);
         
      ELSE
         sdo_object_1 := p_object_1;
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 20
      -- Check over object two and downsize if needed
      --------------------------------------------------------------------------
      int_gtype_2 := p_object_2.get_gtype();
      int_dims_2  := p_object_2.get_dims();
      IF int_dims_2 > 2
      THEN
         sdo_object_2 := dz_sdo_util.downsize_2d(p_object_2);
         
      ELSE
         sdo_object_2 := p_object_2;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Check over object one and downsize if needed
      --------------------------------------------------------------------------
      IF int_gtype_1 = 1
      THEN
         sdo_point_1 := sdo_object_1;
         
      ELSE
         dz_sdo_dissect.deconstruct(
             p_input   => sdo_object_1
            ,p_nodes   => ary_bitbucket
            ,p_edges   => ary_segments_1
         );

      END IF;

      IF int_gtype_2 = 1
      THEN
         sdo_point_2 := sdo_object_2;
         
      ELSE
         dz_sdo_dissect.deconstruct(
             p_input   => sdo_object_2
            ,p_nodes   => ary_bitbucket
            ,p_edges   => ary_segments_2
         );
         
      END IF;

      -- Exit early if by chance they gave us just two points
      IF  sdo_point_1 IS NOT NULL
      AND sdo_point_2 IS NOT NULL
      THEN
         RETURN dz_sdo_dissect.points2segment(
             p_point_one  => sdo_point_1
            ,p_point_two  => sdo_point_2
         );
         
      END IF;

      IF sdo_point_1 IS NOT NULL
      THEN
         sdo_closest_1 := sdo_point_1;
         
      ELSE
         num_closest_distance := NULL;
         num_closest_index    := NULL;
         FOR i IN 1 .. ary_segments_1.COUNT
         LOOP
            num_current_distance := MDSYS.SDO_GEOM.SDO_DISTANCE(
                sdo_object_2
               ,ary_segments_1(i)
               ,p_tolerance
            );
            
            IF num_closest_distance IS NULL
            THEN
               num_closest_distance := num_current_distance;
               num_closest_index    := i;
               
            ELSE
               IF num_current_distance < num_closest_distance
               THEN
                  num_closest_distance := num_current_distance;
                  num_closest_index    := i;
                  
               END IF;
               
            END IF;

         END LOOP;
         
         sdo_closest_1 := MDSYS.SDO_LRS.CONVERT_TO_LRS_GEOM(
             ary_segments_1(num_closest_index)
            ,0
            ,100
         );

      END IF;

      IF sdo_point_2 IS NOT NULL
      THEN
         sdo_closest_2 := sdo_point_2;
         
      ELSE
         num_closest_distance := NULL;
         num_closest_index    := NULL;
         FOR i IN 1 .. ary_segments_2.COUNT
         LOOP
            num_current_distance := MDSYS.SDO_GEOM.SDO_DISTANCE(
                sdo_object_1
               ,ary_segments_2(i)
               ,p_tolerance
            );
            
            IF num_closest_distance IS NULL
            THEN
               num_closest_distance := num_current_distance;
               num_closest_index    := i;
               
            ELSE
               IF num_current_distance < num_closest_distance
               THEN
                  num_closest_distance := num_current_distance;
                  num_closest_index    := i;
               END IF;
               
            END IF;

         END LOOP;
         
         sdo_closest_2 := MDSYS.SDO_LRS.CONVERT_TO_LRS_GEOM(
             ary_segments_2(num_closest_index)
            ,0
            ,100
         );

      END IF;

      sdo_closest_pt_1 := get_closer_endpoint(
          sdo_closest_1
         ,sdo_closest_2
         ,p_tolerance
      );
      sdo_closest_pt_2 := get_closer_endpoint(
          sdo_closest_2
         ,sdo_closest_1
         ,p_tolerance
      );

      sdo_closest_ln_1 := get_closer_linepoint(
          sdo_closest_1
         ,sdo_closest_pt_2
         ,p_tolerance
      );
      sdo_closest_ln_2 := get_closer_linepoint(
          sdo_closest_2
         ,sdo_closest_pt_1
         ,p_tolerance
      );

      IF sdo_point_1 IS NULL
      THEN
         IF MDSYS.SDO_GEOM.SDO_DISTANCE(
             sdo_closest_pt_1
            ,sdo_object_2
            ,p_tolerance
         ) < MDSYS.SDO_GEOM.SDO_DISTANCE(
             sdo_closest_ln_1
            ,sdo_object_2
            ,p_tolerance
         )
         THEN
            sdo_point_1 := sdo_closest_pt_1;
            
         ELSE
            sdo_point_1 := sdo_closest_ln_1;
            
         END IF;
         
      END IF;

      IF sdo_point_2 IS NULL
      THEN
         IF MDSYS.SDO_GEOM.SDO_DISTANCE(
             sdo_closest_pt_2
            ,sdo_object_1
            ,p_tolerance
         ) < MDSYS.SDO_GEOM.SDO_DISTANCE(
             sdo_closest_ln_2
            ,sdo_object_1
            ,p_tolerance
         )
         THEN
            sdo_point_2 := sdo_closest_pt_2;
            
         ELSE
            sdo_point_2 := sdo_closest_ln_2;
            
         END IF;
         
      END IF;

      IF p_output_flag = 'START'
      THEN
         RETURN sdo_point_1;
         
      ELSIF p_output_flag = 'END'
      THEN
         RETURN sdo_point_2;
         
      ELSE
         RETURN dz_sdo_dissect.points2segment(
             p_point_one => sdo_point_1
            ,p_point_two => sdo_point_2
         );
         
      END IF;

   END get_shortest_connecting_line;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE nearest_by_distance(
       p_input     IN  MDSYS.SDO_GEOMETRY
      ,p_sdo_array IN  MDSYS.SDO_GEOMETRY_ARRAY
      ,p_tolerance IN  NUMBER
      ,p_unit      IN  VARCHAR2 DEFAULT NULL
      ,p_output    OUT MDSYS.SDO_GEOMETRY
      ,p_distance  OUT NUMBER
   )
   AS
      num_tolerance NUMBER := p_tolerance;
      str_unit      VARCHAR2(4000 Char) := UPPER(p_unit);
      num_distance  NUMBER;
      num_nearest   NUMBER;
      
   BEGIN 
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF num_tolerance IS NULL
      THEN
         num_tolerance := 0.05;
         
      END IF;
      
      IF p_sdo_array IS NULL
      OR p_sdo_array.COUNT = 0
      THEN
         p_output := NULL;
         p_distance := NULL;
         RETURN;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Loop through the candidates and choose one
      --------------------------------------------------------------------------
      FOR i IN 1 .. p_sdo_array.COUNT
      LOOP
         IF str_unit IS NULL
         THEN
            num_distance := MDSYS.SDO_GEOM.SDO_DISTANCE(
                geom1  => p_input
               ,geom2  => p_sdo_array(i)
               ,tol    => num_tolerance
            );
            
         ELSE
            num_distance := MDSYS.SDO_GEOM.SDO_DISTANCE(
                geom1  => p_input
               ,geom2  => p_sdo_array(i)
               ,tol    => num_tolerance
               ,unit   => str_unit
            );
            
         END IF;
         
         IF num_nearest IS NULL
         OR num_distance < num_nearest
         THEN
            num_nearest := num_distance;
            p_output    := p_sdo_array(i);
            p_distance  := num_distance;
            
         END IF;            
      
      END LOOP;
      
   END nearest_by_distance;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION string_midpoint(
       p_input               IN  MDSYS.SDO_GEOMETRY
      ,p_debuginfo           IN  VARCHAR2 DEFAULT NULL
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      num_vertices   NUMBER;
      sdo_lrsstring  MDSYS.SDO_GEOMETRY;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF p_input IS NULL
      THEN
         RETURN NULL;
         
      ELSIF p_input.get_gtype() <> 2
      THEN
          RAISE_APPLICATION_ERROR(
              -20001
             ,'input must be single linestring'
          );
          
      END IF;
      
      num_vertices := sdo_util.getnumvertices(
         p_input
      );
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Convert to LRS
      --------------------------------------------------------------------------
      BEGIN
         sdo_lrsstring := MDSYS.SDO_LRS.CONVERT_TO_LRS_GEOM(
             dz_sdo_util.downsize_2d(p_input)
            ,1
            ,100
         );
      
      EXCEPTION
         WHEN OTHERS
         THEN
            dbms_output.put_line(p_debuginfo);
            dbms_output.put_line(
               MDSYS.SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(p_input,0.05)
            );
            
            RAISE;
            
      END;
               
      --------------------------------------------------------------------------
      -- Step 30
      -- Return midpoint
      --------------------------------------------------------------------------
      IF p_input.get_dims() = 2
      THEN
         RETURN dz_sdo_util.downsize_2d(
            p_input => MDSYS.SDO_LRS.LOCATE_PT(
                sdo_lrsstring
               ,50
            )
         );
         
      ELSIF p_input.get_dims() > 2 AND
      p_input.get_lrs_dim() <> 0
      THEN
         RETURN MDSYS.SDO_LRS.PROJECT_PT(
             p_input
            ,MDSYS.SDO_LRS.LOCATE_PT(
                 sdo_lrsstring
                ,50
             )
         );
         
      ELSIF p_input.get_dims() = 3 AND
      p_input.get_lrs_dim() = 0
      THEN   
         RETURN dz_sdo_util.downsize_3d(
            p_input => MDSYS.SDO_LRS.PROJECT_PT(
                p_input
               ,MDSYS.SDO_LRS.LOCATE_PT(
                    sdo_lrsstring
                   ,50
                )
            )
         );
         
      ELSIF p_input.get_dims() = 4 AND
      p_input.get_lrs_dim() = 0
      THEN   
         RETURN MDSYS.SDO_LRS.PROJECT_PT(
             p_input
            ,MDSYS.SDO_LRS.LOCATE_PT(
                 sdo_lrsstring
                ,50
             )
         );
         
      END IF;
   
   END string_midpoint;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION self_union(
       p_input         IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance     IN  NUMBER DEFAULT 0.05
      ,p_project_srid  IN  NUMBER DEFAULT NULL
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      sdo_input     MDSYS.SDO_GEOMETRY := p_input;
      sdo_output    MDSYS.SDO_GEOMETRY;
      num_tolerance NUMBER := p_tolerance; 
      str_validate  VARCHAR2(4000 Char);
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF sdo_input IS NULL
      THEN
         RETURN NULL;
         
      END IF;
      
      IF sdo_input.get_gtype() NOT IN (3,7)
      THEN
         RAISE_APPLICATION_ERROR(-20001,'input must be polygon');
         
      END IF;
      
      IF num_tolerance IS NULL
      THEN
         num_tolerance := 0.05;
         
      END IF;
      
      str_validate := MDSYS.SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(
          sdo_input
         ,num_tolerance
      );
         
      IF str_validate = 'TRUE'
      THEN
         RETURN sdo_input;
            
      END IF;
         
      -- there are some errors we should not try to correct, I would check for
      -- them here
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Reproject if requested
      --------------------------------------------------------------------------
      IF p_project_srid IS NOT NULL
      THEN
         sdo_input := MDSYS.SDO_CS.TRANSFORM(
             geom     => sdo_input
            ,to_srid  => p_project_srid
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Execute the union
      --------------------------------------------------------------------------
      sdo_output := dz_sdo_util.scrub_polygons(
         MDSYS.SDO_GEOM.SDO_UNION(
             sdo_input
            ,sdo_input
            ,num_tolerance
         )
      );
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Reproject if required
      --------------------------------------------------------------------------
      IF p_project_srid IS NOT NULL
      THEN
         sdo_output := MDSYS.SDO_CS.TRANSFORM(
             geom     => sdo_output
            ,to_srid  => p_input.SDO_SRID
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Return what we got
      --------------------------------------------------------------------------
      RETURN sdo_output;
      
   END self_union;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION self_union_force(
       p_input               IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance           IN  NUMBER DEFAULT 0.05
      ,p_project_srid        IN  NUMBER DEFAULT NULL
      ,p_tolerance_increment IN  NUMBER DEFAULT 0.02
      ,p_maximum_increment   IN  NUMBER DEFAULT 25
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      sdo_input     MDSYS.SDO_GEOMETRY := p_input;
      sdo_output    MDSYS.SDO_GEOMETRY;
      num_tolerance NUMBER := p_tolerance; 
      str_validate  VARCHAR2(4000);
      num_tolerance_increment NUMBER := p_tolerance_increment;
      num_maximum_increment   NUMBER := p_maximum_increment;
      num_current_tolerance   NUMBER;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF sdo_input IS NULL
      THEN
         RETURN NULL;
         
      END IF;
      
      IF sdo_input.get_gtype() NOT IN (3,7)
      THEN
         RAISE_APPLICATION_ERROR(-20001,'input must be polygon');
         
      END IF;
      
      IF num_tolerance IS NULL
      THEN
         num_tolerance := 0.05;
         
      END IF;
      
      IF num_tolerance_increment IS NULL
      THEN
         num_tolerance_increment := 0.02;
         
      END IF;
      
      IF num_maximum_increment IS NULL
      THEN
         num_maximum_increment := 25;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Loop around trying to force the union
      --------------------------------------------------------------------------
      num_current_tolerance := num_tolerance;
      FOR i IN 1 .. num_maximum_increment
      LOOP
         sdo_output := self_union(
             sdo_input
            ,num_current_tolerance
            ,p_project_srid
         );
         
         str_validate := MDSYS.SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(
             sdo_output
            ,num_tolerance
         );
         IF str_validate = 'TRUE'
         THEN
            RETURN sdo_output;
            
         END IF;
         
         num_current_tolerance := num_current_tolerance + num_tolerance_increment;
         
      END LOOP;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- If we utterly failed, return the input geometry
      --------------------------------------------------------------------------
      RETURN p_input;
      
   END self_union_force;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION remove_dup_vertices(
       p_input               IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance           IN  NUMBER DEFAULT 0.05
      ,p_project_srid        IN  NUMBER DEFAULT NULL
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      sdo_input       MDSYS.SDO_GEOMETRY := p_input;
      sdo_output      MDSYS.SDO_GEOMETRY;
      num_tolerance   NUMBER := p_tolerance; 
      str_validate    VARCHAR2(4000 Char);
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------  
      IF sdo_input IS NULL
      THEN
         RETURN NULL;
         
      END IF;
      
      IF num_tolerance IS NULL
      THEN
         num_tolerance := 0.05;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Inspect incoming geometry
      --------------------------------------------------------------------------
      IF sdo_input.get_gtype() NOT IN (2,6)
      THEN
         RAISE_APPLICATION_ERROR(-20001,'input must be linestring');
         
      END IF;
   
      str_validate := MDSYS.SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(
          sdo_input
         ,num_tolerance
      );
      
      IF str_validate = 'TRUE'
      THEN
         RETURN sdo_input;
         
      END IF;
      
      -- there are some errors we should not try to correct, I would check for
      -- them here
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Reproject if requested
      --------------------------------------------------------------------------
      IF p_project_srid IS NOT NULL
      THEN
         sdo_input := MDSYS.SDO_CS.TRANSFORM(
             sdo_input
            ,p_project_srid
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Execute remove duplicate vertices
      --------------------------------------------------------------------------
      sdo_output := dz_sdo_util.scrub_lines(
         MDSYS.SDO_UTIL.REMOVE_DUPLICATE_VERTICES(
            sdo_input,
            num_tolerance
         )
      );
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Reproject if required
      --------------------------------------------------------------------------
      IF p_project_srid IS NOT NULL
      THEN
         sdo_output := MDSYS.SDO_CS.TRANSFORM(
             sdo_output
            ,p_input.SDO_SRID
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Return what we got
      --------------------------------------------------------------------------
      RETURN sdo_output;
   
   END remove_dup_vertices;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION remove_dup_vertices_force(
       p_input               IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance           IN  NUMBER DEFAULT 0.05
      ,p_project_srid        IN  NUMBER DEFAULT NULL
      ,p_tolerance_increment IN  NUMBER DEFAULT 0.02
      ,p_maximum_increment   IN  NUMBER DEFAULT 25
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      sdo_input               MDSYS.SDO_GEOMETRY := p_input;
      sdo_output              MDSYS.SDO_GEOMETRY;
      num_tolerance           NUMBER := p_tolerance; 
      str_validate            VARCHAR2(4000 Char);
      num_tolerance_increment NUMBER := p_tolerance_increment;
      num_maximum_increment   NUMBER := p_maximum_increment;
      num_current_tolerance   NUMBER;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF sdo_input IS NULL
      THEN
         RETURN NULL;
         
      END IF;
      
      IF sdo_input.get_gtype() NOT IN (2,6)
      THEN
         RAISE_APPLICATION_ERROR(-20001,'input must be linestring');
         
      END IF;
      
      IF num_tolerance IS NULL
      THEN
         num_tolerance := 0.05;
         
      END IF;
      
      IF num_tolerance_increment IS NULL
      THEN
         num_tolerance_increment := 0.02;
         
      END IF;
      
      IF num_maximum_increment IS NULL
      THEN
         num_maximum_increment := 25;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Loop around trying to force the removal of duplicates
      --------------------------------------------------------------------------
      num_current_tolerance := num_tolerance;
      FOR i IN 1 .. num_maximum_increment
      LOOP
         sdo_output := remove_dup_vertices(
             p_input        => sdo_input
            ,p_tolerance    => num_current_tolerance
            ,p_project_srid => p_project_srid
         );
         
         str_validate := MDSYS.SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(
             sdo_output
            ,num_tolerance
         );
         IF str_validate = 'TRUE'
         THEN
            RETURN sdo_output;
            
         END IF;
         
         num_current_tolerance := num_current_tolerance + num_tolerance_increment;
         
      END LOOP;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- If we utterly failed, return the input geometry
      --------------------------------------------------------------------------
      RETURN p_input;
   
   END remove_dup_vertices_force;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE polygon_edge_from_interior(
       p_input_point   IN  MDSYS.SDO_GEOMETRY
      ,p_outer_polygon IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance     IN  NUMBER DEFAULT 0.05
      ,p_unit          IN  VARCHAR2 DEFAULT 'KM'
      ,p_edge_point    OUT MDSYS.SDO_GEOMETRY
      ,p_edge_distance OUT NUMBER
   )
   AS
      num_tolerance   NUMBER := p_tolerance;
      str_unit        VARCHAR2(4000 Char) := UPPER(p_unit);
      str_test        VARCHAR2(4000 Char);
      sdo_outer_poly  MDSYS.SDO_GEOMETRY;
      sdo_outer_ring  MDSYS.SDO_GEOMETRY;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF num_tolerance IS NULL
      THEN
         num_tolerance := 0.05;
         
      END IF;
      
      IF str_unit IS NULL
      THEN
         str_unit := 'KM';
         
      END IF;
      
      IF p_input_point.get_gtype() <> 1
      THEN
         RAISE_APPLICATION_ERROR(-20001,'input point must be a single point');
         
      END IF;
      
      IF p_outer_polygon.get_gtype() NOT IN (3,7)
      THEN
         RAISE_APPLICATION_ERROR(
             -20001
            ,'input polygon must be a polygon or multipolygon'
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Check that the point is really inside (or touches) the polygon
      --------------------------------------------------------------------------
      str_test := MDSYS.SDO_GEOM.RELATE(
          p_outer_polygon
         ,'DETERMINE'
         ,p_input_point
         ,num_tolerance
      );
      
      IF str_test = 'TOUCH'
      THEN
         p_edge_point    := p_input_point;
         p_edge_distance := 0;
         RETURN;
         
      ELSIF str_test = 'CONTAINS'
      THEN
         -- Onward!
         NULL;
         
      ELSE
         p_edge_point    := NULL;
         p_edge_distance := NULL;
         RETURN;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- If its a multipolygon, tease out the required ring
      --------------------------------------------------------------------------
      IF p_outer_polygon.get_gtype() = 7
      THEN
         FOR i IN 1 .. MDSYS.SDO_UTIL.GETNUMELEM(p_outer_polygon)
         LOOP
            IF MDSYS.SDO_GEOM.RELATE(
                MDSYS.SDO_UTIL.EXTRACT(p_outer_polygon,i)
               ,'CONTAINS'
               ,p_input_point
               ,num_tolerance
            ) = 'CONTAINS'
            THEN
               sdo_outer_poly := MDSYS.SDO_UTIL.EXTRACT(p_outer_polygon,i);
               
            END IF;
            
         END LOOP;
         
         IF sdo_outer_poly IS NULL
         THEN
            RAISE_APPLICATION_ERROR(
                -20001
               ,'cannot determine which component polygon contains the point'
            );
            
         END IF;
         
      ELSE
         sdo_outer_poly := p_outer_polygon;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Convert the polygon into an LRS linestring.  
      --------------------------------------------------------------------------
      sdo_outer_ring := MDSYS.SDO_LRS.CONVERT_TO_LRS_GEOM(
         MDSYS.SDO_UTIL.POLYGONTOLINE(sdo_outer_poly)
      );
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Get the nearest point on the LRS linestring to the point  
      --------------------------------------------------------------------------
      p_edge_point := MDSYS.SDO_LRS.CONVERT_TO_STD_GEOM(
         MDSYS.SDO_LRS.PROJECT_PT(
             sdo_outer_ring
            ,p_input_point
            ,0.00000001
         )
      );
      
      p_edge_distance := MDSYS.SDO_GEOM.SDO_DISTANCE(
          p_edge_point
         ,p_input_point
         ,num_tolerance
         ,'UNIT=' || str_unit
      );
      
   END polygon_edge_from_interior;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE safe_buffer(
       p_input         IN  MDSYS.SDO_GEOMETRY
      ,p_distance      IN  NUMBER
      ,p_tolerance     IN  NUMBER
      ,p_params        IN  VARCHAR2 DEFAULT NULL
      ,p_output        OUT MDSYS.SDO_GEOMETRY
      ,p_sqlcode       OUT NUMBER
      ,p_sqlerrm       OUT VARCHAR2
   )
   AS
   BEGIN
   
      p_sqlcode := 0;
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Trap specific errors that can be ignored and returned as NULL
      --------------------------------------------------------------------------
      BEGIN
         p_output := MDSYS.SDO_GEOM.SDO_BUFFER(
             geom   => p_input
            ,dist   => p_distance
            ,tol    => p_tolerance
            ,params => p_params
         );
         
      EXCEPTION
         WHEN OTHERS
         THEN
            p_sqlcode := SQLCODE;
            p_sqlerrm := SQLERRM;
            RETURN;
      
      END;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Remove annoying lines and points
      --------------------------------------------------------------------------
      IF p_output IS NOT NULL
      AND p_output.get_gtype() NOT IN (3,7)
      THEN
         p_output := dz_sdo_util.scrub_polygons(
            p_input => p_output
         );
         
      END IF;
         
   END safe_buffer;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION smart_buffer(
       p_input            IN  MDSYS.SDO_GEOMETRY
      ,p_distance         IN  NUMBER
      ,p_tolerance        IN  NUMBER
      ,p_params           IN  VARCHAR2 DEFAULT NULL
      ,p_tolerance_tries  IN  NUMBER   DEFAULT 10
      ,p_tolerance_incrmt IN  NUMBER   DEFAULT 0.01
      ,p_simplify_thresh  IN  NUMBER   DEFAULT 0.1
      ,p_return_null      IN  VARCHAR2 DEFAULT 'TRUE'
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      str_return_null      VARCHAR2(4000 Char) := UPPER(p_return_null);
      num_tolerance        NUMBER := p_tolerance;
      num_tries            NUMBER := p_tolerance_tries;
      num_tolerance_incrmt NUMBER := p_tolerance_incrmt;
      sdo_input            MDSYS.SDO_GEOMETRY := p_input;
      sdo_output           MDSYS.SDO_GEOMETRY;
      num_sqlcode          NUMBER;
      str_sqlerrm          VARCHAR2(4000 Char);
      str_validate         VARCHAR2(4000 Char);
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF sdo_input IS NULL
      THEN
         IF str_return_null = 'TRUE'
         THEN
            RETURN NULL;
            
         ELSE
            RAISE_APPLICATION_ERROR(-20001,'input geometry is NULL');
            
         END IF;
         
      END IF;
      
      IF num_tolerance IS NULL
      THEN
         num_tolerance := 0.05;
         
      END IF;
      
      IF num_tries IS NULL
      THEN
         num_tries := 10;
         
      END IF;
      
      IF num_tolerance_incrmt IS NULL
      THEN
         num_tolerance_incrmt := 0.01;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Set up the loop of attempts
      --------------------------------------------------------------------------
      FOR i IN 1 .. num_tries
      LOOP
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Hope for the best
      --------------------------------------------------------------------------
         safe_buffer(
             p_input     => sdo_input
            ,p_distance  => p_distance
            ,p_tolerance => num_tolerance
            ,p_params    => p_params
            ,p_output    => sdo_output
            ,p_sqlcode   => num_sqlcode
            ,p_sqlerrm   => str_sqlerrm
         );
      
      --------------------------------------------------------------------------
      -- Step 40
      -- See what came back and attempt to fix
      --------------------------------------------------------------------------
         IF sdo_output IS NOT NULL
         AND num_sqlcode IS NULL
         THEN
             str_validate := MDSYS.SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(
                 sdo_output
                ,num_tolerance
             );
             
             IF str_validate = 'TRUE'
             THEN
                RETURN sdo_output;
                
             END IF;
             
             -- INSERT SPECIFIC FIXES HERE
             
         END IF;
         
      --------------------------------------------------------------------------
      -- Step 50
      -- So at this point the geometry is not fixable at this tolerance
      --------------------------------------------------------------------------
         num_tolerance := num_tolerance + num_tolerance_incrmt;
         
      END LOOP;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Tolerance giggling failed so now try generalization trick
      --------------------------------------------------------------------------
      num_tolerance := p_tolerance;
      
      sdo_input := MDSYS.SDO_UTIL.SIMPLIFY(
          p_input
         ,p_simplify_thresh
      );
      
      safe_buffer(
          p_input     => sdo_input
         ,p_distance  => p_distance
         ,p_tolerance => num_tolerance
         ,p_params    => p_params
         ,p_output    => sdo_output
         ,p_sqlcode   => num_sqlcode
         ,p_sqlerrm   => str_sqlerrm
      );
      
      --------------------------------------------------------------------------
      -- Step 70
      -- See if anything better came back
      --------------------------------------------------------------------------
      IF sdo_output IS NOT NULL
      AND num_sqlcode IS NULL
      THEN
          str_validate := MDSYS.SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(
              sdo_output
             ,num_tolerance
          );
             
          IF str_validate = 'TRUE'
          THEN
             RETURN sdo_output;
             
          END IF;
             
          -- INSERT SPECIFIC FIXES HERE
             
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 80
      -- Not sure what to try here
      --------------------------------------------------------------------------
      RETURN NULL;   
      
   END smart_buffer;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION polygon_merge_cutter(
       p_base          IN  MDSYS.SDO_GEOMETRY
      ,p_cutter        IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance     IN  NUMBER DEFAULT 0.05
      ,p_srid          IN  NUMBER DEFAULT NULL
      ,p_careful       IN  VARCHAR2 DEFAULT 'FALSE'
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      sdo_temp MDSYS.SDO_GEOMETRY := p_base;

   BEGIN
      polygon_merge_cutter(
          p_base          => sdo_temp
         ,p_cutter        => p_cutter
         ,p_tolerance     => p_tolerance
         ,p_srid          => p_srid
         ,p_careful       => p_careful
      );

      RETURN sdo_temp;

   END polygon_merge_cutter;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE polygon_merge_cutter(
       p_base          IN OUT MDSYS.SDO_GEOMETRY
      ,p_cutter        IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance     IN  NUMBER DEFAULT 0.05
      ,p_srid          IN  NUMBER DEFAULT NULL
      ,p_careful       IN  VARCHAR2 DEFAULT 'FALSE'
   )
   AS
      sdo_base      MDSYS.SDO_GEOMETRY := p_base;
      sdo_cutter    MDSYS.SDO_GEOMETRY := p_cutter;
      sdo_inter     MDSYS.SDO_GEOMETRY;
      sdo_diff      MDSYS.SDO_GEOMETRY;
      sdo_working   MDSYS.SDO_GEOMETRY;
      num_tolerance NUMBER := p_tolerance;
      num_srid      NUMBER := p_srid;
      num_srid_orig NUMBER;
      str_careful   VARCHAR2(4000 Char) := UPPER(p_careful);

   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF sdo_base IS NULL
      OR sdo_cutter IS NULL
      THEN
         RETURN;
         
      END IF;
      
      IF sdo_base.get_gtype() NOT IN (3,7)
      OR sdo_cutter.get_gtype() NOT IN (3,7)
      THEN
         RAISE_APPLICATION_ERROR(-20001,'procedure intended for polygons only');
         
      END IF;
      
      IF num_tolerance IS NULL
      OR num_tolerance < 0.05
      THEN
         num_tolerance := 0.05;
         
      END IF;
      
      IF str_careful IS NULL
      THEN
         str_careful := 'FALSE';
         
      END IF;
      
      IF num_srid IS NOT NULL
      THEN
         num_srid_orig := sdo_base.sdo_srid;
         
         IF num_srid_orig = num_srid
         THEN
            num_srid := NULL;
            
         END IF;
         
      END IF;

      IF num_srid IS NOT NULL
      THEN
         sdo_base   := MDSYS.SDO_CS.TRANSFORM(sdo_base,num_srid);
         sdo_cutter := MDSYS.SDO_CS.TRANSFORM(sdo_cutter,num_srid);
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 20
      -- Simplest case of single polygon by single polygon
      --------------------------------------------------------------------------
      IF  sdo_base.get_gtype() = 3
      AND sdo_cutter.get_gtype() = 3
      THEN
         sdo_inter := dz_sdo_util.scrub_polygons(
             MDSYS.SDO_GEOM.SDO_INTERSECTION(
                 sdo_base
                ,sdo_cutter
                ,num_tolerance
             )
         );

         IF sdo_inter IS NULL
         THEN
            RETURN;
            
         END IF;

         sdo_diff := dz_sdo_util.scrub_polygons(
             MDSYS.SDO_GEOM.SDO_DIFFERENCE(
                 sdo_base
                ,sdo_cutter
                ,num_tolerance
             )
         );

         p_base := MDSYS.SDO_UTIL.APPEND(
             sdo_inter
            ,sdo_diff
         );
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Recursive bust it by multipolygons
      --------------------------------------------------------------------------
      ELSE
         p_base := NULL;
         
         FOR i IN 1 .. MDSYS.SDO_UTIL.GETNUMELEM(sdo_base)
         LOOP
            sdo_working := MDSYS.SDO_UTIL.EXTRACT(sdo_base,i);
            
            FOR j IN 1 .. MDSYS.SDO_UTIL.GETNUMELEM(sdo_cutter)
            LOOP
               polygon_merge_cutter(
                   p_base       => sdo_working
                  ,p_cutter     => MDSYS.SDO_UTIL.EXTRACT(sdo_cutter,j)
                  ,p_tolerance  => num_tolerance
                  ,p_careful    => str_careful
               );
               
            END LOOP;
            
            p_base := MDSYS.SDO_UTIL.APPEND(
                p_base
               ,sdo_working
            );
         
         END LOOP;
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Replace the original srid
      --------------------------------------------------------------------------
      IF num_srid IS NOT NULL
      THEN
         p_base := MDSYS.SDO_CS.TRANSFORM(
             p_base
            ,num_srid_orig
         );
         
      END IF;
      
   END polygon_merge_cutter;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE reasonable_endpoints(
       p_input            IN  MDSYS.SDO_GEOMETRY
      ,p_start_point      OUT MDSYS.SDO_GEOMETRY
      ,p_end_point        OUT MDSYS.SDO_GEOMETRY
      ,p_tuning           IN  NUMBER DEFAULT 1
   )
   AS
      sdo_lrs_input MDSYS.SDO_GEOMETRY;
      
   BEGIN
   
      IF p_input IS NULL
      THEN
         RETURN;
         
      END IF;
      
      IF p_input.get_gtype() <> 2
      THEN
         RAISE_APPLICATION_ERROR(-20001,'linestring only');
         
      END IF;
      
      sdo_lrs_input := MDSYS.SDO_LRS.CONVERT_TO_LRS_GEOM(
          standard_geom  => p_input
         ,start_measure  => 0
         ,end_measure    => 100
      );
      
      p_start_point := dz_sdo_util.downsize_2d(
         MDSYS.SDO_LRS.LOCATE_PT(
             geom_segment => sdo_lrs_input
            ,measure      => 10
         )
      );
      
      p_end_point := dz_sdo_util.downsize_2d(
         MDSYS.SDO_LRS.LOCATE_PT(
             geom_segment => sdo_lrs_input
            ,measure      => 90
         )
      );
      
   END reasonable_endpoints;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION filter_linestrings(
       p_input            IN  MDSYS.SDO_GEOMETRY
      ,p_filter_threshold IN  NUMBER
      ,p_units            IN  VARCHAR2 DEFAULT NULL
      ,p_tolerance        IN  NUMBER DEFAULT 0.05
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      sdo_output    MDSYS.SDO_GEOMETRY;
      sdo_temp      MDSYS.SDO_GEOMETRY;
      num_length    NUMBER;
      str_units     VARCHAR2(4000 Char) := p_units;
      num_tolerance NUMBER := p_tolerance;
      
   BEGIN
   
      IF p_input IS NULL
      THEN
         RETURN NULL;
         
      END IF;
      
      IF num_tolerance IS NULL
      THEN
         num_tolerance := 0.05;
      
      END IF;
      
      IF p_input.get_gtype() NOT IN (2,6)
      THEN
         RAISE_APPLICATION_ERROR(-20001,'linestring utility');
         
      END IF;
      
      IF str_units IS NOT NULL
      THEN
         str_units := dz_sdo_util.validate_unit(str_units);
         
      END IF;
      
      FOR i IN 1 .. MDSYS.SDO_UTIL.GETNUMELEM(p_input)
      LOOP
         sdo_temp := MDSYS.SDO_UTIL.EXTRACT(p_input,i);
         num_length := dz_sdo_util.dz_length(sdo_temp,num_tolerance,str_units);
         
         IF num_length >= p_filter_threshold
         THEN
            IF sdo_output IS NULL
            THEN
               sdo_output := sdo_temp;
               
            ELSE
               sdo_output := MDSYS.SDO_UTIL.APPEND(sdo_output,sdo_temp);
            
            END IF;
         
         END IF;
      
      END LOOP;
      
      RETURN MDSYS.SDO_GEOM.SDO_UNION(
          sdo_output
         ,sdo_output
         ,num_tolerance
      );
   
   END filter_linestrings;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION reorient_ordinate_array_ring(
       p_input            IN  MDSYS.SDO_ORDINATE_ARRAY
      ,p_vertice          IN  NUMBER
      ,p_num_dims         IN  NUMBER DEFAULT 2
      ,p_force_direction  IN  VARCHAR2 DEFAULT NULL
   ) RETURN MDSYS.SDO_ORDINATE_ARRAY
   AS
      int_num_dims  PLS_INTEGER := p_num_dims;
      int_ordinates PLS_INTEGER;
      int_vertices  PLS_INTEGER;
      sdoord_output MDSYS.SDO_ORDINATE_ARRAY;
      int_counter   PLS_INTEGER;
      
   BEGIN
   
      IF p_input IS NULL
      OR p_vertice IS NULL
      OR p_vertice = 0
      THEN
         RETURN NULL;
      
      END IF;
      
      IF int_num_dims IS NULL
      THEN
         int_num_dims := 2;
         
      END IF;
      
      int_ordinates := p_input.COUNT;
      int_vertices := int_ordinates / int_num_dims;
      
      IF p_vertice = 1
      OR p_vertice >= int_vertices
      THEN
         RETURN p_input;
         
      END IF;
      
      sdoord_output := MDSYS.SDO_ORDINATE_ARRAY();
      sdoord_output.EXTEND(int_ordinates);
      int_counter := 1;
      
      FOR i IN p_vertice .. int_vertices - 1 
      LOOP
         sdoord_output(int_counter) := p_input( (i * int_num_dims) - (int_num_dims - 1 ) );
         int_counter := int_counter + 1;
         
         sdoord_output(int_counter) := p_input( (i * int_num_dims) - (int_num_dims - 2 ) );
         int_counter := int_counter + 1;
         
         IF int_num_dims > 2
         THEN
            sdoord_output(int_counter) := p_input( (i * int_num_dims) - (int_num_dims - 3 ) );
            int_counter := int_counter + 1;
         
         END IF;
         
         IF int_num_dims > 3
         THEN
            sdoord_output(int_counter) := p_input( (i * int_num_dims) - (int_num_dims - 4 ) );
            int_counter := int_counter + 1;
         
         END IF;
         
      END LOOP;
         
      FOR i IN 1 .. p_vertice
      LOOP
         sdoord_output(int_counter) := p_input( (i * int_num_dims) - (int_num_dims - 1 ) );
         int_counter := int_counter + 1;
         
         sdoord_output(int_counter) := p_input( (i * int_num_dims) - (int_num_dims - 2 ) );
         int_counter := int_counter + 1;
         
         IF int_num_dims > 2
         THEN
            sdoord_output(int_counter) := p_input( (i * int_num_dims) - (int_num_dims - 3 ) );
            int_counter := int_counter + 1;
         
         END IF;
         
         IF int_num_dims > 3
         THEN
            sdoord_output(int_counter) := p_input( (i * int_num_dims) - (int_num_dims - 4 ) );
            int_counter := int_counter + 1;
         
         END IF;
         
      END LOOP;
      
      IF p_force_direction = 'CW'
      THEN
         IF dz_sdo_util.test_ordinate_rotation(
             p_input    => sdoord_output
            ,p_num_dims => int_num_dims
         ) = 'CCW'
         THEN
            sdoord_output := dz_sdo_util.reverse_ordinate_rotation(
                p_input    => sdoord_output
               ,p_num_dims => int_num_dims
            );
         
         END IF;
      
      ELSIF p_force_direction = 'CCW'
      THEN
         IF dz_sdo_util.test_ordinate_rotation(
             p_input    => sdoord_output
            ,p_num_dims => int_num_dims
         ) = 'CW'
         THEN
            sdoord_output := dz_sdo_util.reverse_ordinate_rotation(
                p_input    => sdoord_output
               ,p_num_dims => int_num_dims
            );
         
         END IF;
         
      END IF;     
         
      RETURN sdoord_output;
   
   END reorient_ordinate_array_ring;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION reorient_geometry_ring(
       p_input            IN  MDSYS.SDO_GEOMETRY
      ,p_vertice          IN  NUMBER
      ,p_force_direction  IN  VARCHAR2 DEFAULT NULL
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
   BEGIN
      
      IF p_input IS NULL
      OR p_vertice IS NULL
      OR p_vertice = 0
      THEN
         RETURN NULL;
         
      END IF;
      
      IF p_input.get_gtype <> 2
      THEN
         RAISE_APPLICATION_ERROR(-20001,'input must be single ring');
         
      END IF;
      
      RETURN MDSYS.SDO_GEOMETRY(
          p_input.SDO_GTYPE
         ,p_input.SDO_SRID
         ,NULL
         ,p_input.SDO_ELEM_INFO
         ,reorient_ordinate_array_ring(
              p_input            => p_input.SDO_ORDINATES
             ,p_vertice          => p_vertice
             ,p_num_dims         => p_input.get_dims()
             ,p_force_direction  => p_force_direction
          )
      );
      
   END reorient_geometry_ring;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION reorient_geometry_ring(
       p_input            IN  MDSYS.SDO_GEOMETRY
      ,p_vertice          IN  MDSYS.SDO_GEOMETRY
      ,p_force_direction  IN  VARCHAR2 DEFAULT NULL
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      num_lrs_dim    NUMBER;
      sdo_lrs_input  MDSYS.SDO_GEOMETRY;
      sdo_project_pt MDSYS.SDO_GEOMETRY;
      sdo_part_1     MDSYS.SDO_GEOMETRY;
      sdo_part_2     MDSYS.SDO_GEOMETRY;
      num_project_pt NUMBER;
      num_vertices   PLS_INTEGER;
      sdo_output     MDSYS.SDO_GEOMETRY;
      
   BEGIN
      
      IF p_input IS NULL
      OR p_vertice IS NULL
      THEN
         RETURN NULL;
         
      END IF;
      
      IF p_input.get_gtype <> 2
      THEN
         RAISE_APPLICATION_ERROR(-20001,'input must be single ring');
         
      END IF;
      
      num_lrs_dim := p_input.get_lrs_dim();
      
      IF ( p_input.get_dims = 3 AND num_lrs_dim = 0 )
      OR p_input.get_dims = 4
      THEN
         RAISE_APPLICATION_ERROR(-20001,'3D not implemented');
         
      END IF;
      
      IF num_lrs_dim = 0
      THEN
         sdo_lrs_input := MDSYS.SDO_LRS.CONVERT_TO_LRS_GEOM(
             standard_geom => p_input
            ,start_measure => 100
            ,end_measure   => 0
         );
      
      ELSE
         sdo_lrs_input := p_input;
         
      END IF;
      
      sdo_project_pt := MDSYS.SDO_LRS.PROJECT_PT(
          geom_segment => sdo_lrs_input
         ,point        => p_vertice
      );
      
      num_project_pt := MDSYS.SDO_LRS.GET_MEASURE(
         point         => sdo_project_pt
      );
      
      -- Avoid fuzziness at endpoints
      IF num_project_pt > 99.99999
      THEN
         num_project_pt := 100;
         
      ELSIF num_project_pt < 0.00001
      THEN
         num_project_pt := 0;
         
      END IF;
      
      IF MDSYS.SDO_LRS.IS_SHAPE_PT_MEASURE(
          geom_segment => sdo_lrs_input
         ,measure      => num_project_pt
      ) <> 'TRUE'
      THEN
         MDSYS.SDO_LRS.SPLIT_GEOM_SEGMENT(
             geom_segment  => sdo_lrs_input
            ,split_measure => num_project_pt
            ,segment_1     => sdo_part_1
            ,segment_2     => sdo_part_2
         );
      
         sdo_lrs_input := MDSYS.SDO_LRS.CONCATENATE_GEOM_SEGMENTS(
             geom_segment_1 => sdo_part_1
            ,geom_segment_2 => sdo_part_2
         );
         
      END IF;
      
      num_vertices := NULL;
      FOR i IN 1 .. sdo_lrs_input.SDO_ORDINATES.COUNT / 3
      LOOP
         IF sdo_lrs_input.SDO_ORDINATES(i * 3) = num_project_pt
         THEN
            num_vertices := i;
            EXIT;
            
         END IF;
      
      END LOOP;
      
      IF num_vertices IS NULL
      THEN
         --dbms_output.put_line(num_project_pt);
         --dbms_output.put_line(substr(dz_sdo_sqltext.sdo2sql(sdo_lrs_input),1,4000));
         RAISE_APPLICATION_ERROR(
             -20001
            ,'unable to find proper m value'
         );
         
      END IF;
      
      IF num_lrs_dim = 0
      THEN
         sdo_output := dz_sdo_util.downsize_2d(sdo_lrs_input);
         
      ELSE
         sdo_output := sdo_lrs_input;
      
      END IF;
      
      sdo_output := reorient_geometry_ring(
          p_input            => sdo_output
         ,p_vertice          => num_vertices
         ,p_force_direction  => p_force_direction
      );
      
      RETURN sdo_output;
      
   END reorient_geometry_ring;
      
END dz_sdo_main;
/

