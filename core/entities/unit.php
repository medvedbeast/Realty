<?php

class Unit
{
    public $id;
    public $title;
    public $symbol;
    public $code;
    public $unitGroup;

    public function __construct($id, $title, $symbol, $code, $unitGroup)
    {
        $this->id = $id;
        $this->title = $title;
        $this->symbol = $symbol;
        $this->code = $code;
        $this->unitGroup = $unitGroup;
    }

    public static function CreateEmpty()
    {
        $unit = new Unit(0, "", "", "", 0);
        return $unit;
    }
}
