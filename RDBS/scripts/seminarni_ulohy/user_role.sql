-- Create a new user with a specified password
CREATE USER new_user WITH PASSWORD 'user_password';

-- psql -U new_user -d database_name -- log in
-- \dt  -- Lists tables accessible by the user
-- \l   -- Lists databases the user can access

-- Create a new role called "read_access"
CREATE ROLE read_access;

-- Grant SELECT permission on a specific table to a role
GRANT SELECT ON TABLE animal TO read_access;

-- Grant the "read_access" role to "new_user"
GRANT read_access TO new_user;

-- Revoke SELECT permission on a specific table from the role
REVOKE SELECT ON TABLE animal FROM read_access;

-- Revoke the "read_access" role from "new_user"
REVOKE read_access FROM new_user;

-- Drop the role "read_access"
DROP ROLE read_access;

-- Drop the user account
DROP USER new_user;