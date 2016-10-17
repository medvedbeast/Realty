<?php

class Image
{
    public $id;
    public $isPreview;
    public $offerId;
    public $path;
    
    public function __construct($id, $isPreview, $offerId, $path)
    {
        $this->id = $id;
        $this->isPreview = $isPreview;
        $this->offerId = $offerId;
        $this->path = $path;
    }
    
    public static function CreateEmpty()
    {
        $image = new Image(0, 0, 0, "");
        return $image;
    }
    
}
