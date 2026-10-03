CREATE OR REFRESH MATERIALIZED VIEW citibike.gold.station_hour
COMMENT 'Per station, per local hour: availability and time empty/full'
AS SELECT
  station_id,
  date_trunc('HOUR', from_utc_timestamp(feed_time, 'America/New_York')) AS hour_ny,
  avg(bikes_available)          AS avg_bikes,
  avg(docks_available)          AS avg_docks,
  avg(CAST(is_empty AS INT))    AS pct_empty,
  avg(CAST(is_full  AS INT))    AS pct_full,
  count(*)                      AS snapshots
FROM citibike.silver.station_status
GROUP BY station_id, hour_ny;