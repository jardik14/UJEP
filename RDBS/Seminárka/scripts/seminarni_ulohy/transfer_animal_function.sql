CREATE OR REPLACE FUNCTION transfer_animal(
    target_animal_id INT,
    from_pavilion_id INT,
    to_pavilion_id INT
)
RETURNS VOID AS $$
DECLARE
    from_capacity INT;
    to_capacity INT;
    current_animal_count INT;
BEGIN
    -- Check if source pavilion exists
    IF NOT EXISTS (SELECT 1 FROM pavilion WHERE pavilion_id = from_pavilion_id) THEN
        RAISE EXCEPTION 'Source pavilion does not exist.';
    END IF;

    -- Check if destination pavilion exists
    IF NOT EXISTS (SELECT 1 FROM pavilion WHERE pavilion_id = to_pavilion_id) THEN
        RAISE EXCEPTION 'Destination pavilion does not exist.';
    END IF;

    -- Get capacities
    SELECT capacity INTO from_capacity FROM pavilion WHERE pavilion_id = from_pavilion_id;
    SELECT capacity INTO to_capacity FROM pavilion WHERE pavilion_id = to_pavilion_id;

    -- Count current animals in destination pavilion
    SELECT COUNT(*) INTO current_animal_count FROM animal WHERE pavilion_id = to_pavilion_id;

    -- Check if destination pavilion has space
    IF current_animal_count >= to_capacity THEN
        RAISE EXCEPTION 'Destination pavilion is full.';
    END IF;

    -- Update the pavilion ID of the animal
    UPDATE animal
    SET pavilion_id = to_pavilion_id
    WHERE animal_id = target_animal_id AND pavilion_id = from_pavilion_id;

END;
$$ LANGUAGE plpgsql;
