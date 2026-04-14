Database Exploration
1. Introduction

After defining the project objectives, the next step was to explore the structure of the dataset used in this analysis.

Database exploration is important because it helps the analyst understand:

the tables available in the dataset

the columns and their data types

relationships between tables

which variables can be used for analysis

Understanding the structure of the data ensures that the analysis is accurate and meaningful.

2. Database System

The analysis was performed using:

PostgreSQL as the database system

DBeaver as the database client for writing and executing SQL queries

These tools allow efficient exploration, querying, and management of large datasets.

3. Tables in the Dataset

The Olympic dataset used in this project contains two main tables.

athlete_events

This table contains detailed information about athletes who participated in Olympic events.

It includes athlete demographics, sports participation, and medal outcomes.

noc_regions

This table maps National Olympic Committee (NOC) codes to their corresponding countries or regions.

This information allows the analysis to link athletes to their countries.

4. Exploring Database Tables

The first step was to identify the tables available in the database.

Example query used:

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public';

This query lists all tables available in the database schema.

5. Exploring Table Columns

Next, the columns of each table were examined to understand the available data.

Example query used:

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'athlete_events';

This query helps identify:

column names

data types

potential fields useful for analysis

6. Key Columns in athlete_events

The athlete_events table contains the following important columns.

Column	Description
id	Unique athlete identifier
name	Athlete name
sex	Athlete gender
age	Athlete age
height	Athlete height
weight	Athlete weight
team	Country team name
noc	National Olympic Committee code
year	Olympic year
season	Summer or Winter Olympics
city	Host city
sport	Sport category
event	Specific event
medal	Medal won (Gold, Silver, Bronze)

This table provides the core data used for analysis.

7. Key Columns in noc_regions

The noc_regions table provides geographic information about Olympic teams.

Column	Description
noc	National Olympic Committee code
region	Country or region name
notes	Additional notes about region changes

This table enables linking athletes to their corresponding countries or regions.

8. Table Relationship

The two tables are connected through the NOC code.

Relationship:

athlete_events.noc → noc_regions.noc

This relationship allows the analysis to associate athlete participation with geographic regions.

A JOIN operation can be used to combine the two tables.

Example:

SELECT
    a.name,
    a.sport,
    n.region
FROM athlete_events a
JOIN noc_regions n
ON a.noc = n.noc;

This join enables the analysis of athlete participation by country or region.

9. Observations from Database Exploration

From the exploration phase, several important observations were made:

The athlete_events table contains the main dataset for analysis.

The noc_regions table provides geographic mapping for countries.

The medal column indicates whether an athlete won a medal.

The year column allows time-series analysis of Olympic participation.

The sport column enables sport-level analysis.

The sex column supports gender participation analysis.

These variables form the foundation for the analytical questions defined earlier.

10. Summary

The database exploration stage provided a clear understanding of the Olympic dataset structure.

Key findings from this stage include:

identification of the main dataset tables

understanding of available variables for analysis

discovery of relationships between tables

This understanding enabled the next step of the project: data cleaning and preparation.