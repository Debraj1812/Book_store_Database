DROP DATABASE IF EXISTS bookstore_db;
CREATE DATABASE bookstore_db;
USE bookstore_db;

create table books (
    book_id int auto_increment primary key,
    title varchar(100) not null,
    author varchar(80) not null,
    category_id int not null,
    price decimal(8,2) not null check (price > 0),
    stock int default 0 not null check (stock >= 0),
    published_year int,
    foreign key (category_id) references categories(category_id)
);

create table customers (
    customer_id int auto_increment primary key,
    full_name varchar(80) not null,
    email varchar(100) not null unique,
    city varchar(50) not null,
    created_at timestamp default current_timestamp
);

create table orders (
    order_id int auto_increment primary key,
    customer_id int not null,
    order_date datetime default current_timestamp,
    status enum('PLACED', 'SHIPPED', 'CANCELLED') not null default 'PLACED',
    foreign key (customer_id) references customers(customer_id)
);

create table order_items (
    item_id int auto_increment primary key,
    order_id int not null,
    book_id int not null,
    quantity int not null check (quantity > 0),
    unit_price decimal(8,2) not null default 0.00,
    foreign key (order_id) references orders(order_id) on delete cascade,
    foreign key (book_id) references books(book_id)
);

create table stock_log (
    log_id int auto_increment primary key,
    book_id int not null,
    change_qty int not null,
    reason varchar(60),
    logged_at timestamp default current_timestamp
);

create table price_audit (
    audit_id int auto_increment primary key,
    book_id int not null,
    old_price decimal(8,2) not null,
    new_price decimal(8,2) not null,
    changed_at timestamp default current_timestamp
);

SHOW TABLES;

CREATE INDEX idx_books_title   ON books(title);
CREATE INDEX idx_orders_date   ON orders(order_date);
CREATE INDEX idx_customers_city ON customers(city);
SELECT index_name, column_name
FROM information_schema.statistics
WHERE table_schema = 'bookstore_db' AND table_name = 'orders';

INSERT INTO categories (category_name) VALUES
('Programming'), ('Databases'), ('Fiction'), ('Biography'),
('Self-Help'), ('Data Science'), ('History');
INSERT INTO books (title, author, category_id, price, stock, published_year) VALUES
('Python Crash Course',        'Eric Matthes',                    1, 599.00, 40, 2023),
('Learning SQL',               'Alan Beaulieu',                   2, 550.00, 30, 2020),
('Wings of Fire',              'A. P. J. Abdul Kalam',            4, 250.00, 50, 1999),
('The Alchemist',              'Paulo Coelho',                    3, 299.00, 45, 1988),
('Pather Panchali',            'Bibhutibhushan Bandyopadhyay',    3, 220.00, 25, 1929),
('Clean Code',                 'Robert C. Martin',                1, 650.00, 20, 2008),
('Atomic Habits',              'James Clear',                     5, 399.00, 60, 2018),
('Data Science from Scratch',  'Joel Grus',                       6, 720.00, 15, 2019),
('Feluda Samagra',             'Satyajit Ray',                    3, 350.00, 35, 1992),
('Ikigai',                     'Hector Garcia',                   5, 280.00, 40, 2016),
('SQL Cookbook',               'Anthony Molinaro',                2, 680.00, 18, 2005),
('The Discovery of India',     'Jawaharlal Nehru',                7, 450.00, 22, 1946);
INSERT INTO customers (full_name, email, city) VALUES
('Ananya Sen',     'ananya.sen@example.com',     'Kolkata'),
('Rahul Das',      'rahul.das@example.com',      'Howrah'),
('Priya Ghosh',    'priya.ghosh@example.com',    'Kolkata'),
('Arjun Mitra',    'arjun.mitra@example.com',    'Durgapur'),
('Sneha Roy',      'sneha.roy@example.com',      'Kolkata'),
('Imran Sheikh',   'imran.sheikh@example.com',   'Siliguri'),
('Debjani Paul',   'debjani.paul@example.com',   'Howrah'),
('Rohit Banerjee', 'rohit.banerjee@example.com', 'Kolkata');
SELECT COUNT(*) AS total_books FROM books;
SELECT COUNT(*) AS total_customers FROM customers; 

DELIMITER 
CREATE TRIGGER trg_items_before_insert
BEFORE INSERT ON order_items
FOR EACH ROW
BEGIN
    DECLARE v_price DECIMAL(8,2);
    DECLARE v_stock INT;
    SELECT price, stock INTO v_price, v_stock
    FROM books WHERE book_id = NEW.book_id;
    IF v_stock < NEW.quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient stock for this book';
    END IF;
    SET NEW.unit_price = v_price;
END$$
CREATE TRIGGER trg_items_after_insert
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE books SET stock = stock - NEW.quantity
    WHERE book_id = NEW.book_id;
    INSERT INTO stock_log (book_id, change_qty, reason)
    VALUES (NEW.book_id, -NEW.quantity, CONCAT('Order #', NEW.order_id));
END$$
CREATE TRIGGER trg_books_after_update
AFTER UPDATE ON books
FOR EACH ROW
BEGIN
    IF OLD.price <> NEW.price THEN
        INSERT INTO price_audit (book_id, old_price, new_price)
        VALUES (OLD.book_id, OLD.price, NEW.price);
    END IF;
END$$
DELIMITER ;
SELECT trigger_name, event_manipulation AS event, event_object_table AS on_table, action_timing AS timing
FROM information_schema.triggers
WHERE trigger_schema = 'bookstore_db'
ORDER BY trigger_name; 

INSERT INTO orders (customer_id, order_date) VALUES
(1, '2026-08-05 10:30:00'),
(2, '2026-08-18 14:15:00'),
(3, '2026-09-02 09:45:00'),
(1, '2026-09-14 16:20:00'),
(4, '2026-09-21 11:05:00'),
(5, '2026-10-03 13:40:00'),
(6, '2026-10-12 18:10:00'),
(2, '2026-10-25 12:00:00'),
(7, '2026-11-02 15:30:00'),
(3, '2026-11-08 17:45:00');
INSERT INTO order_items (order_id, book_id, quantity) VALUES
(1, 1, 1), (1, 2, 1),
(2, 7, 2),
(3, 3, 1), (3, 4, 1), (3, 10, 1),
(4, 6, 1),
(5, 8, 1), (5, 11, 1),
(6, 5, 2), (6, 9, 1),
(7, 7, 1), (7, 12, 1),
(8, 1, 2),
(9, 2, 1), (9, 4, 2),
(10, 7, 3);
SELECT * FROM order_items;
SELECT book_id, title, stock FROM books ORDER BY book_id;

SELECT title, author, price
FROM books
WHERE price BETWEEN 300 AND 600;
SELECT book_id, title FROM books WHERE title LIKE '%SQL%';
SELECT DISTINCT city FROM customers;
SELECT b.title, c.category_name, b.price
FROM books b
JOIN categories c ON c.category_id = b.category_id
WHERE c.category_name IN ('Programming', 'Databases');
SELECT o.order_id, cu.full_name, o.order_date, o.status
FROM orders o
JOIN customers cu ON cu.customer_id = o.customer_id
WHERE o.order_date >= '2026-10-01';

SELECT title, price FROM books ORDER BY price DESC LIMIT 5;
SELECT c.category_name, b.title
FROM books b
JOIN categories c ON c.category_id = b.category_id
ORDER BY c.category_name ASC, b.title ASC;

SELECT city, COUNT(*) AS customers
FROM customers
GROUP BY city
ORDER BY customers DESC, city;
SELECT c.category_name, COUNT(*) AS titles, ROUND(AVG(b.price), 2) AS avg_price
FROM books b
JOIN categories c ON c.category_id = b.category_id
GROUP BY c.category_name
ORDER BY titles DESC, c.category_name;
SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
       SUM(oi.quantity * oi.unit_price)  AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY sales_month
ORDER BY sales_month;
SELECT cu.full_name, SUM(oi.quantity * oi.unit_price) AS total_spent
FROM customers cu
JOIN orders o       ON o.customer_id = cu.customer_id
JOIN order_items oi ON oi.order_id   = o.order_id
GROUP BY cu.customer_id, cu.full_name
HAVING total_spent > 1000
ORDER BY total_spent DESC;
SELECT b.title, SUM(oi.quantity) AS units_sold
FROM order_items oi
JOIN books b ON b.book_id = oi.book_id
GROUP BY b.book_id, b.title
ORDER BY units_sold DESC, b.title
LIMIT 5;
SELECT cu.customer_id, cu.full_name
FROM customers cu
LEFT JOIN orders o ON o.customer_id = cu.customer_id
WHERE o.order_id IS NULL;

update orders
set status = 'SHIPPED'
where order_id between 1 and 7;
update books
set price = round(price * 1.10, 2)
where category_id = (
    select category_id
    from categories
    where category_name = 'Programming'
);
update books
set stock = stock + 25
where stock < 20
and book_id > 0;
select status, count(*) as orders
from orders
group by status;
select * from price_audit;
select book_id, title, price, stock
from books
where book_id in (1, 6, 8, 11);

INSERT INTO books (title, author, category_id, price, stock, published_year)
VALUES ('Demo Book (to delete)', 'Test Author', 1, 100.00, 5, 2026);
DELETE FROM books WHERE book_id = LAST_INSERT_ID();
SELECT COUNT(*) AS books_after_delete FROM books;

CREATE VIEW v_order_summary AS
SELECT o.order_id,
       cu.full_name,
       cu.city,
       o.order_date,
       o.status,
       SUM(oi.quantity)                 AS total_items,
       SUM(oi.quantity * oi.unit_price) AS order_total
FROM orders o
JOIN customers cu   ON cu.customer_id = o.customer_id
JOIN order_items oi ON oi.order_id    = o.order_id
GROUP BY o.order_id, cu.full_name, cu.city, o.order_date, o.status;
CREATE VIEW v_category_sales AS
SELECT c.category_name,
       SUM(oi.quantity)                 AS units_sold,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM order_items oi
JOIN books b    ON b.book_id     = oi.book_id
JOIN categories c ON c.category_id = b.category_id
GROUP BY c.category_name;
CREATE VIEW v_low_stock AS
SELECT book_id, title, stock FROM books WHERE stock < 25;
SELECT * FROM v_order_summary ORDER BY order_id;
SELECT * FROM v_category_sales ORDER BY revenue DESC;
SELECT * FROM v_low_stock ORDER BY stock;

START TRANSACTION;
INSERT INTO orders (customer_id) VALUES (8);
SET @new_order = LAST_INSERT_ID();
INSERT INTO order_items (order_id, book_id, quantity) VALUES (@new_order, 2, 1);
SAVEPOINT after_first_item;
INSERT INTO order_items (order_id, book_id, quantity) VALUES (@new_order, 6, 1);
ROLLBACK TO SAVEPOINT after_first_item;
COMMIT;
SELECT oi.order_id, b.title, oi.quantity, oi.unit_price
FROM order_items oi
JOIN books b ON b.book_id = oi.book_id
WHERE oi.order_id = @new_order;
START TRANSACTION;
INSERT INTO orders (customer_id) VALUES (8);
INSERT INTO order_items (order_id, book_id, quantity)
VALUES (LAST_INSERT_ID(), 8, 999);
ROLLBACK;
SELECT COUNT(*) AS orders_of_customer_8 FROM orders WHERE customer_id = 8;
SELECT book_id, title, stock FROM books WHERE book_id IN (2, 6, 8);

SELECT * FROM stock_log ORDER BY log_id DESC LIMIT 6;
SELECT COUNT(*) AS stock_log_rows FROM stock_log;

SELECT 'book_id', 'title', 'author', 'price', 'stock'
UNION ALL
SELECT book_id, title, author, price, stock FROM books
INTO OUTFILE '/var/lib/mysql-files/books_export.csv'
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n';

LOAD DATA INFILE '/var/lib/mysql-files/new_books.csv'
INTO TABLE books
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(title, author, category_id, price, stock, published_year);
SELECT book_id, title, price, stock FROM books WHERE book_id > 12;
SELECT COUNT(*) AS total_books FROM books;