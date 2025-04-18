--- firstly i standardized the data especialy date and event time stamp then added it as a new column to the table
-- Convert varchar to DATE, then format it
SELECT FORMAT(CAST(event_date AS DATE), 'yyyy-MM-dd') AS formatted_date
FROM [dbo].[test_data]

ALTER TABLE [dbo].[test_data]
ADD formatted_date DATE;

UPDATE [dbo].[test_data]
SET [formatted_date] = CAST([event_date] AS DATE);

ALTER TABLE [dbo].[test_data]
DROP COLUMN [event_date];

SELECT TOP 10 event_timestamp FROM[dbo].[test_data] ;

 SELECT 
 LEFT(CAST(event_timestamp AS VARCHAR), 10) AS timestamp_parts,
 DATEADD(SECOND, CAST(LEFT(CAST(event_timestamp AS VARCHAR), 10) AS BIGINT), '1970-01-01') AS event_datetimestamp
 FROM [dbo].[test_data];

 ALTER TABLE [dbo].[test_data]
 ADD event_datetimestamp DATETIME;

 SELECT TOP 10 [event_timestamp], LEFT(CAST([event_timestamp] AS VARCHAR), 10) AS timestamp_part
FROM [dbo].[test_data];

SELECT 
   [event_timestamp],
    DATEADD(SECOND, CONVERT(BIGINT,[event_timestamp] ) / 1000000, '1970-01-01') AS eventtime_stamp
FROM 
   [dbo].[test_data] ;

ALTER TABLE [dbo].[test_data]
ADD eventtime_stamp DATETIME;

UPDATE [dbo].[test_data]
SET eventtime_stamp = DATEADD(SECOND, CONVERT(BIGINT,[event_timestamp] ) / 1000000, '1970-01-01');
--the data is now easy to use lets start;
----I CREATED A NEW TABLE [dbo].[fumbfeb_metrics] TO STORE ALL THE METRICS WITH date as the primary key
---lets find the Daily active users (DAU)

SELECT 
    CAST(eventtime_stamp  AS DATE) AS event_date,
    COUNT(DISTINCT user_id) AS daily_active_user
FROM [dbo].[test_data]
GROUP BY CAST([eventtime_stamp] AS DATE)
ORDER BY event_date;



create table fumbfeb_metrics(
event_date Date PRIMARY KEY,
);
---i put the date values manualy
INSERT INTO [dbo].[fumbfeb_metrics] ([event_date])
VALUES 
    (' 2025-02-25'),
    ('2025-02-26'),
    ('2025-02-27'),
    ('2025-02-28'),
    ('2025-03-01'),
    ('2025-03-02'),
    ('2025-03-03'),
    ('2025-03-04');

ALTER TABLE [dbo].[fumbfeb_metrics]
ADD daily_active_users int;



UPDATE [dbo].[fumbfeb_metrics] 
SET [dbo].[fumbfeb_metrics].daily_active_users = t.daily_active_user
FROM [dbo].[fumbfeb_metrics] f
JOIN (
    SELECT 
        CAST(eventtime_stamp AS DATE) AS event_date,
        COUNT(DISTINCT user_id) AS daily_active_user
    FROM [dbo].[test_data]
    GROUP BY CAST(eventtime_stamp AS DATE)
) t ON f.event_date = t.event_date;

--- finding the Daily new users (DNU)
ALTER TABLE [dbo].[fumbfeb_metrics]
ADD daily_new_users int;

SELECT
    CAST([formatted_date] AS DATE) AS event_date,
    COUNT(DISTINCT [user_id]) AS daily_new_user
FROM
    [dbo].[test_data]
WHERE
    [event_name] = 'session_start'
GROUP BY
    CAST([formatted_date] AS DATE)
ORDER BY
    event_date;


UPDATE [dbo].[fumbfeb_metrics] 
SET [dbo].[fumbfeb_metrics].daily_new_users= t.daily_new_user
FROM [dbo].[fumbfeb_metrics] f
JOIN (SELECT
    CAST([formatted_date] AS DATE) AS event_date,
    COUNT(DISTINCT [user_id]) AS daily_new_user
FROM
    [dbo].[test_data]
WHERE
    [event_name] = 'session_start'
GROUP BY
    CAST([formatted_date] AS DATE)
    
) t ON f.event_date = t.event_date;

-----finding the daily revenue
SELECT 
    CAST([eventtime_stamp] AS DATE) AS event_date,
    format(sum(CAST([ad_ilrd] AS decimal(18, 2))), 'C', 'en-US') AS daily_rev
FROM [dbo].[test_data]
GROUP BY CAST( [eventtime_stamp]AS DATE)
ORDER BY event_date;

ALTER TABLE [dbo].[fumbfeb_metrics]
ADD daily_revenue  decimal(18, 2);

UPDATE [dbo].[fumbfeb_metrics] 
SET [dbo].[fumbfeb_metrics].daily_revenue = t.daily_rev
FROM [dbo].[fumbfeb_metrics] f
JOIN (
   SELECT 
       CAST([eventtime_stamp] AS DATE) AS event_date,
       SUM(CAST([ad_ilrd] AS decimal(18, 2))) AS daily_rev
   FROM [dbo].[test_data]
   GROUP BY CAST([eventtime_stamp] AS DATE)
) t ON f.event_date = t.event_date;

----N day retention i chose 4 days retention rate and added it to the [dbo].[fumbfeb_metrics] table the cohort users,retained users after 4 days and retention rate after 4 days

WITH cohort AS (
    SELECT 
        user_id,
        CAST(eventtime_stamp AS DATE) AS event_date
    FROM [dbo].[test_data]
    WHERE event_name = 'session_start'
),

returns AS (
    SELECT 
        user_id,
        CAST(eventtime_stamp AS DATE) AS return_date
    FROM [dbo].[test_data]
    WHERE event_name = 'session_start'
)

SELECT 
    c.event_date,
    COUNT(DISTINCT c.user_id) AS cohort_users,
    COUNT(DISTINCT r.user_id) AS retained_users,
    CAST(COUNT(DISTINCT r.user_id) AS FLOAT) / NULLIF(COUNT(DISTINCT c.user_id), 0) AS retention_rate
FROM cohort c
LEFT JOIN returns r 
    ON c.user_id = r.user_id
    AND DATEDIFF(DAY, c.event_date, r.return_date) = 4
GROUP BY c.event_date
ORDER BY c.event_date;


ALTER TABLE fumbfeb_metrics
ADD cohort_users INT,
    retained_users INT,
    retention_rate FLOAT;




WITH cohort AS (
    SELECT 
        user_id,
        CAST(eventtime_stamp AS DATE) AS event_date
    FROM [dbo].[test_data]
    WHERE event_name = 'session_start'
),
returns AS (
    SELECT 
        user_id,
        CAST(eventtime_stamp AS DATE) AS return_date
    FROM [dbo].[test_data]
    WHERE event_name = 'session_start'
),
retention_data AS (
    SELECT 
        c.event_date,
        COUNT(DISTINCT c.user_id) AS cohort_users,
        COUNT(DISTINCT r.user_id) AS retained_users,
        CAST(COUNT(DISTINCT r.user_id) AS FLOAT) / NULLIF(COUNT(DISTINCT c.user_id), 0) AS retention_rate
    FROM cohort c
    LEFT JOIN returns r 
        ON c.user_id = r.user_id
        AND DATEDIFF(DAY, c.event_date, r.return_date) = 4
    GROUP BY c.event_date
)

UPDATE f
SET 
    f.cohort_users = r.cohort_users,
    f.retained_users = r.retained_users,
    f.retention_rate = r.retention_rate
FROM [dbo].[fumbfeb_metrics] f
JOIN retention_data r ON f.event_date = r.event_date;


------Average revenue per daily active user (ARPDAU)

--ARPDAU= Daily Active Users/Daily Revenue

ALTER TABLE [dbo].[fumbfeb_metrics]
drop column ARP_DAU; 

ALTER TABLE fumbfeb_metrics
ADD ARP_DAU decimal(18, 4); 



UPDATE fumbfeb_metrics
SET arp_dau = 
    CAST(daily_revenue AS DECIMAL(18, 2)) / 
    NULLIF(CAST(daily_active_users AS DECIMAL(18, 2)), 0);
------Average revenue per paying user (ARPPU),purchasevalue/distinct user id

SELECT 
    SUM(CAST(purchase_value AS FLOAT)) * 1.0 / COUNT(DISTINCT user_id) AS ARPPU
FROM [dbo].[test_data]
WHERE 
    ISNUMERIC(purchase_value) = 1
    AND CAST(purchase_value AS FLOAT) > 0;
SELECT 
    CAST(eventtime_stamp AS DATE) AS event_date,
    SUM(CAST(purchase_value AS FLOAT)) * 1.0 / COUNT(DISTINCT user_id) AS ARPP
FROM [dbo].[test_data]
WHERE 
    ISNUMERIC(purchase_value) = 1
    AND CAST(purchase_value AS FLOAT) > 0
GROUP BY 
    CAST(eventtime_stamp AS DATE)
ORDER BY 
    event_date;


ALTER TABLE [dbo].[fumbfeb_metrics]
drop column ARP_PU; 

ALTER TABLE fumbfeb_metrics
ADD ARP_PU decimal(18, 4); 

UPDATE [dbo].[fumbfeb_metrics] 
SET [dbo].[fumbfeb_metrics].[ARP_PU] = t.ARPP
FROM [dbo].[fumbfeb_metrics] f
JOIN (SELECT 
    CAST(eventtime_stamp AS DATE) AS event_date,
    SUM(CAST(purchase_value AS FLOAT)) * 1.0 / COUNT(DISTINCT user_id) AS ARPP
FROM [dbo].[test_data]
WHERE 
    ISNUMERIC(purchase_value) = 1
    AND CAST(purchase_value AS FLOAT) > 0
GROUP BY 
    CAST(eventtime_stamp AS DATE)
   
) t ON f.event_date = t.event_date;

-----Lifetime value (LTV)

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