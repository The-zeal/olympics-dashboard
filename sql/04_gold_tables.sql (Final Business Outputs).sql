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