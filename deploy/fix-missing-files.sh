#!/bin/bash

set -e

echo "=========================================="
echo "  Проверка и исправление отсутствующих файлов"
echo "=========================================="

if [ "$EUID" -ne 0 ]; then 
    echo "Пожалуйста, запустите скрипт с правами sudo: sudo bash fix-missing-files.sh"
    exit 1
fi

PROJECT_DIR="/var/www/eshop"
TEMP_DIR="/tmp/kt3_fix_$$"

echo ""
echo "1. Клонирование репозитория..."
cd /tmp
rm -rf ${TEMP_DIR}
git clone https://github.com/JEESUScrised/PHP.git -b kt3 ${TEMP_DIR}

echo ""
echo "2. Проверка файлов в core..."
echo "-----------------------------------"
REQUIRED_FILES=(
    "Eshop.class.php"
    "Book.class.php"
    "User.class.php"
    "Order.class.php"
    "Basket.class.php"
    "init.php"
    "eshop.sql"
)

MISSING_FILES=()

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "${PROJECT_DIR}/core/${file}" ]; then
        echo "✗ Отсутствует: core/${file}"
        MISSING_FILES+=("${file}")
    else
        echo "✓ Найден: core/${file}"
    fi
done

echo ""
echo "3. Копирование отсутствующих файлов..."
echo "-----------------------------------"
if [ ${#MISSING_FILES[@]} -gt 0 ]; then
    for file in "${MISSING_FILES[@]}"; do
        if [ -f "${TEMP_DIR}/eshop/core/${file}" ]; then
            cp "${TEMP_DIR}/eshop/core/${file}" "${PROJECT_DIR}/core/${file}"
            chown www-data:www-data "${PROJECT_DIR}/core/${file}"
            chmod 644 "${PROJECT_DIR}/core/${file}"
            echo "✓ Скопирован: core/${file}"
        else
            echo "⚠ Файл не найден в репозитории: core/${file}"
        fi
    done
else
    echo "✓ Все файлы на месте"
fi

echo ""
echo "4. Проверка структуры core..."
echo "-----------------------------------"
ls -la ${PROJECT_DIR}/core/

echo ""
echo "5. Проверка других важных файлов..."
echo "-----------------------------------"
if [ ! -d "${PROJECT_DIR}/app" ]; then
    echo "⚠ Папка app отсутствует! Копирую..."
    cp -r ${TEMP_DIR}/eshop/app ${PROJECT_DIR}/
    chown -R www-data:www-data ${PROJECT_DIR}/app
fi

if [ ! -d "${PROJECT_DIR}/css" ]; then
    echo "⚠ Папка css отсутствует! Копирую..."
    cp -r ${TEMP_DIR}/eshop/css ${PROJECT_DIR}/
    chown -R www-data:www-data ${PROJECT_DIR}/css
fi

if [ ! -f "${PROJECT_DIR}/index.php" ]; then
    echo "⚠ index.php отсутствует! Копирую..."
    cp ${TEMP_DIR}/eshop/index.php ${PROJECT_DIR}/
    chown www-data:www-data ${PROJECT_DIR}/index.php
    chmod 644 ${PROJECT_DIR}/index.php
fi

echo ""
echo "6. Исправление прав доступа..."
chown -R www-data:www-data ${PROJECT_DIR}
find ${PROJECT_DIR} -type d -exec chmod 755 {} \;
find ${PROJECT_DIR} -type f -exec chmod 644 {} \;

echo ""
echo "7. Очистка временных файлов..."
rm -rf ${TEMP_DIR}

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
    RESPONSE=$(curl -s http://localhost | head -5)
    if echo "$RESPONSE" | grep -q "It works"; then
        echo "⚠ ВНИМАНИЕ: Сервер возвращает стандартную страницу!"
    else
        echo "✓ Сервер возвращает содержимое проекта"
    fi
elif [ "$HTTP_CODE" = "500" ]; then
    echo "⚠ Все еще ошибка 500. Проверьте логи:"
    echo "  tail -20 /var/log/apache2/eshop_error.log"
else
    echo "⚠ HTTP код: $HTTP_CODE"
fi

echo ""
echo "=========================================="
echo "  Исправление завершено!"
echo "=========================================="

