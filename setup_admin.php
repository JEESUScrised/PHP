<?php
$initPath = __DIR__ . '/core/init.php';
if (!file_exists($initPath)) {
    $initPath = __DIR__ . '/eshop/core/init.php';
}
require_once $initPath;

Eshop::init(DB);

try {
    $testUser = new User('admin', '');
    $existingAdmin = Eshop::userGet($testUser);
    
    if ($existingAdmin) {
        echo "Администратор уже существует.\n";
        echo "Логин: admin\n";
        exit(0);
    }
    
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

