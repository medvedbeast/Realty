<html>
    <head>
        <meta charset="UTF-8" />
        <title>
            showpage::DATABASE
        </title>
        <script src="scripts/jquery.min.js" type="text/javascript"></script>
        <script type="text/javascript">
            function OnLoginClick()
            {
                var login = document.getElementById("login").value;
                var password = document.getElementById("password").value;
                var request = $.ajax(
                    {
                        type: "POST",
                        url: "database_functions.php",
                        data: {function: 21, login: login, password: password},
                        success: function (data)
                        {
                            if (data > 0)
                            {
                                alert("Вы успешно вошли.");
                                document.cookie = "user=" + login;
                                document.location.href = "http://top-real.com.ua/redactor/database_form.php";
                            }else
                            {
                                alert("Проверьте правильность введенных данных!");
                            }
                            
                        }
                    });
            }
        </script>
    </head>
    <body>
        <table style="width: 512px; background-color: lightgray; margin: auto; padding: 25px;">
            <tr style="height: 100px;">
                <td colspan="2">
                    ДЛЯ ПРОДОЛЖЕНИЯ АВТОРИЗУЙТЕСЬ
                </td>
            </tr>
            <tr>
                <td>
                    LOGIN:
                </td>
                <td style="width: 70%;">
                    <input id="login" style="width: 100%;" type="text"/>
                </td>
            </tr>
            <tr>
                <td>
                    PASSWORD:
                </td>
                <td>
                    <input id="password" style="width: 100%;" type="password"/>
                </td>
            </tr>
            <tr style="height: 100px;">
                <td colspan="2">
                    <input type="button" value="ВОЙТИ" onclick="OnLoginClick()"/>
                </td>
            </tr>
        </table>
    </body>
</html>