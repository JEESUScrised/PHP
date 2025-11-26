-- Создание базы данных eshop
CREATE DATABASE IF NOT EXISTS eshop CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE eshop;

-- Таблица catalog
CREATE TABLE IF NOT EXISTS catalog (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    pubyear INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Таблица orders
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(50) UNIQUE NOT NULL,
    customer VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    address TEXT NOT NULL,
    created DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Таблица ordered_items
CREATE TABLE IF NOT EXISTS ordered_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id VARCHAR(50) NOT NULL,
    item_id INT NOT NULL,
    quantity INT NOT NULL,
    FOREIGN KEY (item_id) REFERENCES catalog(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Таблица admins
CREATE TABLE IF NOT EXISTS admins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    login VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    created DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Хранимая процедура spAddItemToCatalog
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS spAddItemToCatalog(
    IN p_title VARCHAR(255),
    IN p_author VARCHAR(255),
    IN p_price DECIMAL(10, 2),
    IN p_pubyear INT
)
BEGIN
    INSERT INTO catalog (title, author, price, pubyear)
    VALUES (p_title, p_author, p_price, p_pubyear);
END //
DELIMITER ;

-- Хранимая процедура spGetCatalog
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS spGetCatalog()
BEGIN
    SELECT id, title, author, price, pubyear FROM catalog ORDER BY id;
END //
DELIMITER ;

-- Хранимая процедура spGetItemsForBasket
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS spGetItemsForBasket(
    IN p_item_ids TEXT
)
BEGIN
    SET @sql = CONCAT('SELECT id, title, author, price, pubyear FROM catalog WHERE id IN (', p_item_ids, ')');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
DELIMITER ;

-- Хранимая процедура spSaveOrder
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS spSaveOrder(
    IN p_order_id VARCHAR(50),
    IN p_customer VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_phone VARCHAR(50),
    IN p_address TEXT
)
BEGIN
    INSERT INTO orders (order_id, customer, email, phone, address, created)
    VALUES (p_order_id, p_customer, p_email, p_phone, p_address, NOW());
END //
DELIMITER ;

-- Хранимая процедура spSaveOrderedItems
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS spSaveOrderedItems(
    IN p_order_id VARCHAR(50),
    IN p_item_id INT,
    IN p_quantity INT
)
BEGIN
    INSERT INTO ordered_items (order_id, item_id, quantity)
    VALUES (p_order_id, p_item_id, p_quantity);
END //
DELIMITER ;

-- Хранимая процедура spGetOrders
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS spGetOrders()
BEGIN
    SELECT id, order_id, customer, email, phone, address, created FROM orders ORDER BY created DESC;
END //
DELIMITER ;

-- Хранимая процедура spGetOrderedItems
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS spGetOrderedItems(
    IN p_order_id VARCHAR(50)
)
BEGIN
    SELECT oi.id, oi.order_id, oi.item_id, oi.quantity, 
           c.title, c.author, c.price, c.pubyear
    FROM ordered_items oi
    INNER JOIN catalog c ON oi.item_id = c.id
    WHERE oi.order_id = p_order_id;
END //
DELIMITER ;

-- Хранимая процедура spSaveAdmin
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS spSaveAdmin(
    IN p_login VARCHAR(50),
    IN p_password VARCHAR(255),
    IN p_email VARCHAR(255)
)
BEGIN
    INSERT INTO admins (login, password, email, created)
    VALUES (p_login, p_password, p_email, NOW());
END //
DELIMITER ;

-- Хранимая процедура spGetAdmin
DELIMITER //
CREATE PROCEDURE IF NOT EXISTS spGetAdmin(
    IN p_login VARCHAR(50)
)
BEGIN
    SELECT id, login, password, email, created FROM admins WHERE login = p_login LIMIT 1;
END //
DELIMITER ;
