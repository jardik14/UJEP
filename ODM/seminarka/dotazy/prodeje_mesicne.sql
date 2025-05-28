SELECT TO_CHAR(d.full_date, 'YYYY-MM') AS year_month, COUNT(*) AS purchase_count
FROM events_fact e
JOIN date_dim d ON e.event_time = d.full_date
WHERE e.event_type = 'purchase'
GROUP BY year_month
ORDER BY year_month;
