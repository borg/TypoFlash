<?php
	/**
	 * 
	 * SWX thetenwordreview.com API by Carin Campanario and Steve Webster.
	 * 
	 * You can call this API using SWX, Amfphp, JSON and XML-RPC.
	 * 
	 * @author Carin Campanario
	 * @author Steve Webster
	 * @copyright	2007 Aral Balkan. All Rights Reserved. 
	 * @link 	http://thetenwordreview.com
	 * @link 	http://thetenwordreview.com/api
	 * @link 	http://ccampanario.com
	 * @link 	http://dynamicflash.com
	 * @link    mailto://carin@tui.co.uk
	 * @link    mailto://steve@dynamicflash.com
	 * @link 	http://swxformat.org
	 * 
	**/
	
	// Require base service class
	require_once("../BaseService.php");

	/**
	 * SWX thetenwordreview.com API by Carin Campanario & Steve Webster. You can call this API using SWX, Amfphp, JSON and XML-RPC.
	**/
	class TheTenWordReview extends BaseService
	{
	
		/**
		 * Returns the requested number of photos for the specified user.
		 * 
		 * @param	API key for thetenwordreview.com. Required.
		 * @param 	The username of the user you want reviews by. Optional - defaults to all users.
		 * @param	The category that you want reviews for Optional - defaults to all categories.
		 * @param	The subject that you want reviews for. Optional - defaults to all subjects.
		 * @param	The number of reviews you want returned. Max 30. Optional - defaults to 10.
		 * @param	The order in which you want reviews returned. Can be either 'p' for popularity
		 *          or 'd' for date. Defaults to an API-determined order dependant on the other 
		 *          parameters.
		 *
		 * @return An array of reviews matching the specified criteria.
		 * @author Carin Campanario
		 * @author Steve Webster
		 * 
		 * output: 
		**/
		function getReviews ($key, $user = NULL, $cat = NULL, $review = NULL, $num = NULL, $order = NULL)
		{
			$url = 'thetenwordreview.com/api/reviews/get';

			$vars = array(
				'output' => 'php',
				'key' => $key,
				'user' => $user,
				'cat' => $cat,
				'review' => $review,
				'num' => $num,
				'order' => $order
			);

			$response = $this->_phpCall($url, $vars, 'GET');

			return $response;
		}
	}
	
?>