# Power BI SaaS Revenue Analytics Dashboard

A complete, production-grade Power BI project for SaaS Revenue Analytics. This dashboard tracks MRR, ARR, Churn Rate, CAC, LTV, and Cohort Retention — the core metrics every SaaS startup needs for board meetings and investor reporting.

## Why This Project?

Startups don't hire you for "knowing Power BI." They hire you for solving business problems end-to-end. This project demonstrates:
- **Data ingestion** from multiple cloud sources (Stripe, HubSpot, Product DB)
- **Star schema data modeling** with proper relationships and RLS
- **Advanced DAX** — time intelligence, rolling averages, cohort analysis
- **Executive-ready dashboards** with drill-through and dynamic filtering
- **Deployment maturity** — incremental refresh, gateway configuration, workspace management

## Metrics Covered

| Metric | Description | DAX Complexity |
|--------|-------------|----------------|
| MRR | Monthly Recurring Revenue | High (time intelligence) |
| ARR | Annual Recurring Revenue | Medium |
| Churn Rate | Logo + Revenue Churn | High |
| CAC | Customer Acquisition Cost | Medium |
| LTV | Lifetime Value | High (cohort-based) |
| LTV:CAC Ratio | Efficiency benchmark | Medium |
| Cohort Retention | Monthly retention by cohort | High |
| Burn Rate | Net cash burn | Medium |
| Net Revenue Retention | Expansion + Churn | High |

## Data Sources

- **Stripe** — Subscription billing, invoices, payment events
- **HubSpot** — CRM leads, deals, customer acquisition funnel
- **Product Database** — Active users, feature usage, login events
- **Internal Finance DB** — COGS, payroll, operating expenses

## Data Model (Star Schema)

```
Fact Tables:
  - fact_subscriptions (subscription_id, customer_id, plan_id, start_date, end_date, mrr)
  - fact_invoices (invoice_id, customer_id, amount, status, issue_date, paid_date)
  - fact_usage_events (event_id, customer_id, feature_id, event_date, count)
  - fact_crm_deals (deal_id, customer_id, source, cost, close_date)

Dimension Tables:
  - dim_customers (customer_id, name, segment, signup_date, region)
  - dim_plans (plan_id, plan_name, tier, monthly_price)
  - dim_date (date, year, quarter, month, month_name, fiscal_year)
  - dim_features (feature_id, feature_name, category)
  - dim_regions (region_id, region_name, country, sales_rep)
```

## Project Structure

```
PowerBI-SaaS-Revenue-Analytics-Dashboard/
├── README.md
├── LICENSE
├── .gitignore
├── DAX/
│   ├── measures.dax           # All DAX measures
│   └── calculated_columns.dax # Calculated columns
├── docs/
│   ├── data-model.md          # Data model documentation
│   ├── build-guide.md         # Step-by-step build guide
│   └── deployment.md          # Deployment & refresh strategy
├── data/
│   └── sample-schema.sql     # Sample SQL schema for fact/dim tables
├── power-query/
│   └── transformations.m      # Power Query M code
└── .pbix/
    └── README.md              # Instructions for the .pbix file
```

## Key DAX Measures (Highlights)

### MRR (Monthly Recurring Revenue)
```dax
MRR = 
CALCULATE(
    SUM(fact_subscriptions[mrr]),
    fact_subscriptions[status] = "active",
    fact_subscriptions[start_date] <= MAX(dim_date[date]),
    OR(
        fact_subscriptions[end_date] >= MAX(dim_date[date]),
        ISBLANK(fact_subscriptions[end_date])
    )
)
```

### Churn Rate (Revenue)
```dax
Revenue Churn Rate = 
VAR CurrentMRR = [MRR]
VAR PreviousMRR = CALCULATE([MRR], DATEADD(dim_date[date], -1, MONTH))
VAR LostMRR = PreviousMRR - CurrentMRR
RETURN DIVIDE(LostMRR, PreviousMRR, 0)
```

### LTV:CAC Ratio
```dax
LTV:CAC = DIVIDE([LTV], [CAC], 0)
```

### Net Revenue Retention
```dax
Net Revenue Retention = 
VAR CurrentMRR = [MRR]
VAR MRR_12_Months_Ago = CALCULATE([MRR], DATEADD(dim_date[date], -12, MONTH))
RETURN DIVIDE(CurrentMRR, MRR_12_Months_Ago, 0)
```

Full DAX code in `DAX/measures.dax`.

## Row-Level Security (RLS)

Dynamic RLS is implemented so that:
- **Executives** see all regions and segments
- **Regional Managers** see only their assigned region
- **Account Managers** see only their assigned customers

```dax
RLS_Region = 
VAR UserRegion = LOOKUPVALUE(dim_users[region], dim_users[email], USERNAME())
RETURN dim_customers[region] = UserRegion || ISBLANK(UserRegion)
```

## Dashboard Pages

1. **Executive Summary** — MRR, ARR, Churn, LTV:CAC, NRR (KPI cards + trend)
2. **Revenue Deep Dive** — MRR waterfall, plan breakdown, regional analysis
3. **Cohort Retention** — Cohort heatmap, retention curve, churn analysis
4. **Customer Acquisition** — CAC by channel, funnel conversion, payback period
5. **Usage Analytics** — Feature adoption, active users, engagement trends

## Getting Started

1. Clone this repo
2. Review the data model in `docs/data-model.md`
3. Follow the step-by-step build guide in `docs/build-guide.md`
4. Use the DAX measures from `DAX/measures.dax`
5. Apply RLS as described above

## Tech Stack

- Power BI Desktop / Power BI Service
- Power Query (M) for data transformation
- DAX for calculations
- Azure SQL / Snowflake as data warehouse
- Power BI Gateway for scheduled refresh
- Python (optional) for advanced forecasting

## License

MIT License — see [LICENSE](LICENSE)

## Connect

Built by Guptha Ashish Goud. Connect with me on [LinkedIn](https://www.linkedin.com/in/guptha-ashishgoud).

If this project helped you, give it a star! ⭐