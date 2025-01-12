SELECT p.pavilion_id, p.name, count(*) as animal_count
    FROM animal as a
    join pavilion as p
    on a.pavilion_id = p.pavilion_id
    group by p.pavilion_id
    order by p.pavilion_id;