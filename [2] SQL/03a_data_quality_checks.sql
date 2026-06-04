/**********************************************************************************
  03_data_quality_checks.sql
  Project : Melbourne Freeway & Arterial Network — Operational Performance &
            Congestion Dashboard
  Database: MelbourneArterialNetwork
  Phase   : 3 — Data Quality Checks
  Purpose : Validate the ~87.5M-row staging table (stg.tirtl_raw) BEFORE cleaning.
            Each check is a standalone result set. Read the inline notes; anything
            unexpected gets recorded in 5_Docs\limitations.md.

  How to run:
   - Execute top to bottom in SSMS. Each PRINT marks the start of a check.
   - These checks scan the full fact staging table. On SQL Server Express with
     ~87.5M rows, individual checks may take ~30s–2min each. That is expected.

  Scope note:
   - Everything here runs against stg.tirtl_raw only (no joins to dimensions),
     so it runs as-is with nothing else loaded.
   - Site coverage / orphan checks (need dim.site) and dim.date holiday-flag
     verification are added in a follow-up block once dim.site is loaded.
**********************************************************************************/

USE MelbourneArterialNetwork;
GO

SET NOCOUNT ON;
GO


/*================================================================================
  CHECK 1 — Load baseline reconciliation
  Confirms the loaded table still matches the Phase-2 handover totals.
================================================================================*/
PRINT '=== CHECK 1: Load baseline reconciliation ===';

SELECT
    COUNT(*)                          AS total_rows,
    SUM(CAST(volume AS bigint))       AS total_observed_vehicles,
    COUNT(DISTINCT source_file)       AS distinct_source_files,
    COUNT(DISTINCT [date])            AS distinct_dates,
    MIN([date])                       AS first_date,
    MAX([date])                       AS last_date,
    COUNT(DISTINCT site)              AS distinct_sites
FROM stg.tirtl_raw;
-- EXPECT: 87,575,163 rows | 1,492,421,312 vehicles | 89 files | 89 dates
--         range 2026-01-01 .. 2026-04-30. Any mismatch = stop and investigate.
GO


/*================================================================================
  CHECK 2 — Per-day profile (short-day / device-outage detector)
  Flags days with unusually few active sites or low volume.
================================================================================*/
PRINT '=== CHECK 2: Per-day profile (spot short days / device outages) ===';

SELECT
    [date],
    DATENAME(weekday, [date])         AS day_name,
    COUNT(*)                          AS row_count,
    COUNT(DISTINCT site)              AS active_sites,
    SUM(CAST(volume AS bigint))       AS observed_vehicles
FROM stg.tirtl_raw
GROUP BY [date]
ORDER BY [date];
-- EXPECT ~283–289 active sites/day. Days well below ~270 = possible outage,
-- short load, or a public holiday (Jan 01 + Apr 05 are in-window). Note which
-- ones and why in limitations.md.
GO


/*================================================================================
  CHECK 3 — Time-bin completeness (must be 96 fifteen-min bins per day)
================================================================================*/
PRINT '=== CHECK 3: Time-bin completeness (expect 96 bins/day) ===';

SELECT
    [date],
    COUNT(DISTINCT time_bin)          AS distinct_time_bins
FROM stg.tirtl_raw
GROUP BY [date]
HAVING COUNT(DISTINCT time_bin) <> 96
ORDER BY [date];
-- EXPECT empty result = every day has the full 96 bins.
-- Any row returned = an incomplete day (note it; it may not be blocking).
GO

PRINT '=== CHECK 3b: time_bin values that do NOT parse to a valid TIME ===';

SELECT DISTINCT time_bin
FROM stg.tirtl_raw
WHERE TRY_CONVERT(time, time_bin) IS NULL;
-- EXPECT empty. Any value here would break the TIME conversion planned for Phase 4.
GO


/*================================================================================
  CHECK 4 — speed_bin inventory (must be 31 distinct, all readable labels)
================================================================================*/
PRINT '=== CHECK 4: speed_bin distinct count ===';

SELECT COUNT(DISTINCT speed_bin) AS distinct_speed_bins
FROM stg.tirtl_raw;
-- EXPECT 31.
GO

PRINT '=== CHECK 4b: speed_bin full inventory (eyeball the 31 labels) ===';

SELECT
    speed_bin,
    COUNT(*)                          AS row_count,
    SUM(CAST(volume AS bigint))       AS observed_vehicles
FROM stg.tirtl_raw
GROUP BY speed_bin
ORDER BY observed_vehicles DESC;
-- Inventory only. Numeric lower/upper bounds (e.g. parse '70km/hr to < 75km/hr'
-- into 70 / 75) are derived in Phase 4 cleaning, not here.
GO


/*================================================================================
  CHECK 5 — vehicle_class distribution (sanity vs sample expectation)
================================================================================*/
PRINT '=== CHECK 5: vehicle_class distribution ===';

SELECT
    vehicle_class,
    COUNT(*)                          AS row_count,
    SUM(CAST(volume AS bigint))       AS observed_vehicles,
    CAST(100.0 * SUM(CAST(volume AS bigint))
         / SUM(SUM(CAST(volume AS bigint))) OVER ()
         AS decimal(5,2))             AS pct_of_vehicles
FROM stg.tirtl_raw
GROUP BY vehicle_class
ORDER BY vehicle_class;
-- EXPECT approx: class 1 (cars) ~90%, class 3 ~6%, heavy (classes 4+) ~1.7%,
-- class 0 (unclassified) ~0.4%. All classes must stay within 0–14.
GO


/*================================================================================
  CHECK 6 — Null / out-of-domain scan
  Load reported 0 failed conversions; this confirms domain validity too.
================================================================================*/
PRINT '=== CHECK 6: Null / out-of-domain scan ===';

SELECT
    SUM(CASE WHEN [date]        IS NULL THEN 1 ELSE 0 END) AS null_date,
    SUM(CASE WHEN time_bin      IS NULL THEN 1 ELSE 0 END) AS null_time_bin,
    SUM(CASE WHEN site          IS NULL THEN 1 ELSE 0 END) AS null_site,
    SUM(CASE WHEN heading       IS NULL THEN 1 ELSE 0 END) AS null_heading,
    SUM(CASE WHEN vehicle_class IS NULL THEN 1 ELSE 0 END) AS null_vehicle_class,
    SUM(CASE WHEN speed_bin     IS NULL THEN 1 ELSE 0 END) AS null_speed_bin,
    SUM(CASE WHEN volume        IS NULL THEN 1 ELSE 0 END) AS null_volume,
    SUM(CASE WHEN heading NOT IN ('N','S','E','W') THEN 1 ELSE 0 END) AS bad_heading,
    SUM(CASE WHEN vehicle_class NOT BETWEEN 0 AND 14 THEN 1 ELSE 0 END) AS bad_vehicle_class,
    SUM(CASE WHEN volume <= 0 THEN 1 ELSE 0 END)           AS nonpositive_volume
FROM stg.tirtl_raw;
-- EXPECT all zeros. Any non-zero count = investigate and document.
GO

PRINT '=== CHECK 6b: volume range + extreme values (eyeball, not auto-fail) ===';

SELECT
    MIN(volume)                       AS min_volume,
    MAX(volume)                       AS max_volume,
    AVG(CAST(volume AS float))        AS avg_volume
FROM stg.tirtl_raw;

SELECT TOP (20)
    [date], time_bin, site, heading, vehicle_class, speed_bin, volume
FROM stg.tirtl_raw
ORDER BY volume DESC;
-- Each row counts vehicles of ONE class in ONE speed bin at ONE site/heading in a
-- 15-min window. Large values are worth eyeballing but are not necessarily errors.
GO


/*================================================================================
  CHECK 7 — Heading mix (expect ~90% E/W given the M1 corridor dominance)
================================================================================*/
PRINT '=== CHECK 7: Heading mix ===';

SELECT
    heading,
    SUM(CAST(volume AS bigint))       AS observed_vehicles,
    CAST(100.0 * SUM(CAST(volume AS bigint))
         / SUM(SUM(CAST(volume AS bigint))) OVER ()
         AS decimal(5,2))             AS pct_of_vehicles
FROM stg.tirtl_raw
GROUP BY heading
ORDER BY observed_vehicles DESC;
GO


/*================================================================================
  CHECK 8 — Empirical peak windows
  Validates the assumed AM 07–09 / PM 16–18 windows directly from the data.
================================================================================*/
PRINT '=== CHECK 8: Volume by hour of day (ALL days) ===';

SELECT
    DATEPART(hour, TRY_CONVERT(time, time_bin)) AS hour_of_day,
    SUM(CAST(volume AS bigint))       AS observed_vehicles
FROM stg.tirtl_raw
GROUP BY DATEPART(hour, TRY_CONVERT(time, time_bin))
ORDER BY hour_of_day;
GO

PRINT '=== CHECK 8b: Volume by hour — TYPICAL WEEKDAYS only (excl. weekends + VIC holidays) ===';

-- Weekend filter is locale-independent: 2025-12-29 is a Monday, so
-- DATEDIFF(day, that Monday, [date]) % 7 gives 0=Mon..5=Sat,6=Sun.
SELECT
    DATEPART(hour, TRY_CONVERT(time, time_bin)) AS hour_of_day,
    SUM(CAST(volume AS bigint))       AS observed_vehicles
FROM stg.tirtl_raw
WHERE (DATEDIFF(day, '2025-12-29', [date]) % 7) NOT IN (5, 6)          -- exclude Sat/Sun
  AND [date] NOT IN ('2026-01-01','2026-01-26','2026-04-03',          -- exclude VIC holidays
                     '2026-04-04','2026-04-05','2026-04-06','2026-04-25')
GROUP BY DATEPART(hour, TRY_CONVERT(time, time_bin))
ORDER BY hour_of_day;
-- This is the cleanest commuter-peak view. Confirm the two humps fall in 07–09
-- and 16–18. If the real peaks differ, adjust dim.time_period BEFORE building KPIs,
-- and record the empirical justification in methodology.md.
GO


/*================================================================================
  CHECK 9 — Confirm in-window VIC public holidays are present in the fact data
  (Flag verification against dim.date is done in the follow-up block.)
================================================================================*/
PRINT '=== CHECK 9: In-window VIC public holidays present in the data ===';

SELECT
    [date],
    DATENAME(weekday, [date])         AS day_name,
    COUNT(DISTINCT site)              AS active_sites,
    SUM(CAST(volume AS bigint))       AS observed_vehicles
FROM stg.tirtl_raw
WHERE [date] IN ('2026-01-01','2026-01-26','2026-04-03',
                 '2026-04-04','2026-04-05','2026-04-06','2026-04-25')
GROUP BY [date]
ORDER BY [date];
-- Only holidays inside the loaded months (Jan + Feb + Apr) appear:
-- Jan 01, Jan 26, Apr 03, Apr 04, Apr 05, Apr 06, Apr 25.
-- These must be excluded from "typical weekday/weekend" peak analysis.
GO


/*================================================================================
  TO BE APPENDED ONCE dim.site IS LOADED (needs tirtl_sites.csv header + dim DDL):
    - CHECK 10: orphan check (data sites NOT in dim.site)  -> expect 0
    - CHECK 11: reference coverage (406 ref sites; how many never appear;
                "core network" = sites active on all 89 days)
    - CHECK 12: dim.date holiday flags match the dates in CHECK 9
================================================================================*/
