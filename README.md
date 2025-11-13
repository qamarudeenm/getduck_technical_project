# dbt Project for Bidco Africa: Retail Data Analysis

This project is designed to analyze retail sales data for Bidco Africa, a leading FMCG manufacturer in East Africa. The goal is to transform raw, fragmented sales data into actionable insights for commercial and marketing teams. This README provides a detailed overview of the dbt project, including the data models, assumptions, and technical architecture.

## Table of Contents

- [Project Overview](#project-overview)
- [Tech Stack](#tech-stack)
- [Data Pipeline Architecture](#data-pipeline-architecture)
- [Model Development](#model-development)
  - [Assumptions](#assumptions)
  - [Model Structure](#model-structure)
- [Data Quality](#data-quality)
- [Promotions & Performance](#promotions--performance)
- [Pricing Index](#pricing-index)
- [How to Run the Project](#how-to-run-the-project)
- [Next Steps](#next-steps)

## Project Overview

The primary objective of this project is to help Bidco Africa understand its product performance across various stores and categories. By analyzing sales data, we can identify the impact of pricing and promotions, and compare Bidco's price positioning against competitors. The project aims to provide clear, data-driven insights to non-technical stakeholders, such as brand managers.

## Tech Stack

- **dbt:** The core of our data transformation pipeline. We use dbt to build, test, and document our data models.
- **ClickHouse:** Our column-oriented database management system, providing a scalable and performant platform for our data.
- **Python:** Used for data extraction, loading, and any advanced data analysis or machine learning tasks.
- **Airflow:** Our choice for orchestrating and scheduling data pipelines.
- **Power BI / Superset:** For creating interactive dashboards and visualizing the KPIs.

## Data Pipeline Architecture

The data pipeline is designed for scalability, with the capacity to handle data from thousands of users. The current dataset of 30,000 rows from a single user over 7 days is a representative sample of the data we expect to process at scale.

The architecture is as follows:

1. **Data Ingestion:** Raw sales data is extracted from various retailer systems (POS, ERP, etc.) and loaded into our data lake.
2. **Data Transformation:** dbt models are used to clean, transform, and aggregate the raw data into a structured format suitable for analysis.
3. **Data Serving:** The transformed data is served to our business intelligence tools for visualization and to a FastAPI for programmatic access.

## Model Development

The dbt models are structured to provide a clear and modular approach to data transformation. We follow the dbt best practices of staging, intermediate, and mart layers to ensure our data is well-organized and easy to maintain.

### Assumptions

- **Promotion Inference:** A product is considered "on promo" if its realized unit price is at least 10% below the Recommended Retail Price (RRP) for two or more days within a week. This assumption can be adjusted based on business feedback.
- **Competitor Identification:** Products in the same Sub-Department and Section are considered competitors. This allows for a granular comparison of Bidco's products with similar items.
- **Data Reliability:** We assume that the `Item_Code` is a unique identifier for each product. Any duplicates or inconsistencies are flagged and handled in our data quality checks.

### Model Structure

- **Staging Models:** These models perform initial cleaning and casting of the raw data. They are the foundation of our transformation pipeline.
- **Intermediate Models:** These models handle more complex transformations, such as identifying promotions and calculating baseline sales.
- **Mart Models:** These are the final models that produce the KPIs and data structures required for our dashboards and API.

## Data Quality

Data quality is a critical aspect of this project. We have implemented a series of tests and checks to ensure the reliability of our data. Our data quality framework includes:

- **Missing/Duplicated Records:** We identify and flag any missing or duplicated records in the raw data.
- **Outlier Detection:** We have implemented logic to detect suspicious outliers, such as negative quantities or extreme prices.
- **Data Health Score:** We have developed a simple data health score for each store and supplier, which helps us identify and prioritize data quality issues.

## Promotions & Performance

To analyze the effectiveness of promotions, we have developed a set of KPIs that measure their impact on sales and pricing. These include:

- **Promo Uplift %:** The percentage increase in sales during a promotion compared to the baseline.
- **Promo Coverage %:** The percentage of stores running a promotion for a specific product or supplier.
- **Promo Price Impact:** The depth of the discount compared to the RRP.
- **Baseline vs. Promo Avg Price:** A comparison of the average realized unit price during and outside of promotions.

## Pricing Index

The pricing index is a powerful tool for understanding Bidco's price positioning in the market. It compares the average unit price of Bidco's products with their competitors in the same Sub-Department and Section. The index is calculated at the store level and can be rolled up to provide an overall view of Bidco's pricing strategy.

## How to Run the Project

To run the dbt project, you will need to have dbt installed and configured to connect to your data warehouse. Once you have set up your environment, you can run the models using the following command:

1. Build the docker app
execute docker-compose up --build -d


check if this container is running without error
# View logs for the Python service to ensure CSV load was successful
docker-compose logs python_api

```
dbt run
```

You can also run the tests to ensure the data quality of your models:

```
dbt test
```

## Next Steps

- **Automate Data Ingestion:** We plan to automate the data ingestion process to ensure a continuous flow of data into our pipeline.
- **Enhance Data Quality Checks:** We will continue to improve our data quality framework by adding more sophisticated checks and alerts.
- **Develop More Advanced Analytics:** We plan to explore more advanced analytics, such as sales forecasting and customer segmentation, to provide deeper insights to the business.
