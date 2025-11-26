# Развертывание проекта на Ubuntu Server

## Быстрый старт

### 1. Подготовка

Подключитесь к вашему Ubuntu серверу через VNC или SSH.

### 2. Копирование файлов на сервер

Скопируйте папку `deploy` на сервер:

```bash
# С вашего компьютера
scp -r deploy/ user@your-server-ip:/tmp/
```

Или клонируйте репозиторий на сервере:

```bash
cd /tmp
git clone https://github.com/JEESUScrised/PHP.git -b kt3 kt3
cp -r kt3/deploy /tmp/
```

### 3. Установка

Выполните скрипт установки:

```bash
cd /tmp/deploy
chmod +x install.sh
sudo bash install.sh
```

Скрипт запросит:
- Доменное имя (например: `example.com`)
- Пароль для MySQL root (или нажмите Enter для автоматической генерации)

### 4. Настройка DNS

В панели управления вашего доменного регистратора добавьте DNS записи:

- **A запись**: `@` → IP адрес вашего сервера
- **A запись**: `www` → IP адрес вашего сервера

Подождите 5-30 минут для распространения DNS.

### 5. Настройка SSL (HTTPS)

После настройки DNS выполните:

```bash
sudo certbot --apache -d ваш-домен.com -d www.ваш-домен.com
```

### 6. Создание администратора

```bash
cd /var/www/eshop
sudo php setup_admin.php
```

По умолчанию:
- **Логин**: `admin`
- **Пароль**: `admin123`

**ВАЖНО**: Смените пароль после первого входа!

## Обновление проекта

Для обновления проекта используйте:

```bash
cd /tmp/deploy
chmod +x quick-deploy.sh
sudo bash quick-deploy.sh
```

## Структура файлов

- `install.sh` - Полная установка сервера и проекта
- `deploy.sh` - Развертывание с резервным копированием
- `quick-deploy.sh` - Быстрое обновление проекта
- `DEPLOY.md` - Подробная инструкция
- `.htaccess` - Конфигурация Apache для роутинга

## Полезные команды

### Проверка статуса Apache
```bash
sudo systemctl status apache2
```

### Просмотр логов
```bash
sudo tail -f /var/log/apache2/error.log
sudo tail -f /var/www/eshop/app/admin/error.log
```

### Перезапуск Apache
```bash
sudo systemctl restart apache2
```

### Проверка SSL сертификата
```bash
sudo certbot certificates
```

## Устранение проблем

### Ошибка MySQL: Access denied for user "root@localhost"

Если при установке возникает ошибка доступа к MySQL:

**Вариант 1: Использовать скрипт настройки MySQL**
```bash
cd /tmp/deploy
chmod +x setup-mysql.sh
sudo bash setup-mysql.sh
```

**Вариант 2: Настроить вручную**
```bash
sudo mysql
```

В MySQL консоли выполните:
```sql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'ваш_пароль';
FLUSH PRIVILEGES;
EXIT;
```

Затем создайте базу данных:
```bash
mysql -u root -p < /var/www/eshop/core/eshop.sql
```

**Вариант 3: Если MySQL не запущен**
```bash
sudo systemctl start mysql
sudo systemctl enable mysql
```

### Ошибка 403 Forbidden
```bash
sudo chown -R www-data:www-data /var/www/eshop
sudo chmod -R 755 /var/www/eshop
```

### Ошибка подключения к БД
Проверьте настройки в `/var/www/eshop/core/init.php`:
```php
const DB = [
    'HOST' => 'localhost',
    'USER' => 'root',
    'PASS' => 'ваш_пароль',
    'NAME' => 'eshop',
];
```

Пароль MySQL root можно найти в: `/root/mysql_root_password.txt`

### Проблемы с роутингом
Убедитесь, что файл `.htaccess` существует в `/var/www/eshop/` и модуль `mod_rewrite` включен:
```bash
sudo a2enmod rewrite
sudo systemctl restart apache2
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

## Поддержка

При возникновении проблем проверьте:
1. Логи Apache: `/var/log/apache2/error.log`
2. Логи приложения: `/var/www/eshop/app/admin/error.log`
3. Статус сервисов: `sudo systemctl status apache2 mysql`

