# Healthcare Data Engineering & Advanced SQL Analytics
**Simulated EMR Architecture, Comprehensive Joins, and Performance Auditing**

## Project Overview
This project is an end-to-end data engineering and analytics portfolio piece demonstrating the creation, management, and deep analysis of a synthetic Electronic Medical Record (EMR) system. 

It bridges the gap between Python-based data synthesis and advanced SQL relational database architecture. Moving beyond basic queries, this project heavily emphasizes complex data retrieval techniques, including every major type of `JOIN`, correlated subqueries, and multi-layered derived tables to extract clinical and financial business intelligence.

## Key Features & Concepts Mastered
* **Synthetic EMR Pipeline:** A Python script utilizing `Pandas` and `Faker` to generate 5,000+ realistic, medically logical patient records and appointment histories.
* **Normalized Relational Architecture:** A 3-table database schema designed to decouple administrative scheduling from clinical lab results.
* **Strict Data Integrity (DDL):** Implementation of advanced SQL constraints (`PRIMARY KEY`, `FOREIGN KEY`, `CHECK`, `UNIQUE`) to eliminate logical anomalies (e.g., preventing adult assignments to Pediatrics).
* **Comprehensive Table Joins:** Practical implementation of standard and exclusionary joins to map patient journeys, including:
  * `INNER`, `LEFT`, `RIGHT`, and `FULL OUTER` Joins.
  * `LEFT/RIGHT EXCLUSIVE` Joins (e.g., finding appointments with missing lab results).
  * `CROSS` Joins for schedule generation and `SELF` Joins for longitudinal patient tracking.
* **Advanced Subqueries & Derived Tables:** Utilization of nested logic for complex aggregations, such as identifying hospital-wide testing anomalies, tracking most recent patient visits, and filtering top-performing physicians using multi-level derived tables.

## Tech Stack
* **Data Synthesis Language:** Python 3.x (`pandas`, `numpy`, `Faker`)
* **Database Management:** SQL (MySQL / PostgreSQL compatible)
* **Core Competencies:** Relational Database Design, Data Cleaning, Advanced Aggregation, Correlated Subqueries, Set Operations (`UNION`).

## Database Schema
The database is structured into three normalized tables to ensure referential integrity:
1. **`patients`**: Stores demographic data (`patient_id`, `name`, `age`, contact info).
2. **`appointments`**: Stores administrative scheduling (`app_id`, `patient_id`, `doctor_name`, `department`, `status`).
3. **`lab_results`**: Stores specific clinical metrics (`result_id`, `app_id`, `test_name`, `test_value`). 

## How to Run the Project

### 1. Database Setup
Execute the `hospital_management.sql` script in your preferred SQL client. This will:
* Create the `MyHospitalDB` database.
* Build the tables with all necessary `CHECK` and referential constraints.

### 2. Import Data
*(If using the Python generation script)*: Import the generated CSV files into your SQL database in the following strict order to respect foreign key constraints:
1. `patients.csv`
2. `appointments.csv`
3. `lab_results.csv`

### 3. Run Analytics
Execute the `advanced_analytics.sql` file to view the complex Joins and Subqueries in action.

## Sample Analytical Queries

**1. Finding Repeat Patient Visits (Self Join)**
```sql
SELECT 
    a1.patient_id,
    a1.appointment_date AS first_visit_date,
    a2.appointment_date AS follow_up_date,
    a1.department
FROM appointments a1
JOIN appointments a2 ON a1.patient_id = a2.patient_id 
WHERE a1.app_id <> a2.app_id AND a1.appointment_date < a2.appointment_date;
```

**2. The "Latest Visit" Problem (Derived Tables)**
```sql
SELECT a.patient_id, p.name, a.appointment_date, a.department
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
JOIN (
    SELECT patient_id, MAX(appointment_date) AS latest_date
    FROM appointments
    GROUP BY patient_id
) AS latest_visits 
ON a.patient_id = latest_visits.patient_id AND a.appointment_date = latest_visits.latest_date;
```

## About the Author
Developed as a comprehensive technical showcase of database architecture and complex data retrieval methodologies. Based in Hyderabad, focused on leveraging Data Engineering and SQL to solve complex clinical and business problems.
