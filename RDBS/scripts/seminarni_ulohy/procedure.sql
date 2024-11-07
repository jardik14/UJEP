CREATE OR REPLACE PROCEDURE calculate_total_salary_by_pavilion_procedure(IN input_pavilion_id INT)
LANGUAGE plpgsql AS $$
DECLARE
    total_salary INT := 0;
    emp_record RECORD;
    emp_cursor CURSOR FOR
        SELECT e.employee_id, c.salary
        FROM Employee e
        JOIN Contract c ON e.employee_id = c.employee_id
        WHERE e.pavilion_id = input_pavilion_id;

BEGIN
    -- Open the cursor
    OPEN emp_cursor;

    -- Loop through the cursor
    LOOP
        FETCH emp_cursor INTO emp_record;

        -- Exit loop when no more records
        EXIT WHEN NOT FOUND;

        total_salary := total_salary + emp_record.salary;
    END LOOP;

    -- Close the cursor
    CLOSE emp_cursor;

    -- Insert the total salary into a new table or return it as needed
    RAISE NOTICE 'Total salary for pavilion % is %', input_pavilion_id, total_salary;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'An error occurred: %', SQLERRM;
END;
$$;
