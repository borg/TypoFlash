<?php
	/**
	 * The Nabaztag API. Sends messages and commands to a Nabaztag bunny. Initially created at Yahoo! Hack Day London.
	 * 
	 * @author Aral Balkan
	 **/

	require_once("../BaseService.php");
	
	class Nabaztag extends BaseService
	{
		// Replace these with your own serial
		// number and token from nabaztag.com.
		var $sn = "0013d384686d";
		var $token = "1182055607";

		// URL for the Nabaztag API endpoint.
		var $url = "http://api.nabaztag.com/vl/FR/api.jsp";
		
		/**
		 * Sends a message for a Nabaztag bunny to speak.
		 * 
		 * If you call this method without sending a serial number and token, it will use the
		 * serial number and token defined in the service class. For the service class on the
		 * SWX public gateway, this means that Aral's bunny will speak it. (Really, so be nice!) :)
		 * 
		 * @param (str) Message to speak.
		 * @param (str, optional) Voice (English voices are: graham22s, lucy22s, heather22k, ryan22k, aaron22s, laura22s). Defaults to heather22k.
		 * @param (str, optional) Serial number of the bunny you want to send the message to.
		 * @param (str, optional) Token for the bunny you want to send the message to.
		 *
		 * @return Nabaztag response.
		 * @author Aral Balkan
		 **/
		function talk ($tts, $voice = NULL, $sn = NULL, $token = NULL)
		{			
			$args = array('tts' => $tts, 'voice' => $voice);
			
			return $this->_bunnyCall(&$args, $sn, $token);			
		}
		
		/**
		 * Moves the bunny's left ear.
		 * 
		 * @param (int) Position to move ear to (0-16)
		 * @param (str, optional) Serial number of the bunny you want to send the message to.
		 * @param (str, optional) Token for the bunny you want to send the message to.
		 *
		 * @return Nabaztag response.
		 * @author Aral Balkan
		 **/
		function moveLeftEar($pos, $sn = NULL, $token = NULL)
		{
			$args = array('posleft' => $pos);

			return $this->_bunnyCall(&$args, $sn, $token);						
		}

		/**
		 * Moves the bunny's right ear.
		 * 
		 * @param (int) Position to move ear to (0-16)
		 * @param (str, optional) Serial number of the bunny you want to send the message to.
		 * @param (str, optional) Token for the bunny you want to send the message to.
		 *
		 * @return Nabaztag response.
		 * @author Aral Balkan
		 **/
		function moveRightEar($pos, $sn = NULL, $token = NULL)
		{
			$args = array('posright' => $pos);

			return $this->_bunnyCall(&$args, $sn, $token);						
		}		
		
		/**
		 * Moves both ears.
		 * 
		 * @param (int) Position to move the left ear to (0-16)
		 * @param (int) Position to move the right ear to (0-16)
		 * @param (str, optional) Serial number of the bunny you want to send the message to.
		 * @param (str, optional) Token for the bunny you want to send the message to.
		 *
		 * @return Nabaztag response.
		 * @author Aral Balkan
		 **/
		function moveBothEars($posLeft, $posRight, $sn = NULL, $token = NULL)
		{
			$args = array('posleft' => $posLeft, 'posright' => $posRight);

			return $this->_bunnyCall(&$args, $sn, $token);						
		}


		/**
		 * Choreograph a combination of ear and led movements. (See http://help.nabaztag.com/fiche.php?langue=3&fiche=29#none for an explanation of the choreography language.) Here's a sample choreography from the API docs: 10,0,motor,1,20,0,0,0,led,2,0,238,0,2,led,1,250,0,0,3,led,2,0,0,0
		 * 
		 * @param (str) Choreography.
		 * @param (str, optional) Title of the choreography.
		 * @param (str, optional) Serial number of the bunny you want to send the message to.
		 * @param (str, optional) Token for the bunny you want to send the message to.
		 *
		 * @return Nabaztag response.
		 * @author Aral Balkan
		 **/
		function choreograph($chor, $chorTitle = '', $sn = NULL, $token = NULL)
		{
			$args = array('chor' => $chor, 'chorTitle' => $chorTitle);

			return $this->_bunnyCall(&$args, $sn, $token);						
		}		
		
					
		function _bunnyCall(&$args, $sn = NULL, $token = NULL)
		{
			$sn = ($sn == NULL) ? $this->sn : $sn;
			$token = ($token == NULL) ? $this->token : $token;
			
			$args['sn'] = $sn;
			$args['token'] = $token;

			$result = $this->_call($this->url, $args);
			return $result;
		}
	}

?>