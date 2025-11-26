<?php
class User {
    public $id;
    public $login;
    public $password;
    public $email;
    public $created;

    public function __construct($login = '', $password = '', $email = '', $id = null, $created = null) {
        $this->id = $id;
        $this->login = $login;
        $this->password = $password;
        $this->email = $email;
        $this->created = $created;
    }
}

