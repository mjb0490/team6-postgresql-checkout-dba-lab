--This the "after" the index was crated

-- I ran this to chack that the index exists
SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'team6' AND tablename = 'loans';

-- Reran this queries to get the result for the "After"
EXPLAIN (ANALYZE, BUFFERS)
SELECT loan_id, equipment_id, checkout_date, due_date, return_date
FROM team6.loans
WHERE borrower_id = 42
ORDER BY checkout_date DESC;

EXPLAIN (ANALYZE, BUFFERS)
SELECT loan_id, equipment_id, checkout_date, due_date, return_date
FROM team6.loans
WHERE borrower_id = 42
ORDER BY checkout_date DESC;

EXPLAIN (ANALYZE, BUFFERS)
SELECT loan_id, equipment_id, checkout_date, due_date, return_date
FROM team6.loans
WHERE borrower_id = 42
ORDER BY checkout_date DESC;

EXPLAIN (ANALYZE, BUFFERS)
SELECT loan_id, equipment_id, checkout_date, due_date, return_date
FROM team6.loans
WHERE borrower_id = 42
ORDER BY checkout_date DESC;

EXPLAIN (ANALYZE, BUFFERS)
SELECT loan_id, equipment_id, checkout_date, due_date, return_date
FROM team6.loans
WHERE borrower_id = 42
ORDER BY checkout_date DESC;

-- I ran this to make sure that the number of loans borrowed by "42" did not change (30)
SELECT count(*) AS borrower_42_loans FROM team6.loans WHERE borrower_id = 42;