<?php
include "./classes/database.php";
$characteristics = Database::GetCharacteristicList();
$index = 1;
$characteristic_number = 1;
$id = 1;
$previous_group = "";
?>
<form id="offer_filter_form">
    <table>
        <tr>
            <td colspan="3">
                <input type="button" value="ПОИСК" onclick="OnSearchButtonClick()"/>
            </td>
        </tr>
        <?php
        foreach ($characteristics as $key => $group)
        {
            $characteristic_number = 1;
            ?>
            <tr class="category_title">
                <td colspan="3"><heading><?= ($key) ?></heading></td>
            </tr>
            <?php
            foreach ($group as $characteristic)
            {
                $tag = $characteristic[3];
                $type = $characteristic[2];
                $title = $characteristic[1];
                if ($type == "option")
                {
                    ?>
                    <tr>
                        <td colspan="2">
                            <?= $title ?>
                        </td>
                        <td>
                            <input id="<?="input_" . $id?>" name="<?= $tag ?>" type="radio" value="checked" input_type="<?=$type?>" characteristic_id="<?=$id?>" precision="exact" <?= $_GET["action"] == $characteristic_number && $tag == "action" ? "checked" : $_GET["type"] == $characteristic_number && $tag == "type" ? "checked" : "" ; ?>/>
                        </td>
                    </tr>
                    <?php
                    $id++;
                }
                else
                {
                    ?>
                    <tr>
                        <td>
                            <?= $title ?>
                        </td>
                        <td>
                            от
                        </td>
                        <td>
                            <input pattern="^[0-9]+$" id="<?="input_" . $id?>" name="<?= $tag . "_" . $index++ ?>" value="" input_type="<?=$type?>" type="text" characteristic_id="<?=$id++?>" precision="min"/>
                        </td>
                    </tr>
                    <tr>
                        <td></td>
                        <td>
                            до
                        </td>
                        <td>
                            <input pattern="^[0-9]+$" id="<?="input_" . $id?>" name="<?= $tag . "_" . $index++ ?>" value="" input_type="<?=$type?>" type="text" characteristic_id="<?=$id++ - 1?>" precision="max"/>
                        </td>
                    </tr>
                    <?php
                }
                ?>
                <?php
                $characteristic_number++;
            }
            ?>
            <?php
            $previous_group = $key;
        }
        ?>
        <tr>
            <td colspan="3">
                <input type="button" value="ПОИСК" onclick="OnSearchButtonClick()"/>
            </td>
        </tr>
    </table>
</form>