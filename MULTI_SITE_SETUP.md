# Настройка нескольких сайтов на одном сервере

## Обзор

На одном сервере можно разместить несколько сайтов, используя виртуальные хосты Apache. Каждый сайт будет иметь свой домен или поддомен.

## Структура

```
/var/www/
├── eshop/          # Первый сайт (jeesuscrised.ru)
├── site2/          # Второй сайт
└── site3/          # Третий сайт
```

## Шаги настройки

### 1. Создание директории для нового сайта

```bash
sudo mkdir -p /var/www/site2
sudo chown -R www-data:www-data /var/www/site2
sudo chmod -R 755 /var/www/site2
```

### 2. Создание конфигурации виртуального хоста

```bash
sudo nano /etc/apache2/sites-available/site2.conf
```

Содержимое файла:

```apache
<VirtualHost *:80>
    ServerName site2.example.com
    ServerAlias www.site2.example.com
    
    DocumentRoot /var/www/site2
    
    <Directory /var/www/site2>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/site2_error.log
    CustomLog ${APACHE_LOG_DIR}/site2_access.log combined
</VirtualHost>
```

### 3. Активация сайта

```bash
sudo a2ensite site2.conf
sudo systemctl reload apache2
```

### 4. Настройка DNS

Добавьте A-запись в DNS для нового домена:
- `site2.example.com` → IP вашего сервера
- `www.site2.example.com` → IP вашего сервера

### 5. Проверка

```bash
# Проверка конфигурации
sudo apache2ctl configtest

# Проверка активных сайтов
ls -la /etc/apache2/sites-enabled/

# Проверка логов
sudo tail -f /var/log/apache2/site2_error.log
```

## Примеры конфигураций

### Сайт на поддомене

```apache
<VirtualHost *:80>
    ServerName blog.jeesuscrised.ru
    DocumentRoot /var/www/blog
    # ... остальная конфигурация
</VirtualHost>
```

### Сайт на другом домене

```apache
<VirtualHost *:80>
    ServerName anotherdomain.com
    ServerAlias www.anotherdomain.com
    DocumentRoot /var/www/anotherdomain
    # ... остальная конфигурация
</VirtualHost>
```

### Сайт на другом порту

```apache
<VirtualHost *:8080>
    ServerName site2.example.com
    DocumentRoot /var/www/site2
    # ... остальная конфигурация
</VirtualHost>
```

И добавьте в `/etc/apache2/ports.conf`:
```
Listen 8080
```

## SSL для нескольких сайтов

Для каждого сайта можно получить SSL сертификат:

```bash
sudo certbot --apache -d site2.example.com -d www.site2.example.com
```

## Управление сайтами

### Отключить сайт
```bash
sudo a2dissite site2.conf
sudo systemctl reload apache2
```

### Включить сайт
```bash
sudo a2ensite site2.conf
sudo systemctl reload apache2
```

### Удалить сайт
```bash
sudo a2dissite site2.conf
sudo rm /etc/apache2/sites-available/site2.conf
sudo systemctl reload apache2
```

## Ограничения

- **Память**: Каждый сайт использует память сервера
- **CPU**: Все сайты делят процессорное время
- **Диск**: Убедитесь, что достаточно места на диске
- **Порты**: По умолчанию все сайты используют порт 80 (HTTP) и 443 (HTTPS)

## Рекомендации

1. Используйте отдельные директории для каждого сайта
2. Настройте отдельные логи для каждого сайта
3. Используйте SSL для всех сайтов
4. Регулярно проверяйте использование ресурсов
5. Настройте мониторинг для каждого сайта

## Проверка текущих сайтов

```bash
# Список всех доступных сайтов
ls -la /etc/apache2/sites-available/

# Список активных сайтов
ls -la /etc/apache2/sites-enabled/

# Проверка конфигурации
sudo apache2ctl -S
```

