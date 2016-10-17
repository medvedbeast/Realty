<?php
include_once "./database.php";
include_once "./debug.php";

if (isset($_REQUEST["function"]))
{
    switch ($_REQUEST["function"])
    {
        case "AddPost":
            {
                echo Database::AddPost($_REQUEST["title"], $_REQUEST["content"], $_REQUEST["authorId"], $_REQUEST["image"]);
                break;
            }
        case "RemovePost":
            {
                echo Database::RemovePost($_REQUEST["id"]);
                break;
            }
        case "GetPostPreviews":
            {
                echo GetPostPreviewsHTML(Database::GetPostPreviews($_REQUEST["start"], $_REQUEST["quantity"], $_REQUEST["keywords"], $_REQUEST["ownerId"]));
                break;
            }
        case "GetPostCount":
            {
                echo Database::GetPostCount($_REQUEST["keywords"]);
                break;
            }
        case "GetPost":
            {
                echo GetPostHTML(Database::GetPost($_REQUEST["id"]));
                break;
            }
        case "GetCategory":
            {
                echo GetCategoryHTML(Database::GetCategory($_REQUEST["id"], $_REQUEST["parentId"]));
                break;
            }
        case "GetCharacteristic":
            {
                echo GetCharacteristicHTML(Database::GetCharacteristic($_REQUEST["id"], $_REQUEST["categoryId"]));
                break;
            }
        case "GetOfferPreviews":
            {
                echo GetOfferPreviewsHTML(Database::GetOfferPreviews($_REQUEST["categoryId"], $_REQUEST["characteristics"], $_REQUEST["keywords"], $_REQUEST["start"], $_REQUEST["quantity"], $_REQUEST["ownerId"]));
                break;
            }
        case "GetOfferCount":
            {
                echo Database::GetOfferCount($_REQUEST["categoryId"], $_REQUEST["characteristics"], $_REQUEST["keywords"]);
                break;
            }
        case "GetOffer":
            {
                echo GetOfferHTML(Database::GetOffer($_REQUEST["id"], $_REQUEST["ownerId"]));
                break;
            }
        case "GetUserCard":
            {
                echo GetUserCardHTML(Database::GetUser($_REQUEST["id"], $_REQUEST["access"]));
                break;
            }
        case "Login":
            {
                echo Database::Login($_REQUEST["login"], $_REQUEST["password"]);
                break;
            }
        case "AddOffer":
            {
                echo Database::AddOffer($_REQUEST["title"], $_REQUEST["description"], $_REQUEST["location"], $_REQUEST["video"], $_REQUEST["category"], $_REQUEST["owner"], $_REQUEST["characteristics"]);
                break;
            }
        case "UploadImage":
            {
                echo UploadImage($_REQUEST["path"]);
                break;
            }
        case "UnloadImages":
            {
                echo UnloadImages($_REQUEST["path"], $_REQUEST["files"]);
                break;
            }
        case "LinkOfferImages":
            {
                echo LinkOfferImages($_REQUEST["files"]);
                break;
            }
        case "RemoveOffer":
            {
                echo RemoveOffer($_REQUEST["offerId"]);
                break;
            }
        case "RemoveUnusedImages":
            {
                echo RemoveUnusedImages(Database::GetImage(0));
                break;
            }
        case "GetEditableOffer":
            {
                echo GetEditableOfferHTML(Database::GetOffer($_REQUEST["id"], 0));
                break;
            }
        case "GetEditableOfferImages":
            {
                echo GetEditableOfferImages($_REQUEST["offerId"]);
                break;
            }
        case "GetEditablePost":
            {
                echo GetEditablePostHTML(Database::GetPost($_REQUEST["id"]));
                break;
            }
        case "RemoveOfferImage":
            {
                echo Database::RemoveOfferImage($_REQUEST["id"]);
                break;
            }
        case "SetOfferPreviewImage":
            {
                echo Database::SetOfferPreviewImage($_REQUEST["offerId"], $_REQUEST["imageId"]);
                break;
            }
        case "UpdateOffer":
            {
                echo Database::UpdateOffer($_REQUEST["title"], $_REQUEST["description"], $_REQUEST["location"], $_REQUEST["video"], $_REQUEST["category"], $_REQUEST["characteristics"], $_REQUEST["offerId"]);
                break;
            }
        case "LinkPostImage":
            {
                echo Database::LinkPostImage($_REQUEST["id"], $_REQUEST["image"]);
                break;
            }
        case "GetEditablePostImage":
            {
                echo GetEditablePostImage($_REQUEST["id"]);
                break;
            }
        case "RemovePostImage":
            {
                echo Database::RemovePostImage($_REQUEST["id"]);
                break;
            }
        case "UpdatePost":
            {
                echo Database::UpdatePost($_REQUEST["id"], $_REQUEST["title"], $_REQUEST["content"]);
                break;
            }
        case "GetProfileInfo":
            {
                echo GetProfileInfo(Database::GetUser($_REQUEST["id"], 0));
                break;
            }
        case "GetEditableProfileImage":
            {
                echo GetEditableProfileImage($_REQUEST["id"]);
                break;
            }
        case "LinkUserImage":
            {
                echo Database::LinkUserImage($_REQUEST["id"], $_REQUEST["image"]);
                break;
            }
        case "RemoveUserImage":
            {
                echo Database::RemoveUserImage($_REQUEST["id"]);
                break;
            }
        case "UpdateUser":
            {
                echo Database::UpdateUser($_REQUEST["id"], $_REQUEST["nickname"], $_REQUEST["password"], $_REQUEST["firstname"], $_REQUEST["lastname"], $_REQUEST["email"], $_REQUEST["telephone"], $_REQUEST["site"], $_REQUEST["position"], $_REQUEST["experience"], $_REQUEST["country"], $_REQUEST["dateOfBirth"], $_REQUEST["about"]);
                break;
            }
        case "Register":
            {
                echo Database::Register($_REQUEST["login"], $_REQUEST["password"]);
                break;
            }
        case "GetPaidOffers":
            {
                echo GetPaidOffersHTML(Database::GetPaidOffers());
                break;
            }
    }
}

function GetPostPreviewsHTML($data)
{
    if (count($data) < 1)
    {
        return 0;
    }
    $index = 0;
    $previewsPerRow = 2;
    $previewsPerPage = 6;
    foreach ($data as $post)
    {
        if (!isset($_REQUEST["editable"]))
        {
            ?>
            <a href="/postDetails.php?id=<?= $post->id ?>">
                <?php
            }
            ?>
            <div class="search result <?= $index % 2 == 0 ? "left" : "right"; ?> shadowed">
                <div class="header">
                    <?php
                    $maxLength = 100;
                    if (strlen($post->title) > $maxLength)
                    {
                        $space = strripos(substr($post->title, 0, $maxLength), " ");
                        echo mb_strtoupper(substr($post->title, 0, $space) . "...", "utf-8");
                    }
                    else
                    {
                        echo mb_strtoupper($post->title, "utf-8");
                    }
                    ?>
                </div>
                <div class="content">
                    <div class="image container">
                        <div class="image" style="background-image: url('images/<?= $post->image != "" ? "posts/$post->image" : "no_image.gif"; ?>'); <?= $post->image != "" ? "background-size: cover;" : "background-size: contain;"; ?>"></div>
                        <?php
                        if (isset($_REQUEST["editable"]))
                        {
                            ?>
                            <div class="clear"></div>
                            <a href="/postDetails.php?id=<?= $post->id ?>" target="_blank">
                                <div class="button">ПРОСМОТРЕТЬ</div>
                            </a>
                            <div class="button" onclick="EditPost(<?= $post->id ?>)">ИЗМЕНИТЬ</div>
                            <div class="button" onclick="RemovePost(<?= $post->id ?>)">УДАЛИТЬ</div>
                            <div class="clear"></div>
                            <?php
                        }
                        ?>
                    </div>
                    <div class="text">
                        <div class="description">
                            <?php
                            $post->content = str_replace("\n", "<br/>", $post->content);
                            $maxLength = 1000;
                            if (strlen($post->content) > $maxLength)
                            {
                                $space = strripos(substr($post->content, 0, $maxLength), " ");
                                echo substr($post->content, 0, $space) . "...";
                            }
                            else
                            {
                                echo $post->content;
                            }
                            ?>
                        </div>
                        <div class="time">
                            <?php
                            $date = split(" ", $post->date);
                            echo date_format(new DateTime($date[0]), "d-m-Y");
                            ?>
                        </div>
                        <div class="clear"></div>
                    </div>
                    <div class="clear"></div>
                </div>
            </div>
            <?php
            if (!isset($_REQUEST["editable"]))
            {
                ?>
            </a>
            <?php
        }
        if ($index % 2 != 0)
        {
            ?>
            <div class="clear"></div>
            <?php
        }
        $index++;
    }
    ?>
    <div class="clear"></div>
    <?php
}

function GetPostHTML($data)
{
    $user = Database::GetUser($data->authorId, 0);
    $user = $user[0];
    ?>
    <div class="header">
        <?= mb_strtoupper($data->title, "utf-8"); ?>
    </div>
    <div class="content">
        <?php
        if ($data->image != "")
        {
            ?>
            <a href="images/posts/<?= $data->image ?>" target="_blank">
                <div class="image" style="background-image: url('images/posts/<?= $data->image ?>')"></div>
            </a>
            <?php
        }
        ?>
        <div class="text">
            <div class="description <?= $data->image != "" ? "" : "no-margin"; ?>">
                <?= str_replace("\n", "<br/>", $data->content); ?>
            </div>
            <div class="credentials">
                <a href=""><?= "$user->firstName '$user->nickname' $user->lastName" ?></a>,
                <?php
                $date = split(" ", $data->date);
                echo date_format(new DateTime($date[0]), "d-m-Y");
                ?>
            </div>
        </div>
    </div>
    <?php
}

function GetCategoryHTML($data)
{
    if (count($data) < 1)
    {
        return null;
    }
    $categoryGroup = Database::GetCategoryGroup($data[0]->categoryGroupId);
    ?>
    <div class="category" root_category_id="<?= $data[0]->parentCategoryId ?>">
        <div class="title">
            ВЫБЕРИТЕ <?= mb_strtoupper($categoryGroup->title, "utf-8"); ?>
        </div>
        <div class="input">
            <select precision="<?= $categoryGroup->precision ?>" root_category_id="<?= $data[0]->parentCategoryId ?>" onchange="OnCategoryChanged(this)" required="true">
                <option value="-1"></option>
                <?php
                foreach ($data as $childCategory)
                {
                    ?>
                    <option value="<?= $childCategory->id ?>"><?= mb_strtoupper($childCategory->title, "utf-8"); ?></option>
                    <?php
                }
                ?>  
            </select>
        </div>
        <div class="clear"></div>
    </div>
    <?php
}

function GetCharacteristicHTML($data)
{

    function Place($data, $index)
    {
        $dataLength = count($data);
        $item = $data[$index];
        switch ($item->characteristicTypeId)
        {
            case 0:
                {
                    ?>
                    <div class="characteristic">
                        <div class="title">
                            <?= mb_strtoupper($item->title, "utf-8"); ?>
                        </div>
                        <div class="clear"></div>
                    </div>
                    <div style="margin-bottom: 25px;">
                        <?php
                        for ($i = 0; $i < $dataLength; $i++)
                        {
                            if ($data[$i]->parentCharacteristicId == $item->id)
                            {
                                Place($data, $i);
                            }
                        }
                        ?>
                    </div>
                    <?php
                    break;
                }
            case 1:
                {
                    ?>
                    <div class="characteristic">
                        <div class="title">
                            <?= mb_strtolower($item->title, "utf-8"); ?>
                        </div>

                        <div class="input">
                            <?php
                            if (isset($_REQUEST["ranged"]))
                            {
                                ?>
                                <div class="title">от</div>
                                <div class="input">
                                    <input prefix="min" characteristic_id="<?= $item->id ?>" type="text" pattern="^[0-9]+$"/>
                                </div>
                                <div class="title">до</div>
                                <div class="input">
                                    <input prefix="max" characteristic_id="<?= $item->id ?>" type="text" pattern="^[0-9]+$"/>
                                </div>
                                <?php
                            }
                            else
                            {
                                ?>
                                <input characteristic_id="<?= $item->id ?>" type="text" pattern="^[0-9]+$"/>
                                <?php
                            }
                            ?>
                            <div class="clear"></div>
                        </div>
                        <div class="clear"></div>
                    </div>
                    <?php
                    break;
                }
            case 2:
                {
                    ?>
                    <option value="<?= $item->id ?>"><?= mb_strtolower($item->title, "utf-8"); ?></option>
                    <?php
                    break;
                }
            case 3:
                {
                    if ($item->parentCharacteristicId == 0)
                    {
                        ?>
                        <div class="characteristic">
                            <div class="title">
                                <?= mb_strtoupper($item->title, "utf-8"); ?>
                            </div>
                            <div class="input">
                                <select characteristic_id="<?= $item->id ?>">
                                    <option value = "-1"></option>
                                    <?php
                                    for ($i = 0; $i < $dataLength; $i++)
                                    {
                                        if ($data[$i]->parentCharacteristicId == $item->id)
                                        {
                                            Place($data, $i);
                                        }
                                    }
                                    ?>
                                </select>
                            </div>
                            <div class="clear"></div>
                        </div>
                        <?php
                    }
                    else
                    {
                        ?>
                        <div class="characteristic">
                            <div class="title">
                                <?= mb_strtolower($item->title, "utf-8"); ?>
                            </div>
                            <div class="input">
                                <select characteristic_id="<?= $item->id ?>">
                                    <option value = "-1"></option>
                                    <?php
                                    for ($i = 0; $i < $dataLength; $i++)
                                    {
                                        if ($data[$i]->parentCharacteristicId == $item->id)
                                        {
                                            Place($data, $i);
                                        }
                                    }
                                    ?>
                                </select>
                            </div>
                            <div class="clear"></div>
                        </div>
                        <?php
                    }

                    break;
                }
        }
    }

    $dataLength = count($data);
    for ($j = 0; $j < $dataLength; $j++)
    {
        if ($data[$j]->parentCharacteristicId == 0)
        {
            Place($data, $j);
        }
    }
}

function GetOfferPreviewsHTML($data)
{
    if ($data == null || count($data) < 1)
    {
        return 0;
    }
    $index = 0;
    $previewsPerRow = 2;
    $previewsPerPage = 6;
    foreach ($data as $offer)
    {
        $image = Database::GetOfferPreviewImage($offer->id);
        if ($image == null)
        {
            $style = "background-size: contain;";
        }
        else
        {
            $style = "background-size: cover;";
        }
        if ($_REQUEST["ownerId"] == 0)
        {
            ?>    
            <a href="/offerDetails.php?id=<?= $offer->id ?>">
                <?php
            }
            ?>

            <div class="result shadowed <?= $index % 2 == 0 ? "left" : "right"; ?>">
                <div class="header">
                    <?php
                    $maxLength = 100;
                    if (strlen($offer->title) > $maxLength)
                    {
                        $space = strripos(substr($offer->title, 0, $maxLength), " ");
                        echo mb_strtoupper(substr($offer->title, 0, $space) . "...", "utf-8");
                    }
                    else
                    {
                        echo mb_strtoupper($offer->title, "utf-8");
                    }
                    ?>
                </div>
                <div class="content">
                    <div class="image container">
                        <div class="image" style="background-image: url('images/<?= $image == null ? "no_image.gif" : "offers/$image->path"; ?>'); <?= $style ?>">

                        </div>
                        <?php
                        if ($_REQUEST["ownerId"] > 0)
                        {
                            ?>    
                            <div class="clear"></div>
                            <a href="/offerDetails.php?id=<?= $offer->id ?>" target="_blank">
                                <div class="button">ПРОСМОТРЕТЬ</div>
                            </a>
                            <div class="button" onclick="EditOffer(<?= $offer->id ?>)">ИЗМЕНИТЬ</div>
                            <div class="button" onclick="RemoveOffer(<?= $offer->id ?>)">УДАЛИТЬ</div>
                            <div class="clear"></div>
                            <?php
                        }
                        ?>
                    </div>
                    <div class="text">
                        <div class="location">
                            <?php
                            $maxLength = 100;
                            if (strlen($offer->location) > $maxLength)
                            {
                                echo substr($offer->location, 0, strripos(substr($offer->location, 0, $maxLength), " ")) . "...";
                            }
                            else
                            {
                                echo $offer->location;
                            }
                            ?>
                        </div>
                        <div class="description">
                            <?php
                            $maxLength = 650;
                            if (strlen($offer->description) > $maxLength)
                            {
                                echo substr($offer->description, 0, strripos(substr($offer->description, 0, $maxLength), " ")) . "...";
                            }
                            else
                            {
                                echo $offer->description;
                            }
                            ?>
                        </div>
                        <div class="clear"></div>
                    </div>
                    <div class="clear"></div>
                </div>
            </div>
            <?php
            if ($_REQUEST["ownerId"] == 0)
            {
                ?>    
            </a>
            <?php
        }
        if ($index % 2 != 0)
        {
            ?>
            <div class="clear"></div>
            <?php
        }
        $index++;
    }
    ?>
    <div class="clear"></div>
    <?php
}

function GetOfferHTML($data)
{

    function characteristicSearch($element)
    {
        return $element->id;
    }

    $currencyJSON = file("https://api.privatbank.ua/p24api/pubinfo?json&exchange&coursid=5");
    $currencyJSON = json_decode($currencyJSON[0]);
    foreach ($currencyJSON as $c)
    {
        $currency[$c->ccy] = $c->sale;
    }
    $currency["UAH"] = 1;
    $images = Database::GetOfferImages($data->id);
    $previewImage = Database::GetOfferPreviewImage($data->id);
    ?>
    <div class="header">
        ОПИСАНИЕ ПРЕДЛОЖЕНИЯ 123
    </div>
    <div id="offerContent" class="content" owner_id="<?= $data->ownerId ?>">
        <div id="address" style="display: none;"><?= $data->location ?></div>
        <?php
        if (count($images) > 0)
        {
            ?>
            <div class="gallery container">
                <a id="previewLink" href="images/offers/<?= $previewImage->path ?>" target="_blank">
                    <div id="preview" class="preview<?= count($images) > 1 ? "" : " wide"; ?>" style="background-image: url('images/offers/<?= $previewImage->path ?>')"></div>
                </a>
                <?php
                if (count($images) > 1)
                {
                    ?>
                    <div class="list">
                        <?php
                        $index = 0;
                        for ($i = 0; $i < 3; $i++)
                        {
                            ?>
                            <div class="list row">
                                <?php
                                for ($j = 0; $j < 3; $j++, $index++)
                                {
                                    ?>
                                    <div class="list item" style="background-image: url('images/offers/<?= $images[$index]->path ?>');" onclick="<?= strlen($images[$index]->path) > 0 ? "OnImageClicked('" . $images[$index]->path . "')" : ""; ?>"></div>
                                    <?php
                                }
                                ?>
                            </div>
                            <?php
                        }
                        ?>
                    </div>
                    <?php
                }
                ?>
                <div class="clear"></div>
            </div>
            <?php
        }
        ?>
        <div class="description container">
            <?php
            $offerCharacteristics = Database::GetOfferCharacteristics($data->id);
            if (count($offerCharacteristics) > 0)
            {
                ?>
                <div class="characteristics">
                    <?php
                    $characteristics = Database::GetCharacteristic(0, $data->categoryId);
                    $rootCharacteristic = "";
                    $units = false;
                    foreach ($offerCharacteristics as $oc)
                    {
                        $groupIndex = 0;
                        $group = null;
                        $i = array_search($oc->characteristicId, array_map("characteristicSearch", $characteristics));
                        if ($i != false && $i != null)
                        {
                            $seek = true;
                            $c = $characteristics[$i];
                            $units = $c->unitId != 0 ? $c->unitId : false;
                            while ($seek)
                            {
                                $group[$groupIndex++] = $c;
                                if ($c->parentCharacteristicId == 0)
                                {
                                    $seek = false;
                                    break;
                                }
                                $j = array_search($c->parentCharacteristicId, array_map("characteristicSearch", $characteristics));
                                $c = $characteristics[$j];
                            }
                        }
                        $group = array_reverse($group);
                        $previousCharacteristicTitle = "";
                        $rootCharacteristicType = $group[0]->characteristicTypeId;
                        for ($k = 0; $k < count($group); $k++)
                        {
                            switch ($group[$k]->characteristicTypeId)
                            {
                                case 0:
                                    {
                                        if ($rootCharacteristic != $group[$k]->title || $rootCharacteristic == "")
                                        {
                                            ?>
                                            <div class="characteristic group">
                                                <div class="title" ><?= mb_strtoupper($group[$k]->title, "utf-8"); ?></div>
                                                <?php
                                                if ($units == 2)
                                                {
                                                    $u = Database::GetUnit($units, 0);
                                                    $u = Database::GetUnit(0, $u[0]->unitGroup);
                                                    ?>
                                                    <div class="unit">
                                                        <?php
                                                        foreach ($u as $tmpUnit)
                                                        {
                                                            ?>
                                                            <div class="item" exchange_rate="<?= $currency[$tmpUnit->code] ?>" symbol="<?= $tmpUnit->symbol ?>" onclick="OnUnitChanged(this)" thisFuckingItem="true"><?= $tmpUnit->id ?></div>
                                                            <?php
                                                        }
                                                        ?>
                                                        <div class="clear"></div>
                                                    </div>
                                                    <?php
                                                }
                                                ?>
                                                <div class="clear"></div>
                                            </div>
                                            <?php
                                        }
                                        break;
                                    }
                                case 1:
                                    {
                                        ?>
                                        <div class="characteristic" characteristic_id="<?= $oc->characteristicId ?>">
                                            <?php
                                            if ($units != false)
                                            {
                                                $symbol = Database::GetUnit($units, 0);
                                            }
                                            else
                                            {
                                                $symbol = null;
                                            }
                                            $tmpFlag = 0;
                                            if ($symbol != null)
                                            {
                                                if ($units != 2)
                                                {
                                                    $tmpFlag = 1;
                                                    $symbol = $symbol[0]->symbol;
                                                }
                                                else
                                                {
                                                    $tmpFlag = 2;
                                                    $symbol = $symbol[0]->symbol;
                                                }
                                            }
                                            ?>
                                            <div class="title" ><?= mb_strtolower($group[$k]->title, "utf-8") . ($tmpFlag == 1 ? " ($symbol)" : "") ?></div>
                                            <div class="value" <?= $units == 2 ? "unit_id='$units'" : ""; ?> initial_value="<?= $oc->value ?>"><?= $oc->value . ($tmpFlag == 2 ? ".00 $symbol" : "") ?></div>
                                            <div class="clear"></div>
                                        </div>
                                        <?php
                                        break;
                                    }
                                case 2:
                                    {
                                        ?>
                                        <div class="characteristic <?= $rootCharacteristicType == 3 ? "group" : ""; ?>" characteristic_id="<?= $oc->characteristicId ?>">
                                            <div class="title" ><?= $rootCharacteristicType != 3 ? mb_strtolower($previousCharacteristicTitle, "utf-8") : mb_strtoupper($previousCharacteristicTitle, "utf-8"); ?></div>
                                            <div class="value"><?= mb_strtolower($group[$k]->title, "utf-8"); ?></div>
                                            <div class="clear"></div>
                                        </div>
                                        <?php
                                        break;
                                    }
                            }
                            $previousCharacteristicTitle = $group[$k]->title;
                        }
                        $rootCharacteristic = $group[0]->title;
                    }
                    ?>
                </div>
                <?php
            }
            ?>
            <div class="title <?= count($offerCharacteristics) > 0 ? "" : "wide"; ?> <?= count($images) > 0 ? "" : "no-margin"; ?>">
                <?= mb_strtoupper($data->title, "utf-8"); ?>
            </div>
            <div class="description <?= count($offerCharacteristics) > 0 ? "" : "wide"; ?>">
                <?= str_replace("\n", "<br/>", $data->description); ?>
            </div>
            <div class="clear"></div>
        </div>
        <?php
        if ($data->video != "")
        {
            ?>
            <div class="video container">
                <div class="video">
                    <iframe width="100%" height="100%" src="<?= $data->video ?>" frameborder="0" allowfullscreen></iframe>
                </div>
            </div>
            <?php
        }
        ?>
    </div>
    <?php
}

function GetUserCardHTML($data)
{
    foreach ($data as $user)
    {
        ?>
        <div id="user_<?= $user->id ?>" user_id="<?= $user->id ?>" class="user card shadowed">
            <div class="header"><?= mb_strtoupper("$user->firstName $user->lastName", "utf-8"); ?></div>
            <div class="content">
                <a href="images/users/<?= $user->photo ?>">
                    <div class="image" style="background-image: url('images/users/<?= $user->photo ?>')"></div>
                </a>
                <div class="description">
                    <div class="info">
                        <div class="title">EMAIL: </div>
                        <div class="value"><?= $user->email ?></div>
                        <div class="clear"></div>
                    </div>
                    <div class="info">
                        <div class="title">ТЕЛЕФОН: </div>
                        <div class="value"><?= $user->telephone ?></div>
                        <div class="clear"></div>
                    </div>
                    <div class="info">
                        <div class="title">САЙТ: </div>
                        <div class="value"><?= $user->site ?></div>
                        <div class="clear"></div>
                    </div>
                    <div class="info">
                        <div class="title">ДОЛЖНОСТЬ: </div>
                        <div class="value"><?= $user->position ?></div>
                        <div class="clear"></div>
                    </div>
                    <div class="info">
                        <div class="title">ОПЫТ РАБОТЫ: </div>
                        <div class="value"><?= $user->experience ?></div>
                        <div class="clear"></div>
                    </div>
                    <div class="info">
                        <div class="title">СТРАНА: </div>
                        <div class="value"><?= $user->country ?></div>
                        <div class="clear"></div>
                    </div>
                    <?php
                    if (isset($_REQUEST["full"]))
                    {
                        ?>
                        <div class="info">
                            <div class="title">ДАТА РОЖДЕНИЯ: </div>
                            <div class="value"><?= date_format(new DateTime($user->dateOfBirth), "d.m.Y"); ?></div>
                            <div class="clear"></div>
                        </div>
                        <div class="info">
                            <div class="title">ДАТА РЕГИСТРАЦИИ: </div>
                            <div class="value"><?= date_format(new DateTime($user->dateOfRegistration), "d.m.Y"); ?></div>
                            <div class="clear"></div>
                        </div>
                        <?php
                    }
                    ?>
                </div>
                <div class="clear"></div>
                <div class="info">
                    <div class="title">О СЕБЕ: </div>
                    <div class="value">
                        <?= $user->about; ?>
                    </div>
                    <div class="clear"></div>
                </div>
                <?php
                if (isset($_REQUEST["full"]))
                {
                    ?>
                    <a href="editProfile.php?id=<?= $user->id ?>" target="_blank">
                        <div class="edit">
                            <input id="editUserCard" user_id="<?= $user->id ?>" type="button" value="РЕДАКТИРОВАТЬ ПРОФИЛЬ"/>
                        </div>
                    </a>
                    <?php
                }
                ?>
                <div class="clear"></div>
            </div>
        </div>

        <?php
    }
}

function UploadImage($path)
{
    foreach ($_FILES as $file)
    {
        $uploadPath = "../images/$path";
        $type = explode("/", $file["type"]);
        $type = $type[1];
        $tmpName = $file["tmp_name"];
        $error = intval($file["error"]);
        if ($error == 0)
        {
            $index = 0;
            $fullFilename = "$uploadPath/" . ($path == "offers" ? "offer_image-" : ($path == "posts" ? "post_image-" : "user_image-")) . $index . ".$type";
            $filename = ($path == "offers" ? "offer_image-" : ($path == "posts" ? "post_image-" : "user_image-")) . $index . ".$type";
            while (file_exists($fullFilename))
            {
                $index++;
                $fullFilename = "$uploadPath/" . ($path == "offers" ? "offer_image-" : ($path == "posts" ? "post_image-" : "user_image-")) . $index . ".$type";
                $filename = ($path == "offers" ? "offer_image-" : ($path == "posts" ? "post_image-" : "user_image-")) . $index . ".$type";
            }
            move_uploaded_file($tmpName, $fullFilename);
        }
    }
    switch ($path)
    {
        case "offers":
            {
                $index = $_REQUEST["index"];
                $f = "window.top.files[$index].OnLoaded($error, '$filename');";
                break;
            }
        case "posts":
            {
                $f = "window.top.OnPostImageLoaded($error, '$filename');";
                break;
            }
        case "users":
            {
                $f = "window.top.OnUserImageLoaded($error, '$filename');";
            }
    }
    ?>
    <html>
        <head></head>
        <body onload="<?= $f ?>">
        </body>
    </html>
    <?php
}

function UnloadImages($path, $files)
{
    foreach ($files as $file)
    {
        unlink("../images/$path/$file");
    }
}

function RemoveOffer($id)
{
    Database::RemoveOffer($id);
}

function RemoveUnusedImages($data)
{
    $directory = scandir("../images/offers");
    $directory = array_merge($directory, scandir("../images/posts"));
    $directory = array_merge($directory, scandir("../images/users"));
    Debug::Show($directory);
    Debug::Show($data);
    foreach ($directory as $image)
    {
        if ($image != "." && $image != "..")
        {
            $flag = false;
            for ($i = 0; $i < count($data); $i++)
            {
                if (strcmp($image, $data[$i]->path) == 0)
                {
                    $flag = true;
                }
            }
            if ($flag == false)
            {
                if (file_exists("../images/offers/$image"))
                {
                    unlink("../images/offers/$image");
                }
                else if (file_exists("../images/posts/$image"))
                {
                    unlink("../images/posts/$image");
                }
                else
                {
                    unlink("../images/users/$image");
                }
            }
        }
    }
    $directory = scandir("../images/offers");
    $directory = array_merge($directory, scandir("../images/posts"));
    $directory = array_merge($directory, scandir("../images/users"));
    Debug::Show($directory);
}

function LinkOfferImages($files)
{
    foreach ($files as $file)
    {
        Database::LinkOfferImage($file, $_REQUEST["offerId"]);
    }
}

function GetEditableOfferHTML($data)
{
    $offer = $data;
    ?>
    <div class="characteristic">
        <div class="title">
            НАЗВАНИЕ
        </div>
        <div class="input">
            <input id="title" type="text" value="<?= $offer->title; ?>"/>
        </div>
        <div class="clear"></div>
    </div>
    <div class="characteristic">
        <div class="title">
            ОПИСАНИЕ
        </div>
        <div class="input">
            <textarea id="description"><?= $offer->description; ?></textarea>
        </div>
        <div class="clear"></div>
    </div>
    <div class="characteristic">
        <div class="title">
            РАСПОЛОЖЕНИЕ
        </div>
        <div class="input">
            <input id="location" type="text" value="<?= $offer->location; ?>"/>
        </div>
        <div class="clear"></div>
    </div>
    <div class="characteristic">
        <div class="title">
            ССЫЛКА НА ВИДЕО
        </div>
        <div class="input">
            <input id="video" type="text" value="<?= $offer->video; ?>"/>
        </div>
        <div class="clear"></div>
    </div>
    <div id="categories">
        <?php
        $categories;
        $index = 0;
        $category = Category::CreateEmpty();
        $category->parentCategoryId = $offer->categoryId;
        do
        {
            $category = Database::GetCategory($category->parentCategoryId, 0);
            $category = $category[0];
            $categories[$index++] = $category;
        }
        while (intval($category->parentCategoryId) != 0);
        $categories = array_reverse($categories);
        foreach ($categories as $c)
        {
            $categoryGroup = Database::GetCategoryGroup($c->categoryGroupId);
            $childCategories = Database::GetCategory(0, $c->parentCategoryId);
            ?>
            <div class="category" root_category_id="<?= $c->parentCategoryId ?>">
                <div class="title">
                    <?= mb_strtoupper($categoryGroup->title, "utf-8"); ?>
                </div>
                <div class="input">
                    <select precision="<?= $categoryGroup->precision ?>" root_category_id="<?= $c->parentCategoryId ?>" onchange="OnCategoryChanged(this)" required="true">
                        <option value="-1"></option>
                        <?php
                        foreach ($childCategories as $childCategory)
                        {
                            ?>
                            <option value="<?= $childCategory->id ?>" <?= $childCategory->id == $c->id ? "selected='selected'" : ""; ?>><?= mb_strtolower($childCategory->title, "utf-8"); ?></option>
                            <?php
                        }
                        ?>  
                    </select>
                </div>
                <div class="clear"></div>
            </div>
            <?php
        }
        ?>
    </div>
    <div id="characteristics">
        <?php

        function PlaceEditable($data, $index, $offerCharacteristics)
        {
            $dataLength = count($data);
            $item = $data[$index];
            switch ($item->characteristicTypeId)
            {
                case 0:
                    {
                        ?>
                        <div class="characteristic">
                            <div class="title">
                                <?= mb_strtoupper($item->title, "utf-8"); ?>
                            </div>
                            <div class="clear"></div>
                        </div>
                        <div style="margin-bottom: 25px;">
                            <?php
                            for ($i = 0; $i < $dataLength; $i++)
                            {
                                if ($data[$i]->parentCharacteristicId == $item->id)
                                {
                                    PlaceEditable($data, $i, $offerCharacteristics);
                                }
                            }
                            ?>
                        </div>
                        <?php
                        break;
                    }
                case 1:
                    {
                        ?>
                        <div class="characteristic">
                            <div class="title">
                                <?= mb_strtolower($item->title, "utf-8"); ?>
                            </div>

                            <div class="input">
                                <?php
                                $targetValue = -1;
                                for ($l = 0; $l < count($offerCharacteristics); $l++)
                                {
                                    if ($offerCharacteristics[$l]->characteristicId == $item->id)
                                    {
                                        $targetValue = $offerCharacteristics[$l]->value;
                                        break;
                                    }
                                }
                                ?>
                                <input characteristic_id="<?= $item->id ?>" value="<?= $targetValue != -1 ? $targetValue : ""; ?>" type="text" pattern="^[0-9]+$"/>
                                <div class="clear"></div>
                            </div>
                            <div class="clear"></div>
                        </div>
                        <?php
                        break;
                    }
                case 2:
                    {
                        $targetValue = -1;
                        for ($l = 0; $l < count($offerCharacteristics); $l++)
                        {
                            if ($offerCharacteristics[$l]->characteristicId == $item->id)
                            {
                                $targetValue = $offerCharacteristics[$l]->value;
                                break;
                            }
                        }
                        ?>
                        <option value="<?= $item->id ?>" <?= $targetValue != -1 ? "selected='selected'" : ""; ?>><?= mb_strtolower($item->title, "utf-8"); ?></option>
                        <?php
                        break;
                    }
                case 3:
                    {
                        if ($item->parentCharacteristicId == 0)
                        {
                            ?>
                            <div class="characteristic">
                                <div class="title">
                                    <?= mb_strtoupper($item->title, "utf-8"); ?>
                                </div>
                                <div class="input">
                                    <select characteristic_id="<?= $item->id ?>">
                                        <option value = "-1"></option>
                                        <?php
                                        for ($i = 0; $i < $dataLength; $i++)
                                        {
                                            if ($data[$i]->parentCharacteristicId == $item->id)
                                            {
                                                PlaceEditable($data, $i, $offerCharacteristics);
                                            }
                                        }
                                        ?>
                                    </select>
                                </div>
                                <div class="clear"></div>
                            </div>
                            <?php
                        }
                        else
                        {
                            ?>
                            <div class="characteristic">
                                <div class="title">
                                    <?= mb_strtolower($item->title, "utf-8"); ?>
                                </div>
                                <div class="input">
                                    <select characteristic_id="<?= $item->id ?>">
                                        <option value = "-1"></option>
                                        <?php
                                        for ($i = 0; $i < $dataLength; $i++)
                                        {
                                            if ($data[$i]->parentCharacteristicId == $item->id)
                                            {
                                                PlaceEditable($data, $i, $offerCharacteristics);
                                            }
                                        }
                                        ?>
                                    </select>
                                </div>
                                <div class="clear"></div>
                            </div>
                            <?php
                        }
                        break;
                    }
            }
        }

        $offerCharacteristics = Database::GetOfferCharacteristics($offer->id);
        $data = Database::GetCharacteristic(0, $offer->categoryId);
        $dataLength = count($data);
        for ($j = 0; $j < $dataLength; $j++)
        {
            if ($data[$j]->parentCharacteristicId == 0)
            {
                PlaceEditable($data, $j, $offerCharacteristics);
            }
        }
        ?>
    </div>
    <div class="confirm">
        <input type="button" value="СОХРАНИТЬ ИЗМЕНЕНИЯ" onclick="OnUpdateOfferClicked()"/>
    </div>
    <div class="characteristic">
        <div class="title">
            ФОТОГРАФИИ
        </div>
        <div id="fileInputContainer" class="input">
            <input value="ЗАГРУЗИТЬ" type="button" onclick="OnAddFileClicked()"/>
            <div class="hidden" id="source">
                <form action="" method="POST" enctype="multipart/form-data">
                    <input class="hidden" name="photo" type="file" accept="image/*"/>
                    <div class="file">
                        <div class="description">
                            ...ВЫБРАТЬ ИЗОБРАЖЕНИЕ...
                        </div>
                        <div class="button">
                            УДАЛИТЬ
                        </div>
                        <div class="clear"></div>
                    </div>
                </form>
            </div>
        </div>
        <div class="clear"></div>
        <div id="image_preview_container" class="image container">
            <?php
            GetEditableOfferImages($offer->id);
            ?>
            <div class="clear"></div>
        </div>
        <div class="clear"></div>
    </div>
    <?php
}

function GetEditableOfferImages($id)
{
    $images = Database::GetOfferImages($id);
    if (count($images) > 0)
    {
        foreach ($images as $image)
        {
            ?>
            <div class="image" style="background-image: url('<?= "../images/offers/$image->path"; ?>')" image_id="<?= $image->id ?>" image_path="<?= $image->path ?>">
                <div class="preview <?= $image->isPreview == "1" ? "selected" : ""; ?>" onclick="OnMakePreviewClicked(<?= $image->id ?>)">
                    <img style="width:50px; height: 50px;" src="../images/flag.png" />
                </div>
                <div class="enlarge" onclick="window.open('<?= "../images/offers/$image->path"; ?>', '_blank');">
                    <img style="width:50px; height: 50px;" src="../images/eye.png" />
                </div>
                <div class="remove" onclick="OnRemoveImageClicked(<?= $image->id ?>)">
                    <img style="width:50px; height: 50px;" src="../images/cross.png" />
                </div>
                <div class="clear"></div>
            </div>
            <?php
        }
        ?>
        <div class="clear"></div>
        <?php
    }
}

function GetEditablePostHTML($data)
{
    ?>
    <div class="characteristic">
        <div class="title">
            НАЗВАНИЕ
        </div>
        <div class="input">
            <input id="postTitle" type="text" value="<?= $data->title ?>"/>
        </div>
        <div class="clear"></div>
    </div>
    <div class="characteristic">
        <div class="title">
            ТЕКСТ
        </div>
        <div class="input">
            <textarea id="postContent"><?= $data->content ?>"</textarea>
        </div>
        <div class="clear"></div>
    </div>
    <div class="characteristic">
        <div class="title">
            ИЗОБРАЖЕНИЕ
        </div>
        <div class="input">
            <input value="ЗАГРУЗИТЬ" type="button" disabled/>
            <div>
                <form id="postImageForm" action="../core/functions.php?function=UploadImage&path=posts" method="POST" enctype="multipart/form-data" target="postFrame">
                    <input id="postImage" class="hidden" name="postImage" type="file" accept="image/*"/>
                    <input id="resetPostImage" class="hidden" type="reset"/>
                    <div id="postImageDiv" class="file closing">
                        <div id="postImageName" class="description" onclick="OnAddPostImageClicked()">
                            ...ВЫБРАТЬ ИЗОБРАЖЕНИЕ...
                        </div>
                        <div class="clear"></div>
                    </div>
                </form>
                <iframe id="postImageFrame" name="postFrame" src="#" class="hidden"></iframe>
            </div>
        </div>
        <div class="clear"></div>
    </div>
    <div id="postImageLarge" class="characteristic">
        <?php
        GetEditablePostImage($data->id);
        ?>
    </div>
    <div class="confirm">
        <input type="button" value="СОХРАНИТЬ ИЗМЕНЕНИЯ" onclick="OnUpdatePostClicked()"/>
    </div>
    <?php
}

function GetEditablePostImage($id)
{
    $image = Database::GetPostImage($id);
    if ($image != null)
    {
        ?>
        <div class="input right">
            <div class="image" style="background-image: url('<?= "../images/posts/$image"; ?>')">
                <div class="enlarge" onclick="window.open('<?= "../images/posts/$image"; ?>', '_blank');">
                    <img style="width:50px; height: 50px;" src="../images/eye.png" />
                </div>
                <div class="remove" onclick="OnRemoveImageClicked()">
                    <img style="width:50px; height: 50px;" src="../images/cross.png" />
                </div>
                <div class="clear"></div>
            </div>
        </div>
        <div class="clear"></div>
        <?php
    }
}

function GetProfileInfo($data)
{
    $data = $data[0];
    ?>
    <div class="characteristic">
        <div class="title">
            ЛОГИН
        </div>
        <div class="input">
            <input id="nickname" type="text" value="<?= $data->nickname ?>" required="required"/>
        </div>
        <div class="clear"></div>
    </div>
    <div class="characteristic">
        <div class="title">
            ПАРОЛЬ
        </div>
        <div class="input">
            <input id="password" type="password" value="<?= $data->password ?>" required="required"/>
        </div>
        <div class="clear"></div>
    </div>
    <div class="characteristic">
        <div class="title">
            ИМЯ
        </div>
        <div class="input">
            <input id="firstname" type="text" value="<?= $data->firstName ?>"/>
        </div>
        <div class="clear"></div>
    </div>
    <div class="characteristic">
        <div class="title">
            ФАМИЛИЯ
        </div>
        <div class="input">
            <input id="lastname" type="text" value="<?= $data->lastName ?>"/>
        </div>
        <div class="clear"></div>
    </div>
    <div class="characteristic">
        <div class="title">
            E-MAIL
        </div>
        <div class="input">
            <input id="email" type="text" value="<?= $data->email ?>"/>
        </div>
        <div class="clear"></div>
    </div>
    <div class="characteristic">
        <div class="title">
            ТЕЛЕФОН
        </div>
        <div class="input">
            <input id="telephone" type="text" value="<?= $data->telephone ?>"/>
        </div>
        <div class="clear"></div>
    </div>
    <div class="characteristic">
        <div class="title">
            САЙТ
        </div>
        <div class="input">
            <input id="site" type="text" value="<?= $data->site ?>"/>
        </div>
        <div class="clear"></div>
    </div>
    <div class="characteristic">
        <div class="title">
            ДОЛЖНОСТЬ
        </div>
        <div class="input">
            <input id="position" type="text" value="<?= $data->position ?>"/>
        </div>
        <div class="clear"></div>
    </div>
    <div class="characteristic">
        <div class="title">
            ОПЫТ РАБОТЫ
        </div>
        <div class="input">
            <input id="experience" type="text" value="<?= $data->experience ?>"/>
        </div>
        <div class="clear"></div>
    </div>
    <div class="characteristic">
        <div class="title">
            СТРАНА
        </div>
        <div class="input">
            <input id="country" type="text" value="<?= $data->country ?>"/>
        </div>
        <div class="clear"></div>
    </div>
    <div class="characteristic">
        <div class="title">
            ДАТА РОЖДЕНИЯ (ГОД-МЕСЯЦ-ЧИСЛО)
        </div>
        <div class="input">
            <input id="date_of_birth" type="date" value="<?= date_format(new DateTime($data->dateOfBirth), "Y-m-d"); ?>" pattern="\d{4}\-\d{2}\-\d{2}"/>
        </div>
        <div class="clear"></div>
    </div>
    <div class="characteristic">
        <div class="title">
            О СЕБЕ
        </div>
        <div class="input">
            <textarea  id="about"><?= $data->about ?></textarea>
        </div>
        <div class="clear"></div>
    </div>
    <div class="characteristic">
        <div class="title">
            ФОТОГРАФИЯ ПРОФИЛЯ
        </div>
        <div class="input">
            <input value="ЗАГРУЗИТЬ" type="button" disabled/>
            <div>
                <form id="userImageForm" action="../core/functions.php?function=UploadImage&path=users" method="POST" enctype="multipart/form-data" target="userFrame">
                    <input id="userImage" class="hidden" name="userImage" type="file" accept="image/*"/>
                    <input id="resetUserImage" class="hidden" type="reset"/>
                    <div id="userImageDiv" class="file closing">
                        <div id="userImageName" class="description" onclick="OnAddUserImageClicked()">
                            ...ВЫБРАТЬ ИЗОБРАЖЕНИЕ...
                        </div>
                        <div class="clear"></div>
                    </div>
                </form>
                <iframe id="userImageFrame" name="userFrame" src="#" class="hidden"></iframe>
            </div>
        </div>
        <div class="clear"></div>
    </div>
    <div id="profileImageLarge" class="characteristic">
        <?php
        GetEditableProfileImage($data->id);
        ?>
    </div>
    <div class="confirm">
        <input type="button" value="ИЗМЕНИТЬ ДАННЫЕ ПРОФИЛЯ" onclick="OnUpdateUserClicked()"/>
    </div>
    <?php
}

function GetEditableProfileImage($id)
{
    $image = Database::GetUserImage($id);
    if ($image != null)
    {
        ?>
        <div class="input right">
            <div class="image" style="background-image: url('<?= "../images/users/$image"; ?>')">
                <div class="enlarge" onclick="window.open('<?= "../images/users/$image"; ?>', '_blank');">
                    <img style="width:50px; height: 50px;" src="../images/eye.png" />
                </div>
                <div class="remove" onclick="OnRemoveImageClicked()">
                    <img style="width:50px; height: 50px;" src="../images/cross.png" />
                </div>
                <div class="clear"></div>
            </div>
        </div>
        <div class="clear"></div>
        <?php
    }
}

function GetPaidOffersHTML($data)
{
    if (count($data) <= 0)
    {
        return 0;
    }
    $i = 0;
    foreach ($data as $offer)
    {
        $image = Database::GetOfferPreviewImage($offer->id);
        if ($image->path == "")
        {
            $image->path = "no_image.gif";
        }
        else
        {
            $image->path = "offers/$image->path";
        }
        ?>
        <a href="../offerDetails.php?id=<?= $offer->id ?>">
            <div class="result <?= $i == 0 ? "left" : ($i == count($data) - 1 ? "right" : "center"); ?> shadowed">
                <div class="header">
                    <p>
                        <?= $offer->title ?>
                    </p>
                </div>
                <div class="content">
                    <div class="image" style="background-image: url('<?= "images/$image->path" ?>'); <?= $image->path == "no_image.gif" ? "background-size: contain;" : ""; ?>"></div>
                </div>
            </div>
        </a>
        <?php
        $i++;
    }
    ?>
    <div class="clear"></div>
    <?php
}
