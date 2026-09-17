# E-Commerce Customer Analytics: RFM Segmentation & Retention Analysis

## Overview
An end-to-end analytics project on ~99,000 e-commerce orders, built to answer two core business questions: **which customers actually drive revenue**, and **does the business retain customers after their first purchase**. The analysis combines RFM (Recency, Frequency, Monetary) segmentation with cohort-based retention analysis to surface findings that standard sales reporting misses.

## Dataset
Brazilian E-Commerce Public Dataset by Olist (Kaggle) — real, anonymized transactional data covering ~99,441 orders, order items, payments, and customer records.

## Tools Used
- **PostgreSQL** — schema design, data cleaning, RFM scoring, cohort analysis
- **Power BI** — interactive dashboard visualization
- **SQL** — CTEs, window functions (`NTILE`), date-based cohort logic

## Approach
1. **Schema design & ingestion** — built normalized tables for customers, orders, order items, and payments; imported ~99K+ rows per table.
2. **RFM base metrics** — calculated per-customer Recency (days since last order), Frequency (distinct delivered orders), and Monetary value (total spend including freight) using CTEs.
3. **RFM scoring** — used `NTILE(5)` window functions to split customers into quintiles on each dimension, then combined R/F/M scores into five actionable segments: Champions, At Risk (High Value), Regular, New Customers, and Lost.
4. **Cohort retention analysis** — grouped customers by the month of their first purchase, then tracked what percentage of each cohort placed a repeat order in each subsequent month, collapsing all cohorts into a single retention curve.
5. **Dashboard** — built Power BI visuals translating both analyses into decision-ready charts.

## Key Findings

### RFM Segmentation & Revenue Concentration
| Segment | Customers | Avg Spend | Total Revenue | % of Total Revenue |
|---|---|---|---|---|
| Regular | 34,691 | $137.93 | $4.78M | 31.03% |
| Champions | 14,867 | $309.05 | $4.59M | 29.80% |
| At Risk (High Value) | 14,030 | **$313.01** | $4.39M | 28.48% |
| Lost | 15,392 | $55.87 | $0.86M | 5.58% |
| New Customers | 14,378 | $54.84 | $0.79M | 5.11% |

**Standout finding:** the "At Risk (High Value)" segment — customers who previously spent heavily but haven't ordered recently — has a *higher* average spend ($313.01) than even the "Champions" segment ($309.05), and contributes nearly as much total revenue (28.48% vs. 29.80%). Combined, these two segments represent **58.28% of total revenue** concentrated in just ~29,000 customers (roughly 21% of the customer base). Standard "recent activity" reporting would miss the At Risk group entirely, since by definition they look inactive — but they represent one of the largest revenue-at-risk pools in the business.

### Cohort Retention Analysis
| Months Since First Purchase | Retention Rate |
|---|---|
| 0 | 100.00% |
| 1 | 0.48% |
| 2 | 0.34% |
| 3 | 0.26% |
| 4 | 0.26% |
| 5 | 0.23% |
| 6 | 0.23% |

**Standout finding:** retention collapses almost immediately — from 100% at the point of first purchase to just 0.48% within one month, and continues declining to 0.23% by month 6. Of an initial cohort base of 93,358 first-time customers, fewer than 150 were still active by month 5. This indicates the business's growth is driven almost entirely by new customer acquisition rather than repeat purchases, which is a structural risk rather than a normal seasonal dip.

## Business Recommendations
- **Prioritize win-back campaigns for "At Risk (High Value)" customers** — this group represents the single largest recoverable revenue pool in the business. Losing them would mean losing nearly a third of total revenue.
- **Investigate the near-total lack of repeat purchases** — with retention below 1% after month one, the business should examine post-purchase experience, delivery satisfaction, and whether a loyalty or re-engagement program could meaningfully shift this curve.
- **Reframe growth strategy around retention, not just acquisition** — given how few customers return, marketing spend focused purely on new customer acquisition may be reaching a ceiling of diminishing returns without addressing the underlying retention problem.

## Dashboard
Built a dedicated "RFM & Retention Insights" page in Power BI, visualizing total revenue by customer segment and the customer retention curve by month since first purchase, alongside supporting insight callouts.

### Sales Overview
<img width="1170" height="813" alt="E Commerce sales " src="https://github.com/user-attachments/assets/afdc3ab9-8144-43a8-b837-3248ee37c969" />
### Product Performance
<img width="1181" height="802" alt="product performance" src="https://github.com/user-attachments/assets/9139c49e-143f-4ceb-bb62-0e6c4bb6864c" />

### Customer Analytics
<img width="1165" height="802" alt="customer analytics" src="https://github.com/user-attachments/assets/ed84a9c7-a576-405a-b7bc-fa33f4fe4773" />

### RFM & Retention Insights
<img width="1167" height="652" alt="RFM and Retention Insights" src="https://github.com/user-attachments/assets/0eafa87b-b2b2-408b-bda6-e45dd1d9c202" />





## How to Reproduce
1. Set up a PostgreSQL database and run `sql/create_tables.sql` to build the schema
2. Import the Olist CSV files (customers, orders, order_items, order_payments) into their respective tables
3. Run `sql/rfm_analysis.sql` to build the RFM segments
4. Run `sql/cohort_analysis.sql` to build the retention curve
5. Open the `.pbix` file in Power BI Desktop to explore the dashboard
