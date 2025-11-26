<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        // Проверка, что корзина не пуста
        if (Basket::isEmpty()) {
            throw new Exception('Корзина пуста');
        }

        // Очистка данных из формы
        $customer = Cleaner::str($_POST['customer'] ?? '');
        $email = Cleaner::str($_POST['email'] ?? '');
        $phone = Cleaner::str($_POST['phone'] ?? '');
        $address = Cleaner::str($_POST['address'] ?? '');

        // Валидация
        if (empty($customer) || empty($email) || empty($phone) || empty($address)) {
            throw new Exception('Все поля должны быть заполнены');
        }

        // Создание объекта Order
        $order = new Order($customer, $email, $phone, $address);

        // Сохранение заказа
        Eshop::saveOrder($order);

        // Переадресация на каталог
        ob_end_clean(); // Очищаем буфер перед редиректом
        header('Location: /catalog?order=success');
        exit;
    } catch (Exception $e) {
        ?>
        <div class="container">
            <div class="alert alert-error">Ошибка: <?php echo htmlspecialchars($e->getMessage()); ?></div>
            <a href="/create_order" class="btn">← Вернуться назад</a>
        </div>
        <?php
    }
} else {
    ob_end_clean(); // Очищаем буфер перед редиректом
    header('Location: /create_order');
    exit;
}
