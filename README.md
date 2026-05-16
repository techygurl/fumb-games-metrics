# Mobile Game Performance Analysis

## Overview

The data provided is a sample of basic activity and revenue events for a live game, and we would like you to evaluate how it is performing. Some of the events will be highly relevant to establishing basic performance metrics, and some won’t.

Please examine the data, perform any processing you feel necessary, show us some charts, and tell us what you think.

---

# Tools

Examples of how to approach this exercise might be:

- Your email address may be given access to a test area where you can work in Google Cloud with BigQuery (using a table rather than the CSV),
- Analysing and charting the data from the CSV in a Jupyter Notebook,
- Similarly, using R Studio,
- Or in your own local SQL environment.

You might want to use a familiar tool like Microsoft Excel, PowerBI, LibreOffice Calc, or Google Sheets for the charts/visualisations which is absolutely fine. However, carrying out the other parts of the exercise in such a tool is not relevant to this position.

---

# Suggested Metrics

Our basic metrics are those common to most mobile games and many other products, including but not limited to:

- Daily new users (DNU)
- Daily active users (DAU)
- Daily revenue
- N-day retention
- Average revenue per daily active user (ARPDAU)
- Average revenue per paying user (ARPPU)
- Lifetime value (LTV)

If you can think of other interesting metrics, dimensions, or want to show us some distributional data, go ahead!

---

# Timeline

Please don’t spend too much time on this and don’t hesitate to send us unfinished work that we can discuss openly and productively. This is not something you will “pass” or “fail”, but will help us evaluate how you might fit into our team.

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
