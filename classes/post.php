<?php

class Post
{
    public $id;
    public $title;
    public $content;
    public $author_id;
    public $author_firstname;
    public $author_lastname;
    public $date;
    
    public function __construct($id, $title, $content, $author_id, $author_firstname, $author_lastname, $date)
    {
        $this->id = $id;
        $this->title = $title;
        $this->content = $content;
        $this->author_id = $author_id;
        $this->author_firstname = $author_firstname;
        $this->author_lastname = $author_lastname;
        $this->date = $date;
    }
}
