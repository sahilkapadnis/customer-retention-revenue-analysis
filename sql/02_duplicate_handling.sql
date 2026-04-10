-- Identify duplicate rows
SELECT COUNT(*) 
FROM (
    SELECT 
        InvoiceNo,
        StockCode,
        Quantity,
        InvoiceDate_clean,
        UnitPrice,
        CustomerID,
        COUNT(*) as cnt
    FROM transactions
    GROUP BY 
        InvoiceNo,
        StockCode,
        Quantity,
        InvoiceDate_clean,
        UnitPrice,
        CustomerID
    HAVING COUNT(*) > 1
) t;

-- Remove duplicates using ROW_NUMBER
WITH ranked AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY InvoiceNo, StockCode, Quantity, InvoiceDate_clean, UnitPrice, CustomerID
            ORDER BY InvoiceNo
        ) AS rn
    FROM transactions
)
DELETE FROM transactions
WHERE (InvoiceNo, StockCode, Quantity, InvoiceDate_clean, UnitPrice, CustomerID) IN (
    SELECT InvoiceNo, StockCode, Quantity, InvoiceDate_clean, UnitPrice, CustomerID
    FROM ranked
    WHERE rn > 1
);