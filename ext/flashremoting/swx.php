<?php
	/**
	 * PHP implementation of SWX RPC. 
	 * 
	 * This script acts as the endpoint (gateway) for SWX RPC calls. 
	 * It returns a SWX SWF files 
	 *
	 * @author Aral Balkan
	 * @copyright (c) 2007 Aral Balkan
	 * @link http://aralbalkan.com
	 * @link http://swxformat.org
	 * 
	 * Licensed under the Creative Commons GNU GPL License.
	 *  
	 * This gateway handles incoming SWX requests. It instantiates 
	 * the requested service class and calls the requested method 
	 * on the service class instance, passing to it the data
	 * argument (if any).
	 * 
	 **/
	
	// Simple profiling
	function microtime_float()
	{
	    list($usec, $sec) = explode(" ", microtime());
	    return ((float)$usec + (float)$sec);
	}

	// Save start time
	$startTime = microtime_float(); 
	
	// Define E_STRICT if not defined so we don't get errors on PHP 4
	if (!defined('E_STRICT')) define('E_STRICT', 2048);
	
	define('LETTERS_AND_NUMBERS_ONLY', '/[a-zA-Z0-9_]/');
	
	$class = '';
	$method = '';
	$url = '';
	$data = 'array()';
	$debug = false;
		
	// Error handling
	function errorHandler($errorNum, $errorStr, $errorFile, $errorLine)
	{
		$errorMsg = "Error $errorNum: $errorStr in $errorFile, line $errorLine.";
		$GLOBALS['swxLastErrorMessage'] = $errorMsg;
		
		// Display the error message in the PHP error log
		error_log($errorMsg);
		
		$errorObj = array('error' => TRUE, 'code' => $errorNum, 'message' => $errorMsg);
		
		//if ($errorNum == E_ERROR || $errorNum == E_WARNING || $errorNum = E_USER_ERROR)
		// Error num check replaced by code from http://drupal.org/node/11772#comment-18383.
		// This stops PHP5 strict errors from failing a call (e.g., deprecated calls, etc.)
		//if (($errorNum & (E_ALL & E_STRICT) ^ (E_NOTICE & E_STRICT)) || $errorNum = E_USER_ERROR)
		if ($errorNum != E_STRICT && $errorNum != E_NOTICE)
		{			
			// On errors and warnings, stop execution and return the
			// error message to the client. This is a far better
			// alternative to failing silently.
			returnError($errorObj);
		}
	}

	// Error handling (unfortunately has to be global to support PHP 4)
	set_error_handler('errorHandler');

	// Turn on error reporting
	error_reporting(E_ALL);

	// Load the configuration info
	include('swx_config.php');

	// Load and instantiate the SWX Assembler
	include('SwxAssembler.php');
	$swxAssembler = new SwxAssembler();
	
	// Global configuration information
	global $swx;
	$swx = array();
	
	// Change to the service folder from here on.
	// This works exactly like Amfphp to make sure that Amfphp and SWX
	// services are compatible.
	chdir($servicesPath);
	
	/**
	 * Returns a SWX with the passed error message in the result object.
	 *
	 * @param	(str) The error message to return to the client.
	 * 
	 * @return void (exits)
	 * @author Aral Balkan
	 **/
	function returnError($errorObj)
	{
		global $swxAssembler, $debug;
		
		error_log($errorObj['message']);
		$swxAssembler->writeSwf($errorObj, $debug);
		exit();		
	}
	
	/**
	 * Reads parameters from the passed source.
	 *
	 * @param 	array 	Either $_GET or $_POST.
	 * @return 	void
	 * @author 	Aral Balkan
	 **/
	function getParameters($source)
	{
		global $class, $method, $data, $debug, $swxAssembler, $isParameterObject, $url;
				
		// Debug mode?
		if (array_key_exists('debug', $source))
		{
			$debug = ($source['debug'] === 'true');
		}
		else
		{
			// If no debug parameter is passed, debug defaults to false.
			$debug = false;
		}

		// Were any arguments passed?
		if (isset($source['args'])) // if (array_key_exists('args', $source))
		{
			// error_log('[SWX] INFO Arguments: ' . $source['args']);
			$data = $source['args'];
		}

		// Get the class name
		if (isset($source['serviceClass'])) //if (array_key_exists('serviceClass', $source))
		{
			$class = $source['serviceClass'];
		}
		else
		{
			// Error: Service class argument is missing.
			trigger_error('The \'serviceClass\' argument is missing (no class name was supplied)', E_USER_ERROR);
		}

		// Check if service class is null or undefined
		if ($class === "null") trigger_error('The \'serviceClass\' argument is null.', E_USER_ERROR);
		if ($class === "undefined") trigger_error('The \'serviceClass\' argument is undefined.', E_USER_ERROR);

		// Get the method name
		if (isset($source['method'])) // if (array_key_exists('method', $source))
		{
			$method = $source['method'];
		}
		else
		{
			// Error: Method argument is missing.
			trigger_error('The \'method\' argument is missing (no method name was supplied)', E_USER_ERROR);
		}		
		
		// Check if method is null or undefined
		if ($method === "null") trigger_error('The \'method\' argument is null.', E_USER_ERROR);
		if ($method === "undefined") trigger_error('The \'method\' argument is undefined.', E_USER_ERROR);
		
		// TODO: Implement as part of the new security 
		// model in the next Beta. 
		//
		// Get the url that we are being called from 
		// (for cross-domain support)
		if (isset($source['url'])) //(array_key_exists('url', $source))
		{
			$url = urldecode($source['url']);
			
			// Firefox/Flash (at least, and tested only on a Mac), sends 
			// file:/// (three slashses) in the URI and that fails the validation
			// so replacing that with two slashes instead.
			$url = str_replace('///', '//', $url);
			
			if (LOG_ALL) error_log('[SWX] INFO: SWX gateway called from '.$url);
		}
		else
		{
			error_log('[SWX] Warning: No referring URL received from Flash. Cross-domain will not be supported on this call regardless of allowDomain setting.');
		}
		
	}
	
	// Check if the className is supplied as a GET var. If so,
	// we'll use those. Using GET is useful for debugging. 
	//if (isset($_GET['serviceClass'])) // (array_key_exists('serviceClass', $_GET))
	if ($_SERVER['REQUEST_METHOD'] === 'GET')
	{
		// GET
		//error_log('[SWX] INFO Using GET.');
		getParameters($_GET);		
	}
	else
	{
		// POST
		//error_log('[SWX] INFO Using POST.');
		getParameters($_POST);
	}
	
	// Security: Check that only allowed characters are present in the URL.
	require_once('lib/Validate.php');
	$v = new Validate();
	/*
	$options = array 
	(
		'domain_check' => false, 
		'allow_schemes' => array 
		(
			'http', 'https', 'file'
		),
		'strict' => ''
	);
	*/

	$urlValid = $v->uri($url);
	
	if ($urlValid != 1)
	{
		error_log('[SWX] Non-fatal error: URL is not valid. Cross-domain access will not work. ' . $url);
	}
	else
	{
		// URL is valid
		if (LOG_ALL) error_log('[SWX] INFO: The referring URL is valid.');
	}
	
	// Security: Check that only allowed characters are present
	// in the class and method names.
	//$classNameDisallowedCharacters = preg_replace(LETTERS_AND_NUMBERS_ONLY, '', $class);
	$methodNameDisallowedCharacters = preg_replace(LETTERS_AND_NUMBERS_ONLY, '', $method);
	
	//Borg removed this check as it disabled class dot path syntax
	/*if ($classNameDisallowedCharacters !== '')
	{
		// Error: Invalid class name.
		trigger_error("The supplied class name ($class) is invalid (it must only contain letters, numbers, and underscores)", E_USER_ERROR);
	} */
	
	if ($methodNameDisallowedCharacters !== '')
	{
		// Error: Invalid method name.
		trigger_error("The supplied method name ($method) is invalid (it must only contain letters, numbers, and underscores)", E_USER_ERROR);
	}
	
	// Load in the requested class

	//Borg added support for dot syntax and folder structure
	
	$classArr = explode('.',$class);
	
	if(count($classArr)>0){
		$class = array_pop($classArr);
		$classPath = implode('/',$classArr);
		$classPath .='/';
	}else{
		$classPath='';
	}
	

	$classToLoad = $servicesPath .$classPath. $class.'.php';



	if (is_file($classToLoad))
	{
		include($classToLoad);
	}
	else
	{
		// The requested class does not exist. 
		trigger_error('Could not find a class named '.$classToLoad, E_USER_ERROR);
	}
	



	// Instantiate the requested service class and 
	// call the requested method on it, capturing the return value.
	$instance = new $class();
	
	// Security: Check that user is not trying to call a private method	
	if (substr(phpversion(), 0,1) == '4')
	{
		// PHP 4 check
		if (substr($method, 0, 1) === '_' || !method_exists($instance, $method))
		{
			// Error: The requested method either does not exist or is private (PHP 4).
			trigger_error("Could not find a public method in $class called $method(). (Using PHP 4 rules.)", E_USER_ERROR);
		}		
	} 
	else
	{
		// PHP 5 check
		$allowedMethods = get_class_methods($class);
		if (array_search($method, $allowedMethods) === false || substr($method, 0, 1) === '_')
		{
			// Error: The requested method either does not exist or is private (PHP 5).
			trigger_error("Could not find a public method in $class called $method(). (Using PHP 5 rules.)", E_USER_ERROR);
		}		
	}
		
	// Strip slashes in data
	$dataAsPhp = stripslashes($data);
	
	// If the user did not pass an args array, treat it as
	// an empty args array. (Although this may be an error
	// on the client side, it may also be the user calling
	// a method that doesn't take arguments and we shouldn't
	// force the user to create an args parameter with an empty
	// array.)
	if ($dataAsPhp === "undefined") $dataAsPhp = "[]";
	
	// Massage special characters back (is there a better
	// way to do this?)
	$dataAsPhp = str_replace('\\t', '\t', $dataAsPhp);
	$dataAsPhp = str_replace('\\n', '\n', $dataAsPhp);
	$dataAsPhp = str_replace("\\'", "'", $dataAsPhp);

	// Check if there are any undefined values.
	if (strpos($dataAsPhp, 'undefined') !== FALSE)
	{
		// There is at least one undefined argument. This signals an error
		// on the Flash client (you should never pass undefined on purpose, use
		// null for optional arguments); signal the error to the user. 
		$undefinedArgumentIndices = '';
		$numUndefinedArguments = 0;
		
		$arguments = explode(',', $dataAsPhp);
		
		$numArguments = count($arguments);
		for ($i = 0; $i < $numArguments; $i++)
		{
			$currentArgument = $arguments[$i];
			if (strpos($currentArgument, 'undefined'))
			{
				$undefinedArgumentIndices .= ', ' . $i;
				$numUndefinedArguments++;
			}
		}
		
		// Remove the initial comma and space. 
		$undefinedArgumentIndices = substr($undefinedArgumentIndices, 2);
		
		// Make sure the error message is grammatically correct.
		$pluralization = $numUndefinedArguments > 1 ? 's' : '';
		
		$errorMsg = $numUndefinedArguments . ' undefined argument' . $pluralization . ' found at position' . $pluralization . ' ' . $undefinedArgumentIndices . ' for method '.$method.' in class '.$class.'.';
		
		trigger_error($errorMsg, E_USER_ERROR);
	}
	
	// Convert undefined and null to NULL
	//$dataAsPhp = str_replace('undefined', 'NULL', $dataAsPhp);
	$dataAsPhp = str_replace('null', 'NULL', $dataAsPhp);
	
	// Convert the passed JSON data to a PHP array structure.
	// TODO: Add error checking.
	
	// Profiling:
	if (LOG_ALL) $jsonStartTime = microtime_float();
	
	include_once('core/shared/util/JSON.php');
	$j = new Services_JSON();
	$dataAsPhp = $j->decode($dataAsPhp);	
		
	if (LOG_ALL) 
	{
		// Profiling:
		$jsonDuration = microtime_float() - $jsonStartTime;
		error_log("[SWX] PROFILING: JSON parser took $jsonDuration seconds to parse the arguments.");
	}
		
	// Profiling:
	// Service method
	if (LOG_ALL) $methodStartTime = microtime_float();

	// Call the method, passing the array's elements as individual elements.	
	$result = call_user_func_array(array(&$instance, $method),$dataAsPhp);
	
	// Profiling:
	if (LOG_ALL) 
	{
		$methodDuration = microtime_float() - $methodStartTime;
		error_log("[SWX] PROFILING: Method took $methodDuration seconds to return a result.");	

		$duration = microtime_float() - $startTime;
		$swxGatewayOverhead = $duration - $jsonDuration - $methodDuration;
		error_log("[SWX] PROFILING: All other SWX gateway operations took $swxGatewayOverhead seconds.");

		// Debug:
		// error_log ("[SWX] INFO Method call result = $result");	
	
		$swxAssemblerStartTime = microtime_float(); // Reset the timer.
	}
		
	// Create and write out the SWF.
	$swxAssembler->writeSwf($result, $debug, $compressionLevel, $url);

	if (LOG_ALL) 	
	{
		// Profiling:
		$swxCompilerDuration = microtime_float() - $swxAssemblerStartTime;
		$duration = microtime_float() - $startTime; 

		// Status message.
		error_log("[SWX] PROFILING: SWF compiler took $swxCompilerDuration seconds to assemble the data SWF.");
	
		// Call profiling stats:
		$jsonPercentage = round($jsonDuration * 100 / $duration, 0);
		$swxAssemblerPercentage = round($swxCompilerDuration * 100 / $duration, 0);
		$methodPercentage = round($methodDuration * 100 / $duration, 0);
		$otherPercentage = 100 - $jsonPercentage - $swxAssemblerPercentage - $methodPercentage;
		error_log("[SWX] PROFILING: SWX call took $duration seconds in total, of which JSON decoding arguments: $jsonPercentage%, Service method: $methodPercentage%, SWX Data SWF assembly: $swxAssemblerPercentage%, Other: $otherPercentage%.");
	
		// Profiler:
		/*
		error_log("[SWX] PROFILER INFO FOLLOWS:");
		$profileInfo = __profiler__('get');
		foreach ($profileInfo as $functionName => $percentage)
		{
			$inSeconds = round($duration * $percentage / 100, 3);
			error_log("$functionName: $percentage% ($inSeconds seconds)");		
		}
		*/
	}
?>