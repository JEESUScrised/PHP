<?php
/**
 * Скрипт для создания пользователя через командную строку
 * Использование: php create_user.php <login> <password> <email>
 * Пример: php create_user.php admin admin123 admin@email.info
 */

// Определяем правильный путь к init.php
$initPath = __DIR__ . '/core/init.php';
if (!file_exists($initPath)) {
    // Если не найден, пробуем путь из корня проекта
    $initPath = __DIR__ . '/eshop/core/init.php';
}
require_once $initPath;

// Инициализация БД
Eshop::init(DB);

// Получение параметров из командной строки или запрос ввода
if ($argc >= 4) {
    $login = $argv[1];
    $password = $argv[2];
    $email = $argv[3];
} else {
    echo "Создание пользователя\n";
    echo "====================\n\n";
    
    echo "Введите логин: ";
    $login = trim(fgets(STDIN));
    
    echo "Введите пароль: ";
    $password = trim(fgets(STDIN));
    
    echo "Введите email: ";
    $email = trim(fgets(STDIN));
}

try {
    // Валидация
    if (empty($login) || empty($password) || empty($email)) {
        throw new Exception('Все поля должны быть заполнены');
    }
    
    // Проверка существования пользователя
    $testUser = new User($login, '');
    $existingUser = Eshop::userGet($testUser);
    
    if ($existingUser) {
        echo "ОШИБКА: Пользователь с логином '$login' уже существует.\n";
        exit(1);
    }
    
    // Создание пользователя
    $user = new User($login, $password, $email);
    Eshop::userAdd($user);
    
    echo "\n========================================\n";
    echo "  Пользователь успешно создан!\n";
    echo "========================================\n";
    echo "Логин: $login\n";
    echo "Пароль: $password\n";
    echo "Email: $email\n";
    echo "========================================\n";
    
} catch (Exception $e) {
    echo "\nОШИБКА: " . $e->getMessage() . "\n";
    exit(1);
}

