function OnBodyLoaded(id)
{
    var ownerId = $("#offerContent").attr("owner_id");
    GetOfferOwner(ownerId);
    InitializeMap($("#address").html());
}

function GetOffer(id)
{
    var request = $.ajax(
            {
                type: "POST",
                url: "core/functions.php",
                data: {function: "GetOffer", id: id, ownerId: 0},
                success: function (data)
                {
                    $("#details_container").html(data);

                }
            });
}

function OnImageClicked(path)
{
    $("#previewLink").attr("href", "images/offers/" + path);
    $("#preview").css("backgroundImage", "url('images/offers/" + path + "')");
}

function OnUnitChanged(sender)
{
    var exchangeRate = $(sender).attr("exchange_rate");
    var initialRate = $("div [initial]").attr("exchange_rate");
    var symbol = $(sender).attr("symbol");
    $("div [unit_id]").each(function ()
    {
        var initialValue = $(this).attr("initial_value");
        $(this).html(((initialValue * initialRate) / exchangeRate).toFixed(2) + " " + symbol);
    });
}

function InitializeMap(address)
{
    var map;
    ymaps.ready(
            function ()
            {
                var geocode = ymaps.geocode(address);
                geocode.then(
                        function (result)
                        {
                            map = new ymaps.Map("map", {center: result.geoObjects.get(0).geometry.getCoordinates(), zoom: 15});
                            var point = new ymaps.GeoObject({
                                geometry: {
                                    type: "Point",
                                    coordinates: result.geoObjects.get(0).geometry.getCoordinates()
                                }
                            });
                            map.geoObjects.add(point);
                        },
                        function (error)
                        {
                            console.log(error);
                        }
                );
            }
    );
}

function GetOfferOwner(id)
{
    var request = $.ajax(
            {
                type: "POST",
                url: "core/functions.php",
                data: {function: "GetUserCard", id: id, access: 0},
                success: function (data)
                {
                    $("#owner_container").html(data);
                }
            });
}