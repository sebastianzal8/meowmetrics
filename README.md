# MeowMetrics: End-to-End Cat IoT Telemetry & Health Analytics Pipeline

MeowMetrics is a modern, production-grade data engineering repository showcasing a complete, multi-stage data pipeline. It simulates the ingestion, cleaning, transformation, and visualization of real-time telemetry from **Smart Cat Collars** (measuring heart rate, sleep duration, play activity, and purr frequency) merged with breed and registration metadata.

This repository serves as a portfolio project demonstrating expertise in **Databricks (PySpark)**, **Snowflake**, **dbt**, **Apache Airflow**, **Terraform**, **Streamlit**, and **Tableau**.

---

## 📐 Project Architecture

```mermaid
graph TD
    A[Smart Collar IoT Raw JSON] -->|S3 / ADLS Gen2 Stage| B(Databricks Bronze Layer)
    B -->|PySpark / Delta Lake| C(Databricks Silver Layer - Cleaned & De-duplicated Parquet)
    C -->|COPY INTO / Snowpipe| D[(Snowflake Raw Staging Schema)]
    D -->|dbt Models & Tests| E[(Snowflake Gold Star Schema)]
    E -->|dbt Marts & Views| F[Tableau Desktop Dashboard]
    E -->|Read via Snowflake Connector| G[Streamlit Dashboard App]
    
    subgraph Orchestration
        H[Apache Airflow DAG] -.->|Triggers| B
        H -.->|Triggers| D
        H -.->|Triggers| E
    end
    
    subgraph Infrastructure
        I[Terraform Configuration] -->|Deploys| Snowflake Schema & Storage Bucket
    end
```

### Data Pipeline Flow
1. **Ingestion & Processing (Databricks)**:
   - Raw collar IoT readings arrive in cloud storage as nested JSON files.
   - A Databricks PySpark job checks the schema, parses timestamps, flattens coordinates, filters out telemetry anomalies (e.g. invalid heart rates > 250 BPM or sleep duration > 24 hours), joins with breed registry data, and writes the structured records to Delta Lake format (Silver layer).
2. **Data Warehousing & Load (Snowflake)**:
   - Terraform builds the Snowflake warehouses, databases, schemas, stages, and integration roles.
   - Snowflake staging tables load parquet datasets from the Databricks Silver layer using optimized `COPY INTO` commands.
3. **Data Modeling & Analytics (dbt)**:
   - dbt runs transformations inside Snowflake to convert staging tables into a star schema (Gold layer).
   - Analytical models evaluate sleep metrics, activity levels, and cardiac health by breed.
   - Pre-aggregated database views are exposed to serve BI tools like Tableau.
4. **Visualization (Streamlit & Tableau)**:
   - An interactive Streamlit app queries Snowflake to show live cat statistics.
   - BI dashboards are fed via Tableau.

---

## 🛠️ Technology Stack & Skills Displayed

- **Data Lakehouse**: Databricks (Delta Lake, PySpark / Spark SQL)
- **Cloud Data Warehouse**: Snowflake (External Stages, Warehouses, Storage Integration, COPY INTO)
- **Data Build Tool**: dbt Core (Staging, Dimensions, Facts, Schema Tests, dbt Docs, Custom Singular Tests)
- **Orchestration**: Apache Airflow (Dynamic Tasks, Databricks Operator, Snowflake Operator)
- **Infrastructure as Code**: Terraform (HashiCorp Snowflake & AWS Providers, Workspace setup)
- **Visualization**: Streamlit (Python Data App), Tableau Desktop (BI Dashboard Modeling)
- **CI/CD**: GitHub Actions (Linting with Ruff/Flake8, SQL validation, YAML syntax tests)

---

## 📂 Repository Structure

- `databricks/`: PySpark notebooks for Bronze-to-Silver ETL.
- `snowflake/`: SQL scripts for initial databases, roles, stages, and loading commands.
- `dbt_project/`: Full dbt project containing staging models, dimensions, fact tables, marts, and validation tests.
- `dashboard/`: A Streamlit dashboard application to visualize cat behavior and telemetry.
- `airflow/`: Production Apache Airflow DAG demonstrating pipeline scheduling and orchestration.
- `terraform/`: Infrastructure scripts for automated environment setup.
- `.github/workflows/`: CI/CD automation rules.

---

## 🚀 How to Setup and Run

### 1. Initialize Git and Push to GitHub
If you want to host this codebase on your GitHub profile:
```bash
# In your terminal, navigate to this directory:
cd C:/Users/SSalazar11/Code/Other/meowmetrics

# Initialize Git
git init

# Add all files to staging
git add .

# Commit changes
git commit -m "feat: initial commit of MeowMetrics pipeline"

# Go to GitHub, create a new empty repository named "meowmetrics"
# Add your GitHub repository link as a remote:
git remote add origin https://github.com/YOUR_GITHUB_USERNAME/meowmetrics.git
git branch -M main

# Push the code
git push -u origin main
```

### 2. Run the Streamlit Dashboard Locally
To preview the interactive analytics panel:
```bash
cd dashboard
python -m venv venv
source venv/Scripts/activate # Windows: venv\Scripts\activate
pip install -r requirements.txt
streamlit run app.py
```
*(By default, the Streamlit app will load beautifully simulated data so recruiters can test it locally without needing a live connection to a Snowflake warehouse).*

### 3. Tableau Dashboard Connection Guide
To visualize the dbt Gold-layer outputs in **Tableau**:
1. **Pre-requisite**: Install the **Snowflake ODBC driver** on your system.
2. In Tableau, select **Connect** -> **To a Server** -> **Snowflake**.
3. Enter your Snowflake connection details:
   - **Server**: `<your_snowflake_account_identifier>.snowflakecomputing.com`
   - **Authentication**: `Username and Password` (or SSO if configured)
   - **Warehouse**: `MEOW_WH`
4. Go to **Database** `MEOW_DB` -> **Schema** `ANALYTICS` and pull in the pre-built `bi_tableau_views` tables (or the stars: `dim_cats` and `fact_collar_readings`).
5. Build worksheets mapping:
   - *Activity Heatmap*: Play activity index versus hour-of-day.
   - *Sleep Metrics by Breed*: Daily average sleep duration grouped by cat breed.
   - *Anomaly Tracker*: Heart rate excursions compared to normal baseline levels.

---

## 📈 Database Schema & dbt Modeling details
We leverage dbt to build clean dimensional models in Snowflake:
- **`dim_cats`**: Cleaned, deduplicated master cat profiles. Contains calculated properties such as human-equivalent age and weight categories.
- **`fact_collar_readings`**: Dense fact table containing hourly aggregates of collar metrics (steps, purrs, heart rate, sleeping seconds).
- **`daily_cat_health`**: Final Gold-level mart which computes rolling health scores based on sleep anomalies and active patterns.

---

*Project created by a Data Engineer as a CV portfolio project to display Databricks, Snowflake, dbt, Airflow, and Cloud Architecture proficiency.*
