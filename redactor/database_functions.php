<?php
include '../classes/database.php';
include_once '../classes/offer.php';

$function = $_REQUEST["function"];
switch ($function)
{
    case 1:
        echo GetOffersHTML();
        break;
    case 2:
        echo UpdateOffer();
        break;
    case 3:
        echo AddOffer();
        break;
    case 4:
        echo DeleteOffer();
        break;
    case 5:
        echo GetCharacteristicsHTML();
        break;
    case 6:
        echo GetOffersCharacteristicsHTML();
        break;
    case 7:
        echo UpdateOfferCharacteristic();
        break;
    case 8:
        echo AddOfferCharacteristic();
        break;
    case 9:
        echo DeleteOfferCharacteristic();
        break;
    case 10:
        echo GetImagesHTML();
        break;
    case 11:
        echo UpdateImage();
        break;
    case 12:
        echo AddImage();
        break;
    case 13:
        echo DeleteImage();
        break;
    case 14:
        echo GetImagesOnServerHTML();
        break;
    case 15:
        echo UploadImages();
        break;
    case 16:
        echo DeleteImageOnServer();
        break;
    case 17:
        echo GetPostsHTML();
        break;
    case 18:
        echo UpdatePost();
        break;
    case 19:
        echo AddPost();
        break;
    case 20:
        echo DeletePost();
        break;
    case 21:
        echo Login();
        break;
    case 22:
        echo SendMail();
        break;
    case 23:
        echo GetMaxOfferId();
        break;
    case 24:
        echo UploadAndAttachImages();
        break;
    case 25:
        echo GetProfileInfoHTML();
        break;
    case 26:
        echo GetUserOffersHTML();
        break;
    case 27:
        echo DeleteOfferFull();
        break;
    case 28:
        echo GetEditableImagesHTML();
        break;
    case 29:
        echo DeleteImageFull();
        break;
    case 30:
        echo ChangePreviewStatus();
        break;
    case 31:
        echo UpdateOfferFull();
        break;
    case 32:
        echo GetProfilePhoto();
        break;
    case 33:
        echo UpdateProfileInfo();
        break;
    case 34:
        echo UploadProfileImage();
        break;
}

function GetOffersHTML()
{
    $results = GetOffers();
    ?>
    <tr>
        <td>№</td>
        <td>НАЗВАНИЕ</td>
        <td>ОПИСАНИЕ</td>
        <td>РАСПОЛОЖЕНИЕ</td>
    </tr>
    <?php
    foreach ($results as $result)
    {
        ?>
        <tr offer_id="<?= $result->id ?>">
            <td name="id" onclick="OnOfferCellClicked(this)" style="width: 4%; border-bottom: 1px solid black; border-right: 1px solid black;"><?= $result->id ?></td>
            <td name="title" onclick="OnOfferCellClicked(this)" style="width: 20%; border-bottom: 1px solid black; border-right: 1px solid black;"><?= $result->title ?></td>
            <td name="description" onclick="OnOfferCellClicked(this)" style="width: 56%; border-bottom: 1px solid black; border-right: 1px solid black;"><?= $result->description ?></td>
            <td name="location" onclick="OnOfferCellClicked(this)" style="width: 20%; border-bottom: 1px solid black;"><?= $result->location ?></td>
        </tr>
        <?php
    }
}

function GetOffers()
{
    if (Database::ConnectToDatabase())
    {
        $index = 0;
        $query = "select id, title, description, location, video from offers";
        $result = mysql_query($query);
        while ($row = mysql_fetch_array($result, MYSQL_NUM))
        {
            $offer = new Offer($row[0], $row[1], $row[2], $row[3], $row[4], null, null);
            $results[$index++] = $offer;
        }
    }
    else
    {
        $results = false;
    }
    return $results;
}

function UpdateOffer()
{
    if (Database::ConnectToDatabase())
    {
        $query = "update offers set " . $_REQUEST["name"] . " = '" . $_REQUEST["value"] . "' where id = " . $_REQUEST["id"];
        $result = mysql_query($query);
    }
    return $result;
}

function AddOffer()
{
    if (Database::ConnectToDatabase())
    {
        $index = 0;
        $_REQUEST["id"] = $_REQUEST["id"] == -1 ? GetMaxOfferId() + 1 : $_REQUEST["id"];
        $profile = GetProfileInfo();
        $owner_id = $profile[0];
        $query = "insert into offers (id, title, description, location, video, owner_id) values (" . $_REQUEST["id"] . ", '" . $_REQUEST["title"] . "', '" . $_REQUEST["description"] . "', '" . $_REQUEST["location"] . "', '" . $_REQUEST["video"]  . "', '" . $owner_id . "')";
        $result = mysql_query($query);
    }
    return $result;
}

function DeleteOffer()
{
    if (Database::ConnectToDatabase())
    {
        $index = 0;
        $query = "delete from offers where id = " . $_REQUEST["id"];
        $result = mysql_query($query);
    }
    return $result;
}

function GetCharacteristicsHTML()
{
    $results = GetCharacteristics();
    ?>
    <tr>
        <td>№</td>
        <td>НАЗВАНИЕ</td>
    </tr>
    <?php
    foreach ($results as $result)
    {
        ?>
        <tr>
            <td style="border-bottom: 1px solid black; border-right: 1px solid black;"><?= $result[0] ?></td>
            <td style="border-bottom: 1px solid black;"><?= $result[1] ?></td>
        </tr>
        <?php
    }
}

function GetCharacteristics()
{
    if (Database::ConnectToDatabase())
    {
        $index = 0;
        $query = "select id, title from characteristics";
        $result = mysql_query($query);
        while ($row = mysql_fetch_array($result, MYSQL_NUM))
        {
            $results[$index++] = array($row[0], $row[1]);
        }
    }
    else
    {
        $results = false;
    }
    return $results;
}

function GetOffersCharacteristicsHTML()
{
    $results = GetOffersCharacteristics();
    ?>
    <tr>
        <td style="width: 10%;">№</td>
        <td style="width: 10%;">№ ПРЕДЛОЖЕНИЯ</td>
        <td style="width: 10%;">№ ХАРАКТЕРИСТИКИ</td>
        <td>ЗНАЧЕНИЕ ХАРАКТЕРИСТИКИ</td>
    </tr>
    <?php
    foreach ($results as $result)
    {
        ?>
        <tr offer_characteristic_id="<?= $result[0] ?>">
            <td name="id" style="border-bottom: 1px solid black; border-right: 1px solid black;" onclick="OnOfferCharacteristicCellClicked(this)"><?= $result[0] ?></td>
            <td name="offer_id" style="border-bottom: 1px solid black; border-right: 1px solid black;" onclick="OnOfferCharacteristicCellClicked(this)"><?= $result[1] ?></td>
            <td name="characteristic_id" style="border-bottom: 1px solid black; border-right: 1px solid black;" onclick="OnOfferCharacteristicCellClicked(this)"><?= $result[2] ?></td>
            <td name="value" style="border-bottom: 1px solid black;" onclick="OnOfferCharacteristicCellClicked(this)"><?= $result[3] ?></td>
        </tr>
        <?php
    }
}

function GetOffersCharacteristics()
{
    if (Database::ConnectToDatabase())
    {
        $index = 0;
        $query = "select id, offer_id, characteristic_id, value from offers_characteristics";
        $result = mysql_query($query);
        while ($row = mysql_fetch_array($result, MYSQL_NUM))
        {
            $results[$index++] = array($row[0], $row[1], $row[2], $row[3]);
        }
    }
    else
    {
        $results = false;
    }
    return $results;
}

function UpdateOfferCharacteristic()
{
    if (Database::ConnectToDatabase())
    {
        $query = "update offers_characteristics set " . $_REQUEST["name"] . " = '" . $_REQUEST["value"] . "' where id = " . $_REQUEST["id"];
        $result = mysql_query($query);
    }
    return $result;
}

function AddOfferCharacteristic()
{
    if (Database::ConnectToDatabase())
    {
        $index = 0;
        $_REQUEST["id"] = $_REQUEST["id"] == -1 ? GetMaxCharacteristicId() + 1 : $_REQUEST["id"];
        $query = "insert into offers_characteristics (id, offer_id, characteristic_id, value) values (" . $_REQUEST["id"] . ", '" . $_REQUEST["offer_id"] . "', '" . $_REQUEST["characteristic_id"] . "', '" . $_REQUEST["value"] . "')";
        $result = mysql_query($query);
    }
    return $result;
}

function DeleteOfferCharacteristic()
{
    if (Database::ConnectToDatabase())
    {
        $index = 0;
        $query = "delete from offers_characteristics where id = " . $_REQUEST["id"];
        $result = mysql_query($query);
    }
    return $result;
}

function GetImagesHTML()
{
    $results = GetImages();
    ?>
    <tr>
        <td>№</td>
        <td>№ ПРЕДЛОЖЕНИЯ</td>
        <td>ПУТЬ</td>
        <td>ЯВЛЯЕТЬСЯ ЛИ ПРЕДПРОСМОТРОМ</td>
    </tr>
    <?php
    foreach ($results as $result)
    {
        ?>
        <tr image_id="<?= $result[0] ?>">
            <td name="id" onclick="OnImageCellClicked(this)" style="width: 10%; border-bottom: 1px solid black; border-right: 1px solid black;"><?= $result[0] ?></td>
            <td name="offer_id" onclick="OnImageCellClicked(this)" style="width: 10%; border-bottom: 1px solid black; border-right: 1px solid black;"><?= $result[1] ?></td>
            <td name="path" onclick="OnImageCellClicked(this)" style="width: 70%; border-bottom: 1px solid black; border-right: 1px solid black;"><?= $result[2] ?></td>
            <td name="is_preview" onclick="OnImageCellClicked(this)" style="width: 10%; border-bottom: 1px solid black;"><?= $result[3] ?></td>
        </tr>
        <?php
    }
}

function GetImages()
{
    if (Database::ConnectToDatabase())
    {
        $index = 0;
        $query = "select id, offer_id, path, is_preview from images" . (isset($_REQUEST["id"]) ? " where offer_id = " . $_REQUEST["id"] : "");
        $result = mysql_query($query);
        while ($row = mysql_fetch_array($result, MYSQL_NUM))
        {
            $results[$index++] = array($row[0], $row[1], $row[2], $row[3]);
        }
    }
    else
    {
        $results = false;
    }
    return $results;
}

function UpdateImage()
{
    if (Database::ConnectToDatabase())
    {
        $query = "update images set " . $_REQUEST["name"] . " = '" . $_REQUEST["value"] . "' where id = " . $_REQUEST["id"];
        $result = mysql_query($query);
    }
    return $result;
}

function AddImage()
{
    if (Database::ConnectToDatabase())
    {
        $query = "insert into images (id, offer_id, path, is_preview) values (" . $_REQUEST["id"] . ", '" . $_REQUEST["offer_id"] . "', '" . $_REQUEST["path"] . "', '" . $_REQUEST["is_preview"] . "')";
        $result = mysql_query($query);
    }
    return $result;
}

function DeleteImage()
{
    if (Database::ConnectToDatabase())
    {
        $query = "delete from images where id = " . $_REQUEST["id"];
        $result = mysql_query($query);
    }
    return $result;
}

function GetImagesOnServerHTML()
{
    $index = 0;
    $results = GetImagesOnServer();
    $results_per_row = 10;
    $rows = ceil(count($results) / $results_per_row);
    for ($i = 0; $i < $rows; $i++)
    {
        ?>
        <tr>
            <?php
            for ($j = 0; $j < $results_per_row; $j++, $index++)
            {
                if ($results[$index] != "." && $results[$index] != "..")
                {
                    ?>
                    <td style="width: <?= 100 / $results_per_row ?>%;">
                        <?php
                        if ($index < count($results))
                        {
                            ?>
                            <a href="http://top-real.com.ua/images/offers/<?= $results[$index] ?>">
                                <div>
                                    <?= $results[$index]; ?>
                                </div>
                                <div style="height: <?= 1024 / $results_per_row ?>px; width: <?= 1024 / $results_per_row ?>px; background-image: url('../images/offers/<?= $results[$index] ?>'); background-size: contain; background-position: center; background-repeat: no-repeat; border: 1px solid black;">
                                </div>
                            </a>
                            <?php
                        }
                        ?>
                    </td>
                    <?php
                }
            }
            ?>
        </tr>
        <?php
    }
}

function GetImagesOnServer()
{
    return scandir("../images/offers");
}

function UploadImages()
{
    $index = 0;
    foreach ($_REQUEST["images"] as $image)
    {
        $source = $image;
        $start = stripos($source, "image/") + 6;
        $end = stripos($source, ";");
        $extension = substr($source, $start, $end - $start);
        $start = stripos($source, "base64,") + 7;
        $data = substr($source, $start);
        $data = base64_decode($data);
        $image = imagecreatefromstring($data);
        header('Content-Type: image/' . $extension);
        $file = "../images/offers/" . $_REQUEST["filename"] . "_" . $index . "." . $extension;
        if (file_exists($file))
        {
            do
            {
                $index++;
                $file = "../images/offers/" . $_REQUEST["filename"] . "_" . $index . "." . $extension;
            } while (!file_exists($file));
        }
        imagepng($image, $file);
        $index++;
    }
}

function UploadAndAttachImages()
{
    if (Database::ConnectToDatabase())
    {
        $index = 0;
        $preview = true;

        $query = "select count(id) from images where is_preview = 1 and offer_id = " . $_REQUEST["offer_id"];
        $result = mysql_query($query);
        $result = mysql_fetch_row($result);
        $flag = intval($result[0]) > 0 ? false : true;
        foreach ($_REQUEST["images"] as $image)
        {
            $source = $image;
            $start = stripos($source, "image/") + 6;
            $end = stripos($source, ";");
            $extension = substr($source, $start, $end - $start);
            $start = stripos($source, "base64,") + 7;
            $data = substr($source, $start);
            $data = base64_decode($data);
            $image = imagecreatefromstring($data);
            header('Content-Type: image/' . $extension);
            $file = "../images/offers/" . $_REQUEST["filename"] . "_" . $index . "." . $extension;
            while (file_exists($file))
            {
                $file = "../images/offers/" . $_REQUEST["filename"] . "_" . ++$index . "." . $extension;
            }
            imagepng($image, $file);
            $index++;

            $query = "insert into images (id, path, is_preview, offer_id) values ('" . (GetMaxImageId() + 1) . "', '" . $file . "', '" . $flag . "', '" . $_REQUEST["offer_id"] . "')";
            if ($preview)
            {
                $flag = 0;
                $preview = false;
            }
            $result = mysql_query($query);
        }
    }
    return $query;
}

function DeleteImageOnServer()
{
    return unlink("../images/offers/" . $_REQUEST["filename"]);
}

function GetPostsHTML()
{
    $results = GetPosts();
    ?>
    <tr>
        <td>№</td>
        <td>НАЗВАНИЕ</td>
        <td>ТЕКСТ</td>
        <td>ДАТА</td>
    </tr>
    <?php
    foreach ($results as $result)
    {
        ?>
        <tr post_id="<?= $result[0] ?>">
            <td name="id" onclick="OnPostCellClicked(this)" style="width: 4%; border-bottom: 1px solid black; border-right: 1px solid black;"><?= $result[0] ?></td>
            <td name="title" onclick="OnPostCellClicked(this)" style="width: 20%; border-bottom: 1px solid black; border-right: 1px solid black;"><?= $result[1] ?></td>
            <td name="content" onclick="OnPostCellClicked(this)" style="width: 56%; border-bottom: 1px solid black; border-right: 1px solid black;"><?= $result[2] ?></td>
            <td name="date" onclick="OnPostCellClicked(this)" style="width: 20%; border-bottom: 1px solid black;"><?= $result[3] ?></td>
        </tr>
        <?php
    }
}

function GetPosts()
{
    if (Database::ConnectToDatabase())
    {
        $index = 0;
        $query = "select id, title, content, date from posts";
        $result = mysql_query($query);
        while ($row = mysql_fetch_array($result, MYSQL_NUM))
        {
            $results[$index++] = array($row[0], $row[1], $row[2], $row[3]);
        }
    }
    else
    {
        $results = false;
    }
    return $results;
}

function UpdatePost()
{
    if (Database::ConnectToDatabase())
    {
        $query = "update posts set " . $_REQUEST["name"] . " = '" . $_REQUEST["value"] . "' where id = " . $_REQUEST["id"];
        $result = mysql_query($query);
    }
    return $_REQUEST["value"];
}

function AddPost()
{
    if (Database::ConnectToDatabase())
    {
        $query = "insert into posts (id, title, content, author_id, date) values (" . $_REQUEST["id"] . ", '" . $_REQUEST["title"] . "', '" . $_REQUEST["content"] . "', 1, '" . $_REQUEST["date"] . "')";
        $result = mysql_query($query);
    }
    return $result;
}

function DeletePost()
{
    if (Database::ConnectToDatabase())
    {
        $query = "delete from posts where id = " . $_REQUEST["id"];
        $result = mysql_query($query);
    }
    return $result;
}

function Login()
{
    if (Database::ConnectToDatabase())
    {
        $query = "select count(id) from users where login like '" . $_REQUEST["login"] . "' and password like '" . $_REQUEST["password"] . "'";
        $result = mysql_query($query);
        $result = mysql_fetch_row($result);
        $result = $result[0];
    }
    return intval($result);
}

function SendMail()
{
    return mail($_REQUEST["to"], "TOP-REAL.COM.UA: Новый вопрос", "Вопрос задал: " . $_REQUEST["name"] . " (" . $_REQUEST["telephone"] . ")\r\n\n" . $_REQUEST["question"], "From: " . $_REQUEST["from"]);
}

function GetMaxOfferId()
{
    if (Database::ConnectToDatabase())
    {
        $query = "select max(id) from offers";
        $result = mysql_query($query);
        $result = mysql_fetch_row($result);
        $result = $result[0];
    }

    return intval($result);
}

function GetMaxCharacteristicId()
{
    if (Database::ConnectToDatabase())
    {
        $query = "select max(id) from offers_characteristics";
        $result = mysql_query($query);
        $result = mysql_fetch_row($result);
        $result = $result[0];
    }
    return intval($result);
}

function GetMaxImageId()
{
    if (Database::ConnectToDatabase())
    {
        $query = "select max(id) from images";
        $result = mysql_query($query);
        $result = mysql_fetch_row($result);
        $result = $result[0];
    }
    return intval($result);
}

function GetProfileInfoHTML()
{
    // 0 - id, 1 - first_name, 2 - last_name, 3 - email, 4 - telephone, 5 - site, 6 - position, 7 - experience, 8 - country, 9 - date_of_birth, 10 - date_of_registration, 11 - about, 12 - photo
    $result = GetProfileInfo();
    ?>
    <div style="width: 300px; min-height: 300px; float: left; background-image: url('<?= $result[12] ?>'); background-position: center; background-size: cover; background-repeat: no-repeat;"></div>
    <div style="float: right; width: calc(100% - 300px - 25px); padding-left: 25px;">
        <table style="width: 100%; height: 300px;" cellspacing="0" cellpadding="0">
            <tr style="height: 45px; font-size: 200%;">
                <td colspan="2">
                    <?= $result[1] . " " . $result[2] ?>
                </td>
            </tr>
            <tr style="height: 15px;">
                <td colspan="2">
                    <?= $result[6] ?>
                </td>
            </tr>
            <tr>
                <td colspan="2"></td>
            </tr>
            <tr style="height: 30px;">
                <td style="width: 150px; font-weight: bold;">
                    Страна:
                </td>
                <td>
                    <?= $result[8] ?>
                </td>
            </tr>
            <tr  style="height: 30px;">
                <td style="font-weight: bold;">
                    Дата рождения:
                </td>
                <td>
                    <?= date_format(new DateTime($result[9]), "d.m.Y"); ?>
                </td>
            </tr>
            <tr  style="height: 30px;">
                <td style="font-weight: bold;">
                    На сайте с:
                </td>
                <td>
                    <?= date_format(new DateTime($result[10]), "d.m.Y"); ?>
                </td>
            </tr>
            <tr  style="height: 30px;">
                <td style="font-weight: bold;">
                    Стаж работы:
                </td>
                <td>
                    <?= $result[7]; ?>
                </td>
            </tr>
        </table>
    </div>
    <div style="clear: both; width: 100%;"></div>
    <div style="float: left; padding-top: 25px; width: 65%;">
        <div><b>О себе:</b> <br/><?= $result[11] ?></div>
    </div>
    <div style="float: right; padding-top: 25px; width: calc(35% - 25px); padding-left: 25px;">
        <div><b>Контакты:</b><br/></div>
        <div>e-mail: <a href="mailto:<?= $result[3] ?>"><?= $result[3] ?></a></div>
        <div>телефон: <?= $result[4] ?></div>
        <div>сайт: <a href=""><?= $result[5] ?></a></div>
    </div>
    <div style="clear: both;"></div>
    <div style="float: left; padding-top: 25px; width: calc(35% - 25px);">
        <a href="database_profile_edit.php?id=<?= $result[0] ?>" target="_tab">
            <input type="button" style="height: 35px; background-color: gray;" value="ИЗМЕНИТЬ ДАННЫЕ ПРОФИЛЯ" />
        </a>
    </div> 
    <?php
}

function GetProfileInfo()
{
    if (Database::ConnectToDatabase())
    {
        $index = 0;
        $query = "select id, first_name, last_name, email, telephone, site, position, experience, country, date_of_birth, date_of_registration, about, photo from users where login like '" . $_REQUEST["login"] . "' limit 1";
        $result = mysql_query($query);
        $result = mysql_fetch_row($result);
    }
    return $result;
}

function GetUserOffersHTML()
{
    $results = GetUserOffers();
    if ($results != false)
    {
        $index = 0;
        foreach ($results as $offer)
        {
            ?>
            <div id="offer_<?= $index ?>" offer_id="<?= $offer->id ?>" style="border: 1px solid gray; margin-bottom: 10px;">
                <table style="width: 100%; padding: 10px;">
                    <tr>
                        <td style="border: 1px solid gray; min-width: 350px; max-width: 350px; background-image: url('<?= $offer->preview ?>'); background-position: center; background-size: contain; background-repeat: no-repeat;" rowspan="4"></td>
                        <td style="width: 100%; padding-bottom: 10px; padding-left: 10px;" colspan="3">
                            <b><?= $offer->title ?></b>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="3" style="padding-bottom: 30px; padding-left: 10px;">
                            <i><?= $offer->location ?></i>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="3" style="min-height: 200px;  padding-bottom: 0px; padding-left: 10px;">
                            <?php
                            $max_length = 1000;
                            if (strlen($offer->description) >= $max_length)
                            {
                                echo substr($offer->description, 0, strripos(substr($offer->description, 0, $max_length), " ")) . "...";
                            }
                            else
                            {
                                echo $offer->description;
                            }
                            ?>
                        </td>
                    </tr>
                    <tr style="min-height: 30px; text-align: center; vertical-align: middle;">
                        <td style="width: 100%;"></td>
                        <td style="min-width: 150px; max-width: 150px; background-color: lightgray;" onclick="DeleteOfferClicked(<?= $offer->id ?>)">УДАЛИТЬ</td>
                        <td style="min-width: 150px; max-width: 150px; background-color: lightgray;" onclick=""><a href="database_offer_edit.php?id=<?= $offer->id ?>" target="_tab">ИЗМЕНИТЬ</a></td>
                    </tr>
                </table>
            </div>
            <?php
            $index++;
        }
    }
    else
    {
        if ($results == false)
        {
            return "Упс! Вы еще не добавили ни одного предложения! Самое время это исправить!";
        }
        else
        {
            return "Произошла непредвиденная ошибка, попробуйте, пожалуйста, позже!";
        }
    }
}

function GetUserOffers()
{
    if (Database::ConnectToDatabase())
    {
        $index = 0;
        $owner_profile = GetProfileInfo();
        $owner_id = $owner_profile[0];
        $query = "select id, title, description, location, video from offers where owner_id like '" . $owner_id . "'";
        $result = mysql_query($query);
        while ($row = mysql_fetch_array($result, MYSQL_NUM))
        {
            $offer = new Offer($row[0], $row[1], $row[2], $row[3], $row[4], GetPreviewImage($row[0]), null);
            $results[$index++] = $offer;
        }
    }
    else
    {
        $results = false;
    }
    return $results;
}

function GetPreviewImage($id)
{
    if (Database::ConnectToDatabase())
    {
        $query = "select path from images where offer_id like '" . $id . "' and is_preview = 1 limit 1";
        $result = mysql_query($query);
        $result = mysql_fetch_row($result);
    }
    return $result[0];
}

function DeleteOfferFull()
{
    if (Database::ConnectToDatabase())
    {
        $index = 0;
        $query = "delete from offers where id = " . $_REQUEST["id"];
        $result = mysql_query($query);

        $query = "delete from offers_characteristics where offer_id = " . $_REQUEST["id"];
        $result = mysql_query($query);

        $query = "delete from offers_characteristics where offer_id = " . $_REQUEST["id"];
        $result = mysql_query($query);

        $query = "select path from images where offer_id = " . $_REQUEST["id"];
        $result = mysql_query($query);
        while ($row = mysql_fetch_array($result))
        {
            unlink($row[0]);
        }

        $query = "delete from images where offer_id = " . $_REQUEST["id"];
        $result = mysql_query($query);
    }
    return $result;
}

function GetEditableImagesHTML()
{
    $results = GetImages();
    if (count($results) == 0)
        return false;
    $results_per_row = 3;

    $index = 0;
    foreach ($results as $image)
    {
        if ($index == 0)
        {
            echo "<tr>";
        }
        if ($index < count($results))
        {
            ?>
            <td style="width: <?= 100 / $results_per_row ?>%; height: 250px; background-image: url('<?= $image[2] ?>'); background-position: center; background-size: contain; background-repeat: no-repeat;">
                <?php
                if ($image[3] == 1)
                {
                    ?>
                    <table style="width: 100%; height: 100%; padding: 10px;"">
                        <tr style="height: 32px;">
                            <td style="width: 96px; background-image: url('../images/flag.png'); background-position: center; background-repeat: no-repeat; background-color: gray;" rowspan="2" onclick="MakePreviewClicked(<?= $image[0] ?>)"></td>
                            <td></td>
                            <td style="width: 32px; background-image: url('../images/cross.png'); background-position: center; background-repeat: no-repeat; background-color: gray;" onclick="DeleteImageClicked(<?= $image[0] ?>)"></td>
                        </tr>
                        <tr style="height: 64px;"><td></td><td></td></tr>
                        <tr><td></td><td></td><td></td></tr>
                    </table>
                    <?php
                }
                else
                {
                    ?>
                    <table style = "width: 100%; height: 100%; padding: 10px;">
                        <tr style = "height: 32px;">
                            <td style="width: 96px; background-image: url('../images/flag.png'); background-position: center; background-repeat: no-repeat; background-color: lightgray;" rowspan="2" onclick="MakePreviewClicked(<?= $image[0] ?>)"></td>
                            <td></td>
                            <td style = "width: 32px; background-image: url('../images/cross.png'); background-position: center; background-repeat: no-repeat; background-color: gray;" onclick="DeleteImageClicked(<?= $image[0] ?>)"></td>
                        </tr>
                        <tr style = "height: 64px;"><td></td><td></td></tr>
                        <tr><td></td><td></td><td></td></tr>
                    </table>
                    <?php
                }
                ?>
            </td>
            <?php
        }
        else
        {
            ?>
            <td style="width: <?= 100 / $results_per_row ?>; min-height: 250px;">
            </td>
            <?php
        }
        if ($index == $results_per_row - 1)
        {
            $index = 0;
            echo "</tr>";
        }
        else
        {
            $index++;
        }
    }
}

function DeleteImageFull()
{
    if (Database::ConnectToDatabase())
    {
        $query = "select path from images where id = " . $_REQUEST["id"];
        $query_result = mysql_query($query);
        $result = mysql_fetch_row($query_result);
        unlink($result[0]);


        $query = "select id from images where is_preview = 1 and offer_id = " . $_REQUEST["offer_id"];
        $query_result = mysql_query($query);
        $result = mysql_fetch_row($query_result);
        $is_preview = $result[0];

        $query = "delete from images where id = " . $_REQUEST["id"];
        mysql_query($query);

        if ($is_preview == $_REQUEST["id"])
        {
            $query = "select id from images where offer_id = " . $_REQUEST["offer_id"] . " limit 1";
            $query_result = mysql_query($query);
            $result = mysql_fetch_row($query_result);
            $id = $result[0];
            $_REQUEST["id"] = $id;
            ChangePreviewStatus();
        }
    }
}

function ChangePreviewStatus()
{
    if (Database::ConnectToDatabase())
    {
        $query = "update images set is_preview = 0 where offer_id = " . $_REQUEST["offer_id"];
        mysql_query($query);
        $query = "update images set is_preview = 1 where id = " . $_REQUEST["id"];
        mysql_query($query);
    }
    return $result;
}

function UpdateOfferFull()
{
    if (Database::ConnectToDatabase())
    {
        $query = "update offers_characteristics set value = -1 where offer_id = " . $_REQUEST["offer_id"];
        mysql_query($query);
        $query = "update offers set title = '" . $_REQUEST["title"] . "', description = '" . $_REQUEST["description"] . "', location = '" . $_REQUEST["location"] . "', video = '" . $_REQUEST["video"] . "' where id = " . $_REQUEST["offer_id"];
        mysql_query($query);
        foreach ($_REQUEST["characteristics"] as $item)
        {
            $query = "select count(id) from offers_characteristics where characteristic_id = " . $item[0] . " and offer_id = " . $_REQUEST["offer_id"];
            $query_result = mysql_query($query);
            $result = mysql_fetch_row($query_result);
            if (intval($result[0] <= 0))
            {
                $query = "insert into offers_characteristics (value, offer_id, characteristic_id) values ('" . $item[1] . "', '" . $_REQUEST["offer_id"] . "', '" . $item[0] . "')";
                $query_result = mysql_query($query);
            }
            else
            {
                $query = "update offers_characteristics set value = " . $item[1] . " where characteristic_id = " . $item[0] . " and offer_id = " . $_REQUEST["offer_id"];
                $query_result = mysql_query($query);
            }
        }
        $query = "delete from offers_characteristics where value = -1";
        mysql_query($query);
    }
}

function GetProfilePhoto()
{
    if (Database::ConnectToDatabase())
    {
        $query = "select photo from users where id = " . $_REQUEST["id"];
        $query_result = mysql_query($query);
        $result = mysql_fetch_row($query_result);
        return $result[0];
    }
}

function UpdateProfileInfo()
{
    if (Database::ConnectToDatabase())
    {
        $query = "update users set first_name = '" . $_REQUEST["data"][0] . "', last_name = '" . $_REQUEST["data"][1] . "', email = '" . $_REQUEST["data"][2] . "', telephone = '" . $_REQUEST["data"][3] . "', site = '" . $_REQUEST["data"][4] . "', position = '" . $_REQUEST["data"][5] . "', experience = '" . $_REQUEST["data"][6] . "', country = '" . $_REQUEST["data"][7] . "', date_of_birth = '" . $_REQUEST["data"][8] . "', about = '" . $_REQUEST["data"][9] . "' where id = " . $_REQUEST["id"];
        mysql_query($query);
    }
}

function UploadProfileImage()
{
    if (Database::ConnectToDatabase())
    {
        $index = 0;
        $source = $_REQUEST["image"];
        $start = stripos($source, "image/") + 6;
        $end = stripos($source, ";");
        $extension = substr($source, $start, $end - $start);
        $start = stripos($source, "base64,") + 7;
        $data = substr($source, $start);
        $data = base64_decode($data);
        $image = imagecreatefromstring($data);
        header('Content-Type: image/' . $extension);
        $file = "../images/users/" . $filename . "_" . $index++ . "." . $extension;
        while (file_exists($file))
        {
            $file = "../images/users/" . $filename . "_" . $index++ . "." . $extension;
        }
        imagepng($image, $file);

        $query = "update users set photo = '" . $file . "' where id = " . $_REQUEST["user_id"];
        mysql_query($query);

        return $query;
    }
}
