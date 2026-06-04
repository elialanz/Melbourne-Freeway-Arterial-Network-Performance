-- Build per site off peak baseline: volume weighted median speed per site from off peak hours (the site relative congestion reference)

USE MelbourneArterialNetwork;
GO

-- Heavy single pass: off-peak volume by site x speed_bin (off-peak = hour <7 or >=18, matches dim.time_period)
DROP TABLE IF EXISTS #offpeak_dist;

SELECT
    r.site,
    r.speed_bin,
    SUM(CAST(r.volume AS BIGINT)) AS vol
INTO #offpeak_dist
FROM stg.tirtl_raw AS r
WHERE TRY_CONVERT(INT, LEFT(r.time_bin, CHARINDEX(':', r.time_bin) - 1)) < 7
   OR TRY_CONVERT(INT, LEFT(r.time_bin, CHARINDEX(':', r.time_bin) - 1)) >= 18
GROUP BY r.site, r.speed_bin;
GO

-- Per-site off-peak baseline = volume-weighted median speed from the off-peak distribution
DROP TABLE IF EXISTS stg.site_offpeak_baseline;

WITH dist AS (
    SELECT
        d.site,
        sb.speed_mid,
        d.vol,
        SUM(d.vol) OVER (PARTITION BY d.site ORDER BY sb.speed_mid ROWS UNBOUNDED PRECEDING) AS cum_vol,
        SUM(d.vol) OVER (PARTITION BY d.site) AS total_vol
    FROM #offpeak_dist AS d
    JOIN dim.speed_bin AS sb ON sb.speed_bin = d.speed_bin
),
median_bin AS (
    SELECT site, speed_mid, total_vol,
           ROW_NUMBER() OVER (PARTITION BY site ORDER BY speed_mid) AS rn
    FROM dist
    WHERE cum_vol >= total_vol / 2.0
)
SELECT
    site,
    CAST(speed_mid AS DECIMAL(5,1)) AS baseline_median_speed,
    total_vol AS offpeak_volume
INTO stg.site_offpeak_baseline
FROM median_bin
WHERE rn = 1;
GO

-- Checks
SELECT COUNT(*) AS baseline_sites FROM stg.site_offpeak_baseline;
SELECT MIN(baseline_median_speed) AS min_med, MAX(baseline_median_speed) AS max_med,
       AVG(baseline_median_speed) AS avg_med, MIN(offpeak_volume) AS min_offpeak_vol
FROM stg.site_offpeak_baseline;
SELECT TOP 15 b.site, s.corridor, b.baseline_median_speed, b.offpeak_volume
FROM stg.site_offpeak_baseline AS b
JOIN dim.site AS s ON s.site_id = b.site
ORDER BY b.baseline_median_speed ASC;

-- Congestion proxy: per site x time bin, low speed share vs site baseline + volume (the operational pressure signal)

DROP TABLE IF EXISTS #site_time_dist;

SELECT
    r.site,
    r.time_bin,
    sb.speed_mid,
    SUM(CAST(r.volume AS BIGINT)) AS vol
INTO #site_time_dist
FROM stg.tirtl_raw AS r
JOIN dim.speed_bin AS sb ON sb.speed_bin = r.speed_bin
GROUP BY r.site, r.time_bin, sb.speed_mid;
GO

DROP TABLE IF EXISTS stg.congestion_proxy;

SELECT
    d.site,
    d.time_bin,
    SUM(d.vol) AS total_vol,
    SUM(CASE WHEN d.speed_mid < b.baseline_median_speed THEN d.vol ELSE 0 END) AS low_speed_vol,
    CAST(100.0 * SUM(CASE WHEN d.speed_mid < b.baseline_median_speed THEN d.vol ELSE 0 END)
         / NULLIF(SUM(d.vol), 0) AS DECIMAL(5,2)) AS low_speed_share_pct
INTO stg.congestion_proxy
FROM #site_time_dist AS d
JOIN stg.site_offpeak_baseline AS b ON b.site = d.site
GROUP BY d.site, d.time_bin;
GO

-- Checks
SELECT COUNT(*) AS proxy_rows, COUNT(DISTINCT site) AS sites FROM stg.congestion_proxy;
SELECT MIN(low_speed_share_pct) AS min_share, MAX(low_speed_share_pct) AS max_share,
       AVG(low_speed_share_pct) AS avg_share FROM stg.congestion_proxy;
-- Highest-pressure site x time combinations (busy AND slow), core sites only
SELECT TOP 20 p.site, s.corridor, p.time_bin, p.total_vol, p.low_speed_share_pct
FROM stg.congestion_proxy AS p
JOIN dim.site AS s ON s.site_id = p.site
WHERE s.is_core = 1 AND p.total_vol > 1000
ORDER BY p.low_speed_share_pct DESC, p.total_vol DESC;