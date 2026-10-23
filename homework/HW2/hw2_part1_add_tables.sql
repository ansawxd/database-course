-- ============================================================
-- HW #2, Part 1: Add new tables for dish categories
-- This script adds two new tables to the existing schema
-- ============================================================

-- 1. Delete new tables if they exist (for reproducibility)
DROP TABLE IF EXISTS dish_categories CASCADE;
DROP TABLE IF EXISTS categories CASCADE;

-- 2. Create table: categories (dish categories like Pizza, Sushi, Drinks)
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    sort_order  INT NOT NULL DEFAULT 0
);

-- 3. Create table: dish_categories (many-to-many link)
-- This table connects dishes and categories
-- One dish can be in many categories (example: "Seafood Pizza" is in "Pizza" and "Seafood")
-- One category can have many dishes (example: "Pizza" has many pizza types)
CREATE TABLE dish_categories (
    dish_id     INT NOT NULL,
    category_id INT NOT NULL,
    PRIMARY KEY (dish_id, category_id),
    CONSTRAINT fk_dc_dish
        FOREIGN KEY (dish_id) REFERENCES dishes(dish_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_dc_category
        FOREIGN KEY (category_id) REFERENCES categories(category_id)
        ON DELETE CASCADE
);

-- 4. Create indexes on foreign keys (for fast queries)
CREATE INDEX idx_dc_dish ON dish_categories(dish_id);
CREATE INDEX idx_dc_category ON dish_categories(category_id);

-- 5. Add extra indexes for frequent queries from HW #1
-- These indexes help answer common business questions faster

-- Index for query: "Top 10 dishes last week"
CREATE INDEX IF NOT EXISTS idx_orders_created_status
    ON orders(created_at, status);

-- Index for query: "Restaurant revenue this month"
-- Partial index: only delivered orders
CREATE INDEX IF NOT EXISTS idx_orders_delivered
    ON orders(restaurant_id, created_at)
    WHERE status = 'delivered';

-- Index for query: "Restaurants with rating > 4.5"
-- Partial index: only high-rated restaurants
CREATE INDEX IF NOT EXISTS idx_restaurants_high_rated
    ON restaurants(rating DESC)
    WHERE rating > 4.5;

-- 6. Add test data for new tables
INSERT INTO categories (name, description, sort_order) VALUES
    ('Pizza', 'All types of pizza', 1),
    ('Sushi', 'Rolls and sushi', 2),
    ('Drinks', 'Cold and hot drinks', 3),
    ('Desserts', 'Sweet dishes', 4),
    ('Seafood', 'Dishes with seafood', 5);

-- Link dish_id=1 (Margherita Pizza) to category_id=1 (Pizza)
-- Note: dish_id=1 must exist in dishes table (created in schema.sql)
INSERT INTO dish_categories (dish_id, category_id) VALUES
    (1, 1);

-- Show what we created
SELECT 'Part 1 tables created successfully!' AS status;