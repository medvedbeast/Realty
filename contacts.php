<!DOCTYPE html>
<html>
    <head>
        <title>TOP-REAL</title>
        <meta charset="utf-8" />
        <link href="styles/contacts.css" type="text/css" rel="stylesheet" />
        <link href="styles/common.css" type="text/css" rel="stylesheet" />
        <script src="scripts/contacts.js" type="text/javascript"></script>
        <script src="scripts/jquery.min.js" type="text/javascript"></script>
        <link rel="shortcut icon" href="images/favicon.ico" />
    </head>
    <body onload="OnBodyLoaded();">
        <div class="page">
            <?php
            include './parts/header.php';
            ?>
            <div class="contacts container shadowed">
                <div class="header">КОНТАКТЫ</div>
            </div>
            <div id="content">

            </div>
        </div>
        <?php
        include './parts/footer.php';
        ?>
    </body>
</html>