USE MelbourneArterialNetwork;
GO

-- Diagnostic: 6am vs free flow (2am), official AM peak (7am), PM peak (4pm) | speed, volume, drop from free flow
WITH base AS (
    SELECT
        r.site,
        s.corridor,
        TRY_CONVERT(INT, LEFT(r.time_bin, CHARINDEX(':', r.time_bin) - 1)) AS hr,
        SUM(CAST(r.volume AS BIGINT)) AS total_vol,
        CAST(SUM(CAST(r.volume AS BIGINT) * sb.speed_mid) * 1.0
             / NULLIF(SUM(CAST(r.volume AS BIGINT)), 0) AS DECIMAL(5,1)) AS wtd_avg_speed
    FROM stg.tirtl_raw AS r
    JOIN dim.speed_bin AS sb ON sb.speed_bin = r.speed_bin
    JOIN dim.site AS s ON s.site_id = r.site
    WHERE r.site IN ('36','146','142','312','230','32')
      AND TRY_CONVERT(INT, LEFT(r.time_bin, CHARINDEX(':', r.time_bin) - 1)) IN (2,6,7,16)
    GROUP BY r.site, s.corridor, TRY_CONVERT(INT, LEFT(r.time_bin, CHARINDEX(':', r.time_bin) - 1))
)
SELECT
    b.site, b.corridor, b.hr,
    b.total_vol,
    b.wtd_avg_speed,
    CAST(b.wtd_avg_speed - ff.wtd_avg_speed AS DECIMAL(5,1)) AS drop_vs_2am
FROM base AS b
JOIN (SELECT site, wtd_avg_speed FROM base WHERE hr = 2) AS ff ON ff.site = b.site
ORDER BY b.site, b.hr;


-- Network wide AM ramp check: weekday non holiday speed + volume by hour 05-08 vs 2am free flow

WITH hourly AS (
    SELECT
        TRY_CONVERT(INT, LEFT(r.time_bin, CHARINDEX(':', r.time_bin) - 1)) AS hr,
        SUM(CAST(r.volume AS BIGINT)) AS total_vol,
        CAST(SUM(CAST(r.volume AS BIGINT) * sb.speed_mid) * 1.0
             / NULLIF(SUM(CAST(r.volume AS BIGINT)), 0) AS DECIMAL(5,1)) AS wtd_avg_speed
    FROM stg.tirtl_raw AS r
    JOIN dim.speed_bin AS sb ON sb.speed_bin = r.speed_bin
    JOIN dim.date AS d ON d.date_key = r.[date]
    WHERE d.is_weekday = 1 AND d.is_public_holiday = 0
      AND TRY_CONVERT(INT, LEFT(r.time_bin, CHARINDEX(':', r.time_bin) - 1)) IN (2,5,6,7,8)
    GROUP BY TRY_CONVERT(INT, LEFT(r.time_bin, CHARINDEX(':', r.time_bin) - 1))
)
SELECT
    h.hr,
    h.total_vol,
    h.wtd_avg_speed,
    CAST(h.wtd_avg_speed - ff.wtd_avg_speed AS DECIMAL(5,1)) AS drop_vs_2am
FROM hourly AS h
CROSS JOIN (SELECT wtd_avg_speed FROM hourly WHERE hr = 2) AS ff
ORDER BY h.hr;


-- Add Early AM Build-up period (06:00-06:45): morning demand onset before the formal AM peak

-- Widen period_type so longer labels fit
ALTER TABLE dim.time_period ALTER COLUMN period_type VARCHAR(30);
GO

UPDATE dim.time_period
SET period_type = 'Early AM Build-up',
    is_peak = 0,
    is_am_peak = 0,
    is_pm_peak = 0
WHERE hour_of_day = 6;
GO

-- Check: period bins, boundaries, and all three peak-flag counts
SELECT period_type,
       COUNT(*) AS bins,
       MIN(time_bin) AS first_bin,
       MAX(time_bin) AS last_bin,
       SUM(CAST(is_peak AS INT))    AS peak_flag_count,
       SUM(CAST(is_am_peak AS INT)) AS am_peak_flag_count,
       SUM(CAST(is_pm_peak AS INT)) AS pm_peak_flag_count
FROM dim.time_period
GROUP BY period_type
ORDER BY MIN(time_bin);