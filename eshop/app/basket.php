<div class="container">
    <div class="navbar">
        <a href="/catalog" class="link-button">← Вернуться в каталог</a>
    </div>
    
    <h1>Ваша корзина</h1>
    
    <?php if (isset($_GET['removed']) && $_GET['removed'] === '1'): ?>
    <div class="alert alert-success">Товар удален из корзины</div>
    <?php endif; ?>
    
    <?php
    try {
        $items = Eshop::getItemsFromBasket();
        $total = 0;
        $itemCount = 0;
        $n = 1;
        
        if (count(iterator_to_array($items)) > 0):
    ?>
    
    <table>
    <thead>
    <tr>
        <th>№</th>
        <th>Название</th>
        <th>Автор</th>
        <th>Год</th>
        <th>Цена за шт.</th>
        <th>Количество</th>
        <th>Сумма</th>
        <th>Действие</th>
    </tr>
    </thead>
    <tbody>
    <?php
        foreach ($items as $item) {
            $book = $item['book'];
            $quantity = $item['quantity'];
            $subtotal = $book->price * $quantity;
            $total += $subtotal;
            $itemCount += $quantity;
            
            echo "<tr>";
            echo "<td>" . $n++ . "</td>";
            echo "<td><strong>" . htmlspecialchars($book->title) . "</strong></td>";
            echo "<td>" . htmlspecialchars($book->author) . "</td>";
            echo "<td>" . htmlspecialchars($book->pubyear) . "</td>";
            echo "<td>" . number_format($book->price, 2, '.', ' ') . " ₽</td>";
            echo "<td><strong>" . htmlspecialchars($quantity) . "</strong></td>";
            echo "<td><strong style='color: var(--primary-color);'>" . number_format($subtotal, 2, '.', ' ') . " ₽</strong></td>";
            echo "<td><a href='/remove_item_from_basket?id=" . $book->id . "' class='link-button link-danger'>Удалить</a></td>";
            echo "</tr>";
        }
    ?>
    </tbody>
    </table>
    
    <div class="basket-summary">
        <div>Всего товаров: <strong><?php echo $itemCount; ?></strong></div>
        <div class="total">Итого: <?php echo number_format($total, 2, '.', ' '); ?> ₽</div>
    </div>
    
    <a href="/create_order" class="btn btn-success btn-large btn-center">Оформить заказ</a>
    
    <?php
        else:
    ?>
    <div class="empty-state">
        <p>Ваша корзина пуста</p>
        <a href="/catalog" class="btn btn-center">Перейти в каталог</a>
    </div>
    <?php
        endif;
    } catch (Exception $e) {
        echo "<div class='alert alert-error'>Ошибка загрузки корзины: " . htmlspecialchars($e->getMessage()) . "</div>";
    }
    ?>
</div>
