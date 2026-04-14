from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
SQL_FOLDER = BASE_DIR / "sql"

def load_sql(filename: str) -> str:
    filepath = SQL_FOLDER / filename
    return filepath.read_text(encoding="utf-8")

