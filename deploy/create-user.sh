#!/bin/bash

set -e

echo "=========================================="
echo "  Создание пользователя на сервере"
echo "=========================================="

if [ "$EUID" -ne 0 ]; then 
    echo "Пожалуйста, запустите скрипт с правами sudo: sudo bash create-user.sh"
    exit 1
fi

PROJECT_DIR="/var/www/eshop"

echo ""
echo "1. Обновление файлов из репозитория..."
cd /tmp
rm -rf kt3
git clone https://github.com/JEESUScrised/PHP.git -b kt3 kt3

# Копируем скрипты
cp kt3/create_user.php ${PROJECT_DIR}/
cp kt3/setup_admin.php ${PROJECT_DIR}/
chown www-data:www-data ${PROJECT_DIR}/create_user.php ${PROJECT_DIR}/setup_admin.php
chmod 644 ${PROJECT_DIR}/create_user.php ${PROJECT_DIR}/setup_admin.php

echo ""
echo "2. Проверка структуры проекта..."
if [ ! -d "${PROJECT_DIR}/core" ]; then
    echo "⚠ Директория core не найдена! Убедитесь, что проект развернут."
    exit 1
fi

echo ""
echo "3. Создание администратора (если не существует)..."
cd ${PROJECT_DIR}
php setup_admin.php

echo ""
echo "=========================================="
echo "  Для создания дополнительного пользователя:"
echo "=========================================="
echo "cd ${PROJECT_DIR}"
echo "php create_user.php <логин> <пароль> <email>"
echo ""
echo "Пример:"
echo "php create_user.php user1 password123 user1@example.com"
echo "=========================================="

