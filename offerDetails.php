<!DOCTYPE html>
<?php
include_once './core/database.php';
$data = Database::GetOffer($_REQUEST["id"], 0);

$images = Database::GetOfferImages($data->id);
$previewImage = Database::GetOfferPreviewImage($data->id);

$defaultUnit = 4;
$defaultUnitCode = "USD";

?>
<html>
    <head>
        <title>TOP-REAL</title>
        <meta name="description" content="<?= $data->title ?>" />
        <meta property="og:title" content="<?= $data->title ?>"/>
        <meta property="og:description" content="<?= $data->title ?>"/>
        <meta property="og:image" content="http://top-real.com.ua/images/offers/<?= $previewImage->path ?>"/>
        <meta property="og:url" content="http://top-real.com.ua/offerDetails.php?id=<?= $_REQUEST["id"] ?>" />
        <meta property="og:type" content="article" />
        <meta charset="utf-8" />
        <link href="styles/offerDetails.css" type="text/css" rel="stylesheet" />
        <link href="styles/common.css" type="text/css" rel="stylesheet" />
        <script src="scripts/offerDetails.js" type="text/javascript"></script>
        <script src="scripts/jquery.min.js" type="text/javascript"></script>
        <script src="https://api-maps.yandex.ru/2.1/?lang=ru_RU" type="text/javascript"></script>
        <link rel="shortcut icon" href="images/favicon.ico" />
    </head>
    <body onload="OnBodyLoaded(<?= $_REQUEST["id"] ?>)">
        <div class="page">
            <?php
            include './parts/header.php';
            ?>
            <div id="details_container" class="details container shadowed">
                <?php

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
                ?>
                <div class="header">
                    ОПИСАНИЕ ПРЕДЛОЖЕНИЯ
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
                                                            if ($units == $defaultUnit)
                                                            {
                                                                $u = Database::GetUnit($units, 0);
                                                                $u = Database::GetUnit(0, $u[0]->unitGroup);
                                                                ?>
                                                                <div class="unit">
                                                                    <?php
                                                                    foreach ($u as $tmpUnit)
                                                                    {
                                                                        ?>
                                                                        <div class="item" exchange_rate="<?= $currency[$tmpUnit->code] ?>" symbol="<?= $tmpUnit->code ?>" onclick="OnUnitChanged(this)" <?= $tmpUnit->code == $defaultUnitCode ? "initial" : ""; ?>><?= $tmpUnit->code ?></div>
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
                                                        if ($units != $defaultUnit)
                                                        {
                                                            $symbol = "";
                                                        }
                                                        else
                                                        {
                                                            $symbol = Database::GetUnit($units, 0);
                                                            $symbol = $symbol[0]->code;
                                                        }
                                                        ?>
                                                        <div class="title" ><?= mb_strtolower($group[$k]->title, "utf-8")?></div>
                                                        <div class="value" <?= $units == $defaultUnit ? "unit_id='$units'" : ""; ?> initial_value="<?= $oc->value ?>"><?= $oc->value . " " . $symbol ?></div>
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
                                <iframe width="100%" height="100%" src="<?= 'https://www.youtube.com/embed/' . $data->video ?>" frameborder="0" allowfullscreen></iframe>
                            </div>
                        </div>
                        <?php
                    }
                    ?>
                </div>
            </div>
            <div class="map container shadowed">
                <div class="header">РАСПОЛОЖЕНИЕ НА КАРТЕ</div>
                <div class="content">
                    <div id="map" class="map"></div>
                </div>
            </div>
            <div class="header container shadowed">
                <div class="header">ВЛАДЕЛЕЦ ПРЕДЛОЖЕНИЯ</div>
            </div>
            <div id="owner_container" class="owner container">

            </div>
        </div>
        <?php
        include './parts/footer.php';
        ?>
    </body>
</html>