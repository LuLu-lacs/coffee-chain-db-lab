CREATE DATABASE IF NOT EXISTS coffee_chain_db
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE coffee_chain_db;
SET NAMES utf8mb4;

CREATE TABLE categories (
    category_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    category_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (category_id),
    UNIQUE KEY uq_categories_name (category_name)
) ENGINE=InnoDB;

CREATE TABLE suppliers (
    supplier_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    supplier_name VARCHAR(150) NOT NULL,
    PRIMARY KEY (supplier_id),
    UNIQUE KEY uq_suppliers_name (supplier_name)
) ENGINE=InnoDB;

CREATE TABLE coffee_shops (
    shop_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    shop_name VARCHAR(150) NOT NULL,
    address VARCHAR(250) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    PRIMARY KEY (shop_id)
) ENGINE=InnoDB;

CREATE TABLE products (
    product_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    product_name VARCHAR(150) NOT NULL,
    category_id INT UNSIGNED NOT NULL,
    portion_size VARCHAR(50) NOT NULL,
    current_price DECIMAL(10,2) NOT NULL,
    supplier_id INT UNSIGNED NOT NULL,
    PRIMARY KEY (product_id),
    CONSTRAINT chk_products_price CHECK (current_price > 0),
    CONSTRAINT fk_products_category
        FOREIGN KEY (category_id) REFERENCES categories (category_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_products_supplier
        FOREIGN KEY (supplier_id) REFERENCES suppliers (supplier_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE sales (
    shop_id INT UNSIGNED NOT NULL,
    product_id INT UNSIGNED NOT NULL,
    sale_date DATE NOT NULL,
    sale_price DECIMAL(10,2) NOT NULL,
    quantity INT UNSIGNED NOT NULL,
    PRIMARY KEY (shop_id, product_id, sale_date),
    CONSTRAINT chk_sales_price CHECK (sale_price > 0),
    CONSTRAINT chk_sales_quantity CHECK (quantity > 0),
    CONSTRAINT fk_sales_shop
        FOREIGN KEY (shop_id) REFERENCES coffee_shops (shop_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_sales_product
        FOREIGN KEY (product_id) REFERENCES products (product_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

ALTER TABLE coffee_shops
    MODIFY COLUMN phone VARCHAR(30) NOT NULL;

INSERT INTO categories (category_name) VALUES
    ('Кофе'),
    ('Чай'),
    ('Холодные напитки'),
    ('Десерты'),
    ('Выпечка');

INSERT INTO suppliers (supplier_name) VALUES
    ('Поставщик кофейного зерна'),
    ('Поставщик чая'),
    ('Поставщик ингредиентов для напитков'),
    ('Кондитерский поставщик'),
    ('Пекарня-поставщик');

INSERT INTO coffee_shops (shop_name, address, phone) VALUES
    ('Кофейня на Ленина', 'г. Пермь, ул. Ленина, 45', '+7 (342) 200-10-01'),
    ('Кофейня на Комсомольском', 'г. Пермь, Комсомольский проспект, 32', '+7 (342) 200-10-02'),
    ('Кофейня на Мира', 'г. Пермь, ул. Мира, 21', '+7 (342) 200-10-03');

INSERT INTO products (product_name, category_id, portion_size, current_price, supplier_id) VALUES
    ('Эспрессо',       1, '30 мл',      150.00, 1),
    ('Капучино',       1, '250 мл',     220.00, 1),
    ('Латте',          1, '350 мл',     260.00, 1),
    ('Чай чёрный',     2, '300 мл',     160.00, 2),
    ('Чизкейк',        4, '1 порция',   290.00, 4),
    ('Круассан',       5, '1 шт.',      190.00, 5),
    ('Лимонад',        3, '400 мл',     240.00, 3);

INSERT INTO sales (shop_id, product_id, sale_date, sale_price, quantity) VALUES
    (1, 1, '2026-10-01', 150.00, 20),
    (1, 2, '2026-10-01', 220.00, 15),
    (1, 5, '2026-10-01', 290.00,  7),
    (2, 1, '2026-10-01', 150.00, 11),
    (2, 2, '2026-10-01', 225.00, 20),
    (2, 4, '2026-10-01', 160.00, 12),
    (3, 3, '2026-10-01', 260.00, 10),
    (3, 6, '2026-10-01', 190.00, 15),
    (1, 1, '2026-10-02', 150.00, 22),
    (1, 2, '2026-10-02', 220.00, 16),
    (1, 4, '2026-10-02', 160.00,  9),
    (2, 1, '2026-10-02', 150.00, 12),
    (2, 5, '2026-10-02', 290.00,  5),
    (2, 7, '2026-10-02', 240.00, 13),
    (3, 2, '2026-10-02', 220.00, 13),
    (3, 3, '2026-10-02', 260.00, 11),
    (3, 6, '2026-10-02', 190.00, 12),
    (1, 1, '2026-10-03', 150.00, 21),
    (1, 3, '2026-10-03', 260.00, 13),
    (2, 2, '2026-10-03', 225.00, 18),
    (3, 4, '2026-10-03', 160.00, 11),
    (3, 5, '2026-10-03', 290.00,  6);

UPDATE products
SET current_price = 230.00
WHERE product_id = 2;

INSERT INTO suppliers (supplier_name)
VALUES ('Временный поставщик для демонстрации DELETE');
-- Демонстрация DELETE выполняется администратором БД.
DELETE FROM suppliers
WHERE supplier_name = 'Временный поставщик для демонстрации DELETE';

DESCRIBE coffee_shops;
DESCRIBE categories;
DESCRIBE suppliers;
DESCRIBE products;
DESCRIBE sales;


-- Менеджер: просмотр справочников и добавление/изменение данных кофеен, товаров и продаж.
CREATE USER IF NOT EXISTS 'coffee_manager'@'localhost'
IDENTIFIED BY 'CHANGE_BEFORE_USE_MANAGER';
GRANT SELECT ON coffee_chain_db.* TO 'coffee_manager'@'localhost';
GRANT INSERT, UPDATE ON coffee_chain_db.coffee_shops TO 'coffee_manager'@'localhost';
GRANT INSERT, UPDATE ON coffee_chain_db.products TO 'coffee_manager'@'localhost';
GRANT INSERT, UPDATE ON coffee_chain_db.sales TO 'coffee_manager'@'localhost';

-- Аналитик: только чтение таблиц, необходимых для анализа продаж и категорий.
CREATE USER IF NOT EXISTS 'coffee_analyst'@'localhost'
IDENTIFIED BY 'CHANGE_BEFORE_USE_ANALYST';
GRANT SELECT ON coffee_chain_db.sales TO 'coffee_analyst'@'localhost';
GRANT SELECT ON coffee_chain_db.products TO 'coffee_analyst'@'localhost';
GRANT SELECT ON coffee_chain_db.categories TO 'coffee_analyst'@'localhost';
GRANT SELECT ON coffee_chain_db.coffee_shops TO 'coffee_analyst'@'localhost';

-- Директор: только просмотр сведений о кофейнях, товарах и продажах.
CREATE USER IF NOT EXISTS 'coffee_director'@'localhost'
IDENTIFIED BY 'CHANGE_BEFORE_USE_DIRECTOR';
GRANT SELECT ON coffee_chain_db.sales TO 'coffee_director'@'localhost';
GRANT SELECT ON coffee_chain_db.products TO 'coffee_director'@'localhost';
GRANT SELECT ON coffee_chain_db.coffee_shops TO 'coffee_director'@'localhost';


-- 1. Неявное соединение таблиц через WHERE, фильтр по выбранному периоду
--    и сортировка. Операция аналитика: просмотр продаж по кофейням и товарам.
SELECT s.sale_date,
       c.shop_name,
       p.product_name,
       s.quantity,
       s.sale_price,
       s.quantity * s.sale_price AS revenue_rub
FROM sales AS s, coffee_shops AS c, products AS p
WHERE s.shop_id = c.shop_id
  AND s.product_id = p.product_id
  AND s.sale_date BETWEEN '2026-10-01' AND '2026-10-03'
ORDER BY s.sale_date, c.shop_name, p.product_name;

-- 2. Явное соединение JOIN. Операция аналитика: анализ продаж с указанием
--    кофейни, товара и категории за выбранный период.
SELECT c.shop_name,
       p.product_name,
       cat.category_name,
       s.sale_date,
       s.quantity,
       s.sale_price,
       s.quantity * s.sale_price AS revenue_rub
FROM sales AS s
JOIN coffee_shops AS c ON c.shop_id = s.shop_id
JOIN products AS p ON p.product_id = s.product_id
JOIN categories AS cat ON cat.category_id = p.category_id
WHERE s.sale_date BETWEEN '2026-10-01' AND '2026-10-03'
ORDER BY cat.category_name, c.shop_name, p.product_name, s.sale_date;

-- 3. Агрегирующие функции SUM, AVG, COUNT, MAX и MIN.
--    Операция аналитика: анализ количества проданных единиц и выручки по товарам.
--    AVG/MAX/MIN применяются к количеству в дневных записях о продажах.
SELECT p.product_name,
       SUM(s.quantity) AS total_units_sold,
       SUM(s.quantity * s.sale_price) AS revenue_rub,
       ROUND(AVG(s.quantity), 2) AS average_units_per_record,
       COUNT(*) AS number_of_sales_records,
       MAX(s.quantity) AS max_units_in_record,
       MIN(s.quantity) AS min_units_in_record
FROM sales AS s
JOIN products AS p ON p.product_id = s.product_id
WHERE s.sale_date BETWEEN '2026-10-01' AND '2026-10-03'
GROUP BY p.product_id, p.product_name
ORDER BY revenue_rub DESC;

-- 4. GROUP BY по категориям. Операция аналитика: анализ количества продаж
--    и выручки по категориям товаров.
SELECT cat.category_name,
       SUM(s.quantity) AS total_units_sold,
       SUM(s.quantity * s.sale_price) AS revenue_rub
FROM sales AS s
JOIN products AS p ON p.product_id = s.product_id
JOIN categories AS cat ON cat.category_id = p.category_id
WHERE s.sale_date BETWEEN '2026-10-01' AND '2026-10-03'
GROUP BY cat.category_id, cat.category_name
ORDER BY revenue_rub DESC;

-- 5. GROUP BY и HAVING. Операция директора: сравнение количества продаж
--    и выручки по кофейням за выбранный период.
--    HAVING оставляет кофейни, по которым за период есть записи о продажах;
--    произвольный порог выручки не вводится.
SELECT c.shop_name,
       SUM(s.quantity) AS total_units_sold,
       SUM(s.quantity * s.sale_price) AS revenue_rub
FROM coffee_shops AS c
LEFT JOIN sales AS s
       ON s.shop_id = c.shop_id
      AND s.sale_date BETWEEN '2026-10-01' AND '2026-10-03'
GROUP BY c.shop_id, c.shop_name
HAVING COUNT(s.product_id) > 0
ORDER BY revenue_rub DESC;
