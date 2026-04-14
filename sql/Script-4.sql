-- ============================================================
-- FILE: 01_raw.sql
-- PROJECT: Olympics SQL Capstone
-- LAYER: RAW (Ingestion Layer)
--
-- PURPOSE:
--   - Create the RAW schema
--   - Create a raw table that matches the CSV structure
--   - Load the dataset into PostgreSQL without transformations
--
-- WHY THIS MATTERS:
--   In professional pipelines, raw data is preserved exactly as received
--   so that all analysis can always be traced back to the original source.
-- ============================================================


-- -------------------------------
-- 1. Create schema
-- -------------------------------
CREATE SCHEMA IF NOT EXISTS raw;


-- -------------------------------
-- 2. Drop and recreate raw table
-- -------------------------------
DROP TABLE IF EXISTS raw.olympics_raw;

CREATE TABLE raw.olympics_raw (
    id TEXT,
    name TEXT,
    sex TEXT,
    age TEXT,
    height TEXT,
    weight TEXT,
    team TEXT,
    noc TEXT,
    games TEXT,
    year TEXT,
    season TEXT,
    city TEXT,
    sport TEXT,
    event TEXT,
    medal TEXT
);


-- -------------------------------
-- 3. Load CSV data into raw table
-- -------------------------------
-- NOTE:
-- The file path must be accessible to PostgreSQL.
-- If running COPY inside DBeaver, ensure PostgreSQL has permission
-- to read the file path.
--
-- Expected Output:
--   - raw.olympics_raw populated with all CSV rows
--   - No type conversion errors because all fields are TEXT
-- -------------------------------

COPY raw.olympics_raw
FROM 'C:/data/sql-capstone-project/data/raw/athlete_events.csv'
DELIMITER ','
CSV HEADER;


-- -------------------------------
-- 4. Validation checks
-- -------------------------------

-- Confirm dataset row count
SELECT COUNT(*) AS total_raw_rows
FROM raw.olympics_raw;

-- Quick check of missing values
SELECT
    COUNT(*) FILTER (WHERE age IS NULL OR age = 'NA') AS missing_age,
    COUNT(*) FILTER (WHERE medal IS NULL OR medal = 'NA') AS missing_medal
FROM raw.olympics_raw;


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


-- ============================================================
-- FILE: 03_analytics.sql
-- PROJECT: Olympics SQL Capstone
-- LAYER: ANALYTICS
--
-- PURPOSE:
--   Build reporting and insight-ready tables including:
--   - Country medal dominance
--   - Decade leadership
--   - Gender participation trends
--   - Female growth rate analysis
--   - Representation gap (participation vs medal share)
--   - Age-based performance patterns
--   - Sport competitiveness metrics
--
-- EXPECTED RESULT:
--   Tables that support business storytelling and dashboards.
-- ============================================================


-- -------------------------------
-- 1. Create schema
-- -------------------------------
CREATE SCHEMA IF NOT EXISTS analytics;


-- ============================================================
-- SECTION A: COUNTRY MEDAL PERFORMANCE
-- ============================================================

DROP TABLE IF EXISTS analytics.country_medal_summary;

CREATE TABLE analytics.country_medal_summary AS
SELECT
    noc,
    COUNT(*) FILTER (WHERE medal = 'Gold') AS gold_medals,
    COUNT(*) FILTER (WHERE medal = 'Silver') AS silver_medals,
    COUNT(*) FILTER (WHERE medal = 'Bronze') AS bronze_medals,
    COUNT(*) FILTER (WHERE medal IS NOT NULL) AS total_medals
FROM staging.olympics_clean
GROUP BY noc;


DROP TABLE IF EXISTS analytics.country_medal_ranked;

CREATE TABLE analytics.country_medal_ranked AS
SELECT
    *,
    RANK() OVER (ORDER BY total_medals DESC) AS medal_rank
FROM analytics.country_medal_summary;


-- ============================================================
-- SECTION B: COUNTRY DOMINANCE BY DECADE
-- ============================================================

DROP TABLE IF EXISTS analytics.country_decade_medals;

CREATE TABLE analytics.country_decade_medals AS
SELECT
    decade,
    noc,
    COUNT(*) FILTER (WHERE medal = 'Gold') AS gold_medals,
    COUNT(*) FILTER (WHERE medal = 'Silver') AS silver_medals,
    COUNT(*) FILTER (WHERE medal = 'Bronze') AS bronze_medals,
    COUNT(*) FILTER (WHERE medal IS NOT NULL) AS total_medals
FROM staging.olympics_clean
GROUP BY decade, noc;


DROP TABLE IF EXISTS analytics.country_decade_ranked;

CREATE TABLE analytics.country_decade_ranked AS
SELECT
    *,
    RANK() OVER (
        PARTITION BY decade
        ORDER BY total_medals DESC
    ) AS decade_rank
FROM analytics.country_decade_medals;


DROP TABLE IF EXISTS analytics.decade_dominance_concentration;

CREATE TABLE analytics.decade_dominance_concentration AS
WITH decade_totals AS (
    SELECT
        decade,
        SUM(total_medals) AS decade_total_medals
    FROM analytics.country_decade_medals
    GROUP BY decade
),
top_country AS (
    SELECT
        decade,
        noc,
        total_medals
    FROM analytics.country_decade_ranked
    WHERE decade_rank = 1
)
SELECT
    t.decade,
    t.noc AS top_country,
    t.total_medals AS top_country_medals,
    d.decade_total_medals,
    ROUND((t.total_medals::numeric / d.decade_total_medals) * 100, 2)
        AS dominance_percentage
FROM top_country t
JOIN decade_totals d
    ON t.decade = d.decade
ORDER BY t.decade;


-- ============================================================
-- SECTION C: GENDER PARTICIPATION BY DECADE
-- ============================================================

DROP TABLE IF EXISTS analytics.gender_decade_participation;

CREATE TABLE analytics.gender_decade_participation AS
SELECT
    decade,
    sex,
    COUNT(DISTINCT athlete_id) AS athlete_count
FROM staging.olympics_clean
GROUP BY decade, sex;


DROP TABLE IF EXISTS analytics.gender_decade_percentage;

CREATE TABLE analytics.gender_decade_percentage AS
WITH decade_totals AS (
    SELECT
        decade,
        COUNT(DISTINCT athlete_id) AS total_athletes
    FROM staging.olympics_clean
    GROUP BY decade
)
SELECT
    g.decade,
    g.sex,
    g.athlete_count,
    t.total_athletes,
    ROUND((g.athlete_count::numeric / t.total_athletes) * 100, 2)
        AS participation_percentage
FROM analytics.gender_decade_participation g
JOIN decade_totals t
    ON g.decade = t.decade
ORDER BY g.decade, g.sex;


-- ============================================================
-- SECTION D: FEMALE PARTICIPATION GROWTH (DECADE OVER DECADE)
-- ============================================================

DROP TABLE IF EXISTS analytics.female_participation_growth;

CREATE TABLE analytics.female_participation_growth AS
WITH female_trend AS (
    SELECT
        decade,
        participation_percentage
    FROM analytics.gender_decade_percentage
    WHERE sex = 'F'
)
SELECT
    decade,
    participation_percentage AS current_percentage,
    LAG(participation_percentage) OVER (ORDER BY decade) AS previous_percentage,

    ROUND(
        participation_percentage
        - LAG(participation_percentage) OVER (ORDER BY decade),
        2
    ) AS percentage_point_change,

    ROUND(
        (
            (participation_percentage
            - LAG(participation_percentage) OVER (ORDER BY decade))
            /
            NULLIF(LAG(participation_percentage) OVER (ORDER BY decade), 0)
        ) * 100,
        2
    ) AS growth_rate_percentage
FROM female_trend
ORDER BY decade;


-- ============================================================
-- SECTION E: FEMALE MEDAL SHARE + REPRESENTATION GAP
-- ============================================================

DROP TABLE IF EXISTS analytics.female_decade_medals;

CREATE TABLE analytics.female_decade_medals AS
SELECT
    decade,
    COUNT(*) FILTER (WHERE medal IS NOT NULL) AS female_medals
FROM staging.olympics_clean
WHERE sex = 'F'
GROUP BY decade;


DROP TABLE IF EXISTS analytics.decade_total_medals_all;

CREATE TABLE analytics.decade_total_medals_all AS
SELECT
    decade,
    COUNT(*) FILTER (WHERE medal IS NOT NULL) AS total_medals
FROM staging.olympics_clean
GROUP BY decade;


DROP TABLE IF EXISTS analytics.female_medal_share;

CREATE TABLE analytics.female_medal_share AS
SELECT
    f.decade,
    f.female_medals,
    t.total_medals,
    ROUND((f.female_medals::numeric / NULLIF(t.total_medals, 0)) * 100, 2)
        AS female_medal_share_percentage
FROM analytics.female_decade_medals f
JOIN analytics.decade_total_medals_all t
    ON f.decade = t.decade
ORDER BY f.decade;


DROP TABLE IF EXISTS analytics.female_representation_gap;

CREATE TABLE analytics.female_representation_gap AS
SELECT
    p.decade,
    p.participation_percentage AS female_participation_percentage,
    m.female_medal_share_percentage,
    ROUND(m.female_medal_share_percentage - p.participation_percentage, 2)
        AS representation_gap_percentage
FROM analytics.gender_decade_percentage p
JOIN analytics.female_medal_share m
    ON p.decade = m.decade
WHERE p.sex = 'F'
ORDER BY p.decade;


-- ============================================================
-- SECTION F: AGE PERFORMANCE ANALYSIS
-- ============================================================

DROP TABLE IF EXISTS analytics.age_medal_distribution;

CREATE TABLE analytics.age_medal_distribution AS
SELECT
    age_group,
    COUNT(*) FILTER (WHERE medal = 'Gold') AS gold_medals,
    COUNT(*) FILTER (WHERE medal = 'Silver') AS silver_medals,
    COUNT(*) FILTER (WHERE medal = 'Bronze') AS bronze_medals,
    COUNT(*) FILTER (WHERE medal IS NOT NULL) AS total_medals
FROM staging.olympics_clean
WHERE age_group IS NOT NULL
GROUP BY age_group
ORDER BY total_medals DESC;


DROP TABLE IF EXISTS analytics.sport_peak_age;

CREATE TABLE analytics.sport_peak_age AS
SELECT
    sport,
    age_group,
    COUNT(*) FILTER (WHERE medal IS NOT NULL) AS medal_count
FROM staging.olympics_clean
WHERE age_group IS NOT NULL
GROUP BY sport, age_group;


-- ============================================================
-- SECTION G: SPORT COMPETITIVENESS
-- ============================================================

DROP TABLE IF EXISTS analytics.sport_competitiveness;

CREATE TABLE analytics.sport_competitiveness AS
SELECT
    sport,
    COUNT(DISTINCT noc) AS medal_winning_countries
FROM staging.olympics_clean
WHERE medal IS NOT NULL
GROUP BY sport
ORDER BY medal_winning_countries DESC;


-- ============================================================
-- FILE: 04_gold_tables.sql
-- PROJECT: Olympics SQL Capstone
-- LAYER: GOLD OUTPUTS (Dashboard-ready tables)
--
-- PURPOSE:
--   Create final reporting tables that can be used directly
--   in Tableau, Power BI, or executive reporting decks.
--
-- GOLD TABLES SHOULD:
--   - Be clean and stable
--   - Contain business-ready metrics
--   - Avoid unnecessary complexity
-- ============================================================


-- ============================================================
-- GOLD TABLE 1: Country Sport Specialization
-- ============================================================
DROP TABLE IF EXISTS analytics.gold_country_sport_specialization;

CREATE TABLE analytics.gold_country_sport_specialization AS
SELECT
    noc,
    sport,
    COUNT(*) FILTER (WHERE medal IS NOT NULL) AS total_medals,
    RANK() OVER (
        PARTITION BY noc
        ORDER BY COUNT(*) FILTER (WHERE medal IS NOT NULL) DESC
    ) AS sport_rank
FROM staging.olympics_clean
GROUP BY noc, sport;


-- ============================================================
-- GOLD TABLE 2: Sport Competitiveness Ranking
-- ============================================================
DROP TABLE IF EXISTS analytics.gold_sport_competitiveness;

CREATE TABLE analytics.gold_sport_competitiveness AS
SELECT
    sport,
    COUNT(DISTINCT noc) AS medal_winning_countries,
    RANK() OVER (
        ORDER BY COUNT(DISTINCT noc) DESC
    ) AS competitiveness_rank
FROM staging.olympics_clean
WHERE medal IS NOT NULL
GROUP BY sport;


-- ============================================================
-- GOLD TABLE 3: Decade Dominance Concentration (Clean Export)
-- ============================================================
DROP TABLE IF EXISTS analytics.gold_decade_dominance;

CREATE TABLE analytics.gold_decade_dominance AS
SELECT
    decade,
    top_country,
    top_country_medals,
    decade_total_medals,
    dominance_percentage
FROM analytics.decade_dominance_concentration
ORDER BY decade;


-- ============================================================
-- GOLD TABLE 4: Female Representation Trend
-- ============================================================
DROP TABLE IF EXISTS analytics.gold_female_representation;

CREATE TABLE analytics.gold_female_representation AS
SELECT
    decade,
    female_participation_percentage,
    female_medal_share_percentage,
    representation_gap_percentage
FROM analytics.female_representation_gap
ORDER BY decade;


-- ============================================================
-- GOLD TABLE 5: Age Medal Distribution (Clean Export)
-- ============================================================
DROP TABLE IF EXISTS analytics.gold_age_medal_distribution;

CREATE TABLE analytics.gold_age_medal_distribution AS
SELECT
    age_group,
    gold_medals,
    silver_medals,
    bronze_medals,
    total_medals
FROM analytics.age_medal_distribution
ORDER BY total_medals DESC;