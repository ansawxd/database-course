-- 1: CHECK constraint violation
-- Business rule: dish price must be positive (greater than 0)

DO $$
BEGIN
    -- Try to insert a dish with negative price
    INSERT INTO dishes (restaurant_id, name, current_price)
    VALUES (1, 'Bad Price Dish', -50.00);
EXCEPTION
    WHEN check_violation THEN
        RAISE NOTICE '1. CHECK VIOLATION: Dish price cannot be negative or zero. Business rule: price must be greater than 0. SQLERRM: %', SQLERRM;
    WHEN others THEN
        RAISE NOTICE '1. Unexpected error: %', SQLERRM;
END $$;


-- 2: FOREIGN KEY constraint violation
-- Business rule: every dish must belong to an existing restaurant

DO $$
BEGIN
    -- Try to insert a dish for a restaurant that does not exist
    INSERT INTO dishes (restaurant_id, name, current_price)
    VALUES (99999, 'Ghost Dish', 500.00);
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE '2. FOREIGN KEY VIOLATION: Restaurant with ID 99999 does not exist. Business rule: every dish must belong to a real restaurant. SQLERRM: %', SQLERRM;
    WHEN others THEN
        RAISE NOTICE '2. Unexpected error: %', SQLERRM;
END $$;


-- 3: UNIQUE constraint violation
-- Business rule: each user must have a unique email address

DO $$
BEGIN
    -- Try to insert a user with an email that already exists
    INSERT INTO users (full_name, email, phone)
    VALUES ('Hacker User', 'test@example.com', '+70000000000');
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE '3. UNIQUE VIOLATION: User with email test@example.com already exists. Business rule: one email = one account. SQLERRM: %', SQLERRM;
    WHEN others THEN
        RAISE NOTICE '3. Unexpected error: %', SQLERRM;
END $$;


-- 4: NOT NULL constraint violation
-- Business rule: user name is required (cannot be empty)

DO $$
BEGIN
    -- Try to insert a user without a name
    INSERT INTO users (full_name, email, phone)
    VALUES (NULL, 'noname@test.com', '+71111111111');
EXCEPTION
    WHEN not_null_violation THEN
        RAISE NOTICE '4. NOT NULL VIOLATION: User name (full_name) is required. Business rule: we must know the customer name. SQLERRM: %', SQLERRM;
    WHEN others THEN
        RAISE NOTICE '4. Unexpected error: %', SQLERRM;
END $$;


-- 5: PRIMARY KEY (composite) violation
-- Business rule: one dish can be linked to one category only once

DO $$
BEGIN
    -- Try to insert a duplicate link (dish_id=1, category_id=1)
    -- This pair should already exist in dish_categories table
    INSERT INTO dish_categories (dish_id, category_id)
    VALUES (1, 1);
EXCEPTION
    WHEN unique_violation THEN
        RAISE NOTICE '5. PRIMARY KEY VIOLATION: This dish-category pair already exists. Business rule: one dish cannot be linked to the same category twice. SQLERRM: %', SQLERRM;
    WHEN others THEN
        RAISE NOTICE '5. Unexpected error: %', SQLERRM;
END $$;

-- Show completion message
SELECT 'All 5 constraint violationsnstrated!' AS status;