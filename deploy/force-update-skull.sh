#!/bin/bash

set -e

echo "=========================================="
echo "  Принудительное обновление страницы skull"
echo "=========================================="

if [ "$EUID" -ne 0 ]; then 
    echo "Пожалуйста, запустите скрипт с правами sudo: sudo bash force-update-skull.sh"
    exit 1
fi

PROJECT_DIR="/var/www/eshop"
TEMP_DIR="/tmp/kt3_skull_force_$$"

echo ""
echo "1. Клонирование репозитория..."
cd /tmp
rm -rf ${TEMP_DIR}
git clone https://github.com/JEESUScrised/PHP.git -b kt3 ${TEMP_DIR}

echo ""
echo "2. Остановка Apache для обновления..."
systemctl stop apache2

echo ""
echo "3. Обновление skull.php..."
if [ -f "${TEMP_DIR}/eshop/app/skull.php" ]; then
    # Создаем резервную копию
    cp ${PROJECT_DIR}/app/skull.php ${PROJECT_DIR}/app/skull.php.backup.$(date +%Y%m%d_%H%M%S)
    
    # Копируем новый файл
    cp ${TEMP_DIR}/eshop/app/skull.php ${PROJECT_DIR}/app/skull.php
    chown www-data:www-data ${PROJECT_DIR}/app/skull.php
    chmod 644 ${PROJECT_DIR}/app/skull.php
    echo "✓ skull.php обновлен"
    
    # Проверяем что стили есть
    if grep -q "background: #000000 !important" ${PROJECT_DIR}/app/skull.php; then
        echo "✓ Стили найдены в файле"
    else
        echo "⚠ Стили не найдены!"
    fi
else
    echo "✗ Файл skull.php не найден в репозитории!"
    exit 1
fi

echo ""
echo "4. Очистка кэша Apache..."
rm -rf /var/cache/apache2/* 2>/dev/null || true
rm -rf /var/lib/apache2/fastcgi/* 2>/dev/null || true

echo ""
echo "5. Проверка синтаксиса..."
php -l ${PROJECT_DIR}/app/skull.php

echo ""
echo "6. Запуск Apache..."
systemctl start apache2
systemctl status apache2 | head -5

echo ""
echo "7. Очистка временных файлов..."
rm -rf ${TEMP_DIR}

echo ""
echo "=========================================="
echo "  Обновление завершено!"
echo "=========================================="
echo "ВАЖНО: Очистите кэш браузера:"
echo "  - Chrome/Edge: Ctrl+Shift+Delete или Ctrl+F5"
echo "  - Firefox: Ctrl+Shift+Delete или Ctrl+F5"
echo "  - Safari: Cmd+Option+E или Cmd+Shift+R"
echo ""
echo "Или откройте страницу в режиме инкогнито"
echo "=========================================="

