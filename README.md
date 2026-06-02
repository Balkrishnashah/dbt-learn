# dbt-learn 🟠

> My first dbt project — learning analytics engineering with dbt Core + Databricks.

---

## Overview

This project was built while learning dbt (data build tool) from scratch. It covers the full analytics engineering workflow: connecting to a cloud warehouse, defining sources, building a bronze/silver/gold layer model, writing tests, seeding reference data, and snapshotting slowly changing dimensions.

**Stack:**
- dbt Core `1.11.8`
- Databricks (Free Edition) + Delta Lake
- Python `3.12` + virtualenv
- VS Code + Power User for dbt extension

---

## Project Structure

```
bk_learning_dbt/
├── models/
│   ├── bronze/          # Raw source mirrors (select * from source)
│   ├── silver/          # Cleaned, enriched, joined models
│   └── gold/            # Aggregated, business-facing models
├── seeds/               # Static CSV reference data
├── snapshots/           # SCD Type 2 history tracking
├── tests/
│   └── generic/         # Custom generic tests
├── analyses/            # Ad hoc SQL analyses (not materialized)
├── macros/              # Reusable Jinja macros
└── dbt_project.yml      # Project configuration
```

---

## Data Sources

Raw data lives in the `source` schema of the `dbt-tutorial-dev` Databricks catalog:

| Source Table     | Description                        |
|------------------|------------------------------------|
| `dim_customer`   | Customer master data               |
| `dim_date`       | Date dimension                     |
| `dim_product`    | Product reference data             |
| `dim_store`      | Store locations and details        |
| `fact_sales`     | Sales transactions                 |
| `fact_returns`   | Returns transactions               |

---

## Models

### Bronze Layer
Faithful 1:1 mirrors of source tables. Minimal transformation `select *` with source references. One model per source table.

### Silver Layer
Cleaned, joined, and enriched models. Applies business logic: column renaming, type casting, joining dimensions onto facts, filtering invalid records.

### Gold Layer
Aggregated, report-ready models. Designed for consumption by dashboards or analysts.

---

## Seeds

Small, hand-maintained CSV lookup tables loaded into the warehouse with `dbt seed`.

| Seed File              | Description                              |
|------------------------|------------------------------------------|
| `disposition_code.csv` | Debt collection disposition code mapping (PTP, RPC, etc.) |

---

## Tests

### Generic (Built-in)
- `not_null`             : flags null values in key columns
- `unique`               : flags duplicate values in unique key columns
- `accepted_values`      : flags values outside a defined list
- `generic_non_negative` : flags values less than 0

### Custom Generic Tests
Located in `tests/generic/`:

| Test                     | Description                                      |
|--------------------------|--------------------------------------------------|
| `generic_non_negative`   | Fails if a numeric column contains negative values |

---

## Snapshots

`customer_master` : tracks historical changes to customer records using SCD Type 2. Built on `bronze_customer`, stored in the `silver` schema.

- **Strategy:** `timestamp`
- **Unique key:** `customer_sk`
- **Valid-to default:** `9999-12-31` for currently active records

---

## Setup

### Prerequisites
- Python 3.12+
- A Databricks workspace (free edition works)
- A SQL Warehouse with an `http_path`

### Installation

```bash
# Clone the repo
git clone https://github.com/Balkrishnashah/dbt-learn.git
cd dbt-learn/bk_learning_dbt

# Create and activate virtual environment
python -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install requirement.txt
```

### Configure profiles.yml

dbt credentials live **outside** the project at `~/.dbt/profiles.yml` — never committed to Git.

```yaml
bk_learning_dbt:
  target: dev
  outputs:
    dev:
      type: databricks
      catalog: dbt-tutorial-dev
      schema: default
      host: <your-workspace>.cloud.databricks.com
      http_path: /sql/1.0/warehouses/<your-warehouse-id>
      token: <your-personal-access-token>
      threads: 4
      quoting:
        database: true   # Required: If catalog name contains hyphens
    prod:
      type: databricks
      catalog: dbt-tutorial-prod
      schema: default
      host: <your-workspace>.cloud.databricks.com
      http_path: /sql/1.0/warehouses/<your-warehouse-id>
      token: <your-personal-access-token>
      threads: 4
      quoting:
        database: true 
```

### Verify connection

```bash
dbt debug
```

All checks should pass before running models.

---

## Running the Project

```bash
# Load seed tables
dbt seed

# Build all models (bronze → silver → gold, in dependency order)
dbt run

# Run all tests
dbt test

# Run snapshots
dbt snapshot

# Build + test in one command
dbt build

# Generate and serve documentation
dbt docs generate
dbt docs serve
```

---

## Key Concepts Learned

| Concept | What it does |
|---|---|
| **Adapters** | Connector layer between dbt and the warehouse (dbt has no compute of its own) |
| **`ref()`** | References another model dbt resolves dependencies and build order automatically |
| **`source()`** | References raw source tables separates "data we own" from "data we ingest" |
| **Jinja templating** | `{{ }}` for expressions, `{% %}` for logic — renders into plain SQL before hitting the warehouse |
| **Materializations** | `view`, `table`, `incremental`, `ephemeral` — how dbt persists model output |
| **Seeds** | Small CSV lookup tables version-controlled alongside your models |
| **Snapshots** | SCD Type 2 history tracking captures row-level changes over time |
| **Generic tests** | `unique`, `not_null`, `accepted_values` declarative data quality in YAML |
| **Custom tests** | Write your own test logic in SQL, reference it by name in YAML |
| **`target/compiled/`** | Where dbt writes rendered SQL use this to debug Jinja output |
| **`dbt debug`** | Checks profile, connection, and project config first command to run when something's wrong |

---

## Notes

- Catalog `dbt-tutorial-dev` contains hyphens requires `quoting: database: true` in source config and profiles. Underscores in catalog names avoid this entirely.
- `profiles.yml` is intentionally excluded from this repo. Never commit credentials.
- The `target/`, `dbt_packages/`, `logs/`, and `.venv/` directories are gitignored.

---

## Author

**Balkrishna Shah**  
Senior Consultant @ Axion Connect | Data Engineering + Analytics Engineering  
[GitHub](https://github.com/Balkrishnashah) · [LinkedIn](https://www.linkedin.com/in/balkrishna-shah-b6378b182/)