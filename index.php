<html>
    <head>
        <title> TOP-REAL </title>
        <meta charset="utf-8" />
        <meta property="og:image" content="http://top-real.com.ua" />
        <meta property="og:title" content="TOP-REAL" />
        <meta property="og:description" content="Лучшие предложения для Вас!" />
        <link rel="stylesheet" href="styles/index.css" />
        <script type="text/javascript" src="scripts/jquery.min.js"></script>
        <script type="text/javascript" src="https://www.google.com/jsapi"></script>
        <script type="text/javascript" src="scripts/index.js"></script>
    </head>
    <body onload="OnPageLoaded()">
        <div class="page">
            <?php include "./page_blocks/header.php"; ?>
            <div class="body">
                <div class="imaged selector">
                    <div id="buy" class="column center visible half-wide" onclick="OnColumnClick(this, 1)">
                    ПРОДАЖА
                    </div>
                    <div id="rent" class="column center visible half-wide" onclick="OnColumnClick(this, 2)">
                        АРЕНДА
                    </div>
                    <div class="wrapper wide wrapped">
                        <div id="hidden_column_1" class="hidden center third-wide" onclick="OnTypeClick(1)">
                            КОММЕРЧЕСКАЯ НЕДВИЖИМОСТЬ
                        </div>
                        <div id="hidden_column_2" class="hidden center third-wide" onclick="OnTypeClick(2)">
                            ЖИЛАЯ НЕДВИЖИМОСТЬ
                        </div>
                        <div id="hidden_column_3" class="hidden center third-wide" onclick="OnTypeClick(3)">
                            ЗЕМЛЯ
                        </div>
                    </div>
                </div>
                <div id="news_container" class="news_container center wide">
                    Кажется, новостей еще нету!
                </div>
            </div>
            <?php include "./page_blocks/footer.php"; ?>
        </div>
    </body>
</html>