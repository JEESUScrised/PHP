<div class="container">
    <div class="navbar">
        <a href="/admin" class="link-button">← Назад в админку</a>
        <a href="/catalog" class="link-button">Каталог</a>
    </div>
    
    <h1>Добавить пользователя</h1>
    
    <?php if (isset($_GET['success'])): ?>
    <div class="alert alert-success">Пользователь успешно создан!</div>
    <?php endif; ?>
    
    <form action="save_user" method="post">
        <div>
            <label>Логин:</label> 
            <input type="text" name="login" placeholder="Введите логин" required>
        </div>
        <div>
            <label>Пароль:</label> 
            <input type="password" name="password" placeholder="Введите пароль" required>
        </div>
        <div>
            <label>Email:</label> 
            <input type="email" name="email" placeholder="user@example.com" required>
        </div>
        <div>
            <input type="submit" value="Создать пользователя" class="btn btn-success btn-large">
        </div>
    </form>
</div>