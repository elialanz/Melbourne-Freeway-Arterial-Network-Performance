/* 06_business_kpi_queries.sql
   Melbourne Freeway & Arterial Network - Operational Performance & Congestion.
   Standalone business-question queries (portfolio evidence, separate from the views).
   Reads rpt.fact_traffic + rpt.dim_* + stg.congestion_proxy.
   Load baseline anchor: 20,851,152 fact rows / 1,492,421,312 observed vehicles. */

/* Q0 - Reconciliation anchor: every business query traces back to this total. */
SELECT
    COUNT(*)      AS fact_rows,
    SUM(f.volume) AS total_observed_vehicles
FROM rpt.fact_traffic AS f;
GO

/* Q1 - Top operational-pressure sites (core network, formal peak bins).
   Pressure = recurring share of vehicles below each site's own off-peak median. */
SELECT TOP (20)
    s.site_id,
    s.site_name,
    s.corridor,
    SUM(cp.total_vol) AS peak_volume,
    CAST(SUM(cp.low_speed_vol) * 100.0 / NULLIF(SUM(cp.total_vol), 0) AS DECIMAL(5,2))
        AS peak_low_speed_share_pct
FROM stg.congestion_proxy AS cp
JOIN rpt.dim_time_period  AS tp ON tp.time_bin = cp.time_bin
JOIN rpt.dim_site         AS s  ON s.site_id   = cp.site
WHERE tp.is_peak = 1
  AND s.is_core  = 1
GROUP BY s.site_id, s.site_name, s.corridor
ORDER BY peak_low_speed_share_pct DESC, peak_volume DESC;
GO

/* Q2 - AM Peak vs PM Peak: volume and volume-weighted speed (weekday, non-holiday). */
SELECT
    tp.period_type,
    SUM(f.volume) AS total_volume,
    CAST(SUM(f.speed_volume_product) * 1.0 / NULLIF(SUM(f.volume), 0) AS DECIMAL(5,1))
        AS vol_weighted_speed_kmh
FROM rpt.fact_traffic    AS f
JOIN rpt.dim_date        AS d  ON d.date_key = f.date_key
JOIN rpt.dim_time_period AS tp ON tp.time_bin = f.time_bin
JOIN rpt.dim_site        AS s  ON s.site_id   = f.site_id
WHERE d.is_weekday        = 1
  AND d.is_public_holiday = 0
  AND s.is_active_in_data = 1
  AND tp.period_type IN ('AM Peak', 'PM Peak')
GROUP BY tp.period_type
ORDER BY tp.period_type;
GO

/* Q3 - Day-type comparison: weekday vs weekend vs public holiday (holidays split out). */
SELECT
    CASE WHEN d.is_public_holiday = 1 THEN 'Public Holiday' ELSE d.day_type END AS day_category,
    COUNT(DISTINCT d.date_key) AS days,
    SUM(f.volume)              AS total_volume,
    CAST(SUM(f.volume) * 1.0 / NULLIF(COUNT(DISTINCT d.date_key), 0) AS BIGINT)
        AS avg_volume_per_day,
    CAST(SUM(f.speed_volume_product) * 1.0 / NULLIF(SUM(f.volume), 0) AS DECIMAL(5,1))
        AS vol_weighted_speed_kmh
FROM rpt.fact_traffic AS f
JOIN rpt.dim_date     AS d ON d.date_key = f.date_key
JOIN rpt.dim_site     AS s ON s.site_id  = f.site_id
WHERE s.is_active_in_data = 1
GROUP BY CASE WHEN d.is_public_holiday = 1 THEN 'Public Holiday' ELSE d.day_type END
ORDER BY total_volume DESC;
GO

/* Q4 - Directional pressure: AM vs PM volume by heading (the W-morning / E-afternoon signal). */
SELECT
    f.heading,
    SUM(CASE WHEN tp.period_type = 'AM Peak' THEN f.volume ELSE 0 END) AS am_peak_volume,
    SUM(CASE WHEN tp.period_type = 'PM Peak' THEN f.volume ELSE 0 END) AS pm_peak_volume
FROM rpt.fact_traffic    AS f
JOIN rpt.dim_date        AS d  ON d.date_key = f.date_key
JOIN rpt.dim_time_period AS tp ON tp.time_bin = f.time_bin
JOIN rpt.dim_site        AS s  ON s.site_id   = f.site_id
WHERE d.is_weekday        = 1
  AND d.is_public_holiday = 0
  AND s.is_active_in_data = 1
GROUP BY f.heading
ORDER BY f.heading;
GO

/* Q5 - Vehicle mix by Austroads Level-1 group. Light = classes 1-2; Heavy = classes 3-12. */
SELECT
    CASE
        WHEN f.vehicle_class IN (1, 2)         THEN 'Light (Austroads 1-2)'
        WHEN f.vehicle_class BETWEEN 3 AND 12  THEN 'Heavy (Austroads 3-12)'
        ELSE 'Unclassified / Other'
    END AS austroads_group,
    SUM(f.volume) AS total_volume,
    CAST(SUM(f.volume) * 100.0 / SUM(SUM(f.volume)) OVER () AS DECIMAL(5,2)) AS share_pct
FROM rpt.fact_traffic AS f
JOIN rpt.dim_site     AS s ON s.site_id = f.site_id
WHERE s.is_active_in_data = 1
GROUP BY
    CASE
        WHEN f.vehicle_class IN (1, 2)         THEN 'Light (Austroads 1-2)'
        WHEN f.vehicle_class BETWEEN 3 AND 12  THEN 'Heavy (Austroads 3-12)'
        ELSE 'Unclassified / Other'
    END
ORDER BY total_volume DESC;
GO

/* Q5b - Class-level detail behind the Light/Heavy rollup (drill-down). */
SELECT
    f.vehicle_class,
    SUM(f.volume) AS total_volume,
    CAST(SUM(f.volume) * 100.0 / SUM(SUM(f.volume)) OVER () AS DECIMAL(5,2)) AS share_pct
FROM rpt.fact_traffic AS f
JOIN rpt.dim_site     AS s ON s.site_id = f.site_id
WHERE s.is_active_in_data = 1
GROUP BY f.vehicle_class
ORDER BY f.vehicle_class;
GO

/* Q6 - Heavy-vehicle share by corridor (freight interpretation; Heavy = Austroads 3-12). */
SELECT
    s.corridor,
    SUM(f.volume) AS total_volume,
    CAST(SUM(CASE WHEN f.vehicle_class BETWEEN 3 AND 12 THEN f.volume ELSE 0 END) * 100.0
         / NULLIF(SUM(f.volume), 0) AS DECIMAL(5,2)) AS heavy_share_pct
FROM rpt.fact_traffic AS f
JOIN rpt.dim_site     AS s ON s.site_id = f.site_id
WHERE s.is_active_in_data = 1
GROUP BY s.corridor
ORDER BY heavy_share_pct DESC;
GO

/* Q7 - Bottleneck candidates: core sites with recurring elevated peak low-speed share. */
WITH peak_proxy AS (
    SELECT
        cp.site,
        SUM(cp.total_vol) AS peak_volume,
        CAST(SUM(cp.low_speed_vol) * 100.0 / NULLIF(SUM(cp.total_vol), 0) AS DECIMAL(5,2))
            AS peak_low_speed_share_pct
    FROM stg.congestion_proxy AS cp
    JOIN rpt.dim_time_period  AS tp ON tp.time_bin = cp.time_bin
    WHERE tp.is_peak = 1
    GROUP BY cp.site
)
SELECT
    s.site_id, s.site_name, s.corridor, s.region,
    pp.peak_volume,
    pp.peak_low_speed_share_pct
FROM peak_proxy   AS pp
JOIN rpt.dim_site AS s ON s.site_id = pp.site
WHERE s.is_core = 1
  AND pp.peak_low_speed_share_pct >= 50      -- majority of peak vehicles below site's own median
ORDER BY pp.peak_low_speed_share_pct DESC, pp.peak_volume DESC;
GO

/* Q8 - Monitoring priority: blend each core site's volume rank and stress rank into a 0-100 score. */
WITH peak_proxy AS (
    SELECT
        cp.site,
        SUM(cp.total_vol) AS peak_volume,
        CAST(SUM(cp.low_speed_vol) * 100.0 / NULLIF(SUM(cp.total_vol), 0) AS DECIMAL(5,2))
            AS peak_low_speed_share_pct
    FROM stg.congestion_proxy AS cp
    JOIN rpt.dim_time_period  AS tp ON tp.time_bin = cp.time_bin
    WHERE tp.is_peak = 1
    GROUP BY cp.site
),
ranked AS (
    SELECT
        site, peak_volume, peak_low_speed_share_pct,
        PERCENT_RANK() OVER (ORDER BY peak_volume)              AS vol_rank,
        PERCENT_RANK() OVER (ORDER BY peak_low_speed_share_pct) AS stress_rank
    FROM peak_proxy
)
SELECT TOP (15)
    s.site_id, s.site_name, s.corridor,
    r.peak_volume,
    r.peak_low_speed_share_pct,
    CAST((r.vol_rank + r.stress_rank) / 2.0 * 100 AS DECIMAL(5,1)) AS monitoring_priority_score
FROM ranked       AS r
JOIN rpt.dim_site AS s ON s.site_id = r.site
WHERE s.is_core = 1
ORDER BY monitoring_priority_score DESC;
GO