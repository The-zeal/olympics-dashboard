# 🏅 Olympics Analytics Dashboard (SQL + Python + Streamlit)

## 📌 Project Overview
This project analyzes over 120 years of Olympic history using a structured SQL data warehouse pipeline.
Gold reporting tables were generated in PostgreSQL and visualized using an interactive Streamlit dashboard.

## 🏗️ Data Warehouse Architecture
The project follows a layered warehouse structure:

- **raw**: ingested dataset (no transformation)
- **staging**: cleaned and standardized data
- **analytics**: reporting and transformation tables
- **gold**: dashboard-ready aggregated tables

## 📊 Dashboard Features
The Streamlit dashboard provides:
- Olympic dominance trends by decade
- Female participation vs medal share analysis
- Age group medal distribution
- Sport competitiveness rankings
- Country sport specialization insights
- Top countries leaderboard
- CSV download for tables

## 🛠️ Tools & Technologies
- PostgreSQL
- SQL
- Python (Pandas, SQLAlchemy)
- Streamlit
- Plotly

## 📂 Project Structure

sql-capstone-project/
│
├── app.py
├── requirements.txt
├── README.md
├── .env
│
├── src/
│ ├── db.py
│ ├── validation.py
│ ├── business_validation.py
│ ├── utils.py
│ └── pages/
│ ├── overview.py
│ ├── leaderboard.py
│ ├── dominance.py
│ ├── gender.py
│ ├── age.py
│ ├── sport.py
│ ├── specialization.py
│ └── about.py
│
└── notebooks/


## ✅ Data Validation
Validation was performed using Python to ensure:
- No missing values in gold tables
- No duplicates in key columns
- Percentages remain within valid ranges
- Business rule checks confirm SQL calculations are correct

## 🚀 How to Run Locally

### 1. Clone Repository
```bash
git clone <your-repo-url>
cd sql-capstone-project

### 2. Create Virtual Environment
python -m venv olympics_env
source olympics_env/bin/activate   # Mac/Linux
olympics_env\Scripts\activate      # Windows

### 3. Install Dependencies
pip install -r requirements.txt

### 4. Create .env File
Create a .env file in the root folder:
DB_USER=postgres
DB_PASSWORD=your_password
DB_HOST=localhost
DB_PORT=5432
DB_NAME=sql_capstone

### 5. Run Validation
python -m src.run_validation
python -m src.business_validation

### 6. Launch Dashboard
streamlit run app.py

📌 Author

John Philemon