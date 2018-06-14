<html>
    <head>
        <title> TOP-REAL </title>
        <meta charset="utf-8" />
        <link rel="stylesheet" href="styles/index.css" />
        <script type="text/javascript" src="scripts/index.js"></script>
        <script type="text/javascript" src="scripts/jquery.min.js"></script>
    </head>
    <body onload="OnPageLoaded()">
        <div class="page">
            <?php include "./page_blocks/header.php"; ?>
            <div class="body">
                <div style="padding: 25px; width: 500px; margin: auto;">
                    <div style="padding-bottom: 25px;">
                        СВЯЖИТЕСЬ С НАМИ:
                    </div>
                    <div style="padding-bottom: 10px;">
                        <div style="float: left; width: 25%;">ВАШЕ ИМЯ</div>
                        <input style="float: right; width: 75%;" id="name" type="text" />
                        <div style="clear: both;"></div>
                    </div>
                    <div style="padding-bottom: 10px;">
                        <label style="float: left; width: 25%;">ВАШ E-MAIL</label>
                        <input style="float: right; width: 75%;" id="mail" type="text" />
                        <div style="clear: both;"></div>
                    </div>
                    <div style="padding-bottom: 10px;">
                        <label style="float: left; width: 25%;">ВАШ ТЕЛЕФОН</label>
                        <input style="float: right; width: 75%;" id="telephone" type="text" />
                        <div style="clear: both;"></div>
                    </div>
                    <div style="padding-bottom: 25px;">
                        <label style="float: left; width: 25%;">ВАШ ВОПРОС</label>
                        <textarea style="float: right; width: 75%; height: 200px;" id="question" type="text"></textarea>
                        <div style="clear: both;"></div>
                    </div>
                    <div>
                        <input type="button" value="ОТПРАВИТЬ" onclick="SendMail()"/>
                    </div>
                </div>
            </div>
            <?php include "./page_blocks/footer.php"; ?>
        </div>
    </body>
</html>
