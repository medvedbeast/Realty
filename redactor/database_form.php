<?php
if (!isset($_COOKIE["user"]))
{
    header("Location: database_login.php");
}
if (isset($_COOKIE["user"]))
{
    if ($_COOKIE["user"] != "admin")
    {
        header("Location: database.php");
    }
}
?>
<html>
    <head>
        <meta charset="UTF-8" />
        <title>
            showpage::DATABASE
        </title>
        <link rel="stylesheet" href="styles/database_form.css"  type="text/css"/>
        <script src="scripts/database_form.js" type="text/javascript"></script>
        <script src="scripts/jquery.min.js" type="text/javascript"></script>
    </head>
    <body onload="OnPageLoaded()">
        <div id="tab_container">
            <div id="tab_1" class="tab selected" onclick="OnTabClicked(this)">
                ПРЕДЛОЖЕНИЯ
            </div>
            <div id="tab_2" class="tab" onclick="OnTabClicked(this)">
                ХАРАКТЕРИСТИКИ
            </div>
            <div id="tab_3" class="tab" onclick="OnTabClicked(this)">
                ИЗОБРАЖЕНИЯ
            </div>
            <div id="tab_4" class="tab" onclick="OnTabClicked(this)">
                ПОСТЫ
            </div>
            <div id="tab_5" class="tab" onclick="OnTabClicked(this)">
                ВЫЙТИ
            </div>
        </div>
        <div id="page_container">
            <div id="page_1" class="page selected">
                ПРЕДЛОЖЕНИЯ
                <div style="height: 800px; overflow-y: scroll; position: relative; margin-bottom: 25px;">
                    <div id="input" style="display: none; position: absolute; top: 0; left: 0; width: 0px; height: 0px; overflow-y: scroll; background-color: white;">
                        <textarea id="input_area" style="width: 100%; height: 100%; resize: none;"></textarea>
                    </div>
                    <table id="offers_output" style="width: 100%; border: 1px solid black; padding: 5px;"></table>
                </div>
                ДОБАВЛЕНИЕ И УДАЛЕНИЕ ПРЕДЛОЖЕНИЙ
                <div style="margin-bottom: 10px;">
                    <table style="width: 100%; border: 1px solid black; padding: 5px; margin-bottom: 10px;">
                        <tr>
                            <td style="border-bottom: 1px solid black;">
                                <label>№</label>
                            </td>
                            <td style="width: 100%;">
                                <textarea id="offer_id" style="width: 100%; height: 100%; resize: vertical;"></textarea>
                            </td>
                        </tr>
                        <tr style="height: 150px;">
                            <td style="border-bottom: 1px solid black;">
                                <label>НАЗВАНИЕ</label>
                            </td>
                            <td>
                                <textarea id="offer_title" style="width: 100%; height: 150px; resize: vertical;"></textarea>
                            </td>
                        </tr>
                        <tr style="height: 150px;">
                            <td style="border-bottom: 1px solid black;">
                                <label>ОПИСАНИЕ</label>
                            </td>
                            <td>
                                <textarea id="offer_description" style="width: 100%; height: 150px; resize: vertical;"></textarea>
                            </td>
                        </tr>
                        <tr style="height: 150px;">
                            <td style="border-bottom: 1px solid black;">
                                <label>РАСПОЛОЖЕНИЕ</label>
                            </td>
                            <td>
                                <textarea id="offer_location" style="width: 100%; height: 150px; resize: vertical;"></textarea>
                            </td>
                        </tr>
                    </table>
                    <input type="button" style="width: 200px; height: 35px; background-color: lightgray; border: 1px solid black; float: left; margin-right: 25px;" value="ДОБАВИТЬ" onclick="OnOfferAddButtonClick()"/>
                    <input type="button" style="width: 200px; height: 35px; background-color: lightgray; border: 1px solid black; float: left;" value="УДАЛИТЬ" onclick="OnOfferDeleteButtonClick()"/>
                </div>
            </div>
            <div id="page_2" class="page">
                ХАРАКТЕРИСТИКИ
                <div style="border: 1px solid black; padding: 5px; margin-bottom: 25px;">
                    <table id="characteristics_output" style="width: 100%;"></table>
                </div>
                ХАРАКТЕРИСТИКИ ПРЕДЛОЖЕНИЙ
                <div style=" height: 450px; overflow-y: scroll; border: 1px solid black; position: relative; margin-bottom: 25px;">
                    <div id="input2" style="display: none; position: absolute; top: 0; left: 0; width: 0px; height: 0px; overflow-y: scroll; background-color: white;">
                        <textarea id="input_area2" style="width: 100%; height: 100%; resize: none;"></textarea>
                    </div>
                    <table id="offers_characteristics_output" style="width: 100%; padding: 5px;"></table>
                </div>
                ДОБАВЛЕНИЕ И УДАЛЕНИЕ ХАРАКТЕРИСТИК ДЛЯ ПРЕДЛОЖЕНИЯ
                <div>
                    <table style="width: 100%; border: 1px solid black; padding: 5px; margin-bottom: 10px;">
                        <tr>
                            <td style="border-bottom: 1px solid black;">
                                <label>№</label>
                            </td>
                            <td style="width: 100%;">
                                <textarea id="offer_characteristic_id" style="width: 100%; height: 100%; resize: vertical;"></textarea>
                            </td>
                        </tr>
                        <tr>
                            <td style="border-bottom: 1px solid black;">
                                <label>№ ПРЕДЛОЖЕНИЯ</label>
                            </td>
                            <td>
                                <textarea id="offer_id2" style="width: 100%; height: 100%; resize: vertical;"></textarea>
                            </td>
                        </tr>
                        <tr>
                            <td style="border-bottom: 1px solid black;">
                                <label>№ ХАРАКТЕРИСТИКИ</label>
                            </td>
                            <td>
                                <textarea id="characteristic_id" style="width: 100%; height: 100%; resize: vertical;"></textarea>
                            </td>
                        </tr>
                        <tr>
                            <td style="border-bottom: 1px solid black;">
                                <label>ЗНАЧЕНИЕ ХАРАКТЕРИСТИКИ</label>
                            </td>
                            <td>
                                <textarea id="offer_characteristic_value" style="width: 100%; height: 100%; resize: vertical;"></textarea>
                            </td>
                        </tr>
                    </table>
                    <input type="button" style="width: 200px; height: 35px; background-color: lightgray; border: 1px solid black; float: left; margin-right: 25px;" value="ДОБАВИТЬ" onclick="OnOfferCharacteristicAddButtonClick()"/>
                    <input type="button" style="width: 200px; height: 35px; background-color: lightgray; border: 1px solid black; float: left;" value="УДАЛИТЬ" onclick="OnOfferCharacteristicDeleteButtonClick()"/>
                </div>
            </div>
            <div id="page_3" class="page">
                ИЗОБРАЖЕНИЯ
                <div style="border: 1px solid black; margin-bottom: 25px; position: relative; height: 500px; overflow-y: scroll;">
                    <div id="input3" style="display: none; position: absolute; top: 0; left: 0; width: 0px; height: 0px; overflow-y: scroll; background-color: white;">
                        <textarea id="input_area3" style="width: 100%; height: 100%; resize: none;"></textarea>
                    </div>
                    <table id="images_output" style="width: 100%;"></table>
                </div>
                <div>
                    <table style="margin-bottom: 10px">
                        <tr>
                            <td style="border-bottom: 1px solid black;">
                                <label>№</label>
                            </td>
                            <td style="width: 100%;">
                                <textarea id="image_id" style="width: 100%; height: 100%; resize: vertical;"></textarea>
                            </td>
                        </tr>
                        <tr>
                            <td style="border-bottom: 1px solid black;">
                                <label>№ ПРЕДЛОЖЕНИЯ</label>
                            </td>
                            <td>
                                <textarea id="offer_id3" style="width: 100%; height: 100%; resize: vertical;"></textarea>
                            </td>
                        </tr>
                        <tr>
                            <td style="border-bottom: 1px solid black;">
                                <label>ПУТЬ</label>
                            </td>
                            <td>
                                <textarea id="path" style="width: 100%; height: 100%; resize: vertical;"></textarea>
                            </td>
                        </tr>
                        <tr>
                            <td style="border-bottom: 1px solid black;">
                                <label>ЯВЛЯЕТЬСЯ ЛИ ПРЕДПРОСМОТРОМ</label>
                            </td>
                            <td>
                                <textarea id="is_preview" style="width: 100%; height: 100%; resize: vertical;"></textarea>
                            </td>
                        </tr>
                    </table>
                    <input type="button" style="width: 200px; height: 35px; background-color: lightgray; border: 1px solid black; float: left; margin-right: 25px;" value="ДОБАВИТЬ" onclick="OnImageAddButtonClick()"/>
                    <input type="button" style="width: 200px; height: 35px; background-color: lightgray; border: 1px solid black; float: left;" value="УДАЛИТЬ" onclick="OnImageDeleteButtonClick()"/>
                </div>
                <div style="clear: left;margin-top: 150px;">
                    ЗАГРУЖЕННЫЕ НА СЕРВЕР ИЗОБРАЖЕНИЯ
                    <table id="image_list_output" style="width: 100%;"></table>
                </div>
                <div>
                    <form id="images_form" method="post" action="upload.php" enctype="multipart/form-data">
                        <table style="margin-bottom: 10px; width: 100%;">
                            <tr>
                                <td style="border-bottom: 1px solid black; width: 10%;">
                                    <label>ИМЯ</label>
                                </td>
                                <td>
                                    <textarea id="filename" name="filename" style="width: 100%; height: 100%; resize: vertical;"></textarea>
                                </td>
                                <td style="width: 30%;">
                                    <input id="images_input" name="images[]" type="file" multiple="true" style="width: 100%; height: 100%;"/>
                                </td>
                            </tr>
                        </table>
                        <input type="button" style="width: 200px; height: 35px; background-color: lightgray; border: 1px solid black; float: left; margin-right: 25px;" value="ЗАГРУЗИТЬ" onclick="OnImageToServerAddButtonClick()"/>
                        <input type="button" style="width: 200px; height: 35px; background-color: lightgray; border: 1px solid black; float: left;" value="УДАЛИТЬ" onclick="OnImageOnServerDeleteButtonClick()"/>
                    </form>
                </div>
            </div>
            <div id="page_4" class="page">
                ПОСТЫ
                <div style="height: 800px; overflow-y: scroll; position: relative; margin-bottom: 25px;">
                    <div id="input4" style="display: none; position: absolute; top: 0; left: 0; width: 0px; height: 0px; overflow-y: scroll; background-color: white;">
                        <textarea id="input_area4" style="width: 100%; height: 100%; resize: none;"></textarea>
                    </div>
                    <table id="posts_output" style="width: 100%; border: 1px solid black; padding: 5px;"></table>
                </div>
                ДОБАВЛЕНИЕ И УДАЛЕНИЕ ПОСТОВ
                <div style="margin-bottom: 10px;">
                    <table style="width: 100%; border: 1px solid black; padding: 5px; margin-bottom: 10px;">
                        <tr>
                            <td style="border-bottom: 1px solid black;">
                                <label>№</label>
                            </td>
                            <td style="width: 100%;">
                                <textarea id="post_id" style="width: 100%; height: 100%; resize: vertical;"></textarea>
                            </td>
                        </tr>
                        <tr style="height: 150px;">
                            <td style="border-bottom: 1px solid black;">
                                <label>НАЗВАНИЕ</label>
                            </td>
                            <td>
                                <textarea id="post_title" style="width: 100%; height: 150px; resize: vertical;"></textarea>
                            </td>
                        </tr>
                        <tr style="height: 150px;">
                            <td style="border-bottom: 1px solid black;">
                                <label>ТЕКСТ</label>
                            </td>
                            <td>
                                <textarea id="post_content" style="width: 100%; height: 150px; resize: vertical;"></textarea>
                            </td>
                        </tr>
                        <tr style="height: 150px;">
                            <td style="border-bottom: 1px solid black;">
                                <label>ДАТА</label>
                            </td>
                            <td>
                                <textarea id="post_date" style="width: 100%; height: 150px; resize: vertical;"></textarea>
                            </td>
                        </tr>
                    </table>
                    <input type="button" style="width: 200px; height: 35px; background-color: lightgray; border: 1px solid black; float: left; margin-right: 25px;" value="ДОБАВИТЬ" onclick="OnPostAddButtonClick()"/>
                    <input type="button" style="width: 200px; height: 35px; background-color: lightgray; border: 1px solid black; float: left;" value="УДАЛИТЬ" onclick="OnPostDeleteButtonClick()"/>
                </div>
            </div>
        </div>
    </body>
</html>