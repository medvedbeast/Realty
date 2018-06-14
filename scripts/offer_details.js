var selected_image_index  = -1;
var id;

function OnPageLoaded()
{
    var page = window.location.toString();
    page = page.substring(page.lastIndexOf("/") + 1, page.indexOf("?"));
    id = window.location.toString();
    id = id.substring(id.lastIndexOf("=") + 1, id.length);
    InitializeMap(document.getElementById("hidden_info").innerHTML);
    LoadGallery(id, -1);
}

function LoadGallery(offer_id, page)
{
    document.getElementById("image_table").className = "image_table_faded";
    var request = $.ajax(
        {
            type: 'POST',
            url: 'modules/image_gallery.php?id=' + offer_id + (page >= 0 ? '&page=' + page : '') + (selected_image_index >= 0 ? '&selected_image_index=' + selected_image_index : ''),
            success: function (data)
            {
                OnImagesLoaded(data);
                document.getElementById("image_table").className = "image_table";
            }
        });
}

function InitializeMap(address)
{
    address = address.toString();
    geocoder = new google.maps.Geocoder();
    var latlng = new google.maps.LatLng(1, 1);
    var mapOptions = { zoom: 15, center: latlng }
    map = new google.maps.Map(document.getElementById('map'), mapOptions);
    CodeAddress(address);
}

function CodeAddress(address)
{
  geocoder.geocode({'address':address}, function(results, status)
  {
    if (status == google.maps.GeocoderStatus.OK)
    {
        map.setCenter(results[0].geometry.location);
        var marker = new google.maps.Marker(
            {
                position: results[0].geometry.location,
                map: map,
            });
    }
    else
    {
        //alert('Geocode was not successful for the following reason: ' + status);
    }
  });
}

function SelectImage(sender, url)
{
    $("#image_large").css("background-image", "url(" + url + ")");
    $("#image_large").css("background-size", "contain");
    $("#image_large").css("background-repeat", "no-repeat");
    $("#image_large").css("background-position", "center");
    
    var i = 0;
    var str_id = sender.id.toString();
    var selected_index = str_id.substr(str_id.indexOf("_") + 1, str_id.length);
    while (document.getElementById("image_" + i))
    {
        document.getElementById("image_" + i++).className = "image";
    }
    sender.className = "image selected";
    selected_image_index = selected_index;
}

function OnImagesLoaded(data)
{
    $("#image_table").html(data);
}

function OnGalleryPageClicked(number)
{
    LoadGallery(id, number);
}