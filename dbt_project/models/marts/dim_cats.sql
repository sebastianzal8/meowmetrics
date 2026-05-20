-- dim_cats: Cat dimension table

WITH cat_metadata AS (
    SELECT * FROM {{ ref('stg_cat_metadata') }}
)

SELECT
    cat_id,
    cat_name,
    breed,
    gender,
    birth_date,
    weight_lbs,
    
    -- Calculate age in years
    DATEDIFF(year, birth_date, CURRENT_DATE()) AS age_years,
    
    -- Calculate human equivalent age (1st year = 15 human years, 2nd = +9 (24), subsequent years = +4 human years)
    CASE 
        WHEN DATEDIFF(year, birth_date, CURRENT_DATE()) = 0 THEN 0
        WHEN DATEDIFF(year, birth_date, CURRENT_DATE()) = 1 THEN 15
        WHEN DATEDIFF(year, birth_date, CURRENT_DATE()) = 2 THEN 24
        ELSE 24 + ((DATEDIFF(year, birth_date, CURRENT_DATE()) - 2) * 4)
    END AS human_equivalent_age,
    
    -- Classify weight classes based on average standard weights (typical cats average 8-11 lbs)
    CASE
        WHEN weight_lbs < 6.5 THEN 'underweight'
        WHEN weight_lbs >= 6.5 AND weight_lbs <= 11.5 THEN 'healthy weight'
        WHEN weight_lbs > 11.5 AND weight_lbs <= 15.0 THEN 'overweight'
        ELSE 'obese'
    END AS weight_category,
    
    owner_id,
    registered_at
FROM cat_metadata
