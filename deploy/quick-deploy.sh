#!/bin/bash

set -e

echo "=========================================="
echo "  Быстрое обновление проекта"
echo "=========================================="

if [ "$EUID" -ne 0 ]; then 
    echo "Пожалуйста, запустите скрипт с правами sudo: sudo bash quick-deploy.sh"
    exit 1
fi

PROJECT_DIR="/var/www/eshop"
MYSQL_ROOT_PASSWORD="123qweasd"

if [ ! -d "${PROJECT_DIR}" ]; then
    echo "Ошибка: Проект не установлен. Сначала выполните deploy.sh"
    exit 1
fi

echo ""
echo "Клонирование проекта из GitHub..."
TEMP_DIR="/tmp/kt3_deploy_$$"
cd /tmp
rm -rf ${TEMP_DIR}
git clone https://github.com/JEESUScrised/PHP.git -b kt3 ${TEMP_DIR}

echo ""
echo "Копирование файлов..."
cp -r ${TEMP_DIR}/eshop/* ${PROJECT_DIR}/
if [ -d "${TEMP_DIR}/skull" ]; then
    cp -r ${TEMP_DIR}/skull ${PROJECT_DIR}/ 2>/dev/null || true
fi
if [ -f "${TEMP_DIR}/setup_admin.php" ]; then
    cp ${TEMP_DIR}/setup_admin.php ${PROJECT_DIR}/ 2>/dev/null || true
fi

if [ ! -f "${PROJECT_DIR}/.htaccess" ]; then
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
echo "Обновление конфигурации БД..."
if [ -f "${PROJECT_DIR}/core/init.php" ]; then
    sed -i "s/'PASS' => '[^']*',/'PASS' => '${MYSQL_ROOT_PASSWORD}',/" ${PROJECT_DIR}/core/init.php
    echo "Пароль БД обновлен в конфигурации"
fi

echo ""
echo "Настройка прав доступа..."
chown -R www-data:www-data ${PROJECT_DIR}
find ${PROJECT_DIR} -type d -exec chmod 755 {} \;
find ${PROJECT_DIR} -type f -exec chmod 644 {} \;
chmod 755 ${PROJECT_DIR}
chmod 644 ${PROJECT_DIR}/index.php

echo ""
echo "Очистка временных файлов..."
rm -rf ${TEMP_DIR}

echo ""
echo "Перезапуск Apache..."
systemctl restart apache2

echo ""
echo "=========================================="
echo "  Обновление завершено!"
echo "=========================================="
