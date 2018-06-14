<div class="footer">
    <?php
    if ($_SERVER["REQUEST_URI"] != "/contacts.php" && $_SERVER["REQUEST_URI"] != "/about.php")
    {
        ?>
        <div style="float: left;">
            Сайт разработал и создал:
            <a href="mailto:medvedbeast@live.com">
                <heading>
                    Ростислав Савельев
                </heading>
            </a>
        </div>
        <script type="text/javascript" src="//yastatic.net/share/share.js" charset="utf-8"></script>
        <div style="float: right;">
            <!-- Rating@Mail.ru counter -->
            <script type="text/javascript">
                var _tmr = _tmr || [];
                _tmr.push({id: "2629305", type: "pageView", start: (new Date()).getTime()});
                (function (d, w) {
                    var ts = d.createElement("script");
                    ts.type = "text/javascript";
                    ts.async = true;
                    ts.src = (d.location.protocol == "https:" ? "https:" : "http:") + "//top-fwz1.mail.ru/js/code.js";
                    var f = function () {
                        var s = d.getElementsByTagName("script")[0];
                        s.parentNode.insertBefore(ts, s);
                    };
                    if (w.opera == "[object Opera]") {
                        d.addEventListener("DOMContentLoaded", f, false);
                    } else {
                        f();
                    }
                })(document, window);
            </script><noscript><div style="position:absolute;left:-10000px;">
                <img src="//top-fwz1.mail.ru/counter?id=2629305;js=na" style="border:0;" height="1" width="1" alt="Рейтинг@Mail.ru" />
            </div></noscript>
            <!-- //Rating@Mail.ru counter -->
            <!-- Rating@Mail.ru logo -->
            <a href="http://top.mail.ru/jump?from=2629305">
                <img src="//top-fwz1.mail.ru/counter?id=2629305;t=602;l=1" 
                     style="border:0;" height="40" width="88" alt="Рейтинг@Mail.ru" /></a>
            <!-- //Rating@Mail.ru logo -->
        </div>




        <div style="float: right;" class="yashare-auto-init" data-yashareL10n="ru" data-yashareType="small"
             data-yashareQuickServices="vkontakte,facebook,twitter,odnoklassniki,moimir,gplus"
             data-yashareTheme="counter"></div>
             <?php
         }
         ?>
</div>
