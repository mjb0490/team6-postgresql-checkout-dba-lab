-- pgAdmin Query Tool: use the database owner and leave auto-commit on.
-- For each test, highlight BEGIN through the INSERT (including RETURNING,
-- if present) and run the selection. Read Data Output or Messages.
-- Then highlight and run its ROLLBACK on its own before the next test.

-- 1. A loan for an existing borrower and item can have an open return date.
-- Expected: one row with a new loan_id and a NULL return_date.
BEGIN;
INSERT INTO team6.loans (borrower_id, equipment_id, checkout_date, due_date)
VALUES (42, 7, DATE '2026-11-22', DATE '2026-11-29')
RETURNING loan_id, borrower_id, equipment_id, checkout_date, due_date, return_date;
ROLLBACK;

-- 2. Borrower -1 does not exist. Expected: foreign key violation (23503).
BEGIN;
INSERT INTO team6.loans (borrower_id, equipment_id, checkout_date, due_date)
VALUES (-1, 7, DATE '2026-11-22', DATE '2026-11-29');
ROLLBACK;

-- 3. Equipment -1 does not exist. Expected: foreign key violation (23503).
BEGIN;
INSERT INTO team6.loans (borrower_id, equipment_id, checkout_date, due_date)
VALUES (42, -1, DATE '2026-11-22', DATE '2026-11-29');
ROLLBACK;

-- 4. Due date before checkout. Expected: due_on_or_after_checkout (23514).
BEGIN;
INSERT INTO team6.loans (borrower_id, equipment_id, checkout_date, due_date)
VALUES (42, 7, DATE '2026-11-22', DATE '2026-11-21');
ROLLBACK;

-- 5. Return date before checkout. Expected: return_on_or_after_checkout (23514).
BEGIN;
INSERT INTO team6.loans (borrower_id, equipment_id, checkout_date, due_date, return_date)
VALUES (42, 7, DATE '2026-11-22', DATE '2026-11-29', DATE '2026-11-21');
ROLLBACK;

-- 6. A loan needs a due date. Expected: not-null violation (23502).
BEGIN;
INSERT INTO team6.loans (borrower_id, equipment_id, checkout_date, due_date)
VALUES (42, 7, DATE '2026-11-22', NULL);
ROLLBACK;

-- 7. Borrower 42 already exists. Expected: duplicate primary key (23505).
BEGIN;
INSERT INTO team6.borrowers (borrower_id, name)
VALUES (42, 'Duplicate test borrower');
ROLLBACK;

-- After all rollbacks, the loan history still contains the original rows.
SELECT count(*) AS loans_after_tests FROM team6.loans;
