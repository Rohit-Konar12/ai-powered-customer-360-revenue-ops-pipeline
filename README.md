# AI-Powered Customer 360 & Revenue Operations Pipeline

An end-to-end data analytics project that transforms customer, order, product, support, and clickstream data into business insights, interactive Power BI dashboards, and AI-generated explanations.

## Project Overview

The project combines data quality auditing, Python ETL, exploratory data analysis, relational SQL analytics, Power BI reporting, and Generative AI.

The objective is to create a unified Customer 360 analytical layer that helps explain customer purchasing behaviour, engagement, revenue performance, product trends, and support interactions.

## Technology Stack

- **Excel:** Data quality audit
- **Python:** Data profiling, ETL, cleaning, EDA, data retrieval, and GenAI integration
- **MySQL:** Relational database, SQL analytics, and reusable analytical views
- **Power BI:** Interactive dashboards
- **Gemini API:** AI-generated customer summaries and business insights
- **VS Code / Jupyter Notebook:** Development environment

## End-to-End Workflow

Raw Data → Excel Audit → Python ETL → Python EDA → MySQL & SQL Analytics → Power BI → GenAI → Documentation

## Datasets

The project uses five datasets:

| Dataset | Description |
|---|---|
| Customers | Customer profiles and acquisition information |
| Orders | Order dates, amounts, quantities, and statuses |
| Products | Product catalogue, categories, and prices |
| Support Tickets | Issue types, sentiment, resolution information, and support agents |
| Clickstream | Customer activity, sessions, events, and timestamps |

The project includes raw datasets, cleaned CSV files, checkpoint files, and MySQL-ready exports.

## Project Structure

```text
Customer_360/
├── 01_Raw_Data/
├── 02_Excel_Audit/
│   └── Customer_360_Data_Quality_Audit.xlsx
├── 03_Python_ETL/
│   ├── 01_Data_Profiling_Audit.ipynb
│   ├── 02_Data_Cleaning_ETL.ipynb
│   └── MySQL-ready CSV files
├── 04_Python_EDA/
│   └── 01_Data_EDA.ipynb
├── 05_SQL/
│   └── 01_Customer_360_SQL.sql
├── 06_PowerBI/
│   └── 01_customer_360_powerBI.pbix
├── 07_GenAI/
│   └── Customer_360_GenAI.ipynb
```

## Project Phases

### 1. Data Profiling & Quality Audit

Audited the datasets for missing values, duplicate records, invalid values, inconsistent categories, and relationship issues.

### 2. Excel Audit

Organized the initial findings in a structured data quality audit workbook.

### 3. Python ETL & Data Cleaning

Prepared cleaned datasets by standardizing values, handling missing and invalid data, parsing dates, converting data types, and preparing MySQL-ready exports.

### 4. Python Exploratory Data Analysis

Analysed purchasing behaviour, revenue distribution, customer engagement, product performance, support patterns, and customer segments.

### 5. MySQL & SQL Analytics

Loaded the prepared datasets into the `customer_360` database, established table relationships, performed SQL analysis, and created reusable analytical views.

#### Analytical Views

- `vw_customer_360`
- `vw_customer_360_segmented`
- `vw_customer_engagement_metrics`
- `vw_customer_order_metrics`
- `vw_customer_support_metrics`
- `vw_monthly_revenue`
- `vw_product_performance`

### 6. Power BI Dashboards

Created four dashboard pages:

1. **Executive Overview** — high-level customer, order, and revenue metrics.
2. **Customer 360** — customer value, purchasing behaviour, and engagement.
3. **Product & Sales Performance** — category and product comparisons.
4. **Support & Engagement** — issue types, sentiment, resolution performance, and digital engagement.

The report uses base tables and analytical views to provide business-focused analysis.

### 7. Generative AI

Integrated the Gemini API with Python and MySQL retrieval functions.

Implemented components include:

- AI-powered Customer 360 summaries
- Customer segmentation insights
- Revenue and business insights
- Support intelligence
- Data-grounded business Q&A
- Source-data validation and API failure handling

The implementation retrieves selected metrics from approved MySQL views and uses the LLM to explain those results. The AI is not treated as the source of numerical facts.

### 8. End-to-End Pipeline & Documentation

Documenting the architecture, execution workflow, data quality decisions, validation outcomes, known limitations, and interview demonstration.

## Selected Findings & Validation

- The order dataset contains 300,000 rows.
- Total recorded revenue across all orders is 13,042,649,596.81 in the dataset's reported numeric units.
- 210,000 orders have recorded dates, while 90,000 orders lack dates.
- Revenue from dated orders is 9,100,659,243.71.
- Revenue from undated orders is 3,941,990,353.10.
- Monthly revenue therefore represents dated orders only and should not be interpreted as the complete revenue history.
- The product-performance view contains 500 products; 30 have a missing category assignment.
- Validation queries confirmed that total revenue reconciles between dated and undated orders and that product revenue matches total order revenue.
- December 2025 is a partial month in the available data, with 268 orders.

Revenue values are reported without a currency symbol because the dataset does not define a currency.

## GenAI Reliability & Data Considerations

- SQL and Python calculations provide the numerical facts.
- AI-generated statements are checked against source data where applicable.
- Missing or unavailable information is distinguished from zero.
- Prompt instructions discourage unsupported claims and causal conclusions.
- API errors are handled using a limited retry mechanism.
- API keys and database credentials must remain outside version control.
- Only the information required for an AI task should be included in the request.

These safeguards reduce risk but do not guarantee that every generated statement is correct.

## Setup & Execution

### Prerequisites

- Python and Jupyter Notebook
- MySQL Server and MySQL Workbench
- Power BI Desktop
- A Gemini API key for GenAI functionality

### Execution Workflow

1. Review the Excel data quality audit.
2. Run the Python profiling and ETL notebooks as needed to reproduce the cleaning workflow.
3. Load the prepared datasets into MySQL and execute the SQL setup and analytics scripts in the intended order.
4. Open the Power BI project and configure the data connection for the local environment.
5. Open `07_GenAI/Customer_360_GenAI.ipynb`.
6. Configure local database credentials and the Gemini API key securely.
7. Execute the notebook cells in order to retrieve metrics and generate the AI outputs.

Exact package versions, credential configuration, and database connection settings should be confirmed for the target machine before reproducing the workflow.

## Limitations

- Missing order dates reduce the completeness of monthly revenue trends.
- Some product records have missing category assignments.
- Revenue metrics do not establish profitability because cost and margin data are not available.
- Resolution-time values exist for all support tickets even though 9,000 tickets lack a recorded resolved date; this requires careful interpretation.
- AI-generated explanations and recommendations need review and should not be treated as proven causal conclusions.
- The current customer-summary demonstration uses an automatically selected sample customer; customer ID selection is a planned enhancement.

## Portfolio Objective

This project demonstrates practical skills across data quality, Python ETL and EDA, SQL analytics, Power BI dashboard development, GenAI integration, output validation, and business communication.
