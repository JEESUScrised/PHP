@echo off
chcp 65001 >nul
echo ========================================
echo   Запуск книжного магазина
echo ========================================
echo.

REM Проверка наличия PHP
where php >nul 2>&1
if %errorlevel% neq 0 (
    echo [ОШИБКА] PHP не найден в PATH!
    echo.
    echo Установите PHP и добавьте его в PATH, или укажите полный путь к php.exe
    echo Например: C:\tools\php85\php.exe
    echo.
    pause
    exit /b 1
)

echo [OK] PHP найден
php -v | findstr /i "PHP"
echo.

REM Проверка наличия MySQL
where mysql >nul 2>&1
if %errorlevel% neq 0 (
    echo [ПРЕДУПРЕЖДЕНИЕ] MySQL не найден в PATH
    echo Убедитесь, что MySQL/MariaDB установлен и запущен
    echo.
) else (
    echo [OK] MySQL найден
    echo.
)

REM Проверка наличия базы данных
echo Проверка базы данных...
mysql -u root -e "USE eshop;" >nul 2>&1
if %errorlevel% neq 0 (
    echo [ИНФО] База данных не найдена. Создание базы данных...
    mysql -u root < eshop\core\eshop.sql
    if %errorlevel% neq 0 (
        echo [ОШИБКА] Не удалось создать базу данных
        echo Убедитесь, что MySQL запущен и пользователь root имеет права
        echo.
        pause
        exit /b 1
    )
    echo [OK] База данных создана
    echo.
    echo [ИНФО] Создание администратора...
    php setup_admin.php
    echo.
) else (
    echo [OK] База данных существует
    echo.
    REM Проверяем наличие администратора
    echo [ИНФО] Проверка администратора...
    php setup_admin.php >nul 2>&1
)

REM Переход в директорию проекта
cd /d "%~dp0eshop"

REM Запуск PHP сервера
echo ========================================
echo   Сервер запущен на http://localhost:8000
echo ========================================
echo.
echo Нажмите Ctrl+C для остановки сервера
echo.
php -S localhost:8000

