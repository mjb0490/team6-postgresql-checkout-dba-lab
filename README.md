# Campus Equipment Checkout

CSCE 4355 Database Administration · Team 6

A campus lending desk needs to know who checked out each item, when it was due, and when it came back. This PostgreSQL project uses synthetic checkout records to test data integrity, staff permissions, and one borrower-history query.

| Team member | Module |
| --- | --- |
| Mason Bourn | Schema, sample data, and integrity tests |
| Anthony Carter | Read-only and checkout-staff roles and permission tests |
| Jordan Bussa | Borrower-history query, composite index, and before/after measurements |

## Run the schema and load the data

Use PostgreSQL and pgAdmin 4. The schema and data scripts use PostgreSQL 18 syntax. Use a local account that can create the project database and own its objects. Anthony also needs an authorized account that can create the test roles and switch to them.

1. In pgAdmin, expand your PostgreSQL server, right-click **Databases**, and choose **Create → Database**. Name the new database `team6_checkout` and save. If you already have a copy with work in it, give the new database a different name.
2. Right-click the new database and open **Query Tool**. Run `SELECT current_database(), version();` to check the connection and record the PostgreSQL version. Record the pgAdmin version from **Help → About**.
3. Open `sql/01_schema.sql` in the Query Tool and execute the whole file. In the browser tree, refresh **Schemas → team6 → Tables**.
4. Open `sql/02_seed_data.sql` and execute it once. Its final query should show **1,000 borrowers, 300 equipment items, 30,000 loans, and 30 loans for borrower 42**. The script also runs `ANALYZE` so Jordan can take the baseline immediately.
5. Open `tests/01_integrity_tests.sql`. Follow the selection instructions at the top. For a rejected insert, capture **Messages** with the constraint error, then run that test's `ROLLBACK;` on its own. The final check should still show 30,000 loans.

The schema script expects a new database. The seed script expects empty project tables. For another clean run, create a separate database and repeat steps 2–5. Each member can use their own local copy loaded from the same commit.

The starter was checked in an isolated PostgreSQL 18.1 database. The four counts matched, the open loan was accepted, and all six invalid inserts were rejected. After the test transactions were rolled back, the loan count was still 30,000. Run the cases in pgAdmin to collect the team's screenshots.

## Tables

| Table | Columns | How the desk uses it |
| --- | --- | --- |
| `team6.borrowers` | `borrower_id` (PK), `name` | One record per borrower. The seed file supplies the borrower numbers. |
| `team6.equipment` | `equipment_id` (PK), `item_name`, `category` | One record per physical item. The seed file supplies the inventory numbers. |
| `team6.loans` | `loan_id` (identity PK), `borrower_id` (FK), `equipment_id` (FK), `checkout_date`, `due_date`, `return_date` | Each loan references one borrower and one item. Both may appear in many loans. PostgreSQL assigns the loan number. |

Only `return_date` can be NULL. That represents an item still checked out. A due date or return date can equal the checkout date, and both must be on or after checkout. A late return keeps its actual date. All 30,000 seed loans are completed checkouts. Test 1 shows an open loan and rolls it back.

## Jordan's baseline

Run this on the seeded database before creating the borrower/date index. Borrower 42 has 30 loans. Keep the SELECT and the dataset identical for both sets of measurements.

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT loan_id, equipment_id, checkout_date, due_date, return_date
FROM team6.loans
WHERE borrower_id = 42
ORDER BY checkout_date DESC;
```

The following query shows the starting indexes. The only one on `team6.loans` should be `loans_pkey`.

```sql
SELECT indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'team6' AND tablename = 'loans'
ORDER BY indexname;
```

Save the baseline output before running `sql/04_indexes.sql`. Then repeat the same query with the composite index on `team6.loans (borrower_id, checkout_date)`. Record the scan and any sort, actual rows, execution time, and shared buffer hits/reads. A practical comparison is one warm-up followed by three measured runs per condition. Keep the raw plans and use the median time for each condition.

## Where each file goes

| Path | Purpose and order |
| --- | --- |
| `sql/01_schema.sql`, `sql/02_seed_data.sql` | Included. Run in this order. |
| `tests/01_integrity_tests.sql` | Included. Run each case separately after seeding. |
| `sql/03_roles_privileges.sql`, `tests/02_access_tests.sql` | Anthony adds the roles/grants, then the allowed and denied operation tests. Use an authorized login for role switching and roll back test writes. |
| `tests/03_baseline_plan.sql` → `sql/04_indexes.sql` → `tests/04_indexed_plan.sql` | Jordan adds these in the order shown. Save the unindexed evidence before creating the index. |
| `results/` | `01_integrity_check.txt` records the PostgreSQL 18.1 starter check. Add the team's pgAdmin evidence, role tests, and both query plans as they are recorded. |
| `docs/` | Team checklist and `architecture.png`, the workflow diagram from Figure 1 of the proposal. Add the final project report here. |

## Demo and final README

1. Mason shows the three tables, seed counts, and a rejected loan in pgAdmin.
2. Anthony shows which role is active, a permitted action, and a denied write.
3. Jordan runs the borrower lookup and compares the saved baseline and indexed plans. Use a fresh seeded copy if repeating the live before/after sequence.
4. The team summarizes the measurements, one limitation, and each member's contribution. Add the tested versions, final script order, measured results, and links to the report and recording here when available.

## References

- [PostgreSQL documentation on constraints](https://www.postgresql.org/docs/18/ddl-constraints.html)
- [PostgreSQL documentation on generate_series](https://www.postgresql.org/docs/18/functions-srf.html)
- [PostgreSQL documentation on privileges](https://www.postgresql.org/docs/18/ddl-priv.html)
- [PostgreSQL documentation on EXPLAIN](https://www.postgresql.org/docs/18/using-explain.html)
- [pgAdmin Query Tool documentation](https://www.pgadmin.org/docs/pgadmin4/latest/query_tool.html)
