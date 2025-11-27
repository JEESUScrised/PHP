#!/bin/bash

# Скрипт для автоматического исправления Apache через SSH
# Запустите на вашем локальном компьютере

SERVER="root@149.33.4.37"
PASSWORD="PUR42mjSai"

echo "=========================================="
echo "  Подключение к серверу и исправление Apache"
echo "=========================================="
echo ""

# Проверка наличия sshpass
if ! command -v sshpass &> /dev/null; then
    echo "Установка sshpass для автоматического ввода пароля..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update && sudo apt-get install -y sshpass
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install sshpass
    else
        echo "Пожалуйста, установите sshpass вручную"
        exit 1
    fi
fi

echo "1. Клонирование репозитория на сервере..."
sshpass -p "${PASSWORD}" ssh -o StrictHostKeyChecking=no ${SERVER} << 'ENDSSH'
cd /tmp
rm -rf kt3
git clone https://github.com/JEESUScrised/PHP.git -b kt3 kt3
echo "✓ Репозиторий клонирован"
ENDSSH

echo ""
echo "2. Запуск скрипта исправления Apache..."
sshpass -p "${PASSWORD}" ssh -o StrictHostKeyChecking=no ${SERVER} << 'ENDSSH'
cd /tmp/kt3/deploy
chmod +x fix-apache.sh
bash fix-apache.sh
ENDSSH

echo ""
echo "3. Проверка развертывания проекта..."
sshpass -p "${PASSWORD}" ssh -o StrictHostKeyChecking=no ${SERVER} << 'ENDSSH'
if [ ! -f "/var/www/eshop/index.php" ]; then
    echo "⚠ Проект не развернут. Запускаю deploy.sh..."
    cd /tmp/kt3/deploy
    chmod +x deploy.sh
    echo "y" | bash deploy.sh
else
    echo "✓ Проект уже развернут"
fi
ENDSSH

echo ""
echo "=========================================="
echo "  Готово!"
echo "=========================================="
echo "Проверьте сайт: http://149.33.4.37"
echo "Очистите кэш браузера (Ctrl+F5) или откройте в режиме инкогнито"
echo "=========================================="

