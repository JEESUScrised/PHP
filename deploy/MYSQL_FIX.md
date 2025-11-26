# Решение проблемы доступа к MySQL

Если вы получаете ошибку "Access denied for user 'root'@'localhost'", выполните следующие шаги:

## Быстрое решение

Выполните на сервере:

```bash
cd /tmp/deploy
chmod +x fix-mysql.sh
sudo bash fix-mysql.sh
```

Этот скрипт автоматически попробует несколько способов подключения к MySQL и установит пароль.

## Ручное решение

### Шаг 1: Подключитесь к MySQL без пароля

```bash
sudo mysql
```

Если это не работает, попробуйте:

```bash
mysql -u root
```

### Шаг 2: В MySQL консоли выполните

```sql
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'ваш_пароль';
FLUSH PRIVILEGES;
EXIT;
```

Замените `ваш_пароль` на желаемый пароль.

### Шаг 3: Проверьте подключение

```bash
mysql -u root -p
```

Введите пароль, который вы установили.

### Шаг 4: Создайте базу данных

```bash
mysql -u root -p < /var/www/eshop/core/eshop.sql
```

## Если ничего не помогает

### Вариант 1: Сброс пароля через безопасный режим

```bash
sudo systemctl stop mysql
sudo mysqld_safe --skip-grant-tables --skip-networking &
```

В другом терминале:

```bash
mysql -u root
```

В MySQL:

```sql
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'новый_пароль';
FLUSH PRIVILEGES;
EXIT;
```

Затем остановите безопасный режим:

```bash
sudo pkill mysqld
sudo systemctl start mysql
```

### Вариант 2: Переустановка MySQL

```bash
sudo apt-get remove --purge mysql-server mysql-client mysql-common mysql-server-core-* mysql-client-core-*
sudo rm -rf /var/lib/mysql
sudo apt-get autoremove
sudo apt-get autoclean
sudo apt-get install mysql-server
sudo mysql_secure_installation
```

## Проверка статуса MySQL

```bash
sudo systemctl status mysql
```

Если MySQL не запущен:

```bash
sudo systemctl start mysql
sudo systemctl enable mysql
```

## Сохранение пароля

После успешной настройки сохраните пароль:

```bash
echo "ваш_пароль" | sudo tee /root/mysql_root_password.txt
sudo chmod 600 /root/mysql_root_password.txt
```

Это позволит скриптам автоматически использовать пароль в будущем.

