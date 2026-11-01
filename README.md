# Supply-Chain-Dataset-Analysis

## Project Name
Supply-Chain-Dataset-Analysis

## Project Description
Supply chain analytics on real Olist e-commerce data: relational database, data cleaning, delivery and sales analysis, demand and late-delivery forecasting, with Tableau and Power BI dashboards.

## Project Idea
An end-to-end data analytics project on real e-commerce data from Olist (Brazil). We build a relational database, clean and preprocess the data, analyze sales and delivery performance, forecast demand and late deliveries with machine learning, and present the results in interactive dashboards built with Tableau and Power BI.

**Dataset:** Brazilian E-Commerce Public Dataset by Olist.
We used a month-stratified random sample of 8,002 orders (purchase dates 2017-01 to 2018-08, random seed 42) taken from 99,092 orders in that period, with all related rows from 8 tables (orders, order items, payments, reviews, customers, products, sellers, category translation).

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
| Week | Phase | Main tasks | Deliverables |
|---|---|---|---|
| 1 | Data model, cleaning and preprocessing | Build the database and data model, clean and preprocess the data (SQL, Python) | Cleaned dataset, preprocessing notebook |
| 2 | Analysis questions | Define the analysis questions that decision makers care about and answer them with SQL and Python | Set of analysis questions and answers |
| 3 | Forecasting | Define forecasting questions and answer them using trends in the data (scikit-learn) | Forecasting plots and models |
| 4 | Dashboards and final presentation | Build the Tableau and Power BI dashboards (each covering a different part), prepare the final report and presentation | Dashboards, final report, presentation |

## Roles & Responsibilities
- **Data Model & Database:** design the schema, keys and relationships, load the data into PostgreSQL, document the database.
- **Data Cleaning:** profile the data, fix missing values, duplicates, inconsistencies and invalid records, keep a cleaning log.
- **EDA:** explore distributions, outliers, seasonality and delivery delays; produce descriptive statistics and charts.
- **Analysis Questions & SQL:** define the business questions and answer them with SQL queries.
- **Forecasting / Machine Learning:** forecast order volume over time and predict late deliveries; evaluate the models.
- **Dashboards (Tableau and Power BI):** visualize the answers; Tableau covers sales, customers and products, Power BI covers logistics and sellers.

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
- Forecast accuracy on a holdout period (MAPE / RMSE)
- Late-delivery model performance (recall and F1-score)
- Number of analysis questions answered and visualized

## Instructor
Eng/ Islam Atef

## Project Files
**Google Drive (all project files):** [Open the project folder](https://drive.google.com/drive/folders/11TAnH4fV8Wn_y9cJhACtkIaLolthd0aL?usp=sharing)
