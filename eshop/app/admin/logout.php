<?php
Eshop::logOut();
ob_end_clean(); // Очищаем буфер перед редиректом
header('Location: /catalog');
exit;
