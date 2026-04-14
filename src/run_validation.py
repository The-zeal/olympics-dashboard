from src.db import load_table
from src.validation import (
    check_nulls,
    check_duplicates,
    check_unique_keys,
    check_percentage_range,
    check_negative_values
)


# -------------------------------------------------------
# Load Gold Tables
# -------------------------------------------------------
df_dominance = load_table("analytics", "gold_decade_dominance")
df_gender = load_table("analytics", "gold_female_representation")
df_age = load_table("analytics", "gold_age_medal_distribution")
df_sport = load_table("analytics", "gold_sport_competitiveness")


# -------------------------------------------------------
# VALIDATION 1: Dominance Table Checks
# -------------------------------------------------------
check_nulls(df_dominance, "gold_decade_dominance")
check_duplicates(df_dominance, "decade", "gold_decade_dominance")
check_percentage_range(df_dominance, "dominance_percentage", "gold_decade_dominance")
check_negative_values(df_dominance, "top_country_medals", "gold_decade_dominance")
check_negative_values(df_dominance, "decade_total_medals", "gold_decade_dominance")


# -------------------------------------------------------
# VALIDATION 2: Female Representation Checks
# -------------------------------------------------------
check_nulls(df_gender, "gold_female_representation")
check_duplicates(df_gender, "decade", "gold_female_representation")

check_percentage_range(df_gender, "female_participation_percentage", "gold_female_representation")
check_percentage_range(df_gender, "female_medal_share_percentage", "gold_female_representation")

# Representation gap can be negative, but should not exceed -100 or +100
print("\n--- REPRESENTATION GAP RANGE CHECK ---")
invalid_gap = df_gender[(df_gender["representation_gap_percentage"] < -100) | (df_gender["representation_gap_percentage"] > 100)]
print("Invalid rows:", len(invalid_gap))


# -------------------------------------------------------
# VALIDATION 3: Age Medal Distribution Checks
# -------------------------------------------------------
check_nulls(df_age, "gold_age_medal_distribution")
check_duplicates(df_age, "age_group", "gold_age_medal_distribution")
check_negative_values(df_age, "total_medals", "gold_age_medal_distribution")


# -------------------------------------------------------
# VALIDATION 4: Sport Competitiveness Checks
# -------------------------------------------------------
check_nulls(df_sport, "gold_sport_competitiveness")
check_duplicates(df_sport, "sport", "gold_sport_competitiveness")
check_negative_values(df_sport, "medal_winning_countries", "gold_sport_competitiveness")

print("\n✅ VALIDATION COMPLETED SUCCESSFULLY")