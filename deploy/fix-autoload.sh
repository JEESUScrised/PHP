#!/bin/bash

set -e

echo "=========================================="
echo "  Исправление автозагрузки классов"
echo "=========================================="

if [ "$EUID" -ne 0 ]; then 
    echo "Пожалуйста, запустите скрипт с правами sudo: sudo bash fix-autoload.sh"
    exit 1
fi

PROJECT_DIR="/var/www/eshop"

echo ""
echo "1. Проверка файла init.php..."
echo "-----------------------------------"
if [ -f "${PROJECT_DIR}/core/init.php" ]; then
    echo "✓ init.php найден"
    echo "Проверка автозагрузки в init.php:"
    grep -A 3 "spl_autoload" ${PROJECT_DIR}/core/init.php || echo "⚠ Автозагрузка не найдена"
else
    echo "✗ init.php не найден!"
    exit 1
fi

echo ""
echo "2. Проверка путей в init.php..."
echo "-----------------------------------"
CORE_DIR_CHECK=$(grep -c "CORE_DIR" ${PROJECT_DIR}/core/init.php || echo "0")
if [ "$CORE_DIR_CHECK" -gt "0" ]; then
    echo "✓ CORE_DIR определен"
    grep "CORE_DIR" ${PROJECT_DIR}/core/init.php | head -1
else
    echo "⚠ CORE_DIR не найден"
fi

echo ""
echo "3. Проверка что файл Eshop.class.php читается..."
echo "-----------------------------------"
if [ -r "${PROJECT_DIR}/core/Eshop.class.php" ]; then
    echo "✓ Файл читается"
    FILE_SIZE=$(stat -c%s "${PROJECT_DIR}/core/Eshop.class.php" 2>/dev/null || echo "0")
    echo "Размер файла: $FILE_SIZE байт"
    if [ "$FILE_SIZE" -gt "0" ]; then
        echo "✓ Файл не пустой"
        # Проверяем что класс определен
        if grep -q "class Eshop" "${PROJECT_DIR}/core/Eshop.class.php"; then
            echo "✓ Класс Eshop найден в файле"
        else
            echo "✗ Класс Eshop НЕ найден в файле!"
        fi
    else
        echo "✗ Файл пустой!"
    fi
else
    echo "✗ Файл не читается!"
fi

echo ""
echo "4. Тест автозагрузки через PHP CLI..."
echo "-----------------------------------"
cd ${PROJECT_DIR}
php -r "
set_include_path(get_include_path() . PATH_SEPARATOR . 'core' . PATH_SEPARATOR . 'app');
spl_autoload_extensions('.class.php');
spl_autoload_register();
if (class_exists('Eshop')) {
    echo '✓ Класс Eshop найден через autoloader\n';
} else {
    echo '✗ Класс Eshop НЕ найден через autoloader\n';
    echo 'Попытка прямого require...\n';
    require_once 'core/Eshop.class.php';
    if (class_exists('Eshop')) {
        echo '✓ Класс Eshop найден после прямого require\n';
    } else {
        echo '✗ Класс Eshop все еще не найден\n';
    }
}
" 2>&1

echo ""
echo "5. Проверка include_path в PHP..."
echo "-----------------------------------"
php -r "echo 'include_path: ' . get_include_path() . PHP_EOL;"

echo ""
echo "6. Исправление init.php - добавление явного require..."
echo "-----------------------------------"
# Создаем резервную копию
cp ${PROJECT_DIR}/core/init.php ${PROJECT_DIR}/core/init.php.backup

# Проверяем, есть ли уже явные require
if ! grep -q "require_once.*Eshop.class.php" ${PROJECT_DIR}/core/init.php; then
    echo "Добавление явного require для классов..."
    # Находим строку с spl_autoload_register и добавляем после неё require
    sed -i '/spl_autoload_register();/a\
\
// Явная загрузка классов для надежности\
require_once __DIR__ . "/Eshop.class.php";\
require_once __DIR__ . "/Book.class.php";\
require_once __DIR__ . "/User.class.php";\
require_once __DIR__ . "/Order.class.php";\
require_once __DIR__ . "/Basket.class.php";' ${PROJECT_DIR}/core/init.php
    
    echo "✓ Явные require добавлены"
else
    echo "✓ Явные require уже есть"
fi

echo ""
echo "7. Проверка синтаксиса init.php..."
echo "-----------------------------------"
php -l ${PROJECT_DIR}/core/init.php

echo ""
echo "8. Перезапуск Apache..."
systemctl restart apache2

echo ""
echo "9. Проверка ответа сервера..."
sleep 2
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost 2>/dev/null || echo "000")
echo "HTTP код: $HTTP_CODE"

if [ "$HTTP_CODE" = "200" ]; then
    echo "✓ Сервер отвечает успешно!"
elif [ "$HTTP_CODE" = "500" ]; then
    echo "⚠ Все еще ошибка 500. Проверьте последние ошибки:"
    echo "  tail -5 /var/log/apache2/eshop_error.log"
    tail -5 /var/log/apache2/eshop_error.log 2>/dev/null || echo "Лог недоступен"
else
    echo "⚠ HTTP код: $HTTP_CODE"
fi

echo ""
echo "=========================================="
echo "  Исправление завершено!"
echo "=========================================="

