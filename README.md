# AI-Powered Customer 360 & Revenue Operations Pipeline

An end-to-end data analytics project that transforms customer, order, product, support, and clickstream data into business insights, interactive Power BI dashboards, and AI-generated explanations.

## Project Overview

The project combines data quality auditing, Python ETL, exploratory data analysis, relational SQL analytics, Power BI reporting, and Generative AI.

The objective is to create a unified Customer 360 analytical layer that helps explain customer purchasing behaviour, engagement, revenue performance, product trends, customer segments, churn, and support interactions.

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

**Note:** The two clickstream files in `CheckPoints/` and `Cleaned_CSV/` are zipped because the original CSVs exceed GitHub's 100 MB file limit. Unzip them before use. The raw clickstream file is not included; use the 1,000-row sample in `01_Raw_Data/sample/` or download the full file from Kaggle.

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
│   ├── 01_customer_360_powerBI.pbix
│   └── dashboard screenshots
├── 07_GenAI/
│   └── Customer_360_GenAI.ipynb
```

## Project Phases

### 1. Data Profiling & Quality Audit

Audited the datasets for missing values, duplicate records, invalid values, inconsistent categories, mixed date formats, and relationship issues.

### 2. Excel Audit

Organized the initial findings in a structured data quality audit workbook.

### 3. Python ETL & Data Cleaning

Prepared cleaned datasets by standardizing values, handling missing and invalid data, parsing dates, converting data types, and preparing MySQL-ready exports.

### 4. Python Exploratory Data Analysis

Analysed purchasing behaviour, revenue distribution, customer engagement, product performance, support patterns, and customer segments.

### 5. MySQL & SQL Analytics

Loaded the prepared datasets into the `customer_360` database, established table relationships, performed SQL analysis, and created reusable analytical views.

**Revenue definition.** All revenue views count only orders with status `success`. Failed orders are excluded because no payment was received, and refunded orders are excluded from net revenue because the money was returned.

#### Analytical Views

- `vw_customer_360`
- `vw_customer_360_segmented`
- `vw_customer_engagement_metrics`
- `vw_customer_order_metrics` (revenue, quantity, and average order value use successful orders)
- `vw_customer_support_metrics`
- `vw_monthly_revenue` (successful orders with a valid date)
- `vw_product_performance` (successful orders)
- `vw_customer_rfm_base` (recency, frequency, monetary per customer)
- `vw_customer_rfm_scores` (1 to 5 scores)
- `vw_customer_rfm_segments` (named RFM segments)

#### Summary Tables

- `retention_summary` (share of customers who buy again within 90, 180, and 365 days)
- `order_date_quality` (breakdown of valid and invalid order dates)

These two tables hold results calculated by the analysis queries and are not refreshed automatically.

#### RFM Method

- **Recency:** days since the last successful purchase, scored 1 to 5 with equal-sized groups (5 is the most recent).
- **Frequency:** number of successful orders, scored with fixed cut-offs (1, 2, 3, 4, and 5 or more orders), because many customers share the same order count.
- **Monetary:** total net spend, scored 1 to 5 with equal-sized groups.
- Customers whose successful orders have no usable date get no recency score and are placed in a separate **No Date Data** segment.

#### Churn Definition

Customers typically wait 3 to 6 months between purchases (70% of gaps between successful orders are 180 days or shorter), so a 90-day rule would label normal customers as lost. Churn is therefore defined as **no purchase in 181+ days**. Customers at 91 to 180 days are treated as at risk.

### 6. Power BI Dashboards

Created five dashboard pages:

1. **Executive Overview** — customers, orders, net revenue, gross revenue, average order value, support tickets, monthly trend, and revenue by category and payment method.
2. **Customer 360** — customer value, purchasing behaviour, and engagement.
3. **Product & Sales Performance** — category and product comparisons using net revenue and successful quantity.
4. **Support & Engagement** — issue types, sentiment, resolution performance, and digital engagement.
5. **RFM Segments** — customers and revenue by RFM segment, churn status, win-back opportunity, and retention.

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

### Revenue

- The order dataset contains 300,000 rows: 221,280 successful (73.76%), 42,827 refunded (14.28%), and 35,893 failed (11.96%).
- Revenue by status: successful 9,610,792,846.73; refunded 1,850,208,574.19; failed 1,581,648,175.89. Together these equal the 13,042,649,596.81 recorded across all orders.
- **Net revenue** (successful orders only) is 9.61bn. **Gross revenue** (successful plus refunded orders) is 11.46bn. Net revenue assumes refunds equal the full order amount.
- Average order value on successful orders is about 43.4K, and 519,942 units were sold on successful orders.
- 39% of customers (18,394 of 47,180) generate 80% of net revenue, so revenue is spread widely and does not depend on a few customers.

### Customer Segments

| Segment | Share of customers | Share of net revenue |
|---|---|---|
| Champions | 27.6% | 38.9% |
| Loyal | 22.4% | 23.7% |
| Can't Lose Them | 16.5% | 20.6% |
| At Risk | 9.4% | 6.7% |
| Lost | 12.3% | 4.9% |
| No Date Data | 4.8% | 2.1% |
| New / Recent | 4.2% | 1.9% |
| Need Attention | 3.0% | 1.3% |

- Champions and Loyal customers are about 50% of customers and 63% of net revenue.
- Can't Lose Them customers (frequent buyers who have gone quiet) are 16.5% of customers and 20.6% of revenue, which makes them the main win-back opportunity.

### Churn and Retention

- 46.7% of customers with a valid purchase date have not bought in 181+ days.
- Among 38,137 customers whose first dated purchase is at least a year old, 32.8% bought again within 90 days, 54.7% within 180 days, and 79.6% within 365 days. About 1 in 5 first-time buyers does not return within a year.

### Data Quality and Validation

- 90,000 of the 300,000 orders (30%) lack a usable order date: 17,914 are empty in the raw data, 54,112 hold a repeated placeholder value in three different date formats, and 17,974 are valid timestamps (format `YYYY-MM-DDTHH:MM:SS.ffffff`) that the ETL converted to blank. The last group could be recovered by adding that format to the date parser.
- Successful orders without a date account for about 2.89bn of the 9.61bn net revenue, so the monthly trend covers about 6.72bn of it.
- 2,243 customers have no usable date on any successful order, so their recency cannot be calculated.
- Net revenue of 9.61bn reconciles across the Executive Overview, the Product & Sales Performance page, and the RFM base.
- The product-performance view contains 500 products; 30 have a missing category assignment.
- December 2025 is a partial month in the available data, with 201 successful orders.

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

## ⚠️ Data Note

The source datasets are synthetic (Kaggle practice data), so several fields such as sentiment, issue type, and acquisition source are almost evenly distributed. The focus of this project is the end-to-end pipeline: auditing, cleaning, modeling, SQL analysis, dashboarding, and GenAI. With real business data, these categories would normally show clear differences.

## Setup & Execution

### Prerequisites

- Microsoft Excel
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

- About 30% of order dates are missing or invalid, so monthly revenue, recency, RFM, churn, and retention cover only orders with a usable date. Revenue totals use all successful orders.
- Retention uses each customer's first dated purchase, which may not be their true first purchase, so true return rates could be slightly higher.
- The 181-day churn threshold comes from observed purchase gaps and is a business assumption, not a fact in the data.
- The retention and order-date-quality charts are overall figures and do not respond to the dashboard filters.
- Some product records have missing category assignments.
- Revenue metrics do not establish profitability because cost and margin data are not available.
- Resolution-time values exist for all support tickets even though 9,000 tickets lack a recorded resolved date; this requires careful interpretation.
- AI-generated explanations and recommendations need review and should not be treated as proven causal conclusions.
- The current customer-summary demonstration uses an automatically selected sample customer; customer ID selection is a planned enhancement.

## Portfolio Objective

This project demonstrates practical skills across data quality, Python ETL and EDA, SQL analytics, Power BI dashboard development, customer segmentation and retention analysis, GenAI integration, output validation, and business communication.