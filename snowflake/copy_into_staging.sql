-- =====================================================================
-- Snowflake COPY INTO Script for MeowMetrics Ingestion
-- Demonstrates ingestion of Parquet (from Databricks) and CSV datasets
-- into raw staging schemas.
-- =====================================================================

USE ROLE MEOW_ADMIN_ROLE;
USE DATABASE MEOW_DB;
USE WAREHOUSE MEOW_WH;

-- 1. LOAD PARQUET SMART-COLLAR TELEMETRY FROM EXTERNAL STAGE
-- Since the Databricks output is formatted as Parquet, we parse individual
-- fields dynamically from the `$1` variant structure during ingestion.
COPY INTO RAW_STAGE.STG_RAW_COLLAR_TELEMETRY
FROM (
  SELECT
    $1:collar_id::VARCHAR,
    $1:cat_id::VARCHAR,
    $1:parsed_reading_time::TIMESTAMP,
    $1:heart_rate_bpm::INT,
    $1:activity_level::VARCHAR,
    $1:steps_count::INT,
    $1:purr_frequency_hz::FLOAT,
    $1:ambient_temp_c::FLOAT,
    $1:battery_level_pct::INT,
    CURRENT_TIMESTAMP()::TIMESTAMP, -- tracking load audit timestamp
    METADATA$FILENAME::VARCHAR     -- capture source filename
  FROM @RAW_STAGE.MEOW_EXT_STAGE_TELEMETRY
)
FILE_FORMAT = (FORMAT_NAME = 'RAW_STAGE.PARQUET_FILE_FORMAT')
ON_ERROR = 'CONTINUE'; -- Logs and continues if a single malformed file fails


-- 2. LOAD CSV BREED AND REGISTRATION DATA FROM EXTERNAL STAGE
-- Simple columnar copy, mapping fields sequentially from the CSV file.
COPY INTO RAW_STAGE.STG_RAW_CAT_REGISTRY
FROM @RAW_STAGE.MEOW_EXT_STAGE_REGISTRY
FILE_FORMAT = (FORMAT_NAME = 'RAW_STAGE.CSV_FILE_FORMAT')
ON_ERROR = 'ABORT_STATEMENT'; -- Abort if reference data metadata is corrupted


-- 3. AUDIT RECENT LOADS
-- Query metadata details to confirm load progress
SELECT
  TABLE_NAME,
  ROW_COUNT,
  LAST_ALTERED
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'RAW_STAGE';
