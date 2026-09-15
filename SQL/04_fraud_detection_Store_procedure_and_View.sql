-- =====================================================================================
-- Fraud Detection - Fraud Analysis
-- File: 04_fraud_detection_Store_procedure_and_View.sql
-- Author: Rasheed A. Tijani
-- Description: Procedure_and_View for Fraud Detection Analysis
-- ======================================================================================


-- ========================================================================================
-- A category-level fraud summary view
-- ========================================================================================

CREATE OR REPLACE VIEW vw_fraud_by_category AS
SELECT
  m.merchant_category,
  COUNT(*) AS total_txns,
  SUM(t.is_fraud) AS fraud_txns,
  ROUND(SUM(t.is_fraud) / COUNT(*) * 100, 2) AS fraud_rate_pct,
  ROUND(SUM(t.transaction_amount), 2) AS total_volume,
  ROUND(AVG(t.transaction_amount), 2) AS avg_transaction_amount
FROM transactions t
JOIN merchants m ON t.merchant_id = m.merchant_id
GROUP BY m.merchant_category;

-- Use it like any table:
SELECT * FROM vw_fraud_by_category ORDER BY fraud_rate_pct DESC;



-- ========================================================================================
-- A customer risk profile view
-- ========================================================================================

CREATE OR REPLACE VIEW vw_customer_risk_profile AS
SELECT
  c.customer_id,
  c.customer_name,
  c.customer_risk_segment,
  c.previous_fraud_flag,
  COUNT(t.transaction_id) AS total_txns,
  SUM(t.is_fraud) AS fraud_txns,
  ROUND(SUM(t.is_fraud) / NULLIF(COUNT(t.transaction_id), 0) * 100, 2) AS fraud_rate_pct,
  ROUND(SUM(t.transaction_amount), 2) AS lifetime_spend
FROM customers c
LEFT JOIN transactions t ON c.customer_id = t.customer_id
GROUP BY c.customer_id, c.customer_name, c.customer_risk_segment, c.previous_fraud_flag;

SELECT * 
FROM vw_customer_risk_profile
WHERE fraud_rate_pct > 0
ORDER BY fraud_rate_pct DESC;

