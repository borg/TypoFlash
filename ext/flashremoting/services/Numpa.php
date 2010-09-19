<?php
	/**
	 * 
	 * SWX Numpar API by Folkert Hielema using BaseClass by Aral Balkan.
	 * 
	 * You can call this API using SWX, Amfphp, JSON and XML-RPC.
	 * 
	 * @author	Folkert	Hielema
	 * @copyright	2007 Nederflash. All Rights Reserved. 
	 * @link 	http://swapdepths.nl
	 * @link 	http://swxformat.org
	 * 
	**/
	
	// Require base service class
	require_once("../BaseService.php");

	/**
	 * SWX Numpa API by Folkert Hielema. You can call this API using SWX, Amfphp, JSON and XML-RPC.
	**/
	class Numpa extends BaseService
	{
		
		/**
		 * Returns 10 latest public messages.
		 *
		 * @param	(required)	String - Username for your Numpa account
		 * @param	(required)	String - Password for your Numpa account
		 * @param	(optional)	Int - Amount of messages min:1, max:30 default is 10
		 * @param	(optional)	Int - with or without comments 0 (off) or 1 (on) default is 0 (off)
		 * @return Array of public update messages.
		 * @author Folkert Hielema
		 **/
		function publicMessages($user = "", $pass = "", $amount = 10, $comments = 0)
		{
			if($amount>30) $amount = 30;
			else if($amount<1) $amount = 1;
			else $amount = (is_int($amount)) ? $amount : 10;
			
			$result = $this->_getMessages( $user, $pass, "public", $amount, $comments);
			return $result;
		}
		
		/**
		 * Returns 10 latest user messages.
		 *
		 * @param	(required)	String - Username for your Numpa account
		 * @param	(required)	String - Password for your Numpa account
		 * @param	(optional)	Int - Amount of messages min:1, max:30 default is 10
		 * @param	(optional)	Int - with or without comments 0 (off) or 1 (on) default is 0 (off)
		 * @return Array of user statuses.
		 * @author Folkert Hielema
		 **/
		function userMessages($user = "", $pass = "", $amount = 10, $comments = 0)
		{
			if($amount>30) $amount = 30; //max
			else if($amount<1) $amount = 1; //min
			else $amount = (is_int($amount)) ? $amount : 10;
			
			$result = $this->_getMessages( $user, $pass, "user", $amount, $comments);
			return $result;
		}
		
		/**
		 * Returns 10 latest friends messages.
		 *
		 * @param	(required)	String - Username for your Numpa account
		 * @param	(required)	String - Password for your Numpa account
		 * @param	(optional)	Int - Amount of messages min:1, max:30 default is 10
		 * @param	(optional)	Int - with or without comments 0 (off) or 1 (on) default is 0 (off)
		 * @return Array of friends update messages.
		 * @author Folkert Hielema
		 **/
		function friendsMessages($user = "", $pass = "", $amount = 10, $comments = 0)
		{
			if($amount>30) $amount = 30;
			else if($amount<1) $amount = 1;
						
			$result = $this->_getMessages( $user, $pass, "friends", $amount, $comments);
			return $result;
		}
		/**
		 * send the message to numpa only
		 * @param	(required)	String - Username for your Numpa account
		 * @param	(required)	String - Password for your Numpa account
		 * @param	(required)	String - The message to send
		 * @param	(optional)	String - Location from where the message is posted
		 * @param 	(optional) 	Int - Should numpa save your location ? 1=yes 0=no (no is default)
		 *
		 * @return Array - [ 	status (type: string, waarde: ok or failed),
		 * 						msg (type: string) errormessage only if status = failed)
		 * 				   ]
		 * 						
		 **/
		function postMessage( $user = "", $pass = "", $message = "", $location = "", $storeLocation = 0)
		{
			$result = $this->_post( $user, $pass, $message, $location , $storeLocation);
			return $result;
		}
		
		/**
		 * send the message to numpa only
		 * @param	(required)	String - Username for your Numpa account
		 * @param	(required)	String - Password for your Numpa account
		 * @param	(required)	String - The message to send
		 * @param	(optional)	String - Location from where the message is posted
		 * @param 	(optional) 	Int - Should numpa save your location ? 1=yes 0=no (no is default)
		 * @param 	(optional) 	Int - Also post to Twitter 1=yes, 0=no (no is default) 
		 * @param   (optional)  Int - Also post to Jaiku 1=yes, 0=no (no is default) 
		 * 
		 * @return Array - [ 	status (type: string, waarde: ok or failed),
		 * 						msg (type: string) errormessage only if status = failed),
		 * 						twitter (type: string, waarde: ok of failed) post to twitter result
								jaiku (type: string, waarde: ok of failed) post to Jaiku result
		 * 				   ]
		 * 						
		 **/
		function postAdvancedMessage( $user = "", $pass = "", $message = "", $location = "", $storeLocation = 0,$postToTwitter=0,$postToJaiku=0 )
		{
			$result = $this->_post( $user, $pass, $message, $location , $storeLocation, $postToTwitter,$postToJaiku);
			return $result;
		}
		
		/**
		 * Private method Returns 10 messages, three methods to reflect public, user or friends.
		 * @return Array of statuses.
		 * */
		function _getMessages( $user, $pass, $type, $amount, $comments )
		{
			$url = "numpa.nl/api/json.lasso";

			$vars = array(	"method" => "Messages.Latest", "username" => $user, "password" => $pass,
							"type" => $type, "amount"=> $amount, "comments"=> $comments	);
			
			return $this->_jsonCall($url, $vars, "POST");
		}
		
		/**
		 * private method for sending posts to numpa helps the post Methods above
		 * @param	(required)	String - Username for your Numpa account
		 * @param	(required)	String - Password for your Numpa account
		 * @param	(required)	String - The message to send
		 * @param	(optional)	String - Location from where the message is posted
		 * @param 	(optional) 	Int - Should numpa save your location ? 1=yes 0=no (no is default)
		 * @param 	(optional) 	Int - Also post to Twitter 1=yes, 0=no (no is default) 
		 * @param   (optional)  Int - Also post to Jaiku 1=yes, 0=no (no is default) 
		 */
		function _post( $user, $pass, $message, $location = "", $storeLocation = 0, $postToTwitter = 0, $postToJaiku = 0 )
		{
			$url = "numpa.nl/api/json.lasso";
			$location = $location." via SWX Numpa";
			$vars = array(	"method" => "Message.Post", "username" => $user, "password" => $pass,
							"message" => $message, "location"=> $location, "storeLocation"=> $storeLocation,
							"postToTwitter" => $postToTwitter, "postToJaiku"=>$postToJaiku);
			
			return $this->_jsonCall($url, $vars, "POST");
		}
	}
?>