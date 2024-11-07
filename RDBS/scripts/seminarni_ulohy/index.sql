-- Creating a unique index on the 'name' and 'surname' columns to ensure that no two employees can have the same name and surname combination.
CREATE UNIQUE INDEX idx_unique_name_surname ON Employee(name, surname);

-- Creating a full-text index on the 'name' and 'surname' columns to allow for efficient searching of employee names.
CREATE INDEX idx_fulltext_employee_names ON Employee USING gin(to_tsvector('english', name || ' ' || surname));
