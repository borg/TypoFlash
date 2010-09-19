<?php

	/**
	 * Simple class that contains methods that return 
	 * various data types.
	 *
	 * @package default
	 * @author Aral Balkan
	 **/
	class Simple
	{
		/**
		 * Echos the passed data as a string, adding 'Echo: '
		 * to the front of it.
		 *
		 * @return string 'hello'
		 * @author Aral Balkan
		 **/
		function echoData($data)
		{
			return $data;
		}
		
		/**
		 * Adds two numbers together.
		 *
		 * @return The sum of the passed arguments
		 * @author Aral Balkan
		 **/
		function addNumbers($n1, $n2)
		{
			return $n1 + $n2;
		}
		
	} // END class 

?>