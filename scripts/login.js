function Login()
{
    var request = $.ajax(
            {
                type: "POST",
                url: "core/functions.php",
                data: {function: "Login", login: $("#login").val(), password: $("#password").val()},
                success: function (data)
                {
                    if (data.toString().length > 0)
                    {       
                        document.cookie = "user_id=" + encodeURIComponent(data); 
                        document.location.reload();
                    }
                    else
                    {
                        alert("Проверьте правильность введенных данных!");
                    }
                }
            });
}

function Register()
{
    alert("Во время регистрации произошла ошибка! Обратитесь к администратору сервиса: sanches777@ukr.net");
    /*
    var request = $.ajax(
            {
                type: "POST",
                url: "core/functions.php",
                data: {function: "Register", login: $("#login").val(), password: $("#password").val()},
                success: function (data)
                {
                    if (parseInt(data) != -1)
                    {   
                        alert("Вы успешно зарегестрированы!");
                        Login();
                    }
                    else
                    {
                        alert("Пользователь с таким именем уже зарегестрирован!");
                    }
                }
            });
    */
}