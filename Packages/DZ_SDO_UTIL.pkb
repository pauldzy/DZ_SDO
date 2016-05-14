CREATE OR REPLACE PACKAGE BODY dz_sdo_util
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION gz_split(
       p_str              IN VARCHAR2
      ,p_regex            IN VARCHAR2
      ,p_match            IN VARCHAR2 DEFAULT NULL
      ,p_end              IN NUMBER   DEFAULT 0
      ,p_trim             IN VARCHAR2 DEFAULT 'FALSE'
   ) RETURN MDSYS.SDO_STRING2_ARRAY DETERMINISTIC 
   AS
      int_delim      PLS_INTEGER;
      int_position   PLS_INTEGER := 1;
      int_counter    PLS_INTEGER := 1;
      ary_output     MDSYS.SDO_STRING2_ARRAY;
      num_end        NUMBER      := p_end;
      str_trim       VARCHAR2(5 Char) := UPPER(p_trim);
      
      FUNCTION trim_varray(
         p_input            IN MDSYS.SDO_STRING2_ARRAY
      ) RETURN MDSYS.SDO_STRING2_ARRAY
      AS
         ary_output MDSYS.SDO_STRING2_ARRAY := MDSYS.SDO_STRING2_ARRAY();
         int_index  PLS_INTEGER := 1;
         str_check  VARCHAR2(4000 Char);
         
      BEGIN

         --------------------------------------------------------------------------
         -- Step 10
         -- Exit if input is empty
         --------------------------------------------------------------------------
         IF p_input IS NULL
         OR p_input.COUNT = 0
         THEN
            RETURN ary_output;
            
         END IF;

         --------------------------------------------------------------------------
         -- Step 20
         -- Trim the strings removing anything utterly trimmed away
         --------------------------------------------------------------------------
         FOR i IN 1 .. p_input.COUNT
         LOOP
            str_check := TRIM(p_input(i));
            IF str_check IS NULL
            OR str_check = ''
            THEN
               NULL;
               
            ELSE
               ary_output.EXTEND(1);
               ary_output(int_index) := str_check;
               int_index := int_index + 1;
               
            END IF;

         END LOOP;

         --------------------------------------------------------------------------
         -- Step 10
         -- Return the results
         --------------------------------------------------------------------------
         RETURN ary_output;

      END trim_varray;

   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Create the output array and check parameters
      --------------------------------------------------------------------------
      ary_output := MDSYS.SDO_STRING2_ARRAY();

      IF str_trim IS NULL
      THEN
         str_trim := 'FALSE';
         
      ELSIF str_trim NOT IN ('TRUE','FALSE')
      THEN
         RAISE_APPLICATION_ERROR(-20001,'boolean error');
         
      END IF;

      IF num_end IS NULL
      THEN
         num_end := 0;
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 20
      -- Exit early if input is empty
      --------------------------------------------------------------------------
      IF p_str IS NULL
      OR p_str = ''
      THEN
         RETURN ary_output;
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 30
      -- Account for weird instance of pure character breaking
      --------------------------------------------------------------------------
      IF p_regex IS NULL
      OR p_regex = ''
      THEN
         FOR i IN 1 .. LENGTH(p_str)
         LOOP
            ary_output.EXTEND(1);
            ary_output(i) := SUBSTR(p_str,i,1);
            
         END LOOP;
         
         RETURN ary_output;
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 40
      -- Break string using the usual REGEXP functions
      --------------------------------------------------------------------------
      LOOP
         EXIT WHEN int_position = 0;
         int_delim  := REGEXP_INSTR(p_str,p_regex,int_position,1,0,p_match);
         
         IF  int_delim = 0
         THEN
            -- no more matches found
            ary_output.EXTEND(1);
            ary_output(int_counter) := SUBSTR(p_str,int_position);
            int_position  := 0;
            
         ELSE
            IF int_counter = num_end
            THEN
               -- take the rest as is
               ary_output.EXTEND(1);
               ary_output(int_counter) := SUBSTR(p_str,int_position);
               int_position  := 0;
               
            ELSE
               --dbms_output.put_line(ary_output.COUNT);
               ary_output.EXTEND(1);
               ary_output(int_counter) := SUBSTR(p_str,int_position,int_delim-int_position);
               int_counter := int_counter + 1;
               int_position := REGEXP_INSTR(p_str,p_regex,int_position,1,1,p_match);
               
            END IF;
            
         END IF;
         
      END LOOP;

      --------------------------------------------------------------------------
      -- Step 50
      -- Trim results if so desired
      --------------------------------------------------------------------------
      IF str_trim = 'TRUE'
      THEN
         RETURN trim_varray(
            p_input => ary_output
         );
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 60
      -- Cough out the results
      --------------------------------------------------------------------------
      RETURN ary_output;
      
   END gz_split;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION count_points(
      p_input   IN MDSYS.SDO_GEOMETRY
   ) RETURN NUMBER
   AS
   BEGIN
      IF p_input IS NULL
      THEN
         RETURN 0;
         
      END IF;
      
      IF p_input.SDO_POINT IS NOT NULL
      THEN
         RETURN 1;
         
      ELSE
         RETURN p_input.SDO_ORDINATES.COUNT / p_input.get_dims();
         
      END IF;
      
   END count_points;
   
   ----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION true_point(
      p_input      IN MDSYS.SDO_GEOMETRY
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
   BEGIN

      IF p_input.SDO_POINT IS NOT NULL
      THEN
         RETURN p_input;
         
      END IF;

      IF p_input.get_gtype() = 1
      THEN
         IF p_input.get_dims() = 2
         THEN
            RETURN MDSYS.SDO_GEOMETRY(
                p_input.SDO_GTYPE
               ,p_input.SDO_SRID
               ,MDSYS.SDO_POINT_TYPE(
                   p_input.SDO_ORDINATES(1)
                  ,p_input.SDO_ORDINATES(2)
                  ,NULL
                )
               ,NULL
               ,NULL
            );
            
         ELSIF p_input.get_dims() = 3
         THEN
            RETURN MDSYS.SDO_GEOMETRY(
                p_input.SDO_GTYPE
               ,p_input.SDO_SRID
               ,MDSYS.SDO_POINT_TYPE(
                    p_input.SDO_ORDINATES(1)
                   ,p_input.SDO_ORDINATES(2)
                   ,p_input.SDO_ORDINATES(3)
                )
               ,NULL
               ,NULL
            );
            
         ELSE
            RAISE_APPLICATION_ERROR(
                -20001
               ,'function true_point can only work on 2 and 3 dimensional points - dims=' || p_input.get_dims() || ' '
            );
            
         END IF;
         
      ELSE
         RAISE_APPLICATION_ERROR(
             -20001
            ,'function true_point can only work on point geometries'
         );
         
      END IF;
      
   END true_point;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION is_compound(
      p_input   IN MDSYS.SDO_GEOMETRY
   ) RETURN VARCHAR2
   AS
      i PLS_INTEGER := 1;
      
   BEGIN

      IF p_input IS NULL
      OR p_input.SDO_GTYPE IS NULL
      THEN
         RETURN 'FALSE';
         
      END IF;

      WHILE i <= p_input.SDO_ELEM_INFO.COUNT
      LOOP
         i := i + 1;
         IF p_input.SDO_ELEM_INFO(i) = 1005
         OR p_input.SDO_ELEM_INFO(i) = 2005
         THEN
            RETURN 'TRUE';
            
         END IF;
         
         i := i + 2;
         
      END LOOP;
      
      RETURN 'FALSE';

   END is_compound;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION fast_point(
       p_x             IN  NUMBER
      ,p_y             IN  NUMBER
      ,p_z             IN  NUMBER DEFAULT NULL
      ,p_m             IN  NUMBER DEFAULT NULL
      ,p_srid          IN  NUMBER DEFAULT 8265
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF p_x IS NULL
      OR p_y IS NULL
      THEN
         RAISE_APPLICATION_ERROR(-20001,'x and y cannot be NULL');
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Do the simplest solution first
      --------------------------------------------------------------------------
      IF  p_z IS NULL
      AND p_m IS NULL
      THEN
         RETURN MDSYS.SDO_GEOMETRY(
             2001
            ,p_srid
            ,MDSYS.SDO_POINT_TYPE(
                 p_x
                ,p_y
                ,NULL
             )
            ,NULL
            ,NULL
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Do the other wilder choices
      --------------------------------------------------------------------------
      IF p_z IS NULL
      AND p_m IS NOT NULL
      THEN
         RETURN MDSYS.SDO_GEOMETRY(
             3301
            ,p_srid
            ,MDSYS.SDO_POINT_TYPE(
                 p_x
                ,p_y
                ,p_m
             )
            ,NULL
            ,NULL
         );
         
      ELSIF p_z IS NOT NULL
      AND   p_m IS NULL
      THEN
         RETURN MDSYS.SDO_GEOMETRY(
             3001
            ,p_srid
            ,MDSYS.SDO_POINT_TYPE(
                 p_x
                ,p_y
                ,p_z
             )
            ,NULL
            ,NULL
         );
         
      ELSIF p_z IS NOT NULL
      AND   p_m IS NOT NULL
      THEN
         RETURN MDSYS.SDO_GEOMETRY(
             4401
            ,p_srid
            ,NULL
            ,MDSYS.SDO_ELEM_INFO_ARRAY(1,1,1)
            ,MDSYS.SDO_ORDINATE_ARRAY(p_x,p_y,p_z,p_m)
         );
      
      ELSE
         RAISE_APPLICATION_ERROR(-20001,'err');
         
      END IF;
      
   END fast_point;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION get_start_point(
      p_input        IN  MDSYS.SDO_GEOMETRY
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      int_dims PLS_INTEGER;
      int_gtyp PLS_INTEGER;
      int_lrs  PLS_INTEGER;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF p_input IS NULL
      THEN
         RETURN NULL;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Gather information about the geometry
      --------------------------------------------------------------------------
      int_dims := p_input.get_dims();
      int_gtyp := p_input.get_gtype();
      int_lrs  := p_input.get_lrs_dim();
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Handle point and multipoint inputs
      --------------------------------------------------------------------------
      IF int_gtyp = 1
      THEN
         RETURN p_input;
         
      ELSIF int_gtyp = 5
      THEN
         RETURN MDSYS.SDO_UTIL.EXTRACT(p_input,1);
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 40
      -- Return results
      --------------------------------------------------------------------------
      IF int_dims = 2
      THEN
         RETURN fast_point(
             p_x    => p_input.SDO_ORDINATES(1)
            ,p_y    => p_input.SDO_ORDINATES(2)
            ,p_srid => p_input.SDO_SRID
         );
         
      ELSIF  int_dims = 3
      AND int_lrs = 3
      THEN 
         RETURN fast_point(
             p_x    => p_input.SDO_ORDINATES(1)
            ,p_y    => p_input.SDO_ORDINATES(2)
            ,p_m    => p_input.SDO_ORDINATES(3)
            ,p_srid => p_input.SDO_SRID
         );
         
      ELSIF  int_dims = 3
      AND int_lrs = 0
      THEN 
         RETURN fast_point(
             p_x    => p_input.SDO_ORDINATES(1)
            ,p_y    => p_input.SDO_ORDINATES(2)
            ,p_z    => p_input.SDO_ORDINATES(3)
            ,p_srid => p_input.SDO_SRID
         );
         
      ELSIF  int_dims = 4
      AND int_lrs IN (4,0)
      THEN 
         RETURN fast_point(
             p_x    => p_input.SDO_ORDINATES(1)
            ,p_y    => p_input.SDO_ORDINATES(2)
            ,p_z    => p_input.SDO_ORDINATES(3)
            ,p_m    => p_input.SDO_ORDINATES(4)
            ,p_srid => p_input.SDO_SRID
         );
         
      ELSIF  int_dims = 4
      AND int_lrs = 3
      THEN 
         RETURN fast_point(
             p_x    => p_input.SDO_ORDINATES(1)
            ,p_y    => p_input.SDO_ORDINATES(2)
            ,p_z    => p_input.SDO_ORDINATES(4)
            ,p_m    => p_input.SDO_ORDINATES(3)
            ,p_srid => p_input.SDO_SRID
         );
      
      ELSE
         RAISE_APPLICATION_ERROR(-20001,'err');
            
      END IF;

   END get_start_point;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION get_end_point(
      p_input        IN  MDSYS.SDO_GEOMETRY
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      int_dims PLS_INTEGER;
      int_gtyp PLS_INTEGER;
      int_lrs  PLS_INTEGER;
      int_len  PLS_INTEGER;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF p_input IS NULL
      THEN
         RETURN NULL;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Gather information about the geometry
      --------------------------------------------------------------------------
      int_dims := p_input.get_dims();
      int_gtyp := p_input.get_gtype();
      int_lrs  := p_input.get_lrs_dim();
      int_len  := p_input.SDO_ORDINATES.COUNT();
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Handle point and multipoint inputs
      --------------------------------------------------------------------------
      IF int_gtyp = 1
      THEN
         RETURN p_input;
         
      ELSIF int_gtyp = 5
      THEN
         RETURN MDSYS.SDO_UTIL.EXTRACT(
             p_input
            ,MDSYS.SDO_UTIL.GETNUMELEM(p_input)
         );
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 40
      -- Return results
      --------------------------------------------------------------------------
      IF int_dims = 2
      THEN
         RETURN fast_point(
             p_x    => p_input.SDO_ORDINATES(int_len - 1)
            ,p_y    => p_input.SDO_ORDINATES(int_len)
            ,p_srid => p_input.SDO_SRID
         );
         
      ELSIF  int_dims = 3
      AND int_lrs = 3
      THEN
         RETURN fast_point(
             p_x    => p_input.SDO_ORDINATES(int_len - 2)
            ,p_y    => p_input.SDO_ORDINATES(int_len - 1)
            ,p_m    => p_input.SDO_ORDINATES(int_len)
            ,p_srid => p_input.SDO_SRID
         );
         
      ELSIF  int_dims = 3
      AND int_lrs = 0
      THEN 
         RETURN fast_point(
             p_x    => p_input.SDO_ORDINATES(int_len - 2)
            ,p_y    => p_input.SDO_ORDINATES(int_len - 1)
            ,p_z    => p_input.SDO_ORDINATES(int_len)
            ,p_srid => p_input.SDO_SRID
         );
         
      ELSIF  int_dims = 4
      AND int_lrs IN (4,0)
      THEN 
         RETURN fast_point(
             p_x    => p_input.SDO_ORDINATES(int_len - 3)
            ,p_y    => p_input.SDO_ORDINATES(int_len - 2)
            ,p_z    => p_input.SDO_ORDINATES(int_len - 1)
            ,p_m    => p_input.SDO_ORDINATES(int_len)
            ,p_srid => p_input.SDO_SRID
         );
         
      ELSIF  int_dims = 4
      AND int_lrs = 3
      THEN 
         RETURN fast_point(
             p_x    => p_input.SDO_ORDINATES(int_len - 3)
            ,p_y    => p_input.SDO_ORDINATES(int_len - 2)
            ,p_z    => p_input.SDO_ORDINATES(int_len)
            ,p_m    => p_input.SDO_ORDINATES(int_len - 1)
            ,p_srid => p_input.SDO_SRID
         );
         
      ELSE
         RAISE_APPLICATION_ERROR(-20001,'err');
         
      END IF;

   END get_end_point;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION downsize_2d(
      p_input   IN MDSYS.SDO_GEOMETRY
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      geom_2d       MDSYS.SDO_GEOMETRY;
      dim_count     PLS_INTEGER;
      gtype         PLS_INTEGER;
      n_points      PLS_INTEGER;
      n_ordinates   PLS_INTEGER;
      i             PLS_INTEGER;
      j             PLS_INTEGER;
      k             PLS_INTEGER;
      offset        PLS_INTEGER;
      
   BEGIN

      IF p_input IS NULL
      THEN
         RETURN NULL;
         
      END IF;

      IF LENGTH (p_input.SDO_GTYPE) = 4
      THEN
         dim_count := p_input.get_dims();
         gtype     := p_input.get_gtype();
         
      ELSE
         RAISE_APPLICATION_ERROR(
             -20001
            ,'unable to determine dimensionality from gtype'
         );
         
      END IF;

      IF dim_count = 2
      THEN
         RETURN p_input;
         
      END IF;

      geom_2d := MDSYS.SDO_GEOMETRY(
          2000 + gtype
         ,p_input.sdo_srid
         ,p_input.sdo_point
         ,MDSYS.SDO_ELEM_INFO_ARRAY()
         ,MDSYS.SDO_ORDINATE_ARRAY()
      );

      IF geom_2d.sdo_point IS NOT NULL
      THEN
         geom_2d.sdo_point.z   := NULL;
         geom_2d.sdo_elem_info := NULL;
         geom_2d.sdo_ordinates := NULL;
         
      ELSE
         n_points    := p_input.SDO_ORDINATES.COUNT / dim_count;
         n_ordinates := n_points * 2;
         geom_2d.SDO_ORDINATES.EXTEND(n_ordinates);
         j := p_input.SDO_ORDINATES.FIRST;
         k := 1;
         FOR i IN 1 .. n_points
         LOOP
            geom_2d.SDO_ORDINATES(k) := p_input.SDO_ORDINATES(j);
            geom_2d.SDO_ORDINATES(k + 1) := p_input.SDO_ORDINATES(j + 1);
            j := j + dim_count;
            k := k + 2;
         
         END LOOP;

         geom_2d.sdo_elem_info := p_input.sdo_elem_info;

         i := geom_2d.SDO_ELEM_INFO.FIRST;
         WHILE i < geom_2d.SDO_ELEM_INFO.LAST
         LOOP
            offset := geom_2d.SDO_ELEM_INFO(i);
            geom_2d.SDO_ELEM_INFO(i) := (offset - 1) / dim_count * 2 + 1;
            i := i + 3;
            
         END LOOP;

      END IF;

      IF geom_2d.SDO_GTYPE = 2001
      THEN
         RETURN true_point(geom_2d);
         
      ELSE
         RETURN geom_2d;
         
      END IF;

   END downsize_2d;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION downsize_2dM(
      p_input         IN  MDSYS.SDO_GEOMETRY
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      geom_2dm      MDSYS.SDO_GEOMETRY;
      dim_count     PLS_INTEGER;
      measure_chk   PLS_INTEGER;
      gtype         PLS_INTEGER;
      n_points      PLS_INTEGER;
      n_ordinates   PLS_INTEGER;
      i             PLS_INTEGER;
      j             PLS_INTEGER;
      k             PLS_INTEGER;
      offset        PLS_INTEGER;
      
   BEGIN

      IF p_input IS NULL
      THEN
         RETURN NULL;
         
      END IF;

      IF LENGTH (p_input.SDO_GTYPE) = 4
      THEN
         dim_count   := p_input.get_dims();
         measure_chk := p_input.get_lrs_dim();
         gtype       := p_input.get_gtype();
         
      ELSE
         RAISE_APPLICATION_ERROR(
             -20001
            ,'unable to determine dimensionality from gtype'
         );
         
      END IF;

      --------------------------------------------------------------------------
      -- Simple 2D input so just throw it back
      --------------------------------------------------------------------------
      IF dim_count = 2
      THEN
         RETURN p_input;
         
      --------------------------------------------------------------------------
      -- 2D + measure on 3 so just throw it back
      --------------------------------------------------------------------------
      ELSIF dim_count = 3
      AND measure_chk = 3
      THEN
         RETURN p_input;
         
      --------------------------------------------------------------------------
      -- Simple 3D so downsize to 2D
      --------------------------------------------------------------------------
      ELSIF dim_count = 3
      AND measure_chk = 0
      THEN
         RETURN downsize_2d(p_input);
         
      --------------------------------------------------------------------------
      -- 4D so assume measure on the 4
      --------------------------------------------------------------------------
      ELSIF dim_count = 4
      THEN
         --THIS IS BECAUSE ArcSDE is DUMB!
         measure_chk := 4;
         
      END IF;

      IF gtype = 1
      THEN
         geom_2dm := MDSYS.SDO_GEOMETRY(
             3300 + gtype
            ,p_input.sdo_srid
            ,MDSYS.SDO_POINT_TYPE(NULL,NULL,NULL)
            ,NULL
            ,NULL
         );
                 
         geom_2dm.SDO_POINT.X := p_input.SDO_ORDINATES(1);
         geom_2dm.SDO_POINT.Y := p_input.SDO_ORDINATES(2);
         geom_2dm.SDO_POINT.Z := p_input.SDO_ORDINATES(4);
         
         RETURN geom_2dm;
         
      ELSE
         geom_2dm := MDSYS.SDO_GEOMETRY(
             3300 + gtype
            ,p_input.sdo_srid
            ,NULL
            ,MDSYS.SDO_ELEM_INFO_ARRAY()
            ,MDSYS.SDO_ORDINATE_ARRAY()
         );
         
      END IF;

      n_points    := p_input.SDO_ORDINATES.COUNT / dim_count;
      n_ordinates := n_points * 3;
      geom_2dm.SDO_ORDINATES.EXTEND(n_ordinates);
      j := p_input.SDO_ORDINATES.FIRST;
      k := 1;
      
      FOR i IN 1 .. n_points
      LOOP
         geom_2dm.SDO_ORDINATES(k) := p_input.SDO_ORDINATES(j);
         geom_2dm.SDO_ORDINATES(k + 1) := p_input.SDO_ORDINATES(j + 1);
         geom_2dm.SDO_ORDINATES(k + 2) := p_input.SDO_ORDINATES(j + 3);
         j := j + dim_count;
         k := k + 3;
         
      END LOOP;

      geom_2dm.sdo_elem_info := p_input.sdo_elem_info;

      i := geom_2dm.SDO_ELEM_INFO.FIRST;
      WHILE i < geom_2dm.SDO_ELEM_INFO.LAST
      LOOP
         offset := geom_2dm.SDO_ELEM_INFO(i);
         geom_2dm.SDO_ELEM_INFO(i) := (offset - 1) / dim_count * 2 + 1;
         i := i + 3;
         
      END LOOP;

      RETURN geom_2dm;

   END downsize_2dM;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION downsize_3d(
      p_input   IN MDSYS.SDO_GEOMETRY
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      geom_3d       MDSYS.SDO_GEOMETRY;
      num_lrs       NUMBER;
      dim_count     PLS_INTEGER;
      gtype         PLS_INTEGER;
      n_points      PLS_INTEGER;
      n_ordinates   PLS_INTEGER;
      i             PLS_INTEGER;
      j             PLS_INTEGER;
      k             PLS_INTEGER;
      offset        PLS_INTEGER;
      
   BEGIN

      IF p_input IS NULL
      THEN
         RETURN NULL;
         
      END IF;

      IF LENGTH(p_input.SDO_GTYPE) = 4
      THEN
         dim_count := p_input.get_dims();
         gtype     := p_input.get_gtype();
         num_lrs   := p_input.get_lrs_dim();
         
      ELSE
         RAISE_APPLICATION_ERROR(
             -20001
            ,'unable to determine dimensionality from gtype'
         );
         
      END IF;

      IF dim_count = 3 AND num_lrs = 0
      THEN
         RETURN p_input;
         
      ELSIF dim_count = 3 AND num_lrs != 0
      THEN
         RETURN downsize_2d(p_input);
         
      ELSIF dim_count = 4 AND num_lrs = 0
      THEN
         -- we ASSUME that we remove the 4th dimension
         num_lrs := 4;
         
      END IF;

      geom_3d := MDSYS.SDO_GEOMETRY(
          3000 + gtype
         ,p_input.SDO_SRID
         ,p_input.SDO_POINT
         ,MDSYS.SDO_ELEM_INFO_ARRAY()
         ,MDSYS.SDO_ORDINATE_ARRAY()
      );

      IF geom_3d.sdo_point IS NOT NULL
      THEN
         geom_3d.sdo_elem_info := NULL;
         geom_3d.sdo_ordinates := NULL;
         
      ELSE
         n_points    := p_input.SDO_ORDINATES.COUNT / dim_count;
         n_ordinates := n_points * 3;
         geom_3d.SDO_ORDINATES.EXTEND(n_ordinates);
         j := p_input.SDO_ORDINATES.FIRST;
         k := 1;
         
         FOR i IN 1 .. n_points
         LOOP
            geom_3d.SDO_ORDINATES(k) := p_input.SDO_ORDINATES(j);
            geom_3d.SDO_ORDINATES(k + 1) := p_input.SDO_ORDINATES(j + 1);
            
            IF num_lrs = 4
            THEN
               geom_3d.SDO_ORDINATES(k + 2) := p_input.SDO_ORDINATES(j + 2);
               
            ELSIF num_lrs = 3
            THEN
               geom_3d.SDO_ORDINATES(k + 2) := p_input.SDO_ORDINATES(j + 3);
               
            END IF;
            
            j := j + dim_count;
            k := k + 3;
            
         END LOOP;

         geom_3d.sdo_elem_info := p_input.sdo_elem_info;

         i := geom_3d.SDO_ELEM_INFO.FIRST;
         WHILE i < geom_3d.SDO_ELEM_INFO.LAST
         LOOP
            offset := geom_3d.SDO_ELEM_INFO(i);
            geom_3d.SDO_ELEM_INFO(i) := (offset - 1) / dim_count * 3 + 1;
            i := i + 4;
            
         END LOOP;

      END IF;

      IF geom_3d.SDO_GTYPE = 2001
      THEN
         RETURN true_point(geom_3d);
         
      ELSE
         RETURN geom_3d;
         
      END IF;

   END downsize_3d;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION indent(
      p_level      IN NUMBER,
      p_amount     IN VARCHAR2 DEFAULT '   '
   ) RETURN VARCHAR2
   AS
      str_output VARCHAR2(4000 Char) := '';
      
   BEGIN
   
      IF  p_level IS NOT NULL
      AND p_level > 0
      THEN
         FOR i IN 1 .. p_level
         LOOP
            str_output := str_output || p_amount;
            
         END LOOP;
         
         RETURN str_output;
         
      ELSE
         RETURN '';
         
      END IF;
      
   END indent;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION pretty(
      p_input      IN CLOB,
      p_level      IN NUMBER,
      p_amount     IN VARCHAR2 DEFAULT '   ',
      p_linefeed   IN VARCHAR2 DEFAULT CHR(10)
   ) RETURN CLOB
   AS
      str_amount   VARCHAR2(4000 Char) := p_amount;
      str_linefeed VARCHAR2(2 Char)    := p_linefeed;
      
   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Process Incoming Parameters
      --------------------------------------------------------------------------
      IF p_amount IS NULL
      THEN
         str_amount := '   ';
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 20
      -- If input is NULL, then do nothing
      --------------------------------------------------------------------------
      IF p_input IS NULL
      THEN
         RETURN NULL;
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 30
      -- Return indented and line fed results
      --------------------------------------------------------------------------
      IF p_level IS NULL
      THEN
         RETURN p_input;
         
      ELSIF p_level = -1
      THEN
         RETURN p_input || TO_CLOB(str_linefeed);
         
      ELSE
         RETURN TO_CLOB(indent(p_level,str_amount)) || p_input || TO_CLOB(str_linefeed);
         
      END IF;

   END pretty;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION validate_unit(
      p_input        IN  VARCHAR2
   ) RETURN VARCHAR2
   AS
      str_input VARCHAR2(4000 Char) := UPPER(p_input);
   
   BEGIN
   
      IF str_input IS NULL
      THEN
         RETURN NULL;
         
      END IF;
      
      IF INSTR(str_input,'UNIT') > 0 AND INSTR(str_input,'=') > 0
      THEN
         RETURN str_input;
         
      ELSE
         RETURN 'UNIT=' || str_input;
         
      END IF;
   
   END validate_unit;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE verify_ordinate_rotation(
       p_rotation    IN            VARCHAR2
      ,p_input       IN OUT NOCOPY MDSYS.SDO_GEOMETRY
      ,p_lower_bound IN            PLS_INTEGER DEFAULT 1
      ,p_upper_bound IN            PLS_INTEGER DEFAULT NULL
   )
   AS
      str_rotation  VARCHAR2(3 Char);
      int_lb        PLS_INTEGER := p_lower_bound;
      int_ub        PLS_INTEGER := p_upper_bound;
      
   BEGIN

      IF p_rotation NOT IN ('CW','CCW')
      THEN
         RAISE_APPLICATION_ERROR(
             -20001
            ,'rotation values are CW or CCW'
         );
         
      END IF;

      IF p_upper_bound IS NULL
      THEN
         int_ub  := p_input.SDO_ORDINATES.COUNT;
         
      END IF;

      str_rotation := test_ordinate_rotation(
          p_input       => p_input
         ,p_lower_bound => int_lb
         ,p_upper_bound => int_ub
      );
 
      IF p_rotation = str_rotation
      THEN
         RETURN;
         
      ELSE
         reverse_ordinate_rotation(
             p_input       => p_input
            ,p_lower_bound => p_lower_bound
            ,p_upper_bound => p_upper_bound
         );
         
         RETURN;
         
      END IF;

   END verify_ordinate_rotation;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE test_ordinate_rotation(
      p_input       IN  MDSYS.SDO_GEOMETRY,
      p_lower_bound IN  NUMBER DEFAULT 1,
      p_upper_bound IN  NUMBER DEFAULT NULL,
      p_results     OUT VARCHAR2,
      p_area        OUT NUMBER
   )
   AS
      int_dims      PLS_INTEGER;
      int_lb        PLS_INTEGER := p_lower_bound;
      int_ub        PLS_INTEGER := p_upper_bound;
      num_x         NUMBER;
      num_y         NUMBER;
      num_lastx     NUMBER;
      num_lasty     NUMBER;

   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF int_ub IS NULL
      THEN
         int_ub  := p_input.SDO_ORDINATES.COUNT;
         
      END IF;

      IF int_lb IS NULL
      THEN
         int_lb  := 1;
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 20
      -- Get the number of dimensions in the geometry
      --------------------------------------------------------------------------
      int_dims := p_input.get_dims();

      --------------------------------------------------------------------------
      -- Step 30
      -- Loop through the ordinates create the area value
      --------------------------------------------------------------------------
      p_area  := 0;
      num_lastx := 0;
      num_lasty := 0;
      WHILE int_lb <= int_ub
      LOOP
         num_x := p_input.SDO_ORDINATES(int_lb);
         num_y := p_input.SDO_ORDINATES(int_lb + 1);
         p_area := p_area + ( (num_lasty * num_x ) - ( num_lastx * num_y) );
         num_lastx := num_x;
         num_lasty := num_y;
         int_lb := int_lb + int_dims;
         
      END LOOP;

      --------------------------------------------------------------------------
      -- Step 40
      -- If area is positive, then its clockwise
      --------------------------------------------------------------------------
      IF p_area > 0
      THEN
         p_results := 'CW';
         
      ELSE
         p_results := 'CCW';
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 50
      -- Preserve the area value if required by the caller
      --------------------------------------------------------------------------
      p_area := ABS(p_area);

   END test_ordinate_rotation;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION test_ordinate_rotation(
       p_input       IN  MDSYS.SDO_GEOMETRY
      ,p_lower_bound IN  NUMBER DEFAULT 1
      ,p_upper_bound IN  NUMBER DEFAULT NULL
   ) RETURN VARCHAR2
   AS
      str_results   VARCHAR2(3 Char);
      num_area      NUMBER;

   BEGIN

      test_ordinate_rotation(
          p_input       => p_input
         ,p_lower_bound => p_lower_bound
         ,p_upper_bound => p_upper_bound
         ,p_results     => str_results
         ,p_area        => num_area
      );

      RETURN str_results;

   END test_ordinate_rotation;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE test_ordinate_rotation(
       p_input       IN  MDSYS.SDO_ORDINATE_ARRAY
      ,p_lower_bound IN  NUMBER DEFAULT 1
      ,p_upper_bound IN  NUMBER DEFAULT NULL
      ,p_num_dims    IN  NUMBER DEFAULT 2
      ,p_results     OUT VARCHAR2
      ,p_area        OUT NUMBER
   )
   AS
      int_dims      PLS_INTEGER := p_num_dims;
      int_lb        PLS_INTEGER := p_lower_bound;
      int_ub        PLS_INTEGER := p_upper_bound;
      num_x         NUMBER;
      num_y         NUMBER;
      num_lastx     NUMBER;
      num_lasty     NUMBER;

   BEGIN

      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF int_dims IS NULL
      THEN
        int_dims := 2;
        
      END IF;
      
      IF int_ub IS NULL
      THEN
         int_ub  := p_input.COUNT;
         
      END IF;

      IF int_lb IS NULL
      THEN
         int_lb  := 1;
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 20
      -- Loop through the ordinates create the area value
      --------------------------------------------------------------------------
      p_area  := 0;
      num_lastx := 0;
      num_lasty := 0;
      WHILE int_lb <= int_ub
      LOOP
         num_x := p_input(int_lb);
         num_y := p_input(int_lb + 1);
         p_area := p_area + ( (num_lasty * num_x ) - ( num_lastx * num_y) );
         num_lastx := num_x;
         num_lasty := num_y;
         int_lb := int_lb + int_dims;
         
      END LOOP;

      --------------------------------------------------------------------------
      -- Step 40
      -- If area is positive, then its clockwise
      --------------------------------------------------------------------------
      IF p_area > 0
      THEN
         p_results := 'CW';
         
      ELSE
         p_results := 'CCW';
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 50
      -- Preserve the area value if required by the caller
      --------------------------------------------------------------------------
      p_area := ABS(p_area);

   END test_ordinate_rotation;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION test_ordinate_rotation(
       p_input       IN MDSYS.SDO_ORDINATE_ARRAY
      ,p_lower_bound IN NUMBER DEFAULT 1
      ,p_upper_bound IN NUMBER DEFAULT NULL
      ,p_num_dims    IN NUMBER DEFAULT 2
   ) RETURN VARCHAR2
   AS
      str_results   VARCHAR2(3 Char);
      num_area      NUMBER;

   BEGIN

      test_ordinate_rotation(
          p_input       => p_input
         ,p_lower_bound => p_lower_bound
         ,p_upper_bound => p_upper_bound
         ,p_num_dims    => p_num_dims
         ,p_results     => str_results
         ,p_area        => num_area
      );

      RETURN str_results;

   END test_ordinate_rotation;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE reverse_ordinate_rotation(
       p_input       IN OUT NOCOPY MDSYS.SDO_GEOMETRY
      ,p_lower_bound IN            PLS_INTEGER DEFAULT 1
      ,p_upper_bound IN            PLS_INTEGER DEFAULT NULL
   ) 
   AS
      int_n         PLS_INTEGER;
      int_m         PLS_INTEGER;
      int_li        PLS_INTEGER;
      int_ui        PLS_INTEGER;
      num_tempx     NUMBER;
      num_tempy     NUMBER;
      num_tempz     NUMBER;
      num_tempm     NUMBER;
      int_lb        PLS_INTEGER := p_lower_bound;
      int_ub        PLS_INTEGER := p_upper_bound;
      int_dims      PLS_INTEGER;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF int_lb IS NULL
      THEN
         int_lb := 1;
         
      END IF;
      
      IF int_ub IS NULL
      THEN
         int_ub  := p_input.SDO_ORDINATES.COUNT;
         
      END IF;
      
      int_dims := p_input.get_dims();

      int_n := int_ub - int_lb + 1;

      -- Exit if only a single ordinate
      IF int_n <= int_dims
      THEN
         RETURN;
         
      END IF;

      -- Calculate the start n1, the end n2, and the middle m
      int_m  := int_lb + (int_n / 2);
      int_li := int_lb;
      int_ui := int_ub;
      
      WHILE int_li < int_m
      LOOP
         IF int_dims = 2
         THEN
            num_tempx := p_input.SDO_ORDINATES(int_li);
            num_tempy := p_input.SDO_ORDINATES(int_li + 1);

            p_input.SDO_ORDINATES(int_li)     := p_input.SDO_ORDINATES(int_ui - 1);
            p_input.SDO_ORDINATES(int_li + 1) := p_input.SDO_ORDINATES(int_ui);

            p_input.SDO_ORDINATES(int_ui - 1) := num_tempx;
            p_input.SDO_ORDINATES(int_ui)     := num_tempy;

         ELSIF int_dims = 3
         THEN
            num_tempx := p_input.SDO_ORDINATES(int_li);
            num_tempy := p_input.SDO_ORDINATES(int_li + 1);
            num_tempz := p_input.SDO_ORDINATES(int_li + 2);

            p_input.SDO_ORDINATES(int_li)     := p_input.SDO_ORDINATES(int_ui - 2);
            p_input.SDO_ORDINATES(int_li + 1) := p_input.SDO_ORDINATES(int_ui - 1);
            p_input.SDO_ORDINATES(int_li + 2) := p_input.SDO_ORDINATES(int_ui);

            p_input.SDO_ORDINATES(int_ui - 2) := num_tempx;
            p_input.SDO_ORDINATES(int_ui - 1) := num_tempy;
            p_input.SDO_ORDINATES(int_ui)     := num_tempz;
            
         ELSIF int_dims = 4
         THEN
            num_tempx := p_input.SDO_ORDINATES(int_li);
            num_tempy := p_input.SDO_ORDINATES(int_li + 1);
            num_tempz := p_input.SDO_ORDINATES(int_li + 2);
            num_tempm := p_input.SDO_ORDINATES(int_li + 3);

            p_input.SDO_ORDINATES(int_li)     := p_input.SDO_ORDINATES(int_ui - 3);
            p_input.SDO_ORDINATES(int_li + 1) := p_input.SDO_ORDINATES(int_ui - 2);
            p_input.SDO_ORDINATES(int_li + 2) := p_input.SDO_ORDINATES(int_ui - 1);
            p_input.SDO_ORDINATES(int_li + 3) := p_input.SDO_ORDINATES(int_ui);

            p_input.SDO_ORDINATES(int_ui - 3) := num_tempx;
            p_input.SDO_ORDINATES(int_ui - 2) := num_tempy;
            p_input.SDO_ORDINATES(int_ui - 1) := num_tempz;
            p_input.SDO_ORDINATES(int_ui)     := num_tempm;
            
         END IF;

         int_li := int_li + int_dims;
         int_ui := int_ui - int_dims;

      END LOOP;

   END reverse_ordinate_rotation;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE reverse_ordinate_rotation(
       p_input       IN OUT NOCOPY MDSYS.SDO_ORDINATE_ARRAY
      ,p_lower_bound IN            PLS_INTEGER DEFAULT 1
      ,p_upper_bound IN            PLS_INTEGER DEFAULT NULL
      ,p_num_dims    IN            PLS_INTEGER DEFAULT 2
   ) 
   AS
      int_n         PLS_INTEGER;
      num_m         NUMBER;
      int_li        PLS_INTEGER;
      int_ui        PLS_INTEGER;
      num_tempx     NUMBER;
      num_tempy     NUMBER;
      num_tempz     NUMBER;
      num_tempm     NUMBER;
      int_lb        PLS_INTEGER := p_lower_bound;
      int_ub        PLS_INTEGER := p_upper_bound;
      int_dims      PLS_INTEGER := p_num_dims;
      
   BEGIN

      IF int_lb IS NULL
      THEN
         int_lb := 1;
         
      END IF;
      
      IF int_ub IS NULL
      THEN
         int_ub  := p_input.COUNT;
         
      END IF;
      
      IF int_dims IS NULL
      THEN
         int_dims := 2;
         
      END IF;

      int_n := int_ub - int_lb + 1;

      -- Exit if only a single ordinate
      IF int_n <= int_dims
      THEN
         RETURN;
         
      END IF;

      -- Calculate the start n1, the end n2, and the middle m
      num_m  := int_lb + (int_n / 2); 
      int_li := int_lb;
      int_ui := int_ub;

      WHILE int_li < num_m
      LOOP
         IF int_dims = 2
         THEN
            num_tempx := p_input(int_li);
            num_tempy := p_input(int_li + 1);

            p_input(int_li)     := p_input(int_ui - 1);
            p_input(int_li + 1) := p_input(int_ui);

            p_input(int_ui - 1) := num_tempx;
            p_input(int_ui)     := num_tempy;

         ELSIF int_dims = 3
         THEN
            num_tempx := p_input(int_li);
            num_tempy := p_input(int_li + 1);
            num_tempz := p_input(int_li + 2);

            p_input(int_li)     := p_input(int_ui - 2);
            p_input(int_li + 1) := p_input(int_ui - 1);
            p_input(int_li + 2) := p_input(int_ui);

            p_input(int_ui - 2) := num_tempx;
            p_input(int_ui - 1) := num_tempy;
            p_input(int_ui)     := num_tempz;
            
         ELSIF int_dims = 4
         THEN
            num_tempx := p_input(int_li);
            num_tempy := p_input(int_li + 1);
            num_tempz := p_input(int_li + 2);
            num_tempm := p_input(int_li + 3);

            p_input(int_li)     := p_input(int_ui - 3);
            p_input(int_li + 1) := p_input(int_ui - 2);
            p_input(int_li + 2) := p_input(int_ui - 1);
            p_input(int_li + 3) := p_input(int_ui);

            p_input(int_ui - 3) := num_tempx;
            p_input(int_ui - 2) := num_tempy;
            p_input(int_ui - 1) := num_tempz;
            p_input(int_ui)     := num_tempm;
            
         END IF;

         int_li := int_li + int_dims;
         int_ui := int_ui - int_dims;

      END LOOP;

   END reverse_ordinate_rotation;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION reverse_ordinate_rotation(
       p_input       IN  MDSYS.SDO_ORDINATE_ARRAY
      ,p_lower_bound IN  NUMBER DEFAULT 1
      ,p_upper_bound IN  NUMBER DEFAULT NULL
      ,p_num_dims    IN  NUMBER DEFAULT 2
   ) RETURN MDSYS.SDO_ORDINATE_ARRAY
   AS
      sdo_ord_output MDSYS.SDO_ORDINATE_ARRAY := p_input;
      
   BEGIN
   
      reverse_ordinate_rotation(
          p_input       => sdo_ord_output
         ,p_lower_bound => p_lower_bound
         ,p_upper_bound => p_upper_bound
         ,p_num_dims    => p_num_dims
      );
      
      RETURN sdo_ord_output;
      
   END reverse_ordinate_rotation;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE append2(
       p_input      IN OUT MDSYS.SDO_GEOMETRY_ARRAY
      ,p_value      IN     MDSYS.SDO_GEOMETRY
   )
   AS
      num_index   PLS_INTEGER;
      
   BEGIN
      
      IF p_input IS NULL
      OR p_input.COUNT = 0
      THEN
         p_input := MDSYS.SDO_GEOMETRY_ARRAY();
         
      END IF;
      
      num_index := p_input.COUNT + 1;
      p_input.EXTEND(1);
      p_input(num_index) := p_value;
      
   END append2;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE append2(
       p_input      IN OUT MDSYS.SDO_GEOMETRY_ARRAY
      ,p_value      IN     MDSYS.SDO_GEOMETRY_ARRAY
   )
   AS
   BEGIN
   
      IF p_value IS NULL
      OR p_value.COUNT = 0
      THEN
         RETURN;
         
      END IF;
   
      FOR i IN 1 .. p_value.COUNT
      LOOP
         append2(
             p_input => p_input
            ,p_value => p_value(i)
         );
         
      END LOOP;
      
   END append2;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE append2(
       p_input      IN OUT MDSYS.SDO_ORDINATE_ARRAY
      ,p_value      IN     NUMBER
   )
   AS
      num_index   PLS_INTEGER;
      
   BEGIN
      
      IF p_input IS NULL
      OR p_input.COUNT = 0
      THEN
         p_input := MDSYS.SDO_ORDINATE_ARRAY();
         
      END IF;
      
      num_index := p_input.COUNT + 1;
      p_input.EXTEND(1);
      p_input(num_index) := p_value;
      
   END append2;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE append2(
       p_input      IN OUT MDSYS.SDO_ORDINATE_ARRAY
      ,p_value      IN     MDSYS.SDO_ORDINATE_ARRAY
   )
   AS
   BEGIN
      IF p_value IS NULL
      OR p_value.COUNT = 0
      THEN
         RETURN;
         
      END IF;
   
      FOR i IN 1 .. p_value.COUNT
      LOOP
         append2(
             p_input => p_input
            ,p_value => p_value(i)
         );
         
      END LOOP;
      
   END append2;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE append2(
       p_input_array      IN OUT MDSYS.SDO_NUMBER_ARRAY
      ,p_input_value      IN     NUMBER
      ,p_unique           IN     VARCHAR2 DEFAULT 'FALSE'
   )
   AS
      boo_check   BOOLEAN;
      num_index   PLS_INTEGER;
      str_unique  VARCHAR2(5 Char);
      
   BEGIN
   
      IF p_unique IS NULL
      THEN
         str_unique := 'FALSE';
         
      ELSIF UPPER(p_unique) IN ('FALSE','TRUE')
      THEN
         str_unique := UPPER(p_unique);
         
      ELSE
         RAISE_APPLICATION_ERROR(-20001,'p_unique flag must be TRUE or FALSE');
         
      END IF;

      IF p_input_array IS NULL
      THEN
         p_input_array := MDSYS.SDO_NUMBER_ARRAY();
         
      END IF;

      IF p_input_array.COUNT > 0
      THEN
         IF str_unique = 'TRUE'
         THEN
            boo_check := FALSE;
            
            FOR i IN 1 .. p_input_array.COUNT
            LOOP
               IF p_input_value = p_input_array(i)
               THEN
                  boo_check := TRUE;
                  
               END IF;
               
            END LOOP;

            IF boo_check = TRUE
            THEN
               -- Do Nothing
               RETURN;
               
            END IF;

         END IF;

      END IF;

      num_index := p_input_array.COUNT + 1;
      p_input_array.EXTEND(1);
      p_input_array(num_index) := p_input_value;

   END append2;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE append2(
       p_input_array      IN OUT MDSYS.SDO_NUMBER_ARRAY
      ,p_input_value      IN     MDSYS.SDO_NUMBER_ARRAY
      ,p_unique           IN     VARCHAR2 DEFAULT 'FALSE'
   )
   AS
   BEGIN
   
      FOR i IN 1 .. p_input_value.COUNT
      LOOP
         append2(
            p_input_array => p_input_array,
            p_input_value => p_input_value(i),
            p_unique      => p_unique
         );
         
      END LOOP;
      
   END append2;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION sdo2varray(
      p_input IN  MDSYS.SDO_GEOMETRY
   ) RETURN MDSYS.SDO_GEOMETRY_ARRAY
   AS
      ary_output MDSYS.SDO_GEOMETRY_ARRAY;
      int_elems  NUMBER;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming paramters
      --------------------------------------------------------------------------
      ary_output := MDSYS.SDO_GEOMETRY_ARRAY();
      
      IF p_input IS NULL
      THEN
         RETURN ary_output;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Break into components
      --------------------------------------------------------------------------
      int_elems := MDSYS.SDO_UTIL.GETNUMELEM(p_input);
      ary_output.EXTEND(int_elems);
      
      FOR i IN 1 .. int_elems
      LOOP
         ary_output(i) := MDSYS.SDO_UTIL.EXTRACT(p_input,i);
         
      END LOOP;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Return results
      --------------------------------------------------------------------------
      RETURN ary_output;
      
   END sdo2varray;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION varray2sdo(
       p_input              IN  MDSYS.SDO_GEOMETRY_ARRAY
      ,p_union_flag         IN  VARCHAR2 DEFAULT 'FALSE' 
      ,p_tolerance          IN  NUMBER DEFAULT 0.05
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      sdo_output     MDSYS.SDO_GEOMETRY;
      str_union_flag VARCHAR2(4000 Char) := UPPER(p_union_flag);
      num_tolerance  NUMBER := p_tolerance;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming paramters
      --------------------------------------------------------------------------
      IF p_input IS NULL
      OR p_input.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;
      
      IF num_tolerance IS NULL
      THEN
         num_tolerance := 0.05;
      
      END IF;
      
      IF str_union_flag IS NULL
      THEN
         str_union_flag := 'FALSE';
         
      ELSIF str_union_flag NOT IN ('TRUE','FALSE')
      THEN
         RAISE_APPLICATION_ERROR(-20001,'boolean error');
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Combine the varray together
      --------------------------------------------------------------------------
      FOR i IN 1 .. p_input.COUNT
      LOOP
         IF sdo_output IS NULL
         THEN
            sdo_output := p_input(i);
            
         ELSE
            sdo_output := MDSYS.SDO_UTIL.APPEND(
                sdo_output
               ,p_input(i)
            );
            
         END IF;
         
      END LOOP;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Union if requested
      --------------------------------------------------------------------------
      IF str_union_flag = 'TRUE'
      THEN
         sdo_output := MDSYS.SDO_GEOM.SDO_UNION(
             sdo_output
            ,sdo_output
            ,num_tolerance
         );
         
      END IF;
         
      --------------------------------------------------------------------------
      -- Step 40
      -- Return results
      --------------------------------------------------------------------------
      RETURN sdo_output;
      
   END varray2sdo;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION getnumrings(
      p_input                  IN  MDSYS.SDO_GEOMETRY
   ) RETURN NUMBER
   AS
      i         PLS_INTEGER := 1;
      int_rings PLS_INTEGER := 0;
      
   BEGIN

      IF p_input IS NULL
      OR p_input.SDO_GTYPE IS NULL
      THEN
         RETURN 0;
         
      END IF;

      WHILE i <= p_input.SDO_ELEM_INFO.COUNT
      LOOP
         i := i + 1;
         
         IF p_input.SDO_ELEM_INFO(i) = 1005
         OR p_input.SDO_ELEM_INFO(i) = 2005
         THEN
            RAISE_APPLICATION_ERROR(-20001,'compound geometries not supported');
            
         ELSIF p_input.SDO_ELEM_INFO(i) = 1003
         OR p_input.SDO_ELEM_INFO(i) = 2003
         THEN
            int_rings := int_rings + 1;
            
         END IF;
         
         i := i + 2;
         
      END LOOP;
      
      RETURN int_rings;
   
   END getnumrings;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION scrub_lines(
      p_input               IN MDSYS.SDO_GEOMETRY
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      int_gtype   PLS_INTEGER;
      sdo_temp    MDSYS.SDO_GEOMETRY;
      output      MDSYS.SDO_GEOMETRY;
      
   BEGIN

      IF p_input IS NULL
      THEN
         RETURN NULL;
         
      END IF;

      int_gtype := p_input.get_gtype();

      IF int_gtype IN (3,7)
      THEN
         RAISE_APPLICATION_ERROR(-20001,'found polygons in your lines');
         
      ELSIF int_gtype IN (2,6)
      THEN
         RETURN p_input;
         
      ELSIF int_gtype IN (1,5)
      THEN
         RETURN NULL;
         
      ELSIF int_gtype = 4
      THEN
         FOR i IN 1 .. MDSYS.SDO_UTIL.GETNUMELEM(p_input)
         LOOP
            sdo_temp := MDSYS.SDO_UTIL.EXTRACT(p_input,i);
            IF sdo_temp.get_gtype() = 2
            THEN
               IF output IS NULL
               THEN
                  output := sdo_temp;
                  
               ELSE
                  output := MDSYS.SDO_UTIL.APPEND(output,sdo_temp);
                  
               END IF;
               
            ELSIF sdo_temp.get_gtype() = 3
            THEN
               RAISE_APPLICATION_ERROR(-20001,'found polygons in your lines');
               
            END IF;
            
         END LOOP;
         
         RETURN output;
         
      END IF;

   END scrub_lines;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION scrub_polygons(
      p_input                  IN MDSYS.SDO_GEOMETRY
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      int_gtype   PLS_INTEGER;
      sdo_temp    MDSYS.SDO_GEOMETRY;
      output      MDSYS.SDO_GEOMETRY;
      
   BEGIN

      IF p_input IS NULL
      THEN
         RETURN NULL;
         
      END IF;

      int_gtype := p_input.get_gtype();

      IF int_gtype IN (3,7)
      THEN
         RETURN p_input;
         
      ELSIF int_gtype IN (1,2,5,6)
      THEN
         RETURN NULL;
         
      ELSIF int_gtype = 4
      THEN
         FOR i IN 1 .. MDSYS.SDO_UTIL.GETNUMELEM(p_input)
         LOOP
            sdo_temp := MDSYS.SDO_UTIL.EXTRACT(p_input,i);
            
            IF sdo_temp.get_gtype() = 3
            THEN
               IF output IS NULL
               THEN
                  output := sdo_temp;
                  
               ELSE
                  output := MDSYS.SDO_UTIL.APPEND(output,sdo_temp);
                  
               END IF;
               
            END IF;
            
         END LOOP;
         
         RETURN output;
         
      END IF;

   END scrub_polygons;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION is_spaghetti(
       p_input             IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance         IN  NUMBER DEFAULT 0.05
   ) RETURN VARCHAR2
   AS
      num_tolerance    NUMBER := p_tolerance;
      ary_strings      MDSYS.SDO_GEOMETRY_ARRAY := MDSYS.SDO_GEOMETRY_ARRAY();
      ary_starts       MDSYS.SDO_GEOMETRY_ARRAY := MDSYS.SDO_GEOMETRY_ARRAY();
      ary_ends         MDSYS.SDO_GEOMETRY_ARRAY := MDSYS.SDO_GEOMETRY_ARRAY();
      int_count        PLS_INTEGER;
      ary_start_count  MDSYS.SDO_NUMBER_ARRAY := MDSYS.SDO_NUMBER_ARRAY();
      ary_end_count    MDSYS.SDO_NUMBER_ARRAY := MDSYS.SDO_NUMBER_ARRAY();
      ary_inside_count MDSYS.SDO_NUMBER_ARRAY := MDSYS.SDO_NUMBER_ARRAY();
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF p_input IS NULL
      THEN
         RETURN NULL;
         
      ELSIF p_input.get_gtype = 2
      THEN
         RETURN 'FALSE';
         
      ELSIF p_input.get_gtype <> 6
      THEN
         RAISE_APPLICATION_ERROR(-20001,'input gtype must be 2 or 6');
         
      END IF;
      
      IF num_tolerance IS NULL
      THEN
         num_tolerance := 0.05;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Break multistring into single linestrings with nodes
      --------------------------------------------------------------------------
      int_count := MDSYS.SDO_UTIL.GETNUMELEM(p_input);
      ary_strings.EXTEND(int_count);
      ary_starts.EXTEND(int_count);
      ary_ends.EXTEND(int_count);
      ary_start_count.EXTEND(int_count);
      ary_end_count.EXTEND(int_count);
      ary_inside_count.EXTEND(int_count);
      
      FOR i IN 1 .. int_count
      LOOP
         ary_strings(i) := MDSYS.SDO_UTIL.EXTRACT(p_input,i);
         ary_starts(i)  := get_start_point(ary_strings(i));
         ary_ends(i)    := get_end_point(ary_strings(i));
         
      END LOOP;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Loop through and count the nodes connections
      --------------------------------------------------------------------------
      FOR i IN 1 .. int_count
      LOOP
         ary_start_count(i)  := 0;
         ary_end_count(i)    := 0;
         ary_inside_count(i) := 0;
         
         FOR j IN 1 .. int_count
         LOOP
            IF i != j
            THEN
               IF MDSYS.SDO_GEOM.RELATE(
                   ary_starts(i)
                  ,'DETERMINE'
                  ,ary_strings(j)
                  ,num_tolerance
               ) IN ('TOUCH','CONTAINS','COVERS','ON')
               THEN
                  ary_start_count(i) := ary_start_count(i) + 1;
                  
               ELSIF MDSYS.SDO_GEOM.RELATE(
                   ary_ends(i)
                  ,'DETERMINE'
                  ,ary_strings(j)
                  ,num_tolerance
               ) IN ('TOUCH','CONTAINS','COVERS','ON')
               THEN
                  ary_end_count(i) := ary_end_count(i) + 1;
               
               ELSIF MDSYS.SDO_GEOM.RELATE(
                   ary_strings(i)
                  ,'DETERMINE'
                  ,ary_strings(j)
                  ,num_tolerance
               ) IN ('TOUCH','CONTAINS','COVERS','OVERLAPBYINTERSECT')
               THEN
                  ary_inside_count(i) := ary_inside_count(i) + 1;
                  
               END IF;

            END IF;
         
         END LOOP;
         
         IF ary_start_count(i) > 1
         OR ary_end_count(i) > 1
         OR ary_inside_count(i) > 0
         THEN
            RETURN 'TRUE';
            
         END IF;
         
      END LOOP;
      
      RETURN 'FALSE';
   
   END is_spaghetti;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION is_polygon(
       p_input         IN MDSYS.SDO_GEOMETRY
      ,p_tolerance     IN NUMBER DEFAULT 0.05
   ) RETURN VARCHAR2
   AS
      int_dims      PLS_INTEGER;
      int_gtype     PLS_INTEGER;
      num_tolerance NUMBER := p_tolerance;
      
   BEGIN
   
      IF num_tolerance IS NULL
      THEN
         num_tolerance := 0.05;
      
      END IF;
      
      int_dims   := p_input.get_dims();
      int_gtype  := p_input.get_gtype();

      IF int_gtype NOT IN (3,7)
      THEN
         RETURN 'FALSE';
         
      END IF;

      IF MDSYS.SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(
          p_input
         ,num_tolerance
      ) = 'TRUE'
      THEN
         RETURN 'TRUE';
         
      ELSE
         RETURN 'ERROR';
         
      END IF;

   END is_polygon;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION centroid(
       p_input              IN  MDSYS.SDO_GEOMETRY
      ,p_modifier           IN  VARCHAR2 DEFAULT NULL
      ,p_tolerance          IN  NUMBER DEFAULT 0.05
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      num_tolerance NUMBER := p_tolerance;
      
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
      
      --------------------------------------------------------------------------
      -- Step 20
      -- If polygons or points, then use the oracle default
      --------------------------------------------------------------------------
      IF p_input.get_gtype() IN (1,3,5,7)
      THEN
         RETURN MDSYS.SDO_GEOM.SDO_CENTROID(
             p_input
            ,num_tolerance
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Otherwise get the centroid of the mbr of the geometries
      --------------------------------------------------------------------------
      RETURN MDSYS.SDO_GEOM.SDO_CENTROID(
          MDSYS.SDO_GEOM.SDO_MBR(p_input)
         ,num_tolerance
      );
      
   END centroid;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE point2coordinates(
      p_input   IN  MDSYS.SDO_GEOMETRY,
      p_x       OUT NUMBER,
      p_y       OUT NUMBER,
      p_z       OUT NUMBER,
      p_m       OUT NUMBER
   )
   AS
      int_gtype     PLS_INTEGER;
      int_dims      PLS_INTEGER;
      int_lrs       PLS_INTEGER;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      int_gtype := p_input.get_gtype();
      int_dims  := p_input.get_dims();
      int_lrs   := p_input.get_lrs_dim();
      
      IF int_gtype != 1
      THEN
         RAISE_APPLICATION_ERROR(-20001,'input must be a single point');
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Unload the ordinates
      --------------------------------------------------------------------------
      IF p_input.SDO_POINT IS NULL
      THEN
         p_x := p_input.SDO_ORDINATES(1);
         p_y := p_input.SDO_ORDINATES(2);
         
         IF int_dims > 2
         THEN
            IF int_lrs = 3
            THEN
               p_m := p_input.SDO_ORDINATES(3);
               
            ELSE
               p_z := p_input.SDO_ORDINATES(3);
               
            END IF;
            
         END IF;
         
         IF int_dims > 3
         THEN
            IF int_lrs IN (4,0)
            THEN
               p_m := p_input.SDO_ORDINATES(4);
               
            ELSE
               p_z := p_input.SDO_ORDINATES(4);
               
            END IF;
            
         END IF;
         
      ELSE
      
         p_x := p_input.SDO_POINT.X;
         p_y := p_input.SDO_POINT.Y;
         
         IF int_dims > 2
         THEN
            IF int_lrs = 3
            THEN
               p_m := p_input.SDO_POINT.Z;
               
            ELSE
               p_z := p_input.SDO_POINT.Z;
               
            END IF;
            
         END IF;
         
      END IF;
      
   END point2coordinates;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION update_end_point(
       p_input        IN  MDSYS.SDO_GEOMETRY
      ,p_end_point    IN  MDSYS.SDO_GEOMETRY
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      sdo_output MDSYS.SDO_GEOMETRY;
      int_dims   PLS_INTEGER;
      int_gtyp   PLS_INTEGER;
      int_lrs    PLS_INTEGER;
      int_len    PLS_INTEGER;
      num_x      NUMBER;
      num_y      NUMBER;
      num_z      NUMBER;
      num_m      NUMBER;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF p_input IS NULL
      THEN
         RETURN NULL;
         
      END IF;
      
      IF p_end_point.get_gtype() != 1
      THEN
         RAISE_APPLICATION_ERROR(
             -20001
            ,'new end geometry must be a single point'
         );
         
      END IF;
      
      IF p_input.SDO_SRID != p_end_point.SDO_SRID
      THEN
         RAISE_APPLICATION_ERROR(
             -20001
            ,'input geometries must be in the same coordinate system'
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Gather information about the geometry
      --------------------------------------------------------------------------
      sdo_output := p_input;
      int_dims   := p_input.get_dims();
      int_gtyp   := p_input.get_gtype();
      int_lrs    := p_input.get_lrs_dim();
      int_len    := p_input.SDO_ORDINATES.COUNT();
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Break apart the point
      --------------------------------------------------------------------------
      point2coordinates(
          p_input => p_end_point
         ,p_x     => num_x
         ,p_y     => num_y
         ,p_z     => num_z
         ,p_m     => num_m
      );
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Insert results
      --------------------------------------------------------------------------
      IF int_dims = 2
      THEN
         sdo_output.SDO_ORDINATES(int_len - 1) := num_x;
         sdo_output.SDO_ORDINATES(int_len)     := num_y;
         
      ELSIF  int_dims = 3
      AND int_lrs = 3
      THEN
         sdo_output.SDO_ORDINATES(int_len - 2) := num_x;
         sdo_output.SDO_ORDINATES(int_len - 1) := num_y;
         sdo_output.SDO_ORDINATES(int_len)     := num_m;
         
      ELSIF  int_dims = 3
      AND int_lrs = 0
      THEN 
         sdo_output.SDO_ORDINATES(int_len - 2) := num_x;
         sdo_output.SDO_ORDINATES(int_len - 1) := num_y;
         sdo_output.SDO_ORDINATES(int_len)     := num_z;
         
      ELSIF  int_dims = 4
      AND int_lrs IN (4,0)
      THEN 
         sdo_output.SDO_ORDINATES(int_len - 3) := num_x;
         sdo_output.SDO_ORDINATES(int_len - 2) := num_y;
         sdo_output.SDO_ORDINATES(int_len - 1) := num_z;
         sdo_output.SDO_ORDINATES(int_len)     := num_m;
         
      ELSIF  int_dims = 4
      AND int_lrs = 3
      THEN 
         sdo_output.SDO_ORDINATES(int_len - 3) := num_x;
         sdo_output.SDO_ORDINATES(int_len - 2) := num_y;
         sdo_output.SDO_ORDINATES(int_len - 1) := num_m;
         sdo_output.SDO_ORDINATES(int_len)     := num_z;
         
      ELSE
         RAISE_APPLICATION_ERROR(-20001,'err');
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Return results
      --------------------------------------------------------------------------
      RETURN sdo_output;
   
   END update_end_point;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION append_end_point(
      p_input        IN  MDSYS.SDO_GEOMETRY,
      p_end_point    IN  MDSYS.SDO_GEOMETRY
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      sdo_output MDSYS.SDO_GEOMETRY;
      int_dims   PLS_INTEGER;
      int_gtyp   PLS_INTEGER;
      int_lrs    PLS_INTEGER;
      int_len    PLS_INTEGER;
      num_x      NUMBER;
      num_y      NUMBER;
      num_z      NUMBER;
      num_m      NUMBER;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF p_input IS NULL
      THEN
         RETURN NULL;
         
      END IF;
      
      IF p_end_point.get_gtype() <> 1
      THEN
         RAISE_APPLICATION_ERROR(
             -20001
            ,'new start geometry must be a single point'
         );
         
      END IF;
      
      IF p_input.get_gtype() NOT IN (1,2,5,6)
      THEN
         RAISE_APPLICATION_ERROR(
             -20001
            ,'input geometry cannot be a polygon'
         );
         
      END IF;
      
      IF p_input.SDO_SRID != p_end_point.SDO_SRID
      THEN
         RAISE_APPLICATION_ERROR(
             -20001
            ,'input geometries must be in the same coordinate system'
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Gather information about the geometry
      --------------------------------------------------------------------------
      sdo_output := p_input;
      int_dims   := p_input.get_dims();
      int_gtyp   := p_input.get_gtype();
      int_lrs    := p_input.get_lrs_dim();
      int_len    := p_input.SDO_ORDINATES.COUNT();
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Handle point and multipoint inputs
      --------------------------------------------------------------------------
      IF int_gtyp IN (1,5)
      THEN
         RETURN MDSYS.SDO_UTIL.APPEND(
             p_input
            ,p_end_point
         );
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Break apart the point
      --------------------------------------------------------------------------
      point2coordinates(
          p_input => p_end_point
         ,p_x     => num_x
         ,p_y     => num_y
         ,p_z     => num_z
         ,p_m     => num_m
      );

      --------------------------------------------------------------------------
      -- Step 50
      -- Insert results
      --------------------------------------------------------------------------
      IF int_dims = 2
      THEN
         sdo_output.SDO_ORDINATES.EXTEND(2);
         sdo_output.SDO_ORDINATES(int_len + 1) := num_x;
         sdo_output.SDO_ORDINATES(int_len + 2) := num_y;
         
      ELSIF  int_dims = 3
      AND int_lrs = 3
      THEN
         sdo_output.SDO_ORDINATES.EXTEND(3);
         sdo_output.SDO_ORDINATES(int_len + 1) := num_x;
         sdo_output.SDO_ORDINATES(int_len + 2) := num_y;
         sdo_output.SDO_ORDINATES(int_len + 3) := num_m;
         
      ELSIF  int_dims = 3
      AND int_lrs = 0
      THEN 
         sdo_output.SDO_ORDINATES.EXTEND(3);
         sdo_output.SDO_ORDINATES(int_len + 1) := num_x;
         sdo_output.SDO_ORDINATES(int_len + 2) := num_y;
         sdo_output.SDO_ORDINATES(int_len + 3) := num_z;
         
      ELSIF  int_dims = 4
      AND int_lrs IN (4,0)
      THEN 
         sdo_output.SDO_ORDINATES.EXTEND(4);
         sdo_output.SDO_ORDINATES(int_len + 1) := num_x;
         sdo_output.SDO_ORDINATES(int_len + 2) := num_y;
         sdo_output.SDO_ORDINATES(int_len + 3) := num_z;
         sdo_output.SDO_ORDINATES(int_len + 4) := num_m;
         
      ELSIF  int_dims = 4
      AND int_lrs = 3
      THEN 
         sdo_output.SDO_ORDINATES.EXTEND(4);
         sdo_output.SDO_ORDINATES(int_len + 1) := num_x;
         sdo_output.SDO_ORDINATES(int_len + 2) := num_y;
         sdo_output.SDO_ORDINATES(int_len + 3) := num_m;
         sdo_output.SDO_ORDINATES(int_len + 4) := num_z;
         
      ELSE
         RAISE_APPLICATION_ERROR(-20001,'err');
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Return results
      --------------------------------------------------------------------------
      RETURN sdo_output;
   
   END append_end_point;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION get_gtype(
      p_input         IN  MDSYS.SDO_GEOMETRY
   ) RETURN NUMBER
   AS
   BEGIN
      IF p_input IS NULL
      THEN
         RETURN NULL;
         
      ELSE
         RETURN p_input.get_gtype();
         
      END IF;
      
   END get_gtype;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION dz_length(
       p_input         IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance     IN  NUMBER DEFAULT 0.05
      ,p_unit          IN  VARCHAR2 DEFAULT NULL
   ) RETURN NUMBER
   AS
      num_tolerance NUMBER := p_tolerance;
      str_unit      VARCHAR2(4000 Char) := UPPER(p_unit);
      
   BEGIN
      
      IF str_unit IS NOT NULL
      THEN
         str_unit := validate_unit(str_unit);
      
      END IF;
      
      IF num_tolerance IS NULL
      THEN
         num_tolerance := 0.05;
         
      END IF;
      
      IF str_unit IS NULL
      THEN
         RETURN MDSYS.SDO_GEOM.SDO_LENGTH(
             geom   => p_input
            ,tol    => num_tolerance
         );
         
      ELSE
         RETURN MDSYS.SDO_GEOM.SDO_LENGTH(
             geom   => p_input
            ,tol    => num_tolerance
            ,unit   => str_unit
         );
         
      END IF;
      
   END dz_length;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION dz_distance(
       p_input_1       IN  MDSYS.SDO_GEOMETRY
      ,p_input_2       IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance     IN  NUMBER DEFAULT 0.05
      ,p_unit          IN  VARCHAR2 DEFAULT NULL
   ) RETURN NUMBER
   AS
      num_tolerance NUMBER := p_tolerance;
      str_unit      VARCHAR2(4000 Char) := UPPER(p_unit);
      
   BEGIN
   
      IF str_unit IS NOT NULL
      THEN
         str_unit := validate_unit(str_unit);
      
      END IF;
      
      IF num_tolerance IS NULL
      THEN
         num_tolerance := 0.05;
         
      END IF;
      
      IF str_unit IS NULL
      THEN
         RETURN MDSYS.SDO_GEOM.SDO_DISTANCE(
             geom1  => p_input_1
            ,geom2  => p_input_2
            ,tol    => num_tolerance
         );
         
      ELSE
         RETURN MDSYS.SDO_GEOM.SDO_DISTANCE(
             geom1  => p_input_1
            ,geom2  => p_input_2
            ,tol    => num_tolerance
            ,unit   => str_unit
         );
         
      END IF;
   
   END dz_distance;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION is_closed_loop(
       p_input         IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance     IN  NUMBER DEFAULT 0.05
      ,p_threshold     IN  NUMBER DEFAULT 0
      ,p_unit          IN  VARCHAR2 DEFAULT NULL
   ) RETURN VARCHAR2
   AS
      num_tolerance  NUMBER := p_tolerance;
      num_threshold  NUMBER := p_threshold;
      
   BEGIN
      
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF p_input IS NULL
      THEN
         RETURN NULL;
         
      END IF;
      
      IF p_input.get_gtype NOT IN (2,6)
      THEN
         RAISE_APPLICATION_ERROR(-20001,'line strings only');
         
      END IF;
      
      IF num_tolerance IS NULL
      THEN
         num_tolerance := 0.05;
         
      END IF;
      
      IF num_threshold IS NULL
      THEN
         num_threshold := 0;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- multistring wimp out
      --------------------------------------------------------------------------
      IF p_input.get_gtype = 6
      THEN
         RAISE_APPLICATION_ERROR(-20001,'unimplemented');
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- look for problem strings
      --------------------------------------------------------------------------
      IF count_points(p_input => p_input) < 3
      THEN
         RETURN 'FALSE';
         
      END IF;
      
      IF dz_length(
          p_input     => p_input
         ,p_tolerance => num_tolerance
         ,p_unit      => p_unit
      ) < num_threshold
      THEN
         RETURN 'FALSE';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- test the gap
      --------------------------------------------------------------------------
      IF dz_distance(
          p_input_1   => get_start_point(p_input => p_input)
         ,p_input_2   => get_end_point(p_input => p_input)
         ,p_tolerance => num_tolerance
         ,p_unit      => p_unit
      ) <= num_threshold
      THEN
         RETURN 'TRUE';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- must not be a closed loop
      --------------------------------------------------------------------------
      RETURN 'FALSE';
      
   END is_closed_loop;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION clip_string_by_vertices(
       p_input         IN  MDSYS.SDO_GEOMETRY
      ,p_start_vertice IN  NUMBER DEFAULT 1
      ,p_end_vertice   IN  NUMBER DEFAULT NULL
      ,p_2d_flag       IN  VARCHAR2 DEFAULT 'FALSE'
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      num_vertices      NUMBER;
      num_start_vertice NUMBER := p_start_vertice;
      num_end_vertice   NUMBER := p_end_vertice;
      sdoords_output    MDSYS.SDO_ORDINATE_ARRAY;
      int_counter       PLS_INTEGER;
      int_num_dims      PLS_INTEGER;
      str_2d_flag       VARCHAR2(4000 Char) := UPPER(p_2d_flag);
      
   BEGIN
   
      IF str_2d_flag IS NULL
      THEN
         str_2d_flag := 'FALSE';
      
      ELSIF str_2d_flag NOT IN ('TRUE','FALSE')
      THEN
         RAISE_APPLICATION_ERROR(-20001,'boolean error');
         
      END IF;
      
      IF p_input IS NULL
      THEN
         RETURN NULL;
         
      END IF;
      
      IF p_input.get_gtype() <> 2
      THEN
          RAISE_APPLICATION_ERROR(-20001,'linestrings only');
          
      END IF;
      
      num_vertices := MDSYS.SDO_UTIL.GETNUMVERTICES(p_input);
      
      IF num_vertices = 2
      THEN
         RETURN p_input;
         
      END IF;
      
      IF num_start_vertice IS NULL
      OR num_start_vertice = 0
      THEN
         num_start_vertice := 1;
         
      END IF;
      
      IF num_end_vertice IS NULL
      OR num_end_vertice = 0
      THEN
         num_end_vertice := num_vertices;
         
      END IF;
      
      IF num_start_vertice < 0
      THEN
          num_start_vertice := num_vertices + num_start_vertice + 1;
          
      END IF;
      
      IF num_end_vertice < 0
      THEN
         num_end_vertice := num_vertices + num_end_vertice + 1;
         
      END IF;
      
      IF num_start_vertice < 1
      OR num_start_vertice >= num_vertices
      THEN
         RAISE_APPLICATION_ERROR(-20001,'error in start vertice value');
         
      END IF;
      
      IF num_end_vertice < 2
      OR num_end_vertice > num_vertices
      THEN
         RAISE_APPLICATION_ERROR(-20001,'error in end vertice value');
         
      END IF;
      
      IF num_end_vertice - num_start_vertice < 1
      OR num_end_vertice - num_start_vertice > num_vertices
      THEN
         RAISE_APPLICATION_ERROR(
             -20001
            ,'error in vertice range: '|| num_start_vertice || ':' || num_end_vertice
         );
      
      END IF;
      
      int_num_dims   := p_input.get_dims();
      sdoords_output := MDSYS.SDO_ORDINATE_ARRAY();
      sdoords_output.EXTEND(((num_end_vertice - num_start_vertice) + 1) * int_num_dims);
      int_counter := 1;
      
      FOR i IN num_start_vertice .. num_end_vertice
      LOOP
         sdoords_output(int_counter) := p_input.SDO_ORDINATES((i * int_num_dims)-(int_num_dims - 1));
         int_counter := int_counter + 1;
         
         sdoords_output(int_counter) := p_input.SDO_ORDINATES((i * int_num_dims)-(int_num_dims - 2));
         int_counter := int_counter + 1;
         
         IF int_num_dims > 2
         THEN
            sdoords_output(int_counter) := p_input.SDO_ORDINATES((i * int_num_dims)-(int_num_dims - 3));
            int_counter := int_counter + 1;
         
         END IF;
         
         IF int_num_dims > 3
         THEN
            sdoords_output(int_counter) := p_input.SDO_ORDINATES((i * int_num_dims)-(int_num_dims - 4));
            int_counter := int_counter + 1;
         
         END IF;
      
      END LOOP;
      
      IF str_2d_flag = 'TRUE'
      THEN
         RETURN downsize_2d(
            p_input => MDSYS.SDO_GEOMETRY(
                p_input.SDO_GTYPE
               ,p_input.SDO_SRID
               ,NULL
               ,p_input.SDO_ELEM_INFO
               ,sdoords_output
            )
         );
         
      ELSE
         RETURN MDSYS.SDO_GEOMETRY(
             p_input.SDO_GTYPE
            ,p_input.SDO_SRID
            ,NULL
            ,p_input.SDO_ELEM_INFO
            ,sdoords_output
         );
      
      END IF;
      
   END clip_string_by_vertices;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION extract_vertice(
       p_input         IN  MDSYS.SDO_GEOMETRY
      ,p_vertice       IN  NUMBER DEFAULT 1
      ,p_2d_flag       IN  VARCHAR2 DEFAULT 'FALSE'
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      num_cnt_vertices  NUMBER;
      num_vertice       NUMBER := p_vertice;
      int_num_dims      PLS_INTEGER;
      num_x             NUMBER;
      num_y             NUMBER;
      num_3             NUMBER;
      num_4             NUMBER;
      str_2d_flag       VARCHAR2(4000 Char) := UPPER(p_2d_flag);
      
   BEGIN
   
      IF str_2d_flag IS NULL
      THEN
         str_2d_flag := 'FALSE';
      
      ELSIF str_2d_flag NOT IN ('TRUE','FALSE')
      THEN
         RAISE_APPLICATION_ERROR(-20001,'boolean error');
         
      END IF;
      
      IF p_input IS NULL
      THEN
         RETURN NULL;
         
      END IF;
      
      num_cnt_vertices := MDSYS.SDO_UTIL.GETNUMVERTICES(p_input);
      
      int_num_dims   := p_input.get_dims();
      
      IF num_vertice IS NULL
      OR num_vertice = 0
      THEN
         num_vertice := 1;
         
      END IF;
      
      IF num_vertice < 0
      THEN
         num_vertice := num_cnt_vertices + num_vertice + 1;
      
      END IF;
      
      IF num_vertice > num_cnt_vertices
      THEN
         RAISE_APPLICATION_ERROR(-20001,'vertice out of range');
         
      END IF;
      
      num_x := p_input.SDO_ORDINATES((num_vertice * int_num_dims)-(int_num_dims - 1));
      num_y := p_input.SDO_ORDINATES((num_vertice * int_num_dims)-(int_num_dims - 2));
         
      IF int_num_dims > 2
      THEN
         num_3 := p_input.SDO_ORDINATES((num_vertice * int_num_dims)-(int_num_dims - 3));
         
      END IF;
         
      IF int_num_dims > 3
      THEN
         num_4 := p_input.SDO_ORDINATES((num_vertice * int_num_dims)-(int_num_dims - 4));
         
      END IF;
      
      IF str_2d_flag = 'TRUE'
      THEN
         RETURN downsize_2d(
            fast_point(
                p_x    => num_x
               ,p_y    => num_y
               ,p_z    => num_3
               ,p_m    => num_4
               ,p_srid => p_input.SDO_SRID
            )
         );
      
      ELSE
         RETURN fast_point(
             p_x    => num_x
            ,p_y    => num_y
            ,p_z    => num_3
            ,p_m    => num_4
            ,p_srid => p_input.SDO_SRID
         );
         
      END IF;
                       
   END extract_vertice;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION first_ordinate(
       p_geom     IN  MDSYS.SDO_GEOMETRY
   ) RETURN NUMBER
   AS
   BEGIN
      IF p_geom IS NULL
      THEN
         RETURN 0;
         
      END IF;
      
      IF p_geom.SDO_POINT IS NOT NULL
      THEN
         RETURN p_geom.SDO_POINT.X;
         
      END IF;
      
      RETURN p_geom.SDO_ORDINATES(1);

   END first_ordinate;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION get_spatial_extent(
      p_input         IN  MDSYS.SDO_GEOMETRY,
      p_tolerance     IN  NUMBER   DEFAULT 0.05,
      p_meas_unit     IN  VARCHAR2 DEFAULT NULL
   ) RETURN NUMBER
   AS
      int_gtype      PLS_INTEGER;
      int_dims       PLS_INTEGER;
      str_def_length VARCHAR2(4000 Char) := 'UNIT=KM';
      str_def_area   VARCHAR2(4000 Char) := 'UNIT=SQ_KM';
      
   BEGIN
      int_gtype := p_input.get_gtype();
      int_dims  := p_input.get_dims();

      IF int_gtype IN (1,5)
      THEN
         RETURN MDSYS.SDO_UTIL.GETNUMELEM(p_input);
         
      ELSIF int_gtype IN (2,6)
      THEN
         IF p_meas_unit IS NULL
         THEN
            RETURN MDSYS.SDO_GEOM.SDO_LENGTH(
                p_input
               ,p_tolerance
               ,str_def_length
            );
            
         ELSE
            RETURN MDSYS.SDO_GEOM.SDO_LENGTH(
                p_input
               ,p_tolerance
               ,p_meas_unit
            );
            
         END IF;
         
      ELSIF int_gtype IN (3,7)
      THEN
         IF p_meas_unit IS NULL
         THEN
            RETURN MDSYS.SDO_GEOM.SDO_AREA(
                p_input
               ,p_tolerance
               ,str_def_area
            );
            
         ELSE
            RETURN MDSYS.SDO_GEOM.SDO_AREA(
                p_input
               ,p_tolerance
               ,p_meas_unit
            );
            
         END IF;
         
      ELSIF int_gtype = 4
      THEN
         RAISE_APPLICATION_ERROR(
             -20001
            ,'unable to evaluate geometries with gtype 4'
         );
         
      ELSE
         RAISE_APPLICATION_ERROR(-20001,'err');
         
      END IF;

   END get_spatial_extent;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION get_spatial_extent(
      p_input         IN  MDSYS.SDO_GEOMETRY,
      p_eval_geom     IN  MDSYS.SDO_GEOMETRY,
      p_tolerance     IN  NUMBER   DEFAULT 0.05,
      p_meas_unit     IN  VARCHAR2 DEFAULT NULL
   ) RETURN NUMBER
   AS
      int_gtype      PLS_INTEGER;
      int_dims       PLS_INTEGER;
      int_count      PLS_INTEGER;
      sdo_clip       MDSYS.SDO_GEOMETRY;
      str_def_length VARCHAR2(4000 Char) := 'UNIT=KM';
      str_def_area   VARCHAR2(4000 Char) := 'UNIT=SQ_KM';
      
   BEGIN

      int_gtype := p_input.get_gtype();
      int_dims  := p_input.get_dims();

      IF int_gtype IN (1,5)
      THEN
         int_count := 0;
         
         FOR i IN 1 .. MDSYS.SDO_UTIL.GETNUMELEM(p_input)
         LOOP
            IF MDSYS.SDO_GEOM.RELATE(
                MDSYS.SDO_UTIL.EXTRACT(p_input,i)
               ,'ANYINTERACT'
               ,p_eval_geom
               ,p_tolerance
            ) = 'TRUE'
            THEN
               int_count := int_count + 1;
               
            END IF;
            
         END LOOP;
         
         RETURN int_count;
         
      ELSIF int_gtype IN (2,6)
      THEN
         sdo_clip := scrub_lines(
            p_input => MDSYS.SDO_GEOM.SDO_INTERSECTION(
               p_input,
               p_eval_geom,
               p_tolerance
            )
         );
         
         IF sdo_clip IS NULL
         THEN
            RETURN 0;
            
         END IF;
         
         IF p_meas_unit IS NULL
         THEN
            RETURN MDSYS.SDO_GEOM.SDO_LENGTH(
                sdo_clip
               ,p_tolerance
               ,str_def_length
            );
            
         ELSE
            RETURN MDSYS.SDO_GEOM.SDO_LENGTH(
                sdo_clip
               ,p_tolerance
               ,p_meas_unit
            );
            
         END IF;
         
      ELSIF int_gtype IN (3,7)
      THEN
         sdo_clip := scrub_polygons(
            p_input => MDSYS.SDO_GEOM.SDO_INTERSECTION(
                p_input
               ,p_eval_geom
               ,p_tolerance
            )
         );
         
         IF sdo_clip IS NULL
         THEN
            RETURN 0;
            
         END IF;
         
         IF p_meas_unit IS NULL
         THEN
            RETURN MDSYS.SDO_GEOM.SDO_AREA(
                sdo_clip
               ,p_tolerance
               ,str_def_area
            );
            
         ELSE
            RETURN MDSYS.SDO_GEOM.SDO_AREA(
                sdo_clip
               ,p_tolerance
               ,p_meas_unit
            );
            
         END IF;
         
      ELSIF int_gtype = 4
      THEN
         RAISE_APPLICATION_ERROR(
             -20001
            ,'unable to evaluate geometries with gtype 4'
         );
         
      ELSE
         RAISE_APPLICATION_ERROR(-20001,'err');
      
      END IF;

   END get_spatial_extent;
   
END dz_sdo_util;
/

