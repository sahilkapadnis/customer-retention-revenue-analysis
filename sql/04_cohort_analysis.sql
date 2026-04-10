CREATE TABLE cohort_table AS
WITH cohort_base AS (
    SELECT DISTINCT 
        CustomerID,
        DATE_FORMAT(InvoiceDate_clean, '%Y-%m-01') AS purchase_month
    FROM customer
),

cohort_tagged AS (
    SELECT 
        CustomerID,
        purchase_month,
        MIN(purchase_month) OVER (PARTITION BY CustomerID) AS cohort_month
    FROM cohort_base
),

cohort_indexed AS (
    SELECT 
        CustomerID,
        cohort_month,
        purchase_month,
        TIMESTAMPDIFF(MONTH, cohort_month, purchase_month) AS month_index
    FROM cohort_tagged
),

cohort_counts AS (
    SELECT 
        cohort_month,
        month_index,
        COUNT(DISTINCT CustomerID) AS customer_count
    FROM cohort_indexed
    GROUP BY cohort_month, month_index
),

cohort_final AS (
    SELECT 
        cohort_month,
        month_index,
        customer_count,
        MAX(CASE WHEN month_index = 0 THEN customer_count END) 
            OVER (PARTITION BY cohort_month) AS cohort_size
    FROM cohort_counts
)

SELECT 
    cohort_month,
    month_index,
    customer_count,
    ROUND((customer_count / cohort_size) * 100, 2) AS retention_percent
FROM cohort_final;
