CREATE TRIGGER employee_update_trigger
AFTER UPDATE ON Employee
FOR EACH ROW
EXECUTE FUNCTION log_employee_updates();
