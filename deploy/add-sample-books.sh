#!/bin/bash

set -e

echo "=========================================="
echo "  Добавление тестовых книг в каталог"
echo "=========================================="

if [ "$EUID" -ne 0 ]; then 
    echo "Пожалуйста, запустите скрипт с правами sudo: sudo bash add-sample-books.sh"
    exit 1
fi

MYSQL_ROOT_PASSWORD="123qweasd"
DB_NAME="eshop"

echo ""
echo "Добавление 5 книг в каталог..."
echo "-----------------------------------"

mysql -u root -p${MYSQL_ROOT_PASSWORD} ${DB_NAME} << 'SQL'
INSERT INTO catalog (title, author, price, pubyear) VALUES
('Война и мир', 'Лев Толстой', 899.00, 1869),
('Преступление и наказание', 'Фёдор Достоевский', 649.00, 1866),
('Мастер и Маргарита', 'Михаил Булгаков', 799.00, 1967),
('1984', 'Джордж Оруэлл', 599.00, 1949),
('Гарри Поттер и философский камень', 'Джоан Роулинг', 899.00, 1997)
ON DUPLICATE KEY UPDATE title=title;
SQL

if [ $? -eq 0 ]; then
    echo "✓ Книги успешно добавлены"
else
    echo "⚠ Ошибка при добавлении. Попытка через sudo..."
    sudo mysql ${DB_NAME} << 'SQL'
INSERT INTO catalog (title, author, price, pubyear) VALUES
('Война и мир', 'Лев Толстой', 899.00, 1869),
('Преступление и наказание', 'Фёдор Достоевский', 649.00, 1866),
('Мастер и Маргарита', 'Михаил Булгаков', 799.00, 1967),
('1984', 'Джордж Оруэлл', 599.00, 1949),
('Гарри Поттер и философский камень', 'Джоан Роулинг', 899.00, 1997)
ON DUPLICATE KEY UPDATE title=title;
SQL
fi

echo ""
echo "Проверка добавленных книг..."
echo "-----------------------------------"
mysql -u root -p${MYSQL_ROOT_PASSWORD} ${DB_NAME} -e "SELECT id, title, author, price, pubyear FROM catalog;" 2>/dev/null || \
sudo mysql ${DB_NAME} -e "SELECT id, title, author, price, pubyear FROM catalog;"

echo ""
echo "=========================================="
echo "  Готово!"
echo "=========================================="
echo "Книги добавлены в каталог"
echo "Обновите страницу каталога в браузере"
echo "=========================================="

