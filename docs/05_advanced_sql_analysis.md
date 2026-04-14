Analytical Questions and Insights
1. Introduction

After cleaning and exploring the Olympic dataset, the next step was to perform deeper analytical queries to uncover meaningful insights.

SportsStats aims to provide interesting insights for news organizations and elite trainers, particularly trends related to participation, performance, and gender representation in sports.

The following analytical questions were developed to uncover patterns in Olympic performance and gender participation.

2. Identify the Decade with the Largest Performance Gap
Objective

The goal of this analysis was to determine which decade had the largest difference in medal counts between male and female athletes.

This helps identify periods where gender inequality in Olympic performance outcomes was most pronounced.

SQL Query
SELECT
    (year / 10) * 10 AS decade,
    COUNT(CASE WHEN sex = 'M' AND medal IS NOT NULL THEN 1 END) AS male_medals,
    COUNT(CASE WHEN sex = 'F' AND medal IS NOT NULL THEN 1 END) AS female_medals,
    ABS(
        COUNT(CASE WHEN sex = 'M' AND medal IS NOT NULL THEN 1 END) -
        COUNT(CASE WHEN sex = 'F' AND medal IS NOT NULL THEN 1 END)
    ) AS medal_gap
FROM staging.olympics_clean
GROUP BY decade
ORDER BY medal_gap DESC;
Insight

This analysis highlights which decade experienced the largest disparity in medal achievements between male and female athletes.

Historically, earlier decades tend to show larger gaps because:

fewer women participated in Olympic events

fewer sports were open to female athletes

This query helps identify when the gap was most extreme.

3. Compare Male vs Female Medal Efficiency
Objective

This analysis evaluates medal efficiency, which measures how often athletes win medals relative to participation.

Instead of only counting medals, this analysis calculates:

medals won / total participation

This provides a better understanding of performance efficiency by gender.

SQL Query
SELECT
    sex,
    COUNT(*) AS total_participation,
    COUNT(medal) AS medals_won,
    COUNT(medal) * 1.0 / COUNT(*) AS medal_efficiency
FROM staging.olympics_clean
GROUP BY sex;
Insight

This analysis compares:

total participation by gender

total medals won

medal efficiency rate

It helps determine whether one gender historically converts participation into medals more efficiently than the other.

4. Analyze Gender Equity by Country
Objective

This analysis investigates which countries show the most balanced medal distribution between male and female athletes.

The goal is to identify countries where both genders contribute strongly to Olympic success.

SQL Query
SELECT
    region,
    COUNT(CASE WHEN sex = 'M' AND medal IS NOT NULL THEN 1 END) AS male_medals,
    COUNT(CASE WHEN sex = 'F' AND medal IS NOT NULL THEN 1 END) AS female_medals,
    ABS(
        COUNT(CASE WHEN sex = 'M' AND medal IS NOT NULL THEN 1 END) -
        COUNT(CASE WHEN sex = 'F' AND medal IS NOT NULL THEN 1 END)
    ) AS gender_gap
FROM staging.olympics_clean
GROUP BY region
HAVING COUNT(medal) > 50
ORDER BY gender_gap ASC;
Insight

Countries with the smallest gender gaps indicate stronger gender balance in Olympic success.

This insight is valuable for:

sports journalists highlighting gender equity stories

trainers and analysts studying national sports development systems

5. Sport-Level Gender Expansion
Objective

The purpose of this analysis is to identify sports where female participation has grown significantly over time.

This helps highlight sports that have experienced major gender expansion in the Olympics.

SQL Query
SELECT
    sport,
    COUNT(CASE WHEN sex = 'M' THEN 1 END) AS male_participation,
    COUNT(CASE WHEN sex = 'F' THEN 1 END) AS female_participation
FROM staging.olympics_clean
GROUP BY sport
ORDER BY female_participation DESC;
Insight

This query shows which sports have:

high female participation

strong growth in women's events

It highlights how Olympic sports have evolved toward greater gender inclusion.

These trends are particularly valuable for:

sports historians

gender equity advocates

sports policy researchers

6. Summary

This stage of the project focused on answering key analytical questions related to gender representation and performance in Olympic sports.

Four major analyses were performed:

1️⃣ Identifying decades with the largest gender medal gap
2️⃣ Comparing medal efficiency between male and female athletes
3️⃣ Evaluating gender equity across countries
4️⃣ Identifying sports with strong female participation growth

These analyses reveal important historical trends in gender representation and performance in the Olympics, aligning with SportsStats’ mission of providing compelling sports insights.