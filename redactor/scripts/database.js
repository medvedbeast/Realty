var tab_current = 1;
var tab_count = 4;

var upload_ended = false;
var startTime = 0;
var deltaTime = 0;

function OnBodyLoaded()
{
    OnTabChanged(tab_current);
}

function OnTabClicked(tab)
{
    var id = tab.id.substring(tab.id.lastIndexOf("_") + 1, tab.id.length);
    for (var i = 1; i <= tab_count; i++)
    {
        $("#tab_" + i).removeClass("selected");
        $("#page_" + i).removeClass("selected");
    }
    $("#tab_" + id).addClass("selected");
    $("#page_" + id).addClass("selected");
    OnTabChanged(id);
}

function OnTabChanged(id)
{
    switch (parseInt(id))
    {
        case 1:
        {
            var request = $.ajax(
                    {
                        type: "POST",
                        url: "database_functions.php",
                        data: {function: 25, login: $("#user_data").attr("login")},
                        success: function (data)
                        {
                            $("#profile_info").html(data);
                        }
                    });
            break;
        }
        case 3:
        {
            var request = $.ajax(
                    {
                        type: "POST",
                        url: "database_functions.php",
                        data: {function: 26, login: $("#user_data").attr("login")},
                        success: function (data)
                        {
                            $("#offer_output").html(data);
                        }
                    });
            break;
        }
        case 4:
        {
            document.cookie = "user=; expires=Thu, 01 Jan 1970 00:00:01 GMT;";
            document.location.href = "http://top-real.com.ua/redactor/database_form.php";
            break;
        }
    }
}

function OnAddClicked(characteristic_count)
{
    var input_index = 0;
    var requests = [];
    requests[0] = [];
    requests[1] = [];
    var offer_id = -1;
    requests[0][0] = $.ajax(
            {
                type: "POST",
                url: "database_functions.php",
                data: {function: 23},
                success: function (data)
                {
                    offer_id = parseInt(data) + 1;
                    var out = {function: 3, id: offer_id, title: $("#input_0").val(), description: $("#input_1").val(), location: $("#input_2").val(), video: $("#input_3").val(), login: $("#user_data").attr("login")};
                    requests[0][1] = $.ajax(
                            {
                                type: "POST",
                                url: "database_functions.php",
                                data: out
                            });
                    SendCharacteristics(requests, 4, characteristic_count, 0, offer_id);
                    UploadImages(offer_id);
                }
            });
}

function SendCharacteristics(requests, i, max, index, offer_id)
{
    var characteristic_id = -1;
    var characteristic_value = -1;
    if (i != max)
    {
        var characteristic_container = document.getElementById("input_" + i);
        if (characteristic_container.tagName.toLowerCase() == "select")
        {
            characteristic_id = $("#input_" + i + " option:selected").val();
            if (characteristic_id != -1)
            {
                characteristic_value = 1;
            }
        }
        else
        {
            characteristic_id = $("#input_" + i).attr("characteristic_id");
            characteristic_value = $("#input_" + i).val();
        }
        if (characteristic_id == -1 || characteristic_value == " " || characteristic_value == "" || characteristic_value == -1)
            return SendCharacteristics(requests, i + 1, max, index + 1, offer_id);
    }
    requests[1][index] = $.ajax(
            {
                type: "POST",
                url: "database_functions.php",
                data: {function: 8, id: -1, offer_id: offer_id, characteristic_id: characteristic_id, value: characteristic_value},
                success: function ()
                {
                    if (i < max - 1)
                    {
                        SendCharacteristics(requests, i + 1, max, index + 1, offer_id);
                    } else
                    {
                        alert("Предложение успешно добавлено!");
                    }
                }
            });
}

function UploadImages(offer_id)
{
    var input = document.getElementById("input_images");
    var count = input.files.length;
    if (count <= 0)
        return false;
    var reader = [];
    var results = [];
    ReadDataAsURL(reader, results, count, 0, offer_id);
}

function ReadDataAsURL(reader, results, count, i, offer_id)
{
    var input = document.getElementById("input_images");
    reader[i] = new FileReader();
    reader[i].onloadend = function ()
    {
        results[i] = reader[i].result;
        if (i < count - 1)
        {
            ReadDataAsURL(reader, results, count, i + 1, offer_id);
        }
        else
        {
            var request = $.ajax(
                    {
                        type: "POST",
                        url: "database_functions.php",
                        data: {function: 24, filename: $("#input_filename").val(), images: results, offer_id: offer_id},
                    });
        }
    }
    reader[i].readAsDataURL(input.files[i]);
}

function DeleteOfferClicked(id)
{
    var request = $.ajax(
            {
                type: "POST",
                url: "database_functions.php",
                data: {function: 27, id: id},
                success: function ()
                {
                    OnTabChanged(3);
                }
            });
}

function OnUpdateClicked(offer_id, count)
{
    var characteristics = [];
    var index = 0;
    for (var i = 4; i < count; i++)
    {
        var characteristic_container = document.getElementById("input_" + i);
        if (characteristic_container.tagName.toLowerCase() == "select")
        {
            var characteristic_id = $("#input_" + i + " option:selected").val();
            if (characteristic_id != -1)
            {
                characteristic_value = 1;
                characteristics[index] = [];
                characteristics[index][0] = characteristic_id;
                characteristics[index][1] = characteristic_value;
                index++;
            }
        }
        else
        {
            var characteristic_id = $("#input_" + i).attr("characteristic_id");
            var characteristic_value = $("#input_" + i).val();
            if (characteristic_value != '' && characteristic_value != ' ' && characteristic_value != 0)
            {
                characteristics[index] = [];
                characteristics[index][0] = characteristic_id;
                characteristics[index][1] = characteristic_value;
                index++;
            }
        }
    }
    UploadImages($("body").attr("offer_id"));
    var request = $.ajax(
            {
                type: "POST",
                url: "database_functions.php",
                data: {function: 31, offer_id: offer_id, title: $("#input_0").val(), description: $("#input_1").val(), location: $("#input_2").val(), video: $("#input_3").val(), characteristics: characteristics},
                success: function ()
                {
                    var r = confirm("Изменения сохранены!");
                    if (r != null)
                    {
                        setTimeout();
                        location.reload();
                    }
                },
                error: function ()
                {
                    alert("Произошла ошибка! Попробуйте еще раз.");
                }
            });
}

function OnEditLoaded(id)
{
    LoadImages(id);
}

function LoadImages(id)
{
    var request = $.ajax(
            {
                type: "POST",
                url: "database_functions.php",
                data: {function: 28, id: id},
                success: function (data)
                {
                    $("#output_images").html(data);
                }
            });
}

function DeleteImageClicked(id)
{
    var request = $.ajax(
            {
                type: "POST",
                url: "database_functions.php",
                data: {function: 29, id: id, offer_id: $("body").attr("offer_id")},
                success: function (data)
                {
                    LoadImages($("body").attr("offer_id"));
                }
            });
}

function MakePreviewClicked(id)
{
    var request = $.ajax(
            {
                type: "POST",
                url: "database_functions.php",
                data: {function: 30, id: id, offer_id: $("body").attr("offer_id")},
                success: function ()
                {
                    LoadImages($("body").attr("offer_id"));
                }
            });
}

function OnProfileEditLoaded()
{
    OnProfileImageUpdated();
}

function OnProfileImageUpdated()
{
    var request = $.ajax(
            {
                type: "POST",
                url: "database_functions.php",
                data: {function: 32, id: $("body").attr("user_id")},
                success: function (data)
                {
                    $("#image_output").css("background-image", "url('" + data + "')");
                    $("#image_output").css("background-position", "center");
                    $("#image_output").css("background-size", "contain");
                    $("#image_output").css("background-repeat", "no-repeat");
                }
            });
}

function OnUpdateProfileClicked()
{
    var date = $("#input_8").val() + " 00:00:00";
    var info = [$("#input_0").val(), $("#input_1").val(), $("#input_2").val(), $("#input_3").val(), $("#input_4").val(), $("#input_5").val(), $("#input_6").val(), $("#input_7").val(), date, $("#input_9").val()];
    var request = $.ajax(
            {
                type: "POST",
                url: "database_functions.php",
                data: {function: 33, data: info, id: $("body").attr("user_id")},
                success: function ()
                {
                    var input = document.getElementById("input_10");
                    if (input.files.length > 0)
                    {
                        UploadProfileImage();
                    } else
                    {
                        alert("Изменения сохранены!");
                    }
                },
                error: function ()
                {
                    alert("Произошла ошибка! Попробуйте еще раз.");
                }
            });
}

function UploadProfileImage()
{
    var input = document.getElementById("input_10");
    var reader = new FileReader();
    var result;
    reader.onloadend = function ()
    {
        result = reader.result;
        var request = $.ajax(
                {
                    type: "POST",
                    url: "database_functions.php",
                    data: {function: 34, image: result, user_id: $("body").attr("user_id")},
                    success: function ()
                    {
                        alert("Изменения сохранены!");
                        location.reload();
                    },
                    error: function ()
                    {
                        alert("Произошла ошибка! Попробуйте еще раз.");
                    }
                });
    };
    reader.readAsDataURL(input.files[0]);
}