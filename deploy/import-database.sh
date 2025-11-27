#!/bin/bash

set -e

echo "=========================================="
echo "  Импорт структуры базы данных"
echo "=========================================="

if [ "$EUID" -ne 0 ]; then 
    echo "Пожалуйста, запустите скрипт с правами sudo: sudo bash import-database.sh"
    exit 1
fi

PROJECT_DIR="/var/www/eshop"
MYSQL_ROOT_PASSWORD="123qweasd"
DB_NAME="eshop"
SQL_FILE="${PROJECT_DIR}/core/eshop.sql"

echo ""
echo "1. Проверка файла SQL..."
echo "-----------------------------------"
if [ ! -f "$SQL_FILE" ]; then
    echo "✗ Файл $SQL_FILE не найден!"
    echo "Попытка найти файл..."
    if [ -f "/tmp/kt3/eshop/core/eshop.sql" ]; then
        SQL_FILE="/tmp/kt3/eshop/core/eshop.sql"
        echo "✓ Найден: $SQL_FILE"
    else
        echo "✗ Файл не найден. Клонирую репозиторий..."
        cd /tmp
        rm -rf kt3
        git clone https://github.com/JEESUScrised/PHP.git -b kt3 kt3
        if [ -f "kt3/eshop/core/eshop.sql" ]; then
            SQL_FILE="/tmp/kt3/eshop/core/eshop.sql"
            echo "✓ Найден: $SQL_FILE"
        else
            echo "✗ Файл все еще не найден!"
            exit 1
        fi
    fi
else
    echo "✓ Файл найден: $SQL_FILE"
fi

echo ""
echo "2. Проверка подключения к MySQL..."
echo "-----------------------------------"
if mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "SELECT 1;" 2>/dev/null; then
    echo "✓ Подключение к MySQL работает"
else
    echo "✗ Не удалось подключиться к MySQL"
    echo "Попытка через sudo..."
    if sudo mysql -e "SELECT 1;" 2>/dev/null; then
        echo "✓ Подключение через sudo работает"
        MYSQL_CMD="sudo mysql"
    else
        echo "✗ Не удалось подключиться к MySQL"
        exit 1
    fi
else
    MYSQL_CMD="mysql -u root -p${MYSQL_ROOT_PASSWORD}"
fi

echo ""
echo "3. Проверка существования базы данных..."
echo "-----------------------------------"
DB_EXISTS=$(mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "SHOW DATABASES LIKE '${DB_NAME}';" 2>/dev/null | grep -c ${DB_NAME} || echo "0")

if [ "$DB_EXISTS" -eq "0" ]; then
    echo "⚠ База данных ${DB_NAME} не существует. Создаю..."
    mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null || {
        echo "Попытка через sudo..."
        sudo mysql -e "CREATE DATABASE ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    }
    echo "✓ База данных создана"
else
    echo "✓ База данных ${DB_NAME} существует"
fi

echo ""
echo "4. Проверка существующих процедур..."
echo "-----------------------------------"
EXISTING_PROC=$(mysql -u root -p${MYSQL_ROOT_PASSWORD} ${DB_NAME} -e "SHOW PROCEDURE STATUS WHERE Db = '${DB_NAME}' AND Name = 'spGetCatalog';" 2>/dev/null | grep -c spGetCatalog || echo "0")
if [ "$EXISTING_PROC" -gt "0" ]; then
    echo "⚠ Процедура spGetCatalog уже существует"
    read -p "Пересоздать базу данных? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Удаление базы данных..."
        mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "DROP DATABASE IF EXISTS ${DB_NAME};" 2>/dev/null || sudo mysql -e "DROP DATABASE IF EXISTS ${DB_NAME};"
        echo "Создание базы данных..."
        mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null || sudo mysql -e "CREATE DATABASE ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    else
        echo "Пропуск импорта"
        exit 0
    fi
fi

echo ""
echo "5. Импорт структуры базы данных..."
echo "-----------------------------------"
if mysql -u root -p${MYSQL_ROOT_PASSWORD} ${DB_NAME} < ${SQL_FILE} 2>/dev/null; then
    echo "✓ Импорт выполнен успешно"
elif sudo mysql ${DB_NAME} < ${SQL_FILE} 2>/dev/null; then
    echo "✓ Импорт выполнен успешно (через sudo)"
else
    echo "✗ Ошибка импорта. Вывод:"
    mysql -u root -p${MYSQL_ROOT_PASSWORD} ${DB_NAME} < ${SQL_FILE} 2>&1 | head -20
    exit 1
fi

echo ""
echo "6. Проверка импортированных процедур..."
echo "-----------------------------------"
PROCS=$(mysql -u root -p${MYSQL_ROOT_PASSWORD} ${DB_NAME} -e "SHOW PROCEDURE STATUS WHERE Db = '${DB_NAME}';" 2>/dev/null | wc -l || echo "0")
echo "Найдено процедур: $((PROCS - 1))"

TABLES=$(mysql -u root -p${MYSQL_ROOT_PASSWORD} ${DB_NAME} -e "SHOW TABLES;" 2>/dev/null | wc -l || echo "0")
echo "Найдено таблиц: $((TABLES - 1))"

echo ""
echo "7. Проверка процедуры spGetCatalog..."
echo "-----------------------------------"
if mysql -u root -p${MYSQL_ROOT_PASSWORD} ${DB_NAME} -e "SHOW PROCEDURE STATUS WHERE Db = '${DB_NAME}' AND Name = 'spGetCatalog';" 2>/dev/null | grep -q spGetCatalog; then
    echo "✓ Процедура spGetCatalog найдена"
else
    echo "✗ Процедура spGetCatalog НЕ найдена!"
    echo "Проверьте содержимое файла SQL"
fi

echo ""
echo "=========================================="
echo "  Импорт завершен!"
echo "=========================================="
echo "База данных: ${DB_NAME}"
echo "Процедур: $((PROCS - 1))"
echo "Таблиц: $((TABLES - 1))"
echo ""
echo "Проверьте сайт в браузере"
echo "=========================================="

