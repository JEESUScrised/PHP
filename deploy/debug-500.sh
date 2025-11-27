#!/bin/bash

echo "=========================================="
echo "  Диагностика ошибки 500"
echo "=========================================="

if [ "$EUID" -ne 0 ]; then 
    echo "Пожалуйста, запустите скрипт с правами sudo: sudo bash debug-500.sh"
    exit 1
fi

PROJECT_DIR="/var/www/eshop"

echo ""
echo "1. Проверка последних ошибок Apache..."
echo "-----------------------------------"
tail -30 /var/log/apache2/error.log

echo ""
echo "2. Проверка ошибок PHP..."
echo "-----------------------------------"
tail -30 /var/log/apache2/eshop_error.log 2>/dev/null || echo "Лог eshop_error.log не найден"

echo ""
echo "3. Проверка прав доступа..."
echo "-----------------------------------"
ls -la ${PROJECT_DIR}/ | head -10
echo ""
echo "Права на index.php:"
ls -la ${PROJECT_DIR}/index.php

echo ""
echo "4. Проверка конфигурации PHP..."
echo "-----------------------------------"
php -v
php -m | grep -E "(pdo|mysql|mysqli)"

echo ""
echo "5. Проверка подключения к БД..."
echo "-----------------------------------"
if [ -f "${PROJECT_DIR}/core/init.php" ]; then
    echo "Конфигурация БД:"
    grep -A 4 "const DB" ${PROJECT_DIR}/core/init.php
    echo ""
    echo "Проверка подключения:"
    mysql -u root -p123qweasd -e "SELECT 1;" 2>&1 | head -3
else
    echo "⚠ Файл init.php не найден!"
fi

echo ""
echo "6. Проверка синтаксиса PHP..."
echo "-----------------------------------"
php -l ${PROJECT_DIR}/index.php 2>&1 || echo "Ошибка синтаксиса в index.php"

echo ""
echo "7. Тест прямого выполнения PHP..."
echo "-----------------------------------"
cd ${PROJECT_DIR}
php -r "echo 'PHP работает\n';" 2>&1

echo ""
echo "8. Проверка .htaccess..."
echo "-----------------------------------"
if [ -f "${PROJECT_DIR}/.htaccess" ]; then
    echo "✓ .htaccess существует"
    cat ${PROJECT_DIR}/.htaccess
else
    echo "⚠ .htaccess не найден!"
fi

echo ""
echo "9. Проверка модулей Apache..."
echo "-----------------------------------"
apache2ctl -M | grep -E "(php|rewrite)"

echo ""
echo "=========================================="
echo "  Рекомендации:"
echo "=========================================="
echo "1. Проверьте логи выше на наличие ошибок"
echo "2. Убедитесь что PHP модули установлены:"
echo "   sudo apt-get install php php-mysql php-mbstring php-xml"
echo "3. Проверьте права доступа:"
echo "   sudo chown -R www-data:www-data ${PROJECT_DIR}"
echo "   sudo chmod -R 755 ${PROJECT_DIR}"
echo "4. Проверьте что база данных создана и доступна"
echo "=========================================="

