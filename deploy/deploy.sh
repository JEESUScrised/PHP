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
MYSQL_ROOT_PASSWORD="123qweasd"

echo ""
echo "ВАЖНО: Убедитесь, что база данных уже создана и настроена!"
echo "Пароль MySQL root: ${MYSQL_ROOT_PASSWORD}"
echo "База данных: eshop"
echo ""
read -p "Продолжить? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Отменено"
    exit 1
fi

echo ""
echo "Создание резервной копии..."
mkdir -p ${BACKUP_DIR}
if [ -d "${PROJECT_DIR}" ] && [ "$(ls -A ${PROJECT_DIR})" ]; then
    BACKUP_NAME="eshop_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    tar -czf ${BACKUP_DIR}/${BACKUP_NAME} -C /var/www eshop
    echo "Резервная копия создана: ${BACKUP_DIR}/${BACKUP_NAME}"
else
    echo "Резервная копия не требуется (проект не установлен)"
fi

echo ""
echo "Клонирование проекта из GitHub..."
cd /tmp
rm -rf kt3
git clone https://github.com/JEESUScrised/PHP.git -b kt3 kt3

echo ""
echo "Создание директории проекта..."
mkdir -p ${PROJECT_DIR}

echo ""
echo "Копирование файлов..."
cp -r kt3/eshop/* ${PROJECT_DIR}/
if [ -d "kt3/skull" ]; then
    cp -r kt3/skull ${PROJECT_DIR}/ 2>/dev/null || true
fi
if [ -f "kt3/setup_admin.php" ]; then
    cp kt3/setup_admin.php ${PROJECT_DIR}/ 2>/dev/null || true
fi

echo ""
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

echo ""
echo "Настройка конфигурации БД..."
if [ -f "${PROJECT_DIR}/core/init.php" ]; then
    sed -i "s/'PASS' => '[^']*',/'PASS' => '${MYSQL_ROOT_PASSWORD}',/" ${PROJECT_DIR}/core/init.php
    echo "Пароль БД обновлен в конфигурации: ${MYSQL_ROOT_PASSWORD}"
else
    echo "ОШИБКА: Файл ${PROJECT_DIR}/core/init.php не найден!"
    exit 1
fi

echo ""
echo "Настройка прав доступа..."
chown -R www-data:www-data ${PROJECT_DIR}
find ${PROJECT_DIR} -type d -exec chmod 755 {} \;
find ${PROJECT_DIR} -type f -exec chmod 644 {} \;
chmod 755 ${PROJECT_DIR}
chmod 644 ${PROJECT_DIR}/index.php

echo ""
echo "Создание администратора (если не существует)..."
if [ -f "${PROJECT_DIR}/setup_admin.php" ]; then
    cd ${PROJECT_DIR}
    php setup_admin.php 2>/dev/null || echo "Администратор уже существует или произошла ошибка"
else
    echo "Предупреждение: Файл setup_admin.php не найден"
fi

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
echo ""
echo "Проверка подключения к БД:"
echo "mysql -u root -p${MYSQL_ROOT_PASSWORD} eshop"
echo "=========================================="
