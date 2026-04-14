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
