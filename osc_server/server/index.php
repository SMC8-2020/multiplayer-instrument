<?php
 

    if (!file_exists("data/")) {
        mkdir("data", 0700);
    }

   if ($_POST['filename'] && $_POST['contents']) {

        if (preg_match("/data\/[^0-9_]\.csv/",$_POST['filename'] )) {
            die ("invalid");
        }
    
        echo "File: ". $_POST['filename'] . "\n";
        file_put_contents ($_POST['filename'], $_POST['contents']);
    }