# Step-by-Step Build Guide

This guide walks you through building the SaaS Revenue Analytics Dashboard from scratch in Power BI Desktop.

## Prerequisites

- Power BI Desktop (latest version)
- Access to data sources (Stripe API, HubSpot API, SQL database)
- Basic understanding of DAX and Power Query

## Step 1: Data Source Connection

### 1.1 Connect to Stripe
1. Open Power BI Desktop → Get Data → Web
2. Use Stripe API endpoint: `https://api.stripe.com/v1/invoices`
3. Add Authorization header with your Stripe API key
4. Convert to table and expand the JSON records

### 1.2 Connect to HubSpot CRM
1. Get Data → Web
2. Use HubSpot API: `https://api.hubapi.com/crm/v3/objects/deals`
3. Add Bearer token in headers
4. Expand deal properties (amount, closedate, dealstage)

### 1.3 Connect to Product Database
1. Get Data → SQL Server (or PostgreSQL)
2. Enter server and database credentials
3. Import `fact_subscriptions`, `fact_usage_events`, `dim_customers`, `dim_plans`

## Step 2: Power Query Transformations

### 2.1 Clean Subscription Data
- Remove null values in `customer_id` and `mrr`
- Convert `start_date` and `end_date` to proper date types
- Create a calculated column for `cohort_month = EOMONTH(start_date, 0)`
- Filter out test/sandbox subscriptions

### 2.2 Build Date Dimension
- Create a date table from `CALENDAR(MIN(start_date), TODAY())`
- Add columns: Year, Quarter, Month, MonthName, FiscalYear
- Mark as Date Table in Power BI (Modeling → Mark as Date Table)

### 2.3 Merge CRM Deals with Customers
- Merge `fact_crm_deals` with `dim_customers` on `customer_id`
- Expand the `region` and `segment` columns

## Step 3: Data Model Setup

1. Go to Model View
2. Create relationships:
   - `dim_date[date]` → `fact_subscriptions[start_date]` (1:*)
   - `dim_date[date]` → `fact_invoices[issue_date]` (1:*)
   - `dim_date[date]` → `fact_usage_events[event_date]` (1:*)
   - `dim_customers[customer_id]` → `fact_subscriptions[customer_id]` (1:*)
   - `dim_customers[customer_id]` → `fact_invoices[customer_id]` (1:*)
   - `dim_plans[plan_id]` → `fact_subscriptions[plan_id]` (1:*)
3. Set cross-filter direction to Single for all relationships
4. Hide technical columns (IDs) from report view

## Step 4: Add DAX Measures

1. Copy all measures from `DAX/measures.dax` in this repo
2. Create a dedicated measures table (Home → Enter Data → name it `_Measures`)
3. Add each measure to this table for organization
4. Group measures by category using display folders:
   - `Revenue` → MRR, ARR, MRR Growth
   - `Churn` → Logo Churn, Revenue Churn, NRR, GRR
   - `Acquisition` → CAC, New Customers, CAC Payback
   - `LTV` → ARPU, LTV, LTV:CAC
   - `Cohort` → Cohort Retention Rate
   - `Burn` → Monthly Burn Rate, Runway

## Step 5: Build Dashboard Pages

### Page 1: Executive Summary
- 4 KPI Cards: MRR, ARR, NRR, LTV:CAC
- Line chart: MRR trend over 12 months
- Gauge: Churn Rate vs target (target < 5%)
- Card: Active Customers count
- Slicer: Date range

### Page 2: Revenue Deep Dive
- Waterfall chart: MRR changes (New + Expansion - Contraction - Churn)
- Stacked bar: MRR by plan tier
- Matrix: MRR by region x segment
- Drill-through page: Customer-level MRR breakdown

### Page 3: Cohort Retention
- Matrix/Heatmap: Cohort month (rows) x Cohort index (columns), values = retention rate
- Line chart: Retention curves by cohort
- Conditional formatting: Color scale (green > 80%, yellow 60-80%, red < 60%)

### Page 4: Customer Acquisition
- Bar chart: CAC by acquisition channel
- Funnel chart: Lead → MQL → SQL → Customer
- Card: CAC Payback Period (months)
- Line chart: New customers per month

### Page 5: Usage Analytics
- Area chart: Daily active users trend
- Bar chart: Top 10 features by adoption rate
- Scatter plot: Usage frequency vs MRR (to find upsell opportunities)

## Step 6: Row-Level Security (RLS)

1. Go to Modeling → Manage Roles
2. Create role `Regional Manager`:
   - On `dim_customers`, add DAX filter: `[region] = LOOKUPVALUE(dim_users[region], dim_users[email], USERNAME())`
3. Create role `Account Manager`:
   - On `dim_customers`, add DAX filter: `[customer_id] IN SELECTCOLUMNS(FILTER(dim_users, [email] = USERNAME()), "cid", [customer_id])`
4. Create role `Executive` with no filter (sees everything)
5. Test roles: Modeling → View As → Select role

## Step 7: Deployment

### 7.1 Publish to Power BI Service
1. Save the .pbix file
2. Click Publish → Select workspace
3. Configure dataset credentials

### 7.2 Configure Incremental Refresh
1. In Power BI Desktop: Power Query → Right-click `fact_usage_events` → Incremental Refresh
2. Set rolling window to 5 years, incremental refresh to 1 day
3. Publish and configure in Power BI Service

### 7.3 Set Up Scheduled Refresh
1. Power BI Service → Dataset → Settings
2. Configure gateway connection
3. Set refresh schedule (e.g., daily at 6 AM IST)

### 7.4 Deploy Across Workspaces
- Use Power BI Deployment Pipelines (Premium required)
- Dev → Test → Prod pipeline
- Configure dataset rules per environment

## Step 8: Alerts & Subscriptions

1. Set data alerts on KPI cards (e.g., Churn Rate > 5%)
2. Create email subscriptions for weekly executive summary
3. Set up Teams integration for real-time alerts

## Next Steps

- Add Python visual for MRR forecasting (Prophet/ARIMA)
- Integrate with Microsoft Teams for automated weekly reports
- Build a mobile-optimized report layout
