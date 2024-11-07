CREATE VIEW EmployeeDetails AS
SELECT
    e.employee_id,
    e.name AS employee_name,
    e.surname AS employee_surname,
    e.role_name,
    p.name AS pavilion_name,
    CONCAT(m.name, ' ', m.surname) AS manager_name
FROM
    Employee e
LEFT JOIN
    Pavilion p ON e.pavilion_id = p.pavilion_id
LEFT JOIN
    Employee m ON e.manager_id = m.employee_id;
