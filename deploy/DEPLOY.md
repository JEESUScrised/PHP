# Инструкция по развертыванию на Ubuntu Server

## Подготовка сервера

### 1. Подключение к серверу

Подключитесь к вашему Ubuntu серверу через VNC или SSH.

### 2. Обновление системы

```bash
sudo apt-get update
sudo apt-get upgrade -y
```

## Автоматическая установка

### Вариант 1: Использование скрипта установки

1. Скопируйте папку `deploy` на сервер:

```bash
# На вашем компьютере
scp -r deploy/ user@your-server-ip:/tmp/
```

2. На сервере выполните:

```bash
cd /tmp/deploy
chmod +x install.sh
sudo bash install.sh
```

Скрипт установит:
- Apache веб-сервер
- PHP и необходимые расширения
- MySQL/MariaDB
- Certbot для SSL сертификатов
- Настроит виртуальный хост для вашего домена

### Вариант 2: Ручная установка

#### Установка необходимых пакетов

```bash
sudo apt-get update
sudo apt-get install -y apache2 php php-mysql php-mbstring php-xml mysql-server certbot python3-certbot-apache git
```

#### Настройка Apache

```bash
sudo a2enmod rewrite
sudo a2enmod ssl
sudo a2enmod headers
sudo systemctl restart apache2
```

#### Настройка MySQL

```bash
sudo mysql_secure_installation
```

Создайте базу данных:

```bash
sudo mysql -u root -p
```

В MySQL консоли:

```sql
CREATE DATABASE eshop CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'eshop_user'@'localhost' IDENTIFIED BY 'ваш_пароль';
GRANT ALL PRIVILEGES ON eshop.* TO 'eshop_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

Импортируйте структуру БД:

```bash
sudo mysql -u root -p eshop < /var/www/eshop/core/eshop.sql
```

## Развертывание проекта

### Способ 1: Из GitHub (рекомендуется)

```bash
cd /tmp
git clone https://github.com/JEESUScrised/PHP.git -b kt3 kt3
sudo cp -r kt3/eshop/* /var/www/eshop/
sudo cp -r kt3/skull /var/www/eshop/
sudo cp kt3/setup_admin.php /var/www/eshop/
sudo chown -R www-data:www-data /var/www/eshop
sudo chmod -R 755 /var/www/eshop
```

### Способ 2: Использование скрипта развертывания

```bash
cd /tmp/deploy
chmod +x deploy.sh
sudo bash deploy.sh
```

## Настройка доменного имени

### 1. Настройка DNS записей

В панели управления вашего доменного регистратора добавьте DNS записи:

- **A запись**: `@` → IP адрес вашего сервера
- **A запись**: `www` → IP адрес вашего сервера

Подождите 5-30 минут для распространения DNS записей.

### 2. Создание виртуального хоста Apache

Создайте файл конфигурации:

```bash
sudo nano /etc/apache2/sites-available/ваш-домен.com.conf
```

Вставьте следующее содержимое (замените `ваш-домен.com` на ваш домен):

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
    
    ErrorLog ${APACHE_LOG_DIR}/ваш-домен.com_error.log
    CustomLog ${APACHE_LOG_DIR}/ваш-домен.com_access.log combined
    
    RewriteEngine On
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule ^(.*)$ /index.php [QSA,L]
</Directory>
</VirtualHost>
```

Активируйте сайт:

```bash
sudo a2ensite ваш-домен.com.conf
sudo a2dissite 000-default.conf
sudo systemctl reload apache2
```

### 3. Настройка SSL сертификата (HTTPS)

После настройки DNS выполните:

```bash
sudo certbot --apache -d ваш-домен.com -d www.ваш-домен.com
```

Certbot автоматически:
- Получит SSL сертификат от Let's Encrypt
- Настроит HTTPS
- Настроит автоматическое обновление сертификата

## Настройка базы данных в проекте

Отредактируйте файл `/var/www/eshop/core/init.php`:

```bash
sudo nano /var/www/eshop/core/init.php
```

Найдите секцию с настройками БД и измените:

```php
const DB = [
    'HOST' => 'localhost',
    'USER' => 'eshop_user',  // или 'root'
    'PASS' => 'ваш_пароль',
    'NAME' => 'eshop',
];
```

## Создание администратора

```bash
cd /var/www/eshop
sudo php setup_admin.php
```

По умолчанию создается администратор:
- **Логин**: `admin`
- **Пароль**: `admin123`

**ВАЖНО**: После первого входа смените пароль через админ-панель!

## Настройка прав доступа

```bash
sudo chown -R www-data:www-data /var/www/eshop
sudo find /var/www/eshop -type d -exec chmod 755 {} \;
sudo find /var/www/eshop -type f -exec chmod 644 {} \;
```

## Проверка работы

1. Откройте в браузере: `http://ваш-домен.com` или `https://ваш-домен.com`
2. Проверьте админ-панель: `http://ваш-домен.com/enter`
3. Войдите с учетными данными администратора

## Обновление проекта

Для обновления проекта используйте скрипт `deploy.sh`:

```bash
cd /tmp/deploy
sudo bash deploy.sh
```

Или вручную:

```bash
cd /tmp
rm -rf kt3
git clone https://github.com/JEESUScrised/PHP.git -b kt3 kt3
sudo cp -r kt3/eshop/* /var/www/eshop/
sudo cp -r kt3/skull /var/www/eshop/
sudo chown -R www-data:www-data /var/www/eshop
sudo systemctl restart apache2
```

## Устранение проблем

### Ошибка подключения к БД

1. Проверьте настройки в `/var/www/eshop/core/init.php`
2. Проверьте, что MySQL запущен: `sudo systemctl status mysql`
3. Проверьте права пользователя БД

### Ошибка 403 Forbidden

```bash
sudo chown -R www-data:www-data /var/www/eshop
sudo chmod -R 755 /var/www/eshop
```

### Ошибка 500 Internal Server Error

Проверьте логи:

```bash
sudo tail -f /var/log/apache2/error.log
sudo tail -f /var/www/eshop/app/admin/error.log
```

### Проблемы с SSL сертификатом

```bash
sudo certbot renew --dry-run
```

## Безопасность

1. **Смените пароль администратора** после первого входа
2. **Используйте сильные пароли** для MySQL
3. **Настройте файрвол**:

```bash
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

4. **Регулярно обновляйте систему**:

```bash
sudo apt-get update && sudo apt-get upgrade -y
```

## Резервное копирование

Создайте скрипт для резервного копирования:

```bash
#!/bin/bash
BACKUP_DIR="/var/backups/eshop"
mkdir -p $BACKUP_DIR
tar -czf $BACKUP_DIR/eshop_$(date +%Y%m%d).tar.gz -C /var/www eshop
mysqldump -u root -p eshop > $BACKUP_DIR/eshop_db_$(date +%Y%m%d).sql
```

