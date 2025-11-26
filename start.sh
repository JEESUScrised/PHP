#!/bin/bash

echo "========================================"
echo "  Запуск книжного магазина"
echo "========================================"
echo ""

# Проверка наличия PHP
if ! command -v php &> /dev/null; then
    echo "[ОШИБКА] PHP не найден!"
    echo "Установите PHP: sudo apt-get install php php-mysql (Ubuntu/Debian)"
    echo "или: brew install php (macOS)"
    exit 1
fi

echo "[OK] PHP найден"
php -v | head -n 1
echo ""

# Проверка наличия MySQL
if ! command -v mysql &> /dev/null; then
    echo "[ПРЕДУПРЕЖДЕНИЕ] MySQL не найден в PATH"
    echo "Убедитесь, что MySQL/MariaDB установлен и запущен"
    echo ""
else
    echo "[OK] MySQL найден"
    echo ""
fi

# Проверка наличия базы данных
echo "Проверка базы данных..."
if ! mysql -u root -e "USE eshop;" 2>/dev/null; then
    echo "[ИНФО] База данных не найдена. Создание базы данных..."
    mysql -u root < eshop/core/eshop.sql
    if [ $? -ne 0 ]; then
        echo "[ОШИБКА] Не удалось создать базу данных"
        echo "Убедитесь, что MySQL запущен и пользователь root имеет права"
        exit 1
    fi
    echo "[OK] База данных создана"
    echo ""
    echo "[ИНФО] Создание администратора..."
    php setup_admin.php
    echo ""
else
    echo "[OK] База данных существует"
    echo ""
    # Проверяем наличие администратора
    echo "[ИНФО] Проверка администратора..."
    php setup_admin.php >/dev/null 2>&1
fi

# Переход в директорию проекта
cd "$(dirname "$0")/eshop"

# Запуск PHP сервера
echo "========================================"
echo "  Сервер запущен на http://localhost:8000"
echo "========================================"
echo ""
echo "Нажмите Ctrl+C для остановки сервера"
echo ""
php -S localhost:8000

