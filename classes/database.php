<?php

include_once "post.php";
include_once "offer.php";

class Database
{

    static $host = "localhost";
    static $database = "toprealc_data";
    static $username = "toprealc_admin";
    static $password = "QAZwsxedc123";

    static function ConnectToDatabase()
    {
        (database::$password == "" ? mysql_connect(database::$host, database::$username) : mysql_connect(database::$host, database::$username, database::$password));
        if (mysql_select_db(database::$database))
        {
            $answer = true;
            mysql_set_charset("utf8");
        }
        else
        {
            $answer = false;
        }
        return $answer;
    }

    public static function GetPost($id)
    {
        if (database::ConnectToDatabase())
        {
            $query = "select posts.id, posts.title, posts.content, posts.author_id, users.first_name, users.last_name, posts.date from posts, users where posts.id = " . $id . " and  posts.author_id = users.id";
            $result = mysql_query($query);
            $row = mysql_fetch_row($result);
            $current = new post($row[0], $row[1], $row[2], $row[3], $row[4], $row[5], $row[6]);
        }
        else
        {
            $current = false;
        }
        return $current;
    }

    public static function GetPosts($quantity, $start_index)
    {
        if (database::ConnectToDatabase())
        {
            $index = 0;
            $query = "select posts.id, posts.title, posts.content, posts.author_id, users.first_name, users.last_name, posts.date from posts, users where posts.author_id = users.id limit " . $start_index . ", " . $quantity;
            $result = mysql_query($query);
            while ($row = mysql_fetch_array($result, MYSQL_NUM))
            {
                $current = new post($row[0], $row[1], $row[2], $row[3], $row[4], $row[5], $row[6]);
                $results[$index++] = $current;
            }
        }
        else
        {
            $results = false;
        }
        return $results;
    }

    public static function GetRowCount($table)
    {
        if (database::ConnectToDatabase())
        {
            $query = "select count(id) from " . $table;
            $result = mysql_query($query);
            $row = mysql_fetch_row($result);
            $count = $row[0];
        }
        else
        {
            $count = false;
        }
        return $count;
    }

    public static function GetCharacteristicList()
    {
        if (database::ConnectToDatabase())
        {
            $index = 0;
            $previous_group = " ";
            $query = "select c.id, c.title, c.type, cg.tag, cg.title from characteristics as c, characteristic_groups as cg where c.characteristic_group_id = cg.id";
            $result = mysql_query($query);
            while ($row = mysql_fetch_array($result, MYSQL_NUM))
            {
                if ($row[4] != $previous_group)
                {
                    $index = 0;
                }
                $characteristics[$row[4]][$index][0] = $row[0];
                $characteristics[$row[4]][$index][1] = $row[1];
                $characteristics[$row[4]][$index][2] = $row[2];
                $characteristics[$row[4]][$index++][3] = $row[3];
                $previous_group = $row[4];
            }
        }
        else
        {
            $characteristics = false;
        }
        return $characteristics;
    }

    public static function GetOfferPreview($id)
    {
        if (database::ConnectToDatabase())
        {
            $query = "select i.path from images as i, offers as o where i.offer_id = o.id and o.id = " . $id . " and i.is_preview = 1 limit 1";
            $result = mysql_query($query);
            if (!$result)
                return false;
            $row = mysql_fetch_row($result);
            $result = $row[0];
        }
        else
        {
            $result = false;
        }
        return $result;
    }

    public static function GetOffer($id)
    {
        if (database::ConnectToDatabase())
        {
            $query = "select id, title, description, location, video from offers where id = " . $id;
            $result = mysql_query($query);
            $row = mysql_fetch_row($result);
            $offer = new Offer($row[0], $row[1], $row[2], $row[3], $row[4], Database::GetOfferPreview($row[0]), null);
            $query = "select c.title, oc.value, c.type, cg.title from offers_characteristics as oc, characteristics as c, characteristic_groups as cg where offer_id = " . $id . " and oc.characteristic_id = c.id and c.characteristic_group_id = cg.id order by characteristic_id";
            $result = mysql_query($query);
            while ($row = mysql_fetch_array($result, MYSQL_NUM))
            {
                $characteristics[$row[0]][0] = $row[0];
                $characteristics[$row[0]][1] = $row[1];
                $characteristics[$row[0]][2] = $row[2];
                $characteristics[$row[0]][3] = $row[3];
            }
            $offer->characteristics = $characteristics;
        }
        else
        {
            $offer = false;
        }
        return $offer;
    }

    public static function GetOffers($filters, $start_index, $quantity)
    {
        if (Database::ConnectToDatabase() && count($filters) > 0)
        {
            $index = 1;
            $select_part = "select o.id, o.title, o.description, o.location";
            $query = "";
            $previous_id = 0;
            foreach ($filters as $filter)
            {
                switch ($filter[2])
                {
                    case "exact":
                        $allias = "oc" . $index++;
                        $query .= " join offers_characteristics as " . $allias . " on o.id = " . $allias . ".offer_id and " . $allias . ".characteristic_id = " . $filter[0];
                        $query .= " and " . $allias . ".value like " . $filter[1];
                        break;
                    case "min":
                        $allias = "oc" . $index++;
                        $query .= " join offers_characteristics as " . $allias . " on o.id = " . $allias . ".offer_id and " . $allias . ".characteristic_id = " . $filter[0];
                        $query .= " and " . $allias . ".value >= " . $filter[1];
                        $previous_id = $filter[0];
                        break;
                    case "max":
                        if ($filter[0] == $previous_id)
                        {
                            $allias = "oc" . ($index - 1);
                            $query .= " and " . $allias . ".value <= " . $filter[1];
                        }
                        else
                        {
                            $allias = "oc" . $index++;
                            $query .= " join offers_characteristics as " . $allias . " on o.id = " . $allias . ".offer_id and " . $allias . ".characteristic_id = " . $filter[0];
                            $query .= " and " . $allias . ".value <= " . $filter[1];
                        }
                        break;
                }
            }
            for ($i = 1; $i < $index; $i++)
                $select_part .= ", oc" . $i . ".value";
            $select_part .= " from offers as o";
            $index = 0;
            $query = $select_part . $query . " limit " . $start_index . ", " . $quantity;
            $result = mysql_query($query);
            while ($row = mysql_fetch_array($result, MYSQL_NUM))
            {
                $offer = new Offer($row[0], $row[1], $row[2], $row[3], $row[4], Database::GetOfferPreview($row[0]), null);
                $results[$index++] = $offer;
            }
        }
        else
        {
            $results = false;
        }
        return $results;
    }

    public static function GetOfferCount($filters)
    {
        if (Database::ConnectToDatabase() && count($filters) > 0)
        {
            $index = 1;
            $select_part = "select count(o.id)";
            $query = "";
            $previous_id = 0;
            foreach ($filters as $filter)
            {
                switch ($filter[2])
                {
                    case "exact":
                        $allias = "oc" . $index++;
                        $query .= " join offers_characteristics as " . $allias . " on o.id = " . $allias . ".offer_id and " . $allias . ".characteristic_id = " . $filter[0];
                        $query .= " and " . $allias . ".value like " . $filter[1];
                        break;
                    case "min":
                        $allias = "oc" . $index++;
                        $query .= " join offers_characteristics as " . $allias . " on o.id = " . $allias . ".offer_id and " . $allias . ".characteristic_id = " . $filter[0];
                        $query .= " and " . $allias . ".value >= " . $filter[1];
                        $previous_id = $filter[0];
                        break;
                    case "max":
                        if ($filter[0] == $previous_id)
                        {
                            $allias = "oc" . ($index - 1);
                            $query .= " and " . $allias . ".value <= " . $filter[1];
                        }
                        else
                        {
                            $allias = "oc" . $index++;
                            $query .= " join offers_characteristics as " . $allias . " on o.id = " . $allias . ".offer_id and " . $allias . ".characteristic_id = " . $filter[0];
                            $query .= " and " . $allias . ".value <= " . $filter[1];
                        }
                        break;
                }
            }
            $select_part .= " from offers as o";
            $index = 0;
            $query = $select_part . $query;
            $result = mysql_query($query);
            $row = mysql_fetch_row($result);
            $result = $row[0];
        }
        else
        {
            $result = false;
        }
        return $result;
    }

    public static function GetImages($id)
    {
        if (database::ConnectToDatabase())
        {
            $index = 0;
            $query = "select path from images where offer_id = " . $id;
            $result = mysql_query($query);
            while ($row = mysql_fetch_array($result, MYSQL_BOTH))
            {
                $results[$index++] = $row[0];
            }
            return $results;
        }
        else
        {
            $results = false;
        }
        return $results;
    }

    public static function GetOffersByKeywords($keywords, $start_index, $quantity)
    {
        if (database::ConnectToDatabase())
        {
            $index = 0;
            $query = "select * from offers where ";
            foreach ($keywords as $keyword)
            {
                $query .= " (title like '%" . $keyword . "%' or description like '%" . $keyword . "%' or location like '%" . $keyword . "%') or ";
            }
            $query = substr($query, 0, strlen($query) - 4);
            $query .= " limit " . $start_index . ", " . $quantity;
            $result = mysql_query($query);
            while ($row = mysql_fetch_array($result, MYSQL_NUM))
            {
                $offer = new Offer($row[0], $row[1], $row[2], $row[3], $row[4], Database::GetOfferPreview($row[0]), null);
                $results[$index++] = $offer;
            }
        }
        else
        {
            $results = false;
        }
        return $results;
    }

    public static function GetOffersByKeywordsCount($keywords)
    {
        if (database::ConnectToDatabase())
        {
            $index = 0;
            $query = "select count(id) from offers where ";
            foreach ($keywords as $keyword)
            {
                $query .= " (title like '%" . $keyword . "%' or description like '%" . $keyword . "%' or location like '%" . $keyword . "%') or ";
            }
            $query = substr($query, 0, strlen($query) - 4);
            $result = mysql_query($query);
            $row = mysql_fetch_array($result);
            $result = $row[0];
        }
        else
        {
            $result = false;
        }
        return $result;
    }

    public static function GetProfileInfo()
    {
        if (Database::ConnectToDatabase())
        {
            $index = 0;
            $query = "select first_name, last_name, email, telephone, site, position, experience, country, date_of_birth, about, photo from users where id = " . $_REQUEST["id"];
            $result = mysql_query($query);
            $result = mysql_fetch_row($result);
            return $result;
        }
        return $result;
    }

}
