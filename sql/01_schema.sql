-- Run once in a new team6_checkout database.
BEGIN;

CREATE SCHEMA team6;

CREATE TABLE team6.borrowers (
    borrower_id integer PRIMARY KEY,
    name text NOT NULL
);

CREATE TABLE team6.equipment (
    equipment_id integer PRIMARY KEY,
    item_name text NOT NULL,
    category text NOT NULL
);

CREATE TABLE team6.loans (
    loan_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    borrower_id integer NOT NULL REFERENCES team6.borrowers (borrower_id),
    equipment_id integer NOT NULL REFERENCES team6.equipment (equipment_id),
    checkout_date date NOT NULL,
    due_date date NOT NULL,
    return_date date,
    CONSTRAINT due_on_or_after_checkout CHECK (due_date >= checkout_date),
    CONSTRAINT return_on_or_after_checkout CHECK (return_date >= checkout_date)
);

COMMIT;
