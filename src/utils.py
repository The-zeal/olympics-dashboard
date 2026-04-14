def apply_decade_filter(df, decade_range):
    if "decade" in df.columns:
        return df[
            (df["decade"] >= decade_range[0]) &
            (df["decade"] <= decade_range[1])
        ]
    return df