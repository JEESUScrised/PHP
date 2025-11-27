#!/bin/bash

echo "=========================================="
echo "  Диагностика Apache и проекта"
echo "=========================================="

echo ""
echo "1. Проверка активных сайтов Apache:"
echo "-----------------------------------"
ls -la /etc/apache2/sites-enabled/

echo ""
echo "2. Проверка конфигурации eshop:"
echo "-----------------------------------"
if [ -f "/etc/apache2/sites-available/eshop.conf" ]; then
    echo "✓ Файл конфигурации существует"
    echo ""
    cat /etc/apache2/sites-available/eshop.conf
else
    echo "✗ Файл конфигурации НЕ найден!"
fi

echo ""
echo "3. Проверка директории проекта:"
echo "-----------------------------------"
if [ -d "/var/www/eshop" ]; then
    echo "✓ Директория /var/www/eshop существует"
    echo "Содержимое:"
    ls -la /var/www/eshop/ | head -20
    echo ""
    if [ -f "/var/www/eshop/index.php" ]; then
        echo "✓ Файл index.php найден"
    else
        echo "✗ Файл index.php НЕ найден!"
    fi
else
    echo "✗ Директория /var/www/eshop НЕ существует!"
fi

echo ""
echo "4. Проверка статуса Apache:"
echo "-----------------------------------"
systemctl status apache2 --no-pager | head -10

echo ""
echo "5. Проверка активных модулей:"
echo "-----------------------------------"
apache2ctl -M | grep -E "(rewrite|headers)"

echo ""
echo "6. Проверка DocumentRoot в активных сайтах:"
echo "-----------------------------------"
grep -r "DocumentRoot" /etc/apache2/sites-enabled/ 2>/dev/null || echo "Не найдено"

echo ""
echo "7. Проверка последних ошибок Apache:"
echo "-----------------------------------"
tail -20 /var/log/apache2/error.log 2>/dev/null || echo "Лог недоступен"

echo ""
echo "=========================================="
echo "  Рекомендации:"
echo "=========================================="

if [ ! -d "/var/www/eshop" ] || [ ! -f "/var/www/eshop/index.php" ]; then
    echo "⚠ Проект не развернут. Запустите:"
    echo "  cd /tmp/kt3/deploy && sudo bash deploy.sh"
fi

if [ ! -f "/etc/apache2/sites-available/eshop.conf" ]; then
    echo "⚠ Конфигурация Apache не создана. Запустите:"
    echo "  cd /tmp/kt3/deploy && sudo bash setup-apache.sh"
fi

if [ -L "/etc/apache2/sites-enabled/000-default.conf" ]; then
    echo "⚠ Дефолтный сайт все еще активен. Отключите его:"
    echo "  sudo a2dissite 000-default.conf"
    echo "  sudo systemctl restart apache2"
fi

echo ""
echo "Проверка завершена!"

