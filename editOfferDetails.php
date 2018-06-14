<?php
if (!isset($_COOKIE["user_id"]))
{
    header("Location: login.php");
}
?>
<!DOCTYPE html>
<html>
    <head>
        <title>TOP-REAL</title>
        <meta charset="utf-8" />
        <link href="styles/editOfferDetails.css" type="text/css" rel="stylesheet" />
        <link href="styles/common.css" type="text/css" rel="stylesheet" />
        <script src="scripts/editOfferDetails.js" type="text/javascript"></script>
        <script src="scripts/jquery.min.js" type="text/javascript"></script>
        <link rel="shortcut icon" href="images/favicon.ico" />
    </head>
    <body onload="OnBodyLoaded(<?= $_REQUEST["id"]; ?>)" offer_id="<?= $_REQUEST["id"]; ?>">
        <div class="page">
            <?php
            include './parts/header.php';
            ?>
            <div class="offer container">
                <div class="header">
                    ИЗМЕНЕНИЕ ПРЕДЛОЖЕНИЯ
                </div>
                <div class="content">
                    <div id="characteristic_container" class="characteristic container">
                    </div>    
                </div>
            </div>
            <?php
            include './parts/footer.php';
            ?>
    </body>
</html>