-- fact_collar_readings: Granular telemetry facts

WITH telemetry AS (
    SELECT * FROM {{ ref('stg_collar_telemetry') }}
)

SELECT
    reading_id,
    collar_id,
    cat_id,
    reading_time,
    
    -- Telemetry metrics
    heart_rate_bpm,
    activity_level,
    steps_count,
    purr_frequency_hz,
    ambient_temp_c,
    battery_level_pct,
    
    -- Check if battery is low and needs replacement (alert trigger)
    CASE 
        WHEN battery_level_pct <= 15 THEN TRUE 
        ELSE FALSE 
    END AS low_battery_warning,
    
    -- Check if heart rate suggests high exertion or distress
    CASE
        WHEN heart_rate_bpm > 220 THEN 'high/distress'
        WHEN heart_rate_bpm < 90 AND heart_rate_bpm > 0 THEN 'bradycardia/low'
        WHEN heart_rate_bpm = -1 THEN 'sensor error'
        ELSE 'normal'
    END AS cardiac_status
FROM telemetry
