<?php
		
	// Include JSON parser from AMFPHP
	require_once('core/shared/util/JSON.php');

	// Include PHP compatibility layer
	require_once('lib/http_build_query.php');

	/**
	 * Base class for services that provides some basic communication methods.
	 *
	 * @package default
	 * @author Aral Balkan
	 **/
	class BaseService
	{
		
		function BaseService()
		{
			
		}

		// 
		// Private methods
		// 
		
		/**
		 * Uses _call to get a response and PHP deserializes it.
		 *
		 * @param	(str) 	URL to hit, without the protocol (e.g. no http://)
		 * @param	(array) (optional) Arguments to send.
		 * @param	(str)	(optional) HTTP transfer type ('POST' or 'GET'). Defaults to GET.
		 * @param	(str)	(optional) Username for basic authentication.
		 * @param	(str)	(optional) Password for basic authentication.
		 * @param	(str)	(optional) Referer URL. 
		 *
		 * @return Decoded JSON result of cURL call.
		 * @author Aral Balkan
		 **/
		function _phpCall($url, $args = NULL, $type = 'GET', $user = NULL, $pass = NULL ,$referer = NULL)
		{
			$response = $this->_call($url, $args, $type, $user, $pass, $referer);
			
			// Deserialize the returned serialized PHP value
			$response = unserialize($response);
			
			return $response;
		}

		// 
		// Private methods
		// 
		
		/**
		 * Uses _call to get a response and JSON decodes it.
		 *
		 * @param	(str) 	URL to hit, without the protocol (e.g. no http://)
		 * @param	(array) (optional) Arguments to send.
		 * @param	(str)	(optional) HTTP transfer type ('POST' or 'GET'). Defaults to GET.
		 * @param	(str)	(optional) Username for basic authentication.
		 * @param	(str)	(optional) Password for basic authentication.
		 * @param	(str)	(optional) Referer URL. 
		 *
		 * @return Decoded JSON result of cURL call.
		 * @author Aral Balkan
		 **/
		function _jsonCall($url, $args = NULL, $type = 'GET', $user = NULL, $pass = NULL ,$referer = NULL)
		{
			$response = $this->_call($url, $args, $type, $user, $pass, $referer);
			
			// Decode the returned JSON value
			$j = new Services_JSON();
			$response = $j->decode($response);
			
			return $response;
		}
		
		/**
		 * Makes a cURL call and returns the result.
		 * 
		 * @param	(str) 	URL to hit, without the protocol (e.g. no http://)
		 * @param	(array) (optional) Arguments to send.
		 * @param	(str)	(optional) HTTP transfer type ('POST' or 'GET'). Defaults to GET. Case-insenstive.
		 * @param	(str)	(optional) Username for basic authentication.
		 * @param	(str)	(optional) Password for basic authentication.
		 * @param	(str)	(optional) Referer URL. 
		 *
		 * @return Result of the cURL call.
		 * @author Aral Balkan
		 **/
		function _call($url, $args = NULL, $type = 'GET', $user = NULL, $pass = NULL ,$referer = NULL)
		{
			// Make HTTP transfer type argument case-insenstive. 
			$type = strtoupper($type);
			
			// If arguments have been passed, create a URL-encoded string from them.
			if ($args !== NULL)
			{
				// Remove null arguments, if any. It's easier to do this
				// here than to have to use conditional logic throughout all the 
				// various business methods.
				foreach($args as $key => $value)
				{
					if ($value === NULL)
					{
						// error_log('Unsetting '.$key.' (was null).');
						unset($args[$key]);
					}
				}
				
				// If there are any arguments left, build the HTTP query string.
				if (count($args) > 0)
				{
					$args = http_build_query($args);
				}
				else
				{
					$args = NULL;
				}
			}

			// Added from Wouter's socket version. This makes
			// sure that the URL doesn't begin with the http://
			// protocol.
			if(strpos($url, "http://") === 0) $url = substr($url, 7);
			
			// Initialize response.
			$response = NULL;

			// If cURL exists, use it. Otherwise, fall back on a 
			// socket connection to retreive the data. Socket code
			// contributed by Wouter Verweirder (http://aboutme.be).
			if(function_exists('curl_init'))
			{
				// Use cURL.
				
				// error_log("[SWX Twitter API] INFO: Using cURL.");
				
				
				// Initialize cURL object
				$ch = curl_init();

				// If arguments exist, add them according to whether the
				// transfer method is GET or POST.
				if ($args !== NULL)
				{
					if ($type == 'GET')
					{
						// GET
						$url = $url.'?'.$args;
						// error_log('GET url = '.$url);
					}
					else
					{
						// POST
						if ($args !== NULL)
						{
							curl_setopt($ch, CURLOPT_POSTFIELDS, $args);
						}
					}
				}
			
				$url = 'http://'.$url;
			
				// error_log('Final url = '.$url);
			
				curl_setopt($ch, CURLOPT_URL, $url);
				curl_setopt($ch, CURLOPT_USERAGENT, "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)");
				curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
				curl_setopt($ch, CURLOPT_TIMEOUT, 120);
				curl_setopt ($ch, CURLOPT_FOLLOWLOCATION, 1);

				// Do we need to add basic authentication?
				if ($user !== NULL)
				{
					curl_setopt($ch, CURLOPT_USERPWD, $user.':'.$pass);
				}
			
				// Has a referer been set?
				if ($referer !== NULL)
				{
					curl_setopt ($ch, CURLOPT_REFERER, $referer);
				}

				$response = curl_exec($ch);     
						
				//error_log('Raw cURL response: '.$response);
			}
			else
			{
				// error_log("[SWX Twitter API] INFO: Using non-cURL socket connection.");
				
				// cURL does not exist: Use socket connection. 
				// Socket fallback code by Wouter Verweirder 
				// (http://aboutme.be).
				
				// TODO: Refactor to fit with the coding convensions
				// in the rest of the class. 
				
				//get the host name out of the url
				$url_split = split('/', $url);
				$hostname = $url_split[0];
				
				//open a socket
				$da = fsockopen($hostname, 80, $errno, $errstr, 120);
				
				//raw http request variable
				$httprequest = "";
				
				//get or post request header
				if ($type == 'GET') 
				{
					$httprequest .= 'GET http://'.$url." HTTP/1.1\r\n";
				}
				else
				{
					$httprequest .= 'POST http://'.$url." HTTP/1.1\r\n";
				}
				
				$httprequest .= "User-Agent: Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)\r\n";
				$httprequest .= "Host: $hostname\r\n";
				if (!empty($referer)) $httprequest .= "Referer: $referer\r\n";
				
				//additional headers for POSTS
				if ($type != 'GET')
				{
					$httprequest .= "Content-Type: application/x-www-form-urlencoded\r\n";
					$httprequest .= "Content-Length: ".strlen($args)."\r\n";
				}
				
				//authentication header
				if(!empty($user) && !empty($pass))
				{
					$httprequest .= "Authorization: Basic ".base64_encode($user.":".$pass)."\r\n";
				}
				
				$httprequest .= "Connection: close\r\n\r\n";
				
				//Add the post variables to the request
				if($type != 'GET')
				{
					$httprequest .= $args;
				}
				
				//output the raw http request
				fwrite($da, $httprequest);
				
				//process the response
				$response = '';
				while (!feof($da)) $response.=fgets($da, 128);
				
				$response=split("\r\n\r\n",$response);
				$header=$response[0];
				$responsecontent=$response[1];
				if(!(strpos($header,"Transfer-Encoding: chunked")===false))
				{
					$aux=split("\r\n",$responsecontent);
					for($i=0;$i<count($aux);$i++) if($i==0 || ($i%2==0)) $aux[$i]="";
					$responsecontent = implode("",$aux);
				}
				
				$response = $responsecontent;
				
			}
			
			return $response;
		}


		/**
		 * Returns an error object.
		 *
		 * @return Array with 'error' and 'errorMessage' indices.
		 * @author Aral Balkan
		 **/
		function _error($errorMessage)
		{
			error_log($errorMessage);
			$response = array('error' => true, 'errorMessage'=>$errorMessage);
			return $response;
		}
	}
?>