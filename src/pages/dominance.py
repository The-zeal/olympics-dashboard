import streamlit as st
import plotly.express as px


def show_dominance(df_dominance):
    st.header("📅 Olympic Dominance by Decade")

    df_dominance_sorted = df_dominance.sort_values("decade")

    # KPI metrics
    top_row = df_dominance_sorted.loc[df_dominance_sorted["dominance_percentage"].idxmax()]
    low_row = df_dominance_sorted.loc[df_dominance_sorted["dominance_percentage"].idxmin()]

    col1, col2, col3 = st.columns(3)
    col1.metric("🔥 Highest Dominance", f"{top_row['dominance_percentage']}%")
    col2.metric("🏆 Top Country (Peak)", top_row["top_country"])
    col3.metric("❄️ Lowest Dominance", f"{low_row['dominance_percentage']}%")

    st.divider()

    tab1, tab2, tab3 = st.tabs(["📊 Chart", "📋 Table", "📌 Insights"])

    with tab1:
        colA, colB = st.columns([2, 1])

        with colA:
            fig = px.line(
                df_dominance_sorted,
                x="decade",
                y="dominance_percentage",
                markers=True,
                title="Top Country Medal Dominance Percentage by Decade"
            )
            st.plotly_chart(fig, use_container_width=True)

        with colB:
            st.subheader("🔍 Filter by Decade")

            selected_decade = st.selectbox(
                "Select a decade",
                sorted(df_dominance_sorted["decade"].unique())
            )

            filtered = df_dominance_sorted[df_dominance_sorted["decade"] == selected_decade]
            st.dataframe(filtered, use_container_width=True)

    with tab2:
        st.dataframe(df_dominance_sorted, use_container_width=True)

        csv = df_dominance_sorted.to_csv(index=False).encode("utf-8")
        st.download_button(
            label="⬇️ Download Dominance Table",
            data=csv,
            file_name="gold_decade_dominance.csv",
            mime="text/csv"
        )

    with tab3:
        st.write(f"""
        ### Key Insights
        - The highest dominance occurred in **{top_row['decade']}**, led by **{top_row['top_country']}**.
        - The dominance score peaked at **{top_row['dominance_percentage']}%**.
        - The lowest dominance occurred in **{low_row['decade']}**, indicating stronger competition.
        """)