# Supply-Chain-Dataset-Analysis

An end-to-end data analytics and machine learning project on real Brazilian e-commerce data from **Olist**. We design a relational database in PostgreSQL, clean and preprocess the data, analyze sales and delivery performance through EDA and SQL business queries, forecast demand and late deliveries with machine learning, and present the findings in interactive dashboards built with Tableau and Power BI.

## Dataset
- **Source:** Brazilian E-Commerce Public Dataset by Olist.
- **Sample Scope:** A month-stratified random sample of **8,002 orders** (purchase dates from `2017-01-05` to `2018-08-29`, random seed `42`) drawn from 99,092 orders in that period, including all related rows across **8 relational tables**: `Orders`, `Order_Items`, `Payments`, `Reviews`, `Customers`, `Products`, `Sellers`, and `Translation`.

## Tech Stack
- **Database & SQL:** PostgreSQL, pgAdmin, Draw.io
- **Python & Machine Learning:** Pandas, NumPy, Matplotlib, Seaborn, Scikit-learn, Statsmodels
- **Visualization & BI:** Tableau, Power BI *(In Progress)*

## Repository Structure
```text
Supply-Chain-Dataset-Analysis/
├── 1- Data Model & Database/
│   ├── Raw Data/                                      # Original 8 CSV tables
│   ├── Clean Data/                                    # Cleaned 8 CSV tables
│   ├── ERD_diagram.drawio.png                         # Entity-Relationship Diagram
│   ├── olist_code.sql                                 # PostgreSQL schemas (raw & clean), constraints, indexes & COPY scripts
│   ├── Olist_Database_Architecture_Documentation.docx # Full database architecture & data dictionary (Arabic)
│   └── README.md                                      # Database setup & troubleshooting guide
│
├── 2- Data Cleaning/
│   ├── Final_Project_Data_Cleaning.ipynb              # Profiling, missing value handling, validation & IQR outlier flagging
│   └── olist_Cleaned_Dataset.xlsx                     # Consolidated 8-sheet cleaned workbook
│
├── 3- EDA/
│   ├── EDA.ipynb                                      # Key integrity checks, descriptive statistics, sales, reviews & delay EDA
│   └── olist_Cleaned_Dataset.xlsx                     # Cleaned dataset used for exploratory analysis
│
├── 4- Analysis Questions & SQL/
│   ├── oliset queries.sql                             # 13 PostgreSQL analytical queries (CTEs, window functions, aggregations)
│   ├── Olist Explain.docx                             # Methodology & SQL concepts overview
│   ├── Insights & Recommendationdocx.docx             # Business questions, findings, recommendations & data limitations
│   └── *.csv (11 files)                               # Exported SQL query result tables
│
├── 5- Forecasting & ML/
│   ├── Forecasting.ipynb                              # Weekly demand/revenue forecasting, state forecasts, delay classification & regression
│   ├── weekly_series.csv                              # 85 complete weekly order & revenue series (with Black Friday flag)
│   ├── forecast_orders_revenue.csv                    # 8-week ahead orders & revenue forecasts with 80% prediction intervals
│   ├── forecast_states.csv                            # 8-week ahead order forecasts for SP, RJ, and MG
│   ├── late_and_delivery_time_predictions.csv         # Test-set predictions (1,549 orders) with late probabilities & top-10% risk flags
│   ├── metrics_late_delivery.csv                      # Classification evaluation metrics (ROC-AUC, PR-AUC, Precision, Recall, F1)
│   ├── metrics_delivery_time.csv                      # Regression comparison across baselines, Ridge, and Gradient Boosting
│   └── *.png (4 charts)                               # Weekly series, demand forecast, state forecast & delivery error plots
│
└── 6- Dashboards & Presentation/                      # Tableau & Power BI dashboards, final report & slides (Coming Soon)
```

## Key Findings & Model Results

### 1. Business & Logistics Insights
- **Orders & Revenue:** Out of **8,002** total orders (**96.8%** delivered), merchandise sales reached **R$ 1,068,867.13**, total freight reached **R$ 176,081.01**, and total payments reached **R$ 1,262,207.08** (Average Order Value: **R$ 134.80**).
- **Payment Methods:** **Credit Card** dominates with **79.14%** of total payment value.
- **Top Categories & Markets:** **Watches & Gifts** is the top-selling category (**R$ 105,564.80**), followed by **Health & Beauty**. **São Paulo (SP)** leads all states with **42.1%** of orders (**3,369** orders) and **37.8%** of merchandise sales, followed by **Rio de Janeiro (RJ)** and **Minas Gerais (MG)** (together accounting for **65.9%** of valid orders).
- **Delivery Performance & Customer Satisfaction:** Across **7,745** eligible delivered orders, the overall late-delivery rate is **8.64%** (**669** late orders) with a median delivery duration of **10.21 days**. Late deliveries drop the average customer review score from **4.30** (on-time/early) to **2.66** (late), with **51.1%** of late orders receiving ratings of 2 stars or below compared to **8.9%** for on-time orders.
- **Seller Dispatch Compliance:** **8.97%** of order items were handed over to carriers after the seller's shipping deadline.
- **Customer Retention:** Out of **7,979** unique customers, only **23** placed repeat orders (generating **46** orders with a higher AOV of **R$ 162.61** vs. **R$ 134.64** for one-time buyers).

### 2. Forecasting & Machine Learning Performance
- **Weekly Orders & Revenue Forecast (8-Week Horizon):** Evaluated via a 38-origin rolling backtest, a 12-week rolling average outperformed linear trend and exponential smoothing models, forecasting **122.8 orders/week** (80% interval: `78.9 – 154.9`, backtest MAPE: **19.2%**) and **R$ 16,409.1/week** (80% interval: `10,898.4 – 20,752.4`, backtest MAPE: **22.4%**).
- **Top-3 State Forecasts:** Forecasts **58.7 orders/week** in **SP** (WAPE: **19.2%**), **13.2** in **RJ** (WAPE: **27.5%**), and **12.9** in **MG** (WAPE: **29.2%**).
- **Late-Delivery Risk Classification (Purchase-Time Features):** Class-balanced Logistic Regression achieved **ROC-AUC = 0.713** and **PR-AUC = 0.108** (vs. `0.056` baseline rate), capturing **82.8%** of late orders at threshold `0.5` and achieving **1.8x lift** in the top 10% highest-risk orders.
- **Delivery Time Prediction (Regression):** Gradient Boosting trained with MAE loss achieved **MAE = 3.80 days** and **RMSE = 5.88 days** (median absolute error: **2.74 days**, with **72.9%** of predictions within 5 days), outperforming all baselines (`5.12` and `4.47` days MAE).

## Team Members
| Name | Role |
|---|---|
| Omar Gad Salama Gad | Data Model & Database |
| Abdelrahman Essam Eldin Zakaria | Data Cleaning |
| Zeiad Mohamed Ahmed Talaat | Exploratory Data Analysis (EDA) |
| Laila Mohamed Ahmed Abdallah | Analysis Questions & SQL |
| Mostafa Hassan Mostafa El-Sonbaty | Forecasting / Machine Learning |
| Ali Salah Ali Elbohoty | Dashboard with Tableau & Power BI |

## Work Plan
| Week | Phase | Main Tasks | Deliverables |
|---|---|---|---|
| 1 | Data model, cleaning and preprocessing | Build the database and data model, clean and preprocess the data (SQL, Python) | Cleaned dataset, preprocessing notebook |
| 2 | Analysis questions | Define the analysis questions that decision makers care about and answer them with SQL and Python | Set of analysis questions and answers |
| 3 | Forecasting | Define forecasting questions and answer them using trends in the data (scikit-learn) | Forecasting plots and models |
| 4 | Dashboards and final presentation | Build the Tableau and Power BI dashboards (each covering a different part), prepare the final report and presentation | Dashboards, final report, presentation |

## Roles & Responsibilities
- **Data Model & Database:** Design the schema, keys and relationships, load the data into PostgreSQL, and document the database.
- **Data Cleaning:** Profile the data, fix missing values, duplicates, inconsistencies and invalid records, and keep a cleaning log.
- **EDA:** Explore distributions, outliers, seasonality and delivery delays; produce descriptive statistics and charts.
- **Analysis Questions & SQL:** Define the business questions and answer them with SQL queries.
- **Forecasting / Machine Learning:** Forecast order volume and revenue over time, predict late deliveries and delivery duration, and evaluate the models.
- **Dashboards (Tableau and Power BI):** Visualize the answers; Tableau covers sales, customers and products, while Power BI covers logistics and sellers.

## KPIs
**Business KPIs**
- On-time delivery rate (orders delivered on or before the estimated date)
- Average delivery time (days from purchase to delivery)
- Late delivery rate
- Total revenue and average order value
- Average review score
- Freight cost as a share of order value

**Project KPIs**
- Share of identified data quality issues resolved and documented
- Forecast accuracy on a holdout period (MAPE / WAPE / RMSE)
- Late-delivery model performance (ROC-AUC, PR-AUC, recall and F1-score)
- Number of analysis questions answered and visualized

## How to Reproduce
1. **PostgreSQL Database Setup:**
   - Create a database in pgAdmin (e.g., `olist`).
   - Place `Raw Data` and `Clean Data` folders in `C:/Database/raw` and `C:/Database/clean` (or update the paths in `1- Data Model & Database/olist_code.sql`).
   - Execute `1- Data Model & Database/olist_code.sql` (see `1- Data Model & Database/README.md` for full setup instructions).
2. **Python Analysis & ML Notebooks:**
   - Install dependencies: `pip install pandas numpy matplotlib seaborn scikit-learn statsmodels openpyxl`
   - Run `2- Data Cleaning/Final_Project_Data_Cleaning.ipynb`, `3- EDA/EDA.ipynb`, and `5- Forecasting & ML/Forecasting.ipynb` (each notebook reads `olist_Cleaned_Dataset.xlsx`).
3. **SQL Business Queries:**
   - Run the queries in `4- Analysis Questions & SQL/oliset queries.sql` against the `clean` schema in PostgreSQL.

## Instructor
**Eng/ Islam Atef** — Digital Egypt Pioneers Initiative (DEPI), Professional Data Analyst Track

## Project Files
**Google Drive (all project files):** [Open the project folder](https://drive.google.com/drive/folders/11TAnH4fV8Wn_y9cJhACtkIaLolthd0aL?usp=sharing)