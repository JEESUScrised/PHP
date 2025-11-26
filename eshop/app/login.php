<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        // Очистка данных из формы
        $login = Cleaner::str($_POST['login'] ?? '');
        $password = $_POST['password'] ?? ''; // Пароль НЕ очищаем через Cleaner, чтобы не потерять спецсимволы

        // Валидация
        if (empty($login) || empty($password)) {
            throw new Exception('Логин и пароль обязательны для заполнения');
        }

        // Создание объекта User
        $user = new User($login, $password);

        // Попытка входа
        if (Eshop::logIn($user)) {
            ob_end_clean(); // Очищаем буфер перед редиректом
            header('Location: /admin');
            exit;
        } else {
            // Дополнительная проверка для отладки
            $dbUser = Eshop::userGet($user);
            if (!$dbUser) {
                throw new Exception('Пользователь с таким логином не найден');
            } else {
                throw new Exception('Неверный пароль. Проверьте правильность ввода.');
            }
        }
    } catch (Exception $e) {
        ?>
        <div class="container">
            <div class="alert alert-error">Ошибка: <?php echo htmlspecialchars($e->getMessage()); ?></div>
            <a href="/enter" class="btn">← Вернуться назад</a>
        </div>
        <?php
    }
} else {
    ob_end_clean(); // Очищаем буфер перед редиректом
    header('Location: /enter');
    exit;
}

