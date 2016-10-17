<?php

class User
{

    public $id;
    public $nickname;
    public $password;
    public $firstName;
    public $lastName;
    public $email;
    public $telephone;
    public $site;
    public $position;
    public $experience;
    public $country;
    public $userGroupId;
    public $dateOfBirth;
    public $dateOfRegistration;
    public $about;
    public $photo;

    public function __construct($id, $nickname, $password, $firstName, $lastName, $email, $telephone, $site, $position, $experience, $country, $userGroupId, $dateOfBirth, $dateOfRegistration, $about, $photo)
    {
        $this->id = $id;
        $this->nickname = $nickname;
        $this->password = $password;
        $this->firstName = $firstName;
        $this->lastName = $lastName;
        $this->email = $email;
        $this->telephone = $telephone;
        $this->site = $site;
        $this->position = $position;
        $this->experience = $experience;
        $this->country = $country;
        $this->userGroupId = $userGroupId;
        $this->dateOfBirth = $dateOfBirth;
        $this->dateOfRegistration = $dateOfRegistration;
        $this->about = $about;
        $this->photo = $photo;
    }

    public static function CreateEmpty()
    {
        return new User(0, "", "", "", "", "", "", "", "", "", "", 0, 0, 0, "", "");
    }

}
