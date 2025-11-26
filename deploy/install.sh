#!/bin/bash

set -e

echo "=========================================="
echo "  Установка PHP Eshop на Ubuntu Server"
echo "=========================================="

if [ "$EUID" -ne 0 ]; then 
    echo "Пожалуйста, запустите скрипт с правами sudo: sudo bash install.sh"
    exit 1
fi

DOMAIN_NAME=""
read -p "Введите ваше доменное имя (например, example.com): " DOMAIN_NAME

if [ -z "$DOMAIN_NAME" ]; then
    echo "Ошибка: доменное имя не может быть пустым"
    exit 1
fi

echo ""
echo "Обновление списка пакетов..."
apt-get update

echo ""
echo "Установка необходимых пакетов..."
apt-get install -y \
    apache2 \
    php \
    php-mysql \
    php-mbstring \
    php-xml \
    mysql-server \
    certbot \
    python3-certbot-apache \
    git \
    unzip

echo ""
echo "Включение необходимых модулей Apache..."
a2enmod rewrite
a2enmod ssl
a2enmod headers

echo ""
echo "Настройка MySQL..."
MYSQL_ROOT_PASSWORD=""
read -sp "Введите пароль для MySQL root (или нажмите Enter для автоматической генерации): " MYSQL_ROOT_PASSWORD
echo ""

if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
    MYSQL_ROOT_PASSWORD=$(openssl rand -base64 32)
    echo "Автоматически сгенерированный пароль MySQL root сохранен в /root/mysql_root_password.txt"
    echo "$MYSQL_ROOT_PASSWORD" > /root/mysql_root_password.txt
    chmod 600 /root/mysql_root_password.txt
fi

mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}';" 2>/dev/null || true
mysql -e "FLUSH PRIVILEGES;"

echo ""
echo "Создание директории проекта..."
mkdir -p /var/www/eshop

echo ""
echo "Клонирование проекта из GitHub..."
cd /tmp
rm -rf kt3
git clone https://github.com/JEESUScrised/PHP.git -b kt3 kt3

echo ""
echo "Копирование файлов проекта..."
cp -r kt3/eshop/* /var/www/eshop/
cp -r kt3/skull /var/www/eshop/ 2>/dev/null || true
cp kt3/setup_admin.php /var/www/eshop/ 2>/dev/null || true

echo ""
echo "Создание .htaccess..."
cat > /var/www/eshop/.htaccess <<'HTACCESS_EOF'
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteBase /
    
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule ^(.*)$ index.php [QSA,L]
</IfModule>

<IfModule mod_headers.c>
    Header set X-Content-Type-Options "nosniff"
    Header set X-Frame-Options "SAMEORIGIN"
    Header set X-XSS-Protection "1; mode=block"
</IfModule>
HTACCESS_EOF

echo ""
echo "Создание базы данных..."
mysql -u root -p"${MYSQL_ROOT_PASSWORD}" < /var/www/eshop/core/eshop.sql

echo ""
echo "Очистка временных файлов..."
rm -rf /tmp/kt3

echo ""
echo "Настройка Apache..."
cat > /etc/apache2/sites-available/${DOMAIN_NAME}.conf <<EOF
<VirtualHost *:80>
    ServerName ${DOMAIN_NAME}
    ServerAlias www.${DOMAIN_NAME}
    
    DocumentRoot /var/www/eshop
    
    <Directory /var/www/eshop>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog \${APACHE_LOG_DIR}/${DOMAIN_NAME}_error.log
    CustomLog \${APACHE_LOG_DIR}/${DOMAIN_NAME}_access.log combined
</VirtualHost>
EOF

a2ensite ${DOMAIN_NAME}.conf
a2dissite 000-default.conf

echo ""
echo "Настройка прав доступа..."
chown -R www-data:www-data /var/www/eshop
find /var/www/eshop -type d -exec chmod 755 {} \;
find /var/www/eshop -type f -exec chmod 644 {} \;
chmod 755 /var/www/eshop
chmod 644 /var/www/eshop/index.php

echo ""
echo "Перезапуск Apache..."
systemctl restart apache2

echo ""
echo "=========================================="
echo "  Установка завершена!"
echo "=========================================="
echo "Доменное имя: ${DOMAIN_NAME}"
echo "Пароль MySQL root сохранен в: /root/mysql_root_password.txt"
echo ""
echo "Следующие шаги:"
echo "1. Настройте DNS записи для домена ${DOMAIN_NAME}:"
echo "   A запись: @ -> IP вашего сервера"
echo "   A запись: www -> IP вашего сервера"
echo ""
echo "2. После настройки DNS выполните:"
echo "   sudo certbot --apache -d ${DOMAIN_NAME} -d www.${DOMAIN_NAME}"
echo ""
echo "3. Создайте администратора:"
echo "   cd /var/www/eshop && php setup_admin.php"
echo ""
echo "4. Откройте в браузере: http://${DOMAIN_NAME}"
echo "=========================================="

