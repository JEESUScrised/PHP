#!/bin/bash

set -e

echo "=========================================="
echo "  Исправление страницы /skull"
echo "=========================================="

if [ "$EUID" -ne 0 ]; then 
    echo "Пожалуйста, запустите скрипт с правами sudo: sudo bash fix-skull.sh"
    exit 1
fi

PROJECT_DIR="/var/www/eshop"
TEMP_DIR="/tmp/kt3_fix_skull_$$"

echo ""
echo "1. Клонирование репозитория..."
cd /tmp
rm -rf ${TEMP_DIR}
git clone https://github.com/JEESUScrised/PHP.git -b kt3 ${TEMP_DIR}

echo ""
echo "2. Обновление index.php..."
cp ${TEMP_DIR}/eshop/index.php ${PROJECT_DIR}/index.php
chown www-data:www-data ${PROJECT_DIR}/index.php
chmod 644 ${PROJECT_DIR}/index.php
echo "✓ index.php обновлен"

echo ""
echo "3. Обновление skull.php..."
cp ${TEMP_DIR}/eshop/app/skull.php ${PROJECT_DIR}/app/skull.php
chown www-data:www-data ${PROJECT_DIR}/app/skull.php
chmod 644 ${PROJECT_DIR}/app/skull.php
echo "✓ skull.php обновлен"

echo ""
echo "4. Проверка и копирование frames.js..."
if [ -f "${TEMP_DIR}/skull/frames.js" ]; then
    mkdir -p ${PROJECT_DIR}/skull
    cp ${TEMP_DIR}/skull/frames.js ${PROJECT_DIR}/skull/frames.js
    chown -R www-data:www-data ${PROJECT_DIR}/skull
    chmod 644 ${PROJECT_DIR}/skull/frames.js
    echo "✓ frames.js скопирован в ${PROJECT_DIR}/skull/"
    
    # Проверка размера файла
    FILE_SIZE=$(stat -c%s "${PROJECT_DIR}/skull/frames.js" 2>/dev/null || echo "0")
    echo "  Размер файла: $FILE_SIZE байт"
    if [ "$FILE_SIZE" -lt "1000" ]; then
        echo "⚠ ВНИМАНИЕ: Файл frames.js слишком маленький!"
    fi
else
    echo "⚠ frames.js не найден в репозитории!"
fi

echo ""
echo "5. Проверка синтаксиса PHP..."
php -l ${PROJECT_DIR}/index.php
php -l ${PROJECT_DIR}/app/skull.php

echo ""
echo "6. Проверка путей к frames.js..."
echo "Проверяемые пути:"
echo "  ${PROJECT_DIR}/skull/frames.js"
if [ -f "${PROJECT_DIR}/skull/frames.js" ]; then
    echo "  ✓ Файл существует"
else
    echo "  ✗ Файл НЕ существует!"
fi

echo ""
echo "7. Тест прямого выполнения skull.php..."
cd ${PROJECT_DIR}
php app/skull.php 2>&1 | head -30 || echo "Ошибка выполнения"

echo ""
echo "8. Перезапуск Apache..."
systemctl restart apache2
sleep 2

echo ""
echo "9. Проверка ответа сервера..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/skull 2>/dev/null || echo "000")
echo "HTTP код для /skull: $HTTP_CODE"

if [ "$HTTP_CODE" = "200" ]; then
    echo "✓ Страница /skull работает!"
elif [ "$HTTP_CODE" = "500" ]; then
    echo "⚠ Все еще ошибка 500. Проверьте логи:"
    echo "  tail -20 /var/log/apache2/eshop_error.log"
    tail -20 /var/log/apache2/eshop_error.log 2>/dev/null | grep -A 5 "skull" || tail -5 /var/log/apache2/eshop_error.log
else
    echo "⚠ HTTP код: $HTTP_CODE"
fi

echo ""
echo "10. Очистка временных файлов..."
rm -rf ${TEMP_DIR}

echo ""
echo "=========================================="
echo "  Исправление завершено!"
echo "=========================================="
echo "Проверьте страницу: http://jeesuscrised.ru/skull"
echo "=========================================="

