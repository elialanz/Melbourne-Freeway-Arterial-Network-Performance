/* =============================================================================
   Script  : 02a_test_load.sql  (SINGLE-FILE TEST — proven classic method)
   Method  : Classic BULK INSERT with CRLF row terminator.
             FORMAT='CSV' is NOT used — it fails on this SQL Server install
             with error 7301 (IID_IColumnsInfo). The classic field/row
             terminator method was confirmed working via isolated test.
   ============================================================================= */

USE MelbourneArterialNetwork;
GO

TRUNCATE TABLE stg.tirtl_raw;
GO

BEGIN TRY
    BULK INSERT stg.tirtl_raw
    FROM 'C:\Users\eliad\OneDrive\Desktop\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\1_Raw\tirtl_15min_volume_classification_january_2026\TIRTLDATA_20260101.csv'
    WITH (
        FIRSTROW        = 2,          -- skip header
        FIELDTERMINATOR = ',',
        ROWTERMINATOR   = '0x0d0a',   -- CRLF (\r\n) — the proven terminator
        TABLOCK
    );
    PRINT 'LOAD OK — classic BULK INSERT, CRLF terminator';
END TRY
BEGIN CATCH
    PRINT 'FAILED. Error ' + CAST(ERROR_NUMBER() AS VARCHAR) + ': ' + ERROR_MESSAGE();
END CATCH
GO

UPDATE stg.tirtl_raw SET source_file = 'TIRTLDATA_20260101.csv' WHERE source_file IS NULL;
GO

/* ----------------------------------------------------------------------------
   VERIFICATION
   ---------------------------------------------------------------------------- */

-- A. Row count — expect 643,846
SELECT COUNT(*) AS rows_loaded FROM stg.tirtl_raw;

-- B. Volume sanity + total — expect total ~12.4 million
SELECT
    MIN(volume)                  AS min_vol,
    MAX(volume)                  AS max_vol,
    SUM(CAST(volume AS BIGINT))  AS total_vehicles
FROM stg.tirtl_raw;

-- C. Last-column cleanliness — visible_len should EQUAL byte_len (no stray \r)
SELECT TOP 5
    speed_bin,
    LEN(speed_bin)        AS visible_len,
    DATALENGTH(speed_bin) AS byte_len,
    volume
FROM stg.tirtl_raw
ORDER BY DATALENGTH(speed_bin) DESC;

-- D. Eyeball first rows
SELECT TOP 5 * FROM stg.tirtl_raw ORDER BY site, time_bin;
GO
