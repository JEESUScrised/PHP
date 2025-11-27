#!/bin/bash

set -e

echo "=========================================="
echo "  Быстрое исправление HTTP"
echo "=========================================="

if [ "$EUID" -ne 0 ]; then 
    echo "Пожалуйста, запустите скрипт с правами sudo: sudo bash quick-fix-http.sh"
    exit 1
fi

PROJECT_DIR="/var/www/eshop"
DOMAIN="jeesuscrised.ru"

echo ""
echo "1. Отключение всех SSL сайтов..."
a2dissite 000-default-le-ssl.conf 2>/dev/null || true
a2dissite eshop-le-ssl.conf 2>/dev/null || true

echo ""
echo "2. Обновление HTTP конфигурации..."
cat > /etc/apache2/sites-available/eshop.conf <<EOF
<VirtualHost *:80>
    ServerName ${DOMAIN}
    ServerAlias www.${DOMAIN}
    ServerAlias 149.33.4.37
    
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
echo "3. Активация HTTP сайта..."
a2ensite eshop.conf
a2dissite 000-default.conf 2>/dev/null || true

echo ""
echo "4. Проверка конфигурации..."
apache2ctl configtest

echo ""
echo "5. Перезапуск Apache..."
systemctl restart apache2

echo ""
echo "6. Проверка ответа сервера..."
sleep 2
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost 2>/dev/null || echo "000")
echo "HTTP код: $HTTP_CODE"

if [ "$HTTP_CODE" = "200" ]; then
    echo "✓ Сервер отвечает"
    RESPONSE=$(curl -s http://localhost | head -5)
    if echo "$RESPONSE" | grep -q "It works"; then
        echo "⚠ ВНИМАНИЕ: Сервер возвращает стандартную страницу!"
    else
        echo "✓ Сервер возвращает содержимое проекта"
    fi
else
    echo "⚠ Проблема с ответом сервера (код: $HTTP_CODE)"
fi

echo ""
echo "=========================================="
echo "  Настройка завершена!"
echo "=========================================="
echo "Сайт доступен по адресу:"
echo "  http://${DOMAIN}"
echo "  http://149.33.4.37"
echo ""
echo "ВАЖНО: Используйте HTTP, не HTTPS!"
echo "=========================================="

