function OnBodyLoaded(id)
{
    GetProfileInfo(id);
}

function GetProfileInfo(id)
{
    var request = $.ajax(
            {
                type: "POST",
                url: "core/functions.php",
                data: {function: "GetProfileInfo", id: id},
                success: function (data)
                {
                    $("#outputProfileContent").html(data);
                }
            });
}

function GetProfileImage()
{
    var request = $.ajax(
            {
                type: "POST",
                url: "core/functions.php",
                data: {function: "GetEditableProfileImage", id: $("body").attr("user_id")},
                success: function (data)
                {
                    $("#profileImageLarge").html(data);
                }
            });
}

function OnRemoveImageClicked()
{
    RefreshInput();
    var request = $.ajax(
            {
                type: "POST",
                url: "core/functions.php",
                data: {function: "RemoveUserImage", id: $("body").attr("user_id")},
                success: function ()
                {
                    GetProfileImage();
                }
            });
}

function RefreshInput()
{
    $("#userImage").replaceWith($("#userImage").clone());
    $("#userImageName").html("...ВЫБРАТЬ ИЗОБРАЖЕНИЕ...");
    $("#userImageDiv").removeClass("success");
    $("#userImageDiv").removeClass("error");
}

function OnAddUserImageClicked()
{
    $("#userImage").one("change", {}, function ()
    {
        $("#userImageName").html("...ИДЁТ ЗАГРУЗКА ИЗОБРАЖЕНИЯ...");
        $("#userImageForm").submit();
    });
    $("#userImage").click();
}

function OnUpdateUserClicked()
{
    var nickname = $("#nickname").val();
    var password = $("#password").val();
    var firstname = $("#firstname").val();
    var lastname = $("#lastname").val();
    var email = $("#email").val();
    var telephone = $("#telephone").val();
    var site = $("#site").val();
    var position = $("#position").val();
    var experience = $("#experience").val();
    var country = $("#country").val();
    var dateOfBirth = $("#date_of_birth").val() + " 00:00:00";
    var about = $("#about").val();
    if ($("input:invalid").length > 0)
    {
        alert("Проверьте правильность введенных данных!");
        return;
    }
    if ($("#userImage").prop("files").length > 0)
    {
        alert("Дождитесь окончания загрузки изображения!");
        return;
    }
    var request = $.ajax(
            {
                type: "POST",
                url: "core/functions.php",
                data: {function: "UpdateUser", id: $("body").attr("user_id"), nickname: nickname, password: password, firstname: firstname, lastname: lastname, email: email, telephone: telephone, site: site, position: position, experience: experience, country: country, dateOfBirth: dateOfBirth, about: about},
                success: function (data)
                {
                    alert("Профиль успешно обновлен!");
                }
            });
}

function OnUserImageLoaded(errorCode, filename)
{
    if (errorCode == 0 && filename.length > 0)
    {
        $("#userImageDiv").addClass("success");
        var request = $.ajax(
                {
                    type: "POST",
                    url: "core/functions.php",
                    data: {function: "LinkUserImage", id: $("body").attr("user_id"), image: filename},
                    success: function ()
                    {
                        RefreshInput();
                        GetProfileImage();
                    }
                });
    }
    else
    {
        $("#userImageDiv").addClass("error");
    }
}