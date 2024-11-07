CREATE OR REPLACE VIEW EmployeeDetails AS
WITH LatestContract AS (
    SELECT
        employee_id,
        salary,
        contract_start,
        contract_end,
        ROW_NUMBER() OVER (PARTITION BY employee_id ORDER BY contract_end DESC) AS rn
    FROM
        Contract
)
SELECT
    e.employee_id,
    e.name AS employee_name,
    e.surname AS employee_surname,
    e.role_name,
    p.name AS pavilion_name,
    CONCAT(m.name, ' ', m.surname) AS manager_name,
    lc.salary,
    lc.contract_start,
    lc.contract_end,
    CASE
        WHEN lc.contract_end >= CURRENT_DATE THEN 'Yes'
        ELSE 'No'
    END AS is_contract_active
FROM
    Employee e
LEFT JOIN
    Pavilion p ON e.pavilion_id = p.pavilion_id
LEFT JOIN
    Employee m ON e.manager_id = m.employee_id
LEFT JOIN
    LatestContract lc ON e.employee_id = lc.employee_id AND lc.rn = 1;
