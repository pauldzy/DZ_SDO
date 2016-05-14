CREATE OR REPLACE PACKAGE dz_sdo_main
AUTHID CURRENT_USER
AS
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   /*
   header: DZ_SDO
     
   - Build ID: DZBUILDIDDZ
   - TFS Change Set: DZTFSCHANGESETDZ
   
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

