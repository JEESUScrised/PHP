<div class="container">
    <div class="navbar">
        <div>
            <a href="/catalog" class="link-button">Главная</a>
            <a href="/basket" class="link-button">Корзина</a>
        </div>
        <div>
            <a href="/skull" class="glitch-button"><span class="glitch-text">№@*^&$|?</span></a>
            <?php if (Eshop::isAdmin()): ?>
                <a href="/admin" class="link-button">Админка</a>
            <?php else: ?>
                <a href="/enter" class="link-button">Вход</a>
            <?php endif; ?>
        </div>
    </div>
    
    <h1>Каталог товаров</h1>
    
    <?php if (isset($_GET['order']) && $_GET['order'] === 'success'): ?>
    <div class="alert alert-success">Заказ успешно оформлен! Спасибо за покупку!</div>
    <?php endif; ?>
    
    <?php if (isset($_GET['added']) && $_GET['added'] === '1'): ?>
    <div class="alert alert-success">Товар добавлен в корзину!</div>
    <?php endif; ?>
    
    <?php
    $basket = Basket::get();
    $itemCount = 0;
    foreach ($basket as $key => $value) {
        if ($key !== 'order-id' && is_numeric($key)) {
            $itemCount += (int)$value;
        }
    }
    ?>
    
    <?php if ($itemCount > 0): ?>
    <div class="basket-info">
        <span>Товаров в корзине: <?php echo $itemCount; ?></span>
        <a href="/basket" style="color: white; text-decoration: underline;">Перейти в корзину →</a>
    </div>
    <?php endif; ?>
    
    <table>
    <thead>
    <tr>
        <th>Название</th>
        <th>Автор</th>
        <th>Год издания</th>
        <th>Цена, руб.</th>
        <th>Действие</th>
    </tr>
    </thead>
    <tbody>
    <?php
    try {
        $items = Eshop::getItemsFromCatalog();
        $hasItems = false;
        foreach ($items as $book) {
            $hasItems = true;
            echo "<tr>";
            echo "<td><strong>" . htmlspecialchars($book->title) . "</strong></td>";
            echo "<td>" . htmlspecialchars($book->author) . "</td>";
            echo "<td>" . htmlspecialchars($book->pubyear) . "</td>";
            echo "<td><strong style='color: var(--primary-color);'>" . number_format($book->price, 2, '.', ' ') . " ₽</strong></td>";
            echo "<td><a href='/add_item_to_basket?id=" . $book->id . "' class='link-button'>Добавить</a></td>";
            echo "</tr>";
        }
        if (!$hasItems) {
            echo "<tr><td colspan='5' class='empty-state'>Каталог пуст. Добавьте товары через админку.</td></tr>";
        }
    } catch (Exception $e) {
        echo "<tr><td colspan='5'><div class='alert alert-error'>Ошибка загрузки каталога: " . htmlspecialchars($e->getMessage()) . "</div></td></tr>";
    }
    ?>
    </tbody>
    </table>
</div>
