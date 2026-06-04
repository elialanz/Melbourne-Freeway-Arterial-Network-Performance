-- Finalise dimensions: widen PM peak to 15:00-17:45 and flag the 245 core sites (active all 89 days)

USE MelbourneArterialNetwork;
GO

-- 1. Widen PM peak to 15:00-17:45 (3pm plateau matches 4pm)
UPDATE dim.time_period
SET is_pm_peak = 1, is_peak = 1, period_type = 'PM Peak'
WHERE hour_of_day IN (15, 16, 17);
GO

-- 2. Add is_core flag to dim.site
ALTER TABLE dim.site ADD is_core BIT NOT NULL DEFAULT 0;
GO

-- 3. Flag the 245 sites active on all 89 days
UPDATE s
SET s.is_core = 1
FROM dim.site AS s
JOIN (
    SELECT site
    FROM stg.tirtl_raw
    GROUP BY site
    HAVING COUNT(DISTINCT [date]) = 89
) AS c ON c.site = s.site_id;
GO

-- Checks
SELECT period_type, COUNT(*) AS bins, MIN(time_bin) AS first_bin, MAX(time_bin) AS last_bin
FROM dim.time_period
GROUP BY period_type
ORDER BY MIN(time_bin);

SELECT COUNT(*) AS core_sites FROM dim.site WHERE is_core = 1;

-- Speed-bin lookup: 31 actual labels from fact data, parsed to numeric low/high/mid km/hr
DROP TABLE IF EXISTS dim.speed_bin;
GO

CREATE TABLE dim.speed_bin (
    speed_bin   VARCHAR(40)  NOT NULL PRIMARY KEY,
    speed_low   INT          NOT NULL,
    speed_high  INT          NULL,
    speed_mid   DECIMAL(5,1) NOT NULL,
    sort_order  INT          NOT NULL
);
GO

INSERT INTO dim.speed_bin (speed_bin, speed_low, speed_high, speed_mid, sort_order)
SELECT
    d.speed_bin,
    p.speed_low,
    CASE WHEN d.speed_bin LIKE '%+%' THEN NULL ELSE p.speed_low + 5 END,
    p.speed_low + 2.5,
    p.speed_low
FROM (SELECT DISTINCT speed_bin FROM stg.tirtl_raw) AS d
CROSS APPLY (
    SELECT TRY_CONVERT(INT, LEFT(d.speed_bin, PATINDEX('%[^0-9]%', d.speed_bin) - 1)) AS speed_low
) AS p;
GO

-- Checks
SELECT COUNT(*) AS lookup_rows FROM dim.speed_bin;
SELECT COUNT(*) AS bad_parse  FROM dim.speed_bin WHERE speed_low IS NULL;
SELECT * FROM dim.speed_bin ORDER BY sort_order;