-- Analyze missing CustomerID
SELECT 
    COUNT(*) AS blank_customers,
    SUM(revenue) AS blank_revenue
FROM transactions
WHERE CustomerID = '';

-- Create customer-level dataset
CREATE TABLE customer AS
SELECT *
FROM transactions
WHERE CustomerID <> '';

-- Validate
SELECT COUNT(*) FROM customer;
SELECT SUM(revenue) FROM customer;