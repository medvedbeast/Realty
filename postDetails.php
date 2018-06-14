<!DOCTYPE html>
<?php
include_once './core/database.php';
$data = Database::GetPost($_REQUEST["id"]);
?>
<html>
    <head>
        <title>TOP-REAL</title>
        <meta name="description" content="<?= $data->title ?>" />
        <meta property="og:title" content="<?= $data->title ?>"/>
        <meta property="og:description" content="<?= $data->title ?>"/>
        <meta property="og:image" content="http://top-real.com.ua/images/posts/<?= $data->image ?>"/>
        <meta property="og:url" content="http://top-real.com.ua/postDetails.php?id=<?= $_REQUEST["id"] ?>" />
        <meta property="og:type" content="article" />
        <meta charset="utf-8" />
        <link href="styles/postDetails.css" type="text/css" rel="stylesheet" />
        <link href="styles/common.css" type="text/css" rel="stylesheet" />
        <script src="scripts/postDetails.js" type="text/javascript"></script>
        <script src="scripts/jquery.min.js" type="text/javascript"></script>
        <link rel="shortcut icon" href="images/favicon.ico" />
    </head>
    <body>
        <div class="page">
            <?php
            include './parts/header.php';
            ?>
            <div id="postContainer" class="post container">
                <?php
                $user = Database::GetUser($data->authorId, 0);
                $user = $user[0];
                ?>
                <div class="header">
                    <?= mb_strtoupper($data->title, "utf-8"); ?>
                </div>
                <div class="content">
                    <?php
                    if ($data->image != "") {
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
                            <a href=""><?= "$user->firstName  $user->lastName" ?></a>,
                            <?php
                            $date = split(" ", $data->date);
                            echo date_format(new DateTime($date[0]), "d.m.Y");
                            ?>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <?php
        include './parts/footer.php';
        ?>
    </body>
</html>