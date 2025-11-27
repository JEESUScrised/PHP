#!/bin/bash

echo "=========================================="
echo "  Проверка конфигурации базы данных"
echo "=========================================="

if [ "$EUID" -ne 0 ]; then 
    echo "Пожалуйста, запустите скрипт с правами sudo: sudo bash check-db-config.sh"
    exit 1
fi

PROJECT_DIR="/var/www/eshop"
MYSQL_ROOT_PASSWORD="123qweasd"

echo ""
echo "1. Проверка конфигурации в init.php..."
echo "-----------------------------------"
if [ -f "${PROJECT_DIR}/core/init.php" ]; then
    echo "Конфигурация БД:"
    grep -A 5 "const DB" ${PROJECT_DIR}/core/init.php | head -6
    
    PASS_LINE=$(grep "'PASS'" ${PROJECT_DIR}/core/init.php)
    echo ""
    echo "Строка с паролем:"
    echo "$PASS_LINE"
    
    # Проверяем что пароль не пустой
    if echo "$PASS_LINE" | grep -q "'PASS' => ''"; then
        echo "⚠ ОШИБКА: Пароль пустой!"
    elif echo "$PASS_LINE" | grep -q "'PASS' => '[^']*'"; then
        echo "✓ Пароль установлен"
    else
        echo "⚠ ОШИБКА: Неверный формат пароля!"
    fi
else
    echo "✗ Файл init.php не найден!"
    exit 1
fi

echo ""
echo "2. Исправление пароля..."
echo "-----------------------------------"
# Создаем резервную копию
cp ${PROJECT_DIR}/core/init.php ${PROJECT_DIR}/core/init.php.backup.$(date +%Y%m%d_%H%M%S)

# Обновляем пароль - несколько вариантов замены
sed -i "s/'PASS' => '',/'PASS' => '${MYSQL_ROOT_PASSWORD}',/" ${PROJECT_DIR}/core/init.php
sed -i "s/'PASS' => '[^']*',/'PASS' => '${MYSQL_ROOT_PASSWORD}',/" ${PROJECT_DIR}/core/init.php

echo "✓ Пароль обновлен"

echo ""
echo "3. Проверка обновленной конфигурации..."
echo "-----------------------------------"
grep -A 5 "const DB" ${PROJECT_DIR}/core/init.php | head -6

echo ""
echo "4. Проверка подключения к MySQL..."
echo "-----------------------------------"
if mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "SELECT 1;" 2>/dev/null; then
    echo "✓ Подключение с паролем работает"
elif sudo mysql -e "SELECT 1;" 2>/dev/null; then
    echo "⚠ Подключение работает только через sudo (без пароля)"
    echo "Настройка пароля..."
    sudo mysql <<MYSQL_SCRIPT
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
    echo "✓ Пароль установлен"
    
    # Проверяем снова
    if mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "SELECT 1;" 2>/dev/null; then
        echo "✓ Теперь подключение с паролем работает"
    fi
else
    echo "✗ Не удалось подключиться к MySQL"
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
echo "  Проверка завершена!"
echo "=========================================="
echo "Пароль БД: ${MYSQL_ROOT_PASSWORD}"
echo "Проверьте сайт в браузере"
echo "=========================================="

