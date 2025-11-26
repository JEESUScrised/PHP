<?php
$itemId = Cleaner::uint($_GET['id'] ?? 0);
if ($itemId > 0) {
    try {
        Eshop::addItemToBasket($itemId, 1);
        ob_end_clean(); // Очищаем буфер перед редиректом
        header('Location: /catalog?added=1');
        exit;
    } catch (Exception $e) {
        ?>
        <div class="container">
            <div class="alert alert-error">Ошибка добавления товара в корзину: <?php echo htmlspecialchars($e->getMessage()); ?></div>
            <a href="/catalog" class="btn">← Вернуться в каталог</a>
        </div>
        <?php
    }
} else {
    ob_end_clean(); // Очищаем буфер перед редиректом
    header('Location: /catalog');
    exit;
}
