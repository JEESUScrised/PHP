<div class="container">
    <div class="navbar">
        <a href="/catalog" class="link-button">← Вернуться в каталог</a>
    </div>
    
    <h1>Вход в админку</h1>
    
    <form action="/login" method="post">
        <div>
            <label>Логин:</label>
            <input type="text" name="login" placeholder="Введите логин" required autofocus>
        </div>
        <div>
            <label>Пароль:</label>
            <input type="password" name="password" placeholder="Введите пароль" required>
        </div>
        <div>
            <input type="submit" value="Войти" class="btn btn-large">
        </div>
    </form>
</div>