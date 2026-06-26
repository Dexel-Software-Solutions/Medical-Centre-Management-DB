# SmartCare Medical Centre Database System

A relational database designed for a modern medical centre management system using **MySQL 8.0**. This project demonstrates database design principles, normalization techniques, referential integrity, indexing strategies, and SQL best practices through a realistic healthcare management scenario.

> **Academic Project**
> Developed as part of a university Database Management Systems assignment to demonstrate practical relational database design and SQL implementation.

---

## Overview

The SmartCare Medical Centre Database models the core operations of a healthcare organization, including:

* Branch Management
* Clinician Management
* Medical Specialities
* Patient Records
* Consultations
* Clinical Procedures
* Medication Orders
* Billing
* Payment Transactions

The schema emphasizes maintainability, consistency, and data integrity while remaining scalable for future enhancements.

---

## Features

* Fully normalized relational database structure
* Primary and Foreign Key relationships
* Referential integrity using InnoDB
* CHECK constraints
* UNIQUE constraints
* Optimized indexing strategy
* Sample seed data
* Analytical JOIN queries
* UTF-8 (utf8mb4) character support
* Clean and well-documented SQL script

---

## Database Schema

### Core Entities

* Branch
* MedicalSpeciality
* Clinician
* PatientRecord
* Consultation
* ClinicalProcedure
* DrugFormulary
* MedicationOrder
* BillingRecord
* PaymentTransaction

---

## Technologies

| Technology     | Version                     |
| -------------- | --------------------------- |
| MySQL          | 8.0                         |
| Storage Engine | InnoDB                      |
| Character Set  | utf8mb4                     |
| SQL Standard   | ANSI SQL (MySQL Compatible) |

---

## Database Design Highlights

* Logical separation of reference and transactional entities
* Enforced referential integrity
* Proper normalization to reduce redundancy
* Meaningful naming conventions
* Indexed frequently queried columns
* Validation through CHECK constraints
* Production-style SQL formatting and documentation

---

## Project Structure

```
.
├── SmartCare_Database.sql
└── README.md
```

---

## Sample SQL Capabilities

The database demonstrates:

* Database creation
* Table creation
* Foreign key implementation
* Constraint management
* Index creation
* Sample data insertion
* Multi-table JOIN queries
* Consultation history retrieval
* Billing relationships
* Payment tracking

---

## Learning Outcomes

This project demonstrates practical understanding of:

* Relational Database Design
* Entity Relationships
* Data Integrity
* SQL DDL
* SQL DML
* Index Optimization
* Constraint Management
* Database Documentation

---

## Future Improvements

Potential extensions include:

* Stored Procedures
* Database Views
* Triggers
* Audit Logging
* User Roles & Permissions
* Backup and Recovery Scripts
* Reporting Queries
* Performance Optimization

---

## Academic Note

This repository represents an academic database design project created to demonstrate practical database engineering concepts using MySQL. It is intended for educational purposes and portfolio presentation.

---

## Author

**Demiyan Dissanayake**

Software Engineering Undergraduate

GitHub: https://github.com/Dexel-Software-Solutions
---

## License

This project is released under the MIT License.
