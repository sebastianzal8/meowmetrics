-- intermediate model: daily collar aggregation per cat

WITH collar_telemetry AS (
    SELECT * FROM {{ ref('stg_collar_telemetry') }}
),

daily_aggregation AS (
    SELECT
        cat_id,
        CAST(reading_time AS DATE) AS reading_date,
        
        -- Calculations
        AVG(CASE WHEN heart_rate_bpm > 0 THEN heart_rate_bpm ELSE NULL END) AS avg_heart_rate_bpm,
        SUM(steps_count) AS total_daily_steps,
        AVG(purr_frequency_hz) AS avg_purr_frequency_hz,
        AVG(ambient_temp_c) AS avg_ambient_temp_c,
        MIN(battery_level_pct) AS min_battery_level_pct,
        
        -- Duration allocations (since reading is hourly, count of readings maps to hours)
        COUNT(CASE WHEN activity_level = 'sleep' THEN 1 END) * 60 AS estimated_sleep_minutes,
        COUNT(CASE WHEN activity_level = 'active' THEN 1 END) * 60 AS estimated_active_minutes,
        COUNT(CASE WHEN activity_level = 'lazy' THEN 1 END) * 60 AS estimated_lazy_minutes,
        COUNT(*) AS total_readings_logged
    FROM collar_telemetry
    GROUP BY cat_id, CAST(reading_time AS DATE)
)

SELECT
    {{ dbt_utils.generate_surrogate_key(['cat_id', 'reading_date']) }} AS daily_summary_id,
    cat_id,
    reading_date,
    ROUND(avg_heart_rate_bpm, 1) AS avg_heart_rate_bpm,
    total_daily_steps,
    ROUND(avg_purr_frequency_hz, 2) AS avg_purr_frequency_hz,
    ROUND(avg_ambient_temp_c, 2) AS avg_ambient_temp_c,
    min_battery_level_pct,
    estimated_sleep_minutes,
    estimated_active_minutes,
    estimated_lazy_minutes,
    total_readings_logged
FROM daily_aggregation
