CREATE OR REPLACE FUNCTION log_employee_updates()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO EmployeeAuditLog (employee_id, old_name, old_surname, updated_by)
    VALUES (OLD.employee_id, OLD.name, OLD.surname, current_user);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
