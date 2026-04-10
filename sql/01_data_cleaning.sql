-- Remove cancelled invoices
DELETE FROM transactions 
WHERE InvoiceNo LIKE 'C%';

-- Remove negative quantity
DELETE FROM transactions 
WHERE Quantity < 0;

-- Remove zero/negative price
DELETE FROM transactions 
WHERE UnitPrice <= 0;

-- Add revenue column (DECIMAL - correct)
ALTER TABLE transactions 
ADD COLUMN revenue DECIMAL(12,2);

-- Populate revenue
UPDATE transactions 
SET revenue = Quantity * UnitPrice;