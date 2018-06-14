<!DOCTYPE html>
<html>
    <head>
        <title>TOP-REAL</title>
        <meta charset="utf-8" />
        <link href="styles/search.css" type="text/css" rel="stylesheet" />
        <link href="styles/common.css" type="text/css" rel="stylesheet" />
        <script src="scripts/search.js" type="text/javascript"></script>
        <script src="scripts/jquery.min.js" type="text/javascript"></script>
        <link rel="shortcut icon" href="images/favicon.ico" />
    </head>
    <body onload="OnBodyLoaded();" selectedId="<?= $_REQUEST["action"] ?>">
        <div class="page">
            <?php
            include "./parts/header.php";
            ?>
            <div class="filter container shadowed">
                <div class="header">
                    ВЫБЕРИТЕ ПАРАМЕТРЫ ДЛЯ ПОИСКА
                </div>
                <div class="content">
                    <div class="label">
                        КЛЮЧЕВЫЕ СЛОВА:
                    </div>
                    <div id="queryContainer" class="input container floated">
                        <input id="query" type="text" placeholder="введите населенный пункт, любое слово из предложения, и т.д." />
                    </div>
                    <div id="searchContainer" class="input container floated">
                        <input id="search" type="button" value="ПОИСК" onclick="OnSearchClicked()"/>
                    </div>
                    <div class="clear"></div>
                    <div id="filter">
                        <div id="categories"></div>
                        <div id="characteristics" class=""></div>
                    </div>
                    <div class="clear"></div>
                    <div class="label margined">
                        СТРАНИЦА <b id="currentPage">0</b> ИЗ <b id="totalPages">0</b> <div id="pageText"></div>
                    </div>
                    <div id="previousPageContainer" class="input container  floated">
                        <input id="previousPage" type="button" value="<<" onclick="OnPreviousPageClicked()"/>
                    </div>
                    <div id="pageContainer" class="input container  floated">
                        <input id="page" type="number" pattern="^[0-9]+$" onblur="OnPageNumberEntered(event)" onkeyup="OnPageNumberEntered(event)"/>
                    </div>
                    <div id="nextPageContainer" class="input container  floated">
                        <input id="nextPage" type="button" value=">>" onclick="OnNextPageClicked()"/>
                    </div>
                    <div id="showCharacteristics" class="input container floated">
                        <input id="show" type="button" value="РАСШИРЕННЫЙ ПОИСК" onclick="ShowCharacteristicsClicked()"/>
                    </div>
                    <div class="clear"></div>
                </div>
            </div>
            <div class="header container shadowed">
                <div class="header">ЛУЧШИЕ ПРЕДЛОЖЕНИЯ</div>
            </div>
            <div id="paidResults" class="paid container">
            </div>
            <div class="header container shadowed">
                <div class="header">РЕЗУЛЬТАТЫ ПОИСКА</div>
            </div>
            <div id="searchResults" class="results">
            </div>
            <div id="extraPages" class="pages container shadowed">
                <div id="label2">
                    СТРАНИЦА <b id="currentPage2">0</b> ИЗ <b id="totalPages2">0</b>
                </div>
                <div id="previousPageContainer2" class="input container">
                    <input type="button" value="<<" onclick="OnPreviousPageClicked()"/>
                </div>
                <div id="pageContainer2" class="input container">
                    <input id="page2" type="number" pattern="^[0-9]+$" onblur="OnPageNumberEntered(event)" onkeyup="OnPageNumberEntered(event)"/>
                </div>
                <div id="nextPageContainer2" class="input container">
                    <input type="button" value=">>" onclick="OnNextPageClicked()"/>
                </div>
                <div class="clear"></div>
            </div>
        </div>
        <?php
        include "./parts/footer.php";
        ?>
    </body>
</html>
