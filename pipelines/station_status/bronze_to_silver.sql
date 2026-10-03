CREATE OR REFRESH STREAMING TABLE citibike.silver.station_status (
  -- data-quality rules ("expectations")
  CONSTRAINT has_station_id   EXPECT (station_id IS NOT NULL)                          ON VIOLATION DROP ROW,
  CONSTRAINT counts_not_negative EXPECT (bikes_available >= 0 AND docks_available >= 0) ON VIOLATION DROP ROW,
  CONSTRAINT report_is_fresh  EXPECT (last_reported_at >= feed_time - INTERVAL 1 DAY)
)
COMMENT 'One row per station per snapshot, typed and cleaned'
AS SELECT
  s.station_id,
  timestamp_seconds(CAST(last_updated AS LONG)) AS feed_time,
  timestamp_seconds(s.last_reported)       AS last_reported_at,
  CAST(s.num_bikes_available  AS INT)      AS bikes_available,
  CAST(s.num_ebikes_available AS INT)      AS ebikes_available,
  CAST(s.num_docks_available  AS INT)      AS docks_available,
  CAST(s.num_bikes_disabled   AS INT)      AS bikes_disabled,
  CAST(s.is_renting   AS BOOLEAN)          AS is_renting,
  CAST(s.is_returning AS BOOLEAN)          AS is_returning,
  CAST(s.num_bikes_available AS INT) = 0   AS is_empty,
  CAST(s.num_docks_available AS INT) = 0   AS is_full,
  source_file
FROM (
  SELECT last_updated, source_file,
         explode(from_json(data, 'STRUCT<stations: ARRAY<STRUCT<station_id: STRING, last_reported: LONG, num_bikes_available: INT, num_ebikes_available: INT, num_docks_available: INT, num_bikes_disabled: INT, is_renting: BOOLEAN, is_returning: BOOLEAN>>>').stations) AS s
  FROM STREAM(citibike.bronze.station_status_raw)
);