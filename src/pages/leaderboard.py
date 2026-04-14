import streamlit as st
import plotly.express as px


def show_leaderboard(df_country_ranked, search_term=None):
    st.header("🏆 Top Countries Leaderboard")

    top_n = st.slider("Select Top N Countries", 5, 50, 10)

    df_top = df_country_ranked.sort_values("medal_rank").head(top_n)

    if search_term:
        df_country_ranked = df_country_ranked[
            df_country_ranked["noc"].str.contains(search_term, na=False)
        ]
    
    # KPI Metrics
    top_country = df_top.iloc[0]["noc"]
    top_medals = df_top.iloc[0]["total_medals"]
    total_medals_sum = df_top["total_medals"].sum()

    col1, col2, col3 = st.columns(3)
    col1.metric("🥇 #1 Country", top_country)
    col2.metric("🏅 Medals by #1", top_medals)
    col3.metric("📊 Total Medals (Top N)", total_medals_sum)

    st.divider()

    tab1, tab2, tab3 = st.tabs(["📊 Chart", "📋 Table", "📌 Insights"])

    with tab1:
        fig = px.bar(
            df_top.sort_values("total_medals"),
            x="total_medals",
            y="noc",
            orientation="h",
            title=f"Top {top_n} Countries by Total Medals"
        )
        st.plotly_chart(fig, use_container_width=True)

    with tab2:
        st.dataframe(df_top, use_container_width=True)

        csv = df_top.to_csv(index=False).encode("utf-8")
        st.download_button(
            label="⬇️ Download as CSV",
            data=csv,
            file_name="top_countries_leaderboard.csv",
            mime="text/csv"
        )

    with tab3:
        st.write(f"""
        ### Key Insights
        - The top-ranked country is **{top_country}** with **{top_medals} medals**.
        - The combined medals among the top {top_n} countries is **{total_medals_sum} medals**.
        """)