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
        <link href="styles/profile.css" type="text/css" rel="stylesheet" />
        <link href="styles/common.css" type="text/css" rel="stylesheet" />
        <script src="scripts/profile.js" type="text/javascript"></script>
        <script src="scripts/jquery.min.js" type="text/javascript"></script>
        <link rel="shortcut icon" href="images/favicon.ico" />
    </head>
    <body onload="OnBodyLoaded(<?= $_COOKIE["user_id"]; ?>)">
        <div class="page">
            <?php
            include './parts/header.php';
            ?>
            <div id="user_info" class="shadowed"></div>
            <div class="profile container shadowed">
                <div class="tab container">
                    <div id="tab_1" class="tab header selected" onclick="OnTabClicked(this)">
                        ДОБАВИТЬ ПРЕДЛОЖЕНИЕ
                    </div>
                    <div id="tab_2" class="tab header" onclick="OnTabClicked(this)">
                        МОИ ПРЕДЛОЖЕНИЯ
                    </div>
                    <div id="tab_3" class="tab header" onclick="OnTabClicked(this)">
                        ДОБАВИТЬ ПОСТ
                    </div>
                    <div id="tab_4" class="tab header" onclick="OnTabClicked(this)">
                        МОИ ПОСТЫ
                    </div>
                    <div id="tab_5" class="tab header" onclick="OnTabClicked(this)">
                        ВЫЙТИ
                    </div>
                    <div class="clear"></div>
                </div>
                <div class="content container">
                    <div id="tab_1_content" class="tab content selected">
                        <div class="characteristic">
                            <div class="title">
                                НАЗВАНИЕ
                            </div>
                            <div class="input">
                                <input id="title" type="text"/>
                            </div>
                            <div class="clear"></div>
                        </div>
                        <div class="characteristic">
                            <div class="title">
                                ОПИСАНИЕ
                            </div>
                            <div class="input">
                                <textarea id="description"></textarea>
                            </div>
                            <div class="clear"></div>
                        </div>
                        <div class="characteristic">
                            <div class="title">
                                РАСПОЛОЖЕНИЕ
                            </div>
                            <div class="input">
                                <input id="location" type="text" />
                            </div>
                            <div class="clear"></div>
                        </div>
                        <div class="characteristic">
                            <div class="title">
                                ССЫЛКА НА ВИДЕО
                            </div>
                            <div class="input">
                                <input id="video" type="text" />
                            </div>
                            <div class="clear"></div>
                        </div>
                        <div id="categories"></div>
                        <div id="characteristics"></div>
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
                        </div>
                        <div class="confirm">
                            <input type="button" value="СОХРАНИТЬ" onclick="OnAddOfferClicked()"/>
                        </div>
                    </div>
                    <div id="tab_2_content" class="tab content"></div>
                    <div id="tab_3_content" class="tab content">
                        <div class="characteristic">
                            <div class="title">
                                НАЗВАНИЕ
                            </div>
                            <div class="input">
                                <input id="postTitle" type="text"/>
                            </div>
                            <div class="clear"></div>
                        </div>
                        <div class="characteristic">
                            <div class="title">
                                ТЕКСТ
                            </div>
                            <div class="input">
                                <textarea id="postContent"></textarea>
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
                                            <div class="button" onclick="OnRemovePostImageClicked()">
                                                УДАЛИТЬ
                                            </div>
                                            <div class="clear"></div>
                                        </div>
                                    </form>
                                    <iframe id="postImageFrame" name="postFrame" src="#" class="hidden"></iframe>
                                </div>
                            </div>
                            <div class="clear"></div>
                        </div>
                        <div class="confirm">
                            <input type="button" value="СОХРАНИТЬ" onclick="OnAddPostClicked()"/>
                        </div>
                    </div>
                    <div id="tab_4_content" class="tab content"></div>
                </div>
            </div>
            <div id="offerContainer">

            </div>
        </div>
        <?php
        include './parts/footer.php';
        ?>
    </body>
</html>