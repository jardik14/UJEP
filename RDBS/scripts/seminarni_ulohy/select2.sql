SELECT visitor_id,
       (SELECT COUNT(*)
        FROM visitor_feedback
        WHERE visitor_feedback.visitor_id = visitor.visitor_id) AS feedback_count
FROM visitor;
