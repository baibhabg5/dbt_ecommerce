# dbt Ecommerce Data Pipeline

This project is an Data Engineering pipeline built using dbt Core and PostgreSQL. The objective was to understand how raw ecommerce data moves through different stages of processing, from data generation and ingestion to cleaned, enriched, and business-ready analytical datasets, gaining hands-on experience with SQL-based transformations, Docker, dbt, and the Medallion Architecture.

The pipeline starts by generating **synthetic ecommerce** and exchange-rate datasets, loads them into PostgreSQL using **dbt seeds**, processes them through the Bronze, Silver, and Gold layers, and finally produces analytical tables that can be used for business reporting and dashboards.

---

# Project Overview

The project follows the Medallion Architecture: (in dbt_projects/dbt_ecommerce/models)

- **Bronze Layer** stores the raw data with minimal transformation.
- **Silver Layer** cleans, validates, deduplicates, and enriches the Bronze data.
- **Gold Layer** creates fact and dimension tables for analytical queries and reporting.

The entire pipeline runs locally using Docker, with PostgreSQL as the data warehouse and dbt Core as the transformation tool.

---

# Project Structure

```text
dbt_ecommerce
│
├── dbt_project/
│   └── dbt_ecommerce/
│       │
│       ├── analyses/
│       │
│       ├── macros/
│       │
│       ├── models/
│       │   ├── bronze/
│       │   │   ├── bronze_sales.sql
│       │   │   └── bronze_exchange_rates.sql
│       │   │
│       │   ├── silver/
│       │   │   └── silver.sql
│       │   │
│       │   └── gold/
│       │       ├── gold_fact_orders.sql
│       │       ├── gold_dimension_customer.sql
│       │       ├── gold_dimension_product.sql
│       │       └── gold_dimension_dates.sql
│       │
│       ├── seeds/
│       │   ├── ecommerce_sales.csv
│       │   └── exchange_rates.csv
│       │
│       ├── snapshots/
│       ├── tests/
│       ├── dbt_project.yml
│       └── README.md
│
├── docs/
│   └── analytics.png
│
├── data_generator.py
├── exchange_rates.py
├── analytical_queries.sql
├── docker-compose.yml
├── Dockerfile
├── LICENSE
├── README.md
└── .gitignore
```
#Technologies Used
Python,Pandas,SQL,PostgreSQL,dbt Core,Docker,Metabase

#Running the Project

Clone the repository:
```bash
git clone <repository-url>
```
Move into the project directory:
```bash
cd dbt_ecommerce
```

Start the containers:
```bash
docker compose up -d
```
Generate the ecommerce dataset:
```bash
python3 data_generator.py
```
Generate the exchange-rate dataset:
```bash
python3 exchange_rates.py
```
Load the generated CSV files into PostgreSQL:
```bash
docker compose run --rm dbt seed --project-dir /usr/app/dbt_ecommerce
```
Run the Bronze, Silver, and Gold models:
```bash
docker compose run --rm dbt run --project-dir /usr/app/dbt_ecommerce
```
Run dbt tests:
```bash
docker compose run --rm dbt test --project-dir /usr/app/dbt_ecommerce
```
PostgreSQL runs inside Docker and can be accessed using:
```bash
docker exec -it dbt_postgres psql -U <POSTGRES_USER> -d <POSTGRES_DB>
```
#What I Learned

Working on this project helped me better understand:

SQL-based ELT pipeline design
dbt project structure
dbt seeds and models
Medallion Architecture
PostgreSQL as a data warehouse
Data cleaning and validation
CTEs and window functions
Deduplication using ROW_NUMBER()
Joining fact data with exchange-rate data
Currency conversion
INR-standardized revenue calculations
Fact and dimension table design
Dockerized data engineering workflows
Building analytical datasets for dashboards

**More importantly, it gave me practical experience in structuring a small data engineering project instead of only learning the concepts theoretically.**
---
# Acknowledgement

The overall learning path and project idea were inspired by __Jay Chandra kadiveti's dbt Data Engineering project on YouTube channel Data with Jay__.

While the tutorial helped me understand the workflow, this repository was implemented independently and includes my own project structure, Docker setup, validation scripts, documentation, generated datasets, and project organization.

# Author

Baibhab Gupta

Feedback and suggestions are always welcome.
