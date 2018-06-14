<?php
if (!isset($_COOKIE["user"]))
{
    header("Location: database_login.php");
}

include "../classes/database.php";
$offer = Database::GetOffer($_REQUEST["id"]);
$characteristics = Database::GetCharacteristicList();
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
    <body onload="OnEditLoaded(<?= $offer->id ?>)" offer_id="<?= $offer->id ?>">
        <div id="tab_container">
            <div id="tab_1" class="tab selected">
                ИЗМЕНИТЬ ПРЕДЛОЖЕНИЕ
            </div>
        </div>
        <div id="page_container">
            <div id="page_1" class="page selected">
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
                                    <input type="text" id="input_0" value="<?= $offer->title ?>" />
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
                                    <textarea id="input_1"><?= $offer->description ?></textarea>
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
                                    <textarea id="input_2"><?= $offer->location ?></textarea>
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
                                    <input type="text" id="input_3" value="<?= $offer->video ?>" />
                                </td>
                            </tr>
                            <?php
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
                                                            <option value="-1"></option>
                                                            <?php
                                                            foreach ($group as $characteristic)
                                                            {
                                                                $id = $characteristic[0];
                                                                $title = $characteristic[1];
                                                                $tag = $characteristic[3];
                                                                $flag = false;
                                                                foreach ($offer->characteristics as $item)
                                                                {
                                                                    if ($key == $item[3] && mb_strtolower($title, "utf-8") == mb_strtolower($item[0], "utf-8"))
                                                                    {
                                                                        $flag = true;
                                                                    }
                                                                }
                                                                if ($flag)
                                                                {
                                                                    ?>
                                                                    <option value="<?= $id ?>" selected>
                                                                    <?= mb_strtolower($title, "utf-8") ?>
                                                                    </option>
                                                                    <?php
                                                                }
                                                                else
                                                                {
                                                                    ?>
                                                                    <option value="<?= $id ?>" >
                                                                    <?= mb_strtolower($title, "utf-8") ?>
                                                                    </option>
                                                                    <?php
                                                                }
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

                                                    $target = false;
                                                    foreach ($offer->characteristics as $item)
                                                    {
                                                        if (mb_strtolower($title, "utf-8") == mb_strtolower($item[0], "utf-8"))
                                                        {
                                                            $target = $item[1];
                                                        }
                                                    }
                                                    ?>
                                                    <tr>
                                                        <td class="characteristic_td"><?= mb_strtolower($title, "utf-8") ?></td>
                                                        <td>
                                                            <input id="input_<?= $input_index++ ?>"  characteristic_id="<?= $id ?>" type="text" value="<?= $target === false ? "" : $target; ?>" />
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
                            <tr>
                                <td colspan="2">
                                    <table id="output_images" style="width: 100%;">
                                    </table>
                                </td>
                            </tr>
                            <tr class="separator_row">
                                <td colspan="2"></td>
                            </tr>
                        </table>
                    </div>
                    <div>
                        <input type='button' style="height: 50px; text-align: center;" value="ИЗМЕНИТЬ" onclick="OnUpdateClicked(<?= $offer->id ?>, <?= $input_index ?>)"/>
                    </div>
                </form>
            </div>
        </div>
    </body>
</html>