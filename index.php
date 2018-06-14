<!DOCTYPE html>
<?php
include "core/database.php";
?>
<html>
    <head>
        <title>TOP-REAL</title>
        <meta charset="utf-8" />
        <link href="styles/index.css" type="text/css" rel="stylesheet" />
        <link href="styles/common.css" type="text/css" rel="stylesheet" />
        <script src="scripts/index.js" type="text/javascript"></script>
        <script src="scripts/jquery.min.js" type="text/javascript"></script>
        <link rel="shortcut icon" href="images/favicon.ico" />
    </head>
    <body onload="OnBodyLoaded()">
        <div class="page">
            <?php
            include './parts/header.php';
            ?>
            <div class="selector shadowed">
                <div class="header">
                    ВЫБЕРИТЕ ДЕЙСТВИЕ
                </div>
                <div class="content">
                    <a href="search.php?action=1">
                        <div class="block">
                            ПРОДАЖА
                        </div>
                    </a>
                    <a href="search.php?action=35">
                        <div class="block">
                            АРЕНДА
                        </div>
                    </a>
                    <a href="search.php?action=103">
                        <div class="block">
                            ПОКУПКА
                        </div>
                    </a>
                    <a href="search.php?action=137">
                        <div class="block">
                            СДАЧА В АРЕНДУ
                        </div>
                    </a>
                    <div class="clear"></div>
                </div>
            </div>
            <div class="search shadowed">
                <div class="header">
                    ПОИСК СРЕДИ НОВОСТЕЙ И СТАТЕЙ
                </div>
                <div class="content">
                    <div class="label">
                        ПОИСК:
                    </div>
                    <div id="queryContainer" class="input container">
                        <input id="query" type="text" onchange="OnQueryChanged()"/>
                    </div>
                    <div id="searchContainer" class="input container">
                        <input id="search" type="button" value="ПОИСК" onclick="OnSearchClicked()"/>
                    </div>
                    <div class="clear"></div>
                    <div class="label margined">
                        СТРАНИЦА <b id="currentPage">0</b> ИЗ <b id="totalPages">0</b>
                    </div>
                    <div id="previousPageContainer" class="input container">
                        <input id="previousPage" type="button" value="<<" onclick="OnPreviousPageClicked()"/>
                    </div>
                    <div id="pageContainer" class="input container">
                        <input id="page" type="number" pattern="^[0-9]+$" onblur="OnPageNumberEntered(this, event)" onkeyup="OnPageNumberEntered(this, event)"/>
                    </div>
                    <div id="nextPageContainer" class="input container">
                        <input id="nextPage" type="button" value=">>" onclick="OnNextPageClicked()"/>
                    </div>
                    <div class="clear"></div>
                </div>
            </div>
            <div id="searchResults" class="search results">
            </div>
            <div class="search shadowed">
                <div class="header">
                    ПОИСК СРЕДИ НОВОСТЕЙ И СТАТЕЙ
                </div>
                <div class="content">
                    <div class="label">
                        СТРАНИЦА <b id="currentPage_2">0</b> ИЗ <b id="totalPages_2">0</b>
                    </div>
                    <div id="previousPageContainer" class="input container">
                        <input type="button" value="<<" onclick="OnPreviousPageClicked()"/>
                    </div>
                    <div id="pageContainer" class="input container">
                        <input type="number" pattern="^[0-9]+$" onblur="OnPageNumberEntered(this, event)" onkeyup="OnPageNumberEntered(this, event)"/>
                    </div>
                    <div id="nextPageContainer" class="input container">
                        <input type="button" value=">>" onclick="OnNextPageClicked()"/>
                    </div>
                    <div class="clear"></div>
                </div>
            </div>
        </div>
        <?php
        include './parts/footer.php';
        ?>
    </body>
</html>