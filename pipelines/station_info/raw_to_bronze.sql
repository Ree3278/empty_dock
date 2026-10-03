CREATE OR REFRESH STREAMING TABLE citibike.bronze.station_info_raw
AS SELECT
  *,
  _metadata.file_path AS source_file,
  current_timestamp() AS ingested_at
FROM STREAM read_files(
  '/Volumes/citibike/bronze/landing/station_info/',
  format => 'json'
);