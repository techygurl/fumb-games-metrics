# 📊 Fumbgames Metrics 

This repository contains SQL scripts used to clean, transform, and analyze gameplay and monetization data from the Fumbgames platform.

---

## 📂 File: `fumbgames metrics query.sql`

### 🔧 Overview
The SQL script includes the following key steps:

1. **Data Cleaning**
   - Standardizes `event_date` by converting it to a proper `DATE` format.
   - Adds a new column `formatted_date` and drops the original `event_date`.

2. **Data Transformation**
   - Converts purchase values from `VARCHAR` to `FLOAT` to allow for aggregation.
   - Calculates metrics such as:
     - Total revenue per day
     - Average revenue per user per day
     - Daily active users

3. **Metric Calculation**
   - Uses aggregation functions to compute daily customer metrics:
     ```sql
     SELECT 
         formatted_date AS event_date,
         COUNT(DISTINCT user_id) AS active_users,
         SUM(CAST(purchase_value AS FLOAT)) AS total_revenue,
         SUM(CAST(purchase_value AS FLOAT)) / COUNT(DISTINCT user_id) AS ltv_per_user
     FROM 
         [dbo].[test_data]
     WHERE 
         TRY_CAST(purchase_value AS FLOAT) > 0
     GROUP BY 
         formatted_date
     ORDER BY 
         formatted_date;
     ```

---

## 💡 Purpose

This script helps track monetization trends and user behavior across different dates, making it easier to analyze:

- Customer Lifetime Value (LTV)
- Daily active users
- Revenue growth

---

## 🛠 Requirements

- Microsoft SQL Server or any T-SQL compatible environment
- Properly structured `test_data` table with at least:
  - `user_id`
  - `event_date`
  - `purchase_value`
  - `event_timestamp`

---

## ✅ To Do

- Add retention metrics
- Integrate cohort analysis
- Include visualization layer (Power BI / Tableau)

---

## 📬 Contributions

If you find issues or have suggestions, feel free to open an issue or submit a pull request. Let's make this better together!

