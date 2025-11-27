# Развертывание через SSH

## Быстрый способ (рекомендуется)

### Вариант 1: Использование скрипта на сервере

Подключитесь к серверу через SSH и выполните:

```bash
ssh root@149.33.4.37
# Введите пароль: PUR42mjSai

cd /tmp
git clone https://github.com/JEESUScrised/PHP.git -b kt3 kt3
cd kt3/deploy
chmod +x ssh-deploy-all.sh
bash ssh-deploy-all.sh
```

### Вариант 2: Использование sshpass (Linux/macOS)

На вашем локальном компьютере (Linux/macOS):

```bash
# Установите sshpass
sudo apt-get install sshpass  # Linux
# или
brew install sshpass  # macOS

# Запустите скрипт
cd deploy
chmod +x ssh-deploy-all.sh
bash ssh-deploy-all.sh
```

### Вариант 3: Использование PowerShell (Windows)

На вашем локальном компьютере (Windows):

```powershell
# Запустите PowerShell скрипт
powershell -ExecutionPolicy Bypass -File deploy/ssh-deploy.ps1
```

Или установите PuTTY (plink) для автоматического ввода пароля:

```powershell
# Скачайте PuTTY: https://www.putty.org/
# Добавьте plink.exe в PATH
# Затем запустите скрипт
```

### Вариант 4: Ручное выполнение команд

Подключитесь к серверу:

```bash
ssh root@149.33.4.37
# Пароль: PUR42mjSai
```

Затем выполните команды по порядку:

```bash
# 1. Клонирование репозитория
cd /tmp
git clone https://github.com/JEESUScrised/PHP.git -b kt3 kt3
cd kt3/deploy

# 2. Исправление Apache
chmod +x fix-apache.sh
sudo bash fix-apache.sh

# 3. Развертывание проекта
chmod +x deploy.sh
sudo bash deploy.sh
# (ответьте 'y' на запрос подтверждения)
```

## Что делают скрипты

### ssh-deploy-all.sh
Полный скрипт развертывания, который:
1. Клонирует репозиторий
2. Исправляет конфигурацию Apache
3. Развертывает проект

### ssh-fix.sh
Только исправление Apache (если проект уже развернут)

### fix-apache.sh
Исправляет конфигурацию Apache на сервере:
- Отключает дефолтный сайт
- Создает конфигурацию eshop
- Активирует сайт
- Перезапускает Apache

## Проверка результата

После выполнения скриптов:

1. Откройте в браузере: `http://149.33.4.37`
2. Очистите кэш браузера (Ctrl+F5) или откройте в режиме инкогнито
3. Должна открыться главная страница проекта, а не стандартная страница Apache

## Устранение проблем

Если все еще видна стандартная страница Apache:

```bash
ssh root@149.33.4.37
cd /tmp/kt3/deploy
sudo bash check-apache.sh
```

Скрипт покажет детальную диагностику.

