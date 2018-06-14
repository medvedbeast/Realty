<?php

class Post
{
    public $id;
    public $title;
    public $content;
    public $authorId;
    public $date;
    public $image;
    public $views;
       
    public function __construct($id, $title, $content, $authorId, $date, $image, $views)
    {
        $this->id = $id;
        $this->title = $title;
        $this->content = $content;
        $this->author_id = $authorId;
        $this->date = $date;
        $this->image = $image;
        $this->views = $views;
    }
    
    public static function CreateEmpty()
    {
        $post = new Post(0, "", "", 0, 0, "", 0);
        return $post;
    }
    
}
