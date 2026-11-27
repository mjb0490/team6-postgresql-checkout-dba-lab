-- Team 6: Campus Equipment Checkout
-- Author: Anthony Carter
-- Role-Based Access Control (RBAC)

BEGIN;

-- Create database roles
CREATE ROLE team6_reader NOLOGIN;
CREATE ROLE team6_staff NOLOGIN;

-- Remove public access to the project schema and tables
REVOKE ALL ON SCHEMA team6 FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA team6 FROM PUBLIC;

-- Allow both roles to access the schema
GRANT USAGE ON SCHEMA team6
TO team6_reader, team6_staff;

-- Reader permissions
GRANT SELECT ON ALL TABLES IN SCHEMA team6
TO team6_reader;

-- Staff read permissions
GRANT SELECT ON ALL TABLES IN SCHEMA team6
TO team6_staff;

-- Allow staff to create checkout records
GRANT INSERT ON team6.loans TO team6_staff;

-- Allow staff to update return dates only
GRANT UPDATE (return_date) ON team6.loans
TO team6_staff;

COMMIT;