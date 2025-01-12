SELECT pavilion_id, COUNT(*) AS animal_count
    FROM animal
    GROUP BY pavilion_id
    order by pavilion_id;
