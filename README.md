# Campus Equipment Checkout

**CSCE 4355 Database Administration · University of North Texas · Team 6**

A campus lending desk lends the same equipment to different borrowers over time. This PostgreSQL project models those checkouts and tests three questions. Which records should the database reject? Which changes can a checkout employee make? How much work does PostgreSQL do to find one borrower’s history?

| Team member | Module |
| --- | --- |
| Mason Bourn | Checkout schema, synthetic data, and integrity tests |
| Anthony Carter | Reader and checkout-staff roles, grants, and access tests |
| Jordan Bussa | Borrower-history query, composite index, and execution-plan comparison |

## Database and results

The `team6` schema contains `borrowers`, `equipment`, and `loans`. Each loan references one borrower and one physical item. An open checkout has a null `return_date`. The due date and any recorded return date must fall on or after checkout.

| Test | Observed result |
| --- | --- |
| Seed data | 1,000 borrowers, 300 items, and 30,000 historical loans. Borrower 42 has 30 loans. |
| Data integrity | One open loan succeeded. Six invalid records were rejected. The loan count remained 30,000 after rollback. |
| Role permissions | All nine tests matched expectations. Four operations succeeded and five returned SQLSTATE `42501` (insufficient privilege). |
| Borrower history | Both saved plans returned 30 rows. Execution time fell from 4.097 ms to 0.518 ms (7.91× speedup for this pair). Shared buffer hits fell from 192 to 32. |
| Index cost | The composite index occupied 672 kB alongside a 1,536 kB loans table. The experiment did not measure write overhead. |

The reader can query all three tables. Staff can also insert loans and update `loans.return_date`. The tests show that staff cannot edit due dates, change equipment records, or delete loans. The design allows multiple open loans on the same item, a limitation of the current schema.

## Run the project

**Environment.** The scripts were checked with PostgreSQL 18.1. The team used pgAdmin 4 for the demonstrations. Use a local PostgreSQL instance and an account that can create a database, own the project objects, create the two test roles, and switch to them. The role script creates `team6_reader` and `team6_staff` once per PostgreSQL instance. A fresh database on an instance that already has those role names will still see them. Use a separate clean instance for a full repeat from scratch.

1. In pgAdmin, right-click **Databases → Create → Database**, enter `team6_checkout`, and save. Open **Query Tool** on that database and run `SELECT current_database(), version();`.
2. Run [01_schema.sql](sql/01_schema.sql), then [02_seed_data.sql](sql/02_seed_data.sql) once on empty project tables. Confirm the four counts in the results table above.
3. Open [01_integrity_tests.sql](tests/01_integrity_tests.sql). Work through each numbered case separately with auto-commit on. Execute from `BEGIN` through the operation, inspect its row or error, and then execute the case’s `ROLLBACK;` separately. Run the final count.
4. Run [03_roles_privileges.sql](sql/03_roles_privileges.sql) once as the authorized setup account. Open [02_access_tests.sql](tests/02_access_tests.sql). For each role test, execute from `BEGIN` through the tested operation, inspect the result or error, and run `ROLLBACK;` separately. Finish with the role reset and row counts at the end of the file.
5. Run [baseline_plan.sql](tests/baseline_plan.sql) in the lab database before measuring the indexed query. Its opening statements drop the project’s borrower-history index if present and refresh the statistics. Run the five `EXPLAIN` statements individually to see each plan. Treat the first run as a warm-up and record runs 2–5.
6. Run [index.sql](sql/index.sql). It creates the index on `(borrower_id, checkout_date DESC)`, refreshes the statistics, and reports storage use.
7. Run [indexed_plan.sql](tests/indexed_plan.sql) on the same data. Use the same warm-up and four measured runs. Compare the scan type, execution time, and shared buffer hits. The final count for borrower 42 should still be 30.

The execution times above come from the two saved plans. Timings vary across machines and runs. For each new comparison, use the same borrower, data, and SQL on both sides.

## Demonstration scenarios and evidence

- **Integrity.** Review the [seed counts](results/seed_counts.png) and [open loan](results/valid_open_loan.png). The [invalid due-date example](results/invalid_due_date.png) shows what happens when a checkout is due before it starts.
- **Access control.** Compare the [reader’s denied insert](results/security/reader_insert_denied.png) with the [staff role’s successful insert](results/security/staff_insert_success.png). The [security evidence](results/security/) also covers grants, column-level updates, and final row counts.
- **Performance.** Compare the [baseline plan](results/baseline_plan.png) and [indexed plan](results/indexed_plan.png). The first scanned all 30,000 loans. The second used a bitmap index scan followed by a bitmap heap scan. Both sorted the matching rows by checkout date. See the [index size](results/index_size.png) and [final borrower count](results/count_check.png).

## Repository guide

| Folder | Contents |
| --- | --- |
| [sql/](sql/) | Schema, seed data, role grants, and index creation |
| [tests/](tests/) | Integrity cases, permission tests, and the before/after query scripts |
| [results/](results/) | Integrity test log, pgAdmin screenshots, and saved query plans |
| [docs/](docs/) | [Final project report](docs/Team6_Final_Project_Report.docx) and [architecture diagram](docs/architecture.png) |

## References

- [PostgreSQL 18 — Constraints](https://www.postgresql.org/docs/18/ddl-constraints.html)
- [PostgreSQL 18 — Privileges](https://www.postgresql.org/docs/18/ddl-priv.html)
- [PostgreSQL 18 — EXPLAIN](https://www.postgresql.org/docs/18/sql-explain.html)
- [PostgreSQL 18 — Bitmap scans and ordering](https://www.postgresql.org/docs/18/indexes-bitmap-scans.html)
- [pgAdmin 4 — Query Tool](https://www.pgadmin.org/docs/pgadmin4/latest/query_tool.html)
