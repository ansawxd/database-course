-- 1. Delete old tables if they exist
-- Order is important: delete child tables first, then parent tables
DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS dish_categories CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS dishes CASCADE;
DROP TABLE IF EXISTS couriers CASCADE;
DROP TABLE IF EXISTS restaurants CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- 2. Create tables from HW #1

-- Table: users (customers of the service)
CREATE TABLE users (
    user_id    SERIAL PRIMARY KEY,
    full_name  VARCHAR(100) NOT NULL,
    email      VARCHAR(255) NOT NULL UNIQUE,
    phone      VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Table: restaurants (food providers)
CREATE TABLE restaurants (
    restaurant_id SERIAL PRIMARY KEY,
    name          VARCHAR(150) NOT NULL,
    address       TEXT NOT NULL,
    rating        NUMERIC(3,2) NOT NULL DEFAULT 0
                  CHECK (rating >= 0 AND rating <= 5)
);

-- Table: couriers (delivery workers)
CREATE TABLE couriers (
    courier_id SERIAL PRIMARY KEY,
    full_name  VARCHAR(100) NOT NULL,
    phone      VARCHAR(20) NOT NULL,
    rating     NUMERIC(3,2) NOT NULL DEFAULT 5
               CHECK (rating >= 0 AND rating <= 5),
    is_active  BOOLEAN NOT NULL DEFAULT TRUE
);

-- Table: dishes (menu items)
CREATE TABLE dishes (
    dish_id       SERIAL PRIMARY KEY,
    restaurant_id INT NOT NULL,
    name          VARCHAR(150) NOT NULL,
    description   TEXT,
    current_price NUMERIC(10,2) NOT NULL CHECK (current_price > 0),
    CONSTRAINT fk_dishes_restaurant
        FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);

-- Table: orders (customer purchases)
CREATE TABLE orders (
    order_id      SERIAL PRIMARY KEY,
    user_id       INT NOT NULL,
    restaurant_id INT NOT NULL,
    courier_id    INT,
    total_amount  NUMERIC(10,2) NOT NULL DEFAULT 0
                  CHECK (total_amount >= 0),
    status        VARCHAR(20) NOT NULL DEFAULT 'created'
                  CHECK (status IN ('created', 'preparing', 'with_courier',
                                    'delivered', 'cancelled')),
    created_at    TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_orders_user
        FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_orders_restaurant
        FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id),
    CONSTRAINT fk_orders_courier
        FOREIGN KEY (courier_id) REFERENCES couriers(courier_id)
);

-- Table: order_items (dishes in an order)
-- Composite primary key: one dish can appear only once in one order
CREATE TABLE order_items (
    order_id       INT NOT NULL,
    dish_id        INT NOT NULL,
    quantity       INT NOT NULL CHECK (quantity > 0),
    price_at_order NUMERIC(10,2) NOT NULL CHECK (price_at_order >= 0),
    PRIMARY KEY (order_id, dish_id),
    CONSTRAINT fk_items_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_items_dish
        FOREIGN KEY (dish_id) REFERENCES dishes(dish_id)
);

-- Table: reviews (customer feedback)
CREATE TABLE reviews (
    review_id     SERIAL PRIMARY KEY,
    order_id      INT NOT NULL UNIQUE,
    user_id       INT NOT NULL,
    restaurant_id INT NOT NULL,
    courier_id    INT,
    rating        SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment       TEXT,
    created_at    TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_reviews_order
        FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_reviews_user
        FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_reviews_restaurant
        FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id),
    CONSTRAINT fk_reviews_courier
        FOREIGN KEY (courier_id) REFERENCES couriers(courier_id)
);

-- 3. Create tables from HW #2 (Part 1)

-- Table: categories (dish categories like Pizza, Sushi, Drinks)
CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    sort_order  INT NOT NULL DEFAULT 0
);

-- Table: dish_categories (many-to-many link between dishes and categories)
-- One dish can be in many categories, one category can have many dishes
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

-- Indexes for dishes
CREATE INDEX idx_dishes_restaurant ON dishes(restaurant_id);

-- Indexes for orders
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_restaurant ON orders(restaurant_id);
CREATE INDEX idx_orders_courier ON orders(courier_id);
CREATE INDEX idx_orders_created_at ON orders(created_at);

-- Indexes for order_items
CREATE INDEX idx_items_dish ON order_items(dish_id);

-- Indexes for reviews
CREATE INDEX idx_reviews_user ON reviews(user_id);
CREATE INDEX idx_reviews_restaurant ON reviews(restaurant_id);
CREATE INDEX idx_reviews_courier ON reviews(courier_id);

-- Indexes for dish_categories (many-to-many table)
CREATE INDEX idx_dc_dish ON dish_categories(dish_id);
CREATE INDEX idx_dc_category ON dish_categories(category_id);

-- 5. Add test data (so HW #2 Part 2 script can work)

INSERT INTO users (full_name, email, phone) VALUES
    ('Test User', 'test@example.com', '+79991234567');

INSERT INTO restaurants (name, address, rating) VALUES
    ('Test Restaurant', 'Test Address 123', 4.50);

INSERT INTO dishes (restaurant_id, name, current_price) VALUES
    (1, 'Margherita Pizza', 500.00);

INSERT INTO categories (name, description, sort_order) VALUES
    ('Pizza', 'All types of pizza', 1);

INSERT INTO dish_categories (dish_id, category_id) VALUES
    (1, 1);

-- Show what we created
SELECT 'Schema created successfully!' AS status;