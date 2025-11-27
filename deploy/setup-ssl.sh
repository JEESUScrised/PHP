#!/bin/bash

set -e

echo "=========================================="
echo "  Настройка SSL для домена"
echo "=========================================="

if [ "$EUID" -ne 0 ]; then 
    echo "Пожалуйста, запустите скрипт с правами sudo: sudo bash setup-ssl.sh"
    exit 1
fi

DOMAIN=""
read -p "Введите доменное имя (например: jeesuscrised.ru): " DOMAIN

if [ -z "$DOMAIN" ]; then
    echo "Ошибка: Доменное имя не указано"
    exit 1
fi

PROJECT_DIR="/var/www/eshop"

echo ""
echo "1. Установка Certbot..."
apt-get update
apt-get install -y certbot python3-certbot-apache

echo ""
echo "2. Обновление конфигурации Apache для домена..."
cat > /etc/apache2/sites-available/eshop.conf <<EOF
<VirtualHost *:80>
    ServerName ${DOMAIN}
    ServerAlias www.${DOMAIN}
    
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
echo "3. Активация сайта..."
a2ensite eshop.conf
a2dissite 000-default.conf 2>/dev/null || true
a2dissite 000-default-le-ssl.conf 2>/dev/null || true

echo ""
echo "4. Перезапуск Apache..."
systemctl restart apache2

echo ""
echo "5. Получение SSL сертификата..."
certbot --apache -d ${DOMAIN} -d www.${DOMAIN} --non-interactive --agree-tos --email admin@${DOMAIN} --redirect

echo ""
echo "=========================================="
echo "  SSL настроен!"
echo "=========================================="
echo "Сайт доступен по адресу:"
echo "  https://${DOMAIN}"
echo "  https://www.${DOMAIN}"
echo ""
echo "HTTP автоматически перенаправляется на HTTPS"
echo "=========================================="

