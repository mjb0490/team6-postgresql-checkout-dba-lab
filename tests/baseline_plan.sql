-- Before the index was created  
-- I ran this to make sure the index does not exist yet.

DROP INDEX IF EXISTS team6.idx_loans_borrower_checkout;
ANALYZE team6.loans;

-- table size to know how much a full scan has to read

SELECT pg_size_pretty(pg_relation_size('team6.loans')) AS loans_table_size,
       (SELECT relpages FROM pg_class WHERE oid = 'team6.loans'::regclass) AS loans_pages;

-- The lookup: I ran these to get the full history for borrower 42, most recent first. Ran this 5 times to get the different execution time from smallest to largest.

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
