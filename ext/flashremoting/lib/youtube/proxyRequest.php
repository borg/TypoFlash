<?php
// PHP Proxy
// Responds to both HTTP GET and POST requests
//
// Author: Abdul Qabiz
// March 31st, 2006
//

// Get the url of to be proxied
// Is it a POST or a GET?
$url = ($_POST['url']) ? $_POST['url'] : $_GET['url'];
$headers = ($_POST['headers']) ? $_POST['headers'] : $_GET['headers'];
$mimeType =($_POST['mimeType']) ? $_POST['mimeType'] : $_GET['mimeType'];


//Start the Curl session
$session = curl_init($url);

// If it's a POST, put the POST data in the body
//if ($_POST['url']) {
	$postvars = '';
	while ($element = current($_POST)) {
		$postvars .= key($_POST).'='.$element.'&';
		next($_POST);
	}
	curl_setopt ($session, CURLOPT_POST, true);
	curl_setopt ($session, CURLOPT_POSTFIELDS, $postvars);
//}

// Don't return HTTP headers. Do return the contents of the call
curl_setopt($session, CURLOPT_HEADER, ($headers == "true") ? true : false);

curl_setopt($session, CURLOPT_FOLLOWLOCATION, true); 
//curl_setopt($ch, CURLOPT_TIMEOUT, 4); 
curl_setopt($session, CURLOPT_RETURNTRANSFER, true);

// Make the call
$response = curl_exec($session);

if ($mimeType != "")
{
	// The web service returns XML. Set the Content-Type appropriately
	header("Content-Type: ".$mimeType);
}

echo $response;

curl_close($session);

?>

