#!/bin/bash

set -e

echo "=========================================="
echo "  Исправление пароля базы данных"
echo "=========================================="

if [ "$EUID" -ne 0 ]; then 
    echo "Пожалуйста, запустите скрипт с правами sudo: sudo bash fix-db-password.sh"
    exit 1
fi

PROJECT_DIR="/var/www/eshop"
MYSQL_ROOT_PASSWORD="123qweasd"

echo ""
echo "1. Проверка текущей конфигурации БД..."
echo "-----------------------------------"
if [ -f "${PROJECT_DIR}/core/init.php" ]; then
    echo "Текущая конфигурация:"
    grep -A 4 "const DB" ${PROJECT_DIR}/core/init.php
else
    echo "✗ Файл init.php не найден!"
    exit 1
fi

echo ""
echo "2. Обновление пароля в конфигурации..."
echo "-----------------------------------"
# Создаем резервную копию
cp ${PROJECT_DIR}/core/init.php ${PROJECT_DIR}/core/init.php.backup

# Обновляем пароль
sed -i "s/'PASS' => '[^']*',/'PASS' => '${MYSQL_ROOT_PASSWORD}',/" ${PROJECT_DIR}/core/init.php

echo "✓ Пароль обновлен"

echo ""
echo "3. Проверка обновленной конфигурации..."
echo "-----------------------------------"
grep -A 4 "const DB" ${PROJECT_DIR}/core/init.php

echo ""
echo "4. Проверка подключения к MySQL..."
echo "-----------------------------------"
if mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "SELECT 1;" 2>/dev/null; then
    echo "✓ Подключение с паролем работает"
elif sudo mysql -e "SELECT 1;" 2>/dev/null; then
    echo "✓ Подключение через sudo работает"
    echo "Настройка пароля через sudo..."
    sudo mysql <<MYSQL_SCRIPT
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
    echo "✓ Пароль установлен"
else
    echo "⚠ Не удалось подключиться к MySQL"
    echo "Проверьте что MySQL запущен: sudo systemctl status mysql"
fi

echo ""
echo "5. Проверка подключения к базе данных eshop..."
echo "-----------------------------------"
if mysql -u root -p${MYSQL_ROOT_PASSWORD} eshop -e "SELECT 1;" 2>/dev/null; then
    echo "✓ Подключение к базе данных eshop работает"
else
    echo "⚠ Не удалось подключиться к базе данных eshop"
    echo "Проверьте что база данных создана:"
    echo "  mysql -u root -p${MYSQL_ROOT_PASSWORD} -e 'SHOW DATABASES;'"
fi

echo ""
echo "6. Перезапуск Apache..."
systemctl restart apache2

echo ""
echo "=========================================="
echo "  Исправление завершено!"
echo "=========================================="
echo "Пароль БД установлен: ${MYSQL_ROOT_PASSWORD}"
echo "Проверьте сайт в браузере"
echo "=========================================="

