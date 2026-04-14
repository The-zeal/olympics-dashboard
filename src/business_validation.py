from src.db import load_table


def validate_dominance_logic():
    df = load_table("analytics", "gold_decade_dominance")

    # dominance % should equal top_country_medals / decade_total_medals * 100
    df["recalc_dominance"] = round((df["top_country_medals"] / df["decade_total_medals"]) * 100, 2)

    mismatches = df[df["recalc_dominance"] != df["dominance_percentage"]]

    print("\n--- DOMINANCE LOGIC VALIDATION ---")
    print("Mismatched rows:", len(mismatches))

    if len(mismatches) > 0:
        print(mismatches)


def validate_gender_gap_logic():
    df = load_table("analytics", "gold_female_representation")

    df["recalc_gap"] = round(df["female_medal_share_percentage"] - df["female_participation_percentage"], 2)

    mismatches = df[df["recalc_gap"] != df["representation_gap_percentage"]]

    print("\n--- FEMALE GAP LOGIC VALIDATION ---")
    print("Mismatched rows:", len(mismatches))

    if len(mismatches) > 0:
        print(mismatches)


if __name__ == "__main__":
    validate_dominance_logic()
    validate_gender_gap_logic()
    print("\n✅ BUSINESS VALIDATION COMPLETED")