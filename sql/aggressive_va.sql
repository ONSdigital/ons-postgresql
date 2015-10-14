-- Alter autovacuum settings on certain EDC tables
-- To be used only until data model is fixed.
-- Note: this is not a long term solution I propose but a kludge.

ALTER TABLE edc_sample_selection SET (
  autovacuum_vacuum_threshold = 25,
  autovacuum_vacuum_scale_factor = 0.1,
  autovacuum_analyze_threshold = 10,
  autovacuum_analyze_scale_factor = 0.05);

ALTER TABLE edc_enrolment SET (
  autovacuum_vacuum_threshold = 25,
  autovacuum_vacuum_scale_factor = 0.1,
  autovacuum_analyze_threshold = 10,
  autovacuum_analyze_scale_factor = 0.05);

ALTER TABLE edc_sampling_frame_inclusion SET (
  autovacuum_vacuum_threshold = 25,
  autovacuum_vacuum_scale_factor = 0.1,
  autovacuum_analyze_threshold = 10,
  autovacuum_analyze_scale_factor = 0.05);

ALTER TABLE edc_instrument_useage SET (
  autovacuum_vacuum_threshold = 25,
  autovacuum_vacuum_scale_factor = 0.1,
  autovacuum_analyze_threshold = 10,
  autovacuum_analyze_scale_factor = 0.05);

ALTER TABLE edc_instrument_version SET (
  autovacuum_vacuum_threshold = 25,
  autovacuum_vacuum_scale_factor = 0.1,
  autovacuum_analyze_threshold = 10,
  autovacuum_analyze_scale_factor = 0.05);

ALTER TABLE edc_sampling_frame SET (
  autovacuum_vacuum_threshold = 25,
  autovacuum_vacuum_scale_factor = 0.1,
  autovacuum_analyze_threshold = 10,
  autovacuum_analyze_scale_factor = 0.05);

ALTER TABLE edc_survey SET (
  autovacuum_vacuum_threshold = 25,
  autovacuum_vacuum_scale_factor = 0.1,
  autovacuum_analyze_threshold = 10,
  autovacuum_analyze_scale_factor = 0.05);
  
ALTER TABLE edc_respondent_unit_asso SET (
  autovacuum_vacuum_threshold = 25,
  autovacuum_vacuum_scale_factor = 0.1,
  autovacuum_analyze_threshold = 10,
  autovacuum_analyze_scale_factor = 0.05);
