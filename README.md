# Customer_Churn_Intelligence_Platform
Customer Churn Analysis & Prediction System
🔹 Project Overview

This project presents an end-to-end data-driven solution for analyzing customer behavior and predicting churn. It combines SQL-based feature engineering, machine learning models, and interactive dashboards to identify at-risk customers and enable data-driven retention strategies.

The system not only predicts churn but also segments customers into meaningful groups to support targeted business decisions.

🔹 Objectives
Identify customers likely to churn
Understand behavioral patterns driving churn
Segment customers based on purchasing behavior
Provide actionable insights for retention strategies

🔹 Tech Stack
Data Processing & Storage - SQL Server (CTEs, data transformation, feature engineering)
Data Analysis & Machine Learning - Python (Pandas, NumPy, Scikit-learn, XGBoost)
Visualization - Power BI (Business intelligence dashboard)
Streamlit (Interactive analytical interface)
Model Persistence
Joblib (Saving trained models and preprocessing pipelines)

🔹 Dataset
Microsoft AdventureWorks 2019 OLTP database used for feature engineering and to make the dataset consists of 19119 customers with 14 different attributes

The dataset consists of customer transaction and purchase history, including:

Order details
Revenue
Product categories
Customer activity timelines
🔹 Feature Engineering

A total of 14 customer-level features were created using SQL:

TotalRevenue
OrderFrequency
AvgOrderValue
DaysSinceLastOrder
CustomerTenure
TotalProductSubCategories
MostPurchasedCategory
AvgDaysBetweenOrders
RecencyRatio
OneTimeBuyer
ChurnLabel
(and supporting temporal features)

Key techniques:

Multiple CTEs for modular transformations
Window functions (LAG, ROW_NUMBER)
Time-based calculations (recency, tenure, gaps)

🔹 Exploratory Data Analysis (EDA)
Checked class balance (churn vs non-churn)
Handled missing values and outliers
Analyzed distribution (skewness, kurtosis)
Applied log transformation on skewed features
Encoded categorical variables
Removed highly correlated features to avoid multicollinearity

🔹 Machine Learning Models
1. K-Means Clustering (Customer Segmentation)

Customers were segmented into 5 groups:

Dormant Customers
Loyal Customers
At Risk High Spenders
Frequent Low Spenders
High Value Customers

👉 Helps in understanding behavioral personas

2. XGBoost Classifier (Churn Prediction)
Target: ChurnLabel (0 = Active, 1 = Churned)
Handles non-linear relationships effectively
Robust performance on structured data

🔹 Model Performance
Accuracy: ~89.7%
ROC-AUC Score: ~97.25%
Evaluation Techniques:
Confusion Matrix
ROC Curve
Precision-Recall Curve
Feature Importance Analysis
Key Insight:

Behavioral features like RecencyRatio, TotalRevenue, and OrderFrequency are strong predictors of churn.

🔹 Dashboard & Visualization
📊 Power BI Dashboard
Customer segmentation
Revenue analysis
Churn insights
Business strategy recommendations

🌐 Streamlit Application
Interactive filtering
Real-time KPI updates
Behavioral analysis

🔹 Business Impact
Enables early identification of churn risk
Supports targeted retention strategies
Improves customer segmentation for decision-making
Bridges the gap between data science and business insights

🔹 Challenges Faced
Handling skewed distributions in behavioral data
Avoiding data leakage during model training
Managing multicollinearity between features
Deployment limitations in Power BI Service (organizational access required)

🔹 Experimental Features

An LLM-based retention message generator was explored as part of the project to automate customer engagement strategies. However, due to latency and deployment constraints with local models, it has been kept as a prototype and not integrated into the main pipeline

🔹 Future Enhancements
Real-time data pipeline using APIs
Integration with cloud platforms for scalability
AI-driven automated retention strategies
Advanced personalization using behavioral tracking



