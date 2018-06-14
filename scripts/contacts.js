function OnBodyLoaded()
{
    GetAdministration();
}

function GetAdministration()
{
    var request = $.ajax(
            {
                type: "POST",
                url: "core/functions.php",
                data: {function: "GetUserCard", id:0, access: 1},
                success: function (data)
                {
                    $("#content").html(data);
                }
            });
}