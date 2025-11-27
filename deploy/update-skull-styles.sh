#!/bin/bash

set -e

echo "=========================================="
echo "  Обновление стилей страницы skull"
echo "=========================================="

if [ "$EUID" -ne 0 ]; then 
    echo "Пожалуйста, запустите скрипт с правами sudo: sudo bash update-skull-styles.sh"
    exit 1
fi

PROJECT_DIR="/var/www/eshop"
TEMP_DIR="/tmp/kt3_skull_$$"

echo ""
echo "1. Клонирование репозитория..."
cd /tmp
rm -rf ${TEMP_DIR}
git clone https://github.com/JEESUScrised/PHP.git -b kt3 ${TEMP_DIR}

echo ""
echo "2. Обновление skull.php..."
if [ -f "${TEMP_DIR}/eshop/app/skull.php" ]; then
    cp ${TEMP_DIR}/eshop/app/skull.php ${PROJECT_DIR}/app/skull.php
    chown www-data:www-data ${PROJECT_DIR}/app/skull.php
    chmod 644 ${PROJECT_DIR}/app/skull.php
    echo "✓ skull.php обновлен"
else
    echo "✗ Файл skull.php не найден в репозитории!"
    exit 1
fi

echo ""
echo "3. Проверка синтаксиса..."
php -l ${PROJECT_DIR}/app/skull.php

echo ""
echo "4. Проверка что стили встроены..."
if grep -q "background: #000000 !important" ${PROJECT_DIR}/app/skull.php; then
    echo "✓ Стили найдены в файле"
else
    echo "⚠ Стили не найдены!"
fi

echo ""
echo "5. Перезапуск Apache..."
systemctl restart apache2

echo ""
echo "6. Очистка временных файлов..."
rm -rf ${TEMP_DIR}

echo ""
echo "=========================================="
echo "  Обновление завершено!"
echo "=========================================="
echo "Обновите страницу в браузере (Ctrl+F5 для очистки кэша)"
echo "=========================================="

