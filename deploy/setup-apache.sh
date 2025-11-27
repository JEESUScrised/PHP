#!/bin/bash

set -e

echo "=========================================="
echo "  Настройка Apache для проекта"
echo "=========================================="

if [ "$EUID" -ne 0 ]; then 
    echo "Пожалуйста, запустите скрипт с правами sudo: sudo bash setup-apache.sh"
    exit 1
fi

PROJECT_DIR="/var/www/eshop"
DOMAIN=""

echo ""
read -p "Введите доменное имя (или нажмите Enter для localhost): " DOMAIN

if [ -z "$DOMAIN" ]; then
    DOMAIN="localhost"
    SERVER_NAME="localhost"
    SERVER_ALIAS=""
else
    SERVER_NAME="$DOMAIN"
    SERVER_ALIAS="www.$DOMAIN"
fi

echo ""
echo "Установка Apache и PHP (если еще не установлены)..."
apt-get update
apt-get install -y apache2 php php-mysql php-mbstring php-xml libapache2-mod-php

echo ""
echo "Включение необходимых модулей Apache..."
a2enmod rewrite
a2enmod headers

echo ""
echo "Создание конфигурации виртуального хоста..."
cat > /etc/apache2/sites-available/eshop.conf <<EOF
<VirtualHost *:80>
    ServerName ${SERVER_NAME}
EOF

if [ -n "$SERVER_ALIAS" ]; then
    cat >> /etc/apache2/sites-available/eshop.conf <<EOF
    ServerAlias ${SERVER_ALIAS}
EOF
fi

cat >> /etc/apache2/sites-available/eshop.conf <<EOF
    
    DocumentRoot ${PROJECT_DIR}
    
    <Directory ${PROJECT_DIR}>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog \${APACHE_LOG_DIR}/eshop_error.log
    CustomLog \${APACHE_LOG_DIR}/eshop_access.log combined
</VirtualHost>
EOF

echo ""
echo "Активация сайта..."
a2ensite eshop.conf
a2dissite 000-default.conf 2>/dev/null || true

echo ""
echo "Проверка конфигурации Apache..."
apache2ctl configtest

if [ $? -eq 0 ]; then
    echo ""
    echo "Перезапуск Apache..."
    systemctl restart apache2
    systemctl enable apache2
    
    echo ""
    echo "=========================================="
    echo "  Настройка Apache завершена!"
    echo "=========================================="
    echo "Сайт должен быть доступен по адресу:"
    if [ "$DOMAIN" != "localhost" ]; then
        echo "  http://${DOMAIN}"
        echo "  http://${SERVER_ALIAS}"
    else
        echo "  http://localhost"
        echo "  http://$(hostname -I | awk '{print $1}')"
    fi
    echo ""
    echo "Проверка статуса Apache:"
    echo "  sudo systemctl status apache2"
    echo ""
    echo "Просмотр логов:"
    echo "  sudo tail -f /var/log/apache2/eshop_error.log"
    echo "=========================================="
else
    echo ""
    echo "ОШИБКА: Конфигурация Apache содержит ошибки!"
    echo "Проверьте конфигурацию вручную:"
    echo "  sudo apache2ctl configtest"
    exit 1
fi

