<?php
class Eshop {
    private static $db = null;

    public static function init(array $dbConfig) {
        try {
            $dsn = "mysql:host={$dbConfig['HOST']};dbname={$dbConfig['NAME']};charset=utf8mb4";
            self::$db = new PDO($dsn, $dbConfig['USER'], $dbConfig['PASS'], [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
            ]);
        } catch (PDOException $e) {
            throw new Exception("Ошибка подключения к базе данных: " . $e->getMessage());
        }
    }

    public static function addItemToCatalog(Book $book) {
        try {
            $stmt = self::$db->prepare("CALL spAddItemToCatalog(?, ?, ?, ?)");
            $stmt->execute([
                $book->title,
                $book->author,
                $book->price,
                $book->pubyear
            ]);
            return true;
        } catch (PDOException $e) {
            throw new Exception("Ошибка добавления товара: " . $e->getMessage());
        }
    }

    public static function getItemsFromCatalog() {
        try {
            $stmt = self::$db->query("CALL spGetCatalog()");
            $books = [];
            while ($row = $stmt->fetch()) {
                $books[] = new Book(
                    $row['id'],
                    $row['title'],
                    $row['author'],
                    $row['price'],
                    $row['pubyear']
                );
            }
            return new ArrayIterator($books);
        } catch (PDOException $e) {
            throw new Exception("Ошибка получения каталога: " . $e->getMessage());
        }
    }

    public static function addItemToBasket($itemId, $quantity = 1) {
        return Basket::add($itemId, $quantity);
    }

    public static function removeItemFromBasket($itemId) {
        return Basket::remove($itemId);
    }

    public static function getItemsFromBasket() {
        $basket = Basket::get();
        $itemIds = [];
        
        foreach ($basket as $key => $value) {
            if ($key !== 'order-id' && is_numeric($key)) {
                $itemIds[] = (int)$key;
            }
        }

        if (empty($itemIds)) {
            return new ArrayIterator([]);
        }

        try {
            $placeholders = implode(',', array_fill(0, count($itemIds), '?'));
            $stmt = self::$db->prepare("SELECT id, title, author, price, pubyear FROM catalog WHERE id IN ($placeholders)");
            $stmt->execute($itemIds);
            $books = [];
            while ($row = $stmt->fetch()) {
                $itemId = $row['id'];
                $quantity = isset($basket[$itemId]) ? (int)$basket[$itemId] : 1;
                $book = new Book(
                    $row['id'],
                    $row['title'],
                    $row['author'],
                    $row['price'],
                    $row['pubyear']
                );
                $books[] = ['book' => $book, 'quantity' => $quantity];
            }
            return new ArrayIterator($books);
        } catch (PDOException $e) {
            throw new Exception("Ошибка получения корзины: " . $e->getMessage());
        }
    }

    public static function saveOrder(Order $order) {
        try {
            self::$db->beginTransaction();

            $orderId = Basket::getOrderId();
            $order->order_id = $orderId;
            
            $stmt = self::$db->prepare("CALL spSaveOrder(?, ?, ?, ?, ?)");
            $stmt->execute([
                $order->order_id,
                $order->customer,
                $order->email,
                $order->phone,
                $order->address
            ]);

            $basket = Basket::get();
            foreach ($basket as $key => $quantity) {
                if ($key !== 'order-id' && is_numeric($key)) {
                    $stmt = self::$db->prepare("CALL spSaveOrderedItems(?, ?, ?)");
                    $stmt->execute([
                        $orderId,
                        (int)$key,
                        (int)$quantity
                    ]);
                }
            }

            self::$db->commit();
            
            Basket::clear();
            
            return true;
        } catch (PDOException $e) {
            if (self::$db->inTransaction()) {
                self::$db->rollBack();
            }
            throw new Exception("Ошибка сохранения заказа: " . $e->getMessage());
        }
    }

    public static function getOrders() {
        try {
            $stmt = self::$db->query("SELECT id, order_id, customer, email, phone, address, created FROM orders ORDER BY created DESC");
            $orders = [];
            
            while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
                $order = new Order(
                    $row['customer'],
                    $row['email'],
                    $row['phone'],
                    $row['address'],
                    $row['order_id'],
                    $row['id'],
                    $row['created']
                );
                
                $stmtItems = self::$db->prepare("
                    SELECT oi.id, oi.order_id, oi.item_id, oi.quantity, 
                           c.title, c.author, c.price, c.pubyear
                    FROM ordered_items oi
                    INNER JOIN catalog c ON oi.item_id = c.id
                    WHERE oi.order_id = ?
                ");
                $stmtItems->execute([$row['order_id']]);
                $items = [];
                while ($itemRow = $stmtItems->fetch(PDO::FETCH_ASSOC)) {
                    $book = new Book(
                        $itemRow['item_id'],
                        $itemRow['title'],
                        $itemRow['author'],
                        $itemRow['price'],
                        $itemRow['pubyear']
                    );
                    $items[] = ['book' => $book, 'quantity' => $itemRow['quantity']];
                }
                $stmtItems->closeCursor();
                $order->items = $items;
                $orders[] = $order;
            }
            
            $stmt->closeCursor();
            return new ArrayIterator($orders);
        } catch (PDOException $e) {
            throw new Exception("Ошибка получения заказов: " . $e->getMessage());
        }
    }

    public static function userAdd(User $user) {
        try {
            $hashedPassword = self::createHash($user->password);
            $stmt = self::$db->prepare("CALL spSaveAdmin(?, ?, ?)");
            $stmt->execute([
                $user->login,
                $hashedPassword,
                $user->email
            ]);
            return true;
        } catch (PDOException $e) {
            throw new Exception("Ошибка добавления пользователя: " . $e->getMessage());
        }
    }

    public static function userCheck(User $user): bool {
        try {
            $stmt = self::$db->prepare("CALL spGetAdmin(?)");
            $stmt->execute([$user->login]);
            $row = $stmt->fetch();
            return $row !== false;
        } catch (PDOException $e) {
            return false;
        }
    }

    public static function userGet(User $user): ?User {
        try {
            $stmt = self::$db->prepare("SELECT id, login, password, email, created FROM admins WHERE login = ? LIMIT 1");
            $stmt->execute([$user->login]);
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            if ($row) {
                return new User(
                    $row['login'],
                    $row['password'],
                    $row['email'],
                    $row['id'],
                    $row['created']
                );
            }
            return null;
        } catch (PDOException $e) {
            return null;
        }
    }

    public static function createHash(string $password): string {
        return password_hash($password, PASSWORD_DEFAULT);
    }

    public static function isAdmin(): bool {
        return isset($_SESSION['admin']) && $_SESSION['admin'] === true;
    }

    public static function logIn(User $user): bool {
        $dbUser = self::userGet($user);
        if ($dbUser) {
            if (password_verify($user->password, $dbUser->password)) {
                $_SESSION['admin'] = true;
                $_SESSION['admin_login'] = $dbUser->login;
                return true;
            }
        }
        return false;
    }

    public static function logOut() {
        unset($_SESSION['admin']);
        unset($_SESSION['admin_login']);
        session_destroy();
    }
}
