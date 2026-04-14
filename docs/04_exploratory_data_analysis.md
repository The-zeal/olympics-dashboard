Exploratory Data Analysis (EDA)
1. Introduction

Exploratory Data Analysis (EDA) is the process of examining the dataset to understand its structure, patterns, and basic statistics before conducting deeper analysis.

The goal of EDA is to:

understand the distribution of the data

identify patterns or trends

detect anomalies or unusual records

generate ideas for deeper analysis

In this project, EDA was conducted using SQL queries in DBeaver on the cleaned dataset staging.olympics_clean.

2. Understanding the Dataset Size

The first step was to determine how large the dataset is.

This provides a sense of the scale of Olympic participation recorded in the dataset.

SELECT COUNT(*) AS total_records
FROM staging.olympics_clean;

This query counts the total number of athlete-event records available for analysis.

3. Number of Unique Athletes

Since the dataset records athletes per event, some athletes appear multiple times.

To determine how many unique athletes participated:

SELECT COUNT(DISTINCT name) AS unique_athletes
FROM staging.olympics_clean;

This helps understand the true number of individuals represented in the dataset.

4. Olympic Years Covered

Next, we identified the Olympic years included in the dataset.

SELECT DISTINCT year
FROM staging.olympics_clean
ORDER BY year;

This reveals the time span of the Olympic data, which is useful for trend analysis.

5. Athlete Participation by Gender

Understanding gender participation is important for identifying historical inequalities in sports.

SELECT
    sex,
    COUNT(*) AS participation_count
FROM staging.olympics_clean
GROUP BY sex
ORDER BY participation_count DESC;

This query shows how participation differs between male and female athletes.

6. Athlete Participation by Decade

To understand how participation evolved over time, athlete records were grouped by decade.

SELECT
    (year / 10) * 10 AS decade,
    COUNT(*) AS participation_count
FROM staging.olympics_clean
GROUP BY decade
ORDER BY decade;

This reveals long-term trends in Olympic participation.

7. Most Popular Sports

Next, the dataset was analyzed to determine which sports had the highest number of athlete participations.

SELECT
    sport,
    COUNT(*) AS total_participation
FROM staging.olympics_clean
GROUP BY sport
ORDER BY total_participation DESC
LIMIT 10;

This identifies the sports with the largest athlete participation.

8. Medal Distribution

To understand medal outcomes, we analyzed how medals are distributed in the dataset.

SELECT
    medal,
    COUNT(*) AS medal_count
FROM staging.olympics_clean
WHERE medal IS NOT NULL
GROUP BY medal
ORDER BY medal_count DESC;

This shows the total number of:

Gold medals

Silver medals

Bronze medals

recorded in the dataset.

9. Country Participation

Another important exploration was identifying which countries have the most athlete participation.

SELECT
    region,
    COUNT(*) AS athlete_entries
FROM staging.olympics_clean
GROUP BY region
ORDER BY athlete_entries DESC
LIMIT 10;

This query identifies the countries with the highest Olympic participation.

10. Key Observations from EDA

The exploratory analysis revealed several important insights:

The dataset contains multiple athlete-event records, meaning athletes may appear several times.

Participation has grown significantly over time.

Some sports have much higher participation rates than others.

There are notable differences in male and female participation historically.

These findings helped guide the advanced analytical questions explored later in the project.

11. Summary

Exploratory Data Analysis helped develop an initial understanding of the Olympic dataset.

Key steps included:

examining dataset size

counting unique athletes

identifying Olympic years covered

analyzing gender participation

identifying popular sports

understanding medal distribution

analyzing country participation

These explorations provided the foundation for deeper insight analysis, including gender equity, medal efficiency, and sport-level expansion.