<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        // Очистка данных из формы
        $login = Cleaner::str($_POST['login'] ?? '');
        $password = $_POST['password'] ?? '';
        $email = Cleaner::str($_POST['email'] ?? '');

        // Валидация
        if (empty($login) || empty($password) || empty($email)) {
            throw new Exception('Все поля должны быть заполнены');
        }

        // Проверка существования пользователя
        $user = new User($login);
        if (Eshop::userCheck($user)) {
            throw new Exception('Пользователь с таким логином уже существует');
        }

        // Создание объекта User
        $user = new User($login, $password, $email);

        // Добавление пользователя
        Eshop::userAdd($user);

        // Переадресация обратно на форму
        ob_end_clean(); // Очищаем буфер перед редиректом
        header('Location: /admin/create_user?success=1');
        exit;
    } catch (Exception $e) {
        ?>
        <div class="container">
            <div class="alert alert-error">Ошибка: <?php echo htmlspecialchars($e->getMessage()); ?></div>
            <a href="/admin/create_user" class="btn">← Вернуться назад</a>
        </div>
        <?php
    }
} else {
    ob_end_clean(); // Очищаем буфер перед редиректом
    header('Location: /admin/create_user');
    exit;
}
