<div class="container">
    <div class="navbar">
        <a href="/admin" class="link-button">← Назад в админку</a>
        <a href="/catalog" class="link-button">Каталог</a>
    </div>
    
    <h1>Поступившие заказы</h1>
    
    <?php
    try {
        $orders = Eshop::getOrders();
        $hasOrders = false;
        
        foreach ($orders as $order) {
            $hasOrders = true;
            ?>
            <div class="order-card">
                <h2>Заказ № <?php echo htmlspecialchars($order->order_id); ?></h2>
                
                <div class="order-info">
                    <p><b>Заказчик:</b> <?php echo htmlspecialchars($order->customer); ?></p>
                    <p><b>Email:</b> <?php echo htmlspecialchars($order->email); ?></p>
                    <p><b>Телефон:</b> <?php echo htmlspecialchars($order->phone); ?></p>
                    <p><b>Адрес доставки:</b> <?php echo htmlspecialchars($order->address); ?></p>
                    <p><b>Дата размещения:</b> <?php echo htmlspecialchars($order->created); ?></p>
                </div>

                <h3>Купленные товары:</h3>
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
                </tr>
                </thead>
                <tbody>
                <?php
                $total = 0;
                $n = 1;
                foreach ($order->items as $item) {
                    $book = $item['book'];
                    $quantity = $item['quantity'];
                    $subtotal = $book->price * $quantity;
                    $total += $subtotal;
                    
                    echo "<tr>";
                    echo "<td>" . $n++ . "</td>";
                    echo "<td><strong>" . htmlspecialchars($book->title) . "</strong></td>";
                    echo "<td>" . htmlspecialchars($book->author) . "</td>";
                    echo "<td>" . htmlspecialchars($book->pubyear) . "</td>";
                    echo "<td>" . number_format($book->price, 2, '.', ' ') . " ₽</td>";
                    echo "<td><strong>" . htmlspecialchars($quantity) . "</strong></td>";
                    echo "<td><strong style='color: var(--primary-color);'>" . number_format($subtotal, 2, '.', ' ') . " ₽</strong></td>";
                    echo "</tr>";
                }
                ?>
                </tbody>
                </table>
                
                <div class="basket-summary">
                    <div class="total">Итого: <?php echo number_format($total, 2, '.', ' '); ?> ₽</div>
                </div>
            </div>
            <?php
        }
        
        if (!$hasOrders) {
            echo '<div class="empty-state"><p>Заказов пока нет</p></div>';
        }
    } catch (Exception $e) {
        echo '<div class="alert alert-error">Ошибка загрузки заказов: ' . htmlspecialchars($e->getMessage()) . '</div>';
    }
    ?>
</div>
