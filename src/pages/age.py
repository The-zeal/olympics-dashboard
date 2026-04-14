import streamlit as st
import plotly.express as px
import pandas as pd


def show_age(df_age):
    st.header("🎯 Medal Distribution by Age Group")

    # Correct ordering based on your SQL groups
    age_order = ["Under 20", "20-24", "25-29", "30+"]

    df_age_copy = df_age.copy()

    if "age_group" in df_age_copy.columns:
        df_age_copy["age_group"] = pd.Categorical(
            df_age_copy["age_group"],
            categories=age_order,
            ordered=True
        )

    df_age_sorted = df_age_copy.sort_values("age_group")

    # KPI Metrics
    total_medals = df_age_sorted["total_medals"].sum()
    top_group = df_age_sorted.loc[df_age_sorted["total_medals"].idxmax()]

    col1, col2 = st.columns(2)
    col1.metric("🏅 Total Medals Counted", total_medals)
    col2.metric("🥇 Best Age Group", top_group["age_group"])

    st.divider()

    tab1, tab2, tab3 = st.tabs(["📊 Chart", "📋 Table", "📌 Insights"])

    with tab1:
        fig = px.bar(
            df_age_sorted,
            x="age_group",
            y="total_medals",
            title="Total Medals by Age Group"
        )
        st.plotly_chart(fig, use_container_width=True)

    with tab2:
        st.dataframe(df_age_sorted, use_container_width=True)

        csv = df_age_sorted.to_csv(index=False).encode("utf-8")
        st.download_button(
            label="⬇️ Download Age Table",
            data=csv,
            file_name="gold_age_medal_distribution.csv",
            mime="text/csv"
        )

    with tab3:
        st.write(f"""
        ### Key Insights
        - The age group with the highest medal performance is **{top_group['age_group']}**.
        - Across all age groups, total medals counted is **{total_medals}**.
        - This distribution helps identify the peak age range for Olympic medal success.
        """)