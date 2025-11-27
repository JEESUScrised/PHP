#!/bin/bash

# Скрипт для запуска на вашем локальном компьютере
# Он подключится к серверу и выполнит исправления

SERVER="root@149.33.4.37"
SCRIPT_CONTENT=$(cat deploy/fix-apache.sh)

echo "Подключение к серверу и выполнение исправлений..."
echo "Введите пароль когда будет запрошен: PUR42mjSai"
echo ""

ssh ${SERVER} << 'ENDSSH'
cd /tmp
git clone https://github.com/JEESUScrised/PHP.git -b kt3 kt3 2>/dev/null || echo "Репозиторий уже клонирован"
cd kt3/deploy
chmod +x fix-apache.sh
bash fix-apache.sh
ENDSSH

echo ""
echo "Готово! Проверьте сайт в браузере."

