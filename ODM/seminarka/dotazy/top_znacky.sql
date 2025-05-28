SELECT p.brand, COUNT(*) AS purchases
FROM events_fact e
JOIN product_dim p ON e.product_id = p.product_id
WHERE e.event_type = 'purchase'
GROUP BY p.brand
ORDER BY purchases DESC
LIMIT 10;