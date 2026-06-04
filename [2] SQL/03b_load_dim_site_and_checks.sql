USE MelbourneArterialNetwork;
SET NOCOUNT ON;
GO

/* dim.site load + site checks (single-scan version) */

-- Reload dim.site (406 rows, instant)
IF OBJECT_ID('tempdb..#load') IS NOT NULL DROP TABLE #load;
CREATE TABLE #load (
    site             varchar(50),
    site_description varchar(200),
    latitude         varchar(50),
    longitude        varchar(50)
);

BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_sites.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);

TRUNCATE TABLE dim.site;

INSERT INTO dim.site (site_id, site_name, latitude, longitude)
SELECT
    LTRIM(RTRIM(site)),
    NULLIF(LTRIM(RTRIM(site_description)), ''),
    TRY_CONVERT(decimal(10,7), latitude),
    TRY_CONVERT(decimal(10,7), REPLACE(longitude, CHAR(13), ''))
FROM #load;

DROP TABLE #load;
GO

-- ONE pass over the fact table: how many days each site was active
IF OBJECT_ID('tempdb..#site_activity') IS NOT NULL DROP TABLE #site_activity;
SELECT site, COUNT(DISTINCT [date]) AS days_active
INTO #site_activity
FROM stg.tirtl_raw
GROUP BY site;
GO

-- Flag active sites from the tiny summary (instant)
UPDATE s
SET is_active_in_data = CASE WHEN a.site IS NOT NULL THEN 1 ELSE 0 END
FROM dim.site s
LEFT JOIN #site_activity a ON CAST(a.site AS varchar(50)) = s.site_id;
GO

-- Check 10: active sites missing from reference (expect 0)
SELECT COUNT(*) AS orphan_sites
FROM #site_activity a
LEFT JOIN dim.site s ON CAST(a.site AS varchar(50)) = s.site_id
WHERE s.site_id IS NULL;

-- Check 11: reference coverage + core network
SELECT
    (SELECT COUNT(*) FROM dim.site)                           AS ref_sites,
    (SELECT COUNT(*) FROM dim.site WHERE is_active_in_data=1) AS active_sites,
    (SELECT COUNT(*) FROM dim.site WHERE is_active_in_data=0) AS dormant_sites,
    (SELECT COUNT(*) FROM #site_activity WHERE days_active=89) AS core_sites_all_89_days;

-- Check 12: holiday flags
SELECT date_key, day_of_week_name, is_public_holiday, public_holiday_name, is_in_data
FROM dim.date
WHERE date_key IN ('2026-01-01','2026-01-26','2026-04-03',
                   '2026-04-04','2026-04-05','2026-04-06','2026-04-25')
ORDER BY date_key;

-- Corridor vocabulary peek
SELECT LEFT(site_name, CHARINDEX(' ', site_name + ' ') - 1) AS lead_token,
       COUNT(*) AS sites
FROM dim.site
GROUP BY LEFT(site_name, CHARINDEX(' ', site_name + ' ') - 1)
ORDER BY sites DESC;

DROP TABLE #site_activity;
GO

-- Decode tokens + check for lost coordinates
SELECT
    LEFT(site_name, CHARINDEX(' ', site_name + ' ') - 1) AS lead_token,
    COUNT(*) AS sites,
    MIN(site_name) AS example_a,
    MAX(site_name) AS example_b,
    SUM(CASE WHEN latitude IS NULL OR longitude IS NULL THEN 1 ELSE 0 END) AS missing_coords
FROM dim.site
GROUP BY LEFT(site_name, CHARINDEX(' ', site_name + ' ') - 1)
ORDER BY sites DESC;