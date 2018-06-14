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
        <link href="styles/editProfile.css" type="text/css" rel="stylesheet" />
        <link href="styles/common.css" type="text/css" rel="stylesheet" />
        <script src="scripts/editProfile.js" type="text/javascript"></script>
        <script src="scripts/jquery.min.js" type="text/javascript"></script>
        <link rel="shortcut icon" href="images/favicon.ico" />
    </head>
    <body onload="OnBodyLoaded(<?= $_REQUEST["id"]; ?>)" user_id="<?= $_REQUEST["id"]; ?>">
        <div class="page">
            <?php
            include './parts/header.php';
            ?>
            <div class="profile container shadowed">
                <div class="header">
                    ИЗМЕНЕНИЕ ДАННЫХ ПРОФИЛЯ
                </div>
                <div id="outputProfileContent" class="content">
                    
                </div>
            </div>
            <?php
            include './parts/footer.php';
            ?>
    </body>
</html>