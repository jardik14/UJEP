SELECT
    corr(sub.price, sub.purchase_count) AS price_popularity_correlation
FROM (
    SELECT
        p.product_id,
        p.price,
        COUNT(*) AS purchase_count
    FROM events_fact e
    JOIN product_dim p ON e.product_id = p.product_id
    WHERE e.event_type = 'purchase'
    GROUP BY p.product_id, p.price
) sub;
