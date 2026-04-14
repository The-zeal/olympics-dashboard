import streamlit as st
import plotly.express as px


def show_sport(df_sport, search_term=None):
    st.header("🌍 Sport Competitiveness Ranking")

    top_n = st.slider("Select Top N Sports", 5, 30, 10)

    df_top = df_sport.sort_values("competitiveness_rank").head(top_n)
    df_top = df_top.sort_values("medal_winning_countries")

    if search_term:
        df_sport = df_sport[df_sport["sport"].str.upper().str.contains(search_term, na=False)]

    # KPI Metrics
    if len(df_sport) == 0:
        st.warning("No sports found matching your search term.")
        return
    
    most_competitive = df_sport.sort_values("competitiveness_rank").iloc[0]
    least_competitive = df_sport.sort_values("competitiveness_rank").iloc[-1]

    col1, col2, col3 = st.columns(3)
    col1.metric("🥇 Most Competitive Sport", most_competitive["sport"])
    col2.metric("🌍 Countries (Most Competitive)", most_competitive["medal_winning_countries"])
    col3.metric("⚠️ Least Competitive Sport", least_competitive["sport"])

    st.divider()

    tab1, tab2, tab3 = st.tabs(["📊 Chart", "📋 Table", "📌 Insights"])

    with tab1:
        fig = px.bar(
            df_top,
            x="medal_winning_countries",
            y="sport",
            orientation="h",
            title=f"Top {top_n} Most Competitive Sports"
        )
        st.plotly_chart(fig, use_container_width=True)

    with tab2:
        st.dataframe(df_top, use_container_width=True)

        csv = df_top.to_csv(index=False).encode("utf-8")
        st.download_button(
            label="⬇️ Download Sport Table",
            data=csv,
            file_name="gold_sport_competitiveness.csv",
            mime="text/csv"
        )

    with tab3:
        st.write(f"""
        ### Key Insights
        - The most competitive sport is **{most_competitive['sport']}** with
          **{most_competitive['medal_winning_countries']} medal-winning countries**.
        - The least competitive sport is **{least_competitive['sport']}**, meaning medals are dominated by fewer countries.
        - Competitive sports are those with many different medal-winning nations.
        """)