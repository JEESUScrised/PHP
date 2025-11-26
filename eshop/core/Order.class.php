<?php
class Order {
    public $id;
    public $order_id;
    public $customer;
    public $email;
    public $phone;
    public $address;
    public $created;
    public $items = [];

    public function __construct($customer = '', $email = '', $phone = '', $address = '', $order_id = null, $id = null, $created = null) {
        $this->id = $id;
        $this->order_id = $order_id;
        $this->customer = $customer;
        $this->email = $email;
        $this->phone = $phone;
        $this->address = $address;
        $this->created = $created;
        $this->items = [];
    }
}

