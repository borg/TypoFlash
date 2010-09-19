<?php	
	$url = trim($_REQUEST['url']); 

    $ch = curl_init(); 

    curl_setopt($ch, CURLOPT_URL, $url); 
    curl_setopt($ch, CURLOPT_HEADER, false); 
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true); 

    $info = curl_exec($ch); 

    if (!preg_match('#var swfArgs = (\{.*?\})#is', $info, $matches)) 
    { 
        echo "Check the YouTube URL : {$_REQUEST['url']} <br/>\n"; 
        die("Couldnt detect swfArgs"); 
    } 

    if (function_exists(json_decode)) # >= PHP 5.2.0 
    { 
        $swfArgs = json_decode($matches[1]); 
        $video_id = $swfArgs->video_id; 
        $tag_t = $swfArgs->t; 
    } 
	else 
	{ 
        preg_match('#"video_id":.*?"(.*?)"#is', $matches[1], $submatches); 
        $video_id = $submatches[1]; 

        preg_match('#"t":.*?"(.*?)"#is', $matches[1], $submatches); 
        $tag_t = $submatches[1]; 
    }

    $response  = '<video>'; 
    $response .= '<id>' . $video_id . '</id>'; 
    $response .= '<t>' . $tag_t . '</t>'; 
    $response .= '</video>'; 

    header("Content-type: text/xml"); 

    echo $response; 

    curl_close($ch);
?>
