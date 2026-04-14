import streamlit as st


def show_overview(df_dominance, df_gender, df_age, df_sport):
    st.header("📌 Overview")

    st.write("""
    This dashboard is built from PostgreSQL Gold tables generated through a structured
    SQL warehouse pipeline (Raw → Staging → Analytics → Gold).
    """)

    # KPI Metrics (Dominance)
    total_decades = df_dominance["decade"].nunique()
    avg_dominance = round(df_dominance["dominance_percentage"].mean(), 2)

    highest_dom = df_dominance.loc[df_dominance["dominance_percentage"].idxmax()]
    lowest_dom = df_dominance.loc[df_dominance["dominance_percentage"].idxmin()]

    col1, col2, col3, col4 = st.columns(4)

    col1.metric("📅 Total Decades", total_decades)
    col2.metric("📊 Avg Dominance %", f"{avg_dominance}%")
    col3.metric("🔥 Highest Dominance", f"{highest_dom['dominance_percentage']}%")
    col4.metric("❄️ Lowest Dominance", f"{lowest_dom['dominance_percentage']}%")

    st.divider()

    st.subheader("📌 Quick Insight Summary")

    st.write(f"""
    - Across **{total_decades} decades**, Olympic dominance averaged **{avg_dominance}%**.
    - The most dominant decade was **{highest_dom['decade']}**, led by **{highest_dom['top_country']}**
      with a dominance score of **{highest_dom['dominance_percentage']}%**.
    - The least dominant decade was **{lowest_dom['decade']}**, showing a more competitive Olympic era.
    """)

    st.divider()

    tab1, tab2 = st.tabs(["📊 Preview Tables", "📌 Validation Summary"])

    with tab1:
        st.subheader("Decade Dominance")
        st.dataframe(df_dominance.head(10), use_container_width=True)

        st.subheader("Gender Representation")
        st.dataframe(df_gender.head(10), use_container_width=True)

        st.subheader("Age Medal Distribution")
        st.dataframe(df_age.head(10), use_container_width=True)

        st.subheader("Sport Competitiveness")
        st.dataframe(df_sport.head(10), use_container_width=True)

    with tab2:
        st.write("### ✅ Data Validation Summary")
        st.write("Dominance Table Rows:", df_dominance.shape[0])
        st.write("Gender Table Rows:", df_gender.shape[0])
        st.write("Age Table Rows:", df_age.shape[0])
        st.write("Sport Table Rows:", df_sport.shape[0])