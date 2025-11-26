<?php
$itemId = Cleaner::uint($_GET['id'] ?? 0);
if ($itemId > 0) {
    try {
        Eshop::removeItemFromBasket($itemId);
        ob_end_clean(); // Очищаем буфер перед редиректом
        header('Location: /basket?removed=1');
        exit;
    } catch (Exception $e) {
        ?>
        <div class="container">
            <div class="alert alert-error">Ошибка удаления товара из корзины: <?php echo htmlspecialchars($e->getMessage()); ?></div>
            <a href="/basket" class="btn">← Вернуться в корзину</a>
        </div>
        <?php
    }
} else {
    ob_end_clean(); // Очищаем буфер перед редиректом
    header('Location: /basket');
    exit;
}
