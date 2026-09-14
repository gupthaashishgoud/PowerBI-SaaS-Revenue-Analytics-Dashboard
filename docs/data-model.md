# Data Model Documentation

## Overview

This project uses a **Star Schema** design with 4 fact tables and 5 dimension tables. The schema is optimized for Power BI's VertiPaq engine with proper relationships, no circular dependencies, and bidirectional filtering only where necessary.

## Schema Diagram

```
                    ┌─────────────┐
                    │  dim_date   │
                    │  (date PK)  │
                    └──────┬──────┘
                           │ 1:*
           ┌───────────────┼───────────────┐
           │               │               │
    ┌──────┴──────┐ ┌──────┴──────┐ ┌─────┴───────┐
    │fact_        │ │fact_        │ │fact_usage   │
    │subscriptions│ │invoices     │ │events       │
    └──────┬──────┘ └──────┬──────┘ └─────┬───────┘
           │               │               │
           │ 1:*           │ 1:*           │ 1:*
    ┌──────┴───────────────┴───────────────┴──────┐
    │              dim_customers                   │
    └──────┬──────────────────────────┬───────────┘
           │                          │
    ┌──────┴──────┐           ┌──────┴──────┐
    │  dim_plans  │           │ dim_regions │
    └─────────────┘           └─────────────┘
```

## Fact Tables

### fact_subscriptions
| Column | Type | Description |
|--------|------|-------------|
| subscription_id | INT (PK) | Unique subscription identifier |
| customer_id | INT (FK) | Links to dim_customers |
| plan_id | INT (FK) | Links to dim_plans |
| start_date | DATE | Subscription start date |
| end_date | DATE (nullable) | NULL if active |
| mrr | DECIMAL(12,2) | Monthly recurring revenue |
| status | VARCHAR(20) | active, cancelled, paused |
| mrr_change_type | VARCHAR(20) | new, expansion, contraction, churn |
| change_date | DATE | Date of last MRR change |

### fact_invoices
| Column | Type | Description |
|--------|------|-------------|
| invoice_id | INT (PK) | Unique invoice ID |
| customer_id | INT (FK) | Links to dim_customers |
| amount | DECIMAL(12,2) | Invoice amount |
| status | VARCHAR(20) | paid, pending, failed, refunded |
| issue_date | DATE | Invoice issue date |
| paid_date | DATE (nullable) | Date payment received |

### fact_usage_events
| Column | Type | Description |
|--------|------|-------------|
| event_id | BIGINT (PK) | Unique event ID |
| customer_id | INT (FK) | Links to dim_customers |
| feature_id | INT (FK) | Links to dim_features |
| event_date | DATE | Date of usage |
| count | INT | Number of events |

### fact_crm_deals
| Column | Type | Description |
|--------|------|-------------|
| deal_id | INT (PK) | Unique deal ID |
| customer_id | INT (FK) | Links to dim_customers |
| source | VARCHAR(50) | organic, paid, referral, outbound |
| cost | DECIMAL(12,2) | Acquisition cost |
| close_date | DATE | Deal close date |

## Dimension Tables

### dim_date
| Column | Type | Description |
|--------|------|-------------|
| date | DATE (PK) | Calendar date |
| year | INT | Year (e.g., 2024) |
| quarter | INT | Quarter (1-4) |
| month | INT | Month number (1-12) |
| month_name | VARCHAR(10) | January, February, etc. |
| fiscal_year | INT | Fiscal year |
| is_weekend | BOOLEAN | TRUE for Sat/Sun |
| is_month_end | BOOLEAN | Last day of month |

### dim_customers
| Column | Type | Description |
|--------|------|-------------|
| customer_id | INT (PK) | Unique customer ID |
| name | VARCHAR(200) | Customer name |
| segment | VARCHAR(50) | SMB, Mid-Market, Enterprise |
| signup_date | DATE | Account creation date |
| region | VARCHAR(50) | APAC, EMEA, NA, LATAM |

### dim_plans
| Column | Type | Description |
|--------|------|-------------|
| plan_id | INT (PK) | Unique plan ID |
| plan_name | VARCHAR(100) | Free, Starter, Pro, Enterprise |
| tier | INT | 1-4 tier ranking |
| monthly_price | DECIMAL(10,2) | Listed monthly price |

### dim_features
| Column | Type | Description |
|--------|------|-------------|
| feature_id | INT (PK) | Unique feature ID |
| feature_name | VARCHAR(100) | Feature display name |
| category | VARCHAR(50) | core, add-on, beta |

### dim_regions
| Column | Type | Description |
|--------|------|-------------|
| region_id | INT (PK) | Unique region ID |
| region_name | VARCHAR(50) | Region display name |
| country | VARCHAR(50) | Country |
| sales_rep | VARCHAR(100) | Assigned sales rep email |

## Relationship Rules

1. All relationships are **1-to-many** from dimension to fact
2. Cross-filter direction is **single** (dimension filters fact) except where noted
3. The date dimension has an active relationship to every fact table's date column
4. No ambiguous or circular relationships exist
5. `dim_customers` is connected to all fact tables as the primary business entity

## Design Decisions

- **Surrogate keys** (INT) used for all dimension tables for faster joins
- **Date table marked as date table** in Power BI for time intelligence support
- **No calculated columns in fact tables** — all calculations done via measures
- **Incremental refresh** configured on `fact_usage_events` (high volume)
