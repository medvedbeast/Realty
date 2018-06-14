var page = 0;

function OnPageLoaded()
{
    GetOffers();
}

function OnSearchButtonClick()
{
    GetOffers();
}

function GetOffers()
{
    var message = SerializeForm();
    var request = $.ajax(
        {
            type: 'POST',
            url: './modules/offer_selection.php' + (page >= 0 ? '?page=' + page : ''),
            data: message,
            success: function (data)
            {
                $("#selection_container").html(data);
            }
        });
}

function SerializeForm()
{
    var serialized = {};
    var input;
    var index = 1;
    if (document.getElementById("offer_filter_form").checkValidity())
    {
        while (document.getElementById("input_" + index) != null)
        {
            input = document.getElementById("input_" + index);
            if (input.getAttribute("input_type") != "value")
            {
                serialized[index++] = [ input.getAttribute("characteristic_id"), input.checked, input.getAttribute("precision") ];
            }
            else
            {
                serialized[index++] = [ input.getAttribute("characteristic_id"), input.value, input.getAttribute("precision") ];
            }
        }
    }
    else
    {
        alert("Не все поля заполненны правильно!");
    }
    
    return serialized;
}

function OnOfferPageNumberClicked(number)
{
    page = number;
    GetOffers();
}

function OnOfferClicked(number)
{
    document.location.href = "offer_details.php?id=" + number;
}

function OnSearchByKeywordsClick()
{
    var request = $.ajax(
        {
            type: 'POST',
            url: './modules/offer_selection.php' + (page >= 0 ? '?page=' + page : ''),
            data: {keywords: $("#keywords").val()},
            success: function (data)
            {
                $("#selection_container").html(data);
            }
        });
}