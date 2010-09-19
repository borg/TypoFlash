
<?php



$url = 'http://';
if (isset($_GET['sd']) && $_GET['sd'] != '')
{
	$url .= $_GET['sd'].'.';
}
//ensure only facebook domains are used
$url .= 'www.facebook.com/';
if (isset($_GET['path']) && $_GET['path'] != '')
{
	$url .= urldecode($_GET['path']);
}

//$url .= 'topic.php?uid=272338330337&topic=10037';
// initialize a new curl resource
$ch = curl_init();

// set the url to fetch
curl_setopt($ch, CURLOPT_URL, $url);
//curl_setopt($ch, CURLOPT_URL, 'http://www.google.com');

// don't give me the headers just the content
curl_setopt($ch, CURLOPT_HEADER, 0);

// return the value instead of printing the response to browser
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);

// use a user agent to mimic a browser since Facebook blocks pure php calls and does not offer all data in API
curl_setopt($ch, CURLOPT_USERAGENT, 'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.7.5) Gecko/20041107 Firefox/1.0');

// execute the curl command
$xml = curl_exec($ch);

//close the connection
curl_close($ch);
echo $xml;


?>