-- =====================================================================================
-- Fraud Detection - Fraud Analysis
-- File: 03_fraud_detection_Advanced_queries.sql
-- Author: Rasheed A. Tijani
-- Description: Advanced  Queries for Fraud Detection Analysis
-- ======================================================================================


-- ======================================================================================
--  Rank customers by fraud exposure (window function)
-- ======================================================================================

SELECT
  customer_id,
  SUM(is_fraud) AS fraud_txns,
  RANK() OVER (ORDER BY SUM(is_fraud) DESC) AS fraud_rank
FROM transactions
GROUP BY customer_id
HAVING SUM(is_fraud) > 0
ORDER BY fraud_rank
LIMIT 20;



-- ======================================================================================
-- Running total of fraud volume by date (window function)
-- ======================================================================================

SELECT
  transaction_date,
  SUM(transaction_amount) AS daily_fraud_volume,
  SUM(SUM(transaction_amount)) OVER (ORDER BY transaction_date) AS running_total
FROM transactions
WHERE is_fraud = 1
GROUP BY transaction_date
ORDER BY transaction_date;



-- ======================================================================================
-- Compare each transaction to its category average (window function)
-- ======================================================================================

SELECT
  t.transaction_id,
  m.merchant_category,
  t.transaction_amount,
  ROUND(AVG(t.transaction_amount) OVER (PARTITION BY m.merchant_category), 2) AS category_avg,
  t.is_fraud
FROM transactions t
JOIN merchants m ON t.merchant_id = m.merchant_id
ORDER BY t.transaction_amount DESC
LIMIT 20;



-- =======================================================================================
-- A CTE that finds high combined-risk transactions
-- =======================================================================================

WITH risk_flags AS (
  SELECT
    transaction_id, customer_id, risk_score, is_fraud,
    (country_mismatch
      + is_new_device
      + (login_attempts_failed >= 3)
      + previous_fraud_flag
      + (transactions_last_24h >= 6)) AS combined_risk_factors
  FROM transactions
)
SELECT *
FROM risk_flags
WHERE combined_risk_factors >= 3
ORDER BY risk_score DESC;



-- =======================================================================================
-- customers whose most recent transaction was fraud
-- =======================================================================================

SELECT t.customer_id, t.transaction_id, t.transaction_date, t.is_fraud
FROM transactions t
WHERE t.transaction_date = (
  SELECT MAX(t2.transaction_date)
  FROM transactions t2
  WHERE t2.customer_id = t.customer_id
)
AND t.is_fraud = 1;