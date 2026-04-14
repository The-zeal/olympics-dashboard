Data Cleaning and Preparation
1. Introduction

Before performing analytical queries, the dataset must be cleaned and prepared to ensure that the analysis is accurate and reliable.

Raw datasets often contain issues such as:

missing values

inconsistent data formats

duplicate records

unnecessary columns

Cleaning the dataset improves data quality and prepares it for efficient analysis.

In this project, a cleaned dataset called olympics_clean was created to serve as the primary dataset for all analytical queries.

2. Inspecting Missing Values

The first step was to examine the dataset for missing values.

Missing values can affect calculations and lead to misleading results if not handled properly.

Example query used to check missing values:

SELECT *
FROM athlete_events
WHERE age IS NULL;

Similar checks were performed for other important fields such as:

height

weight

medal

Observations:

Some athletes did not have recorded age, height, or weight.

Many records have NULL values in the medal column, which indicates that the athlete did not win a medal.

These observations helped guide the cleaning process.

3. Handling Medal Data

In the dataset, athletes who did not win a medal have NULL values in the medal column.

For analytical purposes, these values were retained because they represent non-medal performances, which are still important for participation analysis.

However, medal-based analysis specifically filters records where the medal field is not NULL.

Example:

SELECT *
FROM athlete_events
WHERE medal IS NOT NULL;
4. Joining Country Region Information

The athlete_events table only contains NOC codes, which represent National Olympic Committees.

To make the dataset more interpretable, country region information from the noc_regions table was added.

This was done using a JOIN operation.

Example:

SELECT
    a.*,
    n.region
FROM athlete_events a
LEFT JOIN noc_regions n
ON a.noc = n.noc;

This step allows the analysis to include country or region names instead of only codes.

5. Creating the Cleaned Dataset

After reviewing and preparing the data, a cleaned dataset was created to serve as the main table used for analysis.

This table combines athlete data with regional information.

Example SQL used:

CREATE TABLE staging.olympics_clean AS
SELECT
    a.id,
    a.name,
    a.sex,
    a.age,
    a.team,
    a.noc,
    n.region,
    a.year,
    a.season,
    a.sport,
    a.event,
    a.medal
FROM athlete_events a
LEFT JOIN noc_regions n
ON a.noc = n.noc;

The resulting table provides a clean and enriched dataset for further analysis.

6. Creating Additional Analytical Fields

To support time-based analysis, an additional column called decade was created.

This field groups Olympic years into decades to make long-term trends easier to analyze.

Example calculation:

(year / 10) * 10 AS decade

Example usage:

SELECT
    year,
    (year / 10) * 10 AS decade
FROM staging.olympics_clean;

This allows the analysis to evaluate trends such as participation growth by decade.

7. Benefits of the Cleaned Dataset

Creating the olympics_clean table provides several advantages:

simplifies future queries

ensures consistent data structure

integrates region information

prepares the dataset for time-series analysis

Using a cleaned dataset improves the efficiency and clarity of analytical queries.

8. Summary

The data cleaning and preparation stage transformed the raw Olympic dataset into a structured and analysis-ready format.

Key steps included:

examining missing values

understanding medal data

joining regional information

creating a cleaned dataset

generating additional analytical fields

The resulting table staging.olympics_clean serves as the foundation for all subsequent analysis in this project.