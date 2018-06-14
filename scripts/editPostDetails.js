function OnBodyLoaded(id)
{
    GetPost(id);
}

function GetPost(id)
{
    var request = $.ajax(
            {
                type: "POST",
                url: "core/functions.php",
                data: {function: "GetEditablePost", id: id},
                success: function (data)
                {
                    $("#outputPostContent").html(data);
                }
            });
}

function GetPostImage()
{
    var request = $.ajax(
            {
                type: "POST",
                url: "core/functions.php",
                data: {function: "GetEditablePostImage", id: $("body").attr("post_id")},
                success: function (data)
                {
                    $("#postImageLarge").html(data);
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
                data: {function: "RemovePostImage", id: $("body").attr("post_id")},
                success: function ()
                {
                    GetPostImage();
                }
            });
}

function RefreshInput()
{
    $("#postImage").replaceWith($("#postImage").clone());
    $("#postImageName").html("...ВЫБРАТЬ ИЗОБРАЖЕНИЕ...");
    $("#postImageDiv").removeClass("success");
    $("#postImageDiv").removeClass("error");
}

function OnAddPostImageClicked()
{
    $("#postImage").one("change", {}, function ()
    {
        $("#postImageName").html("...ИДЁТ ЗАГРУЗКА ФАЙЛА...");
        $("#postImageForm").submit();
    });
    $("#postImage").click();

}

function OnUpdatePostClicked()
{
    var title = $("#postTitle").val();
    var content = $("#postContent").val();
    if (title == "" || content == "")
    {
        alert("Заполните все поля!");
        return;
    }
    if ($("#postImage").prop("files").length > 0)
    {
        alert("Дождитесь окончания загрузки изображения!");
        return;
    }
    var request = $.ajax(
            {
                type: "POST",
                url: "core/functions.php",
                data: {function: "UpdatePost", id: $("body").attr("post_id"), title: title, content: content},
                success: function (data)
                {
                    alert("Пост успешно обновлен!");
                }
            });
}

function OnPostImageLoaded(errorCode, filename)
{
    if (errorCode == 0 && filename.length > 0)
    {
        $("#postImageDiv").addClass("success");
        var postImage = filename;
        var request = $.ajax(
                {
                    type: "POST",
                    url: "core/functions.php",
                    data: {function: "LinkPostImage", id: $("body").attr("post_id"), image: postImage},
                    success: function ()
                    {
                        RefreshInput();
                        GetPostImage();
                    }
                });
    }
    else
    {
        $("#postImageDiv").addClass("error");
    }
}