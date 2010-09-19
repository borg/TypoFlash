<?php
	$id = trim($_REQUEST['id']); 
	$xml = file_get_contents("http://www.vimeo.com/moogaloop/load/clip:{$id}");

	preg_match('|ure>(.*?)</req|i',$xml,$sig);
	preg_match('|ires>(.*?)</req|i',$xml,$exp);

	$url = "http://www.vimeo.com/moogaloop/play/clip:{$id}/{$sig[1]}/{$exp[1]}/?q=sd";
	echo $url;

?>