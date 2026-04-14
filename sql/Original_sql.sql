--Project Schemas

CREATE SCHEMA raw;
CREATE SCHEMA staging;
CREATE SCHEMA analytics;


--Create the Raw Table (No Transformations Yet)
CREATE TABLE raw.olympics_raw (
    id INTEGER,
    name TEXT,
    sex TEXT,
    age INTEGER,
    height INTEGER,
    weight INTEGER,
    team TEXT,
    noc TEXT,
    games TEXT,
    year INTEGER,
    season TEXT,
    city TEXT,
    sport TEXT,
    event TEXT,
    medal TEXT
);


DROP TABLE raw.olympics_raw;

--Recreate Table (All TEXT Columns)
CREATE TABLE raw.olympics_raw (
    id TEXT,
    name TEXT,
    sex TEXT,  432
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


--Use the PostgreSQL COPY Command
--Using DBeaver SQL Editor
copy raw.olympics_raw
FROM 'C:/data/sql-capstone-project/data/raw/athlete_events.csv'
DELIMITER ','
CSV HEADER;

SELECT COUNT(*) FROM raw.olympics_raw;

--Quick Null Check
SELECT
    COUNT(*) FILTER (WHERE age IS NULL) AS null_age,
    COUNT(*) FILTER (WHERE medal IS NULL) AS null_medal
FROM raw.olympics_raw;

--Step 1 — Create staging Schema
--Create Clean Staging Table
CREATE TABLE staging.olympics_clean AS
SELECT
    id::INTEGER                                  AS athlete_id,
    name,
    sex,
    
    NULLIF(age, 'NA')::INTEGER                   AS age,
    NULLIF(height, 'NA')::INTEGER                AS height,
    NULLIF(weight, 'NA')::INTEGER                AS weight,
    
    team,
    noc,
    games,
    year::INTEGER                                AS year,
    season,
    city,
    sport,
    event,
    
    NULLIF(medal, 'NA')                          AS medal,

    -- Derived Fields
    (year / 10) * 10                             AS decade,

    CASE
        WHEN NULLIF(age, 'NA')::INTEGER < 20 THEN 'Under 20'
        WHEN NULLIF(age, 'NA')::INTEGER BETWEEN 20 AND 24 THEN '20-24'
        WHEN NULLIF(age, 'NA')::INTEGER BETWEEN 25 AND 29 THEN '25-29'
        WHEN NULLIF(age, 'NA')::INTEGER >= 30 THEN '30+'
        ELSE NULL
    END                                           AS age_group,

    CASE
        WHEN medal IS NULL OR medal = 'NA' THEN 0
        ELSE 1
    END                                           AS medal_flag

FROM raw.olympics_raw;


DROP TABLE staging.olympics_clean;


--Corrected Staging Query
CREATE TABLE staging.olympics_clean AS
SELECT
    id::INTEGER                                  AS athlete_id,
    name,
    sex,
    
    NULLIF(age, 'NA')::INTEGER                   AS age,
    NULLIF(height, 'NA')::INTEGER                AS height,
    NULLIF(weight, 'NA')::INTEGER                AS weight,
    
    team,
    noc,
    games,
    year::INTEGER                                AS year,
    season,
    city,
    sport,
    event,
    
    NULLIF(medal, 'NA')                          AS medal,

    -- FIXED: Cast year again here
    (year::INTEGER / 10) * 10                    AS decade,

    CASE
        WHEN NULLIF(age, 'NA')::INTEGER < 20 THEN 'Under 20'
        WHEN NULLIF(age, 'NA')::INTEGER BETWEEN 20 AND 24 THEN '20-24'
        WHEN NULLIF(age, 'NA')::INTEGER BETWEEN 25 AND 29 THEN '25-29'
        WHEN NULLIF(age, 'NA')::INTEGER >= 30 THEN '30+'
        ELSE NULL
    END                                           AS age_group,

    CASE
        WHEN medal IS NULL OR medal = 'NA' THEN 0
        ELSE 1
    END                                           AS medal_flag

FROM raw.olympics_raw;

--Drop Staging Table
DROP TABLE staging.olympics_clean;

--Corrected Professional Staging Query
CREATE TABLE staging.olympics_clean AS
SELECT
    id::INTEGER                                  AS athlete_id,
    name,
    sex,
    
    NULLIF(age, 'NA')::INTEGER                   AS age,
    NULLIF(height, 'NA')::NUMERIC                AS height,
    NULLIF(weight, 'NA')::NUMERIC                AS weight,
    
    team,
    noc,
    games,
    year::INTEGER                                AS year,
    season,
    city,
    sport,
    event,
    
    NULLIF(medal, 'NA')                          AS medal,

    (year::INTEGER / 10) * 10                    AS decade,

    CASE
        WHEN NULLIF(age, 'NA')::INTEGER < 20 THEN 'Under 20'
        WHEN NULLIF(age, 'NA')::INTEGER BETWEEN 20 AND 24 THEN '20-24'
        WHEN NULLIF(age, 'NA')::INTEGER BETWEEN 25 AND 29 THEN '25-29'
        WHEN NULLIF(age, 'NA')::INTEGER >= 30 THEN '30+'
        ELSE NULL
    END                                           AS age_group,

    CASE
        WHEN medal IS NULL OR medal = 'NA' THEN 0
        ELSE 1
    END                                           AS medal_flag

FROM raw.olympics_raw;


--Step 3 — Validate Staging Layer
SELECT COUNT(*) FROM staging.olympics_clean;

--Data Type Verification
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'staging'
AND table_name = 'olympics_clean';

--Step 4 — Quick Data Quality Checks
SELECT COUNT(*) 
FROM staging.olympics_clean
WHERE age IS NULL;

--Medal Distribution
SELECT medal, COUNT(*)
FROM staging.olympics_clean
GROUP BY medal
ORDER BY COUNT(*) DESC;

--Country Medal Dominance

--Create Country Medal Summary Table
CREATE TABLE analytics.country_medal_summary AS
SELECT
    noc,
    COUNT(*) FILTER (WHERE medal = 'Gold')   AS gold_medals,
    COUNT(*) FILTER (WHERE medal = 'Silver') AS silver_medals,
    COUNT(*) FILTER (WHERE medal = 'Bronze') AS bronze_medals,
    COUNT(*) FILTER (WHERE medal IS NOT NULL) AS total_medals
FROM staging.olympics_clean
GROUP BY noc;

--Add Ranking Column
CREATE TABLE analytics.country_medal_ranked AS
SELECT
    *,
    RANK() OVER (ORDER BY total_medals DESC) AS medal_rank
FROM analytics.country_medal_summary;

--Quick Validation
--Top 10 Countries by Medal Count
SELECT *
FROM analytics.country_medal_ranked
ORDER BY medal_rank
LIMIT 10;

-- Country Dominance by Decade
--Create Decade Medal Summary
CREATE TABLE analytics.country_decade_medals AS
SELECT
    decade,
    noc,
    COUNT(*) FILTER (WHERE medal = 'Gold')   AS gold_medals,
    COUNT(*) FILTER (WHERE medal = 'Silver') AS silver_medals,
    COUNT(*) FILTER (WHERE medal = 'Bronze') AS bronze_medals,
    COUNT(*) FILTER (WHERE medal IS NOT NULL) AS total_medals
FROM staging.olympics_clean
GROUP BY decade, noc;

--Add Decade Ranking
CREATE TABLE analytics.country_decade_ranked AS
SELECT
    *,
    RANK() OVER (
        PARTITION BY decade
        ORDER BY total_medals DESC
    ) AS decade_rank
FROM analytics.country_decade_medals;


--Inspect Historical Leaders
SELECT *
FROM analytics.country_decade_ranked
WHERE decade_rank <= 5
ORDER BY decade, decade_rank;


--Compute Total Medals Per Decade
CREATE TABLE analytics.decade_total_medals AS
SELECT
    decade,
    SUM(total_medals) AS decade_total_medals
FROM analytics.country_decade_medals
GROUP BY decade;

--Extract Top Country Per Decade
CREATE TABLE analytics.decade_top_country AS
SELECT
    decade,
    noc,
    total_medals
FROM analytics.country_decade_ranked
WHERE decade_rank = 1;

--Calculate Dominance Percentage
CREATE TABLE analytics.decade_dominance_concentration AS
SELECT
    t.decade,
    t.noc AS top_country,
    t.total_medals AS top_country_medals,
    d.decade_total_medals,
    ROUND(
        (t.total_medals::numeric / d.decade_total_medals) * 100,
        2
    ) AS dominance_percentage
FROM analytics.decade_top_country t
JOIN analytics.decade_total_medals d
    ON t.decade = d.decade
ORDER BY t.decade;

--Export the Dominance Table
SELECT *
FROM analytics.decade_dominance_concentration
ORDER BY decade;

--Phase 4 — Gender Inclusion by Decade

--STEP 1 — Participation by Gender per Decade
CREATE TABLE analytics.gender_decade_participation AS
SELECT
    decade,
    sex,
    COUNT(DISTINCT athlete_id) AS athlete_count
FROM staging.olympics_clean
GROUP BY decade, sex
ORDER BY decade, sex;

--STEP 2 — Total Participation Per Decade
CREATE TABLE analytics.decade_total_athletes AS
SELECT
    decade,
    COUNT(DISTINCT athlete_id) AS total_athletes
FROM staging.olympics_clean
GROUP BY decade;

--STEP 3 — Calculate Female Participation %
CREATE TABLE analytics.gender_decade_percentage AS
SELECT
    g.decade,
    g.sex,
    g.athlete_count,
    d.total_athletes,
    ROUND(
        (g.athlete_count::numeric / d.total_athletes) * 100,
        2
    ) AS participation_percentage
FROM analytics.gender_decade_participation g
JOIN analytics.decade_total_athletes d
    ON g.decade = d.decade
ORDER BY g.decade, g.sex;

--STEP 4 — Inspect Results
SELECT *
FROM analytics.gender_decade_percentage;

--Medal Distribution by Gender
CREATE TABLE analytics.gender_decade_medals AS
SELECT
    decade,
    sex,
    COUNT(*) FILTER (WHERE medal IS NOT NULL) AS medal_count
FROM staging.olympics_clean
GROUP BY decade, sex
ORDER BY decade, sex;

--Phase 4B — Female Participation Growth Rate (Decade-over-Decade)
--STEP 1 — Isolate Female Participation Only
CREATE TABLE analytics.female_participation_trend AS
SELECT
    decade,
    participation_percentage
FROM analytics.gender_decade_percentage
WHERE sex = 'F'
ORDER BY decade;

--STEP 2 — Calculate Decade-over-Decade Change
CREATE TABLE analytics.female_participation_growth AS
SELECT
    decade,
    participation_percentage AS current_percentage,
    
    LAG(participation_percentage)
        OVER (ORDER BY decade) AS previous_percentage,
    
    ROUND(
        participation_percentage
        - LAG(participation_percentage)
          OVER (ORDER BY decade),
        2
    ) AS percentage_point_change,
    
    ROUND(
        (
            (participation_percentage
            - LAG(participation_percentage)
              OVER (ORDER BY decade))
            /
            LAG(participation_percentage)
              OVER (ORDER BY decade)
        ) * 100,
        2
    ) AS growth_rate_percentage

FROM analytics.female_participation_trend
ORDER BY decade;


--STEP 3 — Inspect the Results
SELECT *
FROM analytics.female_participation_growth;

--Find Highest Acceleration (Absolute Change)
SELECT *
FROM analytics.female_participation_growth
WHERE percentage_point_change IS NOT NULL
ORDER BY percentage_point_change DESC
LIMIT 1;

--Top 3 Transformative Decades
SELECT *
FROM analytics.female_participation_growth
WHERE percentage_point_change IS NOT NULL
ORDER BY percentage_point_change DESC
LIMIT 3;



--Check If Table Exists
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'analytics'
ORDER BY table_name;

DROP TABLE IF EXISTS analytics.female_decade_medals;

CREATE TABLE analytics.female_decade_medals AS
SELECT
    decade,
    COUNT(*) FILTER (WHERE medal IS NOT NULL) AS female_medals
FROM staging.olympics_clean
WHERE sex = 'F'
GROUP BY decade;

SELECT * 
FROM analytics.female_decade_medals
ORDER BY decade;

Recreate Required Tables (In Proper Order)
DROP TABLE IF EXISTS analytics.decade_total_medals_all;

CREATE TABLE analytics.decade_total_medals_all AS
SELECT
    decade,
    COUNT(*) FILTER (WHERE medal IS NOT NULL) AS total_medals
FROM staging.olympics_clean
GROUP BY decade;


DROP TABLE IF EXISTS analytics.female_medal_share;
--Calculate Female Medal Share %
CREATE TABLE analytics.female_medal_share AS
SELECT
    f.decade,
    f.female_medals,
    t.total_medals,
    ROUND(
        (f.female_medals::numeric / t.total_medals) * 100,
        2
    ) AS female_medal_share_percentage
FROM analytics.female_decade_medals f
JOIN analytics.decade_total_medals_all t
    ON f.decade = t.decade
ORDER BY f.decade;


--Combine Participation % + Medal Share %

SELECT *
FROM analytics.female_participation_trend
ORDER BY decade;

DROP TABLE IF EXISTS analytics.female_representation_gap;

CREATE TABLE analytics.female_representation_gap AS
SELECT
    p.decade,
    p.participation_percentage AS female_participation_percentage,
    m.female_medal_share_percentage,
    
    ROUND(
        m.female_medal_share_percentage
        - p.participation_percentage,
        2
    ) AS representation_gap_percentage

FROM analytics.female_participation_trend p
JOIN analytics.female_medal_share m
    ON p.decade = m.decade
ORDER BY p.decade;

SELECT *
FROM analytics.female_representation_gap
ORDER BY decade;


--Find Largest Negative Gap
SELECT *
FROM analytics.female_representation_gap
WHERE representation_gap_percentage IS NOT NULL
ORDER BY representation_gap_percentage ASC
LIMIT 1;

--Also Identify Largest Positive Gap
SELECT *
FROM analytics.female_representation_gap
WHERE representation_gap_percentage IS NOT NULL
ORDER BY representation_gap_percentage DESC
LIMIT 1;

--Compare Male vs Female Medal Efficiency
--Total Athletes by Gender Per Decade
DROP TABLE IF EXISTS analytics.gender_decade_athletes;

CREATE TABLE analytics.gender_decade_athletes AS
SELECT
    decade,
    sex,
    COUNT(DISTINCT athlete_id) AS athlete_count
FROM staging.olympics_clean
GROUP BY decade, sex;

--Medal Count by Gender Per Decade
DROP TABLE IF EXISTS analytics.gender_decade_medal_count;

CREATE TABLE analytics.gender_decade_medal_count AS
SELECT
    decade,
    sex,
    COUNT(*) FILTER (WHERE medal IS NOT NULL) AS medal_count
FROM staging.olympics_clean
GROUP BY decade, sex;

--Calculate Medal Efficiency
DROP TABLE IF EXISTS analytics.gender_medal_efficiency;

CREATE TABLE analytics.gender_medal_efficiency AS
SELECT
    a.decade,
    a.sex,
    a.athlete_count,
    m.medal_count,
    ROUND(
        (m.medal_count::numeric / a.athlete_count),
        4
    ) AS medal_efficiency
FROM analytics.gender_decade_athletes a
JOIN analytics.gender_decade_medal_count m
    ON a.decade = m.decade
    AND a.sex = m.sex
ORDER BY a.decade, a.sex;


SELECT *
FROM analytics.gender_medal_efficiency
ORDER BY decade, sex;

--Athlete Count by Country & Gender
DROP TABLE IF EXISTS analytics.country_gender_athletes;

CREATE TABLE analytics.country_gender_athletes AS
SELECT
    noc,
    sex,
    COUNT(DISTINCT athlete_id) AS athlete_count
FROM staging.olympics_clean
GROUP BY noc, sex;

--Medal Count by Country & Gender
DROP TABLE IF EXISTS analytics.country_gender_medals;

CREATE TABLE analytics.country_gender_medals AS
SELECT
    noc,
    sex,
    COUNT(*) FILTER (WHERE medal IS NOT NULL) AS medal_count
FROM staging.olympics_clean
GROUP BY noc, sex;

--Total Athletes & Medals Per Country
DROP TABLE IF EXISTS analytics.country_totals;

CREATE TABLE analytics.country_totals AS
SELECT
    noc,
    COUNT(DISTINCT athlete_id) AS total_athletes,
    COUNT(*) FILTER (WHERE medal IS NOT NULL) AS total_medals
FROM staging.olympics_clean
GROUP BY noc;

--Compute Gender Equity Metrics

DROP TABLE IF EXISTS analytics.country_gender_equity;

CREATE TABLE analytics.country_gender_equity AS
SELECT
    a.noc,
    a.sex,
    a.athlete_count,
    m.medal_count,
    t.total_athletes,
    t.total_medals,
    
    ROUND((a.athlete_count::numeric / t.total_athletes) * 100, 2)
        AS participation_percentage,
    
    ROUND((m.medal_count::numeric / t.total_medals) * 100, 2)
        AS medal_share_percentage,
    
    ROUND(
        ((m.medal_count::numeric / t.total_medals) * 100)
        -
        ((a.athlete_count::numeric / t.total_athletes) * 100),
        2
    ) AS representation_gap
    
    

FROM analytics.country_gender_athletes a
JOIN analytics.country_gender_medals m
    ON a.noc = m.noc AND a.sex = m.sex
JOIN analytics.country_totals t
    ON a.noc = t.noc
ORDER BY a.noc, a.sex;

DROP TABLE IF EXISTS analytics.country_gender_equity;

CREATE TABLE analytics.country_gender_equity AS
SELECT
    a.noc,
    a.sex,
    a.athlete_count,
    m.medal_count,
    t.total_athletes,
    t.total_medals,
    
    ROUND(
        (a.athlete_count::numeric / NULLIF(t.total_athletes, 0)) * 100,
        2
    ) AS participation_percentage,
    
    ROUND(
        (m.medal_count::numeric / NULLIF(t.total_medals, 0)) * 100,
        2
    ) AS medal_share_percentage,
    
    ROUND(
        (
            (m.medal_count::numeric / NULLIF(t.total_medals, 0)) * 100
        )
        -
        (
            (a.athlete_count::numeric / NULLIF(t.total_athletes, 0)) * 100
        ),
        2
    ) AS representation_gap

FROM analytics.country_gender_athletes a
JOIN analytics.country_gender_medals m
    ON a.noc = m.noc AND a.sex = m.sex
JOIN analytics.country_totals t
    ON a.noc = t.noc
ORDER BY a.noc, a.sex;


--Inspect Female Equity by Country
SELECT *
FROM analytics.country_gender_equity
WHERE sex = 'F'
ORDER BY representation_gap DESC;


--Create Gender Gap by Decade Table
DROP TABLE IF EXISTS analytics.gender_decade_gap;

CREATE TABLE analytics.gender_decade_gap AS
WITH decade_participation AS (
    SELECT
        decade,
        sex,
        COUNT(*) AS athlete_count
    FROM staging.olympics_clean
    GROUP BY decade, sex
),
decade_totals AS (
    SELECT
        decade,
        SUM(athlete_count) AS total_athletes
    FROM decade_participation
    GROUP BY decade
),
participation_percentages AS (
    SELECT
        p.decade,
        p.sex,
        p.athlete_count,
        t.total_athletes,
        (p.athlete_count::numeric / t.total_athletes) * 100 AS participation_pct
    FROM decade_participation p
    JOIN decade_totals t
        ON p.decade = t.decade
)
SELECT
    decade,
    MAX(CASE WHEN sex = 'M' THEN participation_pct END) AS male_participation_pct,
    MAX(CASE WHEN sex = 'F' THEN participation_pct END) AS female_participation_pct,
    MAX(CASE WHEN sex = 'M' THEN participation_pct END)
    -
    MAX(CASE WHEN sex = 'F' THEN participation_pct END) AS gender_gap_percentage
FROM participation_percentages
GROUP BY decade
ORDER BY decade;

--Identify the Largest Gender Gap

SELECT *
FROM analytics.gender_decade_gap
ORDER BY ABS(gender_gap_percentage) DESC
LIMIT 1;

---Structural Cause of Largest Gender Gap
--STEP 0 — Identify the Decade With Largest Gap
SELECT decade, gender_gap_percentage
FROM analytics.gender_decade_gap
ORDER BY ABS(gender_gap_percentage) DESC
LIMIT 1;


-- Replace with your decade
WITH gap_decade AS (
    SELECT 1890 AS target_decade
)
SELECT decade, gender_gap_percentage
FROM analytics.gender_decade_gap
ORDER BY ABS(gender_gap_percentage) DESC
LIMIT 1;

--Event Availability Analysis
DROP TABLE IF EXISTS analytics.decade_event_gender_distribution;

CREATE TABLE analytics.decade_event_gender_distribution AS
SELECT
    decade,
    sex,
    COUNT(DISTINCT event) AS event_count
FROM staging.olympics_clean
GROUP BY decade, sex;


SELECT *
FROM analytics.decade_event_gender_distribution
WHERE decade = 1900
ORDER BY sex;


--Sport Distribution Imbalance
SELECT
    sport,
    sex,
    COUNT(DISTINCT event) AS event_count
FROM staging.olympics_clean
WHERE decade = 1900
GROUP BY sport, sex
ORDER BY sport, sex;

--Medal Concentration Effect
SELECT
    sport,
    sex,
    COUNT(*) FILTER (WHERE medal IS NOT NULL) AS medal_count
FROM staging.olympics_clean
WHERE decade = 1900
GROUP BY sport, sex
ORDER BY medal_count DESC;

--Largest Positive Performance Gap
SELECT *
FROM analytics.female_representation_gap
ORDER BY representation_gap_percentage DESC
LIMIT 1;


--Female Participation by Sport and Decade
DROP TABLE IF EXISTS analytics.sport_female_participation;

CREATE TABLE analytics.sport_female_participation AS
SELECT
    sport,
    decade,
    COUNT(*) AS female_athletes
FROM staging.olympics_clean
WHERE sex = 'F'
GROUP BY sport, decade
ORDER BY sport, decade;

--Identify First Decade Women Appeared in Each Sport
DROP TABLE IF EXISTS analytics.sport_female_entry;

CREATE TABLE analytics.sport_female_entry AS
SELECT
    sport,
    MIN(decade) AS first_female_decade
FROM staging.olympics_clean
WHERE sex = 'F'
GROUP BY sport
ORDER BY first_female_decade;

--Identify Sports Driving Female Expansion
SELECT
    sport,
    MIN(decade) AS first_decade,
    MAX(decade) AS latest_decade,
    COUNT(*) FILTER (WHERE sex='F') AS total_female_entries
FROM staging.olympics_clean
GROUP BY sport
ORDER BY total_female_entries DESC;

--Detect Late-Opening Sports
SELECT *
FROM analytics.sport_female_entry
ORDER BY first_female_decade DESC
LIMIT 10;


--Age & Peak Performance Analysis
--Create Age Groups
DROP TABLE IF EXISTS analytics.age_groups;

CREATE TABLE analytics.age_groups AS
SELECT
    sport,
    age,
    medal,
    
    CASE
        WHEN age < 18 THEN 'Under 18'
        WHEN age BETWEEN 18 AND 21 THEN '18-21'
        WHEN age BETWEEN 22 AND 25 THEN '22-25'
        WHEN age BETWEEN 26 AND 29 THEN '26-29'
        WHEN age BETWEEN 30 AND 34 THEN '30-34'
        WHEN age >= 35 THEN '35+'
    END AS age_group

FROM staging.olympics_clean
WHERE age IS NOT NULL;

--Medal Distribution by Age Group
DROP TABLE IF EXISTS analytics.age_medal_distribution;

CREATE TABLE analytics.age_medal_distribution AS
SELECT
    age_group,
    COUNT(*) FILTER (WHERE medal = 'Gold') AS gold_medals,
    COUNT(*) FILTER (WHERE medal = 'Silver') AS silver_medals,
    COUNT(*) FILTER (WHERE medal = 'Bronze') AS bronze_medals,
    COUNT(*) FILTER (WHERE medal IS NOT NULL) AS total_medals
FROM analytics.age_groups
GROUP BY age_group
ORDER BY total_medals DESC;

--Peak Age by Sport
DROP TABLE IF EXISTS analytics.sport_peak_age;

CREATE TABLE analytics.sport_peak_age AS
SELECT
    sport,
    age_group,
    COUNT(*) FILTER (WHERE medal IS NOT NULL) AS medal_count
FROM analytics.age_groups
GROUP BY sport, age_group;

SELECT
    sport,
    age_group,
    medal_count
FROM (
    SELECT
        sport,
        age_group,
        medal_count,
        RANK() OVER (
            PARTITION BY sport
            ORDER BY medal_count DESC
        ) AS age_rank
    FROM analytics.sport_peak_age
) ranked
WHERE age_rank = 1
ORDER BY medal_count DESC;

--Detect Sports with Late Peak Ages
SELECT *
FROM analytics.sport_peak_age
WHERE age_group IN ('30-34','35+')
ORDER BY medal_count DESC;


--Largest Negative Performance Gap
SELECT *
FROM analytics.female_representation_gap
ORDER BY representation_gap_percentage ASC
LIMIT 1;

--Top 5 Largest Gaps (Best Practice)
SELECT *
FROM analytics.female_representation_gap
ORDER BY ABS(representation_gap_percentage) DESC
LIMIT 5;


--Total Athletes by Gender
DROP TABLE IF EXISTS analytics.gender_total_athletes;

CREATE TABLE analytics.gender_total_athletes AS
SELECT
    sex,
    COUNT(DISTINCT athlete_id) AS total_athletes
FROM staging.olympics_clean
GROUP BY sex;


SELECT *
FROM analytics.gender_total_athletes;


--Total Medals by Gender
DROP TABLE IF EXISTS analytics.gender_total_medals;

CREATE TABLE analytics.gender_total_medals AS
SELECT
    sex,
    COUNT(*) FILTER (WHERE medal IS NOT NULL) AS total_medals
FROM staging.olympics_clean
GROUP BY sex;

SELECT *
FROM analytics.gender_total_medals;


--Compute Medal Efficiency
DROP TABLE IF EXISTS analytics.gender_medal_efficiency;

CREATE TABLE analytics.gender_medal_efficiency AS
SELECT
    a.sex,
    a.total_athletes,
    m.total_medals,

    ROUND(
        (m.total_medals::numeric / a.total_athletes),
        4
    ) AS medal_efficiency

FROM analytics.gender_total_athletes a
JOIN analytics.gender_total_medals m
    ON a.sex = m.sex;

SELECT *
FROM analytics.gender_medal_efficiency;


--Gender Equity by Country

--Male vs Female Medal Count by Country
DROP TABLE IF EXISTS analytics.country_gender_medals;

CREATE TABLE analytics.country_gender_medals AS
SELECT
    noc,
    sex,
    COUNT(*) FILTER (WHERE medal IS NOT NULL) AS medal_count
FROM staging.olympics_clean
GROUP BY noc, sex;

SELECT *
FROM analytics.country_gender_medals
ORDER BY noc, sex;

--Total Medals per Country
DROP TABLE IF EXISTS analytics.country_total_medals;

CREATE TABLE analytics.country_total_medals AS
SELECT
    noc,
    COUNT(*) FILTER (WHERE medal IS NOT NULL) AS total_medals
FROM staging.olympics_clean
GROUP BY noc;

SELECT *
FROM analytics.country_total_medals
ORDER BY total_medals DESC;

--Extract Female Medal Count
DROP TABLE IF EXISTS analytics.country_female_medals;

CREATE TABLE analytics.country_female_medals AS
SELECT
    noc,
    medal_count AS female_medals
FROM analytics.country_gender_medals
WHERE sex = 'F';

SELECT *
FROM analytics.country_female_medals
ORDER BY female_medals DESC;


--Compute Female Medal Share %
DROP TABLE IF EXISTS analytics.country_gender_equity;

CREATE TABLE analytics.country_gender_equity AS
SELECT
    t.noc,
    t.total_medals,
    f.female_medals,

    ROUND(
        (f.female_medals::numeric / t.total_medals) * 100,
        2
    ) AS female_medal_share_percentage

FROM analytics.country_total_medals t
JOIN analytics.country_female_medals f
    ON t.noc = f.noc
ORDER BY female_medal_share_percentage DESC;


DROP TABLE IF EXISTS analytics.country_gender_equity;

CREATE TABLE analytics.country_gender_equity AS
SELECT
    t.noc,
    t.total_medals,
    f.female_medals,

    ROUND(
        (f.female_medals::numeric / NULLIF(t.total_medals, 0)) * 100,
        2
    ) AS female_medal_share_percentage

FROM analytics.country_total_medals t
JOIN analytics.country_female_medals f
    ON t.noc = f.noc
ORDER BY female_medal_share_percentage DESC;

SELECT *
FROM analytics.country_gender_equity
ORDER BY female_medal_share_percentage DESC;


--Participation by Sport and Gender
DROP TABLE IF EXISTS analytics.sport_gender_participation;

CREATE TABLE analytics.sport_gender_participation AS
SELECT
    sport,
    sex,
    COUNT(DISTINCT athlete_id) AS athlete_count
FROM staging.olympics_clean
GROUP BY sport, sex
ORDER BY sport, sex;


SELECT *
FROM analytics.sport_gender_participation
ORDER BY sport, sex;

--Total Athletes Per Sport
DROP TABLE IF EXISTS analytics.sport_total_athletes;

CREATE TABLE analytics.sport_total_athletes AS
SELECT
    sport,
    COUNT(DISTINCT athlete_id) AS total_athletes
FROM staging.olympics_clean
GROUP BY sport;

--Female Participation % by Sport
DROP TABLE IF EXISTS analytics.sport_female_percentage;

CREATE TABLE analytics.sport_female_percentage AS
SELECT
    g.sport,
    g.athlete_count AS female_athletes,
    t.total_athletes,

    ROUND(
        (g.athlete_count::numeric / t.total_athletes) * 100,
        2
    ) AS female_participation_percentage

FROM analytics.sport_gender_participation g
JOIN analytics.sport_total_athletes t
    ON g.sport = t.sport
WHERE g.sex = 'F'
ORDER BY female_participation_percentage DESC;

SELECT *
FROM analytics.sport_female_percentage
ORDER BY female_participation_percentage DESC;


--Explore the Age Data
SELECT
    MIN(age) AS youngest_athlete,
    MAX(age) AS oldest_athlete,
    AVG(age) AS average_age
FROM staging.olympics_clean
WHERE age IS NOT NULL;

--Create Athlete Age Groups
DROP TABLE IF EXISTS analytics.age_grouped_athletes;

CREATE TABLE analytics.age_grouped_athletes AS
SELECT
    sport,
    age,
    medal,
    
    CASE
        WHEN age < 18 THEN 'Under 18'
        WHEN age BETWEEN 18 AND 21 THEN '18–21'
        WHEN age BETWEEN 22 AND 25 THEN '22–25'
        WHEN age BETWEEN 26 AND 29 THEN '26–29'
        WHEN age BETWEEN 30 AND 34 THEN '30–34'
        WHEN age >= 35 THEN '35+'
    END AS age_group

FROM staging.olympics_clean
WHERE age IS NOT NULL;

--Medal Distribution by Age Group
DROP TABLE IF EXISTS analytics.age_medal_distribution;

CREATE TABLE analytics.age_medal_distribution AS
SELECT
    age_group,
    COUNT(*) FILTER (WHERE medal = 'Gold') AS gold_medals,
    COUNT(*) FILTER (WHERE medal = 'Silver') AS silver_medals,
    COUNT(*) FILTER (WHERE medal = 'Bronze') AS bronze_medals,
    COUNT(*) FILTER (WHERE medal IS NOT NULL) AS total_medals
FROM analytics.age_grouped_athletes
GROUP BY age_group
ORDER BY total_medals DESC;

SELECT *
FROM analytics.age_medal_distribution;

--Identify Peak Age by Sport
DROP TABLE IF EXISTS analytics.sport_age_medals;

CREATE TABLE analytics.sport_age_medals AS
SELECT
    sport,
    age_group,
    COUNT(*) FILTER (WHERE medal IS NOT NULL) AS medal_count
FROM analytics.age_grouped_athletes
GROUP BY sport, age_group;

SELECT
    sport,
    age_group,
    medal_count
FROM (
    SELECT
        sport,
        age_group,
        medal_count,
        RANK() OVER (
            PARTITION BY sport
            ORDER BY medal_count DESC
        ) AS age_rank
    FROM analytics.sport_age_medals
) ranked
WHERE age_rank = 1
ORDER BY medal_count DESC;

--Identify Late-Peak Sports
SELECT
    sport,
    age_group,
    medal_count
FROM analytics.sport_age_medals
WHERE age_group IN ('30–34','35+')
ORDER BY medal_count DESC;


--Sport Specialization by Country
--Create Country–Sport Medal Table
DROP TABLE IF EXISTS analytics.country_sport_medals;

CREATE TABLE analytics.country_sport_medals AS
SELECT
    noc,
    sport,
    COUNT(*) FILTER (WHERE medal = 'Gold') AS gold_medals,
    COUNT(*) FILTER (WHERE medal = 'Silver') AS silver_medals,
    COUNT(*) FILTER (WHERE medal = 'Bronze') AS bronze_medals,
    COUNT(*) FILTER (WHERE medal IS NOT NULL) AS total_medals
FROM staging.olympics_clean
GROUP BY noc, sport;

--Rank Countries Within Each Sport
DROP TABLE IF EXISTS analytics.country_sport_ranked;

CREATE TABLE analytics.country_sport_ranked AS
SELECT
    *,
    RANK() OVER (
        PARTITION BY sport
        ORDER BY total_medals DESC
    ) AS sport_rank
FROM analytics.country_sport_medals;


--Identify Dominant Countries Per Sport
SELECT
    sport,
    noc,
    total_medals
FROM analytics.country_sport_ranked
WHERE sport_rank = 1
ORDER BY total_medals DESC;

--Detect Strong Specialization
SELECT
    sport,
    COUNT(DISTINCT noc) AS medal_countries
FROM staging.olympics_clean
WHERE medal IS NOT NULL
GROUP BY sport
ORDER BY medal_countries ASC;


--Competitive Diversity by Sport

--Count Medal-Winning Countries per Sport
DROP TABLE IF EXISTS analytics.sport_competitiveness;

CREATE TABLE analytics.sport_competitiveness AS
SELECT
    sport,
    COUNT(DISTINCT noc) AS medal_winning_countries
FROM staging.olympics_clean
WHERE medal IS NOT NULL
GROUP BY sport
ORDER BY medal_winning_countries DESC;


--Identify the Most Globally Competitive Sports
SELECT *
FROM analytics.sport_competitiveness
ORDER BY medal_winning_countries DESC
LIMIT 10;

--Identify the Most Concentrated Sports
SELECT *
FROM analytics.sport_competitiveness
ORDER BY medal_winning_countries ASC
LIMIT 10;

--Measure Medal Concentration (Advanced Insight)
SELECT
    sport,
    noc,
    total_medals,
    ROUND(
        total_medals * 100.0 /
        SUM(total_medals) OVER (PARTITION BY sport),
        2
    ) AS medal_share_percentage
FROM analytics.country_sport_medals
ORDER BY sport, medal_share_percentage DESC;


--Regional Participation Growth
--Create a Country → Region Mapping Table
DROP TABLE IF EXISTS analytics.noc_regions;

CREATE TABLE analytics.noc_regions (
    noc VARCHAR PRIMARY KEY,
    region VARCHAR
);

--Insert Example Regional Mapping
INSERT INTO analytics.noc_regions (noc, region) VALUES
('USA','North America'),
('CAN','North America'),
('MEX','North America'),

('BRA','South America'),
('ARG','South America'),

('GBR','Europe'),
('FRA','Europe'),
('GER','Europe'),
('ITA','Europe'),
('ESP','Europe'),

('CHN','Asia'),
('JPN','Asia'),
('KOR','Asia'),
('IND','Asia'),

('KEN','Africa'),
('ETH','Africa'),
('RSA','Africa'),
('EGY','Africa'),

('AUS','Oceania'),
('NZL','Oceania');


--Participation by Region and Decade

--Identify Fastest Growing Regions
SELECT
    region,
    MIN(athlete_count) AS earliest_participation,
    MAX(athlete_count) AS latest_participation,
    MAX(athlete_count) - MIN(athlete_count) AS participation_growth
FROM analytics.region_participation_decade
GROUP BY region
ORDER BY participation_growth DESC;


--Identify First Olympic Participation by Region
SELECT
    region,
    MIN(decade) AS first_participation_decade
FROM analytics.region_participation_decade
GROUP BY region
ORDER BY first_participation_decade;

--GOLD TABLE 1 — Sport Specialization by Country
CREATE TABLE analytics.gold_country_sport_specialization AS
SELECT
    noc,
    sport,
    total_medals,
    RANK() OVER (
        PARTITION BY noc
        ORDER BY total_medals DESC
    ) AS sport_rank
FROM analytics.country_sport_medals;


SELECT *
FROM analytics.gold_country_sport_specialization
WHERE sport_rank = 1
ORDER BY total_medals DESC;


--Sport Competitive Diversity
CREATE TABLE analytics.gold_sport_competitiveness AS
SELECT
    sport,
    medal_winning_countries,
    RANK() OVER (
        ORDER BY medal_winning_countries DESC
    ) AS competitiveness_rank
FROM analytics.sport_competitiveness;


SELECT *
FROM analytics.gold_sport_competitiveness
ORDER BY competitiveness_rank
LIMIT 10;


--Regional Participation Growth
CREATE TABLE analytics.gold_region_participation_growth AS
SELECT
    region,
    decade,
    athlete_count,
    athlete_count 
    - LAG(athlete_count) OVER (
        PARTITION BY region
        ORDER BY decade
    ) AS participation_growth
FROM analytics.region_participation_decade
ORDER BY region, decade;



SELECT
    region,
    SUM(participation_growth) AS total_growth
FROM analytics.gold_region_participation_growth
GROUP BY region
ORDER BY total_growth DESC;

SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema = 'analytics';


SELECT COUNT(*)
FROM staging.olympics_clean;


SELECT table_schema, table_name
FROM information_schema.tables
ORDER BY table_schema, table_name;