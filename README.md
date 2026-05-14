# 📊 Fumbgames Metrics 

# Mobile Game KPI Analysis – Technical Assessment

## Overview
This project analyses live game telemetry data to evaluate product performance using standard mobile gaming KPIs.

The dataset contains:
- User activity events
- Purchase revenue events
- Ad impression revenue events

The objective is to:
- Process raw event data
- Build meaningful KPIs
- Visualize trends
- Generate actionable insights about player behavior and monetization

---

# Dataset Schema

| Field Name | Description | Type |
|---|---|---|
| `user_id` | Unique anonymous user identifier | STRING |
| `event_name` | Name of tracked event | STRING |
| `event_date` | Date event was received (`YYMMDD`) | STRING |
| `event_timestamp` | Unix timestamp in microseconds | INTEGER |
| `ad_ilrd` | Ad impression revenue (USD) | FLOAT |
| `purchase_value` | In-app purchase revenue (USD) | FLOAT |

---

# Recommended Workflow

## 1. Data Cleaning & Preparation

### Tasks
- Convert `event_date` into proper DATE format
- Convert microsecond timestamps into TIMESTAMP/DATETIME
- Handle null revenue values
- Remove duplicate events if necessary
- Standardize event naming

### Example SQL Transformation

```sql
SELECT
    user_id,
    event_name,
    PARSE_DATE('%y%m%d', event_date) AS event_day,
    TIMESTAMP_MICROS(event_timestamp) AS event_ts,
    COALESCE(ad_ilrd, 0) AS ad_revenue,
    COALESCE(purchase_value, 0) AS purchase_revenue
FROM raw_events
```

---

# Core KPI Calculations

## 1. Daily New Users (DNU)

### Definition
Number of users seen for the first time on a given day.

### SQL Example

```sql
WITH first_seen AS (
    SELECT
        user_id,
        MIN(PARSE_DATE('%y%m%d', event_date)) AS install_date
    FROM raw_events
    GROUP BY user_id
)

SELECT
    install_date,
    COUNT(*) AS dnu
FROM first_seen
GROUP BY install_date
ORDER BY install_date;
```

### Why It Matters
Tracks user acquisition volume and growth trends.

---

## 2. Daily Active Users (DAU)

### Definition
Unique users active each day.

### SQL Example

```sql
SELECT
    PARSE_DATE('%y%m%d', event_date) AS event_day,
    COUNT(DISTINCT user_id) AS dau
FROM raw_events
GROUP BY event_day
ORDER BY event_day;
```

### Why It Matters
Measures engagement and overall product health.

---

## 3. Daily Revenue

### Definition
Total daily monetization from:
- In-app purchases
- Ad revenue

### SQL Example

```sql
SELECT
    PARSE_DATE('%y%m%d', event_date) AS event_day,
    SUM(COALESCE(ad_ilrd, 0)) AS ad_revenue,
    SUM(COALESCE(purchase_value, 0)) AS purchase_revenue,
    SUM(COALESCE(ad_ilrd, 0) + COALESCE(purchase_value, 0)) AS total_revenue
FROM raw_events
GROUP BY event_day
ORDER BY event_day;
```

### Why It Matters
Tracks monetization trends and identifies revenue spikes or declines.

---

## 4. N-Day Retention

### Definition
Percentage of users who return N days after first activity.

### Example: Day-1 Retention

```sql
WITH installs AS (
    SELECT
        user_id,
        MIN(PARSE_DATE('%y%m%d', event_date)) AS install_date
    FROM raw_events
    GROUP BY user_id
),

activity AS (
    SELECT DISTINCT
        user_id,
        PARSE_DATE('%y%m%d', event_date) AS activity_date
    FROM raw_events
)

SELECT
    install_date,
    COUNT(DISTINCT i.user_id) AS installs,
    COUNT(DISTINCT a.user_id) AS retained_users,
    SAFE_DIVIDE(COUNT(DISTINCT a.user_id),
                COUNT(DISTINCT i.user_id)) AS day1_retention
FROM installs i
LEFT JOIN activity a
    ON i.user_id = a.user_id
    AND a.activity_date = DATE_ADD(i.install_date, INTERVAL 1 DAY)
GROUP BY install_date
ORDER BY install_date;
```

### Why It Matters
Retention is one of the strongest indicators of product quality and long-term success.

---

## 5. ARPDAU (Average Revenue Per Daily Active User)

### Definition

:contentReference[oaicite:0]{index=0}

### SQL Example

```sql
WITH daily_metrics AS (
    SELECT
        PARSE_DATE('%y%m%d', event_date) AS event_day,
        COUNT(DISTINCT user_id) AS dau,
        SUM(COALESCE(ad_ilrd,0) + COALESCE(purchase_value,0)) AS revenue
    FROM raw_events
    GROUP BY event_day
)

SELECT
    event_day,
    dau,
    revenue,
    SAFE_DIVIDE(revenue, dau) AS arp_dau
FROM daily_metrics
ORDER BY event_day;
```

### Why It Matters
Shows how efficiently the game monetizes active users.

---

## 6. ARPPU (Average Revenue Per Paying User)

### Definition

:contentReference[oaicite:1]{index=1}

### SQL Example

```sql
WITH paying_users AS (
    SELECT
        PARSE_DATE('%y%m%d', event_date) AS event_day,
        COUNT(DISTINCT CASE WHEN purchase_value > 0 THEN user_id END) AS payers,
        SUM(purchase_value) AS purchase_revenue
    FROM raw_events
    GROUP BY event_day
)

SELECT
    event_day,
    payers,
    purchase_revenue,
    SAFE_DIVIDE(purchase_revenue, payers) AS arppu
FROM paying_users
ORDER BY event_day;
```

### Why It Matters
Measures monetization quality among spenders.

---

## 7. Lifetime Value (LTV)

### Definition

:contentReference[oaicite:2]{index=2}

### SQL Example

```sql
SELECT
    user_id,
    SUM(COALESCE(ad_ilrd,0) + COALESCE(purchase_value,0)) AS lifetime_value
FROM raw_events
GROUP BY user_id
ORDER BY lifetime_value DESC;
```

### Why It Matters
Critical for understanding acquisition efficiency and long-term profitability.

---

# Additional Useful Metrics

## Session Frequency
- Average events per user
- Sessions per day

## Monetization Mix
- % revenue from ads vs IAP

## Conversion Rate
- % DAU who made purchases

## Whale Analysis
Revenue concentration among top spenders.

Example:
- Top 1% users contribution
- Median vs average spend

## Cohort Analysis
Track retention and monetization by install date.

---

# Suggested Visualizations

## User Growth
- Line chart of:
  - DNU
  - DAU

## Revenue Trends
- Stacked area chart:
  - Ad revenue
  - Purchase revenue

## Retention Curves
- Day 1 / Day 7 / Day 30 retention

## Monetization Distribution
- Histogram of user lifetime revenue

## Paying User Analysis
- Boxplot of payer spend distribution

---

# Example Insights to Look For

## Healthy Indicators
- Stable or increasing DAU
- Strong Day-1 retention
- Increasing ARPDAU
- Balanced monetization sources

## Potential Problems
- High DNU but weak retention
- Revenue concentrated among very few users
- DAU declining over time
- Heavy dependence on ads or whales

---

# Example Final Assessment Structure

## 1. Executive Summary
High-level findings and recommendations.

## 2. User Acquisition
DNU trends and growth analysis.

## 3. Engagement
DAU and retention analysis.

## 4. Monetization
Revenue trends, ARPDAU, ARPPU, payer behavior.

## 5. Cohort Performance
Retention and LTV by install cohorts.

## 6. Recommendations
Product or monetization opportunities based on findings.

---

# Recommended Tech Stack

## SQL / BigQuery
Best for:
- Data transformation
- KPI calculations
- Cohort analysis

## Python (Pandas + Matplotlib/Seaborn)
Best for:
- Exploratory analysis
- Visualization
- Statistical analysis

## Jupyter Notebook
Best for:
- Reproducible analysis
- Combining code, charts, and commentary

---

# Suggested Deliverables

- SQL queries or notebook
- KPI summary tables
- Visualizations
- Short written interpretation of findings
- Optional recommendations

---

# Notes

This exercise is less about producing perfect dashboards and more about:
- Analytical thinking
- Data interpretation
- Understanding gaming KPIs
- Ability to communicate insights clearly

A concise, well-structured analysis is usually more valuable than excessive complexity.er together!

