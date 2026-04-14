import streamlit as st
import plotly.express as px


def show_gender(df_gender):
    st.header("👩 Gender Inclusion & Representation")

    df_gender_sorted = df_gender.sort_values("decade")

    # KPI metrics
    max_participation = df_gender_sorted.loc[df_gender_sorted["female_participation_percentage"].idxmax()]
    max_medal_share = df_gender_sorted.loc[df_gender_sorted["female_medal_share_percentage"].idxmax()]
    best_gap = df_gender_sorted.loc[df_gender_sorted["representation_gap_percentage"].idxmax()]
    worst_gap = df_gender_sorted.loc[df_gender_sorted["representation_gap_percentage"].idxmin()]

    col1, col2, col3, col4 = st.columns(4)

    col1.metric("📈 Highest Participation", f"{max_participation['female_participation_percentage']}%")
    col2.metric("🏅 Highest Medal Share", f"{max_medal_share['female_medal_share_percentage']}%")
    col3.metric("✅ Best Gap", f"{best_gap['representation_gap_percentage']}%")
    col4.metric("⚠️ Worst Gap", f"{worst_gap['representation_gap_percentage']}%")

    st.divider()

    tab1, tab2, tab3 = st.tabs(["📊 Charts", "📋 Table", "📌 Insights"])

    with tab1:
        fig = px.line(
            df_gender_sorted,
            x="decade",
            y=["female_participation_percentage", "female_medal_share_percentage"],
            markers=True,
            title="Female Participation vs Female Medal Share"
        )
        st.plotly_chart(fig, use_container_width=True)

        fig2 = px.bar(
            df_gender_sorted,
            x="decade",
            y="representation_gap_percentage",
            title="Representation Gap (Medal Share - Participation)"
        )
        st.plotly_chart(fig2, use_container_width=True)

    with tab2:
        st.dataframe(df_gender_sorted, use_container_width=True)

        csv = df_gender_sorted.to_csv(index=False).encode("utf-8")
        st.download_button(
            label="⬇️ Download Gender Table",
            data=csv,
            file_name="gold_female_representation.csv",
            mime="text/csv"
        )

    with tab3:
        st.write(f"""
        ### Key Insights
        - The highest female participation occurred in **{max_participation['decade']}**
          with **{max_participation['female_participation_percentage']}%**.
        - The highest female medal share occurred in **{max_medal_share['decade']}**
          with **{max_medal_share['female_medal_share_percentage']}%**.
        - The best representation gap occurred in **{best_gap['decade']}**.
        - The worst gap occurred in **{worst_gap['decade']}**, showing under-representation in medal outcomes.
        """)