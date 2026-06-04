-- STEP 0 - Create the database (only if it doesn't already exist)

USE master;
GO

IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = N'MelbourneArterialNetwork')
BEGIN
    CREATE DATABASE MelbourneArterialNetwork;
END
GO

USE MelbourneArterialNetwork;
GO


/*
    STEP 1 — Create schemas
    - stg : staging layer (raw, untransformed loads)
    - dim : dimension tables (sites, dates, time periods, vehicle classes)
    - fct : fact tables (added in script 04)
    - rpt : reporting views consumed by Power BI (added in script 05)
*/

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'stg') EXEC('CREATE SCHEMA stg');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'dim') EXEC('CREATE SCHEMA dim');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'fct') EXEC('CREATE SCHEMA fct');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'rpt') EXEC('CREATE SCHEMA rpt');
GO


/* ============================================================================
   STAGING LAYER
   ============================================================================ */

/* ----------------------------------------------------------------------------
   stg.tirtl_raw
   ----------------
   Mirrors the TIRTL daily CSV schema exactly. No transformations applied.
   Column types are chosen to be permissive on load (VARCHAR for fields that
   may have unexpected values) then validated in 03_data_quality_checks.sql.

   Grain: one row per (date, time_bin, site, heading, vehicle_class, speed_bin)
   Volume per file: ~600K–1.1M rows. Total expected: ~70–90M rows across
   ~89 daily CSVs from Jan, Feb, Apr 2026.
   ---------------------------------------------------------------------------- */
DROP TABLE IF EXISTS stg.tirtl_raw;
GO

CREATE TABLE stg.tirtl_raw (
    date            DATE         NOT NULL,   -- ISO format in source (2026-01-01), loads cleanly
    time_bin        VARCHAR(10)  NOT NULL,   -- source is "0:00" (no leading zero) — load as
                                             --   text, convert to TIME in cleaning script 04
    site            VARCHAR(50)  NOT NULL,   -- TIRTL site ID, joins to dim.site
    heading         CHAR(1)      NOT NULL,   -- N, S, E, W
    vehicle_class   TINYINT      NOT NULL,   -- Austroads class 0–14 (0 = unclassified)
    speed_bin       VARCHAR(30)  NOT NULL,   -- source format: "60km/hr to < 65km/hr" /
                                             --   "150km/hr +" — parsed in cleaning script 04
    volume          INT          NOT NULL,   -- observed vehicle count
    -- Load metadata for traceability
    source_file     VARCHAR(200) NULL,
    loaded_at       DATETIME2(0) NOT NULL CONSTRAINT DF_tirtl_raw_loaded_at DEFAULT SYSDATETIME()
);
GO

-- Index to support the dimensional joins and date filtering later.
-- We index AFTER the BULK INSERT in script 02 for faster loads. The CREATE
-- statement below is here for reference only; commented out intentionally.

-- CREATE INDEX IX_tirtl_raw_date_site ON stg.tirtl_raw (date, site);
-- CREATE INDEX IX_tirtl_raw_site ON stg.tirtl_raw (site);


/* ============================================================================
   DIMENSION LAYER
   ============================================================================ */

/* ----------------------------------------------------------------------------
   dim.site
   ---------
   One row per TIRTL site. Sourced from tirtl_sites.csv.
   The corridor column is derived in script 04 based on the road_name pattern
   (M1 Monash, M2, M3, M80, Tullamarine, EastLink, Princes Hwy, etc.). This
   makes it possible to slice the dashboard by major freeway corridor.

   Region (Greater Melbourne vs Regional VIC) is also derived in script 04
   using a lat/long bounding box for Greater Melbourne.
   ---------------------------------------------------------------------------- */
DROP TABLE IF EXISTS dim.site;
GO

CREATE TABLE dim.site (
    site_id         VARCHAR(50)  NOT NULL PRIMARY KEY,
    site_name       NVARCHAR(200) NULL,        -- as published in tirtl_sites.csv
    road_name       NVARCHAR(200) NULL,        -- e.g. "M1 Monash Freeway"
    corridor        NVARCHAR(100) NULL,        -- derived: "M1 Monash", "M80",
                                               --   "Tullamarine", "Princes Hwy", etc.
    latitude        DECIMAL(10, 7) NULL,
    longitude       DECIMAL(10, 7) NULL,
    region          NVARCHAR(50)  NULL,        -- derived: "Greater Melbourne" / "Regional VIC"
    is_active_in_data BIT          NULL,       -- flagged during QA: site appears in fact data
    notes           NVARCHAR(500) NULL
);
GO


/* ----------------------------------------------------------------------------
   dim.date
   ---------
   One row per date in the analysis window. Populated below.

   Analysis window covers: Jan 1 – Apr 30 2026 inclusive (120 days), spanning
   the three data months (Jan, Feb, Apr) plus Mar (no data, but kept in the
   dimension so the gap is visible in the dashboard and documented as a
   limitation in docs/limitations.md).

   Public holidays sourced from Business Victoria 2026 official schedule:
     https://business.vic.gov.au/business-information/public-holidays/victorian-public-holidays-2026
   ---------------------------------------------------------------------------- */
DROP TABLE IF EXISTS dim.date;
GO

CREATE TABLE dim.date (
    date_key            DATE         NOT NULL PRIMARY KEY,
    year                SMALLINT     NOT NULL,
    quarter             TINYINT      NOT NULL,
    month_num           TINYINT      NOT NULL,
    month_name          VARCHAR(10)  NOT NULL,
    month_short         CHAR(3)      NOT NULL,
    day_of_month        TINYINT      NOT NULL,
    day_of_week_num     TINYINT      NOT NULL,   -- 1 = Mon, 7 = Sun (ISO)
    day_of_week_name    VARCHAR(10)  NOT NULL,
    is_weekday          BIT          NOT NULL,
    is_weekend          BIT          NOT NULL,
    is_public_holiday   BIT          NOT NULL,
    public_holiday_name VARCHAR(100) NULL,
    day_type            VARCHAR(20)  NOT NULL,   -- "Weekday", "Weekend", "Public Holiday"
    week_of_year        TINYINT      NOT NULL,
    is_in_data          BIT          NOT NULL    -- 1 = data available, 0 = March gap
);
GO

-- Populate dim.date for Jan 1 – Apr 30 2026 (120 days)
;WITH date_seq AS (
    SELECT CAST('2026-01-01' AS DATE) AS d
    UNION ALL
    SELECT DATEADD(DAY, 1, d) FROM date_seq WHERE d < '2026-04-30'
)
INSERT INTO dim.date (
    date_key, year, quarter, month_num, month_name, month_short,
    day_of_month, day_of_week_num, day_of_week_name,
    is_weekday, is_weekend, is_public_holiday, public_holiday_name, day_type,
    week_of_year, is_in_data
)
SELECT
    d                                                                   AS date_key,
    YEAR(d)                                                             AS year,
    DATEPART(QUARTER, d)                                                AS quarter,
    MONTH(d)                                                            AS month_num,
    DATENAME(MONTH, d)                                                  AS month_name,
    LEFT(DATENAME(MONTH, d), 3)                                         AS month_short,
    DAY(d)                                                              AS day_of_month,
    ((DATEPART(WEEKDAY, d) + @@DATEFIRST - 2) % 7) + 1                  AS day_of_week_num,
    DATENAME(WEEKDAY, d)                                                AS day_of_week_name,
    CASE WHEN DATENAME(WEEKDAY, d) IN ('Saturday','Sunday') THEN 0 ELSE 1 END AS is_weekday,
    CASE WHEN DATENAME(WEEKDAY, d) IN ('Saturday','Sunday') THEN 1 ELSE 0 END AS is_weekend,
    -- Public holiday flag for VIC 2026 (within Jan–Apr window)
    CASE WHEN d IN ('2026-01-01','2026-01-26',
                    '2026-04-03','2026-04-04','2026-04-05','2026-04-06',
                    '2026-04-25')
         THEN 1 ELSE 0 END                                              AS is_public_holiday,
    CASE d
        WHEN '2026-01-01' THEN 'New Year''s Day'
        WHEN '2026-01-26' THEN 'Australia Day'
        WHEN '2026-04-03' THEN 'Good Friday'
        WHEN '2026-04-04' THEN 'Saturday before Easter Sunday'
        WHEN '2026-04-05' THEN 'Easter Sunday'
        WHEN '2026-04-06' THEN 'Easter Monday'
        WHEN '2026-04-25' THEN 'ANZAC Day'
        ELSE NULL
    END                                                                 AS public_holiday_name,
    -- day_type: public holiday takes precedence over weekday/weekend label
    CASE
        WHEN d IN ('2026-01-01','2026-01-26',
                   '2026-04-03','2026-04-04','2026-04-05','2026-04-06',
                   '2026-04-25')
            THEN 'Public Holiday'
        WHEN DATENAME(WEEKDAY, d) IN ('Saturday','Sunday') THEN 'Weekend'
        ELSE 'Weekday'
    END                                                                 AS day_type,
    DATEPART(ISO_WEEK, d)                                               AS week_of_year,
    -- March 2026 has no data per project scope; flag accordingly
    CASE WHEN MONTH(d) = 3 THEN 0 ELSE 1 END                            AS is_in_data
FROM date_seq
OPTION (MAXRECURSION 200);
GO


/* ----------------------------------------------------------------------------
   dim.time_period
   ----------------
   One row per 15-minute bin (96 bins total: 00:00, 00:15, ..., 23:45).

   Peak windows follow the project brief defaults:
     AM Peak   : 07:00 – 09:00
     PM Peak   : 16:00 – 18:00
     Inter-peak: 09:00 – 16:00
     Off-peak  : 18:00 – 07:00
   These defaults will be validated against the actual data in script 03 —
   if observed AM/PM peak windows are different, this dimension can be
   re-populated with adjusted boundaries. The current defaults are typical for
   Melbourne arterial/freeway operational reporting.
   ---------------------------------------------------------------------------- */
DROP TABLE IF EXISTS dim.time_period;
GO

CREATE TABLE dim.time_period (
    time_bin        TIME(0)     NOT NULL PRIMARY KEY,
    hour_of_day     TINYINT     NOT NULL,
    minute_of_hour  TINYINT     NOT NULL,
    time_label      VARCHAR(11) NOT NULL,   -- e.g. "07:00–07:15"
    period_type     VARCHAR(15) NOT NULL,   -- AM Peak / PM Peak / Inter-peak / Off-peak
    is_am_peak      BIT         NOT NULL,
    is_pm_peak      BIT         NOT NULL,
    is_peak         BIT         NOT NULL    -- 1 if AM or PM peak
);
GO

-- Populate the 96 fifteen-minute bins
;WITH time_seq AS (
    SELECT CAST('00:00' AS TIME(0)) AS t
    UNION ALL
    SELECT DATEADD(MINUTE, 15, t) FROM time_seq
    WHERE t < '23:45'
)
INSERT INTO dim.time_period (
    time_bin, hour_of_day, minute_of_hour, time_label,
    period_type, is_am_peak, is_pm_peak, is_peak
)
SELECT
    t                                                                  AS time_bin,
    DATEPART(HOUR, t)                                                  AS hour_of_day,
    DATEPART(MINUTE, t)                                                AS minute_of_hour,
    CONVERT(VARCHAR(5), t, 108) + '–' +
        CONVERT(VARCHAR(5), DATEADD(MINUTE, 15, t), 108)               AS time_label,
    CASE
        WHEN DATEPART(HOUR, t) >= 7  AND DATEPART(HOUR, t) < 9   THEN 'AM Peak'
        WHEN DATEPART(HOUR, t) >= 16 AND DATEPART(HOUR, t) < 18  THEN 'PM Peak'
        WHEN DATEPART(HOUR, t) >= 9  AND DATEPART(HOUR, t) < 16  THEN 'Inter-peak'
        ELSE 'Off-peak'
    END                                                                AS period_type,
    CASE WHEN DATEPART(HOUR, t) >= 7  AND DATEPART(HOUR, t) < 9
         THEN 1 ELSE 0 END                                             AS is_am_peak,
    CASE WHEN DATEPART(HOUR, t) >= 16 AND DATEPART(HOUR, t) < 18
         THEN 1 ELSE 0 END                                             AS is_pm_peak,
    CASE WHEN (DATEPART(HOUR, t) >= 7  AND DATEPART(HOUR, t) < 9)
           OR (DATEPART(HOUR, t) >= 16 AND DATEPART(HOUR, t) < 18)
         THEN 1 ELSE 0 END                                             AS is_peak
FROM time_seq
OPTION (MAXRECURSION 100);
GO


/* ----------------------------------------------------------------------------
   dim.vehicle_class
   ------------------
   Maps the Austroads vehicle classes present in the data (0–14) to readable
   labels and a higher-level grouping (Light / Light Commercial / Heavy) for
   dashboard slicing. Class 0 = unclassified (detector could not categorise);
   confirmed present in the source (~0.4% of volume). Class 15 is not used in
   this dataset.

   Austroads classification ref:
     https://austroads.com.au/publications/asset-management/agam-t005-19/media/AGAM-T05-19_Austroads-Vehicle-Classification_v3.pdf
   ---------------------------------------------------------------------------- */
DROP TABLE IF EXISTS dim.vehicle_class;
GO

CREATE TABLE dim.vehicle_class (
    vehicle_class       TINYINT      NOT NULL PRIMARY KEY,
    class_description   VARCHAR(100) NOT NULL,
    vehicle_group       VARCHAR(20)  NOT NULL,  -- Light / Light Commercial / Heavy
    is_heavy            BIT          NOT NULL,  -- 1 if class >= 4 (freight-relevant)
    sort_order          TINYINT      NOT NULL
);
GO

INSERT INTO dim.vehicle_class (vehicle_class, class_description, vehicle_group, is_heavy, sort_order)
VALUES
    (0,  'Unclassified (detector could not categorise)', 'Unclassified', 0,  0),
    (1,  'Short (Cars, motorcycles)',          'Light',             0,  1),
    (2,  'Short towing (Car + trailer)',       'Light',             0,  2),
    (3,  'Two-axle truck or bus',              'Light Commercial',  0,  3),
    (4,  'Three-axle truck or bus',            'Heavy',             1,  4),
    (5,  'Four-axle truck',                    'Heavy',             1,  5),
    (6,  'Three-axle articulated',             'Heavy',             1,  6),
    (7,  'Four-axle articulated',              'Heavy',             1,  7),
    (8,  'Five-axle articulated',              'Heavy',             1,  8),
    (9,  'Six-axle articulated',               'Heavy',             1,  9),
    (10, 'B-double',                           'Heavy',             1, 10),
    (11, 'Double road train',                  'Heavy',             1, 11),
    (12, 'Triple road train',                  'Heavy',             1, 12),
    (13, 'Heavy (other)',                      'Heavy',             1, 13),
    (14, 'Heavy (other)',                      'Heavy',             1, 14);
GO


/* ============================================================================
   VERIFICATION
   Run the queries below to confirm all tables were created and dimensions
   populated as expected.
   ============================================================================ */

-- 1. All 5 tables exist
SELECT
    s.name + '.' + t.name AS table_name,
    p.rows                AS row_count
FROM sys.tables t
INNER JOIN sys.schemas s   ON t.schema_id = s.schema_id
INNER JOIN sys.partitions p ON t.object_id = p.object_id AND p.index_id IN (0,1)
WHERE s.name IN ('stg','dim','fct','rpt')
ORDER BY s.name, t.name;

-- Expected:
--   dim.date         → 120 rows
--   dim.time_period  → 96 rows
--   dim.vehicle_class→ 15 rows (classes 0 through 14)
--   dim.site         → 0 rows (loaded in script 02)
--   stg.tirtl_raw    → 0 rows (loaded in script 02)

-- 2. Confirm date dimension covers Jan 1 – Apr 30 with correct holiday flags
SELECT
    month_name,
    COUNT(*)                                                          AS days_in_month,
    SUM(CAST(is_weekday AS INT))                                      AS weekdays,
    SUM(CAST(is_weekend AS INT))                                      AS weekend_days,
    SUM(CAST(is_public_holiday AS INT))                               AS public_holidays,
    SUM(CAST(is_in_data AS INT))                                      AS days_with_data
FROM dim.date
GROUP BY month_num, month_name
ORDER BY month_num;

-- Expected:
--   January  → 31, 22 wk, 9 we, 2 holidays (1 + 26), 31 in_data
--   February → 28, 20 wk, 8 we, 0 holidays,            28 in_data
--   March    → 31, 22 wk, 9 we, 0 holidays,            0  in_data ← gap
--   April    → 30, 22 wk, 8 we, 5 holidays (3,4,5,6,25), 30 in_data

-- 3. Confirm time dimension: 96 bins, peak window counts
SELECT period_type, COUNT(*) AS bins
FROM dim.time_period
GROUP BY period_type
ORDER BY period_type;

-- Expected:
--   AM Peak    → 8 bins (07:00 – 09:00 = 2 hrs × 4)
--   PM Peak    → 8 bins (16:00 – 18:00 = 2 hrs × 4)
--   Inter-peak → 28 bins (09:00 – 16:00 = 7 hrs × 4)
--   Off-peak   → 52 bins (18:00 – 07:00 = 13 hrs × 4)

-- 4. Vehicle class dimension
SELECT vehicle_group, COUNT(*) AS classes
FROM dim.vehicle_class
GROUP BY vehicle_group
ORDER BY vehicle_group;
