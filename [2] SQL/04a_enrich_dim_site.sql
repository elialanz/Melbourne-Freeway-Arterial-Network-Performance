USE MelbourneArterialNetwork;
SET NOCOUNT ON;
GO

/* Fix the 2 sites whose names contained a comma (coords lost on load) */
UPDATE dim.site
SET site_name = 'PFW 160m East of Point Cook Road, near Aviation Road IB Entry (IB)',
    latitude  = -37.8686060,
    longitude = 144.7614900
WHERE site_id = '309';

UPDATE dim.site
SET site_name = 'PFW 160m East of Point Cook Road, near Aviation Road IB Entry (OB)',
    latitude  = -37.8690370,
    longitude = 144.7610500
WHERE site_id = '329';
GO

/* Assign corridor / region; flag special devices */
UPDATE s
SET corridor =
        CASE t.tok
            WHEN 'M1'          THEN 'M1 Monash/West Gate Fwy'
            WHEN 'PFW'         THEN 'Princes Fwy West'
            WHEN 'Tullamarine' THEN 'Tullamarine Fwy'
            WHEN 'M80'         THEN 'M80 Ring Road'
            WHEN 'WGT'         THEN 'West Gate'
            WHEN 'TSA'         THEN 'Special Device'
            WHEN 'Shepherd'    THEN 'Special Device'
            WHEN 'M31'         THEN 'Regional Freeway/Highway'
            WHEN 'M39'         THEN 'Regional Freeway/Highway'
            WHEN 'M79'         THEN 'Regional Freeway/Highway'
            WHEN 'A79'         THEN 'Regional Freeway/Highway'
            WHEN 'A1'          THEN 'Regional Freeway/Highway'
            WHEN 'M8'          THEN 'Regional Freeway/Highway'
            ELSE 'Other Metro Road'
        END,
    region =
        CASE
            WHEN t.tok IN ('TSA','Shepherd')                  THEN 'Special Device'
            WHEN t.tok IN ('M31','M39','M79','A79','A1','M8') THEN 'Regional Victoria'
            ELSE 'Greater Melbourne'
        END,
    notes =
        CASE WHEN t.tok IN ('TSA','Shepherd')
             THEN 'Over-height vehicle detection device - exclude from flow/pressure analysis'
             ELSE notes END
FROM dim.site s
CROSS APPLY (SELECT LEFT(s.site_name, CHARINDEX(' ', s.site_name + ' ') - 1) AS tok) t;
GO

/* Verify grouping + confirm no remaining missing coords */
SELECT corridor, region,
       COUNT(*)                                              AS sites,
       SUM(CASE WHEN is_active_in_data=1 THEN 1 ELSE 0 END)  AS active_sites,
       SUM(CASE WHEN latitude IS NULL OR longitude IS NULL THEN 1 ELSE 0 END) AS missing_coords
FROM dim.site
GROUP BY corridor, region
ORDER BY sites DESC;
GO


-- Restore the live site flag in dim.site by scanning stg.tirtl_raw once, and marking sites that appear in the raw sensor data.
USE MelbourneArterialNetwork;
SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#active') IS NOT NULL DROP TABLE #active;
SELECT DISTINCT site INTO #active FROM stg.tirtl_raw;

UPDATE s SET is_active_in_data = CASE WHEN a.site IS NOT NULL THEN 1 ELSE 0 END
FROM dim.site s
LEFT JOIN #active a ON CAST(a.site AS varchar(50)) = s.site_id;

DROP TABLE #active;

SELECT corridor, region, COUNT(*) AS sites,
       SUM(CASE WHEN is_active_in_data=1 THEN 1 ELSE 0 END) AS active_sites
FROM dim.site GROUP BY corridor, region ORDER BY sites DESC;