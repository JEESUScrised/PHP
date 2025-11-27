#!/bin/bash

set -e

echo "=========================================="
echo "  Автоматическое исправление Apache"
echo "=========================================="

if [ "$EUID" -ne 0 ]; then 
    echo "Пожалуйста, запустите скрипт с правами sudo: sudo bash fix-apache.sh"
    exit 1
fi

PROJECT_DIR="/var/www/eshop"

echo ""
echo "1. Проверка активных сайтов Apache..."
echo "-----------------------------------"
ACTIVE_SITES=$(ls -la /etc/apache2/sites-enabled/ 2>/dev/null | grep -v "^total" | awk '{print $9}' | grep -v "^$")
echo "Активные сайты:"
echo "$ACTIVE_SITES"

if echo "$ACTIVE_SITES" | grep -q "000-default"; then
    echo ""
    echo "⚠ Дефолтный сайт активен! Отключаю..."
    a2dissite 000-default.conf
    echo "✓ Дефолтный сайт отключен"
fi

echo ""
echo "2. Проверка конфигурации eshop..."
echo "-----------------------------------"
if [ ! -f "/etc/apache2/sites-available/eshop.conf" ]; then
    echo "⚠ Конфигурация eshop не найдена! Создаю..."
    cat > /etc/apache2/sites-available/eshop.conf <<EOF
<VirtualHost *:80>
    ServerName localhost
    
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
    echo "✓ Конфигурация создана"
else
    echo "✓ Конфигурация существует"
fi

if [ ! -L "/etc/apache2/sites-enabled/eshop.conf" ]; then
    echo ""
    echo "⚠ Сайт eshop не активирован! Активирую..."
    a2ensite eshop.conf
    echo "✓ Сайт активирован"
else
    echo "✓ Сайт уже активирован"
fi

echo ""
echo "3. Проверка директории проекта..."
echo "-----------------------------------"
if [ ! -d "$PROJECT_DIR" ]; then
    echo "⚠ Директория $PROJECT_DIR не существует!"
    echo "Создаю директорию..."
    mkdir -p ${PROJECT_DIR}
    echo "⚠ ВНИМАНИЕ: Проект не развернут! Запустите deploy.sh"
elif [ ! -f "$PROJECT_DIR/index.php" ]; then
    echo "⚠ Файл index.php не найден в $PROJECT_DIR"
    echo "⚠ ВНИМАНИЕ: Проект не развернут! Запустите deploy.sh"
else
    echo "✓ Директория проекта существует"
    echo "✓ Файл index.php найден"
fi

echo ""
echo "4. Проверка модулей Apache..."
echo "-----------------------------------"
a2enmod rewrite 2>/dev/null || echo "Модуль rewrite уже включен"
a2enmod headers 2>/dev/null || echo "Модуль headers уже включен"

echo ""
echo "5. Проверка конфигурации Apache..."
echo "-----------------------------------"
if apache2ctl configtest 2>&1 | grep -q "Syntax OK"; then
    echo "✓ Конфигурация корректна"
else
    echo "⚠ Ошибки в конфигурации:"
    apache2ctl configtest
fi

echo ""
echo "6. Перезапуск Apache..."
echo "-----------------------------------"
systemctl restart apache2
sleep 2

echo ""
echo "7. Проверка статуса Apache..."
echo "-----------------------------------"
if systemctl is-active --quiet apache2; then
    echo "✓ Apache запущен"
else
    echo "✗ Apache не запущен!"
    systemctl status apache2 --no-pager | head -10
fi

echo ""
echo "8. Проверка последних ошибок..."
echo "-----------------------------------"
tail -10 /var/log/apache2/error.log 2>/dev/null | grep -v "^$" || echo "Ошибок не найдено"

echo ""
echo "=========================================="
echo "  Результаты диагностики:"
echo "=========================================="

if [ -f "$PROJECT_DIR/index.php" ] && [ -L "/etc/apache2/sites-enabled/eshop.conf" ]; then
    echo "✓ Проект развернут"
    echo "✓ Apache настроен"
    echo ""
    echo "Сайт должен быть доступен по адресу:"
    echo "  http://149.33.4.37"
    echo "  http://localhost"
    echo ""
    echo "Если все еще видна стандартная страница:"
    echo "  1. Очистите кэш браузера (Ctrl+F5)"
    echo "  2. Попробуйте в режиме инкогнито"
    echo "  3. Проверьте: curl http://localhost"
else
    echo "⚠ Проект не развернут или Apache не настроен"
    echo ""
    echo "Выполните:"
    echo "  cd /tmp"
    echo "  git clone https://github.com/JEESUScrised/PHP.git -b kt3 kt3"
    echo "  cd kt3/deploy"
    echo "  sudo bash deploy.sh"
fi

echo "=========================================="

