<?php
include_once 'classes/database.php';
include_once 'classes/offer.php';
$item = database::GetOffer($_REQUEST["id"]);
?>
<html>
    <head>
        <title> TOP-REAL </title>
        <meta charset="utf-8" />
        <meta property="og:image" content="http://top-real.com.ua/<?= substr($item->preview, 3); ?>" />
        <meta property="og:title" content="<?= $item->title; ?>" />
        <meta property="og:description" content="<?= $item->description; ?>" />
        <link rel="stylesheet" href="styles/index.css" />
        <link rel="stylesheet" href="styles/offer_details.css" />
        <script type="text/javascript" src="scripts/offer_details.js"></script>
        <script type="text/javascript" src="scripts/jquery.min.js"></script>
        <script src="https://maps.googleapis.com/maps/api/js?v=3.exp"></script>
    </head>
    <body onload="OnPageLoaded()">
        <div class="page">
            <?php include "./page_blocks/header.php"; ?>
            <div class="body">
                <div>
                    <div style="float: left; width: 50%; height: 450px;">
                        <div id="image_large" style="height: 100%; width: 100%; background-image: url(<?= "'" . $item->preview . "'" ?>); background-size: contain; background-repeat: no-repeat; background-position: center;">
                        </div>
                    </div>
                    <div style="float: left; width: 50%; height: 450px;">
                        <table id="image_table" class="image_table_faded">
                        </table>
                    </div>
                </div>
                <div>
                    <div style="float: left; width: 50%;">
                        <heading><?= $item->title ?></heading><br/>
                        <?= $item->description ?>
                    </div>
                    <div style="float: left; width: 50%;">
                        <table style="width: 100%; hieght: 100%;">
                            <?php
                            $previous_group = "";
                            if (count($item->characteristics) > 0)
                            {
                                foreach ($item->characteristics as $characteristic)
                                {
                                    if ($previous_group != $characteristic[3])
                                    {
                                        if ($characteristic[2] == "option")
                                        {
                                            ?>
                                            <tr>
                                                <td colspan="2">
                                                    <hr/>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                            <heading><?= $characteristic[3] ?></heading>
                                            </td>
                                            <td>
                                                <?= $characteristic[0] ?>
                                            </td>
                                            </tr>
                                            <?php
                                        }
                                        else if ($characteristic[2] != "option")
                                        {
                                            ?>
                                            <tr>
                                                <td colspan="2">
                                                    <hr/>
                                            <heading><?= $characteristic[3] ?></heading>
                                            </td>
                                            </tr>
                                            <?php
                                        }
                                    }
                                    if ($characteristic[2] != "option")
                                    {
                                        ?>
                                        <tr>
                                            <td>
                                                <?= $characteristic[0] ?>
                                            </td>
                                            <td>
                                                <?= $characteristic[1] ?>
                                            </td>
                                        </tr>    
                                        <?php
                                    }
                                    $previous_group = $characteristic[3];
                                }
                            }
                            ?>
                        </table>
                    </div>
                    <?php
                    if ($item->video != "")
                    {
                        ?>
                        <div style="float: left;">
                            <iframe style="padding-top: 25px;" width="1024px" height="450px" src="<?= $item->video ?>" frameborder="0" allowfullscreen></iframe>
                        </div>
                        <?php
                    }
                    ?>
                </div>
                <div id="map" style="float: left; width: 100%; height: 450px; border: 1px solid black; margin-bottom: 25px; margin-top: 25px;">

                </div>
                <div id="hidden_info" style="display: none">
                    <?= $item->location ?>
                </div>
            </div>
            <?php include "./page_blocks/footer.php"; ?>
        </div>
    </body>
</html>