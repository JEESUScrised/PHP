# Настройка проекта с существующей базой данных

Если у вас уже есть настроенная база данных MySQL с паролем, используйте этот скрипт для быстрой настройки проекта.

## Использование

### Шаг 1: Клонирование проекта

```bash
cd /tmp
git clone https://github.com/JEESUScrised/PHP.git -b kt3 kt3
cd kt3/deploy
```

### Шаг 2: Копирование проекта на сервер

```bash
sudo mkdir -p /var/www/eshop
sudo cp -r ../eshop/* /var/www/eshop/
sudo cp -r ../skull /var/www/eshop/ 2>/dev/null || true
sudo cp ../setup_admin.php /var/www/eshop/ 2>/dev/null || true
```

### Шаг 3: Запуск скрипта настройки

```bash
chmod +x setup-existing-db.sh
sudo bash setup-existing-db.sh
```

Скрипт:
- Проверит подключение к MySQL с паролем `123qweasd`
- Проверит существование базы данных `eshop`
- Создаст БД и структуру, если их нет
- Обновит конфигурацию в `init.php` с правильным паролем
- Создаст администратора, если его нет
- Настроит права доступа

## Ручная настройка

Если скрипт не подходит, настройте вручную:

### 1. Обновите конфигурацию БД

Отредактируйте `/var/www/eshop/core/init.php`:

```php
const DB = [
    'HOST' => 'localhost',
    'USER' => 'root',
    'PASS' => '123qweasd',
    'NAME' => 'eshop',
];
```

### 2. Создайте базу данных (если нужно)

```bash
mysql -u root -p123qweasd < /var/www/eshop/core/eshop.sql
```

### 3. Создайте администратора

```bash
cd /var/www/eshop
sudo php setup_admin.php
```

### 4. Настройте права доступа

```bash
sudo chown -R www-data:www-data /var/www/eshop
sudo chmod -R 755 /var/www/eshop
```

## Изменение пароля БД

Если нужно использовать другой пароль, отредактируйте скрипт:

```bash
nano setup-existing-db.sh
```

Измените строку:
```bash
MYSQL_ROOT_PASSWORD="ваш_новый_пароль"
```

Затем запустите скрипт снова.

## Проверка работы

1. Проверьте подключение к БД:
```bash
mysql -u root -p123qweasd eshop
```

2. Проверьте конфигурацию:
```bash
grep "PASS" /var/www/eshop/core/init.php
```

3. Откройте сайт в браузере и проверьте работу

