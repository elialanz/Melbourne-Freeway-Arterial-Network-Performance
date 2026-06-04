/* =============================================================================
   Project : Melbourne Freeway & Arterial Network - Operational Performance
   Script  : 02_load_raw_data.sql
   Purpose : Load all 89 daily TIRTL CSV files (Jan, Feb, Apr 2026) into the
             staging table stg.tirtl_raw.

   METHOD (proven on single-file test):
     1. BULK INSERT each CSV into an all-VARCHAR temp table (#load).
        - No type casting on load => avoids cast errors (SQLState 22005).
        - No CODEPAGE option => avoids the FORMAT/codepage provider error
          (IID_IColumnsInfo) seen on this SQL Server 2022 Express install.
     2. INSERT ... SELECT into stg.tirtl_raw with TRY_CONVERT for typed columns,
        stripping any trailing carriage return (CHAR(13)) left by the 0x0a
        row terminator, and stamping the source filename.
     3. TRUNCATE the temp table between files.

   Each file is loaded in its own explicit block for full auditability.
   ============================================================================= */

USE MelbourneArterialNetwork;
GO

-- Start from an empty fact-staging table
TRUNCATE TABLE stg.tirtl_raw;
GO

-- Reusable all-text load table (created once, truncated between files)
DROP TABLE IF EXISTS #load;
GO
CREATE TABLE #load (
    date_raw          varchar(20),
    time_bin_raw      varchar(10),
    site_raw          varchar(50),
    heading_raw       varchar(5),
    vehicle_class_raw varchar(10),
    speed_bin_raw     varchar(100),
    volume_raw        varchar(20)
);
GO

/* ---- File 1 of 89 : TIRTLDATA_20260101.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_january_2026\TIRTLDATA_20260101.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260101.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 2 of 89 : TIRTLDATA_20260102.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_january_2026\TIRTLDATA_20260102.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260102.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 3 of 89 : TIRTLDATA_20260103.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_january_2026\TIRTLDATA_20260103.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260103.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 4 of 89 : TIRTLDATA_20260104.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_january_2026\TIRTLDATA_20260104.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260104.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 5 of 89 : TIRTLDATA_20260105.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_january_2026\TIRTLDATA_20260105.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260105.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 6 of 89 : TIRTLDATA_20260106.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_january_2026\TIRTLDATA_20260106.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260106.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 7 of 89 : TIRTLDATA_20260107.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_january_2026\TIRTLDATA_20260107.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260107.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 8 of 89 : TIRTLDATA_20260108.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_january_2026\TIRTLDATA_20260108.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260108.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 9 of 89 : TIRTLDATA_20260109.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_january_2026\TIRTLDATA_20260109.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260109.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 10 of 89 : TIRTLDATA_20260110.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_january_2026\TIRTLDATA_20260110.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260110.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 11 of 89 : TIRTLDATA_20260111.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_january_2026\TIRTLDATA_20260111.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260111.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 12 of 89 : TIRTLDATA_20260112.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_january_2026\TIRTLDATA_20260112.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260112.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 13 of 89 : TIRTLDATA_20260113.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_january_2026\TIRTLDATA_20260113.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260113.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 14 of 89 : TIRTLDATA_20260114.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_january_2026\TIRTLDATA_20260114.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260114.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 15 of 89 : TIRTLDATA_20260115.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_january_2026\TIRTLDATA_20260115.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260115.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 16 of 89 : TIRTLDATA_20260116.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_january_2026\TIRTLDATA_20260116.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260116.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 17 of 89 : TIRTLDATA_20260117.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_january_2026\TIRTLDATA_20260117.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260117.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 18 of 89 : TIRTLDATA_20260118.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_january_2026\TIRTLDATA_20260118.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260118.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 19 of 89 : TIRTLDATA_20260119.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_january_2026\TIRTLDATA_20260119.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260119.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 20 of 89 : TIRTLDATA_20260120.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_january_2026\TIRTLDATA_20260120.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260120.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 21 of 89 : TIRTLDATA_20260121.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_january_2026\TIRTLDATA_20260121.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260121.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 22 of 89 : TIRTLDATA_20260122.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_january_2026\TIRTLDATA_20260122.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260122.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 23 of 89 : TIRTLDATA_20260123.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_january_2026\TIRTLDATA_20260123.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260123.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 24 of 89 : TIRTLDATA_20260124.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_january_2026\TIRTLDATA_20260124.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260124.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 25 of 89 : TIRTLDATA_20260125.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_january_2026\TIRTLDATA_20260125.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260125.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 26 of 89 : TIRTLDATA_20260126.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_january_2026\TIRTLDATA_20260126.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260126.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 27 of 89 : TIRTLDATA_20260127.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_january_2026\TIRTLDATA_20260127.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260127.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 28 of 89 : TIRTLDATA_20260128.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_january_2026\TIRTLDATA_20260128.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260128.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 29 of 89 : TIRTLDATA_20260129.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_january_2026\TIRTLDATA_20260129.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260129.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 30 of 89 : TIRTLDATA_20260130.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_january_2026\TIRTLDATA_20260130.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260130.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 31 of 89 : TIRTLDATA_20260131.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_january_2026\TIRTLDATA_20260131.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260131.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 32 of 89 : TIRTLDATA_20260201.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_february_2026\TIRTLDATA_20260201.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260201.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 33 of 89 : TIRTLDATA_20260202.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_february_2026\TIRTLDATA_20260202.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260202.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 34 of 89 : TIRTLDATA_20260203.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_february_2026\TIRTLDATA_20260203.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260203.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 35 of 89 : TIRTLDATA_20260204.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_february_2026\TIRTLDATA_20260204.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260204.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 36 of 89 : TIRTLDATA_20260205.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_february_2026\TIRTLDATA_20260205.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260205.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 37 of 89 : TIRTLDATA_20260206.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_february_2026\TIRTLDATA_20260206.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260206.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 38 of 89 : TIRTLDATA_20260207.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_february_2026\TIRTLDATA_20260207.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260207.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 39 of 89 : TIRTLDATA_20260208.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_february_2026\TIRTLDATA_20260208.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260208.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 40 of 89 : TIRTLDATA_20260209.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_february_2026\TIRTLDATA_20260209.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260209.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 41 of 89 : TIRTLDATA_20260210.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_february_2026\TIRTLDATA_20260210.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260210.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 42 of 89 : TIRTLDATA_20260211.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_february_2026\TIRTLDATA_20260211.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260211.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 43 of 89 : TIRTLDATA_20260212.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_february_2026\TIRTLDATA_20260212.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260212.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 44 of 89 : TIRTLDATA_20260213.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_february_2026\TIRTLDATA_20260213.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260213.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 45 of 89 : TIRTLDATA_20260214.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_february_2026\TIRTLDATA_20260214.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260214.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 46 of 89 : TIRTLDATA_20260215.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_february_2026\TIRTLDATA_20260215.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260215.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 47 of 89 : TIRTLDATA_20260216.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_february_2026\TIRTLDATA_20260216.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260216.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 48 of 89 : TIRTLDATA_20260217.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_february_2026\TIRTLDATA_20260217.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260217.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 49 of 89 : TIRTLDATA_20260218.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_february_2026\TIRTLDATA_20260218.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260218.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 50 of 89 : TIRTLDATA_20260219.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_february_2026\TIRTLDATA_20260219.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260219.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 51 of 89 : TIRTLDATA_20260220.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_february_2026\TIRTLDATA_20260220.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260220.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 52 of 89 : TIRTLDATA_20260221.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_february_2026\TIRTLDATA_20260221.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260221.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 53 of 89 : TIRTLDATA_20260222.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_february_2026\TIRTLDATA_20260222.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260222.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 54 of 89 : TIRTLDATA_20260223.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_february_2026\TIRTLDATA_20260223.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260223.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 55 of 89 : TIRTLDATA_20260224.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_february_2026\TIRTLDATA_20260224.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260224.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 56 of 89 : TIRTLDATA_20260225.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_february_2026\TIRTLDATA_20260225.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260225.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 57 of 89 : TIRTLDATA_20260226.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_february_2026\TIRTLDATA_20260226.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260226.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 58 of 89 : TIRTLDATA_20260227.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_february_2026\TIRTLDATA_20260227.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260227.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 59 of 89 : TIRTLDATA_20260228.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_february_2026\TIRTLDATA_20260228.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260228.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 60 of 89 : TIRTLDATA_20260401.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_april_2026\TIRTLDATA_20260401.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260401.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 61 of 89 : TIRTLDATA_20260402.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_april_2026\TIRTLDATA_20260402.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260402.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 62 of 89 : TIRTLDATA_20260403.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_april_2026\TIRTLDATA_20260403.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260403.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 63 of 89 : TIRTLDATA_20260404.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_april_2026\TIRTLDATA_20260404.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260404.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 64 of 89 : TIRTLDATA_20260405.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_april_2026\TIRTLDATA_20260405.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260405.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 65 of 89 : TIRTLDATA_20260406.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_april_2026\TIRTLDATA_20260406.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260406.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 66 of 89 : TIRTLDATA_20260407.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_april_2026\TIRTLDATA_20260407.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260407.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 67 of 89 : TIRTLDATA_20260408.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_april_2026\TIRTLDATA_20260408.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260408.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 68 of 89 : TIRTLDATA_20260409.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_april_2026\TIRTLDATA_20260409.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260409.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 69 of 89 : TIRTLDATA_20260410.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_april_2026\TIRTLDATA_20260410.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260410.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 70 of 89 : TIRTLDATA_20260411.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_april_2026\TIRTLDATA_20260411.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260411.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 71 of 89 : TIRTLDATA_20260412.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_april_2026\TIRTLDATA_20260412.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260412.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 72 of 89 : TIRTLDATA_20260413.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_april_2026\TIRTLDATA_20260413.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260413.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 73 of 89 : TIRTLDATA_20260414.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_april_2026\TIRTLDATA_20260414.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260414.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 74 of 89 : TIRTLDATA_20260415.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_april_2026\TIRTLDATA_20260415.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260415.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 75 of 89 : TIRTLDATA_20260416.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_april_2026\TIRTLDATA_20260416.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260416.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 76 of 89 : TIRTLDATA_20260417.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_april_2026\TIRTLDATA_20260417.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260417.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 77 of 89 : TIRTLDATA_20260418.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_april_2026\TIRTLDATA_20260418.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260418.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 78 of 89 : TIRTLDATA_20260419.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_april_2026\TIRTLDATA_20260419.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260419.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 79 of 89 : TIRTLDATA_20260420.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_april_2026\TIRTLDATA_20260420.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260420.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 80 of 89 : TIRTLDATA_20260421.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_april_2026\TIRTLDATA_20260421.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260421.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 81 of 89 : TIRTLDATA_20260422.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_april_2026\TIRTLDATA_20260422.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260422.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 82 of 89 : TIRTLDATA_20260423.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_april_2026\TIRTLDATA_20260423.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260423.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 83 of 89 : TIRTLDATA_20260424.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_april_2026\TIRTLDATA_20260424.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260424.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 84 of 89 : TIRTLDATA_20260425.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_april_2026\TIRTLDATA_20260425.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260425.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 85 of 89 : TIRTLDATA_20260426.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_april_2026\TIRTLDATA_20260426.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260426.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 86 of 89 : TIRTLDATA_20260427.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_april_2026\TIRTLDATA_20260427.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260427.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 87 of 89 : TIRTLDATA_20260428.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_april_2026\TIRTLDATA_20260428.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260428.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 88 of 89 : TIRTLDATA_20260429.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_april_2026\TIRTLDATA_20260429.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260429.csv',
    SYSDATETIME()
FROM #load;
GO

/* ---- File 89 of 89 : TIRTLDATA_20260430.csv ---- */
TRUNCATE TABLE #load;
GO
BULK INSERT #load
FROM 'C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_april_2026\TIRTLDATA_20260430.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);
GO
INSERT INTO stg.tirtl_raw ([date], time_bin, site, heading, vehicle_class, speed_bin, volume, source_file, loaded_at)
SELECT
    TRY_CONVERT(date, date_raw),
    time_bin_raw,
    site_raw,
    heading_raw,
    TRY_CONVERT(tinyint, vehicle_class_raw),
    REPLACE(speed_bin_raw, CHAR(13), ''),
    TRY_CONVERT(int, REPLACE(volume_raw, CHAR(13), '')),
    'TIRTLDATA_20260430.csv',
    SYSDATETIME()
FROM #load;
GO


/* ============================================================================
   VERIFICATION
   ============================================================================ */

-- 1. Total rows loaded (expect ~70-90 million across 89 files)
SELECT COUNT(*) AS total_rows, FORMAT(SUM(CAST(volume AS BIGINT)), 'N0') AS total_vehicles
FROM stg.tirtl_raw;

-- 2. Rows per source file (each should be in the ~500K-1.1M range; 89 files)
SELECT source_file, COUNT(*) AS rows_in_file
FROM stg.tirtl_raw
GROUP BY source_file
ORDER BY source_file;

-- 3. File count check (expect 89)
SELECT COUNT(DISTINCT source_file) AS distinct_files FROM stg.tirtl_raw;

-- 4. Conversion failures (expect 0) - any row where a typed convert returned NULL
SELECT COUNT(*) AS failed_conversions
FROM stg.tirtl_raw
WHERE [date] IS NULL OR volume IS NULL OR vehicle_class IS NULL;

-- 5. Distinct dates loaded (expect 89 distinct dates: 31 Jan + 28 Feb + 30 Apr)
SELECT COUNT(DISTINCT [date]) AS distinct_dates,
       MIN([date]) AS first_date,
       MAX([date]) AS last_date
FROM stg.tirtl_raw;

-- 6. Clean up temp table
DROP TABLE IF EXISTS #load;
GO
