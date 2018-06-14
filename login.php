<?php
if (isset($_COOKIE["user_id"]))
{
    header("Location: profile.php");
}
?>
<!DOCTYPE html>
<html>
    <head>
        <title>TOP-REAL</title>
        <meta charset="utf-8" />
        <link href="styles/login.css" type="text/css" rel="stylesheet" />
        <link href="styles/common.css" type="text/css" rel="stylesheet" />
        <script src="scripts/login.js" type="text/javascript"></script>
        <script src="scripts/jquery.min.js" type="text/javascript"></script>
        <link rel="shortcut icon" href="images/favicon.ico" />
        <script type="text/javascript">
<?php
if (isset($_REQUEST["confirm"]))
{
    $login = $_REQUEST["confirm"];
    $email = $_REQUEST["email"];
    $name = $_REQUEST["name"];
    $password = $_REQUEST["password"];
    echo "Register('$login', '$email', '$name', '$password');";
}
?>
        </script>
    </head>
    <body>
        <div class="page">
            <?php
            include './parts/header.php';
            ?>
            <div class="login container shadowed">
                <div class="header">ВХОД В УЧЁТНУЮ ЗАПИСЬ</div>
                <div class="content">
                    <div class="input container padded">
                        <div class="label">ЛОГИН:</div>
                        <div class="input wide">
                            <input id="login" type="text" pattern="[a-zA-z0-9.-_]+" required/>
                        </div>
                        <div class="clear"></div>
                    </div>
                    <div class="input container padded hidden">
                        <div class="label">E-MAIL:</div>
                        <div class="input wide">
                            <input id="email" type="text" pattern="[a-zA-z0-9.-_]+@[a-zA-z0-9]+.[a-zA-z0-9]+" required/>
                        </div>
                        <div class="clear"></div>
                    </div>
                    <div class="input container padded hidden">
                        <div class="label">ИМЯ:</div>
                        <div class="input wide">
                            <input id="name" type="text" pattern="[a-zA-zа-яА-Я]+" required/>
                        </div>
                        <div class="clear"></div>
                    </div>                  
                    <div class="input container padded">
                        <div class="label">ПАРОЛЬ:</div>
                        <div class="input wide">
                            <input id="password" type="password" pattern="[a-zA-z0-9.-_]+" required/>
                        </div>
                        <div class="clear"></div>
                    </div>
                    <div class="input container">
                        <div class="input left">
                            <input type="button" value="ВОЙТИ" onclick="Login()"/>
                        </div>
                        <div class="input right">
                            <input type="button" value="ЗАРЕГЕСТРИРОВАТЬСЯ" onclick="ShowFields()"/>
                        </div>
                        <div class="clear"></div>
                    </div>
                    <div id="message">
                    </div>
                </div>
            </div>
        </div>
        <?php
        include './parts/footer.php';
        ?>
    </body>
</html>