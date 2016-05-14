
--*************************--
PROMPT sqlplus_header.sql;

WHENEVER SQLERROR EXIT -99;
WHENEVER OSERROR  EXIT -98;
SET DEFINE OFF;



--*************************--
PROMPT DZ_SDO_LABELED.tps;

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


--*************************--
PROMPT DZ_SDO_LABELED.tpb;

CREATE OR REPLACE TYPE BODY dz_sdo_labeled
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   CONSTRUCTOR FUNCTION dz_sdo_labeled
   RETURN SELF AS RESULT
   AS
   BEGIN
      RETURN;
      
   END dz_sdo_labeled;
 
END;
/


--*************************--
PROMPT DZ_SDO_LABELED_LIST.tps;

CREATE OR REPLACE TYPE dz_sdo_labeled_list FORCE                 
AS 
TABLE OF dz_sdo_labeled;
/

GRANT EXECUTE ON dz_sdo_labeled_list TO public;


--*************************--
PROMPT DZ_SDO_UTIL.pks;

CREATE OR REPLACE PACKAGE dz_sdo_util
AUTHID CURRENT_USER
AS
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION gz_split(
       p_str              IN VARCHAR2
      ,p_regex            IN VARCHAR2
      ,p_match            IN VARCHAR2 DEFAULT NULL
      ,p_end              IN NUMBER   DEFAULT 0
      ,p_trim             IN VARCHAR2 DEFAULT 'FALSE'
   ) RETURN MDSYS.SDO_STRING2_ARRAY DETERMINISTIC;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION count_points(
      p_input   IN MDSYS.SDO_GEOMETRY
   ) RETURN NUMBER;
   
   ----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION true_point(
      p_input      IN MDSYS.SDO_GEOMETRY
   ) RETURN MDSYS.SDO_GEOMETRY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION fast_point(
       p_x             IN  NUMBER
      ,p_y             IN  NUMBER
      ,p_z             IN  NUMBER DEFAULT NULL
      ,p_m             IN  NUMBER DEFAULT NULL
      ,p_srid          IN  NUMBER DEFAULT 8265
   ) RETURN MDSYS.SDO_GEOMETRY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION is_compound(
      p_input   IN MDSYS.SDO_GEOMETRY
   ) RETURN VARCHAR2;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION get_start_point(
      p_input        IN  MDSYS.SDO_GEOMETRY
   ) RETURN MDSYS.SDO_GEOMETRY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION get_end_point(
      p_input      IN  MDSYS.SDO_GEOMETRY
   ) RETURN MDSYS.SDO_GEOMETRY;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION downsize_2d(
      p_input      IN MDSYS.SDO_GEOMETRY
   ) RETURN MDSYS.SDO_GEOMETRY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION downsize_2dM(
      p_input         IN  MDSYS.SDO_GEOMETRY
   ) RETURN MDSYS.SDO_GEOMETRY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION downsize_3d(
      p_input      IN MDSYS.SDO_GEOMETRY
   ) RETURN MDSYS.SDO_GEOMETRY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION indent(
      p_level      IN NUMBER,
      p_amount     IN VARCHAR2 DEFAULT '   '
   ) RETURN VARCHAR2;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION pretty(
      p_input      IN CLOB,
      p_level      IN NUMBER,
      p_amount     IN VARCHAR2 DEFAULT '   ',
      p_linefeed   IN VARCHAR2 DEFAULT CHR(10)
   ) RETURN CLOB;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION validate_unit(
      p_input              IN  VARCHAR2
   ) RETURN VARCHAR2;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE verify_ordinate_rotation(
       p_rotation    IN            VARCHAR2
      ,p_input       IN OUT NOCOPY MDSYS.SDO_GEOMETRY
      ,p_lower_bound IN            PLS_INTEGER DEFAULT 1
      ,p_upper_bound IN            PLS_INTEGER DEFAULT NULL
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE test_ordinate_rotation(
       p_input       IN  MDSYS.SDO_GEOMETRY
      ,p_lower_bound IN  NUMBER DEFAULT 1
      ,p_upper_bound IN  NUMBER DEFAULT NULL
      ,p_results     OUT VARCHAR2
      ,p_area        OUT NUMBER
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION test_ordinate_rotation(
       p_input       IN  MDSYS.SDO_GEOMETRY
      ,p_lower_bound IN  NUMBER DEFAULT 1
      ,p_upper_bound IN  NUMBER DEFAULT NULL
   ) RETURN VARCHAR2;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION test_ordinate_rotation(
       p_input       IN MDSYS.SDO_ORDINATE_ARRAY
      ,p_lower_bound IN NUMBER DEFAULT 1
      ,p_upper_bound IN NUMBER DEFAULT NULL
      ,p_num_dims    IN NUMBER DEFAULT 2
   ) RETURN VARCHAR2;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE reverse_ordinate_rotation(
       p_input       IN OUT NOCOPY MDSYS.SDO_GEOMETRY
      ,p_lower_bound IN            PLS_INTEGER DEFAULT 1
      ,p_upper_bound IN            PLS_INTEGER DEFAULT NULL
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE reverse_ordinate_rotation(
       p_input       IN OUT NOCOPY MDSYS.SDO_ORDINATE_ARRAY
      ,p_lower_bound IN            PLS_INTEGER DEFAULT 1
      ,p_upper_bound IN            PLS_INTEGER DEFAULT NULL
      ,p_num_dims    IN            PLS_INTEGER DEFAULT 2
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION reverse_ordinate_rotation(
       p_input       IN  MDSYS.SDO_ORDINATE_ARRAY
      ,p_lower_bound IN  NUMBER DEFAULT 1
      ,p_upper_bound IN  NUMBER DEFAULT NULL
      ,p_num_dims    IN  NUMBER DEFAULT 2
   ) RETURN MDSYS.SDO_ORDINATE_ARRAY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE append2(
       p_input             IN OUT MDSYS.SDO_GEOMETRY_ARRAY
      ,p_value             IN     MDSYS.SDO_GEOMETRY
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE append2(
       p_input             IN OUT MDSYS.SDO_GEOMETRY_ARRAY
      ,p_value             IN     MDSYS.SDO_GEOMETRY_ARRAY
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE append2(
       p_input             IN OUT MDSYS.SDO_ORDINATE_ARRAY
      ,p_value             IN     NUMBER
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE append2(
       p_input             IN OUT MDSYS.SDO_ORDINATE_ARRAY
      ,p_value             IN     MDSYS.SDO_ORDINATE_ARRAY
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE append2(
       p_input_array       IN OUT MDSYS.SDO_NUMBER_ARRAY
      ,p_input_value       IN     NUMBER
      ,p_unique            IN     VARCHAR2 DEFAULT 'FALSE'
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE append2(
       p_input_array       IN OUT MDSYS.SDO_NUMBER_ARRAY
      ,p_input_value       IN     MDSYS.SDO_NUMBER_ARRAY
      ,p_unique            IN     VARCHAR2 DEFAULT 'FALSE'
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION sdo2varray(
      p_input              IN  MDSYS.SDO_GEOMETRY
   ) RETURN MDSYS.SDO_GEOMETRY_ARRAY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION varray2sdo(
       p_input              IN  MDSYS.SDO_GEOMETRY_ARRAY
      ,p_union_flag         IN  VARCHAR2 DEFAULT 'FALSE'
      ,p_tolerance          IN  NUMBER DEFAULT 0.05
   ) RETURN MDSYS.SDO_GEOMETRY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION getnumrings(
      p_input              IN  MDSYS.SDO_GEOMETRY
   ) RETURN NUMBER;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION scrub_lines(
      p_input              IN MDSYS.SDO_GEOMETRY
   ) RETURN MDSYS.SDO_GEOMETRY;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION scrub_polygons(
      p_input              IN MDSYS.SDO_GEOMETRY
   ) RETURN MDSYS.SDO_GEOMETRY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION is_spaghetti(
       p_input             IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance         IN  NUMBER DEFAULT 0.05
   ) RETURN VARCHAR2;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION is_polygon(
       p_input         IN MDSYS.SDO_GEOMETRY
      ,p_tolerance     IN NUMBER DEFAULT 0.05
   ) RETURN VARCHAR2;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION centroid(
       p_input              IN  MDSYS.SDO_GEOMETRY
      ,p_modifier           IN  VARCHAR2 DEFAULT NULL
      ,p_tolerance          IN  NUMBER DEFAULT 0.05
   ) RETURN MDSYS.SDO_GEOMETRY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE point2coordinates(
      p_input   IN  MDSYS.SDO_GEOMETRY,
      p_x       OUT NUMBER,
      p_y       OUT NUMBER,
      p_z       OUT NUMBER,
      p_m       OUT NUMBER
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION update_end_point(
       p_input        IN  MDSYS.SDO_GEOMETRY
      ,p_end_point    IN  MDSYS.SDO_GEOMETRY
   ) RETURN MDSYS.SDO_GEOMETRY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION append_end_point(
       p_input        IN  MDSYS.SDO_GEOMETRY
      ,p_end_point    IN  MDSYS.SDO_GEOMETRY
   ) RETURN MDSYS.SDO_GEOMETRY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION get_gtype(
      p_input         IN  MDSYS.SDO_GEOMETRY
   ) RETURN NUMBER;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION dz_distance(
       p_input_1       IN  MDSYS.SDO_GEOMETRY
      ,p_input_2       IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance     IN  NUMBER DEFAULT 0.05
      ,p_unit          IN  VARCHAR2 DEFAULT NULL
   ) RETURN NUMBER;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION dz_length(
       p_input         IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance     IN  NUMBER DEFAULT 0.05
      ,p_unit          IN  VARCHAR2 DEFAULT NULL
   ) RETURN NUMBER;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION is_closed_loop(
       p_input         IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance     IN  NUMBER DEFAULT 0.05
      ,p_threshold     IN  NUMBER DEFAULT 0
      ,p_unit          IN  VARCHAR2 DEFAULT NULL
   ) RETURN VARCHAR2; 
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION clip_string_by_vertices(
       p_input         IN  MDSYS.SDO_GEOMETRY
      ,p_start_vertice IN  NUMBER DEFAULT 1
      ,p_end_vertice   IN  NUMBER DEFAULT NULL
      ,p_2d_flag       IN  VARCHAR2 DEFAULT 'FALSE'
   ) RETURN MDSYS.SDO_GEOMETRY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION extract_vertice(
       p_input         IN  MDSYS.SDO_GEOMETRY
      ,p_vertice       IN  NUMBER DEFAULT 1
      ,p_2d_flag       IN  VARCHAR2 DEFAULT 'FALSE'
   ) RETURN MDSYS.SDO_GEOMETRY;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION first_ordinate(
       p_geom     IN  MDSYS.SDO_GEOMETRY
   ) RETURN NUMBER;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION get_spatial_extent(
      p_input         IN  MDSYS.SDO_GEOMETRY,
      p_tolerance     IN  NUMBER   DEFAULT 0.05,
      p_meas_unit     IN  VARCHAR2 DEFAULT NULL
   ) RETURN NUMBER;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION get_spatial_extent(
      p_input         IN  MDSYS.SDO_GEOMETRY,
      p_eval_geom     IN  MDSYS.SDO_GEOMETRY,
      p_tolerance     IN  NUMBER   DEFAULT 0.05,
      p_meas_unit     IN  VARCHAR2 DEFAULT NULL
   ) RETURN NUMBER;
   
END dz_sdo_util;
/

GRANT EXECUTE ON dz_sdo_util TO PUBLIC;


--*************************--
PROMPT DZ_SDO_UTIL.pkb;

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


--*************************--
PROMPT DZ_SDO_DISSECT.pks;

CREATE OR REPLACE PACKAGE dz_sdo_dissect 
AUTHID CURRENT_USER
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION multistring_gap(
       p_input          IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance      IN  NUMBER DEFAULT 0.05
      ,p_unit           IN  VARCHAR2 DEFAULT 'KM'
   ) RETURN NUMBER;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE break_string_at_point(
       p_input          IN  MDSYS.SDO_GEOMETRY
      ,p_break_vertices IN  NUMBER DEFAULT NULL
      ,p_first          OUT MDSYS.SDO_GEOMETRY
      ,p_second         OUT MDSYS.SDO_GEOMETRY
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE break_string_at_point(
       p_input          IN  MDSYS.SDO_GEOMETRY
      ,p_break_point    IN  MDSYS.SDO_GEOMETRY
      ,p_first          OUT MDSYS.SDO_GEOMETRY
      ,p_second         OUT MDSYS.SDO_GEOMETRY
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE deconstruct_multipoint(
       p_input          IN  MDSYS.SDO_GEOMETRY
      ,p_nodes          OUT MDSYS.SDO_GEOMETRY_ARRAY
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE deconstruct_string(
       p_input          IN  MDSYS.SDO_GEOMETRY
      ,p_nodes          OUT MDSYS.SDO_GEOMETRY_ARRAY
      ,p_edges          OUT MDSYS.SDO_GEOMETRY_ARRAY
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE deconstruct_multistring(
       p_input          IN  MDSYS.SDO_GEOMETRY
      ,p_nodes          OUT MDSYS.SDO_GEOMETRY_ARRAY
      ,p_edges          OUT MDSYS.SDO_GEOMETRY_ARRAY
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE deconstruct_collection(
       p_input          IN  MDSYS.SDO_GEOMETRY
      ,p_nodes          OUT MDSYS.SDO_GEOMETRY_ARRAY
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE deconstruct(
       p_input          IN  MDSYS.SDO_GEOMETRY
      ,p_nodes          OUT MDSYS.SDO_GEOMETRY_ARRAY
      ,p_edges          OUT MDSYS.SDO_GEOMETRY_ARRAY
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION deconstruct(
      p_input           IN  MDSYS.SDO_GEOMETRY
   ) RETURN MDSYS.SDO_GEOMETRY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION points2segment(
       p_point_one      IN  MDSYS.SDO_POINT_TYPE
      ,p_point_two      IN  MDSYS.SDO_POINT_TYPE
      ,p_srid           IN  NUMBER
   ) RETURN MDSYS.SDO_GEOMETRY;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION points2segment(
       p_point_one      IN  MDSYS.SDO_GEOMETRY
      ,p_point_two      IN  MDSYS.SDO_GEOMETRY
   ) RETURN MDSYS.SDO_GEOMETRY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION linear_gap_filler(
       p_input          IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance      IN  NUMBER DEFAULT 0.05
   ) RETURN MDSYS.SDO_GEOMETRY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE crack_multistring(
       p_input          IN  MDSYS.SDO_GEOMETRY
      ,p_linestrings    OUT MDSYS.SDO_GEOMETRY_ARRAY
      ,p_start_points   OUT MDSYS.SDO_GEOMETRY_ARRAY
      ,p_end_points     OUT MDSYS.SDO_GEOMETRY_ARRAY
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION feature_to_line(
       p_input          IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance      IN  NUMBER DEFAULT 0.05
   ) RETURN MDSYS.SDO_GEOMETRY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION point_at_vertice(
       p_input          IN  MDSYS.SDO_GEOMETRY
      ,p_vertice        IN  NUMBER
      ,p_2d_flag        IN  VARCHAR2 DEFAULT 'TRUE'
   ) RETURN MDSYS.SDO_GEOMETRY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION has_holes(
      p_input             IN  MDSYS.SDO_GEOMETRY
   ) RETURN VARCHAR2;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION remove_holes(
      p_input             IN  MDSYS.SDO_GEOMETRY
   ) RETURN MDSYS.SDO_GEOMETRY;
   
END dz_sdo_dissect;
/

GRANT EXECUTE ON dz_sdo_dissect TO public;


--*************************--
PROMPT DZ_SDO_DISSECT.pkb;

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


--*************************--
PROMPT DZ_SDO_MAIN.pks;

CREATE OR REPLACE PACKAGE dz_sdo_main
AUTHID CURRENT_USER
AS
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   /*
   header: DZ_SDO
     
   - Build ID: 3
   - TFS Change Set: 8194
   
   Utilities for the creation and manipulation of Oracle Spatial geometries.
   
   */
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION order_rings(
       p_input        IN  MDSYS.SDO_GEOMETRY
      ,p_direction    IN  VARCHAR2 DEFAULT 'ASC'
   ) RETURN MDSYS.SDO_GEOMETRY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION get_MBS(
      p_input         IN  MDSYS.SDO_GEOMETRY
   ) RETURN MDSYS.SDO_GEOMETRY;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION get_quad(
       p_input        IN  MDSYS.SDO_GEOMETRY
      ,p_grid_number  IN  NUMBER
   ) RETURN MDSYS.SDO_GEOMETRY;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION ez_quads(
       p_input        IN  MDSYS.SDO_GEOMETRY
      ,p_grid         IN  VARCHAR2
      ,p_tolerance    IN  NUMBER DEFAULT 0.05
   ) RETURN MDSYS.SDO_GEOMETRY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION search_ordinates(
       p_input      IN  MDSYS.SDO_GEOMETRY
      ,p_value      IN  NUMBER
      ,p_position   IN  VARCHAR2 DEFAULT 'ALL'
      ,p_comparator IN  VARCHAR2 DEFAULT '='
   ) RETURN VARCHAR2;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION within_envelope(
       p_input      IN  MDSYS.SDO_GEOMETRY
      ,p_min_x      IN  NUMBER DEFAULT -180
      ,p_max_x      IN  NUMBER DEFAULT 180
      ,p_min_y      IN  NUMBER DEFAULT -90
      ,p_max_y      IN  NUMBER DEFAULT 90
   ) RETURN VARCHAR2;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION move_polygon_to_back(
       p_input      IN  MDSYS.SDO_GEOMETRY
      ,p_number     IN  NUMBER DEFAULT 1
   ) RETURN MDSYS.SDO_GEOMETRY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION find_duplicate_points(
       p_input      IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance  IN  NUMBER DEFAULT 0.05
   ) RETURN MDSYS.SDO_GEOMETRY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION get_shortest_connecting_line(
       p_object_1    IN  MDSYS.SDO_GEOMETRY
      ,p_object_2    IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance   IN  NUMBER
      ,p_output_flag IN  VARCHAR2 DEFAULT 'LINE'
   ) RETURN MDSYS.SDO_GEOMETRY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE nearest_by_distance(
       p_input     IN  MDSYS.SDO_GEOMETRY
      ,p_sdo_array IN  MDSYS.SDO_GEOMETRY_ARRAY
      ,p_tolerance IN  NUMBER
      ,p_unit      IN  VARCHAR2 DEFAULT NULL
      ,p_output    OUT MDSYS.SDO_GEOMETRY
      ,p_distance  OUT NUMBER
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION string_midpoint(
       p_input               IN  MDSYS.SDO_GEOMETRY
      ,p_debuginfo           IN  VARCHAR2 DEFAULT NULL
   ) RETURN MDSYS.SDO_GEOMETRY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION self_union(
       p_input         IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance     IN  NUMBER DEFAULT 0.05
      ,p_project_srid  IN  NUMBER DEFAULT NULL
   ) RETURN MDSYS.SDO_GEOMETRY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION self_union_force(
       p_input               IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance           IN  NUMBER DEFAULT 0.05
      ,p_project_srid        IN  NUMBER DEFAULT NULL
      ,p_tolerance_increment IN  NUMBER DEFAULT 0.02
      ,p_maximum_increment   IN  NUMBER DEFAULT 25
   ) RETURN MDSYS.SDO_GEOMETRY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION remove_dup_vertices(
       p_input               IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance           IN  NUMBER DEFAULT 0.05
      ,p_project_srid        IN  NUMBER DEFAULT NULL
   ) RETURN MDSYS.SDO_GEOMETRY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION remove_dup_vertices_force(
       p_input               IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance           IN  NUMBER DEFAULT 0.05
      ,p_project_srid        IN  NUMBER DEFAULT NULL
      ,p_tolerance_increment IN  NUMBER DEFAULT 0.02
      ,p_maximum_increment   IN  NUMBER DEFAULT 25
   ) RETURN MDSYS.SDO_GEOMETRY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE polygon_edge_from_interior(
       p_input_point   IN  MDSYS.SDO_GEOMETRY
      ,p_outer_polygon IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance     IN  NUMBER DEFAULT 0.05
      ,p_unit          IN  VARCHAR2 DEFAULT 'KM'
      ,p_edge_point    OUT MDSYS.SDO_GEOMETRY
      ,p_edge_distance OUT NUMBER
   );
   
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
   );
   
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
   ) RETURN MDSYS.SDO_GEOMETRY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION polygon_merge_cutter(
       p_base          IN  MDSYS.SDO_GEOMETRY
      ,p_cutter        IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance     IN  NUMBER DEFAULT 0.05
      ,p_srid          IN  NUMBER DEFAULT NULL
      ,p_careful       IN  VARCHAR2 DEFAULT 'FALSE'
   ) RETURN MDSYS.SDO_GEOMETRY;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE polygon_merge_cutter(
       p_base          IN OUT MDSYS.SDO_GEOMETRY
      ,p_cutter        IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance     IN  NUMBER DEFAULT 0.05
      ,p_srid          IN  NUMBER DEFAULT NULL
      ,p_careful       IN  VARCHAR2 DEFAULT 'FALSE'
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION filter_linestrings(
       p_input            IN  MDSYS.SDO_GEOMETRY
      ,p_filter_threshold IN  NUMBER
      ,p_units            IN  VARCHAR2 DEFAULT NULL
      ,p_tolerance        IN  NUMBER DEFAULT 0.05
   ) RETURN MDSYS.SDO_GEOMETRY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE reasonable_endpoints(
       p_input            IN  MDSYS.SDO_GEOMETRY
      ,p_start_point      OUT MDSYS.SDO_GEOMETRY
      ,p_end_point        OUT MDSYS.SDO_GEOMETRY
      ,p_tuning           IN  NUMBER DEFAULT 1
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION reorient_ordinate_array_ring(
       p_input            IN  MDSYS.SDO_ORDINATE_ARRAY
      ,p_vertice          IN  NUMBER
      ,p_num_dims         IN  NUMBER DEFAULT 2
      ,p_force_direction  IN  VARCHAR2 DEFAULT NULL
   ) RETURN MDSYS.SDO_ORDINATE_ARRAY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION reorient_geometry_ring(
       p_input            IN  MDSYS.SDO_GEOMETRY
      ,p_vertice          IN  NUMBER
      ,p_force_direction  IN  VARCHAR2 DEFAULT NULL
   ) RETURN MDSYS.SDO_GEOMETRY;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION reorient_geometry_ring(
       p_input            IN  MDSYS.SDO_GEOMETRY
      ,p_vertice          IN  MDSYS.SDO_GEOMETRY
      ,p_force_direction  IN  VARCHAR2 DEFAULT NULL
   ) RETURN MDSYS.SDO_GEOMETRY;
   
END dz_sdo_main;
/

GRANT EXECUTE ON dz_sdo_main TO public;


--*************************--
PROMPT DZ_SDO_MAIN.pkb;

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
      sdo_input     MDSYS.SDO_GEOMETRY := p_input;
      sdo_output    MDSYS.SDO_GEOMETRY;
      num_tolerance NUMBER := p_tolerance; 
      str_validate  VARCHAR2(4000 Char);
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF num_tolerance IS NULL
      THEN
         num_tolerance := 0.05;
         
      END IF;
      
      IF sdo_input.get_gtype() NOT IN (2,6)
      THEN
         RAISE_APPLICATION_ERROR(-20001,'input must be linestring');
         
      END IF;
      
      IF sdo_input IS NULL
      THEN
         RETURN NULL;
         
      ELSE
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
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
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
      -- Step 30
      -- Execute the union
      --------------------------------------------------------------------------
      sdo_output := dz_sdo_util.scrub_lines(
         MDSYS.SDO_UTIL.REMOVE_DUPLICATE_VERTICES(
            sdo_input,
            num_tolerance
         )
      );
      
      --------------------------------------------------------------------------
      -- Step 40
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
      -- Step 50
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
      sdo_input     MDSYS.SDO_GEOMETRY := p_input;
      sdo_output    MDSYS.SDO_GEOMETRY;
      num_tolerance NUMBER := p_tolerance; 
      str_validate  VARCHAR2(4000 Char);
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
      -- Loop around trying to force the union
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


--*************************--
PROMPT DZ_SDO_GEODETIC.pks;

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


--*************************--
PROMPT DZ_SDO_GEODETIC.pkb;

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


--*************************--
PROMPT DZ_SDO_ACCURACY.pks;

CREATE OR REPLACE PACKAGE dz_sdo_accuracy
AUTHID CURRENT_USER
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION hausdorff_distance(
       p_input_1           IN  MDSYS.SDO_GEOMETRY
      ,p_input_2           IN  MDSYS.SDO_GEOMETRY
   ) RETURN NUMBER;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE hausdorff_distance(
       p_input_1           IN  MDSYS.SDO_GEOMETRY
      ,p_input_2           IN  MDSYS.SDO_GEOMETRY
      ,p_conflation_dist_1 OUT NUMBER
      ,p_conflation_dist_2 OUT NUMBER
      ,p_tolerance         IN  NUMBER DEFAULT 0.05
   );
   
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
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION coefficient_arial_corresp(
       p_input_1       IN  MDSYS.SDO_GEOMETRY
      ,p_input_2       IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance     IN  NUMBER DEFAULT 0.05
      ,p_srid          IN  NUMBER DEFAULT NULL
   ) RETURN NUMBER;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION buffer_overlay_statistics(
       p_input_1    IN  MDSYS.SDO_GEOMETRY
      ,p_input_2    IN  MDSYS.SDO_GEOMETRY
      ,p_buffer_amt IN  NUMBER
      ,p_tolerance  IN  NUMBER DEFAULT 0.05
      ,p_params     IN  VARCHAR2 DEFAULT NULL
   ) RETURN NUMBER;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION linear_direction_relate(
       p_parent        IN  MDSYS.SDO_GEOMETRY
      ,p_child         IN  MDSYS.SDO_GEOMETRY
      ,p_tolerance     IN  NUMBER DEFAULT 0.05
      ,p_determine     IN  VARCHAR2 DEFAULT NULL
   ) RETURN VARCHAR2;

END dz_sdo_accuracy;
/

GRANT EXECUTE ON dz_sdo_accuracy TO public;


--*************************--
PROMPT DZ_SDO_ACCURACY.pkb;

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


--*************************--
PROMPT DZ_SDO_CLUSTER.pks;

CREATE OR REPLACE PACKAGE dz_sdo_cluster
AUTHID CURRENT_USER
AS
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   /*
   Function: update_metadata_envelope

   Procedure to update user_sdo_geom_metadata table with extents of the current
   set of geometry.

   Parameters:

      p_table_name - the table to examine
      p_column_name - the spatial column in the table to examine

   Returns:

      NA
      
   Notes:
   
   -  To avoid tracking dimension name, SRIDs and dimensions beyond X and Y 
      this procedure requires the metadata record to already exist.
      
   -  Any M or Z dimensions are ignored and will remain as is.

   */
   PROCEDURE update_metadata_envelope(
       p_table_name       IN  VARCHAR2
      ,p_column_name      IN  VARCHAR2 DEFAULT 'SHAPE'
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   /*
   Function: morton

   Morton Key generator function by Simon Greener   
   http://www.spatialdbadvisor.com/oracle_spatial_tips_tricks/138/spatial-sorting-of-data-via-morton-key

   Parameters:

      p_column - the morton grid column number
      p_row - the morton grid row number

   Returns:

      INTEGER

   */
   FUNCTION morton(
       p_column           IN  NATURAL
      ,p_row              IN  NATURAL
   ) RETURN INTEGER DETERMINISTIC;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   /*
   Function: morton_key

   Wrapper function to handle the conversion of geometry types into points 
   before generating the morton key.

   Parameters:

      p_input - input geometry to generate a morton key for.
      p_x_offset - the offset to move x coordinates to be zero-based
      p_y_offset - the offset to move y coordinates to be zero-based
      p_x_divisor - the grid divisor for the x axis
      p_y_divisor - the grid divisor for the y axis
      p_geom_devolve - either ACCURATE or FAST to control how points are generated.
      p_tolerance - tolerance value to use when generating centroids and such.
      
   Returns:

      INTEGER
      
   Notes:
   
   -  for p_geom_devolve with polygon input, ACCURATE uses SDO_CENTROID while
      FAST uses SDO_POINTONSURFACE.
      
   -  for p_geom_devolve with linear or multipoint input, ACCURATE uses the 
      SDO_CENTROID of the geometry MBR while FAST uses the first point in the 
      geometry.

   */
   FUNCTION morton_key(
       p_input            IN  MDSYS.SDO_GEOMETRY
      ,p_x_offset         IN  NUMBER
      ,p_y_offset         IN  NUMBER
      ,p_x_divisor        IN  NUMBER
      ,p_y_divisor        IN  NUMBER
      ,p_geom_devolve     IN  VARCHAR2 DEFAULT 'ACCURATE'
      ,p_tolerance        IN  NUMBER DEFAULT 0.05
   ) RETURN INTEGER DETERMINISTIC;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   /*
   Function: morton_update

   Function to generate the morton key update clause.

   Parameters:

      p_owner - the owner of the table to examine
      p_table_name - the table to examine
      p_column_name - the spatial column in the table to examine
      p_use_metadata_env - TRUE/FALSE whether to obtain envelope from metadata
      p_grid_size - the desired morton grid size

   Returns:

      VARCHAR2
      
   Notes:
   
   -  p_use_metadata_env value of TRUE will obtains envelope size from metadata.
      FALSE will calculate the values from the table via SDO_AGGR_MBR (and may 
      take a long time).
      
   -  Probably the most important value here is the grid size.  You should use
      a reasonable grid size.

   */
   FUNCTION morton_update(
       p_owner            IN  VARCHAR2 DEFAULT NULL
      ,p_table_name       IN  VARCHAR2
      ,p_column_name      IN  VARCHAR2 DEFAULT 'SHAPE'
      ,p_use_metadata_env IN  VARCHAR2 DEFAULT 'FALSE'
      ,p_grid_size        IN  NUMBER
   ) RETURN VARCHAR2;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   /*
   Function: morton_visualize

   Function to visualize the results of a morton key spatial clustering.  
   Intended for use with mapviewer or other sdo_geometry viewers that can directly
   display the result of a query.

   Parameters:

      p_owner - the owner of the table to examine
      p_table_name - the table to examine
      p_column_name - the spatial column in the table to examine
      p_key_field - the field name used to obtain the start record
      p_key_start - the field value used to obtain the start record
      p_morton_key_range - the range of morton values to fetch results for
      p_morton_key_field - the name of the field holding the morton key
      
   Returns:

      MDSYS.SDO_GEOMETRY
      
   Notes:
   
   -  Use a modest morton key range to avoid an overly large return geometry.
   
   -  You may wish to index the morton key field for performance when running 
      this function.

   */
   FUNCTION morton_visualize(
       p_owner            IN  VARCHAR2 DEFAULT NULL
      ,p_table_name       IN  VARCHAR2
      ,p_column_name      IN  VARCHAR2 DEFAULT 'SHAPE'
      ,p_key_field        IN  VARCHAR2 DEFAULT 'OBJECTID'
      ,p_key_start        IN  VARCHAR2
      ,p_morton_key_range IN  NUMBER
      ,p_morton_key_field IN  VARCHAR2 DEFAULT 'MORTON_KEY'
   ) RETURN MDSYS.SDO_GEOMETRY;
   
END dz_sdo_cluster;
/

GRANT EXECUTE ON dz_sdo_cluster TO public;


--*************************--
PROMPT DZ_SDO_CLUSTER.pkb;

CREATE OR REPLACE PACKAGE BODY dz_sdo_cluster 
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION devolve_point(
       p_input            IN  MDSYS.SDO_GEOMETRY
      ,p_geom_devolve     IN  VARCHAR2 DEFAULT 'ACCURATE'
      ,p_tolerance        IN  NUMBER DEFAULT 0.05
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      sdo_output MDSYS.SDO_GEOMETRY;
      
   BEGIN
   
      IF p_input.get_gtype() IN (3,7)
      AND p_geom_devolve = 'ACCURATE'
      THEN
         sdo_output := MDSYS.SDO_GEOM.SDO_CENTROID(
             p_input
            ,p_tolerance
         );
         
      ELSIF p_input.get_gtype() IN (3,7)
      AND p_geom_devolve = 'FAST'
      THEN
         sdo_output := MDSYS.SDO_GEOM.SDO_POINTONSURFACE(
             p_input
            ,p_tolerance
         );
         
      ELSIF p_input.get_gtype() IN (2,4,5,6)
      AND p_geom_devolve = 'ACCURATE'
      THEN
         sdo_output := MDSYS.SDO_GEOM.SDO_CENTROID(
             MDSYS.SDO_GEOM.SDO_MBR(p_input)
            ,p_tolerance
         );
         
         IF sdo_output IS NULL
         THEN
             sdo_output := MDSYS.SDO_GEOMETRY(
                2001
               ,p_input.SDO_SRID
               ,MDSYS.SDO_POINT_TYPE(
                    p_input.SDO_ORDINATES(1)
                   ,p_input.SDO_ORDINATES(2)
                   ,NULL
                )
               ,NULL
               ,NULL
            );
            
         END IF;
      
      ELSIF p_input.get_gtype() IN (2,4,5,6)
      AND p_geom_devolve = 'FAST'
      THEN
         sdo_output := MDSYS.SDO_GEOMETRY(
             2001
            ,p_input.SDO_SRID
            ,MDSYS.SDO_POINT_TYPE(
                 p_input.SDO_ORDINATES(1)
                ,p_input.SDO_ORDINATES(2)
                ,NULL
             )
            ,NULL
            ,NULL
         );
         
      ELSIF p_input.get_gtype() = 1
      THEN
         IF p_input.SDO_POINT IS NULL
         THEN
            sdo_output := MDSYS.SDO_GEOMETRY(
                2001
               ,p_input.SDO_SRID
               ,MDSYS.SDO_POINT_TYPE(
                    p_input.SDO_ORDINATES(1)
                   ,p_input.SDO_ORDINATES(2)
                   ,NULL
                )
               ,NULL
               ,NULL
            );
         
         ELSE
            sdo_output := p_input;
            
         END IF;
      
      ELSE
         RAISE_APPLICATION_ERROR(-20001,'err');
         
      END IF;
      
      RETURN sdo_output;
   
   END devolve_point;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   PROCEDURE update_metadata_envelope(
       p_table_name       IN  VARCHAR2
      ,p_column_name      IN  VARCHAR2 DEFAULT 'SHAPE'
   )
   AS
      str_column_name VARCHAR2(30 Char) := p_column_name;
      str_sql         VARCHAR2(4000 Char);
      num_check       NUMBER;
      sdo_envelope    MDSYS.SDO_GEOMETRY;
      obj_diminfo     MDSYS.SDO_DIM_ARRAY;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF str_column_name IS NULL
      THEN
         str_column_name := 'SHAPE';
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Check that table and column exists
      --------------------------------------------------------------------------
      SELECT
      COUNT(*)
      INTO num_check
      FROM
      user_tables a
      JOIN
      user_tab_cols b
      ON
      a.table_name = b.table_name
      WHERE
          a.table_name = p_table_name
      AND b.column_name = str_column_name;
      
      IF num_check <> 1
      THEN
         RAISE_APPLICATION_ERROR(-20001,'cannot find user table with column name');
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Check that metadata already exists
      --------------------------------------------------------------------------
      SELECT
      COUNT(*) 
      INTO num_check
      FROM
      user_sdo_geom_metadata a
      WHERE
          a.table_name = p_table_name
      AND a.column_name = str_column_name;
      
      IF num_check <> 1
      THEN
         RAISE_APPLICATION_ERROR(-20001,'no existing sdo metadata for table');
         
      END IF;
      
      SELECT
      a.diminfo
      INTO obj_diminfo
      FROM
      user_sdo_geom_metadata a
      WHERE
          a.table_name = p_table_name
      AND a.column_name = str_column_name;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Collect the aggregate mbr of the table
      --------------------------------------------------------------------------
      str_sql := 'SELECT '
              || 'MDSYS.SDO_AGGR_MBR(a.' || str_column_name || ') '
              || 'FROM '
              || p_table_name || ' a ';
              
      EXECUTE IMMEDIATE str_sql INTO sdo_envelope;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Update just the x and y elements of the diminfo object
      --------------------------------------------------------------------------
      obj_diminfo(1) := MDSYS.SDO_DIM_ELEMENT(
          obj_diminfo(1).sdo_dimname
         ,sdo_envelope.SDO_ORDINATES(1)
         ,sdo_envelope.SDO_ORDINATES(3)
         ,obj_diminfo(1).sdo_tolerance
      );
      
      obj_diminfo(2) := MDSYS.SDO_DIM_ELEMENT(
          obj_diminfo(2).sdo_dimname
         ,sdo_envelope.SDO_ORDINATES(2)
         ,sdo_envelope.SDO_ORDINATES(4)
         ,obj_diminfo(2).sdo_tolerance
      );
      
      --------------------------------------------------------------------------
      -- Step 60
      -- Update the metadata
      --------------------------------------------------------------------------
      UPDATE user_sdo_geom_metadata a
      SET a.diminfo = obj_diminfo 
      WHERE
          a.table_name = p_table_name
      AND a.column_name = str_column_name;
      
      COMMIT;
   
   END update_metadata_envelope;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   -- Function by Simon Greener
   -- http://www.spatialdbadvisor.com/oracle_spatial_tips_tricks/138/spatial-sorting-of-data-via-morton-key
   FUNCTION morton(
       p_column           IN  NATURAL
      ,p_row              IN  NATURAL
   ) RETURN INTEGER DETERMINISTIC
   AS
      v_row       NATURAL := ABS(p_row);
      v_col       NATURAL := ABS(p_column);
      v_key       NATURAL := 0;
      v_level     BINARY_INTEGER := 0;
      v_left_bit  BINARY_INTEGER;
      v_right_bit BINARY_INTEGER;
      v_quadrant  BINARY_INTEGER;
    
      FUNCTION left_shift(
          p_val   IN  NATURAL
         ,p_shift IN  NATURAL
      ) RETURN PLS_INTEGER
      AS
      BEGIN
         RETURN TRUNC(p_val * POWER(2,p_shift));
      
      END left_shift;
       
   BEGIN
      WHILE v_row > 0 OR v_col > 0 
      LOOP
         /*   split off the row (left_bit) and column (right_bit) bits and
              then combine them to form a bit-pair representing the
              quadrant                                                  */
         v_left_bit  := MOD(v_row,2);
         v_right_bit := MOD(v_col,2);
         v_quadrant  := v_right_bit + (2 * v_left_bit);
         v_key       := v_key + left_shift(v_quadrant,( 2 * v_level));
         /*   row, column, and level are then modified before the loop
              continues                                                */
         v_row := TRUNC(v_row / 2);
         v_col := TRUNC(v_col / 2);
         v_level := v_level + 1;
        
      END LOOP;
      
      RETURN v_key;
   
   END morton;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION morton_key(
       p_input            IN  MDSYS.SDO_GEOMETRY
      ,p_x_offset         IN  NUMBER
      ,p_y_offset         IN  NUMBER
      ,p_x_divisor        IN  NUMBER
      ,p_y_divisor        IN  NUMBER
      ,p_geom_devolve     IN  VARCHAR2 DEFAULT 'ACCURATE'
      ,p_tolerance        IN  NUMBER DEFAULT 0.05
   ) RETURN INTEGER DETERMINISTIC
   AS
      sdo_input        MDSYS.SDO_GEOMETRY := p_input;
      str_geom_devolve VARCHAR2(4000 Char) := UPPER(p_geom_devolve);
      num_tolerance    NUMBER := p_tolerance;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF str_geom_devolve IS NULL
      OR str_geom_devolve NOT IN ('ACCURATE','FAST')
      THEN
         str_geom_devolve := 'ACCURATE';
         
      END IF;
      
      IF num_tolerance IS NULL
      THEN
         num_tolerance := 0.05;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Devolve the input geometry to a point
      --------------------------------------------------------------------------
      sdo_input := devolve_point(
          p_input        => sdo_input
         ,p_geom_devolve => str_geom_devolve
         ,p_tolerance    => num_tolerance
      );
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Return the Morton key
      --------------------------------------------------------------------------
      RETURN morton(
          FLOOR((sdo_input.SDO_POINT.y + p_y_offset ) / p_y_divisor )
         ,FLOOR((sdo_input.SDO_POINT.x + p_x_offset ) / p_x_divisor )
      );
   
   END morton_key;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION morton_update(
       p_owner            IN  VARCHAR2 DEFAULT NULL
      ,p_table_name       IN  VARCHAR2
      ,p_column_name      IN  VARCHAR2 DEFAULT 'SHAPE'
      ,p_use_metadata_env IN  VARCHAR2 DEFAULT 'FALSE'
      ,p_grid_size        IN  NUMBER
   ) RETURN VARCHAR2
   AS
      str_owner       VARCHAR2(30 Char) := p_owner;
      str_column_name VARCHAR2(30 Char) := p_column_name;
      str_use_metadata_env VARCHAR2(4000 Char) := UPPER(p_use_metadata_env);
      str_sql         VARCHAR2(4000 Char);
      sdo_envelope    MDSYS.SDO_GEOMETRY;
      obj_diminfo     MDSYS.SDO_DIM_ARRAY;
      num_check       NUMBER;
      num_max_x       NUMBER;
      num_min_x       NUMBER;
      num_max_y       NUMBER;
      num_min_y       NUMBER;
      num_range_x     NUMBER;
      num_range_y     NUMBER;
      num_offset_x    NUMBER;
      num_offset_y    NUMBER;
      num_divisor_x   NUMBER;
      num_divisor_y   NUMBER;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF str_owner IS NULL
      THEN
         str_owner := USER;
         
      END IF;
      
      IF str_column_name IS NULL
      THEN
         str_column_name := 'SHAPE';
         
      END IF;
      
      IF str_use_metadata_env IS NULL
      OR str_use_metadata_env NOT IN ('TRUE','FALSE')
      THEN
         str_use_metadata_env := 'FALSE';
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Check that table and column exists
      --------------------------------------------------------------------------
      SELECT
      COUNT(*)
      INTO num_check
      FROM
      all_tables a
      JOIN
      all_tab_cols b
      ON
          a.owner = b.owner
      AND a.table_name = b.table_name
      WHERE
          a.owner = str_owner
      AND a.table_name = p_table_name
      AND b.column_name = str_column_name;
      
      IF num_check <> 1
      THEN
         RAISE_APPLICATION_ERROR(-20001,'cannot find table with column name');
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Get the max and mins either from metadata or calc it
      --------------------------------------------------------------------------
      IF str_use_metadata_env = 'TRUE'
      THEN
         SELECT
         COUNT(*) 
         INTO num_check
         FROM
         user_sdo_geom_metadata a
         WHERE
             a.table_name = p_table_name
         AND a.column_name = str_column_name;
         
         IF num_check <> 1
         THEN
            RAISE_APPLICATION_ERROR(-20001,'no existing sdo metadata for table');
            
         END IF;
         
         SELECT
         a.diminfo
         INTO obj_diminfo
         FROM
         user_sdo_geom_metadata a
         WHERE
             a.table_name = p_table_name
         AND a.column_name = str_column_name;
      
         num_min_x := obj_diminfo(1).sdo_lb;
         num_max_x := obj_diminfo(1).sdo_ub;
         
         num_min_y := obj_diminfo(2).sdo_lb;
         num_max_y := obj_diminfo(2).sdo_ub;
         
      ELSE
         str_sql := 'SELECT '
                 || 'MDSYS.SDO_AGGR_MBR(a.' || str_column_name || ') '
                 || 'FROM '
                 || p_table_name || ' a ';
              
         EXECUTE IMMEDIATE str_sql INTO sdo_envelope;
         
         num_min_x := sdo_envelope.SDO_ORDINATES(1);
         num_max_x := sdo_envelope.SDO_ORDINATES(3);
         
         num_min_y := sdo_envelope.SDO_ORDINATES(2);
         num_max_y := sdo_envelope.SDO_ORDINATES(4);
      
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Get the max and mins either from metadata or calc it
      --------------------------------------------------------------------------
      num_range_x   := num_max_x - num_min_x;
      num_range_y   := num_max_y - num_min_y;
      num_offset_x  := num_min_x * -1;
      num_offset_y  := num_min_y * -1;
      num_divisor_x := num_range_x / p_grid_size;
      num_divisor_y := num_range_y / p_grid_size;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Return the update statement
      --------------------------------------------------------------------------
      RETURN 'morton_key(' || 
         str_column_name || ',' ||
         num_offset_x || ',' || num_offset_y || ',' ||
         num_divisor_x || ',' || num_divisor_y || ')';
   
   END morton_update;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION morton_visualize(
       p_owner            IN  VARCHAR2 DEFAULT NULL
      ,p_table_name       IN  VARCHAR2
      ,p_column_name      IN  VARCHAR2 DEFAULT 'SHAPE'
      ,p_key_field        IN  VARCHAR2 DEFAULT 'OBJECTID'
      ,p_key_start        IN  VARCHAR2
      ,p_morton_key_range IN  NUMBER
      ,p_morton_key_field IN  VARCHAR2 DEFAULT 'MORTON_KEY'
   ) RETURN MDSYS.SDO_GEOMETRY
   AS
      str_sql     VARCHAR2(4000 Char);
      str_owner   VARCHAR2(30 Char) := p_owner;
      int_morton  INTEGER;
      ary_sdo     MDSYS.SDO_GEOMETRY_ARRAY;
      sdo_temp    MDSYS.SDO_GEOMETRY;
      sdo_output  MDSYS.SDO_GEOMETRY;
      int_counter PLS_INTEGER;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF str_owner IS NULL
      THEN
         str_owner := USER;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Grab the intial morton key for start record
      --------------------------------------------------------------------------
      str_sql := 'SELECT '
              || 'a.' || p_morton_key_field || ' ' 
              || 'FROM '
              || str_owner || '.' || p_table_name || ' a ' 
              || 'WHERE '
              || '    a.' || p_key_field || ' = :p01 '
              || 'AND rownum <= 1';
      
      EXECUTE IMMEDIATE str_sql INTO int_morton
      USING p_key_start;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Grab the geometries that follow 
      --------------------------------------------------------------------------
      str_sql := 'SELECT '
              || 'a.' || p_column_name || ' '
              || 'FROM '
              || str_owner || '.' || p_table_name || ' a ' 
              || 'WHERE '
              || '    a.' || p_morton_key_field || ' >= :p01 '
              || 'AND a.' || p_morton_key_field || ' <  :p02 '
              || 'ORDER BY '
              || 'a.' || p_morton_key_field || ' ASC ';
              
      EXECUTE IMMEDIATE str_sql
      BULK COLLECT INTO ary_sdo
      USING int_morton, int_morton + p_morton_key_range;
      
      IF ary_sdo IS NULL
      OR ary_sdo.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;

      --------------------------------------------------------------------------
      -- Step 40
      -- Construct the line
      --------------------------------------------------------------------------
      sdo_output := MDSYS.SDO_GEOMETRY(
          2002
         ,ary_sdo(1).SDO_SRID
         ,NULL
         ,MDSYS.SDO_ELEM_INFO_ARRAY(1,2,1)
         ,MDSYS.SDO_ORDINATE_ARRAY()
      );
      
      int_counter := 1;
      sdo_output.SDO_ORDINATES.EXTEND(ary_sdo.COUNT * 2);
      FOR i IN 1 .. ary_sdo.COUNT
      LOOP
         sdo_temp := devolve_point(ary_sdo(i),'ACCURATE',1);
         sdo_output.SDO_ORDINATES(int_counter) := sdo_temp.SDO_POINT.X;
         int_counter := int_counter + 1;
         sdo_output.SDO_ORDINATES(int_counter) := sdo_temp.SDO_POINT.Y;
         int_counter := int_counter + 1;
         
      END LOOP;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Return what we gots
      --------------------------------------------------------------------------
      RETURN sdo_output;
   
   END morton_visualize;
      
END dz_sdo_cluster;
/


--*************************--
PROMPT DZ_SDO_SQLTEXT.pks;

CREATE OR REPLACE PACKAGE dz_sdo_sqltext
AUTHID CURRENT_USER
AS
  
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION sdo2sql (
       p_input            IN  MDSYS.SDO_GEOMETRY
      ,p_2d_flag          IN  VARCHAR2 DEFAULT 'FALSE'
      ,p_output_srid      IN  NUMBER   DEFAULT NULL
      ,p_pretty_print     IN  NUMBER   DEFAULT 0
   ) RETURN CLOB;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION sdo2sql_nvl(
       p_input            IN  MDSYS.SDO_GEOMETRY
      ,p_is_null          IN  CLOB
      ,p_2d_flag          IN  VARCHAR2 DEFAULT 'FALSE'
      ,p_output_srid      IN  NUMBER   DEFAULT NULL
      ,p_pretty_print     IN  NUMBER   DEFAULT 0
   ) RETURN CLOB;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION sdo2sql (
       p_input            IN  MDSYS.SDO_GEOMETRY_ARRAY
      ,p_2d_flag          IN  VARCHAR2 DEFAULT 'FALSE'
      ,p_output_srid      IN  NUMBER   DEFAULT NULL
      ,p_pretty_print     IN  NUMBER   DEFAULT 0
   ) RETURN CLOB;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION sdo2sql (
       p_input            IN  MDSYS.SDO_POINT_TYPE
      ,p_pretty_print     IN  NUMBER   DEFAULT 0
   ) RETURN CLOB;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION sdo2sql (
       p_input            IN  MDSYS.SDO_ELEM_INFO_ARRAY
      ,p_pretty_print     IN  NUMBER   DEFAULT 0
   ) RETURN CLOB;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION sdo2sql (
       p_input            IN  MDSYS.SDO_ORDINATE_ARRAY
      ,p_pretty_print     IN  NUMBER   DEFAULT 0
   ) RETURN CLOB;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION sdo2sql (
       p_input            IN  MDSYS.SDO_DIM_ARRAY
      ,p_pretty_print     IN  NUMBER   DEFAULT 0
   ) RETURN CLOB;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION dump_string_endpoints(
      p_input             IN  MDSYS.SDO_GEOMETRY
   ) RETURN VARCHAR2;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION dump_string_endpoints(
       p_input_1          IN  MDSYS.SDO_GEOMETRY
      ,p_input_2          IN  MDSYS.SDO_GEOMETRY
   ) RETURN VARCHAR2;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION dump_sdo_subelements(
       p_input            IN  MDSYS.SDO_GEOMETRY
      ,p_indent           IN  VARCHAR2 DEFAULT ''
   ) RETURN CLOB;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION dump_single_point_ordinate(
       p_input            IN  MDSYS.SDO_GEOMETRY
      ,p_vertice_type     IN  VARCHAR2
      ,p_vertice_position IN  NUMBER DEFAULT 1
   ) RETURN NUMBER;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION dump_mbr(
      p_input            IN  MDSYS.SDO_GEOMETRY
   ) RETURN VARCHAR2;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION label_ordinates(
      p_input           IN MDSYS.SDO_GEOMETRY
   ) RETURN dz_sdo_labeled_list PIPELINED;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION label_measures(
      p_input           IN MDSYS.SDO_GEOMETRY
   ) RETURN dz_sdo_labeled_list PIPELINED;

END dz_sdo_sqltext;
/

GRANT EXECUTE ON dz_sdo_sqltext TO public;


--*************************--
PROMPT DZ_SDO_SQLTEXT.pkb;

CREATE OR REPLACE PACKAGE BODY dz_sdo_sqltext
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION sdo2sql (
       p_input        IN  MDSYS.SDO_GEOMETRY
      ,p_2d_flag      IN  VARCHAR2 DEFAULT 'FALSE'
      ,p_output_srid  IN  NUMBER   DEFAULT NULL
      ,p_pretty_print IN  NUMBER   DEFAULT 0
   ) RETURN CLOB
   AS
      sdo_input     MDSYS.SDO_GEOMETRY := p_input;
      str_2d_flag   VARCHAR(5 Char)   := UPPER(p_2d_flag);
      str_srid      VARCHAR(12 Char);
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------   
      IF str_2d_flag IS NULL
      THEN
         str_2d_flag := 'FALSE';
         
      ELSIF str_2d_flag NOT IN ('TRUE','FALSE')
      THEN
         RAISE_APPLICATION_ERROR(-20001,'boolean error');
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Downsize to 2D if required
      --------------------------------------------------------------------------   
      IF str_2d_flag = 'TRUE'
      THEN
         sdo_input := dz_sdo_util.downsize_2d(sdo_input);
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Transform if requested
      --------------------------------------------------------------------------   
      IF p_output_srid IS NOT NULL
      AND p_output_srid != sdo_input.SDO_SRID
      THEN
         sdo_input := MDSYS.SDO_CS.TRANSFORM(
            geom    => sdo_input
           ,to_srid => p_output_srid
         );
        
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Account for NULL SRID
      -------------------------------------------------------------------------- 
      IF p_input.SDO_SRID IS NULL
      THEN
         str_srid := 'NULL';
         
      ELSE
         str_srid := TO_CHAR(p_input.SDO_SRID);
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Cough out the results
      --------------------------------------------------------------------------   
      RETURN dz_sdo_util.pretty('MDSYS.SDO_GEOMETRY(',p_pretty_print)
         || dz_sdo_util.pretty(TO_CHAR(p_input.SDO_GTYPE) || ',',p_pretty_print + 1)
         || dz_sdo_util.pretty(str_srid || ',',p_pretty_print + 1)
         || dz_sdo_util.pretty(sdo2sql(p_input.SDO_POINT,p_pretty_print + 1) || ',',p_pretty_print)
         || dz_sdo_util.pretty(sdo2sql(p_input.SDO_ELEM_INFO,p_pretty_print + 1) || ',',p_pretty_print)
         || dz_sdo_util.pretty(sdo2sql(p_input.SDO_ORDINATES,p_pretty_print + 1),p_pretty_print)
         || dz_sdo_util.pretty(')',p_pretty_print,NULL,NULL);

   END sdo2sql;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION sdo2sql_nvl(
       p_input            IN  MDSYS.SDO_GEOMETRY
      ,p_is_null          IN  CLOB
      ,p_2d_flag          IN  VARCHAR2 DEFAULT 'FALSE'
      ,p_output_srid      IN  NUMBER   DEFAULT NULL
      ,p_pretty_print     IN  NUMBER   DEFAULT 0
   ) RETURN CLOB
   AS
   
   BEGIN
      IF p_input IS NULL
      THEN
         RETURN p_is_null;
         
      ELSE
         RETURN sdo2sql(
             p_input        => p_input
            ,p_2d_flag      => p_2d_flag
            ,p_output_srid  => p_output_srid
            ,p_pretty_print => p_pretty_print
         );
         
      END IF;
         
   END sdo2sql_nvl;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION sdo2sql(
       p_input        IN  MDSYS.SDO_GEOMETRY_ARRAY
      ,p_2d_flag      IN  VARCHAR2 DEFAULT 'FALSE'
      ,p_output_srid  IN  NUMBER   DEFAULT NULL
      ,p_pretty_print IN  NUMBER   DEFAULT 0
   ) RETURN CLOB
   AS
      clb_output CLOB;
      
   BEGIN
      
      IF p_input IS NULL
      OR p_input.COUNT = 0
      THEN
         RETURN NULL;
         
      END IF;
      
      clb_output := '';
      FOR i IN 1 .. p_input.COUNT
      LOOP
         clb_output := clb_output || sdo2sql(
             p_input        => p_input(i)
            ,p_2d_flag      => p_2d_flag
            ,p_output_srid  => p_output_srid
            ,p_pretty_print => p_pretty_print
         ) || CHR(10);
         
      END LOOP;
      
      RETURN clb_output;
      
   END sdo2sql;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION sdo2sql (
      p_input        IN MDSYS.SDO_POINT_TYPE,
      p_pretty_print IN NUMBER   DEFAULT 0
   ) RETURN CLOB
   AS
      X          VARCHAR2(64 Char);
      Y          VARCHAR2(64 Char);
      Z          VARCHAR2(64 Char);

   BEGIN
   
      IF p_input IS NULL
      THEN
         RETURN dz_sdo_util.pretty('NULL',p_pretty_print,NULL,NULL);
         
      END IF;

      IF p_input.X IS NULL
      THEN
         X := 'NULL';
         
      ELSE
         X := TO_CHAR(p_input.X);
         
      END IF;

      IF p_input.Y IS NULL
      THEN
         Y := 'NULL';
         
      ELSE
         Y := TO_CHAR(p_input.Y);
         
      END IF;

      IF p_input.Z IS NULL
      THEN
         Z := 'NULL';
         
      ELSE
         Z := TO_CHAR(p_input.Z);
         
      END IF;
      
      RETURN dz_sdo_util.pretty('MDSYS.SDO_POINT_TYPE(',p_pretty_print)
          || dz_sdo_util.pretty(X || ',',p_pretty_print + 1)
          || dz_sdo_util.pretty(Y || ',',p_pretty_print + 1)
          || dz_sdo_util.pretty(Z,p_pretty_print + 1)
          || dz_sdo_util.pretty(')',p_pretty_print,NULL,NULL);
          
   END sdo2sql;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION sdo2sql (
      p_input        IN MDSYS.SDO_ELEM_INFO_ARRAY,
      p_pretty_print IN NUMBER   DEFAULT 0
   ) RETURN CLOB
   AS
      clb_output CLOB := '';
      
   BEGIN
   
      IF p_input IS NULL
      THEN
         RETURN dz_sdo_util.pretty('NULL',p_pretty_print,NULL,NULL);
         
      END IF;

      clb_output := dz_sdo_util.pretty('MDSYS.SDO_ELEM_INFO_ARRAY(',p_pretty_print);

      FOR i IN 1 .. p_input.COUNT
      LOOP
         IF i < p_input.COUNT
         THEN
            clb_output := clb_output 
                    || dz_sdo_util.pretty(TO_CHAR(p_input(i)) || ',',p_pretty_print + 1);
         ELSE
            clb_output := clb_output 
                    || dz_sdo_util.pretty(TO_CHAR(p_input(i)),p_pretty_print + 1);
         END IF;
  
      END LOOP;

      RETURN clb_output || dz_sdo_util.pretty(')',p_pretty_print,NULL,NULL);

   END sdo2sql;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION sdo2sql (
      p_input        IN MDSYS.SDO_ORDINATE_ARRAY,
      p_pretty_print IN NUMBER   DEFAULT 0
   ) RETURN CLOB
   AS
      clb_output CLOB := '';
      
   BEGIN
   
      IF p_input IS NULL
      THEN
         RETURN dz_sdo_util.pretty('NULL',p_pretty_print,NULL,NULL);
      END IF;
      
      clb_output := dz_sdo_util.pretty('MDSYS.SDO_ORDINATE_ARRAY(',p_pretty_print);
      
      FOR i IN 1 .. p_input.COUNT
      LOOP    
         IF i < p_input.COUNT
         THEN
            clb_output := clb_output
                       || dz_sdo_util.pretty(TO_CHAR(p_input(i)) || ',',p_pretty_print + 1);
         ELSE
            clb_output := clb_output
                       || dz_sdo_util.pretty(TO_CHAR(p_input(i)),p_pretty_print + 1);
         END IF;
         
      END LOOP;
      
      RETURN clb_output || dz_sdo_util.pretty(')',p_pretty_print,NULL,NULL);

   END sdo2sql;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION sdo2sql (
      p_input        IN MDSYS.SDO_DIM_ARRAY,
      p_pretty_print IN NUMBER   DEFAULT 0
   ) RETURN CLOB
   AS
      clb_output  CLOB;
      int_count   PLS_INTEGER;
      
   BEGIN
   
      clb_output := dz_sdo_util.pretty('MDSYS.SDO_DIM_ARRAY(',p_pretty_print);
      
      int_count  := p_input.COUNT;

      FOR i IN 1 .. 4
      LOOP
         IF i <= int_count
         THEN
            clb_output := clb_output
                       || dz_sdo_util.pretty('MDSYS.SDO_DIM_ELEMENT(',p_pretty_print + 1)
                       || dz_sdo_util.pretty('''' || p_input(i).SDO_DIMNAME || ''',',p_pretty_print + 2)
                       || dz_sdo_util.pretty(TO_CHAR(p_input(i).SDO_LB) || ',',p_pretty_print + 2)
                       || dz_sdo_util.pretty(TO_CHAR(p_input(i).SDO_UB) || ',',p_pretty_print + 2)
                       || dz_sdo_util.pretty(TO_CHAR(p_input(i).SDO_TOLERANCE),p_pretty_print + 2);
              
            IF i < int_count
            THEN
               clb_output := clb_output
                          || dz_sdo_util.pretty('),',p_pretty_print + 1);
            ELSE
               clb_output := clb_output
                          || dz_sdo_util.pretty(')',p_pretty_print + 1);
            END IF;
            
         END IF;
            
      END LOOP;
 
      RETURN clb_output || dz_sdo_util.pretty(')',p_pretty_print,NULL,NULL);
      
   END sdo2sql;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION dump_string_endpoints(
      p_input        IN MDSYS.SDO_GEOMETRY
   ) RETURN VARCHAR2
   AS
      int_dims PLS_INTEGER;
      int_gtyp PLS_INTEGER;
      int_len  PLS_INTEGER;
      
   BEGIN
   
      int_dims := p_input.get_dims();
      int_gtyp := p_input.get_gtype();

      IF int_gtyp <> 2
      THEN
         RAISE_APPLICATION_ERROR(-20001,'expected linestring but got ' || p_input.SDO_GTYPE);
         
      END IF;

      int_len := p_input.SDO_ORDINATES.COUNT();

      IF int_dims = 2
      THEN
         RETURN p_input.SDO_ORDINATES(1)           || ' , '
             || p_input.SDO_ORDINATES(2)           || ' <-> '
             || p_input.SDO_ORDINATES(int_len - 1) || ' , '
             || p_input.SDO_ORDINATES(int_len);
             
      ELSIF int_dims = 3
      THEN
         RETURN p_input.SDO_ORDINATES(1)           || ' , '
             || p_input.SDO_ORDINATES(2)           || ' , '
             || p_input.SDO_ORDINATES(3)           || ' <-> '
             || p_input.SDO_ORDINATES(int_len - 2) || ' , '
             || p_input.SDO_ORDINATES(int_len - 1) || ' , '
             || p_input.SDO_ORDINATES(int_len);
             
      ELSIF int_dims = 4
      THEN
         RETURN p_input.SDO_ORDINATES(1)           || ' , '
             || p_input.SDO_ORDINATES(2)           || ' , '
             || p_input.SDO_ORDINATES(3)           || ' , '
             || p_input.SDO_ORDINATES(4)           || ' <-> '
             || p_input.SDO_ORDINATES(int_len - 3) || ' , '
             || p_input.SDO_ORDINATES(int_len - 2) || ' , '
             || p_input.SDO_ORDINATES(int_len - 1) || ' , '
             || p_input.SDO_ORDINATES(int_len);
             
      ELSE
         RAISE_APPLICATION_ERROR(-20001,'no idea what to do with ' || p_input.SDO_GTYPE);
         
      END IF;

   END dump_string_endpoints;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION dump_string_endpoints(
      p_input_1      IN  MDSYS.SDO_GEOMETRY,
      p_input_2      IN  MDSYS.SDO_GEOMETRY
   ) RETURN VARCHAR2
   AS
   BEGIN
      RETURN dump_string_endpoints(p_input_1) || CHR(10)
          || dump_string_endpoints(p_input_2);
          
   END dump_string_endpoints;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION dump_sdo_subelements(
      p_input        IN  MDSYS.SDO_GEOMETRY,
      p_indent       IN  VARCHAR2 DEFAULT ''
   ) RETURN CLOB
   AS
      clb_output CLOB := '';
      int_dims   PLS_INTEGER;
      int_gtyp   PLS_INTEGER;
      
   BEGIN
   
      int_dims := p_input.get_dims();
      int_gtyp := p_input.get_gtype();
      
      IF int_gtyp IN (4,5,6,7)
      THEN
         FOR i IN 1 .. MDSYS.SDO_UTIL.GETNUMELEM(p_input)
         LOOP
            clb_output := clb_output
                       || sdo2sql(MDSYS.SDO_UTIL.EXTRACT(p_input,i),p_indent) || CHR(10);
                       
         END LOOP;
         
         RETURN clb_output;
         
      ELSE
         RETURN sdo2sql(p_input,p_indent);
         
      END IF;

   END dump_sdo_subelements;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION dump_single_point_ordinate(
      p_input            IN MDSYS.SDO_GEOMETRY,
      p_vertice_type     IN VARCHAR2,
      p_vertice_position IN NUMBER DEFAULT 1
   ) RETURN NUMBER
   AS
      str_vertice_type     VARCHAR2(1) := UPPER(p_vertice_type);
      num_vertice_position NUMBER      := p_vertice_position;
      num_gtype            NUMBER;
      num_dim              NUMBER;
      num_lrs              NUMBER;
      
   BEGIN
   
      --------------------------------------------------------------------------
      -- Step 10
      -- Check over incoming parameters
      --------------------------------------------------------------------------
      IF str_vertice_type IS NULL
      OR str_vertice_type NOT IN ('X','Y','Z','M')
      THEN
         RAISE_APPLICATION_ERROR(-20001,'ERROR, vertice type may only be X, Y, Z or M!');
         
      END IF;
      
      IF num_vertice_position IS NULL
      THEN
         num_vertice_position := 1;
         
      END IF;
      
      IF p_input IS NULL
      THEN
         RETURN NULL;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 20
      -- Check that gtype and vertice type are sensible
      --------------------------------------------------------------------------
      num_gtype := p_input.get_gtype();
      num_dim   := p_input.get_dims();
      
      IF num_gtype NOT IN (1,2,3)
      THEN
         RAISE_APPLICATION_ERROR(-20001,'function only applies to single geometries');
      END IF;
      
      IF str_vertice_type IN ('M','Z')
      AND num_dim < 3
      THEN
         RAISE_APPLICATION_ERROR(-20001,'input geometry does not have Z or M dimensions');
      END IF;
      
      num_lrs := p_input.get_lrs_dim();
      IF str_vertice_type = 'M'
      AND num_lrs = 0
      THEN
         RAISE_APPLICATION_ERROR(-20001,'input geometry does not have M dimension indicated on sdo_gtype');
      END IF;
      
      IF num_gtype = 1
      AND num_vertice_position != 1
      THEN
         RAISE_APPLICATION_ERROR(-20001,'points can only have a single vertice');
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 30
      -- Check if this is a point with sdo_point type
      --------------------------------------------------------------------------
      IF p_input.SDO_POINT IS NOT NULL
      THEN
         IF str_vertice_type = 'X'
         THEN
            RETURN p_input.sdo_point.X;
            
         ELSIF str_vertice_type = 'Y'
         THEN
            RETURN p_input.sdo_point.Y;
            
         ELSIF str_vertice_type = 'Z'
         THEN
            RETURN p_input.sdo_point.Z;
            
         ELSIF str_vertice_type = 'M'
         THEN
            RAISE_APPLICATION_ERROR(-20001,'sdo_point type geometries cannot carry M values');
            
         END IF;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 40
      -- Check if this is a point with sdo_ordinates
      --------------------------------------------------------------------------
      IF num_gtype = 1
      THEN
         IF str_vertice_type = 'X'
         THEN
            RETURN p_input.sdo_ordinates(1);
            
         ELSIF str_vertice_type = 'Y'
         THEN
            RETURN p_input.sdo_ordinates(2);
            
         ELSIF str_vertice_type = 'Z'
         THEN
            IF num_lrs = 3
            THEN
               RETURN p_input.sdo_ordinates(4);
               
            ELSIF num_lrs = 4
            THEN
               RETURN p_input.sdo_ordinates(3);
               
            ELSE 
               RETURN p_input.sdo_ordinates(3);
               
            END IF;
            
         ELSIF str_vertice_type = 'M'
         THEN
            IF num_lrs = 3
            THEN
               RETURN p_input.sdo_ordinates(3);
               
            ELSIF num_lrs = 4
            THEN
               RETURN p_input.sdo_ordinates(4);
               
            END IF;
            
         END IF;
         
      END IF;
      
      --------------------------------------------------------------------------
      -- Step 50
      -- Process lines and polygons
      --------------------------------------------------------------------------
      RAISE_APPLICATION_ERROR(-20001,'not implemented');
      
   END dump_single_point_ordinate;

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION dump_mbr(
      p_input        IN MDSYS.SDO_GEOMETRY
   ) RETURN VARCHAR2
   AS
     sdo_input MDSYS.SDO_GEOMETRY := p_input;
     
   BEGIN

      IF p_input IS NULL
      THEN
         RETURN NULL;
         
      END IF;

      IF MDSYS.SDO_UTIL.GETNUMVERTICES(p_input) = 2
      AND p_input.SDO_ELEM_INFO(3) = 3
      THEN
         RETURN TO_CHAR(p_input.SDO_ORDINATES(1)) || ',' ||
            TO_CHAR(p_input.SDO_ORDINATES(2))     || ',' ||
            TO_CHAR(p_input.SDO_ORDINATES(3))     || ',' ||
            TO_CHAR(p_input.SDO_ORDINATES(4));
             
      ELSE
         sdo_input := MDSYS.SDO_GEOM.SDO_MBR(
            dz_sdo_util.downsize_2d(p_input)
         );
         
         IF ( MDSYS.SDO_UTIL.GETNUMVERTICES(sdo_input) = 2 AND sdo_input.SDO_ELEM_INFO(3) = 3) 
         OR ( MDSYS.SDO_UTIL.GETNUMVERTICES(sdo_input) = 2 AND sdo_input.SDO_ELEM_INFO(1) = 1 AND sdo_input.SDO_ELEM_INFO(3) = 1)
         THEN
            RETURN TO_CHAR(sdo_input.SDO_ORDINATES(1)) || ',' ||
               TO_CHAR(sdo_input.SDO_ORDINATES(2))     || ',' ||
               TO_CHAR(sdo_input.SDO_ORDINATES(3))     || ',' ||
               TO_CHAR(sdo_input.SDO_ORDINATES(4));
               
         ELSE
            RAISE_APPLICATION_ERROR(
               -20001,
               'input to dump_mbr must be 2 vertice rectangle' || CHR(13) ||
               'found ' || TO_CHAR(sdo_input.SDO_GTYPE)   
            );
            
         END IF;
         
      END IF;

   END dump_mbr;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION label_ordinates(
      p_input           IN MDSYS.SDO_GEOMETRY
   ) RETURN dz_sdo_labeled_list PIPELINED
   AS
      num_dims  PLS_INTEGER;
      num_last  PLS_INTEGER;
      num_index PLS_INTEGER := 1;
      num_coor  PLS_INTEGER := 1;
      rec_label dz_sdo_labeled := dz_sdo_labeled();
      x         NUMBER;
      y         NUMBER;
      
   BEGIN
   
      num_dims := p_input.get_dims();
      num_last := p_input.SDO_ORDINATES.COUNT;

      WHILE num_index <= num_last
      LOOP
         x := p_input.SDO_ORDINATES(num_index);
         y := p_input.SDO_ORDINATES(num_index + 1);
         num_index := num_index + num_dims;
         rec_label.shape_label := TO_CHAR(num_coor);
         num_coor := num_coor + 1;
         
         rec_label.shape := MDSYS.SDO_GEOMETRY(
             2001
            ,p_input.SDO_SRID
            ,MDSYS.SDO_POINT_TYPE(
                 x
                ,y
                ,NULL
             )
            ,NULL
            ,NULL
         );
         
         PIPE ROW(rec_label);
         
      END LOOP;
      
   END label_ordinates;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION label_measures(
      p_input           IN MDSYS.SDO_GEOMETRY
   ) RETURN dz_sdo_labeled_list PIPELINED
   AS
      num_lrs   PLS_INTEGER;
      num_dims  PLS_INTEGER;
      num_last  PLS_INTEGER;
      num_index PLS_INTEGER := 1;
      num_coor  PLS_INTEGER := 1;
      rec_label dz_sdo_labeled := dz_sdo_labeled();
      x1        NUMBER;
      y1        NUMBER;
      m1        NUMBER;
      
   BEGIN
      num_lrs  := p_input.get_lrs_dim();
      num_dims := p_input.get_dims();
      
      IF num_lrs = 0
      THEN
         RAISE_APPLICATION_ERROR(-20001,'geometry is not LRS');
         
      END IF;
      
      num_last := p_input.SDO_ORDINATES.COUNT;

      WHILE num_index <= num_last
      LOOP
         x1 := p_input.SDO_ORDINATES(num_index);
         y1 := p_input.SDO_ORDINATES(num_index + 1);
         
         IF num_lrs = 3
         THEN
            m1 := p_input.SDO_ORDINATES(num_index + 2);
            
         ELSIF num_lrs = 4
         THEN
            m1 := p_input.SDO_ORDINATES(num_index + 3);
            
         END IF;
         
         num_index := num_index + num_dims;
         rec_label.shape_label := TO_CHAR(m1);
         num_coor := num_coor + 1;
         rec_label.shape := MDSYS.SDO_GEOMETRY(
             2001
            ,p_input.SDO_SRID
            ,MDSYS.SDO_POINT_TYPE(
                 x1
                ,y1
                ,NULL
             )
            ,NULL
            ,NULL
         );
         
         PIPE ROW(rec_label);
         
      END LOOP;
      
   END label_measures;
   
END dz_sdo_sqltext;
/


--*************************--
PROMPT DZ_SDO_TEST.pks;

CREATE OR REPLACE PACKAGE dz_sdo_test
AUTHID DEFINER
AS

   C_TFS_CHANGESET CONSTANT NUMBER := 8194;
   C_JENKINS_JOBNM CONSTANT VARCHAR2(255 Char) := 'NULL';
   C_JENKINS_BUILD CONSTANT NUMBER := 3;
   C_JENKINS_BLDID CONSTANT VARCHAR2(255 Char) := 'NULL';
   
   C_PREREQUISITES CONSTANT MDSYS.SDO_STRING2_ARRAY := MDSYS.SDO_STRING2_ARRAY(
   );
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION prerequisites
   RETURN NUMBER;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION version
   RETURN VARCHAR2;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION inmemory_test
   RETURN NUMBER;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION scratch_test
   RETURN NUMBER;
      
END dz_sdo_test;
/

GRANT EXECUTE ON dz_sdo_test TO PUBLIC;


--*************************--
PROMPT DZ_SDO_TEST.pkb;

CREATE OR REPLACE PACKAGE BODY dz_sdo_test
AS

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION prerequisites
   RETURN NUMBER
   AS
      num_check NUMBER;
      
   BEGIN
      
      FOR i IN 1 .. C_PREREQUISITES.COUNT
      LOOP
         SELECT 
         COUNT(*)
         INTO num_check
         FROM 
         user_objects a
         WHERE 
             a.object_name = C_PREREQUISITES(i) || '_TEST'
         AND a.object_type = 'PACKAGE';
         
         IF num_check <> 1
         THEN
            RETURN 1;
         
         END IF;
      
      END LOOP;
      
      RETURN 0;
   
   END prerequisites;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION version
   RETURN VARCHAR2
   AS
   BEGIN
      RETURN '{"TFS":' || C_TFS_CHANGESET || ','
      || '"JOBN":"' || C_JENKINS_JOBNM || '",'   
      || '"BUILD":' || C_JENKINS_BUILD || ','
      || '"BUILDID":"' || C_JENKINS_BLDID || '"}';
      
   END version;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION inmemory_test
   RETURN NUMBER
   AS
   BEGIN
      RETURN 0;
      
   END inmemory_test;
   
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   FUNCTION scratch_test
   RETURN NUMBER
   AS
   BEGIN
      RETURN 0;
      
   END scratch_test;

END dz_sdo_test;
/


--*************************--
PROMPT sqlplus_footer.sql;


SHOW ERROR;

DECLARE
   l_num_errors PLS_INTEGER;

BEGIN

   SELECT
   COUNT(*)
   INTO l_num_errors
   FROM
   user_errors a
   WHERE
   a.name LIKE 'DZ_SDO%';

   IF l_num_errors <> 0
   THEN
      RAISE_APPLICATION_ERROR(-20001,'COMPILE ERROR');

   END IF;

   l_num_errors := DZ_SDO_TEST.inmemory_test();

   IF l_num_errors <> 0
   THEN
      RAISE_APPLICATION_ERROR(-20001,'INMEMORY TEST ERROR');

   END IF;

END;
/

EXIT;

