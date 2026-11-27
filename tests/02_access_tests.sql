-- Team 6: Campus Equipment Checkout
-- Author: Anthony Carter
-- Run after sql/03_roles_privileges.sql as an authorized administrator.
-- In pgAdmin, execute each numbered block separately.
-- For denied tests, execute the block through the attempted operation,
-- capture SQLSTATE 42501, then execute ROLLBACK separately.
-- For successful writes, capture RETURNING output before ROLLBACK.

-- 1. Reader SELECT: allowed; expected 30000 loans.
BEGIN;
SET LOCAL ROLE team6_reader;
SELECT current_user AS active_role, COUNT(*) AS total_loans FROM team6.loans;
ROLLBACK;

-- 2. Reader UPDATE: denied.
BEGIN;
SET LOCAL ROLE team6_reader;
UPDATE team6.loans SET return_date = CURRENT_DATE WHERE FALSE;
ROLLBACK;

-- 3. Reader INSERT: denied.
BEGIN;
SET LOCAL ROLE team6_reader;
INSERT INTO team6.loans (borrower_id, equipment_id, checkout_date, due_date, return_date)
SELECT borrower_id, equipment_id, checkout_date, due_date, return_date
FROM team6.loans WHERE FALSE;
ROLLBACK;

-- 4. Staff SELECT: allowed; expected 30000 loans.
BEGIN;
SET LOCAL ROLE team6_staff;
SELECT current_user AS active_role, COUNT(*) AS total_loans FROM team6.loans;
ROLLBACK;

-- 5. Staff INSERT: allowed; expected one returned row.
-- Identity sequence may advance even after rollback.
BEGIN;
SET LOCAL ROLE team6_staff;
INSERT INTO team6.loans (borrower_id, equipment_id, checkout_date, due_date, return_date)
VALUES (42, 1, CURRENT_DATE, CURRENT_DATE + 14, NULL)
RETURNING current_user AS active_role, *;
ROLLBACK;

-- 6. Staff return_date UPDATE: allowed; expected one returned row.
BEGIN;
SET LOCAL ROLE team6_staff;
UPDATE team6.loans SET return_date = checkout_date + 1 WHERE loan_id = 1
RETURNING current_user AS active_role, *;
ROLLBACK;

-- 7. Staff due_date UPDATE: denied.
BEGIN;
SET LOCAL ROLE team6_staff;
UPDATE team6.loans SET due_date = due_date + 1 WHERE FALSE;
ROLLBACK;

-- 8. Staff DELETE: denied.
BEGIN;
SET LOCAL ROLE team6_staff;
DELETE FROM team6.loans WHERE FALSE;
ROLLBACK;

-- 9. Staff equipment UPDATE: denied.
BEGIN;
SET LOCAL ROLE team6_staff;
UPDATE team6.equipment SET equipment_id = equipment_id WHERE FALSE;
ROLLBACK;

-- 10. Final verification: expected 1000, 300, 30000.
RESET ROLE;
SELECT current_user AS active_role,
    (SELECT COUNT(*) FROM team6.borrowers) AS borrowers,
    (SELECT COUNT(*) FROM team6.equipment) AS equipment,
    (SELECT COUNT(*) FROM team6.loans) AS loans;
