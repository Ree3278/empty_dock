CREATE OR REFRESH MATERIALIZED VIEW citibike.gold.station_profile
COMMENT 'Each station classified by its commute pattern'
AS
WITH peaks AS (
  SELECT
    station_id,
    avg(CASE WHEN hour(hour_ny) BETWEEN 7  AND 9  THEN pct_empty END) AS am_empty,
    avg(CASE WHEN hour(hour_ny) BETWEEN 7  AND 9  THEN pct_full  END) AS am_full,
    avg(CASE WHEN hour(hour_ny) BETWEEN 16 AND 18 THEN pct_empty END) AS pm_empty,
    avg(CASE WHEN hour(hour_ny) BETWEEN 16 AND 18 THEN pct_full  END) AS pm_full,
    avg(pct_empty) AS day_empty,
    avg(pct_full)  AS day_full
  FROM citibike.gold.station_hour
  GROUP BY station_id
)
SELECT
  i.station_id, i.name, i.lat, i.lon, i.capacity,
  p.am_empty, p.am_full, p.pm_empty, p.pm_full, p.day_empty, p.day_full,
  CASE
    WHEN p.am_empty >= 0.2 AND p.pm_full  >= 0.2 THEN 'Residential: drains AM, fills PM'
    WHEN p.am_full  >= 0.2 AND p.pm_empty >= 0.2 THEN 'Job center: fills AM, drains PM'
    WHEN p.day_empty >= 0.2                      THEN 'Chronically empty'
    WHEN p.day_full  >= 0.2                      THEN 'Chronically full'
    ELSE 'Balanced'
  END AS station_type
FROM peaks p
JOIN citibike.silver.station_info i USING (station_id);