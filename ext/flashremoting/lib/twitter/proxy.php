<?php
// PHP Proxy
//for higher security just put the url you want here or build
//your url with GET or POST parameters. Not the best idea to
//pass the entire url
//make sure we're using http
$url = 'http://';
if (isset($_GET['sd']) && $_GET['sd'] != '')
{
	$url .= $_GET['sd'].'.';
}
//ensure only twitter domains are used
$url .= 'twitter.com/';
if (isset($_GET['path']) && $_GET['path'] != '')
{
	$url .= $_GET['path'];
}
//you can change this to set mimeType via parameters, but
//chances are you want xml
$mimeType = 'application/xml';
$response = file_get_contents($url);
if ($mimeType != "")
{
	header("Content-Type: ".$mimeType);
}
echo $response;
?>


