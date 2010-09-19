<?php
	/**
	 * SWX Configuration file
	 * 
	 * Author: Aral Balkan. Copyright (c) 2007 Aral Balkan.
	 * 
	 * Change the configuration parameters here if you want to
	 * customize your deployment.
	 *  
	 * Licensed under the Creative Commons GNU GPL License. 
	 *
	 * @author Aral Balkan
	 **/

	// Service Path: Put your service classes in this folder.
	// Is relative to the SWX gateway (swx.php).	
	//$servicesPath = "/www/htdocs/dev.typoflash.net/typo3conf/ext/typoflash/remoting/";
	//$servicesPath = "../";
	$servicesPath = dirname(dirname(__FILE__)).'/';
	// Allow any domain to access the data SWFs from the SWX gateway? 
	// If you set this to false, you will only be able to call the 
	// SWX gateway from SWFs that reside on exactly the same domain
	// (not even subdomains are allowed.)
	//
	// TODO: Allow user to specify a domain (or domains) to allow by 
	// providing URLs.
	$allowDomain = true;
	
	// How much to compress the returned SWF files. Values range from
	// 0 (no compression) to 9 (maximum compression). The default 
	// compression level is 4. Higher levels of compression may result in
	// smaller SWF files but will take longer to process.
	$compressionLevel = 1;
	
	// VO config value is currently only used by Amfphp.
	$voPath = "services/vo/";
	
	// Whether status (non-error) information should be logged to
	// the php error_log. Set this to false for deployments for better
	// performance. Useful during development. 
	define ('LOG_ALL', true)
	
?>