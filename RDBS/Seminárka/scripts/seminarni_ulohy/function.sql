CREATE OR REPLACE FUNCTION calculate_total_salary_by_pavilion(input_pavilion_id INT)
RETURNS INTEGER AS $$
DECLARE
    total_salary INTEGER;
BEGIN
    SELECT SUM(c.salary)
    INTO total_salary
    FROM Employee e
    JOIN Contract c ON e.employee_id = c.employee_id
    WHERE e.pavilion_id = input_pavilion_id;

    RETURN COALESCE(total_salary, 0);
END;
$$ LANGUAGE plpgsql;