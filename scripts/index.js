var action;
var type;

function OnPageLoaded()
{
    GetPosts(0);
}

function OnColumnClick(sender, index)
{
    action = index;
    $("#" + sender.id).addClass("highlighted");
    $(".column.center.visible.half-wide:not(#" + sender.id + ")").removeClass("highlighted");
    var wrapper = $(".wrapper");
    wrapper.removeClass("wrapped");
    wrapper.addClass("unwrapped");
    if (sender.id == "buy")
    {
        $("#hidden_column_1").removeClass("half-wide");
        $("#hidden_column_1").addClass("third-wide");
        $("#hidden_column_2").removeClass("half-wide");
        $("#hidden_column_2").addClass("third-wide");
        $("#hidden_column_3").removeClass("invisible");
        $("#hidden_column_3").addClass("third-wide");
    }
    else
    {
        if (sender.id == "rent")
        {
            $("#hidden_column_1").removeClass("third-wide");
            $("#hidden_column_1").addClass("half-wide");
            $("#hidden_column_2").removeClass("third-wide");
            $("#hidden_column_2").addClass("half-wide");
            $("#hidden_column_3").removeClass("third-wide");
            $("#hidden_column_3").addClass("invisible");
        }
    }
}

function OnPostPageNumberClicked(page)
{
    GetPosts(page);
}

function GetPosts(page)
{
    var request = $.ajax(
        {
            type: "get",
            url: "modules/post_module.php",
            data: "current_page=" + page,
            async: false,
            success: function (data)
            {
                $("#news_container").html(data);
            }
        });
}

function OnTypeClick(index)
{
    type = index;
    document.location.href = "commerce.php?action=" + action + "&type=" + type;
}

function SendMail()
{
    var request = $.ajax(
            {
                type: "POST",
                url: "/redactor/database_functions.php",
                data: {function: 22, to: "sanches999@ukr.net", from: $("#mail").val(), name: $("#name").val(), telephone: $("#telephone").val(), question: $("#question").val()},
                success: function ()
                {
                    alert("Спасибо! Ваше сообщение отправлено. В скором времени мы с Вами свяжемся.");
                }
            });
}