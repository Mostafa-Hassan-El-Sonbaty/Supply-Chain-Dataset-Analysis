
-- ============================================================
-- Olist E-Commerce Database Schema
-- ============================================================

-- ------------------------------------------------------------
--  CREATE SCHEMAS
-- ------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS clean;

-- RAW TABLES

CREATE TABLE IF NOT EXISTS raw.customers (
    customer_id VARCHAR(50),
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix VARCHAR(5),
    customer_city VARCHAR(100),
    customer_state CHAR(2)
);

CREATE TABLE IF NOT EXISTS raw.sellers (
    seller_id VARCHAR(50),
	seller_zip_code_prefix VARCHAR(5),
    seller_city VARCHAR(100),
    seller_state CHAR(2)
);

CREATE TABLE IF NOT EXISTS raw.translation (
    product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS raw.products (
    product_id VARCHAR(50),
    product_category_name VARCHAR(100),
    product_name_lenght INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty INTEGER,
    product_weight_g NUMERIC,
    product_length_cm NUMERIC,
    product_height_cm NUMERIC,
    product_width_cm NUMERIC
);

CREATE TABLE IF NOT EXISTS raw.orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

CREATE TABLE IF NOT EXISTS raw.order_items (
    order_id VARCHAR(50),
    order_item_id INTEGER,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price NUMERIC(12,2),
    freight_value NUMERIC(12,2)
);

CREATE TABLE IF NOT EXISTS raw.payments (
    order_id VARCHAR(50),
    payment_sequential INTEGER,
    payment_type VARCHAR(30),
    payment_installments INTEGER,
    payment_value NUMERIC(12,2)
);

CREATE TABLE IF NOT EXISTS raw.reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);


-- CLEAN TABLES

CREATE TABLE IF NOT EXISTS clean.customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix VARCHAR(5),
    customer_city VARCHAR(100),
    customer_state CHAR(2)
);

CREATE TABLE IF NOT EXISTS clean.sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
	seller_zip_code_prefix VARCHAR(5),
    seller_city VARCHAR(100),
    seller_state CHAR(2)
);

CREATE TABLE IF NOT EXISTS clean.translation (
    product_category_name VARCHAR(100) PRIMARY KEY,
    product_category_name_english VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS clean.products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_lenght INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty INTEGER,
    product_weight_g NUMERIC,
    product_length_cm NUMERIC,
    product_height_cm NUMERIC,
    product_width_cm NUMERIC
);

CREATE TABLE IF NOT EXISTS clean.orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,
    FOREIGN KEY (customer_id)
        REFERENCES clean.customers(customer_id)
);

CREATE TABLE IF NOT EXISTS clean.order_items (
    order_id VARCHAR(50),
    order_item_id INTEGER,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price NUMERIC(12,2),
    freight_value NUMERIC(12,2),
	price_outlier BOOLEAN,
    freight_outlier BOOLEAN,
    PRIMARY KEY (order_id, order_item_id),
	CONSTRAINT chk_order_items_price CHECK (price >= 0),
    CONSTRAINT chk_order_items_freight CHECK (freight_value >= 0),
    FOREIGN KEY (order_id)
        REFERENCES clean.orders(order_id),
    FOREIGN KEY (product_id)
        REFERENCES clean.products(product_id),
    FOREIGN KEY (seller_id)
        REFERENCES clean.sellers(seller_id)
);

CREATE TABLE IF NOT EXISTS clean.payments (
    order_id VARCHAR(50),
    payment_sequential INTEGER,
    payment_type VARCHAR(30),
    payment_installments INTEGER,
    payment_value NUMERIC(12,2),
    PRIMARY KEY (order_id, payment_sequential),
	CONSTRAINT chk_payments_value CHECK (payment_value >= 0),
    FOREIGN KEY (order_id)
        REFERENCES clean.orders(order_id)
);

CREATE TABLE IF NOT EXISTS clean.reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP,
    PRIMARY KEY (review_id, order_id),
	CONSTRAINT chk_reviews_score CHECK (review_score BETWEEN 1 AND 5),
    FOREIGN KEY (order_id)
        REFERENCES clean.orders(order_id)
);


-- INDEXES

CREATE INDEX IF NOT EXISTS idx_orders_customer_id
    ON clean.orders(customer_id);

CREATE INDEX IF NOT EXISTS idx_orders_purchase_timestamp
    ON clean.orders(order_purchase_timestamp);

CREATE INDEX IF NOT EXISTS idx_order_items_product_id
    ON clean.order_items(product_id);

CREATE INDEX IF NOT EXISTS idx_order_items_seller_id
    ON clean.order_items(seller_id);

CREATE INDEX IF NOT EXISTS idx_reviews_order_id
    ON clean.reviews(order_id);

-- ============================================================
-- CSV IMPORT
-- ============================================================
-- HOW TO CHANGE THE FOLDER PATH:
--   Files are expected in C:/Database/raw and C:/Database/clean
--   If your folder is different, press Ctrl+H (Find & Replace) and
--   replace  C:/Database  with your own path. Use forward slashes (/).
--   Keep the folder OUTSIDE Desktop and Documents to avoid
--   "permission denied" errors.
--
-- DATA FLOW:
--   raw   = original Excel data (Olist_Sample.xlsx), no constraints
--   clean = cleaned data from Abdelrahman's notebook (Python),
--           loaded directly from the cleaned CSV files.
--   There is NO SQL transfer from raw to clean.

-- ------------------------------------------------------------
-- STEP 1: EMPTY THE TABLES (removes rows only, keeps the tables)
-- This makes the script safe to run more than once.
-- ------------------------------------------------------------
TRUNCATE TABLE raw.customers, raw.sellers, raw.translation, raw.products,
               raw.orders, raw.order_items, raw.payments, raw.reviews;

-- All clean tables are in ONE command because they reference each other (FK)
TRUNCATE TABLE clean.reviews, clean.payments, clean.order_items, clean.orders,
               clean.products, clean.translation, clean.sellers, clean.customers;

-- ------------------------------------------------------------
-- STEP 2: LOAD RAW (order respects the relationships)
-- ------------------------------------------------------------
COPY raw.customers   FROM 'C:/Database/raw/Customers.csv'   WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
COPY raw.sellers     FROM 'C:/Database/raw/Sellers.csv'     WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
COPY raw.translation FROM 'C:/Database/raw/Translation.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
COPY raw.products    FROM 'C:/Database/raw/Products.csv'    WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
COPY raw.orders      FROM 'C:/Database/raw/Orders.csv'      WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
COPY raw.order_items FROM 'C:/Database/raw/Order_Items.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
COPY raw.payments    FROM 'C:/Database/raw/Payments.csv'    WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
COPY raw.reviews     FROM 'C:/Database/raw/Reviews.csv'     WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

-- ------------------------------------------------------------
-- STEP 3: LOAD CLEAN (same order)
-- order_items has 9 columns here (includes price_outlier, freight_outlier)
-- ------------------------------------------------------------
COPY clean.customers   FROM 'C:/Database/clean/Customers_cleaned.csv'   WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
COPY clean.sellers     FROM 'C:/Database/clean/Sellers_cleaned.csv'     WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
COPY clean.translation FROM 'C:/Database/clean/Translation_cleaned.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
COPY clean.products    FROM 'C:/Database/clean/Products_cleaned.csv'    WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
COPY clean.orders      FROM 'C:/Database/clean/Orders_cleaned.csv'      WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
COPY clean.order_items FROM 'C:/Database/clean/Order_Items_cleaned.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
COPY clean.payments    FROM 'C:/Database/clean/Payments_cleaned.csv'    WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');
COPY clean.reviews     FROM 'C:/Database/clean/Reviews_cleaned.csv'     WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

-- ------------------------------------------------------------
-- STEP 4: RESTORE LEADING ZEROS IN ZIP CODES
-- Excel stored zips as numbers, so 01046 became 1046.
-- This pads every zip back to 5 digits.
-- ------------------------------------------------------------
UPDATE raw.customers   SET customer_zip_code_prefix = LPAD(customer_zip_code_prefix, 5, '0');
UPDATE raw.sellers     SET seller_zip_code_prefix   = LPAD(seller_zip_code_prefix,   5, '0');
UPDATE clean.customers SET customer_zip_code_prefix = LPAD(customer_zip_code_prefix, 5, '0');
UPDATE clean.sellers   SET seller_zip_code_prefix   = LPAD(seller_zip_code_prefix,   5, '0');