<?php
/**
 * Скрипт для создания администратора
 * Запускается автоматически при первом запуске или вручную
 */

require_once 'eshop/core/init.php';

// Инициализация БД
Eshop::init(DB);

try {
    // Проверяем, есть ли уже администратор
    $testUser = new User('admin', '');
    $existingAdmin = Eshop::userGet($testUser);
    
    if ($existingAdmin) {
        echo "Администратор уже существует.\n";
        echo "Логин: admin\n";
        exit(0);
    }
    
    // Создаем администратора
    $admin = new User('admin', 'admin123', 'admin@email.info');
    
    Eshop::userAdd($admin);
    
    echo "========================================\n";
    echo "  Администратор успешно создан!\n";
    echo "========================================\n";
    echo "Логин: admin\n";
    echo "Пароль: admin123\n";
    echo "========================================\n";
    
} catch (Exception $e) {
    echo "Ошибка при создании администратора: " . $e->getMessage() . "\n";
    exit(1);
}

