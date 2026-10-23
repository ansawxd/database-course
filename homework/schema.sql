-- Служба доставки еды. Физическая модель. PostgreSQL.

-- 1. Удаляем старые таблицы, если они есть
DROP TABLE IF EXISTS reviews     CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders      CASCADE;
DROP TABLE IF EXISTS dishes      CASCADE;
DROP TABLE IF EXISTS couriers    CASCADE;
DROP TABLE IF EXISTS restaurants CASCADE;
DROP TABLE IF EXISTS users       CASCADE;

-- 2. Пользователи
CREATE TABLE users (
    user_id    SERIAL PRIMARY KEY,
    full_name  VARCHAR(100) NOT NULL,
    email      VARCHAR(255) NOT NULL UNIQUE,
    phone      VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 3. Рестораны
CREATE TABLE restaurants (
    restaurant_id SERIAL PRIMARY KEY,
    name          VARCHAR(150) NOT NULL,
    address       TEXT NOT NULL,
    rating        NUMERIC(3,2) NOT NULL DEFAULT 0
                  CHECK (rating >= 0 AND rating <= 5)
);

-- 4. Курьеры
CREATE TABLE couriers (
    courier_id SERIAL PRIMARY KEY,
    full_name  VARCHAR(100) NOT NULL,
    phone      VARCHAR(20) NOT NULL,
    rating     NUMERIC(3,2) NOT NULL DEFAULT 5
               CHECK (rating >= 0 AND rating <= 5),
    is_active  BOOLEAN NOT NULL DEFAULT TRUE
);

-- 5. Блюда (меню ресторана)
CREATE TABLE dishes (
    dish_id       SERIAL PRIMARY KEY,
    restaurant_id INT NOT NULL,
    name          VARCHAR(150) NOT NULL,
    description   TEXT,
    current_price NUMERIC(10,2) NOT NULL CHECK (current_price > 0),
    CONSTRAINT fk_dishes_restaurant
        FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);

-- 6. Заказы
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

-- 7. Состав заказа (одно блюдо + количество)
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

-- 8. Отзывы
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

-- 9. Индексы на внешние ключи
CREATE INDEX idx_dishes_restaurant    ON dishes(restaurant_id);
CREATE INDEX idx_orders_user          ON orders(user_id);
CREATE INDEX idx_orders_restaurant    ON orders(restaurant_id);
CREATE INDEX idx_orders_courier       ON orders(courier_id);
CREATE INDEX idx_items_dish           ON order_items(dish_id);
CREATE INDEX idx_reviews_user         ON reviews(user_id);
CREATE INDEX idx_reviews_restaurant   ON reviews(restaurant_id);
CREATE INDEX idx_reviews_courier      ON reviews(courier_id);

-- Индекс для запросов "заказы за последнюю неделю / месяц"
CREATE INDEX idx_orders_created_at    ON orders(created_at);