#!/bin/bash

set -e

echo "=========================================="
echo "  Исправление всех страниц"
echo "=========================================="

if [ "$EUID" -ne 0 ]; then 
    echo "Пожалуйста, запустите скрипт с правами sudo: sudo bash fix-all-pages.sh"
    exit 1
fi

PROJECT_DIR="/var/www/eshop"
TEMP_DIR="/tmp/kt3_fix_all_$$"

echo ""
echo "1. Клонирование репозитория..."
cd /tmp
rm -rf ${TEMP_DIR}
git clone https://github.com/JEESUScrised/PHP.git -b kt3 ${TEMP_DIR}

echo ""
echo "2. Обновление init.php с явными require..."
cp ${TEMP_DIR}/eshop/core/init.php ${PROJECT_DIR}/core/init.php
chown www-data:www-data ${PROJECT_DIR}/core/init.php
chmod 644 ${PROJECT_DIR}/core/init.php
echo "✓ init.php обновлен"

echo ""
echo "3. Обновление index.php..."
cp ${TEMP_DIR}/eshop/index.php ${PROJECT_DIR}/index.php
chown www-data:www-data ${PROJECT_DIR}/index.php
chmod 644 ${PROJECT_DIR}/index.php
echo "✓ index.php обновлен"

echo ""
echo "4. Обновление skull.php..."
cp ${TEMP_DIR}/eshop/app/skull.php ${PROJECT_DIR}/app/skull.php
chown www-data:www-data ${PROJECT_DIR}/app/skull.php
chmod 644 ${PROJECT_DIR}/app/skull.php
echo "✓ skull.php обновлен"

echo ""
echo "5. Копирование frames.js..."
if [ -d "${TEMP_DIR}/skull" ]; then
    mkdir -p ${PROJECT_DIR}/skull
    cp ${TEMP_DIR}/skull/frames.js ${PROJECT_DIR}/skull/frames.js 2>/dev/null || echo "⚠ frames.js не найден в репозитории"
    chown -R www-data:www-data ${PROJECT_DIR}/skull
    echo "✓ frames.js скопирован"
else
    echo "⚠ Папка skull не найдена в репозитории"
fi

echo ""
echo "6. Проверка синтаксиса..."
php -l ${PROJECT_DIR}/core/init.php
php -l ${PROJECT_DIR}/index.php
php -l ${PROJECT_DIR}/app/skull.php

echo ""
echo "7. Перезапуск Apache..."
systemctl restart apache2

echo ""
echo "8. Проверка ответа сервера..."
sleep 2
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/catalog 2>/dev/null || echo "000")
echo "HTTP код для /catalog: $HTTP_CODE"

if [ "$HTTP_CODE" = "200" ]; then
    echo "✓ Страница /catalog работает"
elif [ "$HTTP_CODE" = "302" ]; then
    echo "✓ Страница /catalog работает (редирект)"
else
    echo "⚠ Проблема с /catalog (код: $HTTP_CODE)"
fi

echo ""
echo "9. Очистка временных файлов..."
rm -rf ${TEMP_DIR}

echo ""
echo "=========================================="
echo "  Исправление завершено!"
echo "=========================================="
echo "Проверьте сайт в браузере"
echo "=========================================="

