-- daily_cat_health: Aggregated metrics & feline health scoring model

WITH daily_telemetry AS (
    SELECT * FROM {{ ref('int_cat_daily_telemetry') }}
),

health_scoring AS (
    SELECT
        *,
        -- Base health score calculation (Max 100)
        -- Cats average 12-16 hours of sleep. Less than 8 or more than 20 hours reduces score.
        -- Anomalous heart rates reduce score.
        -- Zero activity reduces score.
        100 
        - CASE WHEN avg_heart_rate_bpm > 200 OR avg_heart_rate_bpm < 80 THEN 20 ELSE 0 END
        - CASE WHEN estimated_sleep_minutes < 480 OR estimated_sleep_minutes > 1100 THEN 15 ELSE 0 END
        - CASE WHEN total_daily_steps < 500 THEN 15 ELSE 0 END
        - CASE WHEN min_battery_level_pct < 10 THEN 5 ELSE 0 END AS computed_score
    FROM daily_telemetry
)

SELECT
    daily_summary_id,
    cat_id,
    reading_date,
    avg_heart_rate_bpm,
    total_daily_steps,
    avg_purr_frequency_hz,
    estimated_sleep_minutes,
    estimated_active_minutes,
    estimated_lazy_minutes,
    
    -- Ensure health score does not drop below 0 or exceed 100
    CASE 
        WHEN computed_score < 0 THEN 0 
        WHEN computed_score > 100 THEN 100
        ELSE computed_score 
    END AS daily_feline_health_score,
    
    -- Assign health alert levels
    CASE
        WHEN computed_score >= 85 THEN 'Excellent'
        WHEN computed_score >= 70 AND computed_score < 85 THEN 'Good'
        WHEN computed_score >= 50 AND computed_score < 70 THEN 'Needs Attention'
        ELSE 'Critical Care'
    END AS health_status_category
FROM health_scoring
