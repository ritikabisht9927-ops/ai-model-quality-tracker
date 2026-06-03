# AI Model Quality Tracker — SQL Project

A SQL-based project simulating a real-world AI model evaluation pipeline, inspired by work on the **Google Apparel AI Project** at GlobalLogic.

The project models how annotation teams evaluate AI-generated predictions on apparel images — tracking accuracy, flagging low-quality outputs, and generating KPI reports for stakeholders.

---

## Project Overview

| Detail | Info |
|---|---|
| Database | PostgreSQL |
| Domain | AI / ML Data Annotation |
| Rows of data | 520+ evaluations, 30 annotators, 50 apparel items |
| Key SQL concepts | CTEs, Window Functions, Views, Joins, Aggregations |

---

## Business Problem

In AI training pipelines, human annotators review model predictions to ensure quality above target benchmarks. Managers need to:
- Track **model accuracy** across product categories
- Identify **underperforming annotators or batches** early
- Generate **weekly KPI reports** for stakeholders
- Monitor **SLA compliance** (daily output targets)

This project builds the SQL infrastructure to answer all of the above.

---

## Database Schema

```
annotators          — 30 team members with team, level, and status
apparel_items       — 50 items across 10 categories (Tops, Dresses, Footwear, etc.)
model_evaluations   — 520 evaluation records (main fact table)
quality_flags       — flags raised on incorrect/ambiguous evaluations
daily_targets       — target vs actual output per annotator per day
weekly_summaries    — pre-aggregated weekly KPI summary per annotator
```

### Entity Relationship

```
annotators ──< model_evaluations >── apparel_items
                     │
              quality_flags

annotators ──< daily_targets
annotators ──< weekly_summaries
```

---

## Queries Included

| # | Query | SQL Concepts Used |
|---|---|---|
| 1 | Model accuracy by apparel category | GROUP BY, AVG, ROUND |
| 2 | Annotator performance ranking | RANK, DENSE_RANK, PARTITION BY |
| 3 | Weekly accuracy trend + rolling average | CTE, LAG, rolling window |
| 4 | Underperforming batch detection | CASE, deviation from personal avg |
| 5 | Full quality dashboard view | CREATE VIEW, LEFT JOIN, multi-window |
| Bonus | SLA compliance report | Conditional aggregation, % calculation |

---

## Sample Output — Query 2 (Annotator Ranking)

| name | team | accuracy_pct | avg_time_sec | accuracy_rank |
|---|---|---|---|---|
| Priya Sharma | Team A | 96.20 | 38.4 | 1 |
| Vikram Singh | Team B | 95.80 | 41.2 | 2 |
| Amit Kumar | Team C | 94.50 | 44.0 | 3 |
| Sneha Kapoor | Team A | 81.30 | 52.7 | 24 |

---

## How to Run

1. Install [PostgreSQL](https://www.postgresql.org/download/) (free)
2. Open **pgAdmin** or any SQL client
3. Create a new database: `CREATE DATABASE quality_tracker;`
4. Open `sql/ai_model_quality_tracker.sql`
5. Run the full file — tables, data, and queries execute in order

---

## Key Insights This Project Demonstrates

- **Model accuracy drops on hard-difficulty items** (jackets, sarees, lehenga) vs easy ones (t-shirts, sneakers) — flagged via confidence score analysis
- **Senior annotators** complete ~95 evals/week at 92%+ accuracy vs juniors at 65 evals/week at ~80%
- **Rolling 4-week average** in Query 3 smooths out weekly spikes, giving a cleaner trend line for stakeholder reporting
- **vw_quality_dashboard** view is Power BI-ready — connect directly via PostgreSQL connector

---

## Skills Demonstrated

`SQL` `PostgreSQL` `CTEs` `Window Functions` `Aggregations` `Views` `Schema Design` `Data Modelling` `KPI Reporting` `MIS Reporting`

---

## About

Built as a portfolio project to demonstrate SQL skills in the context of AI data annotation and model quality monitoring.

**Author:** Ritika Bisht  
**LinkedIn:** [linkedin.com/in/ritikabisht](https://linkedin.com/in/ritikabisht)  
**Email:** ritikabisht9927@gmail.com
