import os
import pandas as pd
from sqlalchemy import create_engine
from dotenv import load_dotenv
from urllib.parse import quote_plus
from pathlib import Path
import streamlit as st
from urllib.parse import quote_plus

load_dotenv(Path(__file__).parent.parent / ".env")

def get_engine():
    url = URL.create(
        drivername="postgresql+psycopg2",
        username=st.secrets["DB_USER"],
        password=st.secrets["DB_PASSWORD"],  # no quote_plus needed
        host=st.secrets["DB_HOST"],
        port=st.secrets["DB_PORT"],
        database=st.secrets["DB_NAME"],
    )

    return create_engine(
        url,
        connect_args={"sslmode": "require"}
    )

def load_table(schema, table_name):
    engine = get_engine()
    query = f"SELECT * FROM {schema}.{table_name};"
    return pd.read_sql(query, engine)

def run_query(query):
    engine = get_engine()
    return pd.read_sql(query, engine)