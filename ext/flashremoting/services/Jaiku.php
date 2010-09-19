<?php
	/**
	 * 
	 * SWX Jaiku API by Aral Balkan and Folkert Hielema.
	 * 
	 * You can call this API using SWX, Amfphp, JSON and XML-RPC.
	 * 
	 * @author	Aral Balkan, Folkert Hielema
	 * @copyright	2007 Aral Balkan. All Rights Reserved. 
	 * @link 	http://aralbalkan.com
	 * @link 	http://swxformat.org
	 * @link    mailto://aral@aralbalkan.com
	 * 
	**/
	
	// Require base service class
	require_once("../BaseService.php");

	/**
	 * SWX Jaiku API by Aral Balkan and Folkert Hielema. You can call this API using SWX, Amfphp, JSON and XML-RPC.
	**/
	class Jaiku extends BaseService
	{
		//
		// Official Jaiku API methods: These implement the Jaiku API exactly.
		// See http://devku.org/docs for the full official documentation.
		//
		
		/**
		 * Returns up to date user info.
		 * 
		 * Authentication is not required. 
		 *
		 * @param (str) The user name to get the information entry for.
		 * 
		 * @return User information. 
		 * @author Folkert Hielema
		 **/
		function currentPresence( $userName )
		{
			$url = $userName.'.jaiku.com/presence/json';
			$response = $this->_jsonCall($url, NULL, 'POST');
			
			return $response;
		}
		
		/**
		 * Returns entries from public timeline.
		 * 
		 * Authentication is not required.
		 *  
		 * @return Public entries.
		 * @author Folkert Hielema
		 **/
		function publicStream()
		{
			$url = 'jaiku.com/feed/json';
			$responce = $this->_jsonCall($url, NULL, 'POST');
			return $responce;
		}
		
		/**
		 * Returns latest updates from User.
		 * 
		 * Authentication is not required. 
		 *
		 * @param (str) The user name to get the latest entries for.
		 * 
		 * @return users latest entrys. 
		 * @author Folkert Hielema
		 **/
		function userStream($userName)
		{
			$url = $userName.'.jaiku.com/feed/json';
			$responce = $this->_jsonCall($url, NULL, 'POST');
			return $responce;
		}
		
		/**
		 * Returns latest updates from user's contacts.
		 * 
		 * Authentication required. 
		 * 
		 * @param (str) The user name for authentication.
		 * @param (str) The user key for authentication.
		 * 
		 * @return Authenticated user latest contacts entrys. 
		 * @author Folkert Hielema
		 **/
		function contactsStream($userName, $apikey)
		{
			$url = $userName.'.jaiku.com/contacts/feed/json';
			$vars = array( "user"=>$userName, "personal_key"=>"".$apikey );
			$responce = $this->_jsonCall($url, $vars, 'POST');
			return $responce;
			
		}
		
		/**
		 * Returns the last stream entry from given user. Differs from currentPresence for it returns additional info.
		 * 
		 * Authentication is not required. 
		 *
		 * @param (str) The user name to get the last public stream entry for.
		 * 
		 * @return The last stream entry. 
		 * @author Aral Balkan
		 **/
		function lastStreamEntry($userName)
		{
			$url = $userName.'.jaiku.com/presence/last/json';
			$responce = $this->_jsonCall($url, NULL, 'POST');
			return $responce;
		}
		
		/**
		 * Returns the last indiviual stream entry for given item and user.
		 * 
		 * Authentication is not required. 
		 *
		 * @param (str) The user name to get the last public stream entry for.
		 * @param (str) The item id for which to get the update.
		 * @return The last individual stream entry for given user and item. 
		 * @author Folkert Hielema
		 **/
		function lastIndividualStreamEntry($userName, $item)
		{
			$url = $userName.'.jaiku.com/presence/'.$item.'/json';
			$responce = $this->_jsonCall($url, NULL, 'POST');
			return $responce;
		}
		
		/**
		 * Returns up to date user info.
		 * 
		 * Authentication is not required. 
		 *
		 * @param (str) The user name to get the information entry for.
		 * 
		 * @return User information. 
		 * @author Folkert Hielema
		 **/
		function userInformation($userName)
		{
			$url = $userName.'.jaiku.com/json';
			$responce = $this->_jsonCall($url, NULL, 'POST');
			return $responce;
		}
		
		/**
		 * Sends a presence update. Returns 'ok' on success or the corresponding error message.
		 * 
		 * Authentication required. 
		 *
		 * @param (str) (required) The user name.
		 * @param (str) (required) API key (you can get the api key when logged on at http://api.jaiku.com/).
		 * @param (str) (required) The message to send. Will be truncated after 140 characters.
		 * @param (int) (optional) The id of the icon to associate with this update (default is 300).
         * @param (str) (optional) Your location. Can handle neighbourhood, city, country.
		 * @return 'ok' on success else corresponding error message. 
		 * @author Folkert Hielema
		 **/
		 /**
		  * TODO: get more info on the 'generated' settings and find out why true does not work.
		  */
		 function sendPresence( $userName, $apikey, $message , $location = "", $icon= 300)
		 {
		 	$url = 'api.jaiku.com/json';
		 	
		 	$vars = array(	"method" => "presence.send",
							"user" => $userName, "personal_key" =>$apikey, 
							"generated" => false, "message" => $message,  
							"icon" => $icon, "location"=> $location." via Jaiku SWX"
							);
			
			return $this->_jsonCall($url, $vars, 'POST');
		 }
	}
?>