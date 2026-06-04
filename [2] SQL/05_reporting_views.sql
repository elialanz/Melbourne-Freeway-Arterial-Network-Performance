-- Compact reporting layer for Power BI

-- Reporting schema (safe if it already exists)
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'rpt') EXEC('CREATE SCHEMA rpt');
GO

-- Aggregated fact: collapses 31 speed bins; grain = date x time x site x heading x class
DROP TABLE IF EXISTS rpt.fact_traffic;
SELECT
    r.[date]                              AS date_key,
    CAST(r.time_bin AS TIME(0))           AS time_bin,
    r.site                                AS site_id,
    r.heading,
    r.vehicle_class,
    SUM(CAST(r.volume AS BIGINT))                  AS volume,
    SUM(CAST(r.volume AS BIGINT) * sb.speed_mid)   AS speed_volume_product
INTO rpt.fact_traffic
FROM stg.tirtl_raw AS r
JOIN dim.speed_bin AS sb ON sb.speed_bin = r.speed_bin
GROUP BY r.[date], CAST(r.time_bin AS TIME(0)), r.site, r.heading, r.vehicle_class;
GO

-- Speed distribution kept separate (fact drops speed): site x period x speed_bin
DROP TABLE IF EXISTS rpt.site_speed_distribution;
SELECT
    r.site AS site_id,
    tp.period_type,
    r.speed_bin,
    SUM(CAST(r.volume AS BIGINT)) AS volume
INTO rpt.site_speed_distribution
FROM stg.tirtl_raw AS r
JOIN dim.time_period AS tp ON tp.time_bin = CAST(r.time_bin AS TIME(0))
GROUP BY r.site, tp.period_type, r.speed_bin;
GO

SELECT COUNT(*) AS fact_rows, SUM(volume) AS total_volume,
       COUNT(DISTINCT date_key) AS days, COUNT(DISTINCT site_id) AS sites
FROM rpt.fact_traffic;
EXEC sp_spaceused 'rpt.fact_traffic';
EXEC sp_spaceused;
GO

----------- DIM VIEWS -----------

CREATE OR ALTER VIEW rpt.dim_site AS
SELECT site_id, site_name, corridor, region, latitude, longitude,
       is_active_in_data, is_core, notes
FROM dim.site;
GO

CREATE OR ALTER VIEW rpt.dim_date AS
SELECT date_key, is_weekday, is_weekend, is_public_holiday, public_holiday_name,
       day_type, is_in_data,
       MONTH(date_key)             AS month_no,
       DATENAME(MONTH, date_key)   AS month_name,
       DATENAME(WEEKDAY, date_key) AS day_name,
       CASE WHEN is_public_holiday = 1 THEN 'Public Holiday'
            WHEN is_weekend = 1 THEN 'Weekend' ELSE 'Weekday' END AS day_class
FROM dim.date;
GO

CREATE OR ALTER VIEW rpt.dim_time_period AS
SELECT time_bin, hour_of_day, time_label, period_type, is_peak, is_am_peak, is_pm_peak
FROM dim.time_period;
GO

CREATE OR ALTER VIEW rpt.dim_vehicle_class AS
SELECT * FROM dim.vehicle_class;
GO

CREATE OR ALTER VIEW rpt.dim_speed_bin AS
SELECT speed_bin, speed_low, speed_high, speed_mid, sort_order
FROM dim.speed_bin;
GO

-- ===================== SUMMARY VIEWS =====================

-- Site pressure: volume, peak split, weighted speed + peak low-speed share (per site)
CREATE OR ALTER VIEW rpt.view_site_pressure_summary AS
SELECT
    s.site_id, s.site_name, s.corridor, s.region, s.latitude, s.longitude, s.is_core,
    v.total_volume, v.am_peak_volume, v.pm_peak_volume, v.peak_volume,
    CAST(v.spv / NULLIF(v.total_volume, 0) AS DECIMAL(5,1)) AS wtd_avg_speed,
    cp.peak_low_speed_share
FROM dim.site AS s
JOIN (
    SELECT f.site_id,
        SUM(f.volume) AS total_volume,
        SUM(CASE WHEN tp.is_am_peak = 1 THEN f.volume ELSE 0 END) AS am_peak_volume,
        SUM(CASE WHEN tp.is_pm_peak = 1 THEN f.volume ELSE 0 END) AS pm_peak_volume,
        SUM(CASE WHEN tp.is_peak = 1 THEN f.volume ELSE 0 END) AS peak_volume,
        SUM(f.speed_volume_product) AS spv
    FROM rpt.fact_traffic AS f
    JOIN dim.time_period AS tp ON tp.time_bin = f.time_bin
    GROUP BY f.site_id
) AS v ON v.site_id = s.site_id
LEFT JOIN (
    SELECT p.site,
        CAST(100.0 * SUM(CASE WHEN tp.is_peak = 1 THEN p.low_speed_vol ELSE 0 END)
                   / NULLIF(SUM(CASE WHEN tp.is_peak = 1 THEN p.total_vol ELSE 0 END), 0) AS DECIMAL(5,2)) AS peak_low_speed_share
    FROM stg.congestion_proxy AS p
    JOIN dim.time_period AS tp ON tp.time_bin = p.time_bin
    GROUP BY p.site
) AS cp ON cp.site = s.site_id;
GO

-- Direction performance: corridor x heading x period (the tidal W-am / E-pm story)
CREATE OR ALTER VIEW rpt.view_direction_performance AS
SELECT s.corridor, f.heading, tp.period_type,
       SUM(f.volume) AS total_volume,
       CAST(SUM(f.speed_volume_product) / NULLIF(SUM(f.volume), 0) AS DECIMAL(5,1)) AS wtd_avg_speed
FROM rpt.fact_traffic AS f
JOIN dim.site AS s ON s.site_id = f.site_id
JOIN dim.time_period AS tp ON tp.time_bin = f.time_bin
GROUP BY s.corridor, f.heading, tp.period_type;
GO

-- Peak period: period x day_class (holidays forced separate from weekday/weekend)
CREATE OR ALTER VIEW rpt.view_peak_period_summary AS
SELECT tp.period_type,
       CASE WHEN d.is_public_holiday = 1 THEN 'Public Holiday'
            WHEN d.is_weekend = 1 THEN 'Weekend' ELSE 'Weekday' END AS day_class,
       SUM(f.volume) AS total_volume,
       CAST(SUM(f.speed_volume_product) / NULLIF(SUM(f.volume), 0) AS DECIMAL(5,1)) AS wtd_avg_speed
FROM rpt.fact_traffic AS f
JOIN dim.time_period AS tp ON tp.time_bin = f.time_bin
JOIN dim.date AS d ON d.date_key = f.date_key
GROUP BY tp.period_type,
       CASE WHEN d.is_public_holiday = 1 THEN 'Public Holiday'
            WHEN d.is_weekend = 1 THEN 'Weekend' ELSE 'Weekday' END;
GO

-- Vehicle mix: corridor x class volume only (Heavy share KPI deferred to Phase 6)
CREATE OR ALTER VIEW rpt.view_vehicle_mix_summary AS
SELECT s.corridor, f.vehicle_class, SUM(f.volume) AS total_volume
FROM rpt.fact_traffic AS f
JOIN dim.site AS s ON s.site_id = f.site_id
GROUP BY s.corridor, f.vehicle_class;
GO

-- Speed distribution (ADDED beyond the five): site/corridor x period x speed_bin
CREATE OR ALTER VIEW rpt.view_speed_distribution AS
SELECT d.site_id, s.corridor, d.period_type, d.speed_bin,
       sb.speed_mid, sb.sort_order, d.volume
FROM rpt.site_speed_distribution AS d
JOIN dim.speed_bin AS sb ON sb.speed_bin = d.speed_bin
JOIN dim.site AS s ON s.site_id = d.site_id;
GO

-- Congestion profile (full proxy exposed): site x time bin for the Page 3 heatmap
CREATE OR ALTER VIEW rpt.view_congestion_profile AS
SELECT p.site AS site_id, s.corridor, s.is_core,
       p.time_bin, tp.time_label, tp.period_type, tp.is_peak,
       p.total_vol, p.low_speed_vol, p.low_speed_share_pct
FROM stg.congestion_proxy AS p
JOIN dim.site AS s ON s.site_id = p.site
JOIN dim.time_period AS tp ON tp.time_bin = p.time_bin;
GO

-- Bottleneck candidates: core sites, peak bins, busy AND slow, ranked
CREATE OR ALTER VIEW rpt.view_bottleneck_candidates AS
SELECT TOP 100 p.site AS site_id, s.site_name, s.corridor, s.region,
       p.time_bin, tp.time_label, tp.period_type,
       p.total_vol, p.low_speed_share_pct
FROM stg.congestion_proxy AS p
JOIN dim.site AS s ON s.site_id = p.site
JOIN dim.time_period AS tp ON tp.time_bin = p.time_bin
WHERE s.is_core = 1 AND tp.is_peak = 1 AND p.total_vol > 1000
ORDER BY p.low_speed_share_pct DESC, p.total_vol DESC;
GO

-- ===================== RECONCILIATION =====================
SELECT SUM(total_volume) AS sps_total FROM rpt.view_site_pressure_summary;
SELECT SUM(total_volume) AS mix_total FROM rpt.view_vehicle_mix_summary;
SELECT SUM(volume)       AS spd_total FROM rpt.site_speed_distribution;