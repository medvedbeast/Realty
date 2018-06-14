<?php

class OfferCharacteristic
{
    public $id;
    public $value;
    public $offerId;
    public $characteristicId;
    
    public function __construct($id, $value, $offerId, $characteristicId)
    {
        $this->id = $id;
        $this->value = $value;
        $this->offerId = $offerId;
        $this->characteristicId = $characteristicId;
    }
    
    public static function CreateEmpty()
    {
        $characteristic = new OfferCharacteristic(0, "", 0, 0);
        return $characteristic;
    }
}
