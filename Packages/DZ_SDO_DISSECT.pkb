CREATE OR REPLACE PACKAGE BODY dz_sdo_dissect
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION multistring_gap(
       p_input      IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance  IN  NUMBER   DEFAULT 0.05
      ,p_unit       IN  VARCHAR2 DEFAULT 'KM'
   ) RETURN NUMBER
   AS
      num_tolerance     NUMBER := p_tolerance;
      ary_sdo           MDSYS.SDO_GEOMETRY_ARRAY;
      nodes_start_array MDSYS.SDO_GEOMETRY_ARRAY;
      nodes_end_array   MDSYS.SDO_GEOMETRY_ARRAY;
      int_index         PLS_INTEGER;
      num_array         MDSYS.SDO_NUMBER_ARRAY;
      num_smallest      NUMBER;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF p_input IS NULL
      THEN
         RETURN NULL;
         
      END IF;
      
      IF num_tolerance IS NULL
      THEN
         num_tolerance := 0.05;
         
      END IF;
      
      IF p_input.get_gtype() <> 6
      THEN
         RAISE_APPLICATION_ERROR(-20001,'expected multistring geometry as input');
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Break lines into array
      --------------------------------------------------------------------------
      ary_sdo := dz_sdo_util.sdo2varray(
         p_input => p_input
      );
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Break lines into nodes
      --------------------------------------------------------------------------
      int_index := 1;
      nodes_start_array := MDSYS.SDO_GEOMETRY_ARRAY();
      nodes_end_array := MDSYS.SDO_GEOMETRY_ARRAY();
      nodes_start_array.EXTEND(ary_sdo.COUNT);
      nodes_end_array.EXTEND(ary_sdo.COUNT);
      
      FOR i IN 1 .. ary_sdo.COUNT
      LOOP
         nodes_start_array(int_index) := dz_sdo_util.get_start_point(ary_sdo(i));
         nodes_end_array(int_index) := dz_sdo_util.get_end_point(ary_sdo(i));
         int_index := int_index + 1;
         
      END LOOP;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Get the distance between nodes
      --------------------------------------------------------------------------
      int_index := 1;
      num_array := MDSYS.SDO_NUMBER_ARRAY();
      FOR i IN 1 .. ary_sdo.COUNT
      LOOP
         FOR j IN 1 .. ary_sdo.COUNT
         LOOP
            IF i != j
            THEN
               num_array.EXTEND(3);
               num_array(int_index) := dz_sdo_util.dz_distance(
                   nodes_start_array(i)
                  ,nodes_start_array(j)
                  ,num_tolerance
                  ,p_unit
               );
               int_index := int_index + 1;
               
               num_array(int_index) := dz_sdo_util.dz_distance(
                   nodes_start_array(i)
                  ,nodes_end_array(j)
                  ,num_tolerance
                  ,p_unit
               );
               int_index := int_index + 1;
               
               num_array(int_index) := dz_sdo_util.dz_distance(
                   nodes_end_array(i)
                  ,nodes_end_array(j)
                  ,num_tolerance
                  ,p_unit
               );
               int_index := int_index + 1;
               
            END IF;
            
         END LOOP;
        
      END LOOP;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Get the smallest distance between nodes
      --------------------------------------------------------------------------
      num_smallest := 999999999999;
      FOR i IN 1 .. num_array.COUNT
      LOOP
         IF num_array(i) < num_smallest
         THEN
            num_smallest := num_array(i);
            
         END IF;
         
      END LOOP;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Return what we got
      --------------------------------------------------------------------------
      RETURN num_smallest;
      
   END multistring_gap;
   
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
      IF p_input IS NULL
      THEN
         RETURN;
         
      END IF;
      
      IF p_input.get_gtype() != 2
      THEN
          RAISE_APPLICATION_ERROR(-20001,'input must be single linestring');
          
      END IF;
      
      num_vertices := sdo_util.getnumvertices(p_input);
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
   PROCEDURE break_string_at_point(
       p_input          IN  MDSYS.SDO_GEOMETRY
      ,p_break_point    IN  MDSYS.SDO_GEOMETRY
      ,p_first          OUT MDSYS.SDO_GEOMETRY
      ,p_second         OUT MDSYS.SDO_GEOMETRY
   )
   AS
      sdo_input     MDSYS.SDO_GEOMETRY := p_input;
      num_lrs       NUMBER;
      num_clip_meas NUMBER;
      num_start     NUMBER;
      num_end       NUMBER;
      str_direction VARCHAR2(5 Char);
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF sdo_input IS NULL
      OR p_break_point IS NULL
      THEN
         RETURN;
         
      END IF;
      
      IF sdo_input.get_gtype() <> 2
      THEN
          RAISE_APPLICATION_ERROR(-20001,'input must be single linestring');
          
      END IF;
      
      IF p_break_point.get_gtype() <> 1
      THEN
         RAISE_APPLICATION_ERROR(-20001,'break point must be point');
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Add LRS info if not already LRS
      --------------------------------------------------------------------------
      num_lrs := sdo_input.get_lrs_dim();
      
      IF num_lrs = 0
      THEN
         sdo_input := MDSYS.SDO_LRS.CONVERT_TO_LRS_GEOM(
             sdo_input
            ,100
            ,0
         );
         
      END IF;
      
      num_start := MDSYS.SDO_LRS.GEOM_SEGMENT_START_MEASURE(sdo_input);
      num_end   := MDSYS.SDO_LRS.GEOM_SEGMENT_END_MEASURE(sdo_input);
      str_direction := MDSYS.SDO_LRS.IS_MEASURE_INCREASING(sdo_input);
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Get measure at point
      --------------------------------------------------------------------------
      num_clip_meas := MDSYS.SDO_LRS.GET_MEASURE(
          MDSYS.SDO_LRS.PROJECT_PT(
              sdo_input
             ,p_break_point
          )
      );
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Clip as needed
      --------------------------------------------------------------------------
      IF str_direction = 'TRUE'
      THEN
         IF num_clip_meas > num_start
         THEN
            p_first := MDSYS.SDO_LRS.CLIP_GEOM_SEGMENT(
                 sdo_input
                ,num_start
                ,num_clip_meas
             );
      
         END IF;
         
         IF num_clip_meas < num_end
         THEN
            p_second := MDSYS.SDO_LRS.CLIP_GEOM_SEGMENT(
                 sdo_input
                ,num_clip_meas
                ,num_end
             );
      
         END IF;
               
      ELSE
         IF num_clip_meas < num_start
         THEN
            p_first := MDSYS.SDO_LRS.CLIP_GEOM_SEGMENT(
                 sdo_input
                ,num_start
                ,num_clip_meas
             );
      
         END IF;
         
         IF num_clip_meas > num_end
         THEN
            p_second := MDSYS.SDO_LRS.CLIP_GEOM_SEGMENT(
                 sdo_input
                ,num_clip_meas
                ,num_end
             );
           
         END IF;
      
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Toss LRS if required
      --------------------------------------------------------------------------
      IF num_lrs = 0
      THEN
         p_first  := dz_sdo_util.downsize_2d(p_first);
         p_second := dz_sdo_util.downsize_2d(p_second);
         
      END IF;
      
   END break_string_at_point;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE deconstruct_multipoint(
      p_input                  IN  MDSYS.SDO_GEOMETRY,
      p_nodes                  OUT MDSYS.SDO_GEOMETRY_ARRAY
   )
   AS
   BEGIN
   
      IF p_input.get_gtype() NOT IN (1,5)
      THEN
         RAISE_APPLICATION_ERROR(-20001,'input must be point or multipoint');
         
      ELSIF p_input.get_gtype() = 1
      THEN
         p_nodes.EXTEND(1);
         p_nodes(1) := p_input;
         RETURN;
         
      END IF;
      
      p_nodes.EXTEND(MDSYS.SDO_UTIL.GETNUMELEM(p_input));
      FOR i IN 1 .. MDSYS.SDO_UTIL.GETNUMELEM(p_input)
      LOOP
         p_nodes(i) := MDSYS.SDO_UTIL.EXTRACT(p_input,i);
         
      END LOOP;
   
   END deconstruct_multipoint;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE deconstruct_string(
      p_input                  IN  MDSYS.SDO_GEOMETRY,
      p_nodes                  OUT MDSYS.SDO_GEOMETRY_ARRAY,
      p_edges                  OUT MDSYS.SDO_GEOMETRY_ARRAY
   )
   AS
      sdo_input MDSYS.SDO_GEOMETRY;
      int_gtype PLS_INTEGER;
      int_dims  PLS_INTEGER;
      j         PLS_INTEGER;
      i         PLS_INTEGER;
      n         PLS_INTEGER;
      start_x   NUMBER;
      start_y   NUMBER;
      start_z   NUMBER;
      start_m   NUMBER;
      end_x     NUMBER;
      end_y     NUMBER;
      end_z     NUMBER;
      end_m     NUMBER;

   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF p_input IS NULL
      THEN
         RETURN;
         
      END IF;
      
      int_gtype := p_input.get_gtype();
      int_dims  := p_input.get_dims();

      IF int_gtype = 2
      THEN
         sdo_input := p_input;
         
      ELSE
         RAISE_APPLICATION_ERROR(-20001,'geometry must be a single linestring or polygon');
         
      END IF;
      
      IF dz_sdo_util.is_compound(sdo_input) = 'TRUE'
      THEN
         RAISE_APPLICATION_ERROR(-20001,'compound geometries not supported');
         
      END IF;
      
      p_nodes := MDSYS.SDO_GEOMETRY_ARRAY();
      p_edges := MDSYS.SDO_GEOMETRY_ARRAY();
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Loop through the ordinates and extract primitives
      --------------------------------------------------------------------------
      j := 1;
      i := 1;
      n := 1;
      WHILE i <= p_input.SDO_ORDINATES.COUNT
      LOOP
         IF i = 1
         THEN
            start_x := p_input.SDO_ORDINATES(i);
            i := i + 1;
            start_y := p_input.SDO_ORDINATES(i);
            i := i + 1;
            
            IF int_dims > 2
            THEN
               start_z := p_input.SDO_ORDINATES(i);
               i := i + 1;
               IF int_dims > 3
               THEN
                  start_m := p_input.SDO_ORDINATES(i);
                  i := i + 1;
               END IF;
               
            END IF;
            
            p_nodes.EXTEND(1);
            p_nodes(n) := MDSYS.SDO_GEOMETRY(
                2001
               ,p_input.SDO_SRID
               ,MDSYS.SDO_POINT_TYPE(
                    start_x
                   ,start_y
                   ,NULL
                )
               ,NULL
               ,NULL
            );
            n := n + 1;
               
         ELSE
            end_x := p_input.SDO_ORDINATES(i);
            i := i + 1;
            end_y := p_input.SDO_ORDINATES(i);
            i := i + 1;
            
            p_edges.EXTEND(1);
            IF int_dims > 2
            THEN
               end_z := p_input.SDO_ORDINATES(i);
               i := i + 1;
               
               IF int_dims > 3
               THEN
                  end_m := p_input.SDO_ORDINATES(i);
                  i := i + 1;
                  p_edges(j) := MDSYS.SDO_GEOMETRY(
                      4402
                     ,p_input.SDO_SRID
                     ,NULL
                     ,MDSYS.SDO_ELEM_INFO_ARRAY(1,2,1)
                     ,MDSYS.SDO_ORDINATE_ARRAY(start_x,start_y,start_z,start_m,end_x,end_y,end_z,end_m)
                  );
                  
               ELSE
                  p_edges(j) := MDSYS.SDO_GEOMETRY(
                      3002
                     ,p_input.SDO_SRID
                     ,NULL
                     ,MDSYS.SDO_ELEM_INFO_ARRAY(1,2,1)
                     ,MDSYS.SDO_ORDINATE_ARRAY(start_x,start_y,start_z,end_x,end_y,end_z)
                  );
                  
               END IF;
               
            ELSE
               p_edges(j) := MDSYS.SDO_GEOMETRY(
                   2002
                  ,p_input.SDO_SRID
                  ,NULL
                  ,MDSYS.SDO_ELEM_INFO_ARRAY(1,2,1)
                  ,MDSYS.SDO_ORDINATE_ARRAY(start_x,start_y,end_x,end_y)
               );
               
            END IF;

            j := j + 1;

            start_x := end_x;
            start_y := end_y;
            IF int_dims > 2
            THEN
               start_z := end_z;
               IF int_dims > 3
               THEN
                  start_m := end_m;
                  
               END IF;
               
            END IF;
            
            p_nodes.EXTEND(1);
            p_nodes(n) := MDSYS.SDO_GEOMETRY(
                2001
               ,p_input.SDO_SRID
               ,MDSYS.SDO_POINT_TYPE(
                    end_x
                   ,end_y
                   ,NULL
                )
               ,NULL
               ,NULL
            );
            n := n + 1;

         END IF;

      END LOOP;

   END deconstruct_string;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE deconstruct_multistring(
      p_input                  IN  MDSYS.SDO_GEOMETRY,
      p_nodes                  OUT MDSYS.SDO_GEOMETRY_ARRAY,
      p_edges                  OUT MDSYS.SDO_GEOMETRY_ARRAY
   )
   AS
      ary_nodes MDSYS.SDO_GEOMETRY_ARRAY;
      ary_edges MDSYS.SDO_GEOMETRY_ARRAY;
      int_gtype PLS_INTEGER;
      int_dims  PLS_INTEGER;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF p_input IS NULL
      THEN
         RETURN;
         
      END IF;
      
      int_gtype := p_input.get_gtype();
      int_dims  := p_input.get_dims();
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Process into one big sack of nodes and edges
      -- ideally should remove duplicate nodes and edges
      --------------------------------------------------------------------------
      IF int_gtype = 2
      THEN
         deconstruct_string(
            p_input   => p_input,
            p_nodes   => p_nodes,
            p_edges   => p_edges
         );
         
         RETURN;
         
      ELSIF int_gtype = 6
      THEN
         FOR i IN 1 .. MDSYS.SDO_UTIL.GETNUMELEM(p_input)
         LOOP
            deconstruct_string(
               p_input   => MDSYS.SDO_UTIL.EXTRACT(p_input,i),
               p_nodes   => ary_nodes,
               p_edges   => ary_edges
            );
         
            dz_sdo_util.append2(
               p_nodes,
               ary_nodes
            );
            
            dz_sdo_util.append2(
               p_edges,
               ary_edges
            );
         
         END LOOP;
      
      ELSE
         RAISE_APPLICATION_ERROR(-20001,'geometry must be a single linestring or multistring');
         
      END IF;
    
   END deconstruct_multistring;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE deconstruct_collection(
      p_input                  IN  MDSYS.SDO_GEOMETRY,
      p_nodes                  OUT MDSYS.SDO_GEOMETRY_ARRAY
   )
   AS
      sdo_temp   MDSYS.SDO_GEOMETRY;
      ary_nodes  MDSYS.SDO_GEOMETRY_ARRAY;
      ary_edges  MDSYS.SDO_GEOMETRY_ARRAY;
      
   BEGIN
   
      IF p_input.get_gtype() NOT IN (4,6)
      THEN
         RAISE_APPLICATION_ERROR(-20001,'input must be collection');
         
      END IF;
      
      p_nodes := MDSYS.SDO_GEOMETRY_ARRAY();
      FOR i IN 1 .. MDSYS.SDO_UTIL.GETNUMELEM(p_input)
      LOOP
         sdo_temp := MDSYS.SDO_UTIL.EXTRACT(p_input,i);
         
         IF sdo_temp.get_gtype() = 1
         THEN
            dz_sdo_util.append2(
                p_nodes
               ,sdo_temp
            );
            
         ELSIF sdo_temp.get_gtype = 2
         THEN
            deconstruct_string(
                sdo_temp
               ,ary_nodes
               ,ary_edges
            );
            
            dz_sdo_util.append2(
                p_nodes
               ,ary_nodes
            );
      
         ELSE
            RAISE_APPLICATION_ERROR(-20001,'err');
            
         END IF;
         
      END LOOP;
   
   END deconstruct_collection;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE deconstruct(
      p_input                   IN  MDSYS.SDO_GEOMETRY,
      p_nodes                   OUT MDSYS.SDO_GEOMETRY_ARRAY,
      p_edges                   OUT MDSYS.SDO_GEOMETRY_ARRAY
   )
   AS
      int_gtype     PLS_INTEGER;
      int_dims      PLS_INTEGER;
      int_rings     PLS_INTEGER;
      ary_elements  MDSYS.SDO_GEOMETRY_ARRAY;
      ary_nodes     MDSYS.SDO_GEOMETRY_ARRAY;
      ary_edges     MDSYS.SDO_GEOMETRY_ARRAY;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF p_input IS NULL
      THEN
         RETURN;
         
      END IF;
      
      p_nodes      := MDSYS.SDO_GEOMETRY_ARRAY();
      p_edges      := MDSYS.SDO_GEOMETRY_ARRAY();
      
      int_gtype := p_input.get_gtype();
      int_dims  := p_input.get_dims();
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Exit early if inputs are easy
      --------------------------------------------------------------------------
      IF int_gtype = 1
      THEN
         p_nodes.EXTEND(1);
         p_nodes(1) := p_input;
         RETURN;
         
      ELSIF int_gtype = 5
      THEN
         p_nodes := dz_sdo_util.sdo2varray(p_input);
         RETURN;
         
      ELSIF int_gtype = 4
      THEN
         RAISE_APPLICATION_ERROR(-20001,'collection types not supported');
         
      ELSIF int_gtype = 2
      THEN
         deconstruct_string(
             p_input
            ,p_nodes
            ,p_edges
         );
         
         RETURN;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Decompose the geometry into elements
      --------------------------------------------------------------------------
      ary_elements := dz_sdo_util.sdo2varray(
         p_input => p_input
      );
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Loop throught the elements to create nodes and edges
      --------------------------------------------------------------------------
      FOR i IN 1 .. ary_elements.COUNT
      LOOP
      
         int_gtype := ary_elements(i).get_gtype();
         int_dims  := ary_elements(i).get_dims();
         
         IF int_gtype = 2
         THEN
            deconstruct_string(
                ary_elements(i)
               ,ary_nodes
               ,ary_edges
            );
            
            dz_sdo_util.append2(
                p_nodes
               ,ary_nodes
            );
            
            dz_sdo_util.append2(
                p_edges
               ,ary_edges
            );
            
         ELSIF int_gtype = 3
         THEN
            int_rings := dz_sdo_util.getnumrings(
               p_input => ary_elements(i)
            );
            
            FOR j IN 1 .. int_rings
            LOOP
               deconstruct_string(
                   MDSYS.SDO_UTIL.POLYGONTOLINE(
                      MDSYS.SDO_UTIL.EXTRACT(ary_elements(i),1,j)
                   )
                  ,ary_nodes
                  ,ary_edges
               );
               
               dz_sdo_util.append2(
                   p_nodes
                  ,ary_nodes
               );
               
               dz_sdo_util.append2(
                   p_edges
                  ,ary_edges
               );
               
            END LOOP;
            
         ELSE
            RAISE_APPLICATION_ERROR(-20001,'err');
            
         END IF; 
           
      END LOOP;

   END deconstruct;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION deconstruct(
      p_input                   IN  MDSYS.SDO_GEOMETRY
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      p_nodes     MDSYS.SDO_GEOMETRY_ARRAY;
      p_edges     MDSYS.SDO_GEOMETRY_ARRAY;
      
   BEGIN
      deconstruct(
          p_input => p_input
         ,p_nodes => p_nodes
         ,p_edges => p_edges
      );
      
      RETURN dz_sdo_util.varray2sdo(
         p_input => p_nodes
      );
      
   END deconstruct;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION points2segment(
       p_point_one              IN  MDSYS.SDO_POINT_TYPE
      ,p_point_two              IN  MDSYS.SDO_POINT_TYPE
      ,p_srid                   IN  NUMBER
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
   BEGIN
   
      IF ( p_point_one.Z IS NULL AND p_point_two.Z IS NOT NULL )
      OR ( p_point_one.Z IS NOT NULL AND p_point_two.Z IS NULL )
      THEN
         RAISE_APPLICATION_ERROR(
            -20001,
            'both points must have the same number of dimensions, point_one Z is ' || 
            NVL(TO_CHAR(p_point_one.Z),'<NULL>') ||
            ' and point_two Z is ' ||
            NVL(TO_CHAR(p_point_two.Z),'<NULL>')
         );
         
      END IF;

      IF p_point_one.Z IS NULL
      THEN
         RETURN MDSYS.SDO_GEOMETRY(
             2002
            ,p_srid
            ,NULL
            ,MDSYS.SDO_ELEM_INFO_ARRAY(1,2,1)
            ,MDSYS.SDO_ORDINATE_ARRAY(p_point_one.X,p_point_one.Y,p_point_two.X,p_point_two.Y)
         );
         
      ELSE
         RETURN MDSYS.SDO_GEOMETRY(
             3002
            ,p_srid
            ,NULL
            ,MDSYS.SDO_ELEM_INFO_ARRAY(1,2,1)
            ,MDSYS.SDO_ORDINATE_ARRAY(
                 p_point_one.X
                ,p_point_one.Y
                ,p_point_one.Z
                ,p_point_two.X
                ,p_point_two.Y
                ,p_point_two.Z
             )
         );
         
      END IF;

   END points2segment;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION points2segment(
       p_point_one              IN  MDSYS.SDO_GEOMETRY
      ,p_point_two              IN  MDSYS.SDO_GEOMETRY
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      int_gtype1 PLS_INTEGER;
      int_dims1  PLS_INTEGER;
      int_gtype2 PLS_INTEGER;
      int_dims2  PLS_INTEGER;
      point_one  MDSYS.SDO_POINT_TYPE;
      point_two  MDSYS.SDO_POINT_TYPE;
      
   BEGIN

      int_gtype1 := p_point_one.get_gtype();
      int_dims1  := p_point_one.get_dims();
      int_gtype2 := p_point_two.get_gtype();
      int_dims2  := p_point_two.get_dims();

      IF  int_gtype1 = 1
      AND int_gtype2 = 1
      AND int_dims1  = int_dims2
      AND p_point_one.SDO_SRID = p_point_two.SDO_SRID
      THEN
         NULL;  -- Good
         
      ELSE
         RAISE_APPLICATION_ERROR(
             -20001
            ,'both point objects must be points and have the same number of dimensions and SRIDs'
         );
         
      END IF;

      IF int_dims1 = 4
      THEN
         RETURN MDSYS.SDO_GEOMETRY(
             4402
            ,p_point_one.SDO_SRID
            ,NULL
            ,MDSYS.SDO_ELEM_INFO_ARRAY(1,2,1)
            ,MDSYS.SDO_ORDINATE_ARRAY(
                 p_point_one.SDO_ORDINATES(1)
                ,p_point_one.SDO_ORDINATES(2)
                ,p_point_one.SDO_ORDINATES(3)
                ,p_point_one.SDO_ORDINATES(4)
                ,p_point_two.SDO_ORDINATES(1)
                ,p_point_two.SDO_ORDINATES(2)
                ,p_point_two.SDO_ORDINATES(3)
                ,p_point_two.SDO_ORDINATES(4)
            )
         );
          
      ELSE
         -- Use the sdo_point_type method for the rest
         IF p_point_one.SDO_POINT IS NOT NULL
         THEN
            point_one := p_point_one.SDO_POINT;
            
         ELSE
            IF int_dims1 = 3
            THEN
               point_one := MDSYS.SDO_POINT_TYPE(
                   p_point_one.SDO_ORDINATES(1)
                  ,p_point_one.SDO_ORDINATES(2)
                  ,p_point_one.SDO_ORDINATES(3)
               );
                            
            ELSE
               point_one := MDSYS.SDO_POINT_TYPE(
                   p_point_one.SDO_ORDINATES(1)
                  ,p_point_one.SDO_ORDINATES(2)
                  ,NULL
               );
                            
            END IF;
            
         END IF;

         IF p_point_two.SDO_POINT IS NOT NULL
         THEN
            point_two := p_point_two.SDO_POINT;
            
         ELSE
            IF int_dims1 = 3
            THEN
               point_two := MDSYS.SDO_POINT_TYPE(
                    p_point_two.SDO_ORDINATES(1)
                   ,p_point_two.SDO_ORDINATES(2)
                   ,p_point_two.SDO_ORDINATES(3)
               );
                            
            ELSE
               point_two := MDSYS.SDO_POINT_TYPE(
                   p_point_two.SDO_ORDINATES(1)
                  ,p_point_two.SDO_ORDINATES(2)
                  ,NULL
               );
               
            END IF;
            
         END IF;

         RETURN points2segment(
             p_point_one   => point_one
            ,p_point_two   => point_two
            ,p_srid        => p_point_one.SDO_SRID
         );

      END IF;

   END points2segment;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION linear_gap_filler(
       p_input            IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance        IN  NUMBER DEFAULT 0.05
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      sdo_input     MDSYS.SDO_GEOMETRY := p_input;
      num_tolerance NUMBER;
      int_counter   PLS_INTEGER;
      ary_edges     MDSYS.SDO_GEOMETRY_ARRAY;
      ary_starts    MDSYS.SDO_GEOMETRY_ARRAY;
      ary_ends      MDSYS.SDO_GEOMETRY_ARRAY;
      ary_nearest   MDSYS.SDO_NUMBER_ARRAY;
      ary_distance  MDSYS.SDO_NUMBER_ARRAY;
      num_temp      NUMBER;
      num_nearest   NUMBER;
      int_winner    PLS_INTEGER;
      int_winner2   PLS_INTEGER;
      sdo_point1    MDSYS.SDO_GEOMETRY;
      sdo_point2    MDSYS.SDO_GEOMETRY;
      boo_done      BOOLEAN;
      num_one       NUMBER;
      num_two       NUMBER;
      int_looper    PLS_INTEGER := 1;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF num_tolerance IS NULL
      THEN
         num_tolerance := 0.05;
         
      END IF;
      
      IF sdo_input IS NULL
      OR sdo_input.get_gtype() <> 6
      THEN
         RETURN sdo_input;
         
      END IF;
      
      IF dz_sdo_util.is_spaghetti(
          p_input     => sdo_input
         ,p_tolerance => p_tolerance
      ) = 'TRUE'
      THEN
         RETURN sdo_input;
         
      END IF;
      
      <<TOP_OF_IT>>
      ary_edges     := MDSYS.SDO_GEOMETRY_ARRAY();
      ary_starts    := MDSYS.SDO_GEOMETRY_ARRAY();
      ary_ends      := MDSYS.SDO_GEOMETRY_ARRAY();
      ary_nearest   := MDSYS.SDO_NUMBER_ARRAY();
      ary_distance  := MDSYS.SDO_NUMBER_ARRAY();
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Break multistring into edges and start and end nodes
      --------------------------------------------------------------------------
      int_counter := MDSYS.SDO_UTIL.GETNUMELEM(sdo_input);      
      ary_edges.EXTEND(int_counter);
      ary_starts.EXTEND(int_counter);
      ary_ends.EXTEND(int_counter);
      FOR i IN 1 .. int_counter
      LOOP  
         ary_edges(i)  := MDSYS.SDO_UTIL.EXTRACT(sdo_input,i);
         ary_starts(i) := dz_sdo_util.get_start_point(ary_edges(i));
         ary_ends(i)   := dz_sdo_util.get_end_point(ary_edges(i));
         
      END LOOP;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Determine the closest endpoints
      --------------------------------------------------------------------------
      ary_nearest.EXTEND(int_counter);
      ary_distance.EXTEND(int_counter);
      FOR i IN 1 .. int_counter
      LOOP
         num_nearest := NULL;
         int_winner := NULL;
         
         FOR j IN 1 .. int_counter
         LOOP
            IF j != i
            THEN
               num_temp := MDSYS.SDO_GEOM.SDO_DISTANCE(
                   ary_edges(i)
                  ,ary_edges(j)
                  ,0.00000001
               );
               
               IF num_nearest IS NULL
               OR num_temp < num_nearest
               THEN
                  num_nearest := num_temp;
                  int_winner := j;
                  
               END IF;
               
            END IF;
            
         END LOOP;
         
         ary_nearest(i) := int_winner;
         ary_distance(i) := num_nearest;
         
      END LOOP;
     
      --------------------------------------------------------------------------
      -- Step 40
      -- Find the smallest gap
      --------------------------------------------------------------------------
      int_winner := NULL;
      num_nearest := NULL;
      FOR i IN 1 .. int_counter
      LOOP
         IF num_nearest IS NULL
         OR ary_distance(i) < num_nearest
         THEN
             int_winner := i;
             num_nearest := ary_distance(i);
             int_winner2 := ary_nearest(i);
         
         END IF;
         
      END LOOP;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Determine the endpoints to connect
      --------------------------------------------------------------------------
      num_one := MDSYS.SDO_GEOM.SDO_DISTANCE(
          dz_sdo_util.get_start_point(ary_edges(int_winner))
         ,ary_edges(int_winner2)
         ,num_tolerance
      );
      
      num_two := MDSYS.SDO_GEOM.SDO_DISTANCE(
          dz_sdo_util.get_end_point(ary_edges(int_winner))
         ,ary_edges(int_winner2)
         ,num_tolerance
      );
            
      IF ( num_one = 0 AND MDSYS.SDO_GEOM.RELATE(
          dz_sdo_util.get_start_point(ary_edges(int_winner))
         ,'ANYINTERACT'
         ,ary_edges(int_winner2)
         ,num_tolerance
      ) = 'TRUE' )
      OR ( num_two = 0 AND MDSYS.SDO_GEOM.RELATE(
          dz_sdo_util.get_end_point(ary_edges(int_winner))
         ,'ANYINTERACT'
         ,ary_edges(int_winner2)
         ,num_tolerance
      ) = 'TRUE' )
      THEN
         sdo_point1 := NULL;
         
      ELSIF num_one < num_two THEN
         sdo_point1 := dz_sdo_util.get_start_point(
            p_input => ary_edges(int_winner)
         );
         
      ELSE
         sdo_point1 := dz_sdo_util.get_end_point(
            p_input => ary_edges(int_winner)
         );
         
      END IF;
     
      num_one := MDSYS.SDO_GEOM.SDO_DISTANCE(
          dz_sdo_util.get_start_point(ary_edges(int_winner2))
         ,ary_edges(int_winner)
         ,num_tolerance
      );
      num_two := MDSYS.SDO_GEOM.SDO_DISTANCE(
          dz_sdo_util.get_end_point(ary_edges(int_winner2))
         ,ary_edges(int_winner)
         ,num_tolerance
      );
      
      IF ( num_one = 0 AND MDSYS.SDO_GEOM.RELATE(
          dz_sdo_util.get_start_point(ary_edges(int_winner2))
         ,'ANYINTERACT'
         ,ary_edges(int_winner)
         ,num_tolerance
      ) = 'TRUE' )
      OR ( num_two = 0 AND MDSYS.SDO_GEOM.RELATE(
          dz_sdo_util.get_end_point(ary_edges(int_winner2))
         ,'ANYINTERACT'
         ,ary_edges(int_winner)
         ,num_tolerance
      ) = 'TRUE' )
      THEN
         sdo_point2 := NULL;
         
      ELSIF num_one < num_two 
      THEN
         sdo_point2 := dz_sdo_util.get_start_point(
            p_input => ary_edges(int_winner2)
         );
         
      ELSE
         sdo_point2 := dz_sdo_util.get_end_point(
            p_input => ary_edges(int_winner2)
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Smash together
      --------------------------------------------------------------------------
      IF sdo_point1 IS NULL
      OR sdo_point2 IS NULL
      THEN
         sdo_input := MDSYS.SDO_UTIL.CONCAT_LINES(
             ary_edges(int_winner)
            ,ary_edges(int_winner2)
         );
         
      ELSE
         sdo_input := MDSYS.SDO_UTIL.CONCAT_LINES(
             MDSYS.SDO_UTIL.CONCAT_LINES(
                 ary_edges(int_winner)
                ,dz_sdo_dissect.points2segment(sdo_point1,sdo_point2)
             )
            ,ary_edges(int_winner2)
         );
      
      END IF;
      
      boo_done := TRUE;
      FOR i IN 1 .. int_counter
      LOOP
         IF i NOT IN (int_winner,int_winner2)
         THEN
            sdo_input := MDSYS.SDO_UTIL.APPEND(sdo_input,ary_edges(i));
            boo_done := FALSE;
            
         END IF;
         
      END LOOP;

      --------------------------------------------------------------------------
      -- Step 60
      -- Check if valid if returning
      --------------------------------------------------------------------------
      IF sdo_input.get_gtype() = 2
      OR boo_done = TRUE
      THEN
         RETURN sdo_input;
 
      END IF;
      
      int_looper := int_looper + 1;
      GOTO TOP_OF_IT;
      
   END linear_gap_filler;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE crack_multistring(
       p_input        IN  MDSYS.SDO_GEOMETRY
      ,p_linestrings  OUT MDSYS.SDO_GEOMETRY_ARRAY
      ,p_start_points OUT MDSYS.SDO_GEOMETRY_ARRAY
      ,p_end_points   OUT MDSYS.SDO_GEOMETRY_ARRAY
   )
   AS
      int_counter PLS_INTEGER;
      sdo_temp    MDSYS.SDO_GEOMETRY;
      
   BEGIN
   
      int_counter := MDSYS.SDO_UTIL.GETNUMELEM(p_input);
      
      p_linestrings  := MDSYS.SDO_GEOMETRY_ARRAY();
      p_start_points := MDSYS.SDO_GEOMETRY_ARRAY();
      p_end_points   := MDSYS.SDO_GEOMETRY_ARRAY();
      
      p_linestrings.EXTEND(int_counter);
      p_start_points.EXTEND(int_counter);
      p_end_points.EXTEND(int_counter);
      
      FOR i IN 1 .. int_counter
      LOOP
         sdo_temp := MDSYS.SDO_UTIL.EXTRACT(p_input,i);
         p_linestrings(i)  := sdo_temp;
         p_start_points(i) := dz_sdo_util.get_start_point(
            p_input => sdo_temp
         );
         p_end_points(i)   := dz_sdo_util.get_end_point(
            p_input => sdo_temp
         );
         
      END LOOP;
   
   END crack_multistring;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION feature_to_line(
       p_input      IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance  IN  NUMBER DEFAULT 0.05
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      num_tolerance    NUMBER;
      sdo_input        MDSYS.SDO_GEOMETRY;
      ary_linestrings  MDSYS.SDO_GEOMETRY_ARRAY;
      ary_start_points MDSYS.SDO_GEOMETRY_ARRAY;
      ary_end_points   MDSYS.SDO_GEOMETRY_ARRAY;
      int_sanity       PLS_INTEGER := 255;
      
   BEGIN
   
      IF p_input IS NULL
      THEN
         RETURN NULL;
         
      END IF;
      
      IF p_input.get_gtype() = 2
      THEN
         RETURN p_input;
         
      END IF;
      
      IF p_input.get_gtype() <> 6
      THEN
         RAISE_APPLICATION_ERROR(-20001,'linestring utility');
      
      END IF;
      
      IF num_tolerance IS NULL
      THEN
         num_tolerance := 0.05;
         
      END IF;
      
      sdo_input := dz_sdo_util.downsize_2d(p_input);
      
      crack_multistring(
          p_input        => sdo_input
         ,p_linestrings  => ary_linestrings
         ,p_start_points => ary_start_points
         ,p_end_points   => ary_end_points
      );
      
      <<looper>>
      WHILE int_sanity > 0
      LOOP
         int_sanity := int_sanity - 1;
      
         FOR i IN 1 .. ary_linestrings.COUNT
         LOOP
            FOR j IN 1 .. ary_linestrings.COUNT
            LOOP
               IF i <> j
               AND MDSYS.SDO_GEOM.RELATE(
                   ary_linestrings(i)
                  ,'DETERMINE'
                  ,ary_linestrings(j)
                  ,num_tolerance
               ) IN ('TOUCH','OVERLAPBDYINTERSECT','CONTAINS')
               THEN         
                  IF MDSYS.SDO_GEOM.RELATE(
                      ary_start_points(i)
                     ,'DETERMINE'
                     ,ary_start_points(j)
                     ,num_tolerance
                  ) IN ('DISJOINT')
                  AND MDSYS.SDO_GEOM.RELATE(
                      ary_end_points(i)
                     ,'DETERMINE'
                     ,ary_start_points(j)
                     ,num_tolerance
                  ) IN ('DISJOINT')
                  AND MDSYS.SDO_GEOM.RELATE(
                      ary_linestrings(i)
                     ,'DETERMINE'
                     ,ary_start_points(j)
                     ,num_tolerance
                  ) IN ('TOUCH','OVERLAPBDYINTERSECT','CONTAINS')
                  THEN
                     ary_linestrings.EXTEND();
                     ary_start_points.EXTEND();
                     ary_end_points.EXTEND(); 
                                      
                     break_string_at_point(
                         p_input          => ary_linestrings(i)
                        ,p_break_point    => ary_start_points(j)
                        ,p_first          => ary_linestrings(i)
                        ,p_second         => ary_linestrings(ary_linestrings.COUNT)
                     );
                        
                     ary_start_points(i) := dz_sdo_util.get_start_point(
                        p_input => ary_linestrings(i)
                     );
                     ary_end_points(i) := dz_sdo_util.get_end_point(
                        p_input => ary_linestrings(i)
                     );
                        
                     ary_start_points(ary_linestrings.COUNT) := dz_sdo_util.get_start_point(
                        p_input => ary_linestrings(ary_linestrings.COUNT)
                     );
                     ary_end_points(ary_linestrings.COUNT) := dz_sdo_util.get_end_point(
                        p_input => ary_linestrings(ary_linestrings.COUNT)
                     );
                     
                     CONTINUE looper;
                  
                  END IF;
                  
                  IF MDSYS.SDO_GEOM.RELATE(
                      ary_start_points(i)
                     ,'DETERMINE'
                     ,ary_end_points(j)
                     ,num_tolerance
                  ) IN ('DISJOINT')
                  AND MDSYS.SDO_GEOM.RELATE(
                      ary_end_points(i)
                     ,'DETERMINE'
                     ,ary_end_points(j)
                     ,num_tolerance
                  ) IN ('DISJOINT')
                  AND MDSYS.SDO_GEOM.RELATE(
                      ary_linestrings(i)
                     ,'DETERMINE'
                     ,ary_end_points(j)
                     ,num_tolerance
                  ) IN ('TOUCH','OVERLAPBDYINTERSECT','CONTAINS')
                  THEN
                     ary_linestrings.EXTEND();
                     ary_start_points.EXTEND();
                     ary_end_points.EXTEND();  
                                     
                     break_string_at_point(
                         p_input          => ary_linestrings(i)
                        ,p_break_point    => ary_end_points(j)
                        ,p_first          => ary_linestrings(i)
                        ,p_second         => ary_linestrings(ary_linestrings.COUNT)
                     );
                        
                     ary_start_points(i) := dz_sdo_util.get_start_point(
                        p_input => ary_linestrings(i)
                     );
                     ary_end_points(i) := dz_sdo_util.get_end_point(
                        p_input => ary_linestrings(i)
                     );
                        
                     ary_start_points(ary_linestrings.COUNT) := dz_sdo_util.get_start_point(
                        p_input => ary_linestrings(ary_linestrings.COUNT)
                     );
                     ary_end_points(ary_linestrings.COUNT) := dz_sdo_util.get_end_point(
                        p_input => ary_linestrings(ary_linestrings.COUNT)
                     );
                     
                     CONTINUE looper;
           
                  END IF;
                  
               END IF;
         
            END LOOP;
         
         END LOOP;
         
         RETURN dz_sdo_util.varray2sdo(
            p_input => ary_linestrings
         ); 
         
      END LOOP;
      
      RAISE_APPLICATION_ERROR(-20001,'out of control loop');   
   
   END feature_to_line;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION point_at_vertice(
       p_input      IN  MDSYS.SDO_GEOMETRY
      ,p_vertice    IN  NUMBER
      ,p_2d_flag    IN  VARCHAR2 DEFAULT 'TRUE'
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      num_vertices NUMBER;
      num_dim      NUMBER;
      sdo_output   MDSYS.SDO_GEOMETRY;
      str_2d_flag  VARCHAR2(4000) := UPPER(p_2d_flag);
      num_3rd      NUMBER;
      num_4th      NUMBER;
      
   BEGIN
      
      IF p_input IS NULL
      THEN
         RETURN NULL;
         
      END IF;
      
      IF p_input.get_gtype() <> 2
      THEN
         RAISE_APPLICATION_ERROR(-20001,'linestrings only');
         
      END IF;
      
      num_vertices := MDSYS.SDO_UTIL.GETNUMVERTICES(p_input);
      num_dim := p_input.get_dims();
      
      IF p_vertice IS NULL
      OR p_vertice = 0
      THEN
         RAISE_APPLICATION_ERROR(-20001,'vertices must be non-zero number');
         
      END IF;
      
      IF p_vertice > num_vertices
      OR p_vertice < (num_vertices * -1)
      THEN
         RAISE_APPLICATION_ERROR(
             -20001
            ,'geom only has ' || num_vertices || ' vertices'
         );
         
      END IF;
      
      IF str_2d_flag IS NULL
      THEN
         str_2d_flag := 'TRUE';
      
      ELSIF str_2d_flag NOT IN ('TRUE','FALSE')
      THEN
         RAISE_APPLICATION_ERROR(-20001,'boolean error');
         
      END IF;
      
      IF str_2d_flag = 'FALSE'
      THEN
         RAISE_APPLICATION_ERROR(-20001,'unimplemented');
      
      END IF;
   
      IF p_vertice > 0
      THEN
         sdo_output := MDSYS.SDO_GEOMETRY(
             2001
            ,p_input.SDO_SRID
            ,MDSYS.SDO_POINT_TYPE(
                 p_input.SDO_ORDINATES((num_dim * p_vertice)-(num_dim - 1))
                ,p_input.SDO_ORDINATES((num_dim * p_vertice)-(num_dim - 2))
                ,NULL
             )
            ,NULL
            ,NULL
         );
      
      ELSE
         sdo_output := MDSYS.SDO_GEOMETRY(
             2001
            ,p_input.SDO_SRID
            ,MDSYS.SDO_POINT_TYPE(
                 p_input.SDO_ORDINATES((num_vertices * num_dim) - (ABS(p_vertice) * num_dim) + 1)
                ,p_input.SDO_ORDINATES((num_vertices * num_dim) - (ABS(p_vertice) * num_dim) + 2)
                ,NULL
             )
            ,NULL
            ,NULL
         );
      
      END IF;
      
      RETURN sdo_output;
   
   END point_at_vertice;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION has_holes(
      p_input             IN  MDSYS.SDO_GEOMETRY
   ) RETURN VARCHAR2
   AS
      i PLS_INTEGER := 1;

   BEGIN
    
      IF p_input IS NULL
      THEN
         RETURN 'FALSE';
      
      END IF;
    
      WHILE i <= p_input.SDO_ELEM_INFO.COUNT
      LOOP
         i := i + 1;
      
         IF p_input.SDO_ELEM_INFO(i) IN (2003,2005)
         THEN
            RETURN 'TRUE';
            
         END IF;
      
         i := i + 2;
      
      END LOOP;
          
      RETURN 'FALSE';
    
   END has_holes;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION remove_holes(
      p_input             IN  MDSYS.SDO_GEOMETRY
   ) RETURN MDSYS.SDO_GEOMETRY
   AS

      temp_input       MDSYS.SDO_GEOMETRY;
      output_geom      MDSYS.SDO_GEOMETRY;
      sdo_mother       MDSYS.SDO_GEOMETRY;
      sdo_daughters    MDSYS.SDO_GEOMETRY;
      gtype4           NUMBER;
      gtype4a          NUMBER;
      gtype4b          NUMBER;
      str_relationship VARCHAR2(4000 Char);
      
   BEGIN

      gtype4 := p_input.get_gtype();

      IF gtype4 = 3
      THEN
         RETURN MDSYS.SDO_UTIL.EXTRACT(p_input,1,1);
         
      ELSIF gtype4 IN (4,7)
      THEN
         -- Extract the mother polygon assumed to be in position 1
         sdo_mother := MDSYS.SDO_UTIL.EXTRACT(p_input,1);
         
         gtype4a := sdo_mother.get_gtype();
         
         IF gtype4a = 3
         THEN
            sdo_mother := MDSYS.SDO_UTIL.EXTRACT(sdo_mother,1,1);
         
         END IF;

         -- Loop through all daughters and toss out any inside the mother
         FOR i in 2 .. MDSYS.SDO_UTIL.GETNUMELEM(p_input)
         LOOP
            temp_input := MDSYS.SDO_UTIL.EXTRACT(p_input,i);
            
            gtype4b := temp_input.get_gtype();
            
            IF gtype4b = 3
            THEN
               temp_input := MDSYS.SDO_UTIL.EXTRACT(temp_input,1,1);
               
               str_relationship := MDSYS.SDO_GEOM.RELATE(
                   temp_input
                  ,'DETERMINE'
                  ,sdo_mother
                  ,0.5
               );
               
               IF str_relationship IN ('INSIDE','COVEREDBY')
               THEN
                  NULL; -- Toss it!
               
               ELSE
                  IF sdo_daughters IS NULL
                  THEN
                     sdo_daughters := temp_input;
               
                  ELSE
                     sdo_daughters := MDSYS.SDO_GEOM.SDO_UNION(
                         sdo_daughters
                        ,temp_input
                        ,0.5
                     );
               
                  END IF;
               
               END IF;
               
            ELSE
               IF sdo_daughters IS NULL
               THEN
                  sdo_daughters := temp_input;
               
               ELSE
                  sdo_daughters := MDSYS.SDO_UTIL.APPEND(
                      sdo_daughters
                     ,temp_input
                  );
               
               END IF;
            
            END IF;

         END LOOP;

         output_geom := sdo_mother;
         IF sdo_daughters IS NOT NULL
         THEN
            FOR i IN 1 .. MDSYS.SDO_UTIL.GETNUMELEM(sdo_daughters)
            LOOP
               temp_input := MDSYS.SDO_UTIL.EXTRACT(sdo_daughters,i,1);
               gtype4a := temp_input.get_gtype();
               
               IF gtype4a = 3
               THEN
                  str_relationship := MDSYS.SDO_GEOM.RELATE(
                      temp_input
                     ,'DETERMINE'
                     ,output_geom
                     ,0.5
                  );
                  
                  IF  str_relationship = 'INSIDE'
                  OR  str_relationship = 'COVERS'
                  OR  str_relationship = 'COVEREDBY'
                  OR  str_relationship = 'CONTAINS'
                  OR  str_relationship = 'EQUALS'
                  OR  str_relationship = 'OVERLAPBDYINTERSECT'
                  THEN
                     output_geom := MDSYS.SDO_GEOM.SDO_UNION(
                         output_geom
                        ,temp_input
                        ,0.5
                     );
                  
                  ELSE
                     output_geom := MDSYS.SDO_UTIL.APPEND(
                         output_geom
                        ,temp_input
                     );
                  
                  END IF;
               
               END IF;

            END LOOP;

         END IF;

         RETURN output_geom;

     ELSE
        RETURN p_input;

      END IF;

   END remove_holes;
   
END dz_sdo_dissect;
/

