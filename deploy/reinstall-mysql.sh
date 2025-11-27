#!/bin/bash

set -e

echo "=========================================="
echo "  Переустановка MySQL"
echo "=========================================="

if [ "$EUID" -ne 0 ]; then 
    echo "Пожалуйста, запустите скрипт с правами sudo: sudo bash reinstall-mysql.sh"
    exit 1
fi

MYSQL_ROOT_PASSWORD="123qweasd"

echo ""
echo "ВНИМАНИЕ: Этот скрипт полностью удалит MySQL и все данные!"
echo "Убедитесь, что у вас есть резервная копия важных данных!"
echo ""
read -p "Продолжить? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Отменено"
    exit 1
fi

echo ""
echo "Шаг 1: Остановка MySQL..."
systemctl stop mysql 2>/dev/null || systemctl stop mysqld 2>/dev/null || true

echo ""
echo "Шаг 2: Удаление MySQL..."
apt-get remove --purge -y mysql-server mysql-client mysql-common mysql-server-core-* mysql-client-core-* 2>/dev/null || true
apt-get autoremove -y
apt-get autoclean -y

echo ""
echo "Шаг 3: Удаление конфигурационных файлов и данных..."
rm -rf /var/lib/mysql
rm -rf /var/lib/mysql-files
rm -rf /var/lib/mysql-keyring
rm -rf /var/log/mysql
rm -rf /etc/mysql
rm -rf /var/run/mysqld
rm -rf /tmp/mysql.sock
rm -rf /tmp/mysqld.sock

echo ""
echo "Шаг 4: Удаление пользователей MySQL (если есть)..."
userdel mysql 2>/dev/null || true
groupdel mysql 2>/dev/null || true

echo ""
echo "Шаг 5: Очистка пакетов..."
apt-get update

echo ""
echo "Шаг 6: Установка MySQL заново..."
export DEBIAN_FRONTEND=noninteractive
debconf-set-selections <<EOF
mysql-server mysql-server/root_password password ${MYSQL_ROOT_PASSWORD}
mysql-server mysql-server/root_password_again password ${MYSQL_ROOT_PASSWORD}
mysql-server mysql-server/root_password seen true
mysql-server mysql-server/root_password_again seen true
EOF

apt-get install -y mysql-server mysql-client

echo ""
echo "Шаг 7: Настройка MySQL..."
systemctl start mysql
systemctl enable mysql

echo ""
echo "Шаг 8: Настройка пароля root и аутентификации..."
sleep 3

mysql -u root -p${MYSQL_ROOT_PASSWORD} <<MYSQL_SCRIPT 2>/dev/null || {
    echo "Попытка подключения через sudo..."
    sudo mysql <<MYSQL_SCRIPT
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
}

ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo ""
echo "Шаг 9: Проверка подключения..."
if mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "SELECT 1;" 2>/dev/null; then
    echo "✓ Успешное подключение с паролем"
elif sudo mysql -e "SELECT 1;" 2>/dev/null; then
    echo "✓ Успешное подключение через sudo"
    echo "Настройка пароля через sudo..."
    sudo mysql <<MYSQL_SCRIPT
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
else
    echo "⚠ Не удалось подключиться автоматически"
    echo "Попробуйте подключиться вручную:"
    echo "  sudo mysql"
    echo "Или:"
    echo "  mysql -u root -p${MYSQL_ROOT_PASSWORD}"
fi

echo ""
echo "=========================================="
echo "  Переустановка MySQL завершена!"
echo "=========================================="
echo "Пароль root: ${MYSQL_ROOT_PASSWORD}"
echo ""
echo "Проверка подключения:"
echo "  mysql -u root -p${MYSQL_ROOT_PASSWORD}"
echo "Или:"
echo "  sudo mysql"
echo ""
echo "Теперь вы можете создать базу данных eshop:"
echo "  mysql -u root -p${MYSQL_ROOT_PASSWORD} -e \"CREATE DATABASE eshop CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;\""
echo "=========================================="

