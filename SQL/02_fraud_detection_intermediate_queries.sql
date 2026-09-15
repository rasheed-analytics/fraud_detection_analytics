-- =====================================================================================
-- Fraud Detection - Fraud Analysis
-- File: 02_fraud_detection_intermediate_queries.sql
-- Author: Rasheed A. Tijani
-- Description: Intermediate Queries for Fraud Detection Analysis
-- ====================================================================================== 


-- ======================================================================================
-- Fraud rate by merchant category 
-- ======================================================================================

SELECT
  m.merchant_category,
  COUNT(*) AS txns,
  SUM(t.is_fraud) AS fraud_txns,
  ROUND(SUM(t.is_fraud) / COUNT(*) * 100, 2) AS fraud_rate_pct
FROM transactions t
JOIN merchants m ON t.merchant_id = m.merchant_id
GROUP BY m.merchant_category
ORDER BY fraud_rate_pct DESC;



-- ========================================================================================
-- Only show categories with a meaningful sample size 
-- ========================================================================================

SELECT
  m.merchant_category,
  COUNT(*) AS txns,
  ROUND(SUM(t.is_fraud) / COUNT(*) * 100, 2) AS fraud_rate_pct
FROM transactions t
JOIN merchants m ON t.merchant_id = m.merchant_id
GROUP BY m.merchant_category
HAVING COUNT(*) >= 100
ORDER BY fraud_rate_pct DESC;



-- ========================================================================================
-- Three-way JOIN — fraud transactions with customer and merchant details
-- ========================================================================================

SELECT
  t.transaction_id, t.transaction_date, t.transaction_amount,
  c.customer_name, c.home_country,
  m.merchant_name, m.merchant_category
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
JOIN merchants m ON t.merchant_id = m.merchant_id
WHERE t.is_fraud = 1
ORDER BY t.transaction_amount DESC
LIMIT 20;



-- ========================================================================================
-- Bucket transactions with CASE WHEN
-- ========================================================================================

SELECT
  CASE
    WHEN transaction_hour BETWEEN 0 AND 5 THEN 'Late Night (12am-5am)'
    WHEN transaction_hour BETWEEN 6 AND 11 THEN 'Morning'
    WHEN transaction_hour BETWEEN 12 AND 17 THEN 'Afternoon'
    ELSE 'Evening'
  END AS time_of_day,
  COUNT(*) AS txns,
  ROUND(SUM(is_fraud) / COUNT(*) * 100, 2) AS fraud_rate_pct
FROM transactions
GROUP BY time_of_day
ORDER BY fraud_rate_pct DESC;



-- ========================================================================================
-- Customers with the highest lifetime spend
-- ========================================================================================

SELECT
  c.customer_id, c.customer_name,
  COUNT(t.transaction_id) AS total_txns,
  SUM(t.transaction_amount) AS lifetime_spend,
  SUM(t.is_fraud) AS fraud_txns
FROM customers c
JOIN transactions t ON c.customer_id = t.customer_id
GROUP BY c.customer_id, c.customer_name
ORDER BY lifetime_spend DESC
LIMIT 15;
