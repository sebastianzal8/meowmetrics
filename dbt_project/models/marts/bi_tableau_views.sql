-- bi_tableau_views: Denormalized dataset layout optimized for Tableau dashboards
-- Exposing this shows Tableau optimization best practices (e.g. flat star schema views to reduce dashboard join bottlenecks)

WITH cats AS (
    SELECT * FROM {{ ref('dim_cats') }}
),

daily_health AS (
    SELECT * FROM {{ ref('daily_cat_health') }}
)

SELECT
    h.daily_summary_id,
    c.cat_id,
    c.cat_name,
    c.breed,
    c.gender,
    c.age_years,
    c.human_equivalent_age,
    c.weight_lbs,
    c.weight_category,
    
    -- Health Log Details
    h.reading_date,
    h.avg_heart_rate_bpm,
    h.total_daily_steps,
    h.avg_purr_frequency_hz,
    h.estimated_sleep_minutes,
    h.estimated_active_minutes,
    h.estimated_lazy_minutes,
    h.daily_feline_health_score,
    h.health_status_category,
    
    -- Calculate sleep percentage of day (cats sleep a lot!)
    ROUND((h.estimated_sleep_minutes / 1440.0) * 100, 1) AS sleep_percentage_of_day,
    
    -- Calculate activity percentage
    ROUND((h.estimated_active_minutes / 1440.0) * 100, 1) AS active_percentage_of_day
FROM daily_health h
LEFT JOIN cats c 
  ON h.cat_id = c.cat_id
