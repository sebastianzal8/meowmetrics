-- staging model for collar telemetry

WITH raw_telemetry AS (
    SELECT * FROM {{ source('raw_sources', 'stg_raw_collar_telemetry') }}
)

SELECT
    -- Generate unique surrogate key for tracking individual records
    {{ dbt_utils.generate_surrogate_key(['collar_id', 'reading_time']) }} AS reading_id,
    
    collar_id,
    cat_id,
    reading_time,
    
    -- Telemetry Metrics
    COALESCE(heart_rate_bpm, -1) AS heart_rate_bpm,
    COALESCE(activity_level, 'unknown') AS activity_level,
    COALESCE(steps_count, 0) AS steps_count,
    COALESCE(purr_frequency_hz, 0.0) AS purr_frequency_hz,
    COALESCE(ambient_temp_c, 0.0) AS ambient_temp_c,
    battery_level_pct,
    
    -- Metadata
    ingested_at,
    source_file
FROM raw_telemetry
