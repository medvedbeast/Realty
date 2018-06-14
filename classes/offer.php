<?php

class Offer
{
    public $id;
    public $title;
    public $description;
    public $location;
    public $video;
    public $preview;
    public $characteristics;
    
    public function __construct($id, $title, $description, $location, $video, $preview, $characteristics)
    {
        $this->id = $id;
        $this->title = $title;
        $this->description = $description;
        $this->location = $location;
        $this->video = $video;
        $preview == null ? $this->preview = '../images/offers/default.jpg' : $this->preview = $preview;
        $this->characteristics = $characteristics;
    }
    
    public static function CreateEmpty()
    {
        return new offer(null, null, null, null, null, null, null);
    }
    
    public static function CreateFromArray($source)
    {
        $offer = Offer::CreateEmpty();
        $offer->id = $source[0];
        $offer->title = $source[1];
        $offer->description = $source[2];
        $offer->location = $source[3];
        $this->video = $source[4];
        $source[4] == null ? $this->preview = '../images/offers/default.jpg' : $this->preview = $source[4];
        $offer->characteristics = $source[5];
        return $offer;
    }
}
