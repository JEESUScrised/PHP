#!/bin/bash

# Полный скрипт развертывания через SSH
# Выполняет все необходимые шаги автоматически

SERVER="root@149.33.4.37"
PASSWORD="PUR42mjSai"

echo "=========================================="
echo "  Полное развертывание проекта через SSH"
echo "=========================================="
echo ""

# Установка sshpass если нужно
if ! command -v sshpass &> /dev/null; then
    echo "Установка sshpass..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update && sudo apt-get install -y sshpass 2>/dev/null || echo "Не удалось установить sshpass автоматически"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install sshpass 2>/dev/null || echo "Не удалось установить sshpass автоматически"
    fi
fi

if ! command -v sshpass &> /dev/null; then
    echo "ОШИБКА: sshpass не установлен. Установите вручную:"
    echo "  Linux: sudo apt-get install sshpass"
    echo "  macOS: brew install sshpass"
    exit 1
fi

echo "Подключение к серверу ${SERVER}..."
echo ""

# Выполнение всех команд на сервере
sshpass -p "${PASSWORD}" ssh -o StrictHostKeyChecking=no ${SERVER} << 'ENDSSH'
set -e

echo "=========================================="
echo "  Начало развертывания"
echo "=========================================="

# 1. Клонирование репозитория
echo ""
echo "1. Клонирование репозитория..."
cd /tmp
rm -rf kt3
git clone https://github.com/JEESUScrised/PHP.git -b kt3 kt3
cd kt3/deploy
echo "✓ Репозиторий клонирован"

# 2. Исправление Apache
echo ""
echo "2. Настройка Apache..."
chmod +x fix-apache.sh
bash fix-apache.sh

# 3. Развертывание проекта
echo ""
echo "3. Развертывание проекта..."
chmod +x deploy.sh
# Автоматически отвечаем 'y' на запрос подтверждения
echo "y" | bash deploy.sh

echo ""
echo "=========================================="
echo "  Развертывание завершено!"
echo "=========================================="
echo "Сайт должен быть доступен: http://149.33.4.37"
echo "Админ-панель: http://149.33.4.37/enter"
echo "Логин: admin"
echo "Пароль: admin123"
echo "=========================================="
ENDSSH

echo ""
echo "Готово! Проверьте сайт в браузере."

