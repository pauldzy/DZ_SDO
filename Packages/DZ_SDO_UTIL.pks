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

