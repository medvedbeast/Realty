<?php
include "../classes/database.php";
$posts_per_page = 5;
$current_page = (isset($_REQUEST["current_page"]) == true ? $_GET["current_page"] : 0);
$post_list = Database::GetPosts($posts_per_page, ($current_page * $posts_per_page));
$total_post_count = Database::GetRowCount("posts");
$total_pages = ceil($total_post_count / $posts_per_page);
?>
<div class="left">
    <heading>НОВОСТИ И СТАТЬИ</heading>
</div>
<?php
foreach ($post_list as $post)
{
    ?>
    <div class="post">
        <a href="post_details.php?id=<?= $post->id ?>">
            <div class="post_title">
                <heading><?= $post->title ?></heading>
            </div>
            <div class="post_content">
    <?php
    if (strlen($post->content) >= 1024)
    {
        $shortened_content = substr($post->content, 0, strpos($post->content, " ", 1024));
        $shortened_content .= "...";
        echo $shortened_content;
    }
    else
    {
        echo $post->content;
    }
    ?>
            </div>
        </a>
    </div>
    <?php
}
?>
<div>
    Страницы:
<?php
for ($i = $current_page - 2; $i < $current_page + 3; $i++)
{
    if ($i >= 0 and $i < $total_pages)
    {
        ?>
            <span onclick="OnPostPageNumberClicked(<?= $i ?>)" <?= ($current_page == $i ? "class='page_number_selected'" : "class='page_number'") ?>><?= $i + 1 ?></span>
        <?php
    }
}
?>
    из
    <span onclick="OnPostPageNumberClicked(<?= $total_pages - 1 ?>)" class="page_number"><?= $total_pages ?></span>
</div>

