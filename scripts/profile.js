var postImage = "";
var files = [];
/* #region FILE */
var Markup = function (p)
{
    this.wrap;
    this.form;
    this.frame;
    this.input;
    this.div;
    this.loadButton;
    this.unloadButton;
    this.parent = p;
}
var File = function (i)
{
    this.markup = new Markup(this);
    this.name;
    this.nameOnServer;
    this.size;
    this.index = i;
}
Markup.prototype.Create = function (index)
{
    this.wrap = $("#source").clone();
    this.wrap.prop("id", "inputWrap_" + index);
    this.wrap.removeClass("hidden");
    $("#fileInputContainer").append($(this.wrap));
    this.form = $(this.wrap).children("form");
    this.form.prop("id", "inputForm_" + index);
    this.form.attr("action", "../core/functions.php?function=UploadImage&path=offers&index=" + index);
    this.form.attr("target", "inputFrame_" + index);
    this.form.after("<iframe class='hidden' name='inputFrame_" + index + "'></iframe>");
    this.frame = $("iframe[name='inputFrame_" + index + "']");
    this.input = $(this.form).children("input");
    this.input.prop("id", "input_" + index);
    this.div = $(this.form).children("div.file");
    if (files.length > 1)
    {
        this.div.addClass("closing");
        $(files[this.parent.index - 1].markup.div).removeClass("closing");
    }
    else
    {
        this.div.addClass("closing");
    }
    this.loadButton = $(this.div).children("div.description");
    this.loadButton.on("click", {index: index}, OnLoadClicked);
    this.unloadButton = $(this.div).children("div.button");
    this.unloadButton.on("click", {index: index}, OnRemoveClicked);
}
Markup.prototype.Assign = function (index)
{
    this.wrap.prop("id", "inputWrap_" + index);
    this.form.prop("id", "inputForm_" + index);
    this.form.attr("action", "../core/functions.php?function=UploadImage&path=offers&index=" + index);
    this.form.attr("target", "inputFrame_" + index);
    this.frame.remove();
    this.form.after("<iframe class='hidden' name='inputFrame_" + index + "'></iframe>");
    this.frame = $("iframe[name='inputFrame_" + index + "']");
    this.input.prop("id", "input_" + index);
    this.loadButton.unbind("click");
    this.loadButton.on("click", {index: index}, OnLoadClicked);
    this.unloadButton.unbind("click");
    this.unloadButton.on("click", {index: index}, OnRemoveClicked);
}
Markup.prototype.Remove = function ()
{
    $(this.wrap).remove();
}
File.prototype.Remove = function ()
{
    if (typeof this.nameOnServer != "undefined" && typeof this.nameOnServer != "null" && this.nameOnServer != "")
    {
        var request = $.ajax(
                {
                    type: "POST",
                    url: "core/functions.php",
                    data: {function: "UnloadImages", path: "offers", files: [this.nameOnServer]}
                });
    }
    this.markup.Remove();
}
File.prototype.Assign = function (index)
{
    this.index = index;
    this.markup.Assign(index);
}
File.prototype.OnLoaded = function (returnCode, filename)
{
    if (returnCode == 0)
    {
        $(this.markup.div).addClass("success");
        this.nameOnServer = filename;
    }
    else
    {
        $(this.markup.div).addClass("error");
    }
    this.markup.loadButton.html(this.name);
}
/* #endregion FILE */
function OnBodyLoaded(id)
{
    GetUserCard(id);
    GetCategory(0);
}

function GetUserCard(id)
{
    var request = $.ajax(
            {
                type: "POST",
                url: "core/functions.php",
                data: {function: "GetUserCard", id: id, access: 0, full: true},
                success: function (data)
                {
                    $("#user_info").html(data);
                }
            });
}

function GetCategory(parentId)
{
    var request = $.ajax(
            {
                type: "POST",
                url: "core/functions.php",
                data: {function: "GetCategory", id: 0, parentId: parentId},
                success: function (data)
                {
                    $("#categories").append(data);
                }
            });
}

function GetCharacteristic(categoryId)
{
    var request = $.ajax(
            {
                type: "POST",
                url: "core/functions.php",
                data: {function: "GetCharacteristic", id: 0, categoryId: categoryId},
                success: function (data)
                {
                    $("#characteristics").html(data);
                    $("#show").addClass("visible");
                }
            });
}

function OnCategoryChanged(sender)
{
    if ($(sender).val() == -1)
    {
        return;
    }
    var precision = $(sender).attr("precision");
    var rootId = $(sender).attr("root_category_id");
    $("div [root_category_id]").each(function ()
    {
        if ($(this).attr("root_category_id") > rootId)
        {
            $(this).remove();
        }
    });
    $("#characteristics").empty();
    if ($(sender).attr("precision") == 1)
    {
        GetCategory($(sender).val(), null);
    }
    else
    {
        GetCharacteristic($(sender).val());
    }
}

function OnTabClicked(sender)
{
    var id = $(sender).prop("id");
    var number = parseInt(id.split("_")[1]);
    $("#offerContainer").empty();
    switch (number)
    {
        case 2:
        {
            GetOffers();
            break;
        }
        case 4:
        {
            GetPosts();
            break;
        }
        case 5:
        {
            document.cookie = "user_id=; expires=Thu, 01 Jan 1970 00:00:01 GMT;";
            document.location.href = "login.php";
            break;
        }
    }
    $(".tab.header").each(function ()
    {
        if ($(this).prop("id") == id)
        {
            $(this).addClass("selected");
        }
        else
        {
            $(this).removeClass("selected");
        }
    });
    $(".tab.content").each(function ()
    {
        if ($(this).prop("id") == id + "_content")
        {
            $(this).addClass("selected");
        }
        else
        {
            $(this).removeClass("selected");
        }
    });
}

function OnAddOfferClicked()
{   
    if ($("input:invalid").length > 0)
    {
        alert("Проверьте правильность введённых данных!");
        return;
    }
    if ($("[precision=2]").length < 1 || $("[precision=2]")[0].value === null || typeof $("[precision=2]")[0].value == "undefined" || $("[precision=2]")[0].value == -1)
    {
        alert("Выберите категории предложения!");
        return;
    }
    for (var i = 0; i < files.length; i++)
    {
        var file = files[i];
        if ((typeof file.nameOnServer == "undefined" || typeof file.nameOnServer == "null" || file.nameOnServer == "") && file.name.length > 0)
        {
            alert("Дождитесь окончания загрузки изображений!");
            return;
        }
    }
    var title = $("#title").val();
    var description = $("#description").val();
    var location = $("#location").val();
    var video = $("#video").val();
    video = video.substring(video.indexOf("v=") + 2, video.length);
    var category = $("[precision=2]")[0].value;
    var owner = $($("[user_id]")[0]).attr("user_id");
    var characteristics = [];
    var index = 0;
    var input = $("[characteristic_id]");
    for (var i = 0; i < input.length; i++)
    {
        var element = $(input[i]);
        var tag = element.prop("tagName").toString();
        if (element.val().toString() != "-1" && element.val().toString() != "" && element.val().toString() != " ")
        {
            switch (tag.toLowerCase())
            {
                case "select":
                {
                    characteristics[index] = {characteristicId: element.val(), value: true};
                    index++;
                    break;
                }
                case "input":
                {
                    characteristics[index] = {characteristicId: element.attr("characteristic_id"), value: element.val()};
                    index++;
                    break;
                }
            }
        }
    }
    var request = $.ajax(
            {
                type: "POST",
                url: "core/functions.php",
                data: {function: "AddOffer", title: title, description: description, location: location, video: video, category: category, owner: owner, characteristics: characteristics},
                success: function (data)
                {
                    if (parseInt(data) > 0 && files.length > 0)
                    {
                        var filenameList = [];
                        for (var i = 0; i < files.length; i++)
                        {
                            filenameList[i] = files[i].nameOnServer;
                        }
                        var request = $.ajax(
                                {
                                    type: "POST",
                                    url: "core/functions.php",
                                    data: {function: "LinkOfferImages", files: filenameList, offerId: data},
                                    success: function (data)
                                    {
                                        alert("Обьявление успешно добавлено!");
                                        Empty();
                                    }
                                });
                    }
                    else
                    {
                        alert("Обьявление успешно добавлено!");
                        Empty();
                    }
                }
            });
}

function OnAddFileClicked()
{
    if (files.length < 9)
    {
        var i = files.length;
        files[i] = new File(i);
        files[i].markup.Create(i);
    }
    else
    {
        alert("Вы не можете загрузить больше 9 файлов!");
    }
}

function OnLoadClicked(event)
{
    var file = files[event.data.index];
    if (typeof file.name != "undefined" && typeof file.nameOnServer != "undefined")
    {
        var request = $.ajax(
                {
                    type: "POST",
                    url: "core/functions.php",
                    data: {function: "UnloadImages", path: "offers", files: [file.nameOnServer]}
                });
    }
    $(file.markup.input).on("change", {}, function ()
    {
        $(file.markup.div).removeClass("success");
        $(file.markup.div).removeClass("error");
        if ($(file.markup.input).prop("files").length < 1)
        {
            return;
        }
        file.name = $(file.markup.input).prop("files")[0].name;
        file.size = $(file.markup.input).prop("files")[0].size;
        if (file.size / 1000000 >= 8)
        {
            alert("Выбранный файл слишком большой! Пожалуйста, выберите файл размером до 8 мегабайт!");
            $(file.markup.div).addClass("error");
            return;
        }
        $(file.markup.loadButton).html("...ИДЁТ ЗАГРУЗКА ФАЙЛА...");
        $(file.markup.form).submit();
    });
    $(file.markup.input).click();
}

function OnRemoveClicked(event)
{
    files[event.data.index].Remove();
    files[event.data.index] = null;
    var newFiles = [];
    for (var j = 0, k = 0; j < files.length; j++)
    {
        if (j != event.data.index)
        {
            if (j > event.data.index)
            {
                files[j].Assign(k);
            }
            newFiles[k] = files[j];
            k++;
        }
    }
    files = newFiles;
    if (files.length >= 1)
    {
        $("#fileInputContainer div form .file.closing").removeClass("closing");
        $("#inputWrap_" + (files.length - 1) + " div").addClass("closing");
    }
}

function Empty()
{
    $("input[type='text']").each(function ()
    {
        $(this).val("");
    });
    $("textarea").each(function ()
    {
        $(this).val("");
    });
    for (var i = 0; i < files.length; i++)
    {
        files[i].markup.Remove();
    }
}

function GetOffers()
{
    var owner = $($("[user_id]")[0]).attr("user_id");
    var request = $.ajax(
            {
                type: "POST",
                url: "core/functions.php",
                data: {function: "GetOfferPreviews", categoryId: 0, characteristics: [], keywords: [], start: 0, quantity: 0, ownerId: owner},
                success: function (data)
                {
                    if (parseInt(data) == 0)
                    {
                        $("#offerContainer").html("Вы не добавили ни одного предложения!");
                    }
                    else
                    {
                        $("#offerContainer").html(data);
                    }
                }
            });
}

function GetPosts()
{
    var owner = $($("[user_id]")[0]).attr("user_id");
    var request = $.ajax(
            {
                type: "POST",
                url: "core/functions.php",
                data: {function: "GetPostPreviews", start: 0, quantity: 0, keywords: [], ownerId: owner, editable: true},
                success: function (data)
                {
                    if (parseInt(data) == 0)
                    {
                        $("#offerContainer").html("Вы не добавили ни одного поста!");
                    }
                    else
                    {
                        $("#offerContainer").html(data);
                    }
                }
            });
}

function RemoveOffer(id)
{
    var request = $.ajax(
            {
                type: "POST",
                url: "core/functions.php",
                data: {function: "RemoveOffer", offerId: id},
                success: function (data)
                {
                    OnTabClicked($("#tab_2"));
                }
            });
}

function EditOffer(id)
{
    document.location.href = "editOfferDetails.php?id=" + id;
}

function RemovePost(id)
{
    var request = $.ajax(
            {
                type: "POST",
                url: "core/functions.php",
                data: {function: "RemovePost", id: id},
                success: function (data)
                {
                    OnTabClicked($("#tab_4"));
                }
            });
}

function EditPost(id)
{
    document.location.href = "editPostDetails.php?id=" + id;
}

function OnRemovePostImageClicked()
{
    if (postImage != "" && $("#postImage").prop("files").length > 0)
    {
        $("#postImage").replaceWith($("#postImage").clone());
        $("#postImageName").html("...ВЫБРАТЬ ИЗОБРАЖЕНИЕ...");
        var request = $.ajax(
                {
                    type: "POST",
                    url: "core/functions.php",
                    data: {function: "UnloadImages", path: "posts", files: [postImage]}
                });
        $("#postImageDiv").removeClass("success");
        $("#postImageDiv").removeClass("error");
    }
    else
    {
        alert("Для начала выберите файл!");
    }
}

function OnAddPostImageClicked()
{
    $("#postImage").one("change", {}, function ()
    {
        $("#postImageName").html("...ИДЁТ ЗАГРУЗКА ИЗОБРАЖЕНИЯ...");
        $("#postImageForm").submit();
    });
    $("#postImage").click();

}

function OnAddPostClicked()
{
    var title = $("#postTitle").val();
    var content = $("#postContent").val();
    var authorId = $($("[user_id]")[0]).attr("user_id");
    if (title == "" || content == "")
    {
        alert("Заполните все поля!");
        return;
    }
    if ($("#postImage").prop("files").length > 0 && postImage == "")
    {
        alert("Дождитесь окончания загрузки изображения!");
        return;
    }
    var request = $.ajax(
            {
                type: "POST",
                url: "core/functions.php",
                data: {function: "AddPost", title: title, content: content, authorId: authorId, image: postImage},
                success: function (data)
                {
                    alert("Пост успешно добавлен!");
                    $("#postTitle").val("");
                    $("#postContent").val("");
                    $("#postImage").replaceWith($("#postImage").clone());
                    $("#postImageName").html("...ВЫБРАТЬ ИЗОБРАЖЕНИЕ...");
                    $("#postImageDiv").removeClass("success");
                    $("#postImageDiv").removeClass("error");
                }
            });
}

function OnPostImageLoaded(errorCode, filename)
{
    if (errorCode == 0 && filename.length > 0)
    {
        $("#postImageDiv").addClass("success");
        postImage = filename;
    }
    else
    {
        $("#postImageDiv").addClass("error");
    }
    $("#postImageName").html(filename);
}