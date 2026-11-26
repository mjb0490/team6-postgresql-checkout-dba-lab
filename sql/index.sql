-- Create INDEX

CREATE INDEX IF NOT EXISTS idx_loans_borrower_checkout
    ON team6.loans (borrower_id, checkout_date DESC);

-- Refresh the statistics to let the planner know about the new index

ANALYZE team6.loans;

-- I ran this to know how much extra space it takes next to the table

SELECT indexrelid::regclass AS index_name,
       pg_size_pretty(pg_relation_size(indexrelid)) AS index_size,
       pg_size_pretty(pg_relation_size(indrelid)) AS table_size
FROM pg_index
WHERE indrelid = 'team6.loans'::regclass;
