import streamlit as st
import plotly.express as px


def show_specialization(df_specialization, search_term=None):
    st.header("🏅 Country Sport Specialization")

    st.write("""
    This section highlights which sports each country performs best in,
    based on total medals won.
    """)

    if search_term:
        df_specialization = df_specialization[
            (df_specialization["noc"].str.contains(search_term, na=False)) |
            (df_specialization["sport"].str.upper().str.contains(search_term, na=False))
        ]

    # Select Country
    selected_country = st.selectbox(
        "Select a Country (NOC Code)",
        sorted(df_specialization["noc"].unique())
    )

    df_country = df_specialization[df_specialization["noc"] == selected_country]
    df_country = df_country.sort_values("total_medals", ascending=False)

    # KPI Metrics
    total_medals = df_country["total_medals"].sum()
    best_sport = df_country.iloc[0]["sport"]
    best_sport_medals = df_country.iloc[0]["total_medals"]

    col1, col2, col3 = st.columns(3)
    col1.metric("🏅 Total Medals (All Sports)", total_medals)
    col2.metric("🥇 Top Sport", best_sport)
    col3.metric("🎯 Medals in Top Sport", best_sport_medals)

    st.divider()

    tab1, tab2, tab3 = st.tabs(["📊 Chart", "📋 Table", "📌 Insights"])

    with tab1:
        top_n = st.slider("Select Top N Sports", 5, 20, 10)

        df_top_sports = df_country.head(top_n)

        fig = px.bar(
            df_top_sports.sort_values("total_medals"),
            x="total_medals",
            y="sport",
            orientation="h",
            title=f"Top {top_n} Sports for {selected_country}"
        )

        st.plotly_chart(fig, use_container_width=True)

    with tab2:
        st.dataframe(df_country, use_container_width=True)

        csv = df_country.to_csv(index=False).encode("utf-8")
        st.download_button(
            label="⬇️ Download Specialization Table",
            data=csv,
            file_name=f"{selected_country}_specialization.csv",
            mime="text/csv"
        )

    with tab3:
        st.write(f"""
        ### Key Insights
        - **{selected_country}** wins the most medals in **{best_sport}**.
        - Their total medal count across all sports is **{total_medals}**.
        - This analysis shows which sports are national strengths.
        """)