<div class="container">
    <div class="navbar">
        <a href="/basket" class="link-button">← Вернуться в корзину</a>
        <a href="/catalog" class="link-button">Каталог</a>
    </div>
    
    <h1>Оформление заказа</h1>
    
    <form action="save_order" method="post">
        <div>
            <label>Заказчик (ФИО):</label>
            <input type="text" name="customer" placeholder="Введите ваше полное имя" required />
        </div>
        <div>
            <label>Email заказчика:</label>
            <input type="email" name="email" placeholder="example@email.com" required />
        </div>
        <div>
            <label>Телефон для связи:</label>
            <input type="tel" name="phone" placeholder="+7 (999) 123-45-67" required />
        </div>
        <div>
            <label>Адрес доставки:</label>
            <input type="text" name="address" placeholder="Город, улица, дом, квартира" required />
        </div>
        <div>
            <input type="submit" value="Оформить заказ" class="btn btn-success btn-large" />
        </div>
    </form>
</div>