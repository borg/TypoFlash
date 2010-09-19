<?php
	set_time_limit(0);
	$url = ($_POST['url']) ? $_POST['url'] : $_GET['url'];
	header("Content-type: video/x-flv"); 
	$f = fopen($url, "r");
	while(!feof($f)) {
		echo fread($f,8192);
	}
	fclose($f);
?>