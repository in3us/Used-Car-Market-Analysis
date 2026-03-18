# Used Car Market Analysis
 
An end-to-end data analysis project combining SQL and Tableau to identify pricing drivers and market opportunities in a used car dataset of 7,253 listings across 11 Indian cities.
 
## Dashboard
 
[View Interactive Tableau Dashboard](https://public.tableau.com/app/profile/steven.myette/viz/UsedCarMarketAnalysis_17738569388000/UsedCarMarketAnalysis)
 
## Project Overview
 
This project answers a core business question: **what drives used car prices, and how can that insight support smarter acquisition and pricing decisions?**
 
Using SQL for structured analysis and Tableau for visualization, the project examines how brand, vehicle age, mileage, transmission type, and ownership history each affect market price.
 
## Key Findings
 
- **Transmission is the single biggest price driver** — automatic vehicles average 19.84 lakh vs 5.33 lakh for manual, nearly a 4x difference
- **Ownership history matters significantly** — first owner cars average 9.96 lakh vs 3.28 lakh for fourth+ owners
- **Depreciation is steep and predictable** — average price drops from 19.46 lakh at 6 years old to 2.03 lakh at 20 years
- **Low mileage commands a clear premium** — cars with under 20K km average 13.59 lakh vs 6.17 lakh for 150K+ km
- **Diesel vehicles command more than double petrol prices** on average (12.84 vs 5.70 lakh)
 
## Repository Contents
 
| File | Description |
|------|-------------|
| `used_car_analysis.sql` | 10 SQL queries across 5 analytical sections |
| `used_cars.csv` | Source dataset — 7,253 listings across 11 cities |
 
## SQL Analysis Structure
 
**Section 1 — Market Overview**
High-level summary of the dataset including listings by city and fuel type distribution.
 
**Section 2 — Brand Analysis**
Average price by brand and identification of budget-friendly brands by listing volume.
 
**Section 3 — Depreciation & Value Retention**
Price trends by vehicle age, transmission type, and ownership history.
 
**Section 4 — Mileage & Usage Analysis**
Price segmentation by kilometers driven and fuel efficiency tiers.
 
**Section 5 — Pricing Opportunity Analysis**
Identification of potentially underpriced listings relative to brand and fuel type averages, and a price-per-kilometer value efficiency metric.
 
## Tools Used
 
- **SQL** (SQLite) — data extraction, aggregation, and business logic
- **Tableau Public** — interactive dashboard and data visualization
- **Python / pandas** — data exploration and validation
 
## How to Run the SQL
 
1. Download DB Browser for SQLite at sqlitebrowser.org
2. Import `used_cars.csv` as a new table named `used_cars`
3. Open `used_car_analysis.sql` in the Execute SQL tab
4. Run queries individually by highlighting and executing each section
 
## Author
 
Steve Myette
[LinkedIn](https://www.linkedin.com/in/stevenmyette-7119191b/) | [GitHub](https://github.com/in3us)
 
