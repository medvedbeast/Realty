var currentPage = -1;
var totalPages = -1;
var postsPerPage = 8;

function OnBodyLoaded()
{
    GetPostPreviews(0);
}

function GetPostCount()
{
    var request = $.ajax(
            {
                type: "POST",
                url: "core/functions.php",
                data: {function: "GetPostCount", keywords: $("#query").val()},
                success: function (data)
                {
                    totalPages = Math.ceil(data / postsPerPage);
                    $("#totalPages").html(totalPages);
                    $("#totalPages_2").html(totalPages);
                    
                }
            });
}

function GetPostPreviews(page)
{
    GetPostCount();
    var request = $.ajax(
            {
                type: "POST",
                url: "core/functions.php",
                data: {function: "GetPostPreviews", keywords: $("#query").val(), start: page * postsPerPage, quantity: postsPerPage, ownerId: 0},
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
                    }
                    $("#currentPage").html(page + 1);
                    $("#currentPage_2").html(page + 1);
                    currentPage = page;
                }
            });
}

function OnPreviousPageClicked()
{
    if (currentPage - 1 >= 0)
    {
        GetPostPreviews(currentPage - 1);
        currentPage -= 1;
    }
}

function OnNextPageClicked()
{
    if (currentPage + 1 < totalPages)
    {
        GetPostPreviews(currentPage + 1);
        currentPage += 1;
    }
}

function OnPageNumberEntered(sender, event)
{
    if ((event.key == "enter" && event.type == "keyup") || event.type == "blur")
    {
        var newPage = $(sender).val();
        if (newPage > 0 && newPage <= totalPages)
        {
            GetPostPreviews(newPage - 1);
        }
        $(sender).val("");
    }
}

function OnSearchClicked()
{
    GetPostPreviews(0);
}