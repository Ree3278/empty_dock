CREATE OR REFRESH STREAMING TABLE station_status_raw
COMMENT 'Raw Citi Bike GBFS station_status snapshots, one row per file'
AS SELECT
  *,
  _metadata.file_path         AS source_file,
  _metadata.file_modification_time AS file_landed_at,
  current_timestamp()         AS ingested_at
FROM STREAM cloud_files(
  '/Volumes/citibike/bronze/landing/station_status/',
  'json'
);