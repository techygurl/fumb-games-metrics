# Mobile Game Performance Analysis

## Overview

The data provided is a sample of basic activity and revenue events for a live game, and i would like to evaluate how it is performing. Some of the events will be highly relevant to establishing basic performance metrics, and some won’t.



---

# Tools

Examples of how to approach this exercise might be:


- Analysing and charting the data from the CSV in a Jupyter Notebook,
- Similarly, using R Studio,
- Or in your own local SQL environment.

You might want to use a familiar tool like Microsoft Excel, Power BI, LibreOffice Calc, or Google Sheets for the charts/visualisations which is absolutely fine. 

---

# Suggested Metrics

basic metrics are those common to most mobile games and many other products, including but not limited to:

- Daily new users (DNU)
- Daily active users (DAU)
- Daily revenue
- N-day retention
- Average revenue per daily active user (ARPDAU)
- Average revenue per paying user (ARPPU)
- Lifetime value (LTV)


---

# Data Taxonomy

| Field Name | Description | Type (Raw) |
|---|---|---|
| `user_id` | Unique anonymous user identifier. | string |
| `event_name` | Name of the event. | string |
| `event_date` | Date of event receipt (YYmmdd). | string |
| `event_timestamp` | Timestamp event was sent (unix with microseconds). | integer |
| `ad_ilrd` | Advert (impression level) revenue data (USD). | float |
| `purchase_value` | Purchase value (USD). | float |
