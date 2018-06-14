var isShown = false;
var currentPage = -1;
var totalPages = -1;
var offersPerPage = 8;

function OnBodyLoaded()
{
    GetCategory(0, function ()
    {
        var value = parseInt($("body").attr("selectedId"));
        $("option[value='" + value + "']").attr("selected", "selected");
        OnCategoryChanged($("select[precision]")[0]);
    });
    GetPaid();
}

function GetPaid()
{
    var request = $.ajax(
            {
                type: "POST",
                url: "core/functions.php",
                data: {function: "GetPaidOffers"},
                success: function (data)
                {
                    $("#paidResults").html(data);
                }
            });
}

function GetCategory(parentId, onSuccess)
{
    $("#searchResults").empty();
    var request = $.ajax(
            {
                type: "POST",
                url: "core/functions.php",
                data: {function: "GetCategory", id: 0, parentId: parentId},
                success: function (data)
                {
                    $("#categories").append(data);
                    if (typeof (onSuccess) == "function")
                    {
                        onSuccess();
                    }
                }
            });
}

function GetCharacteristic(categoryId)
{
    var request = $.ajax(
            {
                type: "POST",
                url: "core/functions.php",
                data: {function: "GetCharacteristic", id: 0, categoryId: categoryId, ranged: true},
                success: function (data)
                {
                    $("#characteristics").html(data);
                    $("#show").addClass("visible");
                }
            });
}

function OnCategoryChanged(sender)
{
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
    $("#show").removeClass("visible");
    if ($(sender).val() != "-1")
    {
        OnSearchClicked();
    }
    if ($(sender).attr("precision") == 1)
    {
        GetCategory($(sender).val(), null);
    }
    else
    {
        GetCharacteristic($(sender).val());
    }
}

function ShowCharacteristicsClicked()
{
    if ($("#characteristics").html() != "")
    {
        if (isShown)
        {
            $("#characteristics").removeClass("visible");
            $("#show").val("РАСШИРЕННЫЙ ПОИСК");
        } else
        {
            $("#characteristics").addClass("visible");
            $("#show").val("СВЕРНУТЬ РАСШИРЕННЫЙ ПОИСК");
        }
        isShown = !isShown;
    }
}

function OnSearchClicked()
{
    GetOfferPreviews(0);
}

function GetOfferPreviews(page)
{
    if ($("input:invalid").length > 0)
    {
        alert("Проверьте правильность введённых данных!");
        return;
    }

    //выбор х-к
    var index = 0;
    var characteristics = [];
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
                    characteristics[index] = {characteristicId: element.val(), value: true, precision: "option"};
                    index++;
                    break;
                }
                case "input":
                {
                    characteristics[index] = {characteristicId: element.attr("characteristic_id"), value: element.val(), precision: element.attr("prefix")};
                    index++;
                    break;
                }
            }
        }
    }
    //
    //наибольшая выбранная категория
    var maxRoot = -1;
    $("select").each(function ()
    {
        var v = parseInt($(this).val());
        if (v >= 0)
        {
            var r = $(this).attr("root_category_id");
            if (r > maxRoot)
            {
                maxRoot = r;
            }
        }
    });
    var category = $("select[root_category_id=" + maxRoot + "]")[0].value;
    //    
    var keywords = $("#query").val();
    var request = $.ajax(
            {
                type: "POST",
                url: "core/functions.php",
                data: {function: "GetOfferPreviews", categoryId: category, characteristics: characteristics, keywords: keywords, start: page * offersPerPage, quantity: offersPerPage, ownerId: 0},
                success: function (data)
                {
                    if (data == 0)
                    {
                        alert("Поиск не дал результатов! Попробуйте повторить поиск с другими параметрами!");
                        $("#searchResults").html("");
                    }
                    else
                    {
                        $("#searchResults").html(data);
                        $("#currentPage").html(page + 1);
                        $("#currentPage2").html(page + 1);
                        currentPage = page;
                    }
                }
            });
    GetOfferCount(category, characteristics, keywords);
}

function GetOfferCount(category, characteristics, keywords)
{
    var request = $.ajax(
            {
                type: "POST",
                url: "core/functions.php",
                data: {function: "GetOfferCount", categoryId: category, characteristics: characteristics, keywords: keywords},
                success: function (data)
                {
                    if (parseInt(data) == 0)
                    {
                        $("#totalPages").html(0);
                        $("#totalPages2").html(0);
                        $("#currentPage").html(0);
                        $("#currentPage2").html(0);
                    }
                    else
                    {
                        $("#totalPages").html(Math.ceil(data / offersPerPage));
                        $("#totalPages2").html(Math.ceil(data / offersPerPage));
                        var word = "";
                        switch (parseInt(data.substring(data.length - 1, data.length)))
                        {
                            case 1:
                            {
                                word = "ПРЕДЛОЖЕНИЕ";
                                break;
                            }
                            case 2, 3, 4:
                            {
                                word = "ПРЕДЛОЖЕНИЯ";
                                break;
                            }
                            case 5, 6, 7, 8, 9, 0:
                            {
                                word = "ПРЕДЛОЖЕНИЙ";
                                break;
                            }
                        }
                        $("#pageText").html(" (ВСЕГО: <b>" + data + "</b> " + word + ")");
                        totalPages = Math.ceil(data / offersPerPage);
                    }
                }
            });
}

function OnPreviousPageClicked()
{
    if (currentPage - 1 >= 0)
    {
        GetOfferPreviews(currentPage - 1);
        currentPage -= 1;
    }
}

function OnNextPageClicked()
{
    if (currentPage + 1 < totalPages)
    {
        GetOfferPreviews(currentPage + 1);
        currentPage += 1;
    }
}

function OnPageNumberEntered(event)
{
    if ((event.key == "Enter" && event.type == "keyup") || event.type == "blur")
    {
        var newPage = $("#page").val();
        if (newPage > 0 && newPage <= totalPages)
        {
            GetOfferPreviews(newPage - 1);
        }
        else
        {
            newPage = $("#page2").val();
            if (newPage > 0 && newPage <= totalPages)
            {
                GetOfferPreviews(newPage - 1);
            }
        }
        $("#page").val("");
    }
}