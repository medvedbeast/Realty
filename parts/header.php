<script>
    (function (i, s, o, g, r, a, m) {
        i['GoogleAnalyticsObject'] = r;
        i[r] = i[r] || function () {
            (i[r].q = i[r].q || []).push(arguments)
        }, i[r].l = 1 * new Date();
        a = s.createElement(o),
                m = s.getElementsByTagName(o)[0];
        a.async = 1;
        a.src = g;
        m.parentNode.insertBefore(a, m)
    })(window, document, 'script', 'https://www.google-analytics.com/analytics.js', 'ga');

    ga('create', 'UA-88655970-1', 'auto');
    ga('send', 'pageview');

</script>
<div id="menu" class="menu container shadowed">
    <div class="menu">
        <a href="index.php">
            <img src="images/logo.png"/>
            <div class="menu item">
                TOP-REAL.COM.UA
            </div>
        </a>
        <a href="<?= isset($_COOKIE["user_id"]) ? "profile.php" : "login.php"; ?>">
            <img class="right" src="images/login.png"/>
            <div class="menu item right last">
                <?php
                if (isset($_COOKIE["user_id"]))
                {
                    echo "ЛИЧНЫЙ КАБИНЕТ";
                }
                else
                {
                    echo "ВОЙТИ";
                }
                ?>
            </div>
        </a>
        <a href="contacts.php">
            <div class="menu item right">
                КОНТАКТЫ
            </div>
        </a>
        <a href="law.php">
            <div class="menu item right">
                ЗАКОНОДАТЕЛЬСТВО
            </div>
        </a>
        <div class="clear"></div>
    </div>
</div>