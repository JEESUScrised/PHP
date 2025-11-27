#!/bin/bash

echo "=========================================="
echo "  Проверка ошибок на сервере"
echo "=========================================="

if [ "$EUID" -ne 0 ]; then 
    echo "Пожалуйста, запустите скрипт с правами sudo: sudo bash check-errors.sh"
    exit 1
fi

echo ""
echo "1. Последние ошибки Apache..."
echo "-----------------------------------"
tail -30 /var/log/apache2/error.log

echo ""
echo "2. Последние ошибки проекта..."
echo "-----------------------------------"
tail -30 /var/log/apache2/eshop_error.log 2>/dev/null || echo "Лог недоступен"

echo ""
echo "3. Проверка синтаксиса PHP файлов..."
echo "-----------------------------------"
php -l /var/www/eshop/app/skull.php
php -l /var/www/eshop/index.php
php -l /var/www/eshop/core/init.php

echo ""
echo "4. Проверка прав доступа..."
echo "-----------------------------------"
ls -la /var/www/eshop/app/skull.php

echo ""
echo "5. Тест прямого выполнения skull.php..."
echo "-----------------------------------"
cd /var/www/eshop
php app/skull.php 2>&1 | head -20

echo ""
echo "=========================================="

