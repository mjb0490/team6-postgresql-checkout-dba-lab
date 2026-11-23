-- Run once after 01_schema.sql. The borrower and equipment IDs are fixed
-- so that everyone can look up the same records on their own computer.
BEGIN;

INSERT INTO team6.borrowers (borrower_id, name)
SELECT n, 'Borrower ' || n
FROM generate_series(1, 1000) AS s(n);

WITH inventory AS (
    SELECT n,
           (ARRAY['Laptop', 'Camera', 'Projector', 'Tablet', 'Microphone'])
               [1 + (n - 1) % 5] AS category
    FROM generate_series(1, 300) AS s(n)
)
INSERT INTO team6.equipment (equipment_id, item_name, category)
SELECT n, category || ' ' || n, category
FROM inventory;

-- Each group of 1,000 loans gives every borrower one checkout.
-- Each item is checked out once every eight days and is back within six.
WITH history AS (
    SELECT n,
           1 + (n + n / 1000) % 1000 AS borrower_id,
           1 + n % 300 AS equipment_id,
           DATE '2024-09-01' + (n / 300) * 8 + n % 5 AS checkout_date
    FROM generate_series(0, 29999) AS s(n)
)
INSERT INTO team6.loans
    (borrower_id, equipment_id, checkout_date, due_date, return_date)
SELECT borrower_id, equipment_id, checkout_date,
       checkout_date + 5, checkout_date + n % 7
FROM history
ORDER BY n;

ANALYZE team6.borrowers;
ANALYZE team6.equipment;
ANALYZE team6.loans;
COMMIT;

-- Jordan's starting point should read 1000, 300, 30000, 30.
SELECT (SELECT count(*) FROM team6.borrowers) AS borrowers,
       (SELECT count(*) FROM team6.equipment) AS equipment_items,
       (SELECT count(*) FROM team6.loans) AS loans,
       (SELECT count(*) FROM team6.loans WHERE borrower_id = 42) AS borrower_42_loans;
