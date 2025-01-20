SELECT AVG(row_count) AS avg_records
FROM (
    SELECT COUNT(*) AS row_count FROM animal
    UNION ALL
    SELECT COUNT(*) FROM pavilion
    UNION ALL
    SELECT COUNT(*) FROM employee
    UNION ALL
    SELECT COUNT(*) FROM contract
    UNION ALL
    SELECT COUNT(*) FROM feeding
    UNION ALL
    SELECT COUNT(*) FROM visitor
    UNION ALL
    SELECT COUNT(*) FROM visitor_feedback
) AS subquery;
