CREATE OR REPLACE FUNCTION calculate_total_salary_by_pavilion(input_pavilion_id INT)
RETURNS NUMERIC AS $$
DECLARE
    total_salary NUMERIC := 0;
    emp_salary INT;
BEGIN
    -- Begin the transaction
    BEGIN
        FOR emp_salary IN
            SELECT salary
            FROM Contract
            INNER JOIN Employee ON Contract.employee_id = Employee.employee_id
            WHERE Employee.pavilion_id = input_pavilion_id
        LOOP
            total_salary := total_salary + emp_salary;
        END LOOP;

        -- Commit transaction if successful
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            -- Rollback transaction in case of an error
            RAISE NOTICE 'Transaction failed, rolling back changes.';
            ROLLBACK;
            RETURN NULL;
    END;

    RETURN total_salary;
END;
$$ LANGUAGE plpgsql;
