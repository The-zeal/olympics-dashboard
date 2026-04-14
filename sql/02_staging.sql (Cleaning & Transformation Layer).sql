-- ============================================================
-- FILE: 02_staging.sql
-- PROJECT: Olympics SQL Capstone
-- LAYER: STAGING (Clean + Typed Layer)
--
-- PURPOSE:
--   - Convert raw TEXT fields into correct datatypes
--   - Replace invalid placeholders like 'NA' with NULL
--   - Add derived fields needed for analytics:
--       * decade
--       * age_group
--       * medal_flag
--
-- EXPECTED RESULT:
--   A clean table (staging.olympics_clean) that can support
--   reporting, analytics, and dashboarding.
-- ============================================================


-- -------------------------------
-- 1. Create schema
-- -------------------------------
CREATE SCHEMA IF NOT EXISTS staging;


-- -------------------------------
-- 2. Drop and rebuild staging table
-- -------------------------------
DROP TABLE IF EXISTS staging.olympics_clean;

CREATE TABLE staging.olympics_clean AS
SELECT
    id::INTEGER AS athlete_id,
    name,
    sex,

    NULLIF(age, 'NA')::INTEGER AS age,
    NULLIF(height, 'NA')::NUMERIC AS height,
    NULLIF(weight, 'NA')::NUMERIC AS weight,

    team,
    noc,
    games,
    year::INTEGER AS year,
    season,
    city,
    sport,
    event,

    NULLIF(medal, 'NA') AS medal,

    -- Derived decade field (example: 1996 -> 1990)
    (year::INTEGER / 10) * 10 AS decade,

    -- Standardized age grouping
    CASE
        WHEN NULLIF(age, 'NA')::INTEGER < 20 THEN 'Under 20'
        WHEN NULLIF(age, 'NA')::INTEGER BETWEEN 20 AND 24 THEN '20-24'
        WHEN NULLIF(age, 'NA')::INTEGER BETWEEN 25 AND 29 THEN '25-29'
        WHEN NULLIF(age, 'NA')::INTEGER >= 30 THEN '30+'
        ELSE NULL
    END AS age_group,

    -- Medal flag for fast filtering
    CASE
        WHEN medal IS NULL OR medal = 'NA' THEN 0
        ELSE 1
    END AS medal_flag

FROM raw.olympics_raw;


-- -------------------------------
-- 3. Add indexes for performance
-- -------------------------------
-- These indexes speed up filtering and joins in analytics queries.
CREATE INDEX IF NOT EXISTS idx_clean_athlete_id
ON staging.olympics_clean (athlete_id);

CREATE INDEX IF NOT EXISTS idx_clean_noc
ON staging.olympics_clean (noc);

CREATE INDEX IF NOT EXISTS idx_clean_decade
ON staging.olympics_clean (decade);

CREATE INDEX IF NOT EXISTS idx_clean_sport
ON staging.olympics_clean (sport);

CREATE INDEX IF NOT EXISTS idx_clean_sex
ON staging.olympics_clean (sex);


-- -------------------------------
-- 4. Validation checks
-- -------------------------------

-- Row count check
SELECT COUNT(*) AS total_clean_rows
FROM staging.olympics_clean;

-- Confirm staging column datatypes
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'staging'
AND table_name = 'olympics_clean'
ORDER BY ordinal_position;

-- Null profiling (basic data quality check)
SELECT
    COUNT(*) FILTER (WHERE age IS NULL) AS null_age,
    COUNT(*) FILTER (WHERE height IS NULL) AS null_height,
    COUNT(*) FILTER (WHERE weight IS NULL) AS null_weight,
    COUNT(*) FILTER (WHERE medal IS NULL) AS null_medal
FROM staging.olympics_clean;

-- Medal distribution check
SELECT medal, COUNT(*) AS medal_count
FROM staging.olympics_clean
GROUP BY medal
ORDER BY medal_count DESC;