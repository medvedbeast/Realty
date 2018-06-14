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
                    data: {function: "UnloadImages", path: "offers", files: [this.nameOnServer]},
                    success: function ()
                    {
                        GetEditableOfferImages();
                    }
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
        var request = $.ajax(
                {
                    type: "POST",
                    url: "core/functions.php",
                    data: {function: "LinkOfferImages", files: [this.nameOnServer], offerId: $("body").attr("offer_id")},
                    success: function (data)
                    {
                        GetEditableOfferImages();
                    }
                });
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
    var request = $.ajax(
            {
                type: "POST",
                url: "core/functions.php",
                data: {function: "GetEditableOffer", id: id},
                success: function (data)
                {
                    $("#characteristic_container").html(data);
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

function OnAddFileClicked()
{
    var count = $($("#image_preview_container").children(".image")).length;
    if (files.length + count < 9)
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
        var id = $("div.image[image_path='" + file.nameOnServer + "']");
        id = id[0];
        id = $(id).attr("image_id")
        var request = $.ajax(
                {
                    type: "POST",
                    url: "core/functions.php",
                    data: {function: "RemoveOfferImage", id: id},
                    success: function ()
                    {
                        GetEditableOfferImages();
                    }
                });
    }
    $(file.markup.input).click();
    $(file.markup.input).one("change", {}, function ()
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
}

function OnRemoveClicked(event)
{
    var file = files[event.data.index];
    var id = $("div.image[image_path='" + file.nameOnServer + "']");
    id = id[0];
    id = $(id).attr("image_id")
    var request = $.ajax(
            {
                type: "POST",
                url: "core/functions.php",
                data: {function: "RemoveOfferImage", id: id},
                success: function ()
                {
                    GetEditableOfferImages();
                }
            });

    files[event.data.index].Remove();
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

function GetEditableOfferImages()
{
    var request = $.ajax(
            {
                type: "POST",
                url: "core/functions.php",
                data: {function: "GetEditableOfferImages", offerId: $("body").attr("offer_id")},
                success: function (data)
                {
                    $("#image_preview_container").html(data);
                }
            });
}

function OnRemoveImageClicked(id)
{
    var path = $(".image[image_id='" + id + "']");
    path = $(path).attr("image_path");
    for (var i = 0; i < files.length; i++)
    {
        if (files[i].nameOnServer == path)
        {
            files[i].Remove();
        }
    }
    var request = $.ajax(
            {
                type: "POST",
                url: "core/functions.php",
                data: {function: "RemoveOfferImage", id: id},
                success: function ()
                {
                    GetEditableOfferImages();
                }
            });
}

function OnMakePreviewClicked(id)
{
    var request = $.ajax(
            {
                type: "POST",
                url: "core/functions.php",
                data: {function: "SetOfferPreviewImage", offerId: $("body").attr("offer_id"), imageId: id},
                success: function ()
                {
                    GetEditableOfferImages();
                }
            });
}

function OnUpdateOfferClicked()
{
    if ($("input:invalid").length > 0)
    {
        alert("Проверьте правильность введённых данных!");
        return;
    }
    $("select").each(function ()
    {
        if ($(this).val() == "" && $(this).prop("required") == true)
        {
            alert("Выберите категории предложения!");
            return;
        }
    });
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
                data: {function: "UpdateOffer", title: title, description: description, location: location, video: video, category: category, characteristics: characteristics, offerId: $("body").attr("offer_id")},
                success: function (data)
                {
                    alert("Обьявление успешно обновлено!");
                }
            });
}