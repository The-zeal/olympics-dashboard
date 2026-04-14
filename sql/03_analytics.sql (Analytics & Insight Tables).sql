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