-- ============================================================
-- SaaS Revenue Analytics - Sample SQL Schema
-- ============================================================

-- Dimension: Date
CREATE TABLE dim_date (
    date DATE PRIMARY KEY,
    year INT NOT NULL,
    quarter INT NOT NULL,
    month INT NOT NULL,
    month_name VARCHAR(10) NOT NULL,
    fiscal_year INT NOT NULL,
    is_weekend BOOLEAN DEFAULT FALSE,
    is_month_end BOOLEAN DEFAULT FALSE
);

-- Dimension: Customers
CREATE TABLE dim_customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    segment VARCHAR(50) NOT NULL, -- SMB, Mid-Market, Enterprise
    signup_date DATE NOT NULL,
    region VARCHAR(50) NOT NULL,  -- APAC, EMEA, NA, LATAM
    account_manager VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Dimension: Plans
CREATE TABLE dim_plans (
    plan_id INT PRIMARY KEY,
    plan_name VARCHAR(100) NOT NULL,
    tier INT NOT NULL,
    monthly_price DECIMAL(10,2) NOT NULL
);

-- Dimension: Features
CREATE TABLE dim_features (
    feature_id INT PRIMARY KEY,
    feature_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL
);

-- Dimension: Regions
CREATE TABLE dim_regions (
    region_id INT PRIMARY KEY,
    region_name VARCHAR(50) NOT NULL,
    country VARCHAR(50) NOT NULL,
    sales_rep VARCHAR(100) NOT NULL
);

-- Fact: Subscriptions
CREATE TABLE fact_subscriptions (
    subscription_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    plan_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    mrr DECIMAL(12,2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    mrr_change_type VARCHAR(20),
    change_date DATE,
    FOREIGN KEY (customer_id) REFERENCES dim_customers(customer_id),
    FOREIGN KEY (plan_id) REFERENCES dim_plans(plan_id)
);

-- Fact: Invoices
CREATE TABLE fact_invoices (
    invoice_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    issue_date DATE NOT NULL,
    paid_date DATE,
    FOREIGN KEY (customer_id) REFERENCES dim_customers(customer_id)
);

-- Fact: Usage Events
CREATE TABLE fact_usage_events (
    event_id BIGINT PRIMARY KEY,
    customer_id INT NOT NULL,
    feature_id INT NOT NULL,
    event_date DATE NOT NULL,
    count INT NOT NULL DEFAULT 1,
    FOREIGN KEY (customer_id) REFERENCES dim_customers(customer_id),
    FOREIGN KEY (feature_id) REFERENCES dim_features(feature_id)
);

-- Fact: CRM Deals
CREATE TABLE fact_crm_deals (
    deal_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    source VARCHAR(50) NOT NULL,
    cost DECIMAL(12,2) NOT NULL,
    close_date DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES dim_customers(customer_id)
);

-- Fact: Expenses (for CAC and Burn Rate)
CREATE TABLE fact_expenses (
    expense_id INT PRIMARY KEY,
    category VARCHAR(50) NOT NULL, -- Sales, Marketing, Advertising, Engineering, etc.
    amount DECIMAL(12,2) NOT NULL,
    expense_date DATE NOT NULL
);

-- Fact: Finance (for Runway)
CREATE TABLE fact_finance (
    finance_id INT PRIMARY KEY,
    cash_balance DECIMAL(15,2) NOT NULL,
    date DATE NOT NULL
);

-- Dimension: Users (for RLS)
CREATE TABLE dim_users (
    user_id INT PRIMARY KEY,
    email VARCHAR(200) NOT NULL UNIQUE,
    role VARCHAR(50) NOT NULL, -- Executive, Regional Manager, Account Manager
    region VARCHAR(50),
    customer_id INT
);

-- Indexes for performance
CREATE INDEX idx_subscriptions_customer ON fact_subscriptions(customer_id);
CREATE INDEX idx_subscriptions_dates ON fact_subscriptions(start_date, end_date);
CREATE INDEX idx_invoices_customer ON fact_invoices(customer_id);
CREATE INDEX idx_usage_customer_date ON fact_usage_events(customer_id, event_date);

-- Sample data inserts
INSERT INTO dim_plans VALUES
    (1, 'Free', 1, 0.00),
    (2, 'Starter', 2, 999.00),
    (3, 'Pro', 3, 4999.00),
    (4, 'Enterprise', 4, 19999.00);

INSERT INTO dim_features VALUES
    (1, 'Dashboard', 'core'),
    (2, 'API Access', 'core'),
    (3, 'Advanced Analytics', 'add-on'),
    (4, 'White Label', 'add-on'),
    (5, 'AI Insights', 'beta');
