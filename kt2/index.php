<?php
session_start();

$message = '';
$messageType = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['captcha_input'])) {
    $userInput = trim($_POST['captcha_input']);
    
    if (isset($_SESSION['captcha_code'])) {
        if (strtolower($userInput) === strtolower($_SESSION['captcha_code'])) {
            $message = 'CAPTCHA введена правильно.';
            $messageType = 'success';
            unset($_SESSION['captcha_code']);
        } else {
            $message = 'Введённый код не совпадает с изображением.';
            $messageType = 'error';
        }
    } else {
        $message = 'Ошибка: CAPTCHA не найдена. Обновите страницу.';
        $messageType = 'error';
    }
}
?>
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CAPTCHA Проверка</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 600px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background-color: white;
            padding: 30px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            text-align: center;
        }
        .captcha-container {
            margin: 20px 0;
            text-align: center;
        }
        .captcha-image {
            border: 2px solid #ddd;
            border-radius: 5px;
            margin-bottom: 10px;
        }
        .refresh-link {
            display: inline-block;
            margin-top: 10px;
            color: #007bff;
            text-decoration: none;
            font-size: 14px;
        }
        .refresh-link:hover {
            text-decoration: underline;
        }
        .form-group {
            margin: 20px 0;
        }
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #555;
        }
        input[type="text"] {
            width: 100%;
            padding: 10px;
            font-size: 16px;
            border: 2px solid #ddd;
            border-radius: 5px;
            box-sizing: border-box;
        }
        input[type="text"]:focus {
            outline: none;
            border-color: #007bff;
        }
        button {
            width: 100%;
            padding: 12px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
        }
        button:hover {
            background-color: #0056b3;
        }
        .message {
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
            text-align: center;
            font-weight: bold;
        }
        .message.success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .message.error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Проверка CAPTCHA</h1>
        
        <?php if ($message): ?>
            <div class="message <?php echo $messageType; ?>">
                <?php echo htmlspecialchars($message); ?>
            </div>
        <?php endif; ?>
        
        <form method="POST" action="">
            <div class="captcha-container">
                <img src="captcha.php" alt="CAPTCHA" class="captcha-image" id="captchaImage">
                <br>
                <a href="#" class="refresh-link" onclick="refreshCaptcha(); return false;">Обновить изображение</a>
            </div>
            
            <div class="form-group">
                <label for="captcha_input">Введите текст с изображения:</label>
                <input type="text" id="captcha_input" name="captcha_input" required autocomplete="off" autofocus>
            </div>
            
            <button type="submit">Проверить</button>
        </form>
    </div>
    
    <script>
        function refreshCaptcha() {
            var img = document.getElementById('captchaImage');
            img.src = 'captcha.php?' + new Date().getTime();
        }
    </script>
</body>
</html>

