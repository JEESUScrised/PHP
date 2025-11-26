#!/bin/bash

set -e

echo "=========================================="
echo "  Настройка проекта с существующей БД"
echo "=========================================="

if [ "$EUID" -ne 0 ]; then 
    echo "Пожалуйста, запустите скрипт с правами sudo: sudo bash setup-existing-db.sh"
    exit 1
fi

PROJECT_DIR="/var/www/eshop"
MYSQL_ROOT_PASSWORD="123qweasd"

echo ""
echo "Проверка подключения к MySQL..."
if mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "SELECT 1;" 2>/dev/null; then
    echo "Успешное подключение к MySQL"
else
    echo "Ошибка: Не удалось подключиться к MySQL с паролем ${MYSQL_ROOT_PASSWORD}"
    echo "Проверьте пароль и убедитесь, что MySQL запущен:"
    echo "  sudo systemctl status mysql"
    exit 1
fi

echo ""
echo "Проверка существования базы данных eshop..."
DB_EXISTS=$(mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "SHOW DATABASES LIKE 'eshop';" 2>/dev/null | grep -c eshop || echo "0")

if [ "$DB_EXISTS" -eq "0" ]; then
    echo "База данных eshop не найдена. Создание..."
    if [ -f "${PROJECT_DIR}/core/eshop.sql" ]; then
        mysql -u root -p"${MYSQL_ROOT_PASSWORD}" < ${PROJECT_DIR}/core/eshop.sql
        echo "База данных создана успешно!"
    else
        echo "Ошибка: Файл ${PROJECT_DIR}/core/eshop.sql не найден"
        exit 1
    fi
else
    echo "База данных eshop уже существует"
fi

echo ""
echo "Настройка конфигурации проекта..."

if [ ! -f "${PROJECT_DIR}/core/init.php" ]; then
    echo "Ошибка: Файл ${PROJECT_DIR}/core/init.php не найден"
    echo "Сначала установите проект"
    exit 1
fi

echo "Обновление настроек БД в init.php..."
if [ -f "${PROJECT_DIR}/core/init.php" ]; then
    sed -i "s/'PASS' => '[^']*',/'PASS' => '${MYSQL_ROOT_PASSWORD}',/" ${PROJECT_DIR}/core/init.php
    echo "Пароль БД обновлен в конфигурации"
else
    echo "Ошибка: Файл ${PROJECT_DIR}/core/init.php не найден"
    exit 1
fi

echo ""
echo "Проверка структуры базы данных..."
TABLES_COUNT=$(mysql -u root -p"${MYSQL_ROOT_PASSWORD}" eshop -e "SHOW TABLES;" 2>/dev/null | wc -l)

if [ "$TABLES_COUNT" -lt "5" ]; then
    echo "Предупреждение: В базе данных мало таблиц. Проверка структуры..."
    if [ -f "${PROJECT_DIR}/core/eshop.sql" ]; then
        echo "Импорт структуры БД..."
        mysql -u root -p"${MYSQL_ROOT_PASSWORD}" eshop < ${PROJECT_DIR}/core/eshop.sql 2>/dev/null || {
            echo "База данных уже содержит структуру или произошла ошибка"
        }
    fi
fi

echo ""
echo "Проверка наличия администратора..."
ADMIN_COUNT=$(mysql -u root -p"${MYSQL_ROOT_PASSWORD}" eshop -e "SELECT COUNT(*) FROM admins;" 2>/dev/null | tail -n 1 || echo "0")

if [ "$ADMIN_COUNT" -eq "0" ]; then
    echo "Администратор не найден. Создание..."
    if [ -f "${PROJECT_DIR}/setup_admin.php" ]; then
        cd ${PROJECT_DIR}
        php setup_admin.php
    else
        echo "Предупреждение: Файл setup_admin.php не найден"
        echo "Создайте администратора вручную через админ-панель или SQL"
    fi
else
    echo "Администратор уже существует"
fi

echo ""
echo "Настройка прав доступа..."
chown -R www-data:www-data ${PROJECT_DIR}
find ${PROJECT_DIR} -type d -exec chmod 755 {} \;
find ${PROJECT_DIR} -type f -exec chmod 644 {} \;
chmod 755 ${PROJECT_DIR}
chmod 644 ${PROJECT_DIR}/index.php

echo ""
echo "Проверка конфигурации..."
if grep -q "'PASS' => '${MYSQL_ROOT_PASSWORD}'" ${PROJECT_DIR}/core/init.php; then
    echo "Конфигурация БД обновлена успешно"
else
    echo "Предупреждение: Не удалось автоматически обновить конфигурацию"
    echo "Отредактируйте вручную: ${PROJECT_DIR}/core/init.php"
    echo "Установите: 'PASS' => '${MYSQL_ROOT_PASSWORD}'"
fi

echo ""
echo "=========================================="
echo "  Настройка завершена!"
echo "=========================================="
echo "Пароль MySQL: ${MYSQL_ROOT_PASSWORD}"
echo "База данных: eshop"
echo ""
echo "Проверка подключения:"
echo "mysql -u root -p${MYSQL_ROOT_PASSWORD} eshop"
echo ""
echo "Проект должен быть доступен по адресу вашего домена"
echo "Админ-панель: http://ваш-домен/enter"
echo "=========================================="

