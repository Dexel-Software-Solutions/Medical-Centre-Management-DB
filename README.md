<div align="center">

<!-- Animated Banner -->
<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0f4c75,50:1b6ca8,100:00b4d8&height=220&section=header&text=SmartCare%20Medical%20Centre&fontSize=40&fontColor=ffffff&fontAlignY=38&desc=Relational%20Database%20Management%20System&descSize=18&descAlignY=58&animation=fadeIn" width="100%"/>

<!-- Badges Row -->
<p>
  <img src="https://img.shields.io/badge/MySQL-8.0-4479A1?style=for-the-badge&logo=mysql&logoColor=white"/>
  <img src="https://img.shields.io/badge/Engine-InnoDB-00758F?style=for-the-badge&logo=mysql&logoColor=white"/>
  <img src="https://img.shields.io/badge/Charset-utf8mb4-FF6B6B?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/Status-Complete-28a745?style=for-the-badge"/>
  <img src="https://img.shields.io/badge/License-Academic-blueviolet?style=for-the-badge"/>
</p>

<p>
  <img src="https://img.shields.io/badge/Tables-10-0f4c75?style=flat-square"/>
  <img src="https://img.shields.io/badge/Foreign%20Keys-12-1b6ca8?style=flat-square"/>
  <img src="https://img.shields.io/badge/Indexes-6-00b4d8?style=flat-square"/>
  <img src="https://img.shields.io/badge/Check%20Constraints-4-teal?style=flat-square"/>
</p>

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Entity Relationship Diagram](#-entity-relationship-diagram)
- [Database Schema](#-database-schema)
- [Key Design Decisions](#-key-design-decisions)
- [Sample Queries](#-sample-queries)
- [Setup & Installation](#-setup--installation)
- [Project Structure](#-project-structure)
- [Tech Stack](#-tech-stack)

---

## 🏥 Overview

**SmartCare Medical Centre DB** is a fully normalised relational database system designed to manage the end-to-end operations of a multi-branch private medical centre. The system handles clinician management, patient records, consultation scheduling, prescriptions, clinical procedures, and billing — all within a single coherent schema.

> 🎓 This project was developed as part of a **Database Systems** assignment, demonstrating advanced schema design, referential integrity enforcement, index optimisation, and multi-table query authoring.

### ✨ Core Capabilities

| Domain | Coverage |
|---|---|
| 🏢 **Branch Management** | Multi-location support with manager assignment |
| 👨‍⚕️ **Clinician Registry** | SLMC-registered specialists linked to branches |
| 🧑‍💼 **Patient Records** | Full demographic and enrolment tracking |
| 📅 **Consultation Engine** | Bookings with status lifecycle management |
| 💊 **Medication Orders** | Drug formulary with prescribing clinician audit |
| 🔬 **Clinical Procedures** | Per-consultation procedure logging with fees |
| 🧾 **Billing & Payments** | Multi-channel payment transaction tracking |

---

## 🗂️ Entity Relationship Diagram

```
┌─────────────────┐         ┌──────────────────────┐
│     Branch      │◄────────│      Clinician        │
│─────────────────│    ┌────│──────────────────────│
│ branch_id  (PK) │    │    │ clinician_id     (PK) │
│ branch_name     │    │    │ first_name            │
│ street_address  │    │    │ last_name             │
│ city            │    │    │ speciality_id    (FK) │──► MedicalSpeciality
│ contact_phone   │    │    │ slmc_reg_number       │
│ branch_manager  │    │    │ branch_id        (FK) │
└─────────────────┘    │    └──────────────────────┘
         ▲             │
         │             │    ┌──────────────────────┐
         │             └───►│    PatientRecord      │
         │                  │──────────────────────│
         └──────────────────│ patient_id       (PK) │
                            │ given_name            │
                            │ family_name           │
                            │ birth_date            │
                            │ sex                   │
                            │ national_id           │
                            │ branch_id        (FK) │
                            └──────────────────────┘
                                       │
                                       ▼
                            ┌──────────────────────┐
                            │    Consultation       │◄──── Branch (FK)
                            │──────────────────────│
                            │ consultation_id  (PK) │
                            │ visit_date            │
                            │ visit_time            │
                            │ visit_status          │
                            │ clinical_notes        │
                            │ patient_id       (FK) │
                            │ clinician_id     (FK) │
                            │ branch_id        (FK) │
                            └──────────────────────┘
                               │         │        │
               ┌───────────────┘         │        └────────────────┐
               ▼                         ▼                         ▼
  ┌──────────────────────┐  ┌──────────────────────┐  ┌──────────────────────┐
  │  ClinicalProcedure   │  │   MedicationOrder    │  │    BillingRecord     │
  │──────────────────────│  │──────────────────────│  │──────────────────────│
  │ procedure_id    (PK) │  │ order_id        (PK) │  │ bill_id         (PK) │
  │ procedure_name       │  │ prescribed_dose       │  │ gross_amount         │
  │ procedure_fee        │  │ supply_days           │  │ settlement_status    │
  │ performed_date       │  │ drug_id         (FK) │  │ due_by               │
  │ consultation_id (FK) │  │ clinician_id    (FK) │  │ consultation_id (FK) │
  └──────────────────────┘  │ consultation_id (FK) │  │ patient_id      (FK) │
                             └──────────────────────┘  └──────────────────────┘
                                       │                          │
                                       ▼                          ▼
                            ┌──────────────────────┐  ┌──────────────────────┐
                            │    DrugFormulary     │  │  PaymentTransaction  │
                            │──────────────────────│  │──────────────────────│
                            │ drug_id         (PK) │  │ txn_id          (PK) │
                            │ brand_name           │  │ paid_amount           │
                            │ generic_name         │  │ payment_channel       │
                            │ price_per_unit       │  │ payment_date          │
                            │ units_in_stock       │  │ bill_id         (FK) │
                            └──────────────────────┘  └──────────────────────┘
```

---

## 🗃️ Database Schema

### Reference Tables

<details>
<summary><b>📍 Branch</b> — Clinic location registry</summary>

```sql
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
);
```
</details>

<details>
<summary><b>🩺 MedicalSpeciality</b> — Clinical speciality catalogue</summary>

```sql
CREATE TABLE MedicalSpeciality (
    speciality_id        INT          NOT NULL AUTO_INCREMENT,
    speciality_name      VARCHAR(150) NOT NULL,
    clinical_description TEXT             NULL,
    PRIMARY KEY (speciality_id),
    UNIQUE KEY uq_spec_name (speciality_name)
);
```
</details>

<details>
<summary><b>💊 DrugFormulary</b> — Approved medicines with stock levels</summary>

```sql
CREATE TABLE DrugFormulary (
    drug_id         INT            NOT NULL AUTO_INCREMENT,
    brand_name      VARCHAR(200)   NOT NULL,
    generic_name    VARCHAR(200)       NULL,
    manufacturer    VARCHAR(150)       NULL,
    price_per_unit  DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
    units_in_stock  INT            NOT NULL DEFAULT 0,
    PRIMARY KEY (drug_id),
    UNIQUE KEY uq_brand (brand_name),
    CONSTRAINT chk_stock_nonneg CHECK (units_in_stock >= 0)
);
```
</details>

---

### Transactional Tables

<details>
<summary><b>👨‍⚕️ Clinician</b> — Registered medical professionals</summary>

```sql
CREATE TABLE Clinician (
    clinician_id    INT           NOT NULL AUTO_INCREMENT,
    first_name      VARCHAR(100)  NOT NULL,
    last_name       VARCHAR(100)  NOT NULL,
    speciality_id   INT           NOT NULL,  -- FK → MedicalSpeciality
    slmc_reg_number VARCHAR(60)   NOT NULL,  -- Sri Lanka Medical Council ID (UNIQUE)
    work_phone      VARCHAR(20)       NULL,
    work_email      VARCHAR(150)      NULL,
    branch_id       INT           NOT NULL,  -- FK → Branch
    joined_date     DATE              NULL,
    PRIMARY KEY (clinician_id),
    UNIQUE KEY uq_slmc (slmc_reg_number)
);
```
</details>

<details>
<summary><b>🧑‍💼 PatientRecord</b> — Patient demographics and enrolment</summary>

```sql
CREATE TABLE PatientRecord (
    patient_id     INT            NOT NULL AUTO_INCREMENT,
    given_name     VARCHAR(100)   NOT NULL,
    family_name    VARCHAR(100)   NOT NULL,
    birth_date     DATE           NOT NULL,
    sex            ENUM('Male','Female','Other') NOT NULL,
    national_id    VARCHAR(20)        NULL,  -- NIC (UNIQUE)
    mobile         VARCHAR(20)    NOT NULL,
    email          VARCHAR(150)       NULL,
    home_address   VARCHAR(255)       NULL,
    branch_id      INT            NOT NULL,  -- FK → Branch
    enrolment_date DATE           NOT NULL DEFAULT (CURRENT_DATE),
    PRIMARY KEY (patient_id),
    UNIQUE KEY uq_natid (national_id)
);
```
</details>

<details>
<summary><b>📅 Consultation</b> — Appointment and visit records</summary>

```sql
-- visit_status lifecycle:
-- Booked → Confirmed → Completed
--                    → Cancelled
--                    → DidNotAttend
CREATE TABLE Consultation (
    consultation_id INT   NOT NULL AUTO_INCREMENT,
    visit_date      DATE  NOT NULL,
    visit_time      TIME  NOT NULL,
    visit_status    ENUM('Booked','Confirmed','Completed','Cancelled','DidNotAttend')
                          NOT NULL DEFAULT 'Booked',
    clinical_notes  TEXT      NULL,
    patient_id      INT   NOT NULL,   -- FK → PatientRecord
    clinician_id    INT   NOT NULL,   -- FK → Clinician
    branch_id       INT   NOT NULL,   -- FK → Branch
    PRIMARY KEY (consultation_id)
);
```
</details>

<details>
<summary><b>🔬 ClinicalProcedure</b> — Procedures performed per consultation</summary>

```sql
CREATE TABLE ClinicalProcedure (
    procedure_id          INT            NOT NULL AUTO_INCREMENT,
    procedure_name        VARCHAR(200)   NOT NULL,
    procedure_description TEXT               NULL,
    procedure_fee         DECIMAL(10,2)  NOT NULL DEFAULT 0.00,
    performed_date        DATE           NOT NULL,
    consultation_id       INT            NOT NULL,   -- FK → Consultation (CASCADE DELETE)
    PRIMARY KEY (procedure_id),
    CONSTRAINT chk_fee_nonneg CHECK (procedure_fee >= 0)
);
```
</details>

<details>
<summary><b>💉 MedicationOrder</b> — Prescriptions with dispensing audit trail</summary>

```sql
CREATE TABLE MedicationOrder (
    order_id        INT           NOT NULL AUTO_INCREMENT,
    prescribed_dose VARCHAR(100)  NOT NULL,
    dose_schedule   VARCHAR(100)      NULL,
    supply_days     INT               NULL,
    order_date      DATE          NOT NULL DEFAULT (CURRENT_DATE),
    consultation_id INT           NOT NULL,  -- FK → Consultation (CASCADE DELETE)
    drug_id         INT           NOT NULL,  -- FK → DrugFormulary
    clinician_id    INT           NOT NULL,  -- FK → Clinician
    PRIMARY KEY (order_id)
);
```
</details>

<details>
<summary><b>🧾 BillingRecord</b> — Financial records per consultation</summary>

```sql
-- settlement_status lifecycle:
-- Pending → PartiallyPaid → Cleared
--         → Overdue
--         → Void
CREATE TABLE BillingRecord (
    bill_id           INT            NOT NULL AUTO_INCREMENT,
    bill_date         DATE           NOT NULL DEFAULT (CURRENT_DATE),
    gross_amount      DECIMAL(12,2)  NOT NULL DEFAULT 0.00,
    due_by            DATE               NULL,
    settlement_status ENUM('Pending','PartiallyPaid','Cleared','Overdue','Void')
                                     NOT NULL DEFAULT 'Pending',
    consultation_id   INT            NOT NULL,  -- FK → Consultation (UNIQUE)
    patient_id        INT            NOT NULL,  -- FK → PatientRecord
    PRIMARY KEY (bill_id),
    UNIQUE KEY uq_bill_cons (consultation_id),
    CONSTRAINT chk_gross_nonneg CHECK (gross_amount >= 0)
);
```
</details>

<details>
<summary><b>💳 PaymentTransaction</b> — Multi-channel payment entries</summary>

```sql
CREATE TABLE PaymentTransaction (
    txn_id          INT            NOT NULL AUTO_INCREMENT,
    paid_amount     DECIMAL(12,2)  NOT NULL,
    payment_date    DATE           NOT NULL DEFAULT (CURRENT_DATE),
    payment_channel ENUM('Cash','Card','BankTransfer','InsuranceClaim','OnlinePortal')
                                   NOT NULL,
    reference_code  VARCHAR(100)       NULL,
    bill_id         INT            NOT NULL,  -- FK → BillingRecord
    PRIMARY KEY (txn_id),
    CONSTRAINT chk_paid_positive CHECK (paid_amount > 0)
);
```
</details>

---

## 🎯 Key Design Decisions

### Referential Integrity Strategy

| Relationship | ON UPDATE | ON DELETE | Rationale |
|---|---|---|---|
| Clinician → MedicalSpeciality | `CASCADE` | `RESTRICT` | Speciality name changes propagate; deletion blocked if clinicians exist |
| PatientRecord → Branch | `CASCADE` | `RESTRICT` | Patients cannot be orphaned from a branch |
| Consultation → Patient / Clinician | `CASCADE` | `RESTRICT` | Core audit record must be preserved |
| ClinicalProcedure → Consultation | `CASCADE` | `CASCADE` | Procedures are child records with no standalone meaning |
| MedicationOrder → Consultation | `CASCADE` | `CASCADE` | Orders are tied to the consultation lifecycle |
| BillingRecord → Consultation | `CASCADE` | `RESTRICT` | Financial records must not be silently deleted |

### Index Optimisation

```sql
-- High-frequency date-range queries on appointments
ALTER TABLE Consultation    ADD INDEX idx_cons_date    (visit_date);

-- Patient search by surname (most common lookup pattern)
ALTER TABLE PatientRecord   ADD INDEX idx_pat_name     (family_name, given_name);

-- Overdue billing reports filtered by status + date
ALTER TABLE BillingRecord   ADD INDEX idx_bill_status  (settlement_status, due_by);

-- Generic drug lookup for prescribing workflow
ALTER TABLE DrugFormulary   ADD INDEX idx_drug_generic (generic_name);
```

### Data Integrity Constraints

```sql
-- Financial guards: no negative amounts
CONSTRAINT chk_paid_positive  CHECK (paid_amount    >  0)
CONSTRAINT chk_fee_nonneg     CHECK (procedure_fee  >= 0)
CONSTRAINT chk_gross_nonneg   CHECK (gross_amount   >= 0)

-- Inventory guard: stock cannot go below zero
CONSTRAINT chk_stock_nonneg   CHECK (units_in_stock >= 0)
```

### Normalisation

The schema is designed to **3NF (Third Normal Form)**:
- All non-key attributes depend only on the primary key (no partial dependencies)
- No transitive dependencies exist between non-key columns
- Lookup data (specialities, drugs, branches) is stored once and referenced via FKs

---

## 🔍 Sample Queries

### Patient Consultation History — Full JOIN

```sql
-- Retrieve complete consultation history for a patient,
-- spanning 6 tables with LEFT JOIN for optional billing
SELECT
    pr.patient_id,
    CONCAT(pr.given_name, ' ', pr.family_name)   AS patient_name,
    c.consultation_id,
    c.visit_date,
    c.visit_time,
    c.visit_status,
    CONCAT(cl.first_name, ' ', cl.last_name)     AS clinician_name,
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
```

> 💡 `LEFT JOIN` on `BillingRecord` is intentional — some consultations may not yet have a bill generated, and those records should still appear in the history.

---

## 🚀 Setup & Installation

### Prerequisites

- MySQL Server **8.0+**
- MySQL Workbench (recommended) or any compatible MySQL client
- A user account with `CREATE DATABASE` privileges

### Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/Dexel-Software-Solutions/Medical-Centre-Management-DB.git
cd Medical-Centre-Management-DB

# 2. Connect to your MySQL instance
mysql -u root -p

# 3. Run the full schema script
mysql -u root -p < smartcare_db.sql
```

Or, from inside MySQL Workbench:

```sql
-- Run the full script directly
SOURCE /path/to/smartcare_db.sql;

-- Verify all tables were created
USE SmartCare_db;
SHOW TABLES;
```

### Expected Output

```
+---------------------------+
| Tables_in_SmartCare_db    |
+---------------------------+
| BillingRecord             |
| Branch                    |
| ClinicalProcedure         |
| Clinician                 |
| Consultation              |
| DrugFormulary             |
| MedicalSpeciality         |
| MedicationOrder           |
| PatientRecord             |
| PaymentTransaction        |
+---------------------------+
10 rows in set
```

---

## 📁 Project Structure

```
Medical-Centre-Management-DB/
│
├── 📄 smartcare_db.sql          # Complete schema + seed data + sample queries
│
└── 📄 README.md                 # This file
```

---

## 🛠️ Tech Stack

<div align="center">

<img src="https://img.shields.io/badge/MySQL-8.0-4479A1?style=for-the-badge&logo=mysql&logoColor=white"/>
<img src="https://img.shields.io/badge/MySQL%20Workbench-IDE-00758F?style=for-the-badge&logo=mysql&logoColor=white"/>
<img src="https://img.shields.io/badge/InnoDB-Storage%20Engine-005C84?style=for-the-badge"/>
<img src="https://img.shields.io/badge/utf8mb4-Character%20Set-9B59B6?style=for-the-badge"/>

</div>

---

## 📌 Assignment Context

> This database was designed and implemented as part of a **Database Systems** module at degree level. The assignment required demonstrating competency in:
>
> - Relational schema design with normalisation (3NF)
> - DDL authoring (`CREATE TABLE`, `ALTER TABLE`, constraints)
> - Foreign key strategy with appropriate `ON UPDATE` / `ON DELETE` rules
> - Index design for query performance
> - Multi-table `JOIN` queries with `INNER JOIN` and `LEFT JOIN`
> - Use of `ENUM` types for domain-constrained attributes
> - `CHECK` constraints for business rule enforcement

---

<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:00b4d8,50:1b6ca8,100:0f4c75&height=120&section=footer&animation=fadeIn" width="100%"/>

<sub>Built with precision for the SmartCare Medical Centre database assignment</sub>

</div>
