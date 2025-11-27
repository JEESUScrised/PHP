<?php
class Cleaner {
    /**
     * Очистка строки от опасных символов
     */
    public static function str($value) {
        if (!is_string($value)) {
            return '';
        }
        $value = trim($value);
        $value = strip_tags($value);
        $value = htmlspecialchars($value, ENT_QUOTES, 'UTF-8');
        return $value;
    }
    
    /**
     * Получение положительного целого числа
     */
    public static function uint($value) {
        $value = filter_var($value, FILTER_VALIDATE_INT);
        if ($value === false || $value < 0) {
            return 0;
        }
        return (int)$value;
    }
}

