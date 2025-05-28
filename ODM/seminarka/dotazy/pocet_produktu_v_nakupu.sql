SELECT
    products_bought,
    COUNT(*) AS session_count
FROM (
    SELECT
        user_session,
        COUNT(*) AS products_bought
    FROM events_fact
    WHERE event_type = 'purchase'
    GROUP BY user_session
) AS sub
GROUP BY products_bought
ORDER BY products_bought
LIMIT 10;
