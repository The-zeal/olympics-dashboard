import os
import pandas as pd
from sqlalchemy import create_engine
from dotenv import load_dotenv
from urllib.parse import quote
from pathlib import Path

load_dotenv(Path(__file__).parent.parent / ".env")

def get_engine():
    user = os.getenv("DB_USER")
    password = quote_plus(st.secrets["DB_PASSWORD"])
    host = os.getenv("DB_HOST")
    port = os.getenv("DB_PORT")
    database = os.getenv("DB_NAME")
    sslmode = os.getenv("DB_SSLMODE", "require")

    connection_url = (
        f"postgresql+psycopg2://{user}:{password}@{host}:{port}/{database}"
        f"?sslmode={sslmode}"
    )
    engine = create_engine(connection_url)
    return engine

def load_table(schema, table_name):
    engine = get_engine()
    query = f"SELECT * FROM {schema}.{table_name};"
    return pd.read_sql(query, engine)

def run_query(query):
    engine = get_engine()
    return pd.read_sql(query, engine)