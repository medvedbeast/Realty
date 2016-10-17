<?php

class СategoryGroup
{

    public $id;
    public $title;
    public $precision;

    public function __construct($id, $title, $precision)
    {
        $this->id = $id;
        $this->title = $title;
        $this->precision = $precision;
    }

    public static function CreateEmpty()
    {
        $categoryGroup = new СategoryGroup(0, "", 0);
        return $categoryGroup;
    }

}
