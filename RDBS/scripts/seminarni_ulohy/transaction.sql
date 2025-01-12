BEGIN;
SELECT transfer_animal(1,1,2);
UPDATE employee SET pavilion_id = 2 WHERE employee_id = 1;
COMMIT;