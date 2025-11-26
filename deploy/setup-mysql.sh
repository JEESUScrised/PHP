#!/bin/bash

set -e

echo "=========================================="
echo "  Настройка MySQL вручную"
echo "=========================================="

if [ "$EUID" -ne 0 ]; then 
    echo "Пожалуйста, запустите скрипт с правами sudo: sudo bash setup-mysql.sh"
    exit 1
fi

echo ""
echo "Запуск MySQL..."
systemctl start mysql
systemctl enable mysql

echo ""
MYSQL_ROOT_PASSWORD=""
read -sp "Введите пароль для MySQL root (или нажмите Enter для автоматической генерации): " MYSQL_ROOT_PASSWORD
echo ""

if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
    MYSQL_ROOT_PASSWORD=$(openssl rand -base64 32)
    echo "Автоматически сгенерированный пароль MySQL root сохранен в /root/mysql_root_password.txt"
    echo "$MYSQL_ROOT_PASSWORD" > /root/mysql_root_password.txt
    chmod 600 /root/mysql_root_password.txt
    echo "Пароль: ${MYSQL_ROOT_PASSWORD}"
fi

echo ""
echo "Установка пароля для MySQL root..."
sudo mysql <<MYSQL_SCRIPT
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

if [ $? -eq 0 ]; then
    echo "Пароль успешно установлен!"
else
    echo "Ошибка при установке пароля. Попробуйте выполнить вручную:"
    echo "sudo mysql"
    echo "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'ваш_пароль';"
    echo "FLUSH PRIVILEGES;"
    exit 1
fi

echo ""
echo "Создание базы данных eshop..."
if [ -f "/var/www/eshop/core/eshop.sql" ]; then
    mysql -u root -p"${MYSQL_ROOT_PASSWORD}" < /var/www/eshop/core/eshop.sql
    echo "База данных создана успешно!"
else
    echo "Файл /var/www/eshop/core/eshop.sql не найден. Сначала установите проект."
    exit 1
fi

echo ""
echo "=========================================="
echo "  MySQL настроен успешно!"
echo "=========================================="
echo "Пароль MySQL root сохранен в: /root/mysql_root_password.txt"

