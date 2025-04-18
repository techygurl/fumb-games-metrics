SELECT 
    user_id,
    SUM(CAST(purchase_value AS FLOAT)) AS lifetime_value
FROM [dbo].[test_data]
WHERE 
    ISNUMERIC(purchase_value) = 1
    AND CAST(purchase_value AS FLOAT) > 0
GROUP BY 
  [user_id]
ORDER BY 
    lifetime_value DESC;




	SELECT 
    SUM(CAST(purchase_value AS FLOAT)) * 1.0 / COUNT(DISTINCT user_id) AS ARPPU


SELECT 
    SUM(CAST(purchase_value AS FLOAT)) * 1.0 / COUNT(DISTINCT user_id) AS avg_lifetime_value
FROM [dbo].[test_data]
WHERE 
    ISNUMERIC(purchase_value) = 1
    AND CAST(purchase_value AS FLOAT) > 0;

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


