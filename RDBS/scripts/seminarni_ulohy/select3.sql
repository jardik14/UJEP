SELECT pavilion_id, animal_count
FROM (
    SELECT pavilion_id, COUNT(*) AS animal_count
    FROM animal
    GROUP BY pavilion_id
) AS subquery
GROUP BY pavilion_id;
