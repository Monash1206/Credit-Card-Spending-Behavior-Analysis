-- =============================================
-- CREDIT CARD SPENDING BEHAVIOR ANALYSIS: SQL QUERIES
-- Business Analyst Portfolio Project
-- =============================================

-- 📊 CUSTOMER ANALYSIS
-- ----------------------------

-- 1. Age group and gender distribution
SELECT
  CASE 
    WHEN age BETWEEN 18 AND 25 THEN '18-25'
    WHEN age BETWEEN 26 AND 35 THEN '26-35'
    WHEN age BETWEEN 36 AND 50 THEN '36-50'
    ELSE '50+' 
  END AS age_group,
  gender,
  COUNT(*) AS customer_count
FROM cc_customers
GROUP BY age_group, gender;

-- 2. Cities with the most customers
SELECT city, COUNT(*) AS total_customers
FROM cc_customers
GROUP BY city
ORDER BY total_customers DESC;

-- 3. Average income by city
SELECT city, AVG(income) AS avg_income
FROM cc_customers
GROUP BY city
ORDER BY avg_income DESC;

-- 4. Customers joined per year
SELECT EXTRACT(YEAR FROM join_date) AS year_joined, COUNT(*) AS customers_joined
FROM cc_customers
GROUP BY year_joined
ORDER BY year_joined;

-- 💳 CARD USAGE ANALYSIS
-- ----------------------------

-- 5. Active vs inactive cards
SELECT status, COUNT(*) AS card_count
FROM cc_cards
GROUP BY status;

-- 6. Average credit limit by card type
SELECT card_type, AVG(card_limit) AS avg_limit
FROM cc_cards
GROUP BY card_type;

-- 7. Customers with highest card limits
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name, card_limit
FROM cc_cards cc
JOIN cc_customers c ON c.customer_id = cc.customer_id
ORDER BY card_limit DESC
LIMIT 10;

-- 💰 TRANSACTION BEHAVIOR
-- ----------------------------

-- 8. Average transaction amount by category
SELECT category, AVG(amount) AS avg_spend
FROM cc_transactions
GROUP BY category
ORDER BY avg_spend DESC;

-- 9. Top 5 merchants by total spend
SELECT merchant, SUM(amount) AS total_spent
FROM cc_transactions
GROUP BY merchant
ORDER BY total_spent DESC
LIMIT 5;

-- 10. Monthly transaction volume and value
SELECT DATE_FORMAT(txn_date, '%Y-%m') AS txn_month,
       COUNT(*) AS txn_count,
       SUM(amount) AS total_spend
FROM cc_transactions
GROUP BY txn_month
ORDER BY txn_month;

-- 11. Top 10 spending customers
SELECT customer_id, SUM(amount) AS total_spent
FROM cc_transactions
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 10;

-- 12. City-wise customer spending
SELECT c.city, SUM(s.total_spent) AS city_spending
FROM cc_statements s
JOIN cc_customers c ON s.customer_id = c.customer_id
GROUP BY c.city
ORDER BY city_spending DESC;

-- 📈 SPENDING TRENDS
-- ----------------------------

-- 13. Monthly spending trend
SELECT month, SUM(total_spent) AS monthly_total
FROM cc_statements
GROUP BY month
ORDER BY month;

-- 14. Spending by category over time
SELECT DATE_FORMAT(txn_date, '%Y-%m') AS month, category, SUM(amount) AS total_spent
FROM cc_transactions
GROUP BY month, category
ORDER BY month, category;

-- ⚠️ RISK/CHURN ANALYSIS
-- ----------------------------

-- 15. Inactive customers (no transactions)
SELECT c.customer_id, c.name
FROM cc_customers c
LEFT JOIN cc_transactions t ON c.customer_id = t.customer_id
WHERE t.txn_id IS NULL;

-- 16. Customers with no transactions in last 3 months
SELECT customer_id
FROM cc_transactions
GROUP BY customer_id
HAVING MAX(txn_date) < CURDATE() - INTERVAL 3 MONTH;

-- 17. High credit utilization customers (>80%)
SELECT t.customer_id,
       SUM(t.amount) AS total_spent,
       cd.credit_limit,
       ROUND((SUM(t.amount) / cd.credit_limit) * 100, 2) AS utilization_percentage
FROM cc_transactions t
JOIN cc_cards cd ON t.customer_id = cd.customer_id
GROUP BY t.customer_id, cd.credit_limit
HAVING utilization_percentage > 80;

-- 🧾 STATEMENT-BASED ANALYSIS
-- ----------------------------

-- 18. Average monthly spending by income level
SELECT c.income_level, AVG(s.total_spent) AS avg_monthly_spending
FROM cc_statements s
JOIN cc_customers c ON s.customer_id = c.customer_id
GROUP BY c.income_level;

-- 19. Customer age vs total spending
SELECT c.age, SUM(s.total_spent) AS total_spent
FROM cc_statements s
JOIN cc_customers c ON s.customer_id = c.customer_id
GROUP BY c.age
ORDER BY c.age;

-- 20. Consistent spenders (lowest stddev)
SELECT customer_id, STDDEV(total_spent) AS spend_stddev
FROM cc_statements
GROUP BY customer_id
ORDER BY spend_stddev ASC
LIMIT 10;

-- ✅ KPI QUERIES FOR DASHBOARDS
-- ----------------------------

-- Total Spend
SELECT SUM(amount) AS total_spend FROM cc_transactions;

-- Average Spend Per Customer
SELECT AVG(total_spent) FROM (
  SELECT customer_id, SUM(amount) AS total_spent
  FROM cc_transactions
  GROUP BY customer_id
) AS customer_spend;

-- Total Active Customers
SELECT COUNT(DISTINCT customer_id) AS active_customers FROM cc_transactions;

-- Monthly Transactions Count
SELECT DATE_FORMAT(txn_date, '%Y-%m') AS month, COUNT(*) AS total_txns
FROM cc_transactions
GROUP BY month;

-- Top 5 Transaction Categories
SELECT category, COUNT(*) AS transaction_count
FROM cc_transactions
GROUP BY category
ORDER BY transaction_count DESC
LIMIT 5;
