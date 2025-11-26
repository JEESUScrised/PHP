#!/bin/bash

set -e

echo "=========================================="
echo "  Развертывание проекта на сервере"
echo "=========================================="

if [ "$EUID" -ne 0 ]; then 
    echo "Пожалуйста, запустите скрипт с правами sudo: sudo bash deploy.sh"
    exit 1
fi

PROJECT_DIR="/var/www/eshop"
BACKUP_DIR="/var/backups/eshop"

echo ""
echo "Создание резервной копии..."
mkdir -p ${BACKUP_DIR}
if [ -d "${PROJECT_DIR}" ]; then
    BACKUP_NAME="eshop_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    tar -czf ${BACKUP_DIR}/${BACKUP_NAME} -C /var/www eshop
    echo "Резервная копия создана: ${BACKUP_DIR}/${BACKUP_NAME}"
fi

echo ""
echo "Очистка старой версии..."
rm -rf ${PROJECT_DIR}/*

echo ""
echo "Клонирование проекта из GitHub..."
cd /tmp
rm -rf kt3
git clone https://github.com/JEESUScrised/PHP.git -b kt3 kt3

echo ""
echo "Копирование файлов..."
cp -r kt3/eshop/* ${PROJECT_DIR}/
cp -r kt3/skull ${PROJECT_DIR}/
cp kt3/setup_admin.php ${PROJECT_DIR}/

if [ -f "${PROJECT_DIR}/.htaccess" ]; then
    echo ".htaccess найден"
else
    echo "Создание .htaccess..."
    cat > ${PROJECT_DIR}/.htaccess <<'HTACCESS_EOF'
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
fi

echo ""
echo "Настройка прав доступа..."
chown -R www-data:www-data ${PROJECT_DIR}
find ${PROJECT_DIR} -type d -exec chmod 755 {} \;
find ${PROJECT_DIR} -type f -exec chmod 644 {} \;
chmod 755 ${PROJECT_DIR}
chmod 644 ${PROJECT_DIR}/index.php

echo ""
echo "Настройка базы данных..."
if [ -f "${PROJECT_DIR}/core/eshop.sql" ]; then
    MYSQL_ROOT_PASSWORD=""
    if [ -f "/root/mysql_root_password.txt" ]; then
        MYSQL_ROOT_PASSWORD=$(cat /root/mysql_root_password.txt)
    else
        read -sp "Введите пароль MySQL root: " MYSQL_ROOT_PASSWORD
        echo ""
    fi
    
    mysql -u root -p"${MYSQL_ROOT_PASSWORD}" < ${PROJECT_DIR}/core/eshop.sql 2>/dev/null || echo "База данных уже существует или произошла ошибка"
fi

echo ""
echo "Создание администратора (если не существует)..."
cd ${PROJECT_DIR}
php setup_admin.php

echo ""
echo "Очистка временных файлов..."
rm -rf /tmp/kt3

echo ""
echo "Перезапуск Apache..."
systemctl restart apache2

echo ""
echo "=========================================="
echo "  Развертывание завершено!"
echo "=========================================="
echo "Проект доступен по адресу вашего домена"
echo "Админ-панель: http://ваш-домен/enter"
echo "Логин: admin"
echo "Пароль: admin123"
echo "=========================================="

