-- Rebuild Offpeak Baseline (6AM became an early buildup therefore must be excluded from it)

IF OBJECT_ID('stg.site_offpeak_baseline','U') IS NOT NULL DROP TABLE stg.site_offpeak_baseline;

WITH offpeak AS (
    SELECT r.site, sb.speed_mid, SUM(CAST(r.volume AS BIGINT)) AS vol
    FROM stg.tirtl_raw r
    JOIN dim.time_period tp ON CAST(r.time_bin AS TIME(0)) = tp.time_bin
    JOIN dim.speed_bin sb   ON r.speed_bin = sb.speed_bin
    WHERE tp.period_type = 'Off-peak'
    GROUP BY r.site, sb.speed_mid
),
cum AS (
    SELECT site, speed_mid,
           SUM(vol) OVER (PARTITION BY site ORDER BY speed_mid ROWS UNBOUNDED PRECEDING) AS cum_vol,
           SUM(vol) OVER (PARTITION BY site) AS tot_vol
    FROM offpeak
)
SELECT site,
       MIN(speed_mid) AS baseline_median_speed,
       MAX(tot_vol)   AS offpeak_volume
INTO stg.site_offpeak_baseline
FROM cum
WHERE cum_vol >= tot_vol / 2.0
GROUP BY site;

--  Run again congestion proxy on the refreshed baseline

IF OBJECT_ID('stg.congestion_proxy','U') IS NOT NULL DROP TABLE stg.congestion_proxy;

SELECT r.site,
       CAST(r.time_bin AS TIME(0)) AS time_bin,
       SUM(CAST(r.volume AS BIGINT)) AS total_vol,
       SUM(CASE WHEN sb.speed_mid < b.baseline_median_speed THEN CAST(r.volume AS BIGINT) ELSE 0 END) AS low_speed_vol,
       CAST(100.0 * SUM(CASE WHEN sb.speed_mid < b.baseline_median_speed THEN r.volume ELSE 0 END)
                  / NULLIF(SUM(r.volume), 0) AS DECIMAL(5,2)) AS low_speed_share_pct
INTO stg.congestion_proxy
FROM stg.tirtl_raw r
JOIN dim.speed_bin sb            ON r.speed_bin = sb.speed_bin
JOIN stg.site_offpeak_baseline b ON r.site = b.site
GROUP BY r.site, CAST(r.time_bin AS TIME(0));

-- Validation (confirm only the intended change happened)

SELECT COUNT(*) AS sites, MIN(baseline_median_speed) AS min_med, MAX(baseline_median_speed) AS max_med,
       AVG(baseline_median_speed) AS avg_med, MIN(offpeak_volume) AS min_offpeak_vol
FROM stg.site_offpeak_baseline;

SELECT COUNT(*) AS rows_out, AVG(low_speed_share_pct) AS avg_share,
       MIN(low_speed_share_pct) AS min_share, MAX(low_speed_share_pct) AS max_share
FROM stg.congestion_proxy;