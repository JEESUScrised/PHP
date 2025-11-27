<?php
const CORE_DIR = 'core/';
const APP_DIR = 'app/';
const ADMIN_DIR = APP_DIR . 'admin/';

/* 
    ////////////////////////////////////
    ////// ЭТОТ БЛОК ДЛЯ ОТЛАДКИ //////
    ///////////////////////////////////
*/
set_include_path(get_include_path() . PATH_SEPARATOR . CORE_DIR . PATH_SEPARATOR . APP_DIR . PATH_SEPARATOR . ADMIN_DIR);
spl_autoload_extensions('.class.php');
spl_autoload_register();

// Явная загрузка классов для надежности
require_once __DIR__ . "/Eshop.class.php";
require_once __DIR__ . "/Book.class.php";
require_once __DIR__ . "/User.class.php";
require_once __DIR__ . "/Order.class.php";
require_once __DIR__ . "/Basket.class.php";

const ERROR_LOG = ADMIN_DIR . 'error.log';
const ERROR_MSG = 'Срочно обратитесь к администратору! admin@email.info';
function errors_log($msg, $file, $line){
    $dt = date('d-m-Y H:i:s');
    $message = "$dt - $msg in $file:$line\n";
    error_log($message, 3, ERROR_LOG);
    echo ERROR_MSG;
}
function error_handler($no, $msg, $file, $line) {
    errors_log($msg, $file, $line);
}
set_error_handler('error_handler');
function exception_handler($e) {
    // Не обрабатываем исключения, которые уже обрабатываются в try-catch
    // Это позволит try-catch блокам корректно обрабатывать свои исключения
    if (error_get_last() === null) {
        errors_log($e->getMessage(), $e->getFile(), $e->getLine());
    }
}
set_exception_handler('exception_handler');
/* 
    //////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////
*/
const DB = [
    'HOST' => 'localhost',
    'USER' => 'root',
    'PASS' => '',
    'NAME' => 'eshop',
];

// Открытие сессии
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// Проверка доступа к админке (кроме страниц входа) - ДО инициализации и вывода HTML
$path = parse_url($_SERVER['REQUEST_URI'] ?? '', PHP_URL_PATH);
$path = rtrim($path, '/');
$adminPaths = ['/admin', '/admin/add_item_to_catalog', '/admin/save_item_to_catalog', 
               '/admin/orders', '/admin/create_user', '/admin/save_user', '/admin/logout'];
$isAdminPath = in_array($path, $adminPaths);

if ($isAdminPath && $path !== '/enter' && $path !== '/login') {
    // Проверяем сессию напрямую, без подключения к БД
    if (!isset($_SESSION['admin']) || $_SESSION['admin'] !== true) {
        if (!headers_sent()) {
            header('Location: /enter');
            exit;
        }
    }
}

// Инициализация приложения
try {
    // Временно отключаем глобальный обработчик исключений для корректной обработки ошибок БД
    $oldExceptionHandler = set_exception_handler(null);
    Eshop::init(DB);
    // Восстанавливаем обработчик после успешной инициализации
    if ($oldExceptionHandler) {
        set_exception_handler($oldExceptionHandler);
    } else {
        set_exception_handler('exception_handler');
    }
} catch (Exception $e) {
    // Восстанавливаем обработчик перед обработкой ошибки
    set_exception_handler('exception_handler');
    $errorMsg = $e->getMessage();
    if (strpos($errorMsg, 'could not find driver') !== false) {
        // Выводим ошибку только если заголовки еще не отправлены
        if (!headers_sent()) {
            header('Content-Type: text/html; charset=utf-8');
        }
        die('
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <title>Ошибка конфигурации</title>
        </head>
        <body>
        <h1>Ошибка конфигурации PHP</h1>
        <p><b>Проблема:</b> Не установлен драйвер PDO для MySQL.</p>
        <p><b>Решение:</b></p>
        <ol>
            <li>Откройте файл php.ini: <code>C:\tools\php85\php.ini</code></li>
            <li>Найдите и раскомментируйте (уберите точку с запятой в начале) строки:<br>
                <code>;extension=pdo_mysql</code> → <code>extension=pdo_mysql</code><br>
                <code>;extension=mysqli</code> → <code>extension=mysqli</code></li>
            <li>Сохраните файл и перезапустите веб-сервер</li>
        </ol>
        <p>Если расширения нет в папке ext, скачайте PHP с официального сайта или установите XAMPP/WAMP.</p>
        <p><a href="/catalog">Попробовать снова</a></p>
        </body>
        </html>
        ');
    }
    // Для других ошибок БД просто выводим сообщение без выброса исключения
    // чтобы не попасть в глобальный обработчик
    if (!headers_sent()) {
        header('Content-Type: text/html; charset=utf-8');
    }
    die('
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="utf-8">
        <title>Ошибка подключения</title>
    </head>
    <body>
    <h1>Ошибка подключения к базе данных</h1>
    <p>' . htmlspecialchars($errorMsg) . '</p>
    <p><a href="/catalog">Попробовать снова</a></p>
    </body>
    </html>
    ');
}
Basket::init();