<?php
// *******************************
// TYPO3 includes for Flash Remoting
// This script is made by A Borg, based on Kasper's index_ts.php.
// *******************************


// *******************************
// Set error reporting
// *******************************
error_reporting (E_ALL ^ E_NOTICE);

// *******************************
// Typo3 remoting config
// *******************************




define('RELAY_HOST','localhost');
//define('RELAY_PORT','8801');
//define('RELAY_SERVER','http://www.xxx.com/typo3conf/ext/remoting_relay/xxx_8801.php');//Used for restarting server


// ******************
// Constants defined
// ******************

//require_once('../typo3_remoting_config.php');	

define('PATH_thisScript',str_replace('//','/', str_replace('\\','/', (php_sapi_name()=='cgi'||php_sapi_name()=='isapi' ||php_sapi_name()=='cgi-fcgi')&&($_SERVER['ORIG_PATH_TRANSLATED']?$_SERVER['ORIG_PATH_TRANSLATED']:$_SERVER['PATH_TRANSLATED'])? ($_SERVER['ORIG_PATH_TRANSLATED']?$_SERVER['ORIG_PATH_TRANSLATED']:$_SERVER['PATH_TRANSLATED']):($_SERVER['ORIG_SCRIPT_FILENAME']?$_SERVER['ORIG_SCRIPT_FILENAME']:$_SERVER['SCRIPT_FILENAME']))));//generates /www/cms.elevated.to/elevated/typo3conf/ext/flashremoting/gateway.php 

$ss = split('typo3conf',PATH_thisScript);

define('PATH_site',$ss[0]);// '/www/cms.elevated.to/elevated/'

//getcwd() //generates /usr/local/home/httpd/cms.elevated.to/elevated/typo3conf/ext/mus/remoting
//define('PATH_site', '/www/cms.elevated.to/elevated/');

define('TYPO3_OS', stristr(PHP_OS,'win')&&!stristr(PHP_OS,'darwin')?'WIN':'');
define('TYPO3_MODE','FE');




//$TYPO3_MISC['microtime_start'] = microtime();
define('PATH_t3lib', PATH_site.'t3lib/');
define('PATH_tslib', PATH_site.'tslib/');
define('PATH_typo3conf', PATH_site.'typo3conf/');
define('TYPO3_mainDir', PATH_site.'typo3/');		// This is the directory of the backend administration for the sites of this TYPO3 installation.

if (!@is_dir(PATH_typo3conf))	die('Cannot find configuration. You need to set PATH_site relative to your site. And if you are using remoting_relay the port and host.');


// *********************
// DIV Library included
// *********************


// *********************
// Timetracking started
// *********************
require_once(PATH_t3lib.'class.t3lib_timetrack.php');
$GLOBALS['TT'] = $TT = new t3lib_timeTrack;
$TT->start();
$TT->push('','Script start');


// *********************
// DIV Library included
// *********************
$TT->push('Include class t3lib_db, t3lib_div, t3lib_extmgm','');
	require(PATH_t3lib.'class.t3lib_div.php');
	require(PATH_t3lib.'class.t3lib_extmgm.php');
$TT->pull();


//require(PATH_t3lib.'class.t3lib_div.php');
//require(PATH_t3lib.'class.t3lib_extmgm.php');

//$error = array("errortype"=>2,"errormsg"=>"Flash remoting extension not installed."); 
//	return $error; 


$CLIENT=t3lib_div::clientInfo();				// Set to the browser: net / msie if 4+ browsers
//require_once(PATH_t3lib.'class.t3lib_timetrack.php');
//$GLOBALS['TT'] =$TT=  new t3lib_timeTrack;
//$TT->start();







// **********************
// Include configuration
// **********************
global $TT,$TYPO3_CONF_VARS,$TYPO3_LOADED_EXT,$T3_VAR,$EXEC_TIME,$SIM_EXEC_TIME,$LANG,$LOCAL_LANG,$TYPO3_DB,$TYPO_VERSION;//must define all globals as such here...else they will be lost. Borg

require(PATH_t3lib.'config_default.php');

/*
Issue here with two sets of cached files and only half of the info in the remoting one!!
Why? 
Explains why !t3lib_extMgm::isLoaded('cms')) doesnt work for instance


The cache prefix is determined by PATH_site and TYPO_VERSION and in the normal html version 
define('PATH_site', dirname(PATH_thisScript).'/');

if (intval($TYPO3_CONF_VARS['EXT']['extCache'])==1)	$cacheFilePrefix.= '_ps'.substr(t3lib_div::shortMD5(PATH_site.'|'.$GLOBALS['TYPO_VERSION']),0,4);

That script didn't have access to the global variable TYPO_VERSION because it wasnt set as global above.
Careful with that!

*/

global $TT,$TYPO3_CONF_VARS,$TYPO3_LOADED_EXT,$T3_VAR,$EXEC_TIME,$SIM_EXEC_TIME,$LANG,$LOCAL_LANG,$TYPO3_DB;//must define all globals as such here...else they will be lost. Borg






// the name of the TYPO3 database is stored in this constant. Here the inclusion of the config-file is verified by checking if this var is set.
//if (!t3lib_extMgm::isLoaded('cms'))	die('<strong>Error:</strong> The main frontend extension "cms" was not loaded. Enable it in the extension manager in the backend.'); //doesnt work with remoting

require(PATH_t3lib.'class.t3lib_db.php');
$GLOBALS['TYPO3_DB'] = $TYPO3_DB = t3lib_div::makeInstance('t3lib_DB');

// *******************************
// Checking environment
// *******************************
if (t3lib_div::int_from_ver(phpversion())<4000006)	die ('TYPO3 runs with PHP4.0.6+ only');

if (isset($_POST['GLOBALS']) || isset($_GET['GLOBALS']))	die('You cannot set the GLOBALS-array from outside the script.');
if (!get_magic_quotes_gpc())	{
	t3lib_div::addSlashesOnArray($_GET);
	t3lib_div::addSlashesOnArray($_POST);
	$HTTP_GET_VARS = $_GET;
	$HTTP_POST_VARS = $_POST;
}
// *********************
// Libraries included
// *********************

//require_once(PATH_tslib.'class.tslib_fe.php');
//require_once(PATH_t3lib.'class.t3lib_page.php');
//require_once('class.flashremoting_userauth.php');

//require_once(PATH_t3lib.'class.t3lib_tstemplate.php');
//require_once(PATH_t3lib.'class.t3lib_cs.php');
require_once('class.flashremoting_base.php');

 //Check if remoting is installed otherwise die
if(!t3lib_extMgm::isLoaded('flashremoting')){
	die;
}


// ***********************************
// Connecting to database
// ***********************************
$TYPO3_DB->link = mysql_pconnect(TYPO3_db_host, TYPO3_db_username,TYPO3_db_password);
mysql_select_db(TYPO3_db);



$GLOBALS['TYPO3_CONF_VARS']['SYS']['doNotCheckReferer'] = true;//this is to enable login from different places via remoting

// *********
// FE_USER
// *********
$GLOBALS['R_SQL'] ='';
if ($_COOKIE['fe_typo_user']) {	
	require_once('class.flashremoting_feuserauth.php');
	if($GLOBALS['FE_USER'] == null){
		$GLOBALS['FE_USER'] = t3lib_div::makeInstance('flashremoting_feuserauth');
	}
	flashremoting_base::initFEuser();
}



// *********
// BE_USER
// *********

if ($_COOKIE['be_typo_user']) {		// If the backend cookie is set, we proceed and checks if a backend user is logged in.
	
	require_once (PATH_t3lib.'class.t3lib_befunc.php');
	require_once ('class.flashremoting_beuserauth.php');
	if($GLOBALS['BE_USER'] == null){
		$GLOBALS['BE_USER'] =  t3lib_div::makeInstance('flashremoting_beuserauth');	// New backend user object
	}
	flashremoting_base::initBEuser();

}


// ********************
// Finish timetracking
// ********************
$TT->pull();

?>