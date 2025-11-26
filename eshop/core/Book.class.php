<?php
class Book {
    public $id;
    public $title;
    public $author;
    public $price;
    public $pubyear;

    public function __construct($id = null, $title = '', $author = '', $price = 0, $pubyear = 0) {
        $this->id = $id;
        $this->title = $title;
        $this->author = $author;
        $this->price = $price;
        $this->pubyear = $pubyear;
    }
}

