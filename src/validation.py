import pandas as pd


def check_nulls(df: pd.DataFrame, table_name: str):
    """Checks missing values in each column."""
    print(f"\n--- NULL CHECK: {table_name} ---")
    nulls = df.isnull().sum()
    print(nulls)


def check_duplicates(df: pd.DataFrame, column: str, table_name: str):
    """Checks duplicate values in a key column."""
    print(f"\n--- DUPLICATE CHECK: {table_name} ({column}) ---")
    duplicates = df[column].duplicated().sum()
    print(f"Duplicates in {column}: {duplicates}")


def check_unique_keys(df: pd.DataFrame, columns: list, table_name: str):
    """Checks duplicates based on multiple columns (composite keys)."""
    print(f"\n--- COMPOSITE KEY CHECK: {table_name} {columns} ---")
    duplicates = df.duplicated(subset=columns).sum()
    print(f"Duplicate rows based on {columns}: {duplicates}")


def check_percentage_range(df: pd.DataFrame, column: str, table_name: str):
    """Checks that percentage values fall between 0 and 100."""
    print(f"\n--- PERCENTAGE RANGE CHECK: {table_name} ({column}) ---")

    invalid = df[(df[column] < 0) | (df[column] > 100)]

    if len(invalid) == 0:
        print("✅ All values are within 0 - 100.")
    else:
        print(f"❌ Found {len(invalid)} invalid rows.")
        print(invalid)


def check_negative_values(df: pd.DataFrame, column: str, table_name: str):
    """Checks for negative values in numeric columns where negatives should not exist."""
    print(f"\n--- NEGATIVE VALUE CHECK: {table_name} ({column}) ---")

    invalid = df[df[column] < 0]

    if len(invalid) == 0:
        print("✅ No negative values found.")
    else:
        print(f"❌ Found {len(invalid)} negative values.")
        print(invalid)


def summary_stats(df: pd.DataFrame, table_name: str):
    """Print basic descriptive statistics."""
    print(f"\n--- SUMMARY STATS: {table_name} ---")
    print(df.describe(include="all"))