<?php
include_once '../classes/database.php';

$images_per_row = 3;
$images_per_page = 9;
$images_current_page = $_REQUEST["page"];
$images = database::GetImages($_REQUEST["id"]);
if (isset($_REQUEST["selected_image_index"]))
{
    $selected_image_index = $_REQUEST["selected_image_index"];
}
else
{
    $selected_image_index = 0;
    $index = 0;
    $preview_path = Database::GetOfferPreview($_REQUEST["id"]);
    if (count($images) <= 0)
    {
        echo "Фотографий нет!";
        return;
    } 
    foreach ($images as $image)
    {
        if ($image == $preview_path)
        {
            $selected_image_index = $index;
            break;
        }
        $index++;
    }
}
$index = $images_current_page * $images_per_page;
for ($i = 0; $i < $images_per_page / $images_per_row; $i++)
{
    ?>
    <tr>
        <?php
        for ($j = 0; $j < $images_per_row; $j++)
        {
            $url = "'" . $images[$index] . "'";
            if ($index < count($images))
            {
                ?>
                <td id="image_<?= $index ?>" onclick="SelectImage(this, <?= $url ?>)" <?= ($selected_image_index == $index ? 'class="selected image"' : 'class="image"') ?> style="width: <?= (100 / $images_per_row) ?>%;">
                    <div style="background-image: url(<?= $url ?>); background-size: contain; background-repeat: no-repeat; background-position: center; width: 100%; height: 100%;">
                    </div>
                </td>
                <?php
            }
            else
            {
                ?>
                <td>

                </td>
                <?php
            }
            $index++;
        }
        ?>
    </tr>    
    <?php
}
?>
<tr style="height: 5%">
    <td>
        Страницы:
        <?php
        $total_image_count = count($images);
        $total_pages = ceil($total_image_count / $images_per_page);
        for ($i = $images_current_page - 2; $i < $images_current_page + 3; $i++)
        {
            if ($i >= 0 and $i < $total_pages)
            {
                ?>
                <span onclick="OnGalleryPageClicked(<?= $i ?>)" <?= ($images_current_page == $i ? "class='page_number_selected'" : "class='page_number'") ?>><?= $i + 1 ?></span>
                <?php
            }
        }
        ?>
        из
        <span onclick="OnGalleryPageClicked(<?= $total_pages - 1 ?>)" class="page_number"><?= $total_pages ?></span>
    </td>
</tr>