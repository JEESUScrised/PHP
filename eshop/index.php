<?php
error_reporting(E_ALL);

// Включаем буферизацию вывода, чтобы можно было делать редиректы даже после начала вывода
ob_start();

// Сначала проверяем специальный маршрут /skull - он не требует init.php
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
if (rtrim($path, '/') === '/skull') {
    ob_end_clean();
    // Отключаем все обработчики ошибок для этой страницы
    ini_set('display_errors', 0);
    error_reporting(0);
    // Отключаем глобальные обработчики ошибок
    restore_error_handler();
    restore_exception_handler();
    header('Content-Type: text/html; charset=utf-8');
    header('Cache-Control: no-cache, no-store, must-revalidate, max-age=0');
    header('Pragma: no-cache');
    header('Expires: Thu, 01 Jan 1970 00:00:00 GMT');
    header('Last-Modified: ' . gmdate('D, d M Y H:i:s') . ' GMT');
    header('ETag: "' . md5(time()) . '"');
    require_once 'app/skull.php';
    exit;
}

require_once 'core/init.php';

// Сначала выполняем роутинг (может делать редиректы)
// Но не подключаем файлы напрямую, а сохраняем путь к файлу
$routeFile = null;
// Важно: обрабатываем /skull ДО того, как сервер попытается отдать статический файл
switch (rtrim($path, '/')):
    case '':
    case '/index.php':
        ob_end_clean(); // Очищаем буфер перед редиректом
        header('Location: /catalog');
        exit;
    case '/catalog':
        $routeFile = 'catalog.php';
        break;
    case '/basket':
        $routeFile = 'basket.php';
        break;
    case '/admin':
        $routeFile = 'admin/admin.php';
        break;    
    case '/admin/add_item_to_catalog':
        $routeFile = 'admin/add_item_to_catalog.php';
        break;
    case '/admin/save_item_to_catalog':
        $routeFile = 'admin/save_item_to_catalog.php';
        break;    
    case '/add_item_to_basket':
        $routeFile = 'add_item_to_basket.php';
        break;
    case '/remove_item_from_basket':
        $routeFile = 'remove_item_from_basket.php';
        break;
    case '/create_order':
        $routeFile = 'create_order.php';
        break;
    case '/save_order':
        $routeFile = 'save_order.php';
        break;   
    case '/admin/orders':
        $routeFile = 'admin/orders.php';
        break;
    case '/admin/create_user':
        $routeFile = 'admin/create_user.php';
        break;
    case '/admin/save_user':
        $routeFile = 'admin/save_user.php';
        break;
    case '/admin/logout':
        $routeFile = 'admin/logout.php';
        break;
    case '/enter':
        $routeFile = 'enter.php';
        break;
    case '/login':
        $routeFile = 'login.php';
        break;
    default:
        $routeFile = '404.php';
endswitch;

// Теперь выводим HTML и подключаем нужный файл
require_once 'app/__header.php';
if ($routeFile) {
    require_once 'app/' . $routeFile;
}
require_once 'app/__footer.php';

// Отправляем буферизованный вывод
ob_end_flush();
