# Развертывание проекта на Ubuntu Server

## Важно: Настройка базы данных

**Перед запуском скрипта развертывания необходимо вручную создать и настроить базу данных!**

### Шаг 1: Создание базы данных

Подключитесь к MySQL:

```bash
sudo mysql
```

Или с паролем:

```bash
mysql -u root -p123qweasd
```

Создайте базу данных и пользователя:

```sql
CREATE DATABASE eshop CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Если нужно создать отдельного пользователя (опционально)
CREATE USER 'eshop_user'@'localhost' IDENTIFIED BY 'ваш_пароль';
GRANT ALL PRIVILEGES ON eshop.* TO 'eshop_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### Шаг 2: Импорт структуры базы данных

После клонирования проекта импортируйте структуру:

```bash
cd /tmp
git clone https://github.com/JEESUScrised/PHP.git -b kt3 kt3
mysql -u root -p123qweasd eshop < kt3/eshop/core/eshop.sql
```

## Развертывание проекта

### Быстрый старт

1. **Клонируйте репозиторий на сервере:**

```bash
cd /tmp
git clone https://github.com/JEESUScrised/PHP.git -b kt3 kt3
cd kt3/deploy
```

2. **Запустите скрипт развертывания:**

```bash
chmod +x deploy.sh
sudo bash deploy.sh
```

Скрипт:
- Создаст резервную копию (если проект уже установлен)
- Склонирует проект из GitHub
- Скопирует файлы в `/var/www/eshop`
- Настроит конфигурацию БД (пароль: `123qweasd`)
- Настроит права доступа
- Создаст администратора (если его нет)
- Перезапустит Apache

### Изменение пароля БД

Если используется другой пароль MySQL, отредактируйте скрипт:

```bash
nano deploy.sh
```

Измените строку:
```bash
MYSQL_ROOT_PASSWORD="ваш_пароль"
```

## Настройка Apache и домена

### 1. Установка Apache и PHP (если еще не установлены)

```bash
sudo apt-get update
sudo apt-get install -y apache2 php php-mysql php-mbstring php-xml
sudo a2enmod rewrite
sudo systemctl restart apache2
```

### 2. Настройка виртуального хоста

Создайте конфигурацию:

```bash
sudo nano /etc/apache2/sites-available/eshop.conf
```

Добавьте:

```apache
<VirtualHost *:80>
    ServerName ваш-домен.com
    ServerAlias www.ваш-домен.com
    
    DocumentRoot /var/www/eshop
    
    <Directory /var/www/eshop>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/eshop_error.log
    CustomLog ${APACHE_LOG_DIR}/eshop_access.log combined
</VirtualHost>
```

Активируйте сайт:

```bash
sudo a2ensite eshop.conf
sudo a2dissite 000-default.conf
sudo systemctl reload apache2
```

### 3. Настройка DNS

В панели управления домена добавьте:
- **A запись**: `@` → IP адрес сервера
- **A запись**: `www` → IP адрес сервера

### 4. Настройка SSL (HTTPS)

После настройки DNS:

```bash
sudo apt-get install -y certbot python3-certbot-apache
sudo certbot --apache -d ваш-домен.com -d www.ваш-домен.com
```

## Обновление проекта

Для обновления проекта просто запустите скрипт снова:

```bash
cd /tmp/kt3/deploy
sudo bash deploy.sh
```

Скрипт создаст резервную копию и обновит файлы.

## Создание администратора

Администратор создается автоматически при первом развертывании.

По умолчанию:
- **Логин**: `admin`
- **Пароль**: `admin123`

**ВАЖНО**: Смените пароль после первого входа!

Для создания администратора вручную:

```bash
cd /var/www/eshop
sudo php setup_admin.php
```

## Проверка работы

1. **Проверьте подключение к БД:**
```bash
mysql -u root -p123qweasd eshop -e "SHOW TABLES;"
```

2. **Проверьте конфигурацию:**
```bash
grep "PASS" /var/www/eshop/core/init.php
```

3. **Откройте сайт в браузере:**
- Главная: `http://ваш-домен.com`
- Админ-панель: `http://ваш-домен.com/enter`

## Полезные команды

### Просмотр логов
```bash
sudo tail -f /var/log/apache2/error.log
sudo tail -f /var/www/eshop/app/admin/error.log
```

### Перезапуск Apache
```bash
sudo systemctl restart apache2
```

### Проверка статуса сервисов
```bash
sudo systemctl status apache2 mysql
```

### Проверка прав доступа
```bash
ls -la /var/www/eshop
```

## Устранение проблем

### Ошибка подключения к БД

1. Проверьте, что MySQL запущен:
```bash
sudo systemctl status mysql
```

2. Проверьте пароль в конфигурации:
```bash
grep "PASS" /var/www/eshop/core/init.php
```

3. Проверьте подключение вручную:
```bash
mysql -u root -p123qweasd eshop
```

### Ошибка 403 Forbidden

```bash
sudo chown -R www-data:www-data /var/www/eshop
sudo chmod -R 755 /var/www/eshop
```

### Проблемы с роутингом

Убедитесь, что модуль `mod_rewrite` включен:

```bash
sudo a2enmod rewrite
sudo systemctl restart apache2
```

## Безопасность

1. **Смените пароль администратора** после первого входа
2. **Используйте сильные пароли** для MySQL
3. **Настройте файрвол:**
```bash
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

4. **Регулярно обновляйте систему:**
```bash
sudo apt-get update && sudo apt-get upgrade -y
```
