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

