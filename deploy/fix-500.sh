#!/bin/bash

set -e

echo "=========================================="
echo "  Исправление ошибки 500"
echo "=========================================="

if [ "$EUID" -ne 0 ]; then 
    echo "Пожалуйста, запустите скрипт с правами sudo: sudo bash fix-500.sh"
    exit 1
fi

PROJECT_DIR="/var/www/eshop"

echo ""
echo "1. Установка PHP модулей..."
apt-get update
apt-get install -y php php-mysql php-mbstring php-xml libapache2-mod-php

echo ""
echo "2. Включение модулей Apache..."
a2enmod php8.1 2>/dev/null || a2enmod php8.2 2>/dev/null || a2enmod php8.3 2>/dev/null || a2enmod php7.4 2>/dev/null || echo "PHP модуль уже включен"
a2enmod rewrite
a2enmod headers

echo ""
echo "3. Исправление прав доступа..."
chown -R www-data:www-data ${PROJECT_DIR}
find ${PROJECT_DIR} -type d -exec chmod 755 {} \;
find ${PROJECT_DIR} -type f -exec chmod 644 {} \;
chmod 755 ${PROJECT_DIR}
chmod 644 ${PROJECT_DIR}/index.php

echo ""
echo "4. Проверка .htaccess..."
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
    chmod 644 ${PROJECT_DIR}/.htaccess
    echo "✓ .htaccess создан"
else
    echo "✓ .htaccess существует"
fi

echo ""
echo "5. Проверка конфигурации БД..."
if [ -f "${PROJECT_DIR}/core/init.php" ]; then
    echo "Конфигурация БД найдена"
    DB_PASS=$(grep "'PASS'" ${PROJECT_DIR}/core/init.php | head -1)
    echo "Текущая конфигурация: $DB_PASS"
    
    # Проверка подключения к БД
    if mysql -u root -p123qweasd -e "SELECT 1;" 2>/dev/null; then
        echo "✓ Подключение к MySQL работает"
    else
        echo "⚠ Проблема с подключением к MySQL"
        echo "Проверьте пароль в конфигурации"
    fi
else
    echo "⚠ Файл init.php не найден!"
fi

echo ""
echo "6. Включение отображения ошибок PHP (временно для диагностики)..."
PHP_INI=$(php --ini | grep "Loaded Configuration File" | awk '{print $4}')
if [ -f "$PHP_INI" ]; then
    sed -i 's/display_errors = Off/display_errors = On/' "$PHP_INI" 2>/dev/null || true
    sed -i 's/display_errors = off/display_errors = On/' "$PHP_INI" 2>/dev/null || true
    echo "✓ Отображение ошибок включено"
else
    echo "⚠ Не удалось найти php.ini"
fi

echo ""
echo "7. Перезапуск Apache..."
systemctl restart apache2

echo ""
echo "8. Проверка ответа сервера..."
sleep 2
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost 2>/dev/null || echo "000")
echo "HTTP код: $HTTP_CODE"

if [ "$HTTP_CODE" = "200" ]; then
    echo "✓ Сервер отвечает успешно!"
elif [ "$HTTP_CODE" = "500" ]; then
    echo "⚠ Все еще ошибка 500. Проверьте логи:"
    echo "  tail -50 /var/log/apache2/error.log"
    echo "  tail -50 /var/log/apache2/eshop_error.log"
else
    echo "⚠ HTTP код: $HTTP_CODE"
fi

echo ""
echo "=========================================="
echo "  Исправление завершено!"
echo "=========================================="
echo "Если ошибка 500 сохраняется, выполните:"
echo "  sudo bash debug-500.sh"
echo "=========================================="

