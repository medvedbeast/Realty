<?php

class Category
{
    public $id;
    public $title;
    public $categoryGroupId;
    public $parentCategoryId;
    public $characteristicGroupId;
       
    public function __construct($id, $title, $categoryGroupId, $parentCategoryId, $characteristicGroupId)
    {
        $this->id = $id;
        $this->title = $title;
        $this->categoryGroupId = $categoryGroupId;
        $this->parentCategoryId = $parentCategoryId;
        $this->characteristicGroupId = $characteristicGroupId;
    }
    
    public static function CreateEmpty()
    {
        $category = new Category(0, "", 0, 0, 0);
        return $category;
    }
}
