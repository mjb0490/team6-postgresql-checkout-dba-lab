# Campus Equipment Checkout

CSCE 4355 Database Administration · Team 6

Problem Scenario: A campus lending desk needs to know who checked out each item, when it was due, and when it came back. Our PostgreSQL project uses synthetic, but realistic, checkout records to test data integrity, staff permissions, and one borrower-history query.

Our Project: Campus Equipment Checkout is a PostgreSQL database project for our CSCE 4355 - Database Administration course. It models how a campus lending desk tracks borrowers, equipment, and checkout history. Using 30,000 synthetic loan records, our team is testing how database constraints catch invalid checkouts, how staff roles control who can change records, and how an index affects the time it takes to retrieve one borrower’s loan history.

|Team member|Module|
|-|-|
|Mason Bourn|Schema, sample data, and integrity tests|
|Anthony Carter|Read-only and checkout-staff roles and permission tests|
|Jordan Bussa|Borrower-history query, composite index, and before/after measurements|

## Run the schema and load the data

We are using PostgreSQL and pgAdmin 4. The schema and data scripts use PostgreSQL 18 syntax. Mason (author) will use a local account to create the project database and will own its objects. Anthony will use an authorized account that can create the test roles and switch to them.

1. In pgAdmin, expand your PostgreSQL server, right-click **Databases**, and choose **Create → Database**. Name the new database `team6\_checkout` and save. If you already have a copy with work in it, give the new database a different name.
2. Right-click the new database and open **Query Tool**. Run `SELECT current\_database(), version();` to check the connection and record the PostgreSQL version. Record the pgAdmin version from **Help → About**.
3. Open `sql/01\_schema.sql` in the Query Tool and execute the whole file. In the browser tree, refresh **Schemas → team6 → Tables**.
4. Open `sql/02\_seed\_data.sql` and execute it once. Its final query should show **1,000 borrowers, 300 equipment items, 30,000 loans, and 30 loans for borrower 42**. The script also runs `ANALYZE` so Jordan can take the baseline immediately.
5. Open `tests/01\_integrity\_tests.sql`. Follow the selection instructions at the top. For a rejected insert, capture **Messages** with the constraint error, then run that test's `ROLLBACK;` on its own. The final check should still show 30,000 loans.

The schema script expects a new database. The seed script expects empty project tables. For another clean run, create a separate database and repeat steps 2–5. Each member can use their own local copy loaded from the same commit.

The starter was checked in an isolated PostgreSQL 18.1 database. The four counts matched, the open loan was accepted, and all six invalid inserts were rejected. After the test transactions were rolled back, the loan count was still 30,000. Run the cases in pgAdmin to collect the team's screenshots.

## Tables

|Table|Columns|How the desk uses it|
|-|-|-|
|`team6.borrowers`|`borrower\_id` (PK), `name`|One record per borrower. The seed file supplies the borrower numbers.|
|`team6.equipment`|`equipment\_id` (PK), `item\_name`, `category`|One record per physical item. The seed file supplies the inventory numbers.|
|`team6.loans`|`loan\_id` (identity PK), `borrower\_id` (FK), `equipment\_id` (FK), `checkout\_date`, `due\_date`, `return\_date`|Each loan references one borrower and one item. Both may appear in many loans. PostgreSQL assigns the loan number.|

Only `return\_date` can be NULL. That represents an item still checked out. A due date or return date can equal the checkout date, and both must be on or after checkout. A late return keeps its actual date. All 30,000 seed loans are completed checkouts. Test 1 shows an open loan and rolls it back.

\## Security and Access Control



The database uses role-based access control (RBAC) to

limit what users can access and modify. Two roles were

created following the principle of least privilege:

`team6\_reader` and `team6\_staff`.



The reader role can view records but cannot modify them.

The staff role can view records, create new checkout

records, and update return dates. Neither role has

administrative privileges.



| Permission | Reader | Staff |

| --- | --- | --- |

| SELECT borrowers, equipment, and loans | Allowed | Allowed |

| INSERT loans | Denied | Allowed |

| UPDATE loan return\_date | Denied | Allowed |

| UPDATE loan due\_date | Denied | Denied |

| UPDATE equipment | Denied | Denied |

| DELETE loans | Denied | Denied |



\### Running the security scripts



1\. Complete the schema and data setup.

2\. Open `sql/03\_roles\_privileges.sql` in pgAdmin

&#x20;  using an authorized administrator account.

3\. Execute the role creation and permissions script once.

4\. Open `tests/02\_access\_tests.sql`.

5\. Execute each numbered test separately and verify

&#x20;  the expected results.

6\. Roll back test transactions to preserve the original

&#x20;  records.



\### Security test results



All nine permission tests produced the expected results.

Unauthorized operations were rejected with PostgreSQL

error code 42501 (insufficient privilege).



Final verification confirmed the original record counts:



\- Borrowers: 1,000

\- Equipment: 300

\- Loans: 30,000



Screenshots of the role verification, permissions,

and access tests are available in

\[results/security/]



## Jordan's baseline

Run this on the seeded database before creating the borrower/date index. Borrower 42 has 30 loans. Keep the SELECT and the dataset identical for both sets of measurements.

```sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT loan\_id, equipment\_id, checkout\_date, due\_date, return\_date
FROM team6.loans
WHERE borrower\_id = 42
ORDER BY checkout\_date DESC;
```

The following query shows the starting indexes. The only one on `team6.loans` should be `loans\_pkey`.

```sql
SELECT indexname, indexdef
FROM pg\_indexes
WHERE schemaname = 'team6' AND tablename = 'loans'
ORDER BY indexname;
```

Save the baseline output before running `sql/04\_indexes.sql`. Then repeat the same query with the composite index on `team6.loans (borrower\_id, checkout\_date)`. Record the scan and any sort, actual rows, execution time, and shared buffer hits/reads. A practical comparison is one warm-up followed by three measured runs per condition. Keep the raw plans and use the median time for each condition.

## Where each file goes

|Path|Purpose and order|
|-|-|
|`sql/01\_schema.sql`, `sql/02\_seed\_data.sql`|Included. Run in this order.|
|`tests/01\_integrity\_tests.sql`|Included. Run each case separately after seeding.|
|`sql/03\_roles\_privileges.sql`, `tests/02\_access\_tests.sql`|Anthony adds the roles/grants, then the allowed and denied operation tests. Use an authorized login for role switching and roll back test writes.|
|`tests/03\_baseline\_plan.sql` → `sql/04\_indexes.sql` → `tests/04\_indexed\_plan.sql`|Jordan adds these in the order shown. Save the unindexed evidence before creating the index.|
|`results/`|`01\_integrity\_check.txt` records the PostgreSQL 18.1 starter check. Add the team's pgAdmin evidence, role tests, and both query plans as they are recorded.|
|`docs/`|Team checklist and `architecture.png`, the workflow diagram from Figure 1 of the proposal. Add the final project report here.|

## Demo and final README

1. Mason shows the three tables, seed counts, and a rejected loan in pgAdmin.
2. Anthony shows which role is active, a permitted action, and a denied write.
3. Jordan runs the borrower lookup and compares the saved baseline and indexed plans. Use a fresh seeded copy if repeating the live before/after sequence.
4. The team summarizes the measurements, one limitation, and each member's contribution. Add the tested versions, final script order, measured results, and links to the report and recording here when available.

## References

* [PostgreSQL documentation on constraints](https://www.postgresql.org/docs/18/ddl-constraints.html)
* [PostgreSQL documentation on generate\_series](https://www.postgresql.org/docs/18/functions-srf.html)
* [PostgreSQL documentation on privileges](https://www.postgresql.org/docs/18/ddl-priv.html)
* [PostgreSQL documentation on EXPLAIN](https://www.postgresql.org/docs/18/using-explain.html)
* [pgAdmin Query Tool documentation](https://www.pgadmin.org/docs/pgadmin4/latest/query_tool.html)

