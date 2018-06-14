<?php

class Characteristic
{
    public $id;
    public $title;
    public $unitId;
    public $characteristicTypeId;
    public $characteristicGroupId;
    public $parentCharacteristicId;
    
    public function __construct($id, $title, $unitId, $characteristicTypeId, $characteristicGroupId, $parentCharacteristicId)
    {
        $this->id = $id;
        $this->title = $title;
        $this->unitId = $unitId;
        $this->characteristicTypeId = $characteristicTypeId;
        $this->characteristicGroupId = $characteristicGroupId;
        $this->parentCharacteristicId = $parentCharacteristicId;
    }
    
    public static function CreateEmpty()
    {
        $characteristic = new Characteristic(0, "", 0, 0, 0, 0);
        return $characteristic;
    }
}
