SELECT p.category_code, COUNT(*) AS count
FROM events_fact e
JOIN product_dim p ON e.product_id = p.product_id
WHERE e.event_type = 'purchase'
GROUP BY p.category_code
ORDER BY count DESC
