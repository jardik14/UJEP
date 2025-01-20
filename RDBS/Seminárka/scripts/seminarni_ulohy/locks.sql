BEGIN;
LOCK TABLE Animal IN SHARE MODE;
-- Now other transactions can read but cannot modify the Animal table.
-- You can perform your read queries here.
select * from animal
update animal set pavilion_id = 5 where animal_id = 3;
COMMIT;

BEGIN;
LOCK TABLE Employee IN EXCLUSIVE MODE;
-- Now other transactions cannot read or write to the Employee table.
-- You can perform your modifications here.
COMMIT;

BEGIN;
SELECT * FROM Pavilion WHERE pavilion_id = 1 FOR UPDATE;
-- This locks the specific row in Pavilion for updates in the current transaction.
-- Other transactions cannot modify this row until the lock is released.
COMMIT;


BEGIN;

-- Lock each table in the database with ACCESS EXCLUSIVE mode
LOCK TABLE Animal, Pavilion, Employee, Contract, Feeding, Visitor, visitor_feedback, EmployeeAuditLog IN ACCESS EXCLUSIVE MODE;

-- Now all tables are locked, effectively locking the entire database.
-- No other transaction can read or write to any of these tables.

-- Do any operations needed with this exclusive access

COMMIT;  -- Release locks at the end of the transaction