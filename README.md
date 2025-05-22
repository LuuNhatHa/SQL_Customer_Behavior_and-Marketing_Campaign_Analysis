# SQL_Customer_Behavior_and_Marketing_Campaign_Analysis

## Project Title
**Customer behavior and Marketing campaign analysis using SQL**

## Project Objectives
- Clean, preprocess, and enrich the marketing dataset using SQL Server.
- Analyze customer demographics, purchasing behavior, and promotional response.
- Measure the effectiveness of marketing campaigns.
- Identify customer segments and spending patterns based on age, income, education, and shopping channels.

## Dataset Overview

- **Source:** Marketing Campaign Dataset
- **Size:** 2,240 rows × 29 columns
- **Key Fields:**

**Personal Information**
- ID: Unique identifier for each customer
- Year_Birth: Customer's year of birth
- Education: Level of education
- Marital_Status: Marital status (e.g., Single, Married, Divorced)
- Income: Annual household income
- Kidhome: Number of children in the household
- Teenhome: Number of teenagers in the household
- Dt_Customer: Date the customer enrolled with the company
- Recency: Number of days since the customer's last purchase
- Complain: 1 if the customer has complained in the last 2 years, 0 otherwise

**Product Spending**
- MntWines: Amount spent on wine in the last 2 years
- MntFruits: Amount spent on fruits in the last 2 years
- MntMeatProducts: Amount spent on meat in the last 2 years
- MntFishProducts: Amount spent on fish in the last 2 years
-- MntSweetProducts: Amount spent on sweets in the last 2 years
- MntGoldProds: Amount spent on gold products in the last 2 years

**Promotion Campaigns**
- NumDealsPurchases: Number of purchases made with discounts
- AcceptedCmp1 to AcceptedCmp5: 1 if the customer accepted the offer in campaign 1 to 5
- Response: 1 if the customer accepted the offer in the last (most recent) campaign

**Purchase Channels**
- NumWebPurchases: Number of purchases made through the company’s website
- NumCatalogPurchases: Number of purchases made using a catalog
- NumStorePurchases: Number of purchases made directly in physical stores
- NumWebVisitsMonth: Number of visits to the company’s website in the last month

## Tools Used
- **SQL Server** — For data cleaning, preprocessing, feature engineering, and querying insights.

## Project Steps

### 1. Data Cleaning & Feature Engineering

- Removed rows with missing income
- Converted `Dt_Customer` to `DATE` format
- Added new columns:
  - `Age`, `Year_Enrolled`, `TotalPeople`, `TotalSpend`, `TotalPurchases`, `CampaignsAccepted`
- Removed irrelevant or uniform columns: `Z_CostContact`, `Z_Revenue`
- Removed outliers with Age < 15 or > 75
  
### 2. Customer Behavior Analysis

- **By Age Group**: spending, web visits, campaign response rate
- **By Education**: response rate and average spend
- **By Income Group**: categorized spending and purchasing habits
- **By Marital Status and Children**: behavioral insights
- **By Product Category**: dominant categories like wine and meat
- **By Channel**: preference for web, catalog, or store purchases

### 3. Promotional Campaign Analysis
- Calculated response rate for each campaign (Cmp1 to Cmp5, Response)
- Identified high-response customers (3+ campaigns accepted)
- Compared average purchases between responders and non-responders
- Analyzed correlation between deals used and campaign response
- Determined the final campaign as most impactful
