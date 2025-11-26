<?php
class Basket {
    private static $basket = [];
    private static $cookieName = 'eshop';

    public static function init() {
        self::read();
        if (empty(self::$basket) || !isset(self::$basket['order-id'])) {
            self::create();
        }
    }

    public static function create() {
        self::$basket = ['order-id' => uniqid()];
        self::save();
    }

    public static function read() {
        if (isset($_COOKIE[self::$cookieName])) {
            $data = json_decode($_COOKIE[self::$cookieName], true);
            if (is_array($data)) {
                self::$basket = $data;
            } else {
                self::$basket = [];
            }
        } else {
            self::$basket = [];
        }
    }

    public static function save() {
        setcookie(self::$cookieName, json_encode(self::$basket), time() + 3600 * 24 * 30, '/');
    }

    public static function add($itemId, $quantity = 1) {
        $itemId = (int)$itemId;
        $quantity = (int)$quantity;
        
        if ($itemId > 0 && $quantity > 0) {
            if (isset(self::$basket[$itemId])) {
                self::$basket[$itemId] += $quantity;
            } else {
                self::$basket[$itemId] = $quantity;
            }
            self::save();
            return true;
        }
        return false;
    }

    public static function remove($itemId) {
        $itemId = (int)$itemId;
        if (isset(self::$basket[$itemId])) {
            unset(self::$basket[$itemId]);
            self::save();
            return true;
        }
        return false;
    }

    public static function get() {
        return self::$basket;
    }

    public static function clear() {
        self::$basket = ['order-id' => uniqid()];
        self::save();
    }

    public static function getOrderId() {
        return isset(self::$basket['order-id']) ? self::$basket['order-id'] : null;
    }

    public static function isEmpty() {
        return count(self::$basket) <= 1; // только order-id
    }
}

