<div class="container">
    <div class="navbar">
        <a href="/admin" class="link-button">← Назад в админку</a>
        <a href="/catalog" class="link-button">Каталог</a>
    </div>
    
    <h1>Добавить товар в каталог</h1>
    
    <?php if (isset($_GET['success'])): ?>
    <div class="alert alert-success">Товар успешно добавлен в каталог!</div>
    <?php endif; ?>
    
    <form action="save_item_to_catalog" method="post">
        <div>
            <label>Название книги:</label> 
            <input type="text" name="title" placeholder="Введите название книги" required>
        </div>
        <div>
            <label>Автор:</label>
            <input type="text" name="author" placeholder="Введите имя автора" required>
        </div>
        <div>
            <label>Год издания:</label> 
            <input type="number" name="pubyear" placeholder="2024" min="1000" max="9999" required>
        </div>
        <div>
            <label>Цена (руб.):</label> 
            <input type="number" name="price" placeholder="0.00" step="0.01" min="0" required>
        </div>
        <div>
            <input type="submit" value="Добавить товар" class="btn btn-success btn-large">
        </div>
    </form>
</div>
