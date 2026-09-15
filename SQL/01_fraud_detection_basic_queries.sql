-- ======================================================================================
-- Fraud Detection - Fraud Analysis
-- File: 01_fraud_detection_basic_queries.sql
-- Author: Rasheed A. Tijani
-- Description: Basic Queries for Fraud Detection Analysis
-- =======================================================================================


-- Before analyzing anything, confirm the data loaded correctly.

select 'customers' table_name, count(*) as row_count from customers
union all
select 'merchants', count(*) from merchants
union all
select 'transactions', count(*) from transactions;


-- ========================================================================================
-- How many transactions are fraudulent?
-- ========================================================================================
SELECT is_fraud, COUNT(*) AS txn_count
FROM transactions
GROUP BY is_fraud;



-- ========================================================================================
-- What's the overall fraud rate?
-- ========================================================================================

SELECT
  SUM(is_fraud) AS fraud_count,
  COUNT(*) AS total_txns,
  ROUND(SUM(is_fraud) / COUNT(*) * 100, 2) AS fraud_rate_pct
FROM transactions;



-- ========================================================================================
-- What are the 10 largest transactions?
-- ========================================================================================

SELECT transaction_id, customer_id, transaction_amount
FROM transactions
ORDER BY transaction_amount DESC
LIMIT 10;



-- ========================================================================================
-- Which countries appear as home_country? 
-- ========================================================================================

SELECT DISTINCT home_country
FROM customers
ORDER BY home_country;



-- ========================================================================================
-- Filter where transactions with 3+ failed logins
-- ========================================================================================

SELECT transaction_id, customer_id, login_attempts_failed, is_fraud
FROM transactions
WHERE login_attempts_failed >= 3
ORDER BY login_attempts_failed DESC;



-- ========================================================================================
-- Filter customers whose occupation contains 'Engineer'
-- ========================================================================================

SELECT customer_id, customer_name, occupation
FROM customers
WHERE occupation LIKE '%Engineer%';
