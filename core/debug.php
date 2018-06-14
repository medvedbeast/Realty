<?php

class Debug
{

    public static function Log($message)
    {
        ?>
        <script type='text/javascript'>console.log("<?= $message ?>")</script>
        <?php
    }

    public static function Alert($message)
    {
        ?>
        <script type='text/javascript'>alert("<?= $message ?>")</script>
        <?php
    }
    
    public static function Show($object)
    {
        ?>
        <pre>
            <?php
            print_r($object);
            ?>
        </pre>
        <?php
    }

}
