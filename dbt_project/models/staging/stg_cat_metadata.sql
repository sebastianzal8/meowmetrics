-- staging model for cat breed registry

WITH raw_registry AS (
    SELECT * FROM {{ source('raw_sources', 'stg_raw_cat_registry') }}
)

SELECT
    cat_id,
    TRIM(name) AS cat_name,
    COALESCE(TRIM(breed), 'Mixed Breed') AS breed,
    LOWER(gender) AS gender,
    birth_date,
    weight_lbs,
    owner_id,
    registered_at
FROM raw_registry
