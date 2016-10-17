<?php

class Offer
{
    public $id;
    public $title;
    public $description;
    public $location;
    public $video;
    public $categoryId;
    public $ownerId;
    
    public function __construct($id, $title, $description, $location, $video, $categoryId, $ownerId)
    {
        $this->id = $id;
        $this->title = $title;
        $this->description = $description;
        $this->location = $location;
        $this->video = $video;
        $this->categoryId = $categoryId;
        $this->ownerId = $ownerId;
    }
    
    public static function CreateEmpty()
    {
        $offer = new Offer(0, "", "", "", "", 0, 0);
        return $offer;
    }
}
