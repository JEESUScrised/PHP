<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        $login = Cleaner::str($_POST['login'] ?? '');
        $password = $_POST['password'] ?? '';
        $email = Cleaner::str($_POST['email'] ?? '');

        if (empty($login) || empty($password) || empty($email)) {
            throw new Exception('Все поля должны быть заполнены');
        }

        $user = new User($login);
        if (Eshop::userCheck($user)) {
            throw new Exception('Пользователь с таким логином уже существует');
        }

        $user = new User($login, $password, $email);

        Eshop::userAdd($user);

        ob_end_clean();
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
    ob_end_clean();
    header('Location: /admin/create_user');
    exit;
}
