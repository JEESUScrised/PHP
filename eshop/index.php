<?php
error_reporting(E_ALL);

ob_start();

require_once 'core/init.php';

$routeFile = null;
switch (rtrim($path, '/')):
    case '':
    case '/index.php':
        ob_end_clean();
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

require_once 'app/__header.php';
if ($routeFile) {
    require_once 'app/' . $routeFile;
}
require_once 'app/__footer.php';

ob_end_flush();
