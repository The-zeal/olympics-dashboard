import streamlit as st


def show_about():
    st.header("📘 About This Project")

    st.write("""
    ## Project Summary
    This project analyzes Olympic history using a structured SQL data warehouse pipeline.
    The goal is to generate clean reporting-ready Gold tables and visualize insights
    through an interactive Streamlit dashboard.

    ## Pipeline Architecture
    - **raw**: ingested CSV data (no transformations)
    - **staging**: cleaned and standardized dataset
    - **analytics**: reporting tables and derived insights
    - **gold**: dashboard-ready tables for visualization

    ## Data Source
    Olympic athlete-events dataset (`athlete_events.csv`).

    ## Key Metrics Explained
    - **dominance_percentage**: top country's medals / total medals in that decade
    - **female_participation_percentage**: % of athletes who are female per decade
    - **female_medal_share_percentage**: % of medals won by female athletes per decade
    - **representation_gap_percentage**: medal share % - participation %

    ## Tools Used
    - PostgreSQL
    - SQL
    - Python
    - Pandas
    - Streamlit
    - Plotly

    ## Author
    **[Your Name]**
    SQL | Data Analytics | Data Engineering Portfolio Project
    """)