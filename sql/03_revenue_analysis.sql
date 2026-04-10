WITH monthly_revenue AS (
    SELECT 
        DATE_FORMAT(InvoiceDate_clean,'%Y-%m') AS year_mon,
        COUNT(DISTINCT InvoiceNo) AS total_orders,
        COUNT(DISTINCT CustomerID) AS active_customers,
        SUM(revenue) AS total_revenue
    FROM customer
    GROUP BY DATE_FORMAT(InvoiceDate_clean,'%Y-%m')
)

SELECT 
    year_mon,
    total_orders,
    active_customers,
    total_revenue,

    -- AOV
    (total_revenue / total_orders) AS aov,

    -- Previous month revenue
    LAG(total_revenue) OVER (ORDER BY year_mon) AS prev_month_rev,

    -- MoM Growth
    ((total_revenue - LAG(total_revenue) OVER (ORDER BY year_mon)) 
     / LAG(total_revenue) OVER (ORDER BY year_mon)) * 100 AS mom_growth,

    -- Revenue per customer
    (total_revenue / active_customers) AS rev_per_customer,

    -- Orders per customer
    (total_orders / active_customers) AS orders_per_customer

FROM monthly_revenue
ORDER BY year_mon;

# Revenue at Risk

WITH last_purchase AS (
    SELECT 
        CustomerID,
        MAX(InvoiceDate_clean) AS last_purchase_date,
        SUM(Revenue) AS total_revenue
    FROM customer
    GROUP BY CustomerID
),


dataset_max AS (
    SELECT MAX(InvoiceDate_clean) AS max_date
    FROM customer
),

customer_status AS (
    SELECT 
        lp.CustomerID,
        lp.total_revenue,
        DATEDIFF(dm.max_date, lp.last_purchase_date) AS days_inactive,
        CASE 
            WHEN DATEDIFF(dm.max_date, lp.last_purchase_date) > 90 THEN 'At Risk'
            ELSE 'Active'
        END AS status
    FROM last_purchase lp
    CROSS JOIN dataset_max dm
)
SELECT 
    status,
    ROUND(AVG(total_revenue), 2) AS avg_revenue_per_customer
FROM customer_status
GROUP BY status;
-- SELECT 
--     status,
--     COUNT(CustomerID) AS customers,
--     ROUND(SUM(total_revenue), 2) AS revenue,
--     ROUND(100 * SUM(total_revenue) / SUM(SUM(total_revenue)) OVER (), 2) AS revenue_pct
-- FROM customer_status
-- GROUP BY status;


# Repeat vs One-time Customers

WITH customer_orders AS (
    SELECT 
        CustomerID,
        COUNT(DISTINCT InvoiceNo) AS total_orders,
        SUM(Revenue) AS total_revenue
    FROM customer
    GROUP BY CustomerID
),

customer_type AS (
    SELECT 
        CustomerID,
        total_revenue,
        CASE 
            WHEN total_orders = 1 THEN 'One-Time'
            ELSE 'Repeat'
        END AS customer_category
    FROM customer_orders
)
SELECT 
    customer_category,
    ROUND(AVG(total_revenue), 2) AS avg_revenue_per_customer
FROM customer_type
GROUP BY customer_category;

SELECT 
    customer_category,
    COUNT(CustomerID) AS customers,
    ROUND(SUM(total_revenue), 2) AS revenue,
    ROUND(100 * SUM(total_revenue) / SUM(SUM(total_revenue)) OVER (), 2) AS revenue_pct
FROM customer_type
GROUP BY customer_category;


# Revenue Concentration

WITH customer_revenue AS (
    SELECT 
        CustomerID,
        SUM(Revenue) AS total_revenue
    FROM customer
    GROUP BY CustomerID
),

ranked_customers AS (
    SELECT 
        CustomerID,
        total_revenue,
        NTILE(10) OVER (ORDER BY total_revenue DESC) AS decile
    FROM customer_revenue
)

SELECT 
    'Top 10%' AS segment,
    COUNT(*) AS customers,
    ROUND(SUM(total_revenue), 2) AS revenue
FROM ranked_customers
WHERE decile = 1

UNION ALL

SELECT 
    'Top 20%',
    COUNT(*),
    ROUND(SUM(total_revenue), 2)
FROM ranked_customers
WHERE decile IN (1,2)

UNION ALL

SELECT 
    'Bottom 50%',
    COUNT(*),
    ROUND(SUM(total_revenue), 2)
FROM ranked_customers
WHERE decile IN (6,7,8,9,10);

# Cohort Comparison
SELECT 
    cohort_month,

    MAX(CASE WHEN month_index = 1 THEN retention_percent END) AS m1_retention,
    MAX(CASE WHEN month_index = 2 THEN retention_percent END) AS m2_retention,
    MAX(CASE WHEN month_index = 3 THEN retention_percent END) AS m3_retention

FROM cohort_table
GROUP BY cohort_month
ORDER BY cohort_month;
