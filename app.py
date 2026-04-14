import streamlit as st
from src.db import load_table

from src.pages.leaderboard import show_leaderboard
from src.pages.overview import show_overview
from src.pages.dominance import show_dominance
from src.pages.gender import show_gender
from src.pages.age import show_age
from src.pages.sport import show_sport
from src.pages.specialization import show_specialization
from src.pages.about import show_about


st.set_page_config(page_title="Olympics Analytics Dashboard", layout="wide")


@st.cache_data
def load_gold_tables():
    df_dominance = load_table("analytics", "gold_decade_dominance")
    df_gender = load_table("analytics", "gold_female_representation")
    df_age = load_table("analytics", "gold_age_medal_distribution")
    df_sport = load_table("analytics", "gold_sport_competitiveness")
    df_specialization = load_table("analytics", "gold_country_sport_specialization")
    df_country_ranked = load_table("analytics", "country_medal_ranked")

    return df_dominance, df_gender, df_age, df_sport, df_specialization, df_country_ranked


try:
    df_dominance, df_gender, df_age, df_sport, df_specialization, df_country_ranked = load_gold_tables()
except Exception as e:
    st.error("Database connection failed. Please check your PostgreSQL settings.")
    st.exception(e)
    st.stop()

st.sidebar.markdown("## 🏅 Olympics Dashboard")
st.sidebar.caption("SQL Warehouse → Gold Tables → Streamlit BI App")
st.sidebar.divider()

st.title("🏅 Olympics Analytics Dashboard")

st.sidebar.markdown("### 🔍 Global Search")

search_term = st.sidebar.text_input("Search (Country NOC or Sport)").strip().upper()

page = st.sidebar.selectbox(
    "Select Dashboard View",
    [
        "Overview",
        "Top Countries Leaderboard",
        "Decade Dominance",
        "Gender Inclusion",
        "Age Performance",
        "Sport Competitiveness",
        "Country Specialization",
        "About This Project"
    ]
)


if page == "Overview":
    show_overview(df_dominance, df_gender, df_age, df_sport)

elif page == "Top Countries Leaderboard":
    show_leaderboard(df_country_ranked, search_term)

elif page == "Decade Dominance":
    show_dominance(df_dominance)

elif page == "Gender Inclusion":
    show_gender(df_gender)

elif page == "Age Performance":
    show_age(df_age)

elif page == "Sport Competitiveness":
    show_sport(df_sport, search_term)

elif page == "Country Specialization":
    show_specialization(df_specialization, search_term)

elif page == "About This Project":
    show_about()




st.divider()
st.caption("Built with PostgreSQL + SQL Warehouse + Python + Streamlit | Portfolio Project")


