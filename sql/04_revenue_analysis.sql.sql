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