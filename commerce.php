<html>
    <head>
        <title> TOP-REAL </title>
        <meta charset="utf-8" />
        <link rel="stylesheet" href="styles/index.css" />
        <link rel="stylesheet" href="styles/commerce.css" />
        <script type="text/javascript" src="scripts/commerce.js"></script>
        <script type="text/javascript" src="scripts/jquery.min.js"></script>
    </head>
    <body onload="OnPageLoaded()">
        <div class="page">
            <?php include "./page_blocks/header.php"; ?>
            <div class="body">
                <div style="width: 100%;">
                    <table style="width: 100%;">
                        <tr style="background-color: lightgray; height: 30px; color: black;">
                            <td colspan="2">
                                ПОИСК ПО КЛЮЧЕВЫМ СЛОВАМ В МЕСТОПОЛОЖЕНИИ, НАЗВАНИИ, ОПИСАНИИ И Т.Д.
                            </td>
                        </tr>
                        <tr>
                            <td style="width: 75%;">
                                <input id="keywords" type="text" style="width: 100%;"/>
                            </td>
                            <td style="width: 75%;">
                                <input type="button" value="ПОИСК ПО КЛЮЧЕВЫМ СЛОВАМ" onclick="OnSearchByKeywordsClick()"/>
                            </td>
                        </tr>
                    </table>
                </div>
                <div style="width: 25%; float: left">
                    <?php include "./modules/offer_filter.php"; ?>
                </div>
                <div id="selection_container" style="width: 75%; float: left; text-align: center;">
                    Ничего не найдено! Попробуйте повторить поиск с другими фильтрами.
                </div>
            </div>
            <?php include "./page_blocks/footer.php"; ?>
        </div>
    </body>
</html>