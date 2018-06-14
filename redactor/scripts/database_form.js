var tab_current = 1;
var tab_count = 4;
var selectedElement;

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
    selectedElement = null;
    tab_current = id;
    switch (parseInt(id))
    {
        case 1:
            var request = $.ajax(
                    {
                        type: "POST",
                        url: "database_functions.php",
                        data: {function: 1},
                        success: function (data)
                        {
                            $("#offers_output").html(data);
                        }
                    });
            break;
        case 2:
            var request = $.ajax(
                    {
                        type: "POST",
                        url: "database_functions.php",
                        data: {function: 5},
                        success: function (data)
                        {
                            $("#characteristics_output").html(data);
                            request = $.ajax(
                                    {
                                        type: "POST",
                                        url: "database_functions.php",
                                        data: {function: 6},
                                        success: function (data)
                                        {
                                            $("#offers_characteristics_output").html(data);
                                        }
                                    });
                        }
                    });
            break;
        case 3:
            var request = $.ajax(
                    {
                        type: "POST",
                        url: "database_functions.php",
                        data: {function: 10},
                        success: function (data)
                        {
                            $("#images_output").html(data);
                            var request = $.ajax(
                                    {
                                        type: "POST",
                                        url: "database_functions.php",
                                        data: {function: 14},
                                        success: function (data)
                                        {
                                            $("#image_list_output").html(data);
                                        }
                                    });
                        }
                    });
            break;
        case 4:
            var request = $.ajax(
                    {
                        type: "POST",
                        url: "database_functions.php",
                        data: {function: 17},
                        success: function (data)
                        {
                            $("#posts_output").html(data);
                        }
                    });
            break;
        case 5:
        {
            document.cookie = "user=; expires=Thu, 01 Jan 1970 00:00:01 GMT;";
            document.location.href = "http://top-real.com.ua/redactor/database_form.php";
            break;
        }
    }
}

function OnPageLoaded()
{
    OnTabChanged(1);
}

function OnOfferCellClicked(sender)
{
    if (selectedElement != null)
    {
        var request = $.ajax(
                {
                    type: "POST",
                    url: "database_functions.php",
                    data: {function: 2, name: selectedElement.getAttribute("name"), value: $("#input_area").val(), id: selectedElement.parentNode.getAttribute("offer_id")},
                    success: function ()
                    {
                        OnTabChanged(tab_current);
                    }
                });
        $("#input").css("display", "none");
    }
    else
    {
        selectedElement = sender;
        $("#input").css("display", "block");
        $("#input").css("top", sender.offsetTop);
        $("#input").css("left", sender.offsetLeft);
        $("#input").css("width", sender.offsetWidth);
        $("#input").css("height", sender.offsetHeight);
        $("#input_area").val(sender.innerHTML);
    }
}

function OnOfferAddButtonClick()
{
    var request = $.ajax(
            {
                type: "POST",
                url: "database_functions.php",
                data: {function: 3, id: $("#offer_id").val(), title: $("#offer_title").val(), description: $("#offer_description").val(), location: $("#offer_location").val(), owner: "admin"},
                success: function ()
                {
                    OnTabChanged(tab_current);
                }
            });
}

function OnOfferDeleteButtonClick()
{
    var request = $.ajax(
            {
                type: "POST",
                url: "database_functions.php",
                data: {function: 4, id: $("#offer_id").val()},
                success: function ()
                {
                    OnTabChanged(tab_current);
                }
            });
}

function OnOfferCharacteristicCellClicked(sender)
{
    if (selectedElement != null)
    {
        var request = $.ajax(
                {
                    type: "POST",
                    url: "database_functions.php",
                    data: {function: 7, name: selectedElement.getAttribute("name"), value: $("#input_area2").val(), id: selectedElement.parentNode.getAttribute("offer_characteristic_id")},
                    success: function ()
                    {
                        OnTabChanged(tab_current);
                    }
                });
        $("#input2").css("display", "none");
    }
    else
    {
        selectedElement = sender;
        $("#input2").css("display", "block");
        $("#input2").css("top", sender.offsetTop);
        $("#input2").css("left", sender.offsetLeft);
        $("#input2").css("width", sender.offsetWidth);
        $("#input2").css("height", sender.offsetHeight);
        $("#input_area2").val(sender.innerHTML);
    }
}

function OnOfferCharacteristicAddButtonClick()
{
    var request = $.ajax(
            {
                type: "POST",
                url: "database_functions.php",
                data: {function: 8, id: $("#offer_characteristic_id").val(), offer_id: $("#offer_id2").val(), characteristic_id: $("#characteristic_id").val(), value: $("#offer_characteristic_value").val()},
                success: function ()
                {
                    OnTabChanged(tab_current);
                }
            });
}

function OnOfferCharacteristicDeleteButtonClick()
{
    var request = $.ajax(
            {
                type: "POST",
                url: "database_functions.php",
                data: {function: 9, id: $("#offer_characteristic_id").val()},
                success: function ()
                {
                    OnTabChanged(tab_current);
                }
            });
}

function OnImageCellClicked(sender)
{
    if (selectedElement != null)
    {
        var request = $.ajax(
                {
                    type: "POST",
                    url: "database_functions.php",
                    data: {function: 11, name: selectedElement.getAttribute("name"), value: $("#input_area3").val(), id: selectedElement.parentNode.getAttribute("image_id")},
                    success: function ()
                    {
                        OnTabChanged(tab_current);
                    }
                });
        $("#input3").css("display", "none");
    }
    else
    {
        selectedElement = sender;
        $("#input3").css("display", "block");
        $("#input3").css("top", sender.offsetTop);
        $("#input3").css("left", sender.offsetLeft);
        $("#input3").css("width", sender.offsetWidth);
        $("#input3").css("height", sender.offsetHeight);
        $("#input_area3").val(sender.innerHTML);
    }
}

function OnImageAddButtonClick()
{
    var request = $.ajax(
            {
                type: "POST",
                url: "database_functions.php",
                data: {function: 12, id: $("#image_id").val(), offer_id: $("#offer_id3").val(), path: "../images/offers/" + $("#path").val(), is_preview: $("#is_preview").val()},
                success: function ()
                {
                    OnTabChanged(tab_current);
                }
            });
}

function OnImageDeleteButtonClick()
{
    var request = $.ajax(
            {
                type: "POST",
                url: "database_functions.php",
                data: {function: 13, id: $("#image_id").val()},
                success: function ()
                {
                    OnTabChanged(tab_current);
                }
            });
}

function OnImageToServerAddButtonClick()
{
    var input = document.getElementById("images_input");
    var count = input.files.length;
    var reader = [];
    var results = [];
    ReadDataAsURL(reader, results, count, 0);
}

function ReadDataAsURL(reader, results, count, i)
{
    var input = document.getElementById("images_input");
    reader[i] = new FileReader();
    reader[i].onloadend = function ()
    {
        results[i] = reader[i].result;
        if (i < count - 1)
        {
            ReadDataAsURL(reader, results, count, i + 1);
        }
        else
        {
            var request = $.ajax(
                    {
                        type: "POST",
                        url: "database_functions.php",
                        data: {function: 15, filename: $("#filename").val(), images: results},
                        success: function ()
                        {
                            OnTabChanged(tab_current);
                        }
                    });
        }
    }
    reader[i].readAsDataURL(input.files[i]);
}

function OnImageOnServerDeleteButtonClick()
{
    var request = $.ajax(
            {
                type: "POST",
                url: "database_functions.php",
                data: {function: 16, filename: $("#filename").val()},
                success: function ()
                {
                    OnTabChanged(tab_current);
                }
            });
}

function OnPostCellClicked(sender)
{
    if (selectedElement != null)
    {
        var request = $.ajax(
                {
                    type: "POST",
                    url: "database_functions.php",
                    data: {function: 18, name: selectedElement.getAttribute("name"), value: $("#input_area4").val(), id: selectedElement.parentNode.getAttribute("post_id")},
                    success: function (data)
                    {
                        OnTabChanged(tab_current);
                    }
                });
        $("#input4").css("display", "none");
    }
    else
    {
        selectedElement = sender;
        $("#input4").css("display", "block");
        $("#input4").css("top", sender.offsetTop);
        $("#input4").css("left", sender.offsetLeft);
        $("#input4").css("width", sender.offsetWidth);
        $("#input4").css("height", sender.offsetHeight);
        $("#input_area4").val(sender.innerHTML);
    }
}

function OnPostAddButtonClick()
{
    var request = $.ajax(
            {
                type: "POST",
                url: "database_functions.php",
                data: {function: 19, id: $("#post_id").val(), title: $("#post_title").val(), content: $("#post_content").val(), date: $("#post_date").val()},
                success: function ()
                {
                    OnTabChanged(tab_current);
                }
            });
}

function OnPostDeleteButtonClick()
{
    var request = $.ajax(
            {
                type: "POST",
                url: "database_functions.php",
                data: {function: 20, id: $("#post_id").val()},
                success: function ()
                {
                    OnTabChanged(tab_current);
                }
            });
}