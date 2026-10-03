CREATE OR REFRESH MATERIALIZED VIEW citibike.silver.station_info (
  CONSTRAINT in_nyc        EXPECT (lat BETWEEN 40.4 AND 41.0 AND lon BETWEEN -74.3 AND -73.6) ON VIOLATION DROP ROW,
  CONSTRAINT has_capacity  EXPECT (capacity > 0)
)
COMMENT 'Latest known name, location and capacity for each station'
AS SELECT
  s.station_id, s.name, s.short_name, s.lat, s.lon, s.capacity, s.region_id,
  feed_time
FROM (
  SELECT
    timestamp_seconds(CAST(last_updated AS BIGINT)) AS feed_time,
    explode(data.stations) AS s
  FROM citibike.bronze.station_info_raw
)
QUALIFY row_number() OVER (PARTITION BY s.station_id ORDER BY feed_time DESC) = 1;