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

