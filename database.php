<?php

include 'entities/post.php';
include 'entities/user.php';
include 'entities/category.php';
include 'entities/categoryGroup.php';
include 'entities/characteristic.php';
include 'entities/offer.php';
include 'entities/image.php';
include 'entities/offerCharacteristic.php';
include 'entities/unit.php';

include 'debug.php';

class Database
{

    static public $host = "*";
    static public $database = "*";
    static public $username = "*";
    static public $password = "*";
    static public $link;

    static private function ConnectToDatabase()
    {
        Database::$link = (Database::$password == "" ? mysql_connect(Database::$host, Database::$username) : mysql_connect(Database::$host, Database::$username, Database::$password));
        if (mysql_select_db(Database::$database))
        {
            mysql_set_charset("utf8");
            mysql_query("set names 'utf-8'");
            return true;
        }
        else
        {
            return false;
        }
    }

    static private function ArrayToString($data)
    {
        $result = "";
        for ($i = 0; $i < count($data); $i++)
        {
            $result .= "[";
            foreach ($data[$i] as $key => $value)
            {
                $result .= "$value;";
            }
            $result .= "]";
        }
        return $result;
    }

    static function GetPostCount($keywords)
    {
        if (Database::ConnectToDatabase())
        {
            $query = "call GetPostCount('$keywords')";
            $result = mysql_query($query);
            $row = mysql_fetch_row($result);
            mysql_close(Database::$link);
            return $row[0];
        }
    }

    static function GetPostPreviews($start, $quantity, $keywords, $ownerId)
    {
        if (Database::ConnectToDatabase())
        {
            $index = 0;
            $query = "call GetPostPreviews($start, $quantity, '$keywords', $ownerId);";
            $results = mysql_query($query);
            while ($result = mysql_fetch_array($results, MYSQL_NUM))
            {
                $post = Post::CreateEmpty();
                $post->id = $result[0];
                $post->title = $result[1];
                $post->content = $result[2];
                $post->date = $result[3];
                $post->image = $result[4];
                $posts[$index] = $post;
                $index++;
            }
            mysql_close(Database::$link);
            return $posts;
        }
    }

    static function GetCategory($id, $parentId)
    {
        if (Database::ConnectToDatabase())
        {
            $index = 0;
            $query = "call GetCategory($id, $parentId);";
            $results = mysql_query($query);
            while ($result = mysql_fetch_array($results, MYSQL_NUM))
            {
                $category = Category::CreateEmpty();
                $category->id = $result[0];
                $category->title = $result[1];
                $category->categoryGroupId = $result[2];
                $category->parentCategoryId = $result[3];
                $categories[$index] = $category;
                $index++;
            }
            mysql_close(Database::$link);
            return $categories;
        }
    }

    static function GetCharacteristic($id, $categoryId)
    {
        if (Database::ConnectToDatabase())
        {
            $index = 0;
            $query = "call GetCharacteristic($id, $categoryId);";
            $results = mysql_query($query);
            while ($result = mysql_fetch_array($results, MYSQL_NUM))
            {
                $characteristic = Characteristic::CreateEmpty();
                $characteristic->id = $result[0];
                $characteristic->title = $result[1];
                $characteristic->unitId = $result[2];
                $characteristic->characteristicTypeId = $result[3];
                $characteristic->characteristicGroupId = $result[4];
                $characteristic->parentCharacteristicId = $result[5];
                $characteristics[$index] = $characteristic;
                $index++;
            }
            mysql_close(Database::$link);
            return $characteristics;
        }
    }

    static function GetOfferPreviews($categoryId, $characteristics, $keywords, $start, $quantity, $ownerId)
    {
        if (Database::ConnectToDatabase())
        {
            $index = 0;
            $query = "call GetOfferPreviews($categoryId, '" . Database::ArrayToString($characteristics) . "', '$keywords', $start, $quantity, $ownerId);";
            $results = mysql_query($query);
            if (mysql_affected_rows() != -1 && mysql_affected_rows() != 0)
            {
                while ($result = mysql_fetch_array($results, MYSQL_NUM))
                {
                    $offer = Offer::CreateEmpty();
                    $offer->id = $result[0];
                    $offer->title = $result[1];
                    $offer->description = $result[2];
                    $offer->location = $result[3];
                    $offers[$index] = $offer;
                    $index++;
                }
            }
            else
            {
                $offers = null;
            }
            mysql_close(Database::$link);
            return $offers;
        }
    }

    static function GetOfferPreviewImage($offerId)
    {
        if (Database::ConnectToDatabase())
        {
            $query = "call GetOfferPreviewImage($offerId);";
            $results = mysql_query($query);
            while ($result = mysql_fetch_array($results, MYSQL_NUM))
            {
                $image = Image::CreateEmpty();
                $image->id = $result[0];
                $image->isPreview = $result[1];
                $image->offerId = $result[2];
                $image->path = $result[3];
            }
            mysql_close(Database::$link);
            return $image;
        }
    }

    static function GetOfferCount($categoryId, $characteristics, $keywords)
    {
        if (Database::ConnectToDatabase())
        {
            $query = "call GetOfferCount($categoryId, '" . Database::ArrayToString($characteristics) . "', '$keywords');";
            $result = mysql_query($query);
            if (mysql_affected_rows() != 0 && mysql_affected_rows() != -1)
            {
                $row = mysql_fetch_row($result);
                $result = $row[0];
            }
            else
            {
                $result = 0;
            }
            mysql_close(Database::$link);
            return $result;
        }
    }

    static function GetOfferImages($offerId)
    {
        if (Database::ConnectToDatabase())
        {
            $index = 0;
            $query = "call GetOfferImages($offerId);";
            $results = mysql_query($query);
            while ($result = mysql_fetch_array($results, MYSQL_NUM))
            {
                $image = Image::CreateEmpty();
                $image->id = $result[0];
                $image->isPreview = $result[1];
                $image->offerId = $result[2];
                $image->path = $result[3];
                $images[$index] = $image;
                $index++;
            }
            mysql_close(Database::$link);
            return $images;
        }
    }

    static function GetOfferCharacteristics($offerId)
    {
        if (Database::ConnectToDatabase())
        {
            $index = 0;
            $query = "call GetOfferCharacteristics($offerId);";
            $results = mysql_query($query);
            while ($result = mysql_fetch_array($results, MYSQL_NUM))
            {
                $offerCharacteristic = OfferCharacteristic::CreateEmpty();
                $offerCharacteristic->id = $result[0];
                $offerCharacteristic->value = $result[1];
                $offerCharacteristic->offerId = $result[2];
                $offerCharacteristic->characteristicId = $result[3];
                $offerCharacteristics[$index] = $offerCharacteristic;
                $index++;
            }
            mysql_close(Database::$link);
            return $offerCharacteristics;
        }
    }

    static function GetCategoryGroup($id)
    {
        if (Database::ConnectToDatabase())
        {
            $query = "call GetCategoryGroup($id);";
            $results = mysql_query($query);
            while ($result = mysql_fetch_array($results, MYSQL_NUM))
            {
                $categoryGroup = СategoryGroup::CreateEmpty();
                $categoryGroup->id = $result[0];
                $categoryGroup->title = $result[1];
                $categoryGroup->precision = $result[2];
            }
            mysql_close(Database::$link);
            return $categoryGroup;
        }
    }

    public static function GetPost($id)
    {
        if (Database::ConnectToDatabase())
        {
            $query = "call GetPost($id);";
            $results = mysql_query($query);
            while ($result = mysql_fetch_array($results, MYSQL_NUM))
            {
                $post = Post::CreateEmpty();
                $post->id = $result[0];
                $post->title = $result[1];
                $post->content = $result[2];
                $post->authorId = $result[3];
                $post->date = $result[4];
                $post->image = $result[5];
                $post->views = $result[6];
            }
            mysql_close(Database::$link);
            return $post;
        }
    }

    public static function GetUser($id, $access)
    {
        if (Database::ConnectToDatabase())
        {
            $index = 0;
            $query = "call GetUser($id, $access);";
            $results = mysql_query($query);
            while ($result = mysql_fetch_array($results, MYSQL_NUM))
            {
                $user = User::CreateEmpty();
                $user->id = $result[0];
                $user->nickname = $result[1];
                $user->password = $result[2];
                $user->firstName = $result[3];
                $user->lastName = $result[4];
                $user->email = $result[5];
                $user->telephone = $result[6];
                $user->site = $result[7];
                $user->position = $result[8];
                $user->experience = $result[9];
                $user->country = $result[10];
                $user->userGroupId = $result[11];
                $user->dateOfBirth = $result[12];
                $user->dateOfRegistration = $result[13];
                $user->about = $result[14];
                $user->photo = $result[15];
                $users[$index] = $user;
                $index++;
            }
            mysql_close(Database::$link);
            return $users;
        }
    }

    static function GetImage($id)
    {
        if (Database::ConnectToDatabase())
        {
            $index = 0;
            $query = "call GetImage($id);";
            $results = mysql_query($query);
            while ($result = mysql_fetch_array($results, MYSQL_NUM))
            {
                $image = Image::CreateEmpty();
                $image->id = $result[0];
                $image->isPreview = $result[1];
                $image->offerId = $result[2];
                $image->path = $result[3];
                $images[$index] = $image;
                $index++;
            }
            mysql_close(Database::$link);
            return $images;
        }
    }

    static function GetOffer($id, $owner)
    {
        if (Database::ConnectToDatabase())
        {
            $query = "call GetOffer($id, $owner);";
            $results = mysql_query($query);
            while ($result = mysql_fetch_array($results, MYSQL_NUM))
            {
                $offer = Offer::CreateEmpty();
                $offer->id = $result[0];
                $offer->title = $result[1];
                $offer->description = $result[2];
                $offer->location = $result[3];
                $offer->video = $result[4];
                $offer->categoryId = $result[5];
                $offer->ownerId = $result[6];
            }
            mysql_close(Database::$link);
            return $offer;
        }
    }

    static function RemoveOffer($id)
    {
        if (Database::ConnectToDatabase())
        {
            $query = "call RemoveOffer($id);";
            $results = mysql_query($query);
            $result = mysql_affected_rows();
            mysql_close(Database::$link);
            return $result;
        }
    }

    static function GetUnit($id, $group)
    {
        if (Database::ConnectToDatabase())
        {
            $index = 0;
            $query = "call GetUnit($id, $group);";
            $results = mysql_query($query);
            while ($result = mysql_fetch_array($results, MYSQL_NUM))
            {
                $unit = Unit::CreateEmpty();
                $unit->id = $result[0];
                $unit->title = $result[1];
                $unit->symbol = $result[2];
                $unit->code = $result[3];
                $unit->unitGroup = $result[4];
                $units[$index] = $unit;
                $index++;
            }
            mysql_close(Database::$link);
            return $units;
        }
    }

    static function Login($login, $password)
    {
        if (Database::ConnectToDatabase())
        {
            $query = "call Login('$login', '$password');";
            $results = mysql_query($query);
            $row = mysql_fetch_row($results);
            mysql_close(Database::$link);
            return $row[0];
        }
    }

    static function AddOffer($title, $description, $location, $video, $category, $owner, $characteristics)
    {
        if (Database::ConnectToDatabase())
        {
            $query = "call AddOffer('$title', '$description', '$location', '$video', '$category', '$owner', '" . Database::ArrayToString($characteristics) . "');";
            $results = mysql_query($query);
            $row = mysql_fetch_row($results);
            mysql_close(Database::$link);
            return $row[0];
        }
    }

    static function LinkOfferImage($image, $offerId)
    {
        if (Database::ConnectToDatabase())
        {
            $query = "call LinkOfferImage('$image', $offerId);";
            $results = mysql_query($query);
            $results = mysql_affected_rows();
            mysql_close(Database::$link);
            return $results;
        }
    }

    static function RemoveOfferImage($id)
    {
        if (Database::ConnectToDatabase())
        {
            $query = "call RemoveOfferImage($id);";
            $results = mysql_query($query);
            $results = mysql_affected_rows();
            mysql_close(Database::$link);
            return $results;
        }
    }

    static function SetOfferPreviewImage($offerId, $imageId)
    {
        if (Database::ConnectToDatabase())
        {
            $query = "call SetOfferPreviewImage($offerId, $imageId);";
            $results = mysql_query($query);
            $results = mysql_affected_rows();
            mysql_close(Database::$link);
            return $results;
        }
    }

    static function UpdateOffer($title, $description, $location, $video, $category, $characteristics, $offerId)
    {
        if (Database::ConnectToDatabase())
        {
            $query = "call UpdateOffer('$title', '$description', '$location', '$video', '$category', '" . Database::ArrayToString($characteristics) . "', $offerId);";
            $results = mysql_query($query);
            $results = mysql_affected_rows();
            mysql_close(Database::$link);
            return $results;
        }
    }

    static function AddPost($title, $content, $authorId, $image)
    {
        if (Database::ConnectToDatabase())
        {
            $query = "call AddPost('$title', '$content', $authorId, '$image');";
            $results = mysql_query($query);
            $result = mysql_affected_rows();
            mysql_close(Database::$link);
            return $result;
        }
    }

    static function RemovePost($id)
    {
        if (Database::ConnectToDatabase())
        {
            $query = "call RemovePost('$id');";
            $results = mysql_query($query);
            $result = mysql_affected_rows();
            mysql_close(Database::$link);
            return $result;
        }
    }

    static function GetPostImage($id)
    {
        if (Database::ConnectToDatabase())
        {
            $query = "call GetPostImage($id)";
            $results = mysql_query($query);
            $row = mysql_fetch_row($results);
            mysql_close(Database::$link);
            return $row[0];
        }
    }

    static function LinkPostImage($id, $image)
    {
        if (Database::ConnectToDatabase())
        {
            $query = "call LinkPostImage($id, '$image');";
            $results = mysql_query($query);
            $results = mysql_affected_rows();
            mysql_close(Database::$link);
            return $results;
        }
    }

    static function RemovePostImage($id)
    {
        if (Database::ConnectToDatabase())
        {
            $query = "call RemovePostImage($id);";
            $results = mysql_query($query);
            $results = mysql_affected_rows();
            mysql_close(Database::$link);
            return $results;
        }
    }

    static function UpdatePost($id, $title, $content)
    {
        if (Database::ConnectToDatabase())
        {
            $query = "call UpdatePost($id, '$title', '$content');";
            $results = mysql_query($query);
            $results = mysql_affected_rows();
            mysql_close(Database::$link);
            return $results;
        }
    }

    static function GetUserImage($id)
    {
        if (Database::ConnectToDatabase())
        {
            $query = "call GetUserImage($id)";
            $results = mysql_query($query);
            $row = mysql_fetch_row($results);
            mysql_close(Database::$link);
            return $row[0];
        }
    }

    static function LinkUserImage($id, $image)
    {
        if (Database::ConnectToDatabase())
        {
            $query = "call LinkUserImage($id, '$image');";
            $results = mysql_query($query);
            $results = mysql_affected_rows();
            mysql_close(Database::$link);
            return $results;
        }
    }

    static function RemoveUserImage($id)
    {
        if (Database::ConnectToDatabase())
        {
            $query = "call RemoveUserImage($id);";
            $results = mysql_query($query);
            $results = mysql_affected_rows();
            mysql_close(Database::$link);
            return $results;
        }
    }

    static function UpdateUser($id, $nickname, $password, $firstname, $lastname, $email, $telephone, $site, $position, $experience, $country, $dateOfBirth, $about)
    {
        if (Database::ConnectToDatabase())
        {
            $query = "call UpdateUser($id, '$nickname', '$password', '$firstname', '$lastname', '$email', '$telephone', '$site', '$position', '$experience', '$country', '$dateOfBirth', '$about');";
            $results = mysql_query($query);
            $results = mysql_affected_rows();
            mysql_close(Database::$link);
            return $results;
        }
    }

    static function Register($login, $password)
    {
        if (Database::ConnectToDatabase())
        {
            $query = "call Register('$login', '$password');";
            $results = mysql_query($query);
            $row = mysql_fetch_row($results);
            mysql_close(Database::$link);
            return $row[0];
        }
    }

    static function GetPaidOffers()
    {
        if (Database::ConnectToDatabase())
        {
            $index = 0;
            $query = "call GetPaidOffers();";
            $results = mysql_query($query);
            while ($result = mysql_fetch_array($results, MYSQL_NUM))
            {
                $offer = Offer::CreateEmpty();
                $offer->id = $result[0];
                $offer->title = $result[1];
                $offers[$index] = $offer;
                $index++;
            }
            mysql_close(Database::$link);
            return $offers;
        }
    }

}
