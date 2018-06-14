<?php

include "./classes/database.php";
$post = Database::GetPost($_GET["id"]);

?>
<html>
    <head>
        <title> TOP-REAL </title>
        <meta charset="utf-8" />
        <meta property="og:image" content="http://top-real.com.ua/<?= substr($post->preview, 3); ?>" />
        <meta property="og:title" content="<?= $post->title; ?>" />
        <meta property="og:description" content="<?= $post->content; ?>" />
        <link rel="stylesheet" href="styles/index.css" />
        <script type="text/javascript" src="scripts/index.js"></script>
        <script type="text/javascript" src="scripts/jquery.min.js"></script>
    </head>
    <body onload="OnPageLoaded()">
        <div class="page">
            <?php include "./page_blocks/header.php"; ?>
            <div class="body">
                <div class="post_container">
                    <div class="post_title padded">
                        <heading><?=$post->title?></heading>
                    </div>
                    <div class="post_content">
                        <?=nl2br($post->content)?>
                    </div>
                    <div class="post_subscription">
                        <heading><?=$post->author_firstname . " " . $post->author_lastname . ", " , $post->date?></heading>
                    </div>
                </div>
            </div>
            <?php include "./page_blocks/footer.php"; ?>
        </div>
    </body>
</html>