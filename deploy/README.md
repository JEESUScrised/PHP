# Развертывание проекта на Ubuntu Server

## Важно: Настройка базы данных

**Перед запуском скрипта развертывания необходимо вручную создать и настроить базу данных!**

### Шаг 1: Удаление старой базы данных

**Если не можете подключиться к MySQL, см. раздел "Решение проблем с подключением к MySQL" ниже.**

#### Способ 1: Подключение через sudo (без пароля)

```bash
sudo mysql
```

В MySQL консоли выполните:

```sql
DROP DATABASE IF EXISTS eshop;
EXIT;
```

#### Способ 2: Подключение с паролем

```bash
mysql -u root -p123qweasd
```

В MySQL консоли выполните:

```sql
DROP DATABASE IF EXISTS eshop;
EXIT;
```

#### Способ 3: Подключение с запросом пароля

```bash
mysql -u root -p
```

Введите пароль при запросе (если пароль `123qweasd`, введите его).

В MySQL консоли выполните:

```sql
DROP DATABASE IF EXISTS eshop;
EXIT;
```

#### Решение проблем с подключением к MySQL

**Проблема 1: "Access denied for user 'root'@'localhost'"**

Попробуйте подключиться через sudo:

```bash
sudo mysql
```

Если это не работает, сбросьте пароль root:

```bash
sudo systemctl stop mysql
sudo mysqld_safe --skip-grant-tables &
mysql -u root
```

В MySQL консоли:

```sql
USE mysql;
UPDATE user SET authentication_string=PASSWORD('123qweasd') WHERE User='root';
FLUSH PRIVILEGES;
EXIT;
```

Затем перезапустите MySQL:

```bash
sudo pkill mysqld
sudo systemctl start mysql
```

**Проблема 2: MySQL не запущен**

Проверьте статус:

```bash
sudo systemctl status mysql
```

Запустите MySQL:

```bash
sudo systemctl start mysql
sudo systemctl enable mysql
```

**Проблема 3: Не знаете пароль root**

Попробуйте подключиться без пароля:

```bash
sudo mysql
```

Или сбросьте пароль (см. Проблема 1).

**Проблема 4: "Command 'mysql' not found"**

Установите MySQL клиент:

```bash
sudo apt-get update
sudo apt-get install mysql-client
```

Или используйте полный путь:

```bash
/usr/bin/mysql -u root -p123qweasd
```

### Шаг 2: Создание новой базы данных

Подключитесь к MySQL снова:

```bash
mysql -u root -p123qweasd
```

Создайте новую базу данных:

```sql
CREATE DATABASE eshop CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EXIT;
```

### Шаг 3: Импорт структуры базы данных

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

1. **Проверьте, что MySQL запущен:**
```bash
sudo systemctl status mysql
```

Если не запущен:
```bash
sudo systemctl start mysql
sudo systemctl enable mysql
```

2. **Проверьте пароль в конфигурации:**
```bash
grep "PASS" /var/www/eshop/core/init.php
```

3. **Попробуйте подключиться разными способами:**

Через sudo (без пароля):
```bash
sudo mysql
```

С паролем:
```bash
mysql -u root -p123qweasd eshop
```

С запросом пароля:
```bash
mysql -u root -p
```

4. **Если ничего не помогает, сбросьте пароль root:**

Остановите MySQL:
```bash
sudo systemctl stop mysql
```

Запустите в безопасном режиме:
```bash
sudo mysqld_safe --skip-grant-tables &
```

Подключитесь:
```bash
mysql -u root
```

В MySQL консоли:
```sql
USE mysql;
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '123qweasd';
FLUSH PRIVILEGES;
EXIT;
```

Остановите безопасный режим и запустите MySQL нормально:
```bash
sudo pkill mysqld
sudo systemctl start mysql
```

Теперь попробуйте подключиться:
```bash
mysql -u root -p123qweasd
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
