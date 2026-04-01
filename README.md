# Healthcare-Data-Synthesis-and-Analysis
**Simulated EMR System Architecture & Departmental Performance Auditing**

## Project Overview
This project is an end-to-end data engineering and analytics portfolio piece demonstrating the creation, management, and analysis of a synthetic Electronic Medical Record (EMR) system. It bridges the gap between Python-based data synthesis and advanced SQL relational database architecture. 

The project simulates hospital operations across Cardiology, Nephrology, and Pediatrics, focusing heavily on clinical data integrity, SQL constraints, and complex exploratory data analysis (EDA).

## Key Features
* **Synthetic EMR Pipeline:** A Python script utilizing `Pandas` and `Faker` to generate 5,000+ realistic, medically logical patient records and appointment histories.
* **Normalized Relational Architecture:** A 3-table database schema designed to decouple administrative scheduling from clinical lab results.
* **Strict Data Integrity:** Implementation of advanced SQL Data Definition Language (DDL) constraints (`PRIMARY KEY`, `FOREIGN KEY`, `CHECK`, `UNIQUE`) to eliminate logical anomalies (e.g., preventing adult assignments to Pediatrics).
* **Clinical Performance Auditing:** Complex SQL Data Manipulation Language (DML) queries utilizing `JOIN`s, Date/Time extractions, and Aggregations (`GROUP BY`, `HAVING`) to track departmental revenue and flag sub-par dialysis treatments based on URR and Kt/V metrics.

## Tech Stack
* **Language:** Python 3.x
* **Libraries:** `pandas`, `numpy`, `Faker`
* **Database:** SQL (MySQL / PostgreSQL compatible)
* **Core Concepts:** Object-Oriented Programming (OOP) principles, Relational Database Management, Data Cleaning, Advanced Aggregation.

## Database Schema
The database is structured into three normalized tables to ensure referential integrity:
1. **`patients`**: Stores demographic data (`patient_id`, `name`, `age`, contact info).
2. **`appointments`**: Stores administrative scheduling (`app_id`, `doctor_name`, `department`, `consultation_fee`, `status`).
3. **`lab_results`**: Stores specific clinical metrics (`result_id`, `test_name`, `test_value`). 

## How to Run the Project

### 1. Generate the Data
Ensure you have the required Python libraries installed:
```bash
pip install pandas numpy faker
```
Run the data synthesis script to generate the three CSV files:
```bash
python generate_emr_data.py
```

### 2. Set Up the Database
Execute the `hospital_management.sql` script in your preferred SQL client. This will:
* Create the `HospitalDB` database.
* Build the tables with all necessary `CHECK` and `FOREIGN KEY` constraints.
* Set up analytical `VIEWS`.

### 3. Import Data
Import the generated CSV files into your SQL database in the following strict order to respect foreign key constraints:
1. `patients.csv`
2. `appointments.csv`
3. `lab_results.csv`

## Sample Analytical Query
Here is a sample of the exploratory data analysis performed within the database, designed to audit the Nephrology department's clinical and financial performance:

```sql
SELECT 
    a.doctor_name,
    EXTRACT(MONTH FROM a.appointment_date) AS appointment_month,
    COUNT(a.app_id) AS total_appointments,
    SUM(a.consultation_fee) AS total_revenue,
    ROUND(AVG(l.test_value), 2) AS average_urr_score
FROM appointments a
JOIN lab_results l ON a.app_id = l.app_id
WHERE a.department = 'Nephrology' AND a.status = 'Completed' AND l.test_name = 'URR'
GROUP BY a.doctor_name, EXTRACT(MONTH FROM a.appointment_date)
HAVING AVG(l.test_value) < 65 OR SUM(a.consultation_fee) > 5000
ORDER BY appointment_month ASC, average_urr_score ASC;
```
