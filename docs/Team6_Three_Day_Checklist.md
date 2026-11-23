# Team 6 · Three-day project checklist

**Campus Equipment Checkout | CSCE 4355 | November 22–25, 2026**

Mason's first handoff is the schema plus the seeded loan history. Jordan needs both to measure the borrower lookup. Anthony can start writing grants as soon as he has the table definitions. Each person can work in their own local copy of the database from the same commit.

## Sunday, November 22 · Get teammates started tonight

- [ ] **Mason** — Confirm the due time and proposal approval in Canvas. The supplied guidelines give no clock time. The proposal review row for Mason says “Pending” with “Approved” in the notes; reconcile it if the team keeps that copy.
- [ ] **Mason** — Create the GitHub repository, add the starter files, and invite Anthony and Jordan. In pgAdmin, run `sql/01_schema.sql` and then `sql/02_seed_data.sql` in a new `team6_checkout` database. Capture the counts and give both teammates the repo link and the commit they should use. They can also start from the extracted handoff.
- [ ] **Jordan** — Run the two files locally. Check for **1,000 borrowers, 300 items, 30,000 loans, and 30 rows for borrower 42**. Verify that `loans_pkey` is the only index on the loans table. Save the first baseline plan before creating the composite index.
- [ ] **Anthony** — Check that the local setup account can create roles and switch to them. Draft the privilege table for `team6_reader` and `team6_staff`. A practical split is reader SELECT on all three tables, and staff SELECT plus loan INSERT and UPDATE of `return_date`. Test a denied DELETE and a denied reader write.

## Monday, November 23 · Finish the three modules

| Owner | Work to complete | Evidence to hand over by evening |
| --- | --- | --- |
| Mason | Run `tests/01_integrity_tests.sql` one case at a time. Record a valid open loan, missing borrower/item, invalid dates, missing due date, and duplicate key. Roll back each case. Draft the problem, objectives, and database design. Start the architecture section with the proposal's Figure 1 in `docs/architecture.png`. | Seed counts, accepted insert, constraint errors, final loan count, and a captioned diagram checked against the actual setup. |
| Anthony | Complete `sql/03_roles_privileges.sql` and `tests/02_access_tests.sql`. Grant schema access and the chosen table/column permissions. Test as each role, display `current_user`, and roll back test writes. Write the security section and permissions table. | Actual allowed SELECT and staff INSERT/UPDATE, a reader write denial, and a staff denial. Record the role, operation, expected result, and actual result. |
| Jordan | Complete `tests/03_baseline_plan.sql`, then `sql/04_indexes.sql`, then `tests/04_indexed_plan.sql`. Index `team6.loans (borrower_id, checkout_date)`. Run the same SELECT on the same 30,000 loans before and after. Write the index design, method, results, and limitations. | Both text plans and a comparison of scan/sort, actual rows, execution time, and shared buffer hits/reads. Try one warm-up and three timed runs per condition, then compare medians. |

- [ ] **All three** — Commit each finished module and its evidence. Review another member's work and agree on the versions and commit to use for Tuesday's clean run.

## Tuesday, November 24 · Reproduce, write, and record

- [ ] **Mason** — Start a fresh database from the agreed commit. Follow the README, verify the totals, and save one accepted and one rejected example for the report. Assemble the report and add captions and figure references.
- [ ] **Anthony** — Recheck allowed and denied operations under the limited roles. Review the README's role setup and the report's permission claims. If the roles already exist on this PostgreSQL instance, reuse the agreed project roles or test on a separate local instance; coordinate any change to shared roles.
- [ ] **Jordan** — Capture the clean baseline before making the index. Repeat the indexed lookup, keep the raw plans in `results/`, and check the comparison table against those plans. Explain any sort left in the plan or any timing variation observed.
- [ ] **All three** — Cross-check each other's sections, fill out the contribution table, and record the running database in pgAdmin. Mason introduces the problem, architecture, data, and rejected insert. Anthony shows the active roles and allowed/denied operations. Jordan shows the plans and measured result. Close with limitations and who built each module.
- [ ] **By Tuesday evening** — Upload the public or unlisted recording, finish the README and report, and try both links in a signed-out/private browser. Aim to have a submit-ready package tonight.

## Wednesday, November 25 · Submit before the Canvas cutoff

- [ ] **Anthony** checks the repository link, setup steps, permissions evidence, and absence of credentials. **Jordan** checks the video link, playback/audio for all three speakers, and the numbers quoted in the report.
- [ ] **Mason**, as suggested uploader, submits **one team report (PDF or Word), the GitHub URL, and the public/unlisted video URL** through Canvas. Use `Team6_Final_Project_Report.pdf` if exporting to PDF. Upload a ZIP or extra files only if Canvas or the instructor requests them. Save the submission confirmation and tell the team.

## What the instructor will look for

| Requirement | Final check |
| --- | --- |
| Working implementation | Three related tables in schema `team6`; primary/foreign keys, required fields, and date checks; generated data; two limited-access roles; one measured index comparison. All SQL can be reproduced. |
| Report contents | Title page (title, course, members, date), executive summary, 1 Introduction & Problem, 2 System / Database Architecture, 3 Database Design, 4 DBA Implementation, 5 Implementation Evidence, 6 Testing & Verification, 7 Results & Discussion, 8 Challenges & Limitations, 9 Team Contributions, 10 Conclusion & Future Work, and References. An appendix is optional. |
| Evidence and credit | Include expected and actual results. Number and caption every table, screenshot, and diagram. Refer to each in the text and explain what the important figures show. Keep full scripts in GitHub. Cite sources and acknowledge AI assistance as required by the course, consistent with the proposal. |
| Contribution statement | One row per person with the implementation files or tests they actually completed, the report sections they wrote, and what they explained in the recording. |
| GitHub | Use `team6-postgresql-checkout-dba-lab`. Include overview, members, prerequisites, database creation/import, run order, demo scenarios, folder map, and actual results in the final README. Keep meaningful commits as modules are finished. Use public visibility unless private access is expressly approved and already granted to the instructor. |
| Video and submission | Show the running database, important SQL, tests, and a measured result. All three members narrate or demonstrate a meaningful part. Check access, sound, and playback before submitting the report and both links. |

## Class methods worth reusing

- **Activity 10** used the same query before and after an index change. Jordan can carry the SQL text and actual plan output into the comparison and explain the scan or sort he observes.
- **Activity 11** used `generate_series()`, `ANALYZE`, and transaction-based tests. Mason's seed and integrity scripts use that pattern. As in the earlier pgAdmin activities, select only the checkpoint being demonstrated and capture the command plus its output or error.

## Create the GitHub repository

1. Sign in at [GitHub's new repository page](https://github.com/new). Use your account as owner and enter `team6-postgresql-checkout-dba-lab`. Choose **Public** unless the instructor approved private access. Leave **Add README** off because the starter includes one, then click **Create repository**.
2. On the empty repository page, click **uploading an existing file**. If the repository already contains a file, use **Add file → Upload files**. Open the extracted starter and drag `README.md` and the `sql`, `tests`, `results`, and `docs` folders into the upload area. Check that `README.md` is at the top level. Commit with a message such as `Add checkout schema, seed data, and integrity tests`.
3. Under **Settings → Collaborators → Add people**, invite Anthony and Jordan by GitHub username. After they accept, each can commit their own work as it is finished and place test output in `results/`.
4. Open the repository in a private browser window. Verify the README and `sql/01_schema.sql` open there. For an approved private repository, verify the instructor's account has access instead.

GitHub documentation covers [creating a repository](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-new-repository), [uploading files and folders](https://docs.github.com/en/repositories/working-with-files/managing-files/adding-a-file-to-a-repository), and [inviting collaborators](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/repository-access-and-collaboration/inviting-collaborators-to-a-personal-repository).

The plan follows the Team 6 proposal (§§5–13), the Database Administration Project Guidelines (§§2–7 and 9–11), and the Database Administration Final Project Submission Guidelines (§§1–10). The dates above are team targets based on the stated three-day window. Canvas controls the submission cutoff.
