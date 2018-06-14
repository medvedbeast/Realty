<?php
include "../classes/database.php";
$offers_per_page = 12;
$offers_per_row = 3;
$current_page = isset($_REQUEST["page"]) ? $_REQUEST["page"] : 0;
if (!isset($_REQUEST["keywords"]))
{
    $index = 0;
    foreach ($_POST as $key => $value)
    {
        if ($value[1] != "" and $value[1] != " " and $value[1] != "false")
        {
            if ($value[1] == "true")
            {
                $parameters[$index++] = array($value[0], 1, $value[2]);
            }
            else
            {
                $parameters[$index++] = array($value[0], $value[1], $value[2]);
            }
        }
    }

    $results = Database::GetOffers($parameters, $current_page * $offers_per_page, $offers_per_page);
    $total_offer_count = Database::GetOfferCount($parameters);

    if (count($results) <= 0)
    {
        die("Ничего не найдено! Попробуйте повторить поиск с другими фильтрами.");
    }
}
else
{
    $results = Database::GetOffersByKeywords(split(" ", $_REQUEST["keywords"]), $current_page * $offers_per_page, $offers_per_page);
    $total_offer_count = Database::GetOffersByKeywordsCount(split(" ", $_REQUEST["keywords"]));
    if (count($results) <= 0)
    {
        die("Ничего не найдено! Попробуйте повторить поиск с ключевыми словами.");
    }
}
?>
<table style="height: 100%; width: 100%;">
    <?php
    $index = 0;
    $rows = ceil($offers_per_page / $offers_per_row);
    for ($i = 0; $i < $rows; $i++)
    {
        ?>
        <tr style="height: <?= 100 / ($offers_per_page / $offers_per_row) ?>%">
            <?php
            for ($j = 0; $j < $offers_per_row; $j++, $index++)
            {
                ?>
                <td style="width: <?= 100 / $offers_per_row ?>%">
                    <?php
                    if ($index < count($results))
                    {
                        $offer = $results[$index];
                        ?>
                        <table style="top: 0; bottom: 0; height: 100%; width: 100%; border: 1px solid lightgray;" onclick="OnOfferClicked(<?= $offer->id ?>)">
                            <tr style="height: 300px">
                                <td style="background-image: url('<?= $offer->preview ?>'); background-position: center; background-size: contain; background-repeat: no-repeat;"></td>
                            </tr>
                            <tr>
                                <td>
                            <heading><?= $offer->title ?></heading>
                    </td>
                </tr>
                <tr>
                    <td>
                        <?php
                        if (strlen($offer->description) >= 256)
                        {
                            $shortened_content = substr($offer->description, 0, strpos($offer->description, " ", 256));
                            $shortened_content .= "...";
                            echo $shortened_content;
                        }
                        else
                        {
                            echo $offer->description;
                        }
                        ?>
                    </td>
                </tr>
            </table>
            <?php
        }
        ?>
        </td>
        <?php
    }
    ?>
    </tr>
    <?php
}
?>
<tr>
    <td colspan="<?= $offers_per_row ?>">
        Страницы:
        <?php
        $total_pages = ceil($total_offer_count / $offers_per_page);
        for ($i = $current_page - 2; $i < $current_page + 3; $i++)
        {
            if ($i >= 0 and $i < $total_pages)
            {
                ?>
                <span onclick="OnOfferPageNumberClicked(<?= $i ?>)" <?= ($current_page == $i ? "class='page_number_selected'" : "class='page_number'") ?>><?= $i + 1 ?></span>

                <?php
            }
        }
        ?>
        из
        <span onclick="OnOfferPageNumberClicked(<?= $total_pages - 1 ?>)" class="page_number"><?= $total_pages ?></span>
    </td>
</tr>
</table>