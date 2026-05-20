-- Custom singular dbt test
-- Any rows returned by this query represent test failures.
-- This asserts that no recorded heart rate falls outside of physical possibility (excluding the -1 indicator for sensor outages)

SELECT
    reading_id,
    cat_id,
    heart_rate_bpm
FROM {{ ref('stg_collar_telemetry') }}
WHERE heart_rate_bpm > 250
   OR (heart_rate_bpm < 0 AND heart_rate_bpm != -1)
