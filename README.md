## 🦆 Duck Retail Data Challenge: Bidco Africa Commercial Data Pipeline
# 🚀 Overview
This repository contains a modern, production-grade data pipeline designed to transform raw, fragmented retail sales data into actionable commercial insights for Bidco Africa Limited.
The solution uses a ClickHouse-backed Data Lakehouse orchestrated by dbt (Data Build Tool), with final results delivered via a simple FastAPI service for consumption by BI tools, dashboards, and the non-technical Brand Manager.

# 🛠️ Technology Stack & Architecture
Layer	Technology	Rationale (Cost-Optimization & Resilience)
Storage (Raw/Lake)	MinIO / ClickHouse (Table Data)	Leverages inexpensive object storage for the data lake, only moving optimized data into high-performance ClickHouse tables for query processing.
Transformation	dbt (Data Build Tool)	Provides version control, lineage, testing, and ensures repeatable, reliable transformations (ELT/SQL-first approach).
Data Warehouse (OLAP)	ClickHouse	Optimized for high-speed analytical queries (aggregations, window functions) required for the Pricing Index. Highly efficient on columnar data.
API / Presentation	FastAPI & Streamlit	FastAPI provides a lean, performant API endpoint for reliable data delivery. Streamlit offers rapid iteration for a user-friendly analytical dashboard.
Modeling	Star Schema (Dimensional Modeling)	Separates facts (sales events) from dimensions (products, stores, suppliers), maximizing query performance and flexibility for BI users.

# ✅ Data Quality & Governance
The pipeline implements a "Flag and Filter" strategy, ensuring immutability in the Raw Layer while guaranteeing a clean Silver/Gold Layer for reporting.
Check Implemented	Rationale & Outcome
Deduplication	Unique sales events are enforced by generating a composite key on (Store, Item, Date, Quantity, Price, etc.) and filtering for ROW_NUMBER() = 1.
Negative/Null Filter	Transactions with non-positive Quantity, Total Sales, or RRP are removed from the clean pipeline.
Extreme Outlier Removal	Transactions where Total Sales exceeded $52,000 (a commercially indefensible level for a single line-item in this FMCG dataset) were removed to prevent skewing aggregates.
rpt_data_volume_acceptance	Overall Acceptance Rate: 99.88%. The pipeline confirms the underlying raw data quality is high.
rpt_dq_supplier_reliability	Identified specific, low-volume suppliers whose data contributes most to rejection (e.g., BEECARE APIARIES).

# 💡 Commercial Insights & Actions for Bidco
The core mission is to inform the Brand Manager's decisions on Promotions and Pricing.
A. Promotions & Uplift (Informs: Marketing Budget Allocation)
KPI & Finding	Implication	Actionable Recommendation
RIBENA (FD-SBF) Achieved +44.82% Uplift	Ribena is a highly price-elastic brand. The deep discount strategy drives massive volume increases.	Maximize Campaign Scale: Prioritize Ribena for mass-market campaigns (high ROI on volume increase). Ensure inventory can support 45%+ surge.
GOLDEN FRY Achieved +23.95% Uplift	The primary product line responds well to the 15.65% average discount depth.	Optimize Bulk: Focus promotions on wholesale-relevant sizes (5L/10L) to increase total turnover during promo periods.
B. Competitive Pricing Index (Informs: Margin Protection)
The Pricing Index measures (Own Brand Price / Peer Average Price).
Bidco Brand	Price Positioning (PPI)	Finding	Actionable Recommendation
GOLD BAND (Margarine)	0.803 (20% Below Peer Avg)	Leaving Margin on the Table: The brand is significantly underselling competitors in the same competitive set.	Test Price Increase: Pilot a 5-10% price increase (moving PPI to 0.84 - 0.88). If volume holds, profit dramatically increases.
ELIANTO (Corn Oil)	1.042 (4.2% Above Peer Avg)	Perfect Positioning: Successfully commands a small premium in the Corn Oil category.	Maintain Status Quo: This strategy is balanced; no immediate pricing action is necessary.

# 💻 Presentation & API (Delivery)
Streamlit Dashboard (Visualization Focus)
The Streamlit app visualizes the final mart tables:
KPI Card: Shows the 99.88% Data Acceptance Rate (builds trust).
Uplift Bar Chart: Ranks Bidco brands by Promo Uplift % (quickly spotlights the Ribena success story).
Pricing Histogram: Shows the distribution of Bidco SKUs across PREMIUM, NEAR MARKET, and DISCOUNT bands (confirms Gold Band is in the deep discount zone).
FastAPI (Production Endpoint)

A simple, fast API exposes the clean data marts:
Endpoint	Data Mart
/data-health/overall	rpt_data_volume_acceptance
/promotions/uplift	rpt_promo_performance
/pricing-index/positioning	rpt_pricing_index_detail
This stack provides the agility required to meet commercial demands (fast dashboard) while maintaining the integrity required for enterprise-level data operations.