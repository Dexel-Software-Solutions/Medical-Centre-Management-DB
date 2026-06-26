-- ================================================================
--  SmartCare Medical Centre  |  Database System  |  Version 1.0
--  RDBMS  : MySQL 8.0    Engine : InnoDB    Charset : utf8mb4
-- ================================================================

-- ================================================================
-- SECTION 1 : CREATE DATABASE
-- ================================================================

CREATE DATABASE IF NOT EXISTS SmartCare_db
    CHARACTER SET  utf8mb4
    COLLATE        utf8mb4_unicode_ci;

USE SmartCare_db;

-- ================================================================
-- SECTION 2 : CREATE TABLE STATEMENTS
-- ================================================================

-- ── REFERENCE TABLES (no FK dependencies) ─────────────────────

CREATE TABLE Branch (
    branch_id      INT           NOT NULL AUTO_INCREMENT,
    branch_name    VARCHAR(150)  NOT NULL,
    street_address VARCHAR(255)  NOT NULL,
    city           VARCHAR(100)  NOT NULL,
    contact_phone  VARCHAR(20)   NOT NULL,
    contact_email  VARCHAR(150)      NULL,
    branch_manager VARCHAR(150)      NULL,
    created_at     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (branch_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE MedicalSpeciality (
    speciality_id          INT          NOT NULL AUTO_INCREMENT,
    speciality_name        VARCHAR(150) NOT NULL,
    clinical_description   TEXT             NULL,
    PRIMARY KEY (speciality_id),
    UNIQUE KEY uq_spec_name (speciality_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE DrugFormulary (
    drug_id         INT            NOT NULL AUTO_INCREMENT,
    brand_name      VARCHAR(200)   NOT NULL,
    generic_name    VARCHAR(200)       NULL,
    manufacturer    VARCHAR(150)       NULL,
    price_per_unit  DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
    units_in_stock  INT            NOT NULL DEFAULT 0,
    PRIMARY KEY (drug_id),
    UNIQUE KEY uq_brand (brand_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── ENTITIES WITH FK REFERENCES ────────────────────────────────

CREATE TABLE Clinician (
    clinician_id      INT           NOT NULL AUTO_INCREMENT,
    first_name        VARCHAR(100)  NOT NULL,
    last_name         VARCHAR(100)  NOT NULL,
    speciality_id     INT           NOT NULL,
    slmc_reg_number   VARCHAR(60)   NOT NULL,
    work_phone        VARCHAR(20)       NULL,
    work_email        VARCHAR(150)      NULL,
    branch_id         INT           NOT NULL,
    joined_date       DATE              NULL,
    PRIMARY KEY  (clinician_id),
    UNIQUE KEY   uq_slmc (slmc_reg_number),
    CONSTRAINT fk_clin_spec   FOREIGN KEY (speciality_id)
        REFERENCES MedicalSpeciality (speciality_id)
        ON UPDATE CASCADE  ON DELETE RESTRICT,
    CONSTRAINT fk_clin_branch FOREIGN KEY (branch_id)
        REFERENCES Branch (branch_id)
        ON UPDATE CASCADE  ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE PatientRecord (
    patient_id       INT            NOT NULL AUTO_INCREMENT,
    given_name       VARCHAR(100)   NOT NULL,
    family_name      VARCHAR(100)   NOT NULL,
    birth_date       DATE           NOT NULL,
    sex              ENUM('Male','Female','Other') NOT NULL,
    national_id      VARCHAR(20)        NULL,
    mobile           VARCHAR(20)    NOT NULL,
    email            VARCHAR(150)       NULL,
    home_address     VARCHAR(255)       NULL,
    branch_id        INT            NOT NULL,
    enrolment_date   DATE           NOT NULL DEFAULT (CURRENT_DATE),
    PRIMARY KEY  (patient_id),
    UNIQUE KEY   uq_natid (national_id),
    CONSTRAINT fk_pat_branch FOREIGN KEY (branch_id)
        REFERENCES Branch (branch_id)
        ON UPDATE CASCADE  ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE Consultation (
    consultation_id   INT   NOT NULL AUTO_INCREMENT,
    visit_date        DATE  NOT NULL,
    visit_time        TIME  NOT NULL,
    visit_status  ENUM('Booked','Confirmed','Completed','Cancelled','DidNotAttend')
                              NOT NULL DEFAULT 'Booked',
    clinical_notes    TEXT      NULL,
    patient_id        INT   NOT NULL,
    clinician_id      INT   NOT NULL,
    branch_id         INT   NOT NULL,
    PRIMARY KEY (consultation_id),
    CONSTRAINT fk_cons_pat    FOREIGN KEY (patient_id)
        REFERENCES PatientRecord (patient_id)
        ON UPDATE CASCADE  ON DELETE RESTRICT,
    CONSTRAINT fk_cons_clin   FOREIGN KEY (clinician_id)
        REFERENCES Clinician (clinician_id)
        ON UPDATE CASCADE  ON DELETE RESTRICT,
    CONSTRAINT fk_cons_branch FOREIGN KEY (branch_id)
        REFERENCES Branch (branch_id)
        ON UPDATE CASCADE  ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE ClinicalProcedure (
    procedure_id          INT            NOT NULL AUTO_INCREMENT,
    procedure_name        VARCHAR(200)   NOT NULL,
    procedure_description TEXT               NULL,
    procedure_fee         DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
    performed_date        DATE           NOT NULL,
    consultation_id       INT            NOT NULL,
    PRIMARY KEY (procedure_id),
    CONSTRAINT fk_proc_cons FOREIGN KEY (consultation_id)
        REFERENCES Consultation (consultation_id)
        ON UPDATE CASCADE  ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE MedicationOrder (
    order_id         INT           NOT NULL AUTO_INCREMENT,
    prescribed_dose  VARCHAR(100)  NOT NULL,
    dose_schedule    VARCHAR(100)      NULL,
    supply_days      INT               NULL,
    order_date       DATE          NOT NULL DEFAULT (CURRENT_DATE),
    consultation_id  INT           NOT NULL,
    drug_id          INT           NOT NULL,
    clinician_id     INT           NOT NULL,
    PRIMARY KEY (order_id),
    CONSTRAINT fk_mo_cons FOREIGN KEY (consultation_id)
        REFERENCES Consultation (consultation_id)
        ON UPDATE CASCADE  ON DELETE CASCADE,
    CONSTRAINT fk_mo_drug FOREIGN KEY (drug_id)
        REFERENCES DrugFormulary (drug_id)
        ON UPDATE CASCADE  ON DELETE RESTRICT,
    CONSTRAINT fk_mo_clin FOREIGN KEY (clinician_id)
        REFERENCES Clinician (clinician_id)
        ON UPDATE CASCADE  ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE BillingRecord (
    bill_id            INT            NOT NULL AUTO_INCREMENT,
    bill_date          DATE           NOT NULL DEFAULT (CURRENT_DATE),
    gross_amount       DECIMAL(12,2)  NOT NULL DEFAULT 0.00,
    due_by             DATE               NULL,
    settlement_status  ENUM('Pending','PartiallyPaid','Cleared','Overdue','Void')
                                      NOT NULL DEFAULT 'Pending',
    consultation_id    INT            NOT NULL,
    patient_id         INT            NOT NULL,
    PRIMARY KEY (bill_id),
    UNIQUE KEY  uq_bill_cons (consultation_id),
    CONSTRAINT fk_bill_cons FOREIGN KEY (consultation_id)
        REFERENCES Consultation (consultation_id)
        ON UPDATE CASCADE  ON DELETE RESTRICT,
    CONSTRAINT fk_bill_pat  FOREIGN KEY (patient_id)
        REFERENCES PatientRecord (patient_id)
        ON UPDATE CASCADE  ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE PaymentTransaction (
    txn_id          INT            NOT NULL AUTO_INCREMENT,
    paid_amount     DECIMAL(12,2)  NOT NULL,
    payment_date    DATE           NOT NULL DEFAULT (CURRENT_DATE),
    payment_channel ENUM('Cash','Card','BankTransfer','InsuranceClaim','OnlinePortal')
                                   NOT NULL,
    reference_code  VARCHAR(100)       NULL,
    bill_id         INT            NOT NULL,
    PRIMARY KEY (txn_id),
    CONSTRAINT fk_txn_bill FOREIGN KEY (bill_id)
        REFERENCES BillingRecord (bill_id)
        ON UPDATE CASCADE  ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ================================================================
-- SECTION 3 : ALTER TABLE – INDEXES AND CONSTRAINTS
-- ================================================================

-- Consultation lookup by date (most frequent query pattern)
ALTER TABLE Consultation
    ADD INDEX idx_cons_date (visit_date);

-- Patient name search index
ALTER TABLE PatientRecord
    ADD INDEX idx_pat_name (family_name, given_name);

-- Billing status and overdue reporting index
ALTER TABLE BillingRecord
    ADD INDEX idx_bill_status (settlement_status, due_by);

-- Drug stock lookup index
ALTER TABLE DrugFormulary
    ADD INDEX idx_drug_generic (generic_name);

-- Data integrity CHECK constraints
ALTER TABLE PaymentTransaction
    ADD CONSTRAINT chk_paid_positive CHECK (paid_amount > 0);

ALTER TABLE ClinicalProcedure
    ADD CONSTRAINT chk_fee_nonneg CHECK (procedure_fee >= 0);

ALTER TABLE DrugFormulary
    ADD CONSTRAINT chk_stock_nonneg CHECK (units_in_stock >= 0);

ALTER TABLE BillingRecord
    ADD CONSTRAINT chk_gross_nonneg CHECK (gross_amount >= 0);

-- ================================================================
-- SECTION 4 : SAMPLE INSERT STATEMENTS
-- ================================================================

-- Seed data: Branch
INSERT INTO Branch (branch_name, street_address, city, contact_phone, contact_email, branch_manager)
VALUES
  ('SmartCare Negombo', '17 Sea Street, Negombo', 'Negombo', '+94312223344', 'negombo@smartcare.lk', 'Mrs. K. Ranatunga'),
  ('SmartCare Colombo 07', '34 Jawatte Road, Colombo 07', 'Colombo', '+94112334455', 'col07@smartcare.lk', 'Mr. P. De Silva');

-- Seed data: MedicalSpeciality
INSERT INTO MedicalSpeciality (speciality_name, clinical_description) VALUES
  ('Endocrinology',     'Disorders of the endocrine system and metabolism'),
  ('General Practice',  'Primary and preventive outpatient care'),
  ('Cardiology',        'Diagnosis and treatment of cardiovascular conditions');

-- Seed data: Clinician
INSERT INTO Clinician (first_name, last_name, speciality_id, slmc_reg_number, work_phone, branch_id, joined_date)
VALUES
  ('Ruwan',    'Jayasena',    1, 'SLMC-2009-077', '0713344556', 1, '2019-08-01'),
  ('Dilrukshi','Abeywardena', 2, 'SLMC-2016-214', '0721122334', 2, '2021-03-15');

-- Seed data: PatientRecord
INSERT INTO PatientRecord (given_name, family_name, birth_date, sex, national_id, mobile, home_address, branch_id)
VALUES
  ('Ishara',  'Wickramasinghe', '1984-06-11', 'Male',   '841620012V', '0778899001', '22/A Lake Rd, Negombo', 1),
  ('Sewwandi','Gunawardena',    '1995-11-28', 'Female', '952330045V', '0769977883', '7 Palm Ave, Colombo 07', 2);

-- ================================================================
-- SECTION 5 : SAMPLE SELECT QUERY – Patient Consultation History
-- ================================================================

-- Retrieve full consultation history for a given patient
-- Demonstrates JOIN across PatientRecord, Consultation, Clinician,
-- MedicalSpeciality, Branch, and BillingRecord

SELECT
    pr.patient_id,
    CONCAT(pr.given_name, ' ', pr.family_name)        AS patient_name,
    c.consultation_id,
    c.visit_date,
    c.visit_time,
    c.visit_status,
    CONCAT(cl.first_name, ' ', cl.last_name)          AS clinician_name,
    ms.speciality_name,
    b.branch_name,
    br.gross_amount,
    br.settlement_status
FROM        Consultation      c
INNER JOIN  PatientRecord     pr  ON c.patient_id    = pr.patient_id
INNER JOIN  Clinician         cl  ON c.clinician_id  = cl.clinician_id
INNER JOIN  MedicalSpeciality ms  ON cl.speciality_id = ms.speciality_id
INNER JOIN  Branch            b   ON c.branch_id     = b.branch_id
LEFT  JOIN  BillingRecord     br  ON c.consultation_id = br.consultation_id
WHERE  pr.patient_id = 1
ORDER  BY c.visit_date DESC, c.visit_time DESC;
