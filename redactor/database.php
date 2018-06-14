<?php
if (!isset($_COOKIE["user"]))
{
    header("Location: database_login.php");
}
?>
<html>
    <head>
        <meta charset="UTF-8" />
        <title>
            Личный кабинет - <?= $_COOKIE["user"] ?>
        </title>
        <link rel="stylesheet" href="styles/database.css"  type="text/css"/>
        <script src="scripts/database.js" type="text/javascript"></script>
        <script src="scripts/jquery.min.js" type="text/javascript"></script>
    </head>
    <body onload="OnBodyLoaded()">
        <div id="tab_container">
            <div id="tab_1" class="tab selected" onclick="OnTabClicked(this)">
                ПРОФИЛЬ
            </div>
            <div id="tab_2" class="tab" onclick="OnTabClicked(this)">
                ДОБАВИТЬ ПРЕДЛОЖЕНИЕ
            </div>
            <div id="tab_3" class="tab" onclick="OnTabClicked(this)">
                ВСЕ ПРЕДЛОЖЕНИЯ
            </div>
            <div id="tab_4" class="tab" onclick="OnTabClicked(this)">
                ВЫЙТИ
            </div>
        </div>
        <div id="page_container">
            <div id="page_1" class="page selected">
                <div id="user_data" style="display: none;" login="<?= $_COOKIE["user"] ?>"></div>
                <div id="profile_info"></div>
            </div>
            <div id="page_2" class="page">
                <form action="" method="POST">
                    <div style="width: 100%;">
                        <table style="width: 100%;">
                            <tr class="separator_row">
                                <td colspan="2"></td>
                            </tr>
                            <tr>
                                <td class="category_td">
                                    НАЗВАНИЕ 
                                </td>
                                <td class="input_td">
                                    <input type="text" id="input_0" />
                                </td>
                            </tr>
                            <tr class="separator_row">
                                <td colspan="2"></td>
                            </tr>
                            <tr>
                                <td class="category_td">
                                    ОПИСАНИЕ 
                                </td>
                                <td class="input_td">
                                    <textarea id="input_1"></textarea>
                                </td>
                            </tr>
                            <tr class="separator_row">
                                <td colspan="2"></td>
                            </tr>
                            <tr>
                                <td class="category_td">
                                    РАСПОЛОЖЕНИЕ 
                                </td>
                                <td class="input_td">
                                    <textarea id="input_2"></textarea>
                                </td>
                            </tr>
                            <tr class="separator_row">
                                <td colspan="2"></td>
                            </tr>
                            <tr>
                                <td class="category_td">
                                    ВИДЕО 
                                </td>
                                <td class="input_td">
                                    <input type="text" id="input_3" />
                                </td>
                            </tr>
                            <?php
                            include "../classes/database.php";
                            $characteristics = Database::GetCharacteristicList();
                            $input_index = 4;
                            foreach ($characteristics as $key => $group)
                            {
                                ?>
                                <tr class="separator_row">
                                    <td colspan="2"></td>
                                </tr>
                                <tr>
                                    <td class="category_td">
                                        <?= mb_strtoupper($key, "utf-8") ?>
                                    </td>
                                    <td class="input_td">
                                        <?php
                                        $general_type = true;
                                        $previous_type = $group[0][2];
                                        foreach ($group as $characteristic)
                                        {
                                            $type = $characteristic[2];
                                            if ($type != $previous_type)
                                            {
                                                $general_type = false;
                                            }
                                            $previous_type = $type;
                                        }
                                        if ($general_type)
                                        {
                                            switch ($previous_type)
                                            {
                                                case "option":
                                                    {
                                                        ?>
                                                        <select id="input_<?= $input_index++ ?>">
                                                            <option value="-1">
                                                                
                                                            </option>
                                                            <?php
                                                            foreach ($group as $characteristic)
                                                            {
                                                                $id = $characteristic[0];
                                                                $title = $characteristic[1];
                                                                $tag = $characteristic[3];
                                                                ?>
                                                                <option value="<?= $id ?>">
                                                                    <?= mb_strtolower($title, "utf-8") ?>
                                                                </option>
                                                                <?php
                                                            }
                                                            ?>
                                                        </select>            
                                                        <?php
                                                        break;
                                                    }
                                                case "value":
                                                    {
                                                        ?>
                                                </tr>
                                                <?php
                                                foreach ($group as $characteristic)
                                                {
                                                    $id = $characteristic[0];
                                                    $title = $characteristic[1];
                                                    $tag = $characteristic[3];
                                                    ?>
                                                    <tr>
                                                        <td class="characteristic_td"><?= mb_strtolower($title, "utf-8") ?></td>
                                                        <td>
                                                            <input id="input_<?= $input_index++ ?>"  characteristic_id="<?= $id ?>" type="text"/>
                                                        </td>
                                                    </tr>
                                                    <?php
                                                }
                                                break;
                                            }
                                    }
                                }
                                ?>
                                </td>
                                </tr>
                                <?php
                            }
                            ?>
                            <tr class="separator_row">
                                <td colspan="2"></td>
                            </tr>
                            <tr>
                                <td>
                                    ИЗОБРАЖЕНИЯ
                                </td>
                                <td>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    базовое имя файла
                                </td>
                                <td>
                                    <input id="input_filename" type="text" /> 
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    файлы
                                </td>
                                <td>
                                    <input id="input_images" type="file" multiple /> 
                                </td>
                            </tr>
                            <tr class="separator_row">
                                <td colspan="2"></td>
                            </tr>
                        </table>
                    </div>
                    <div>
                        <input type='button' style="height: 50px; text-align: center;" value="ДОБАВИТЬ" onclick="OnAddClicked(<?= $input_index ?>)"/>
                    </div>
                </form>
            </div>
            <div id="page_3" class="page">
                <div id="offer_output"></div>
            </div>
            <div id="page_4" class="page">
                ВЫПОЛНЯЕТСЯ ВЫХОД..
            </div>
        </div>
    </body>
</html>