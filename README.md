# 🦆 Duck Retail Data Challenge: Bidco Africa Commercial Data Pipeline

## 🚀 Overview
This repository contains a modern, production-grade data pipeline designed to transform raw, fragmented retail sales data into actionable commercial insights for Bidco Africa Limited.

The solution uses a ClickHouse-backed Data Lakehouse orchestrated by dbt (Data Build Tool), with final results delivered via a simple FastAPI service for consumption by BI tools, dashboards, and other applications.

## 💻 How to Run

### Prerequisites
- Docker and Docker Compose

### Instructions
1.  **Initial Build & Start Services:**
    ```bash
    docker-compose up --build -d
    ```
2.  **Run dbt Transformations:**
    ```bash
    docker-compose exec dbt_cli dbt run --target dev
    ```
3.  **Access the API:**
    The API documentation is available at [http://localhost:2026/docs](http://localhost:2026/docs).

### Services
- `clickhouse`: ClickHouse database, accessible on the host at port `2025`.
- `python_api`: The FastAPI application, accessible on the host at port `2026`.
- `dbt_cli`: A container for running dbt commands against the data warehouse.

## 🛠️ Data Pipeline Architecture
The pipeline follows an ELT (Extract, Load, Transform) approach:

1.  **Extract & Load**: Raw CSV data is loaded into a ClickHouse database, which acts as the storage layer for our Data Lakehouse.
2.  **Transform**: `dbt` runs a series of version-controlled SQL models to clean, transform, and aggregate the raw data. This process creates structured data marts, including:
    - **Lake**: Cleaned, standardized base tables.
    - **Curated**: Dimension and fact tables based on a Star Schema model.
    - **Reports**: Final aggregated tables that power the API endpoints.
3.  **Serve**: A FastAPI application queries the final report tables in ClickHouse and exposes the data through a REST API.

### Technology Stack
| Layer | Technology | Rationale (Cost-Optimization & Resilience) |
| :--- | :--- | :--- |
| **Storage (Raw/Lake)** | ClickHouse (Table Data) | Leverages inexpensive object storage for the data lake, only moving optimized data into high-performance ClickHouse tables for query processing. |
| **Transformation** | dbt (Data Build Tool) | Provides version control, lineage, testing, and ensures repeatable, reliable transformations (ELT/SQL-first approach). |
| **Data Warehouse (OLAP)**| ClickHouse | Optimized for high-speed analytical queries (aggregations, window functions) required for the Pricing Index. Highly efficient on columnar data. |
| **API / Presentation** | FastAPI | FastAPI provides a lean, performant API endpoint for reliable data delivery. |
| **Modeling** | Star Schema | Separates facts (sales events) from dimensions (products, stores, suppliers), maximizing query performance and flexibility 
for BI users. |

### Data Pipeline Architecture Diagram
![Data Pipeline Architecture](assets/getduct_project.jpg)


## ✅ Data Quality & Governance
The pipeline implements a "Flag and Filter" strategy, ensuring immutability in the Raw Layer while guaranteeing a clean Silver/Gold Layer for reporting.

| Check Implemented | Rationale & Outcome |
| :--- | :--- |
| **Deduplication** | Unique sales events are enforced by generating a composite key on (Store, Item, Date, Quantity, Price, etc.) and filtering for `ROW_NUMBER() = 1`. |
| **Negative/Null Filter** | Transactions with non-positive `Quantity`, `Total Sales`, or `RRP` are removed from the clean pipeline. |
| **Extreme Outlier Removal** | Transactions where `Total Sales` exceeded $52,000 (a commercially indefensible level for a single line-item in this FMCG dataset) were removed to prevent skewing aggregates. |
| **`rpt_data_volume_acceptance`** | **Overall Acceptance Rate: 99.88%**. The pipeline confirms the underlying raw data quality is high. |
| **`rpt_dq_supplier_reliability`** | Identified specific, low-volume suppliers whose data contributes most to rejection (e.g., BEECARE APIARIES). |


## 💡 Commercial Insights & Actions for Bidco
The core mission is to inform the Brand Manager's decisions on Promotions and Pricing.

#### A. Promotions & Uplift (Informs: Marketing Budget Allocation)
| KPI & Finding | Implication | Actionable Recommendation |
| :--- | :--- | :--- |
| **RIBENA (FD-SBF) Achieved +44.82% Uplift** | Ribena is a highly price-elastic brand. The deep discount strategy drives massive volume increases. | **Maximize Campaign Scale**: Prioritize Ribena for mass-market campaigns (high ROI on volume increase). Ensure inventory can support 45%+ surge. |
| **GOLDEN FRY Achieved +23.95% Uplift** | The primary product line responds well to the 15.65% average discount depth. | **Optimize Bulk**: Focus promotions on wholesale-relevant sizes (5L/10L) to increase total turnover during promo periods. |

#### B. Competitive Pricing Index (Informs: Margin Protection)
The Pricing Index measures `(Own Brand Price / Peer Average Price)`.

| Bidco Brand | Price Positioning (PPI) | Finding | Actionable Recommendation |
| :--- | :--- | :--- | :--- |
| **GOLD BAND (Margarine)** | 0.803 (20% Below Peer Avg) | **Leaving Margin on the Table**: The brand is significantly underselling competitors in the same competitive set. | **Test Price Increase**: Pilot a 5-10% price increase (moving PPI to 0.84 - 0.88). If volume holds, profit dramatically increases. |
| **ELIANTO (Corn Oil)** | 1.042 (4.2% Above Peer Avg) | **Perfect Positioning**: Successfully commands a small premium in the Corn Oil category. | **Maintain Status Quo**: This strategy is balanced; no immediate pricing action is necessary. |


## 📦 API Endpoints & Presentation

A simple, fast API exposes the clean data marts for production use.

| Endpoint | Data Mart | Description |
| :--- | :--- | :--- |
| `/data-health/overall` | `rpt_data_volume_acceptance` | Returns the overall data acceptance rate and rejection details. |
| `/promotions/uplift` | `rpt_promo_performance` | Returns data for the Promo Uplift Ranking chart (Top 10). |
| `/pricing-index/positioning`| `rpt_pricing_index_detail` | Returns data for the Pricing Index (Bidco only). |
| `/supplier/reliability` |  `rpt_dq_supplier_reliability and rejected_data_process` | Provide a detailed breakdown of data quality issues per supplier
This stack provides the agility required to meet commercial demands while maintaining the integrity required for enterprise-level data operations.
