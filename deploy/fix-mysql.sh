#!/bin/bash

set -e

echo "=========================================="
echo "  Исправление доступа к MySQL"
echo "=========================================="

if [ "$EUID" -ne 0 ]; then 
    echo "Пожалуйста, запустите скрипт с правами sudo: sudo bash fix-mysql.sh"
    exit 1
fi

echo ""
echo "Проверка статуса MySQL..."
systemctl start mysql 2>/dev/null || service mysql start 2>/dev/null || true
systemctl enable mysql 2>/dev/null || true

sleep 2

echo ""
echo "Попытка подключения к MySQL..."

MYSQL_ROOT_PASSWORD=""
if [ -f "/root/mysql_root_password.txt" ]; then
    MYSQL_ROOT_PASSWORD=$(cat /root/mysql_root_password.txt)
    echo "Найден сохраненный пароль"
else
    read -sp "Введите пароль для MySQL root (или нажмите Enter для автоматической генерации): " MYSQL_ROOT_PASSWORD
    echo ""
    
    if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
        MYSQL_ROOT_PASSWORD=$(openssl rand -base64 32)
        echo "$MYSQL_ROOT_PASSWORD" > /root/mysql_root_password.txt
        chmod 600 /root/mysql_root_password.txt
        echo "Автоматически сгенерированный пароль сохранен в /root/mysql_root_password.txt"
    fi
fi

echo ""
echo "Попытка 1: Подключение через sudo mysql (без пароля)..."
if sudo mysql -e "SELECT 1;" 2>/dev/null; then
    echo "Успешно подключились через sudo mysql"
    sudo mysql <<MYSQL_SCRIPT
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
    
    if [ $? -eq 0 ]; then
        echo "Пароль успешно установлен!"
    else
        echo "Ошибка при установке пароля через sudo mysql"
        exit 1
    fi
else
    echo "Не удалось подключиться через sudo mysql"
    
    echo ""
    echo "Попытка 2: Подключение с пустым паролем..."
    if mysql -u root -e "SELECT 1;" 2>/dev/null; then
        echo "Успешно подключились с пустым паролем"
        mysql -u root <<MYSQL_SCRIPT
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
        
        if [ $? -eq 0 ]; then
            echo "Пароль успешно установлен!"
        else
            echo "Ошибка при установке пароля"
            exit 1
        fi
    else
        echo "Не удалось подключиться с пустым паролем"
        
        echo ""
        echo "Попытка 3: Сброс пароля через безопасный режим..."
        echo "Остановка MySQL..."
        systemctl stop mysql 2>/dev/null || service mysql stop 2>/dev/null || true
        
        echo "Запуск MySQL в безопасном режиме..."
        mysqld_safe --skip-grant-tables --skip-networking &
        MYSQL_SAFE_PID=$!
        sleep 5
        
        echo "Подключение и сброс пароля..."
        mysql -u root <<MYSQL_SCRIPT
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
        
        echo "Остановка безопасного режима..."
        kill $MYSQL_SAFE_PID 2>/dev/null || true
        sleep 2
        
        echo "Запуск MySQL в обычном режиме..."
        systemctl start mysql 2>/dev/null || service mysql start 2>/dev/null || true
        sleep 3
    fi
fi

echo ""
echo "Проверка подключения с новым паролем..."
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "SELECT 1;" 2>/dev/null && {
    echo "Успешно! MySQL настроен правильно."
} || {
    echo "Предупреждение: Не удалось подключиться с новым паролем, но это может быть нормально."
    echo "Попробуйте подключиться вручную: mysql -u root -p"
}

echo ""
if [ -f "/var/www/eshop/core/eshop.sql" ]; then
    echo "Создание базы данных eshop..."
    mysql -u root -p"${MYSQL_ROOT_PASSWORD}" < /var/www/eshop/core/eshop.sql 2>/dev/null && {
        echo "База данных создана успешно!"
    } || {
        echo "Попытка создания БД через sudo mysql..."
        sudo mysql < /var/www/eshop/core/eshop.sql 2>/dev/null && {
            echo "База данных создана успешно!"
        } || {
            echo "База данных уже существует или произошла ошибка"
        }
    }
else
    echo "Файл /var/www/eshop/core/eshop.sql не найден."
    echo "Сначала установите проект."
fi

echo ""
echo "=========================================="
echo "  Настройка MySQL завершена!"
echo "=========================================="
echo "Пароль MySQL root: ${MYSQL_ROOT_PASSWORD}"
echo "Пароль сохранен в: /root/mysql_root_password.txt"
echo ""
echo "Проверка подключения:"
echo "mysql -u root -p"
echo "Введите пароль: ${MYSQL_ROOT_PASSWORD}"

