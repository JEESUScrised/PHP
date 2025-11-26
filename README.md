# Книжный магазин

Веб-приложение для продажи книг с админ-панелью.

## Быстрый запуск

### Windows
1. Дважды кликните на файл `start.bat`
2. Откройте браузер и перейдите на http://localhost:8000

### Linux/macOS
1. Откройте терминал в папке проекта
2. Выполните: `chmod +x start.sh && ./start.sh`
3. Откройте браузер и перейдите на http://localhost:8000

## Требования

- PHP 7.4+ с расширениями:
  - pdo_mysql
  - mysqli
- MySQL/MariaDB 5.7+
- Веб-браузер

## Установка зависимостей

### Windows
1. Скачайте PHP с https://windows.php.net/download/
2. Распакуйте в `C:\tools\php85\` (или другое место)
3. Добавьте PHP в PATH или укажите путь в `start.bat`
4. Установите MySQL/MariaDB или используйте XAMPP/WAMP

### Linux (Ubuntu/Debian)
```bash
sudo apt-get update
sudo apt-get install php php-mysql mysql-server
```

### macOS
```bash
brew install php mysql
```

## Настройка базы данных

База данных создается автоматически при первом запуске через `start.bat` или `start.sh`.

Если нужно настроить вручную:
1. Откройте MySQL: `mysql -u root`
2. Выполните: `source eshop/core/eshop.sql`

## Доступ к админ-панели

- URL: http://localhost:8000/enter
- Логин: `admin`
- Пароль: `admin123`

## Структура проекта

```
eshop/
├── app/              # Страницы приложения
│   ├── admin/        # Админ-панель
│   └── ...
├── core/             # Основные классы
├── css/              # Стили
├── skull-data/       # Данные для анимации черепа
└── index.php         # Точка входа
```

## Остановка сервера

Нажмите `Ctrl+C` в окне терминала/консоли, где запущен сервер.

