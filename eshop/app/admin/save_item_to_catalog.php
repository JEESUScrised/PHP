<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        // Очистка данных из формы
        $title = Cleaner::str($_POST['title'] ?? '');
        $author = Cleaner::str($_POST['author'] ?? '');
        $price = Cleaner::uint($_POST['price'] ?? 0);
        $pubyear = Cleaner::uint($_POST['pubyear'] ?? 0);

        // Валидация
        if (empty($title) || empty($author) || $price <= 0 || $pubyear <= 0) {
            throw new Exception('Все поля должны быть заполнены корректно');
        }

        // Создание объекта Book
        $book = new Book(null, $title, $author, $price, $pubyear);

        // Добавление в каталог
        Eshop::addItemToCatalog($book);

        // Переадресация обратно на форму
        ob_end_clean(); // Очищаем буфер перед редиректом
        header('Location: /admin/add_item_to_catalog?success=1');
        exit;
    } catch (Exception $e) {
        ?>
        <div class="container">
            <div class="alert alert-error">Ошибка: <?php echo htmlspecialchars($e->getMessage()); ?></div>
            <a href="/admin/add_item_to_catalog" class="btn">← Вернуться назад</a>
        </div>
        <?php
    }
} else {
    ob_end_clean(); // Очищаем буфер перед редиректом
    header('Location: /admin/add_item_to_catalog');
    exit;
}
