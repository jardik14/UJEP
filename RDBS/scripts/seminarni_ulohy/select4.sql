WITH RECURSIVE EmployeeHierarchy AS (
    -- Anchor member: Select the starting point (for example, a specific manager)
    SELECT
        e.employee_id,
        e.name AS employee_name,
        e.surname AS employee_surname,
        e.manager_id,
        m.surname AS manager_surname, -- Get the manager's surname
        0 AS level  -- Level in the hierarchy
    FROM
        Employee e
    LEFT JOIN
        Employee m ON e.manager_id = m.employee_id  -- Join to get manager details
    WHERE
        e.employee_id = 1  -- Replace with the desired employee_id or manager_id

    UNION ALL

    -- Recursive member: Join with the Employee table to find direct reports
    SELECT
        e.employee_id,
        e.name AS employee_name,
        e.surname AS employee_surname,
        e.manager_id,
        m.surname AS manager_surname, -- Get the manager's surname
        eh.level + 1  -- Increase the level for each level down in the hierarchy
    FROM
        Employee e
    INNER JOIN
        EmployeeHierarchy eh ON e.manager_id = eh.employee_id
    LEFT JOIN
        Employee m ON e.manager_id = m.employee_id  -- Join to get manager details
)
SELECT * FROM EmployeeHierarchy;
