<?php
/***************************************************************
A. Borg
2005
borg@elevated.to
Version of Kasper's

15/07/2006
I have removed the ipLockClause call for remoting, cause I think remoting calls either dont generate the same IP as 
for html calls, or none...if in the future a need for ipLockClause should arise you will need to investigate and modify
as required. For now, I can't see why its such a big deal.
/****************************************************************/




	// Need this for parsing User TSconfig
require_once (PATH_t3lib.'class.t3lib_tsparser.php');




/**
 * TYPO3 user authentication, backend
 * Could technically have been the same class as t3lib_userauthgroup since these two are always used together and only together.
 * t3lib_userauthgroup contains most of the functions used for checking permissions, authenticating users, setting up the user etc. This class is most interesting in terms of an API for user from outside.
 * This class contains the configuration of the database fields used plus some functions for the authentication process of backend users.
 *
 * @author	Kasper Skaarhoj <kasperYYYY@typo3.com>
 * @package TYPO3
 * @subpackage t3lib
 */
class flashremoting_beuserauth {

	/*
	From t3lib_userauth
	*/

	var $global_database = '';		// Which global database to connect to

	var $get_name = '';				// Session/GET-var name

	var $gc_time  = 24;               	// GarbageCollection. Purge all session data older than $gc_time hours.
	var $gc_probability = 1;			// Possibility (in percent) for GarbageCollection to be run.
	var $writeStdLog = 0;					// Decides if the writelog() function is called at login and logout
	var $writeAttemptLog = 0;				// If the writelog() functions is called if a login-attempt has be tried without success
	var $sendNoCacheHeaders = 1;		// If this is set, headers is sent to assure, caching is NOT done
	var $getFallBack = 0;				// If this is set, authentication is also accepted by the $_GET. Notice that the identification is NOT 128bit MD5 hash but reduced. This is done in order to minimize the size for mobile-devices, such as WAP-phones
	var $hash_length = 32;				// The ident-hash is normally 32 characters and should be! But if you are making sites for WAP-devices og other lowbandwidth stuff, you may shorten the length. Never let this value drop below 6. A length of 6 would give you more than 16 mio possibilities.
	var $getMethodEnabled = 0;			// Setting this flag true lets user-authetication happen from GET_VARS if POST_VARS are not set. Thus you may supply username/password from the URL.
	var $lockIP = 4;					// If set, will lock the session to the users IP address (all four numbers. Reducing to 1-3 means that only first, second or third part of the IP address is used).
	var $lockHashKeyWords = 'useragent';	// Keyword list (commalist with no spaces!): "useragent". Each keyword indicates some information that can be included in a integer hash made to lock down usersessions.

	var $warningEmail = '';				// warning -emailaddress:
	var $warningPeriod = 3600;			// Period back in time (in seconds) in which number of failed logins are collected
	var $warningMax = 3;				// The maximum accepted number of warnings before an email is sent
	var $checkPid=1;					// If set, the user-record must $checkPid_value as pid
	var $checkPid_value=0;				// The pid, the user-record must have as page-id

		// Internals
	var $id;							// Internal: Will contain session_id (MD5-hash)
	var $cookieId;						// Internal: Will contain the session_id gotten from cookie or GET method. This is used in statistics as a reliable cookie (one which is known to come from $_COOKIE).
	var $loginSessionStarted = 0;		// Will be set to 1 if the login session is actually written during auth-check.

	var $user;							// Internal: Will contain user- AND session-data from database (joined tables)
	var $get_URL_ID = '';				// Internal: Will will be set to the url--ready (eg. '&login=ab7ef8d...') GET-auth-var if getFallBack is true. Should be inserted in links!

	var $forceSetCookie=0;				// Will force the session cookie to be set everytime (liftime must be 0)
	var $dontSetCookie=0;				// Will prevent the setting of the session cookie (takes precedence over forceSetCookie)







	/*
	From t3lib_userauthgroup
	*/
	var $usergroup_column = 'usergroup';		// Should be set to the usergroup-column (id-list) in the user-record
	var $usergroup_table = 'be_groups';			// The name of the group-table

		// internal
	var $groupData = Array(				// This array holds lists of eg. tables, fields and other values related to the permission-system. See fetchGroupData
		'filemounts' => Array()			// Filemounts are loaded here
	);

	var $userGroups = Array();			// This array will hold the groups that the user is a member of
	var $userGroupsUID = Array();		// This array holds the uid's of the groups in the listed order
	var $groupList ='';					// This is $this->userGroupsUID imploded to a comma list... Will correspond to the 'usergroup_cached_list'
	var $dataLists=array(				// Used internally to accumulate data for the user-group. DONT USE THIS EXTERNALLY! Use $this->groupData instead
		'webmount_list'=>'',
		'filemount_list'=>'',
		'modList'=>'',
		'tables_select'=>'',
		'tables_modify'=>'',
		'pagetypes_select'=>'',
		'non_exclude_fields'=>'',
		'explicit_allowdeny'=>'',
		'allowed_languages' => '',
		'custom_options' => '',
	);
	var $includeHierarchy=array();		// For debugging/display of order in which subgroups are included.
	var $includeGroupArray=array();		// List of group_id's in the order they are processed.

	var $OS='';							// Set to 'WIN', if windows
	var $TSdataArray=array();			// Used to accumulate the TSconfig data of the user
	var $userTS_text = '';				// Contains the non-parsed user TSconfig
	var $userTS = array();				// Contains the parsed user TSconfig
	var $userTSUpdated=0;				// Set internally if the user TSconfig was parsed and needs to be cached.
	var $userTS_dontGetCached=0;		// Set this from outside if you want the user TSconfig to ALWAYS be parsed and not fetched from cache.

	var $RTE_errors = array();			// RTE availability errors collected.
	var $errorMsg = '';					// Contains last error message

	/*
	From t3lib_beuserauth
	*/



	var $session_table = 'be_sessions'; 		// Table to use for session data.
	var $name = 'be_typo_user';                 // Session/Cookie name

	var $user_table = 'be_users'; 					// Table in database with userdata
	var $username_column = 'username'; 			// Column for login-name
	var $userident_column = 'password'; 		// Column for password
	var $userid_column = 'uid'; 					// Column for user-id
	var $lastLogin_column = 'lastlogin';
	var $notifyHeader = 'From: TYPO3 Login notify <no_reply@no_reply.no_reply>';

	var $enablecolumns = Array (
		'rootLevel' => 1,
		'deleted' => 'deleted',
		'disabled' => 'disable',
		'starttime' => 'starttime',
		'endtime' => 'endtime'
	);

	var $formfield_uname = 'username'; 			// formfield with login-name
	var $formfield_uident = 'userident'; 		// formfield with password
	var $formfield_chalvalue = 'challenge';		// formfield with a unique value which is used to encrypt the password and username
	var $formfield_status = 'login_status'; 	// formfield with status: *'login', 'logout'
	var $security_level = 'challenged';				// sets the level of security. *'normal' = clear-text. 'challenged' = hashed password/username from form in $formfield_uident. 'superchallenged' = hashed password hashed again with username.

	//var $writeStdLog = 1;					// Decides if the writelog() function is called at login and logout
	//var $writeAttemptLog = 1;				// If the writelog() functions is called if a login-attempt has be tried without success

	var $auth_include = '';						// this is the name of the include-file containing the login form. If not set, login CAN be anonymous. If set login IS needed.

	var $auth_timeout_field = 60000; 				// if > 0 : session-timeout in seconds. if false/<0 : no timeout. if string: The string is fieldname from the usertable where the timeout can be found.
	var $lifetime = 0;                  		// 0 = Session-cookies. If session-cookies, the browser will stop session when the browser is closed. Else it keeps the session for $lifetime seconds.



		// User Config:
	var $uc;

		// User Config Default values:
		// The array may contain other fields for configuration. For this, see "setup" extension and "TSConfig" document (User TSconfig, "setup.[xxx]....")
		/*
			Reserved keys for other storage of session data:
			moduleData
			moduleSessionID
		*/
	var $uc_default = Array (
//		'lang' => 'dk',		// this value will be transferred from $BE_USER->user[lang] if not set...
		'interfaceSetup' => '',	// serialized content that is used to store interface pane and menu positions. Set by the logout.php-script
		'moduleData' => Array(),	// user-data for the modules
		'thumbnailsByDefault' => 0,
		'emailMeAtLogin' => 0,
		'condensedMode' => 0,
		'noMenuMode' => 0,
		'startInTaskCenter' => 0,
		'hideSubmoduleIcons' => 0,
		'helpText' => 1,
		'titleLen' => 30,
		'edit_wideDocument' => '0',
		'edit_showFieldHelp' => 'icon',
		'edit_RTE' => '1',
		'edit_docModuleUpload' => '1',
		'disableCMlayers' => 0,
		'navFrameWidth' => '',	// Default is 245 pixels
		'navFrameResizable' => 0,
	);







/**
	 * Starts a user session
	 * Typical configurations will:
	 * a) check if session cookie was set and if not, set one,
	 * b) check if a password/username was sent and if so, try to authenticate the user
	 * c) Lookup a session attached to a user and check timeout etc.
	 * d) Garbage collection, setting of no-cache headers.
	 * If a user is authenticated the database record of the user (array) will be set in the ->user internal variable.
	 *
	 * @return	void
	 */
	function start() {

			// Init vars.
		$mode='';
		$new_id = false;				// Default: not a new session
		$id = isset($_COOKIE[$this->name]) ? stripslashes($_COOKIE[$this->name]) : '';	// $id is set to ses_id if cookie is present. Else set to false, which will start a new session
		$this->hash_length = t3lib_div::intInRange($this->hash_length,6,32);

			// If fallback to get mode....
		if (!$id && $this->getFallBack && $this->get_name)	{
			$id = isset($_GET[$this->get_name]) ? t3lib_div::_GET($this->get_name) : '';
			if (strlen($id)!=$this->hash_length)	$id='';
			$mode='get';
		}
		$this->cookieId = $id;
		
		if (!$id)	{					// If new session...
    		$id = substr(md5(uniqid('')),0,$this->hash_length);		// New random session-$id is made
			$new_id = true;				// New session
		}
			// Internal var 'id' is set
		$this->id = $id;
		/*if ($mode=='get' && $this->getFallBack && $this->get_name)	{	// If fallback to get mode....
			$this->get_URL_ID = '&'.$this->get_name.'='.$id;
		}*/
		$this->user = '';				// Make certain that NO user is set initially
		//echo 'using my class'; 
			// Setting cookies
        if (($new_id || $this->forceSetCookie) && $this->lifetime==0 ) {		// If new session and the cookie is a sessioncookie, we need to set it only once!
          if (!$this->dontSetCookie)	SetCookie($this->name, $id, 0, '/');		// Cookie is set
        }
        if ($this->lifetime > 0) {		// If it is NOT a session-cookie, we need to refresh it.
          if (!$this->dontSetCookie)	SetCookie($this->name, $id, time()+$this->lifetime, '/');
        }

			// Check to see if anyone has submitted login-information and if so register the user with the session. $this->user[uid] may be used to write log...
		if ($this->formfield_status)	{
			$this->check_authentication();
		}
		unset($this->user);				// Make certain that NO user is set initially. ->check_authentication may have set a session-record which will provide us with a user record in the next section:

	$BE_SQL =$this->session_table.'.ses_id = "'.$GLOBALS['TYPO3_DB']->quoteStr($this->id,	$this->session_table).'" AND '.$this->session_table.'.ses_name = "'.$GLOBALS['TYPO3_DB']->quoteStr($this->name, $this->session_table).'" AND '.$this->session_table.'.ses_userid = '.$this->user_table.'.'.$this->userid_column.' '.$this->hashLockClause().' '.$this->user_where_clause();
			// The session_id is used to find user in the database. Two tables are joined: The session-table with user_id of the session and the usertable with its primary key
		$dbres = $GLOBALS['TYPO3_DB']->exec_SELECTquery('*',$this->session_table.','.$this->user_table,$BE_SQL);
 
		if ($this->user = $GLOBALS['TYPO3_DB']->sql_fetch_assoc($dbres))	{
				// A user was found
			if (is_string($this->auth_timeout_field))	{
				$timeout = intval($this->user[$this->auth_timeout_field]);		// Get timeout-time from usertable
			} else {
				$timeout = intval($this->auth_timeout_field);	 				// Get timeout from object
			}
				// If timeout > 0 (true) and currenttime has not exceeded the latest sessions-time plus the timeout in seconds then accept user
				// Option later on: We could check that last update was at least x seconds ago in order not to update twice in a row if one script redirects to another...
				$GLOBALS['BE_loginstatus'] =1;
			if ($timeout>0 && ($GLOBALS['EXEC_TIME'] < ($this->user['ses_tstamp']+$timeout)))	{  
					$GLOBALS['TYPO3_DB']->exec_UPDATEquery(
											$this->session_table,
											'ses_id="'.$GLOBALS['TYPO3_DB']->quoteStr($this->id, $this->session_table).'"
												AND ses_name="'.$GLOBALS['TYPO3_DB']->quoteStr($this->name, $this->session_table).'"',
											array('ses_tstamp' => $GLOBALS['EXEC_TIME'])
										);
					$this->user['ses_tstamp'] = $GLOBALS['EXEC_TIME'];	// Make sure that the timestamp is also updated in the array
			} else {
				
				$GLOBALS['BE_loginstatus']  =-1;   
				$this->user='';
				$this->logoff();		// delete any user set...
			} 
		} else {
			$GLOBALS['BE_loginstatus'] =-2;
			
			$this->logoff();		// delete any user set...
		}

		$this->redirect();		// If any redirection (inclusion of file) then it will happen in this function

			// Set all posible headers that could ensure that the script is not cached on the client-side
		if ($this->sendNoCacheHeaders)	{
			header('Expires: Mon, 26 Jul 1997 05:00:00 GMT');
			header('Last-Modified: ' . gmdate('D, d M Y H:i:s') . ' GMT');
			header('Expires: 0');
			header('Cache-Control: no-cache, must-revalidate');
			header('Pragma: no-cache');
		}
 
			// If we're lucky we'll get to clean up old sessions....
		if ((rand()%100) <= $this->gc_probability) {
			$this->gc();
		}
	}





	/**
	 * Checks if a submission of username and password is present
	 *
	 * @return	string		Returns "login" if login, "logout" if logout, or empty if $F_status was none of these values.
	 * @internal
	 */
	function check_authentication() {

			// The values fetched from input variables here are supposed to already BE slashed...
		/*if ($this->getMethodEnabled)	{
			$F_status = t3lib_div::_GP($this->formfield_status);
			$F_uname = t3lib_div::_GP($this->formfield_uname);
			$F_uident = t3lib_div::_GP($this->formfield_uident);
			$F_chalvalue = t3lib_div::_GP($this->formfield_chalvalue);
		} else {
			$F_status = t3lib_div::_POST($this->formfield_status);
			$F_uname = t3lib_div::_POST($this->formfield_uname);
			$F_uident = t3lib_div::_POST($this->formfield_uident);
			$F_chalvalue = t3lib_div::_POST($this->formfield_chalvalue);
		}*/

		// Values sent by Flash
		
			$F_status = $GLOBALS['BE_USER']->formfield_status;
			$F_uname =$GLOBALS['BE_USER']->remote_usr;
			$F_uident = $GLOBALS['BE_USER']->remote_psw;
			$F_chalvalue =  $GLOBALS['BE_USER']->remote_chalvalue;


		switch ($F_status)	{ 
			case 'login':
				$refInfo=parse_url(t3lib_div::getIndpEnv('HTTP_REFERER'));
				$httpHost = t3lib_div::getIndpEnv('TYPO3_HOST_ONLY');
				if (!$this->getMethodEnabled && ($httpHost!=$refInfo['host'] && !$GLOBALS['TYPO3_CONF_VARS']['SYS']['doNotCheckReferer']))	{
					$GLOBALS['R_SQL'] = 'Error: This host address ("'.$httpHost.'") and the referer host ("'.$refInfo['host'].'") mismatches!';
					return('Error: This host address ("'.$httpHost.'") and the referer host ("'.$refInfo['host'].'") mismatches!<br />
						It\'s possible that the environment variable HTTP_REFERER is not passed to the script because of a proxy.<br />
						The site administrator can disable this check in the "All Configuration" section of the Install Tool (flag: TYPO3_CONF_VARS[SYS][doNotCheckReferer]).');
				}
				if ($F_uident && $F_uname)	{

						// Reset this flag
					$loginFailure=0;

						// delete old user session if any
//					echo '3 log					';
					$GLOBALS['R_SQL'] ='Logoff 3';
					
					$this->logoff();

						// Look up the new user by the username:
					$dbres = $GLOBALS['TYPO3_DB']->exec_SELECTquery(
									'*',
									$this->user_table,
									($this->checkPid ? 'pid IN ('.$GLOBALS['TYPO3_DB']->cleanIntList($this->checkPid_value).') AND ' : '').
										$this->username_column.'="'.$GLOBALS['TYPO3_DB']->quoteStr($F_uname, $this->user_table).'" '.
										$this->user_where_clause()
							);

						// Enter, if a user was found:
					if ($tempuser = $GLOBALS['TYPO3_DB']->sql_fetch_assoc($dbres))	{
							// Internal user record set (temporarily)
						$this->user = $tempuser;

							// Default: not OK - will be set true if password matches in the comparison hereafter
						$OK = false;

							// check the password
						switch ($this->security_level)	{
							case 'superchallenged':		// If superchallenged the password in the database ($tempuser[$this->userident_column]) must be a md5-hash of the original password.
							case 'challenged':
								if (!strcmp($F_uident,md5($tempuser[$this->username_column].':'.$tempuser[$this->userident_column].':'.$F_chalvalue)))	{
									$OK = true;

								};
							break;
							default:	// normal
								if (!strcmp($F_uident,$tempuser[$this->userident_column]))	{
									$OK = true;
								};
							break;
						}
//$GLOBALS['R_SQL'] ='security_level: '.$this->security_level.' chalvalue: '.$F_chalvalue . ' uident: '.$F_uident .' might be this username: ' .$tempuser[$this->username_column].' with this psw: '.$tempuser[$this->userident_column];
							// Write session-record in case user was verified OK
						if ($OK)	{
								// Checking the domain (lockToDomain)
							if ($this->user['lockToDomain'] && $this->user['lockToDomain']!=t3lib_div::getIndpEnv('HTTP_HOST'))	{
									// Lock domain didn't match, so error:
								if ($this->writeAttemptLog) {
									$this->writelog(255,3,3,1,
										"Login-attempt from %s (%s), username '%s', locked domain '%s' did not match '%s'!",
										Array(t3lib_div::getIndpEnv('REMOTE_ADDR'),t3lib_div::getIndpEnv('REMOTE_HOST'),$F_uname,$this->user['lockToDomain'],t3lib_div::getIndpEnv('HTTP_HOST')));
								}
								$loginFailure=1;
							} else {
									// The loginsession is started.
								$this->loginSessionStarted = 1;

									// Inserting session record:
								$insertFields = array(
									'ses_id' => $this->id,
									'ses_name' => $this->name,
									'ses_iplock' => $this->user['disableIPlock'] ? '[DISABLED]' : $this->ipLockClause_remoteIPNumber($this->lockIP),
									'ses_hashlock' => $this->hashLockClause_getHashInt(),
									'ses_userid' => $tempuser[$this->userid_column],
									'ses_tstamp' => $GLOBALS['EXEC_TIME']
								);
								$GLOBALS['TYPO3_DB']->exec_INSERTquery($this->session_table, $insertFields);

									// Updating column carrying information about last login.
								if ($this->lastLogin_column)	{
									$GLOBALS['TYPO3_DB']->exec_UPDATEquery(
															$this->user_table,
															$this->userid_column.'="'.$GLOBALS['TYPO3_DB']->quoteStr($tempuser[$this->userid_column], $this->user_table).'"',
															array($this->lastLogin_column => $GLOBALS['EXEC_TIME'])
														);
								}
									// User logged in - write that to the log!
								if ($this->writeStdLog) {
									$this->writelog(255,1,0,1,
										'User %s logged in from %s (%s)',
										Array($this->user['username'],t3lib_div::getIndpEnv('REMOTE_ADDR'),t3lib_div::getIndpEnv('REMOTE_HOST')));
								}
							}
						} else {
								// Failed login attempt (wrong password) - write that to the log!
							if ($this->writeAttemptLog) {
								$this->writelog(255,3,3,1,
									"Login-attempt from %s (%s), username '%s', password not accepted!",
									Array(t3lib_div::getIndpEnv('REMOTE_ADDR'),t3lib_div::getIndpEnv('REMOTE_HOST'),$F_uname));
							}
							$loginFailure=1;
						}
							// Make sure to clear the user again!!
						unset($this->user);
					} else {
							// Failed login attempt (no username found)
						if ($this->writeAttemptLog) {
							$this->writelog(255,3,3,2,
								"Login-attempt from %s (%s), username '%s' not found!!",
								Array(t3lib_div::getIndpEnv('REMOTE_ADDR'),t3lib_div::getIndpEnv('REMOTE_HOST'),$F_uname));	// Logout written to log
						}
						$loginFailure=1;
					}

						// If there were a login failure, check to see if a warning email should be sent:
					if ($loginFailure)	{
						$this->checkLogFailures($this->warningEmail, $this->warningPeriod, $this->warningMax);
					}
				}

					// Return "login" - since this was the $F_status
				return 'login';
			break;
			case 'logout':
					// Just logout:
				if ($this->writeStdLog) 	$this->writelog(255,2,0,2,'User %s logged out',Array($this->user['username']));	// Logout written to log
//				echo '4 log				';
				$GLOBALS['R_SQL'] ='Logoff 4';
				$this->logoff();

					// Return "logout" - since this was the $F_status
				return 'logout';
			break;
		}
	}









	/**
	 * If flag is set and the extensions 'beuser_tracking' is loaded, this will insert a table row with the REQUEST_URI of current script - thus tracking the scripts the backend users uses...
	 * This function works ONLY with the "beuser_tracking" extension and is depreciated since it does nothing useful.
	 *
	 * @param	boolean		Activate insertion of the URL.
	 * @return	void
	 * @access private
	 */
	function trackBeUser($flag)	{
		if ($flag && t3lib_extMgm::isLoaded('beuser_tracking'))	{
			$insertFields = array(
				'userid' => intval($this->user['uid']),
				'tstamp' => time(),
				'script' => t3lib_div::getIndpEnv('REQUEST_URI')
			);

			$GLOBALS['TYPO3_DB']->exec_INSERTquery('sys_trackbeuser', $insertFields);
		}
	}

	/**
	 * If TYPO3_CONF_VARS['BE']['enabledBeUserIPLock'] is enabled and an IP-list is found in the User TSconfig objString "options.lockToIP", then make an IP comparison with REMOTE_ADDR and return the outcome (true/false)
	 *
	 * @return	boolean		True, if IP address validates OK (or no check is done at all)
	 * @access private
	 */
	function checkLockToIP()	{
		global $TYPO3_CONF_VARS;
		$out = 1;
		if ($TYPO3_CONF_VARS['BE']['enabledBeUserIPLock'])	{
			$IPList = $this->getTSConfigVal('options.lockToIP');
			if (trim($IPList))	{
				$baseIP = t3lib_div::getIndpEnv('REMOTE_ADDR');
				$out = t3lib_div::cmpIP($baseIP, $IPList);
			}
		}
		return $out;
	}

	/**
	 * Check if user is logged in and if so, call ->fetchGroupData() to load group information and access lists of all kind, further check IP, set the ->uc array and send login-notification email if required.
	 * If no user is logged in the default behaviour is to exit with an error message, but this will happen ONLY if the constant TYPO3_PROCEED_IF_NO_USER is set true.
	 * This function is called right after ->start() in fx. init.php
	 *
	 * @return	void
	 */
	function backendCheckLogin()	{
		if (!$this->user['uid'])	{
			if (!defined('TYPO3_PROCEED_IF_NO_USER') || !TYPO3_PROCEED_IF_NO_USER)	{
				t3lib_BEfunc::typo3PrintError ('Login-error','No user logged in! Sorry, I can\'t proceed then!<br /><br />(You must have cookies enabled!)',0);
				exit;
			} 
		} else {	// ...and if that's the case, call these functions
			$this->fetchGroupData();	//	The groups are fetched and ready for permission checking in this initialization.	Tables.php must be read before this because stuff like the modules has impact in this
			if ($this->checkLockToIP())	{
				if (!$GLOBALS['TYPO3_CONF_VARS']['BE']['adminOnly'] || $this->isAdmin())	{
					$this->backendSetUC();		// Setting the UC array. It's needed with fetchGroupData first, due to default/overriding of values.
					$this->emailAtLogin();		// email at login - if option set.
				} else {
					t3lib_BEfunc::typo3PrintError ('Login-error','TYPO3 is in maintenance mode at the moment. Only administrators are allowed access.',0);
					exit;
				}
			} else {
				t3lib_BEfunc::typo3PrintError ('Login-error','IP locking prevented you from being authorized. Can\'t proceed, sorry.',0);
				exit;
			}
		}
	}

	/**
	 * If the backend script is in CLI mode, it will try to load a backend user named by the CLI module name (in lowercase)
	 *
	 * @return	boolean		Returns true if a CLI user was loaded, otherwise false!
	 */
	function checkCLIuser()	{
			// First, check if cliMode is enabled:
		if (defined('TYPO3_cliMode') && TYPO3_cliMode)	{
			if (!$this->user['uid'])	{
				if (substr($GLOBALS['MCONF']['name'],0,5)=='_CLI_')	{
					$userName = strtolower($GLOBALS['MCONF']['name']);
					$this->setBeUserByName($userName);
					if ($this->user['uid'])	{
						if (!$this->isAdmin())	{
							return TRUE;
						} else die('ERROR: CLI backend user "'.$userName.'" was ADMIN which is not allowed!'.chr(10).chr(10));
					} else die('ERROR: No backend user named "'.$userName.'" was found!'.chr(10).chr(10));
				} else die('ERROR: Module name, "'.$GLOBALS['MCONF']['name'].'", was not prefixed with "_CLI_"'.chr(10).chr(10));
			} else die('ERROR: Another user was already loaded which is impossible in CLI mode!'.chr(10).chr(10));
		}
	}

	/**
	 * Initialize the internal ->uc array for the backend user
	 * Will make the overrides if necessary, and write the UC back to the be_users record if changes has happend
	 *
	 * @return	void
	 * @internal
	 */
	function backendSetUC()	{

			// UC - user configuration is a serialized array inside the userobject
		$temp_theSavedUC=unserialize($this->user['uc']);		// if there is a saved uc we implement that instead of the default one.
		if (is_array($temp_theSavedUC))	{
			$this->unpack_uc($temp_theSavedUC);
		}
			// Setting defaults if uc is empty
		if (!is_array($this->uc))	{
			$this->uc = array_merge($this->uc_default, (array)$TYPO3_CONF_VARS['BE']['defaultUC'], (array)$this->getTSConfigProp('setup.default'));	// Candidate for t3lib_div::array_merge() if integer-keys will some day make trouble...
			$this->overrideUC();
			$U=1;
		}
			// If TSconfig is updated, update the defaultUC.
		if ($this->userTSUpdated)	{
			$this->overrideUC();
			$U=1;
		}
			// Setting default lang from be_user record.
		if (!isset($this->uc['lang']))	{
			$this->uc['lang']=$this->user['lang'];
			$U=1;
		}
			// Saving if updated.
		if ($U)	{
			$this->writeUC();	// Method from the t3lib_userauth class.
		}
	}

	/**
	 * Override: Call this function every time the uc is updated.
	 * That is 1) by reverting to default values, 2) in the setup-module, 3) userTS changes (userauthgroup)
	 *
	 * @return	void
	 * @internal
	 */
	function overrideUC()	{
		$this->uc = array_merge((array)$this->uc, (array)$this->getTSConfigProp('setup.override'));	// Candidate for t3lib_div::array_merge() if integer-keys will some day make trouble...
	}

	/**
	 * Clears the user[uc] and ->uc to blank strings. Then calls ->backendSetUC() to fill it again with reset contents
	 *
	 * @return	void
	 * @internal
	 */
	function resetUC()	{
		$this->user['uc']='';
		$this->uc='';
		$this->backendSetUC();
	}

	/**
	 * Will send an email notification to warning_email_address/the login users email address when a login session is just started.
	 * Depends on various parameters whether mails are send and to whom.
	 *
	 * @return	void
	 * @access private
	 */
	function emailAtLogin()	{
		if ($this->loginSessionStarted)	{
				// Send notify-mail
			$subject = 'At "'.$GLOBALS['TYPO3_CONF_VARS']['SYS']['sitename'].'"'.
						' from '.t3lib_div::getIndpEnv('REMOTE_ADDR').
						(t3lib_div::getIndpEnv('REMOTE_HOST') ? ' ('.t3lib_div::getIndpEnv('REMOTE_HOST').')' : '');
			$msg = sprintf ('User "%s" logged in from %s (%s) at "%s" (%s)',
				$this->user['username'],
				t3lib_div::getIndpEnv('REMOTE_ADDR'),
				t3lib_div::getIndpEnv('REMOTE_HOST'),
				$GLOBALS['TYPO3_CONF_VARS']['SYS']['sitename'],
				t3lib_div::getIndpEnv('HTTP_HOST')
			);

				// Warning email address
			if ($GLOBALS['TYPO3_CONF_VARS']['BE']['warning_email_addr'])	{
				$warn=0;
				$prefix='';
				if (intval($GLOBALS['TYPO3_CONF_VARS']['BE']['warning_mode']) & 1)	{	// first bit: All logins
					$warn=1;
					$prefix= $this->isAdmin() ? '[AdminLoginWarning]' : '[LoginWarning]';
				}
				if ($this->isAdmin() && (intval($GLOBALS['TYPO3_CONF_VARS']['BE']['warning_mode']) & 2))	{	// second bit: Only admin-logins
					$warn=1;
					$prefix='[AdminLoginWarning]';
				}
				if ($warn)	{
					mail($GLOBALS['TYPO3_CONF_VARS']['BE']['warning_email_addr'],
						$prefix.' '.$subject,
						$msg,
						$this->notifyHeader
					);
				}
			}

				// If An email should be sent to the current user, do that:
			if ($this->uc['emailMeAtLogin'] && strstr($this->user['email'],'@'))	{
				mail($this->user['email'],
					$subject,
					$msg,
					$this->notifyHeader
				);
			}
		}
	}

	/**
	 * VeriCode returns 10 first chars of a md5 hash of the session cookie AND the encryptionKey from TYPO3_CONF_VARS.
	 * This code is used as an alternative verification when the JavaScript interface executes cmd's to tce_db.php from eg. MSIE 5.0 because the proper referer is not passed with this browser...
	 *
	 * @return	string
	 */
	function veriCode()	{
		return substr(md5($this->id.$GLOBALS['TYPO3_CONF_VARS']['SYS']['encryptionKey']),0,10);
	}




	/************************************
	*
	* The following functions are from t3lib_userauthgroup
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	* Borg
	 ************************************/



	/************************************
	 *
	 * Permission checking functions:
	 *
	 ************************************/

	/**
	 * Returns true if user is admin
	 * Basically this function evaluates if the ->user[admin] field has bit 0 set. If so, user is admin.
	 *
	 * @return	boolean
	 */
	function isAdmin()	{
		return (($this->user['admin']&1) ==1);
	}

	/**
	 * Returns true if the current user is a member of group $groupId
	 * $groupId must be set. $this->groupList must contain groups
	 * Will return true also if the user is a member of a group through subgroups.
	 *
	 * @param	integer		Group ID to look for in $this->groupList
	 * @return	boolean
	 */
	function isMemberOfGroup($groupId)	{
		$groupId = intval($groupId);
		if ($this->groupList && $groupId)	{
			return $this->inList($this->groupList, $groupId);
		}
	}

	/**
	 * Checks if the permissions is granted based on a page-record ($row) and $perms (binary and'ed)
	 *
	 * Bits for permissions, see $perms variable:
	 *
	 * 		1 - Show:	See/Copy page and the pagecontent.
	 * 		16- Edit pagecontent: Change/Add/Delete/Move pagecontent.
	 * 		2- Edit page: Change/Move the page, eg. change title, startdate, hidden.
	 * 		4- Delete page: Delete the page and pagecontent.
	 * 		8- New pages: Create new pages under the page.
	 *
	 * @param	array		$row is the pagerow for which the permissions is checked
	 * @param	integer		$perms is the binary representation of the permission we are going to check. Every bit in this number represents a permission that must be set. See function explanation.
	 * @return	boolean		True or False upon evaluation
	 */
	function doesUserHaveAccess($row,$perms)	{
		$userPerms = $this->calcPerms($row);
		return ($userPerms & $perms)==$perms;
	}

	/**
	 * Checks if the page id, $id, is found within the webmounts set up for the user.
	 * This should ALWAYS be checked for any page id a user works with, whether it's about reading, writing or whatever.
	 * The point is that this will add the security that a user can NEVER touch parts outside his mounted pages in the page tree. This is otherwise possible if the raw page permissions allows for it. So this security check just makes it easier to make safe user configurations.
	 * If the user is admin OR if this feature is disabled (fx. by setting TYPO3_CONF_VARS['BE']['lockBeUserToDBmounts']=0) then it returns "1" right away
	 * Otherwise the function will return the uid of the webmount which was first found in the rootline of the input page $id
	 *
	 * @param	integer		Page ID to check
	 * @param	string		Content of "->getPagePermsClause(1)" (read-permissions). If not set, they will be internally calculated (but if you have the correct value right away you can save that database lookup!)
	 * @param	boolean		If set, then the function will exit with an error message.
	 * @return	integer		The page UID of a page in the rootline that matched a mount point
	 */
	function isInWebMount($id,$readPerms='',$exitOnError=0)	{
		if (!$GLOBALS['TYPO3_CONF_VARS']['BE']['lockBeUserToDBmounts'] || $this->isAdmin())	return 1;
		$id = intval($id);
		if (!$readPerms)	$readPerms = $this->getPagePermsClause(1);
		if ($id>0)	{
			$wM = $this->returnWebmounts();
			$rL = t3lib_BEfunc::BEgetRootLine($id,' AND '.$readPerms);

			foreach($rL as $v)	{
				if ($v['uid'] && in_array($v['uid'],$wM))	{
					return $v['uid'];
				}
			}
		}
		if ($exitOnError)	{
			t3lib_BEfunc::typo3PrintError ('Access Error','This page is not within your DB-mounts',0);
			exit;
		}
	}

	/**
	 * Checks access to a backend module with the $MCONF passed as first argument
	 *
	 * @param	array		$MCONF array of a backend module!
	 * @param	boolean		If set, an array will issue an error message and exit.
	 * @return	boolean		Will return true if $MCONF['access'] is not set at all, if the BE_USER is admin or if the module is enabled in the be_users/be_groups records of the user (specifically enabled). Will return false if the module name is not even found in $TBE_MODULES
	 */
	function modAccess($conf,$exitOnError)	{
		if (!t3lib_BEfunc::isModuleSetInTBE_MODULES($conf['name']))	{
			if ($exitOnError)	{
				t3lib_BEfunc::typo3PrintError ('Fatal Error','This module "'.$conf['name'].'" is not enabled in TBE_MODULES',0);
				exit;
			}
			return false;
		}

			// Returns true if conf[access] is not set at all or if the user is admin
		if (!$conf['access']  ||  $this->isAdmin()) return true;

			// If $conf['access'] is set but not with 'admin' then we return true, if the module is found in the modList
		if (!strstr($conf['access'],'admin') && $conf['name'])	{
			$acs = $this->check('modules',$conf['name']);
		}
		if (!$acs && $exitOnError)	{
			t3lib_BEfunc::typo3PrintError ('Access Error','You don\'t have access to this module.',0);
			exit;
		} else return $acs;
	}

	/**
	 * Returns a WHERE-clause for the pages-table where user permissions according to input argument, $perms, is validated.
	 * $perms is the 'mask' used to select. Fx. if $perms is 1 then you'll get all pages that a user can actually see!
	 * 	 	2^0 = show (1)
	 * 		2^1 = edit (2)
	 * 		2^2 = delete (4)
	 * 		2^3 = new (8)
	 * If the user is 'admin' " 1=1" is returned (no effect)
	 * If the user is not set at all (->user is not an array), then " 1=0" is returned (will cause no selection results at all)
	 * The 95% use of this function is "->getPagePermsClause(1)" which will return WHERE clauses for *selecting* pages in backend listings - in other words will this check read permissions.
	 *
	 * @param	integer		Permission mask to use, see function description
	 * @return	string		Part of where clause. Prefix " AND " to this.
	 */
	function getPagePermsClause($perms)	{
		if (is_array($this->user))	{
			if ($this->isAdmin())	{
				return ' 1=1';
			}

			$perms = intval($perms);	// Make sure it's integer.
			$str= ' ('.
				'(pages.perms_everybody & '.$perms.' = '.$perms.')'.	// Everybody
				'OR(pages.perms_userid = '.$this->user['uid'].' AND pages.perms_user & '.$perms.' = '.$perms.')';	// User
			if ($this->groupList){$str.='OR(pages.perms_groupid in ('.$this->groupList.') AND pages.perms_group & '.$perms.' = '.$perms.')';}	// Group (if any is set)
			$str.=')';
			return $str;
		} else {
			return ' 1=0';
		}
	}

	/**
	 * Returns a combined binary representation of the current users permissions for the page-record, $row.
	 * The perms for user, group and everybody is OR'ed together (provided that the page-owner is the user and for the groups that the user is a member of the group
	 * If the user is admin, 31 is returned	(full permissions for all five flags)
	 *
	 * @param	array		Input page row with all perms_* fields available.
	 * @return	integer		Bitwise representation of the users permissions in relation to input page row, $row
	 */
	function calcPerms($row)	{
		if ($this->isAdmin()) {return 31;}		// Return 31 for admin users.

		$out=0;
		if (isset($row['perms_userid']) && isset($row['perms_user']) && isset($row['perms_groupid']) && isset($row['perms_group']) && isset($row['perms_everybody']) && isset($this->groupList))	{
			if ($this->user['uid']==$row['perms_userid'])	{
				$out|=$row['perms_user'];
			}
			if ($this->isMemberOfGroup($row['perms_groupid']))	{
				$out|=$row['perms_group'];
			}
			$out|=$row['perms_everybody'];
		}
		return $out;
	}

	/**
	 * Returns true if the RTE (Rich Text Editor) can be enabled for the user
	 * Strictly this is not permissions being checked but rather a series of settings like a loaded extension, browser/client type and a configuration option in ->uc[edit_RTE]
	 * The reasons for a FALSE return can be found in $this->RTE_errors
	 *
	 * @return	boolean
	 */
	function isRTE()	{
		global $CLIENT;

			// Start:
		$this->RTE_errors = array();
		if (!$this->uc['edit_RTE'])
			$this->RTE_errors[] = 'RTE is not enabled for user!';
		if (!$GLOBALS['TYPO3_CONF_VARS']['BE']['RTEenabled'])
			$this->RTE_errors[] = 'RTE is not enabled in $TYPO3_CONF_VARS["BE"]["RTEenabled"]';


			// Acquire RTE object:
		$RTE = &t3lib_BEfunc::RTEgetObj();
		if (!is_object($RTE))	{
			$this->RTE_errors = array_merge($this->RTE_errors, $RTE);
		}

		if (!count($this->RTE_errors))	{
			return TRUE;
		} else {
			return FALSE;
		}
	}

	/**
	 * Returns true if the $value is found in the list in a $this->groupData[] index pointed to by $type (array key).
	 * Can thus be users to check for modules, exclude-fields, select/modify permissions for tables etc.
	 * If user is admin true is also returned
	 * Please see the document Inside TYPO3 for examples.
	 *
	 * @param	string		The type value; "webmounts", "filemounts", "pagetypes_select", "tables_select", "tables_modify", "non_exclude_fields", "modules"
	 * @param	string		String to search for in the groupData-list
	 * @return	boolean		True if permission is granted (that is, the value was found in the groupData list - or the BE_USER is "admin")
	 */
	function check($type,$value)	{
		if (isset($this->groupData[$type]))	{
			if ($this->isAdmin() || $this->inList($this->groupData[$type],$value)) {
				return 1;
			}
		}
	}

	/**
	 * Checking the authMode of a select field with authMode set
	 *
	 * @param	string		Table name
	 * @param	string		Field name (must be configured in TCA and of type "select" with authMode set!)
	 * @param	string		Value to evaluation (single value, must not contain any of the chars ":,|")
	 * @param	string		Auth mode keyword (explicitAllow, explicitDeny, individual)
	 * @return	boolean		True or false whether access is granted or not.
	 */
	function checkAuthMode($table,$field,$value,$authMode)	{
		global $TCA;

			// Admin users can do anything:
		if ($this->isAdmin())	return TRUE;

			// Allow all blank values:
		if (!strcmp($value,''))	return TRUE;

			// Certain characters are not allowed in the value
		if (ereg('[:|,]',$value))	{
			return FALSE;
		}

			// Initialize:
		$testValue = $table.':'.$field.':'.$value;
		$out = TRUE;

			// Checking value:
		switch((string)$authMode)	{
			case 'explicitAllow':
				if (!$this->inList($this->groupData['explicit_allowdeny'],$testValue.':ALLOW'))	{
					$out = FALSE;
				}
			break;
			case 'explicitDeny':
				if ($this->inList($this->groupData['explicit_allowdeny'],$testValue.':DENY'))	{
					$out = FALSE;
				}
			break;
			case 'individual':
				t3lib_div::loadTCA($table);
				if (is_array($TCA[$table]) && is_array($TCA[$table]['columns'][$field]))	{
					$items = $TCA[$table]['columns'][$field]['config']['items'];
					if (is_array($items))	{
						foreach($items as $iCfg)	{
							if (!strcmp($iCfg[1],$value) && $iCfg[4])	{
								switch((string)$iCfg[4])	{
									case 'EXPL_ALLOW':
										if (!$this->inList($this->groupData['explicit_allowdeny'],$testValue.':ALLOW'))	{
											$out = FALSE;
										}
									break;
									case 'EXPL_DENY':
										if ($this->inList($this->groupData['explicit_allowdeny'],$testValue.':DENY'))	{
											$out = FALSE;
										}
									break;
								}
								break;
							}
						}
					}
				}
			break;
		}

		return $out;
	}

	/**
	 * Checking if a language value (-1, 0 and >0 for sys_language records) is allowed to be edited by the user.
	 *
	 * @param	integer		Language value to evaluate
	 * @return	boolean		Returns true if the language value is allowed, otherwise false.
	 */
	function checkLanguageAccess($langValue)	{
		if (strcmp($this->groupData['allowed_languages'],''))	{	// The users language list must be non-blank - otherwise all languages are allowed.
			$langValue = intval($langValue);
			if ($langValue != -1 && !$this->check('allowed_languages',$langValue))	{	// Language must either be explicitly allowed OR the lang Value be "-1" (all languages)
				return FALSE;
			}
		}
		return TRUE;
	}

	/**
	 * Checking if a user has editing access to a record from a $TCA table.
	 * The checks does not take page permissions and other "environmental" things into account. It only deal with record internals; If any values in the record fields disallows it.
	 * For instance languages settings, authMode selector boxes are evaluated (and maybe more in the future).
	 * The function takes an ID (integer) or row (array) as second argument.
	 *
	 * @param	string		Table name
	 * @param	mixed		If integer, then this is the ID of the record. If Array this just represents fields in the record.
	 * @return	boolean		True if OK, otherwise false
	 */
	function recordEditAccessInternals($table,$idOrRow)	{
		global $TCA;

		if (isset($TCA[$table]))	{
			t3lib_div::loadTCA($table);

				// Always return true for Admin users.
			if ($this->isAdmin())	return TRUE;

				// Fetching the record if the $idOrRow variable was not an array on input:
			if (!is_array($idOrRow))	{
				$idOrRow = t3lib_BEfunc::getRecord($table, $idOrRow);
				if (!is_array($idOrRow))	{
					$this->errorMsg = 'ERROR: Record could not be fetched.';
					return FALSE;
				}
			}

				// Checking languages:
			if ($TCA[$table]['ctrl']['languageField'])	{
				if (isset($idOrRow[$TCA[$table]['ctrl']['languageField']]))	{	// Language field must be found in input row - otherwise it does not make sense.
					if (!$this->checkLanguageAccess($idOrRow[$TCA[$table]['ctrl']['languageField']]))	{
						$this->errorMsg = 'ERROR: Language was not allowed.';
						return FALSE;
					}
				}
			}

				// Checking authMode fields:
			if (is_array($TCA[$table]['columns']))	{
				foreach($TCA[$table]['columns'] as $fN => $fV)	{
					if (isset($idOrRow[$fN]))	{	//
						if ($fV['config']['type']=='select' && $fV['config']['authMode'] && !strcmp($fV['config']['authMode_enforce'],'strict')) {
							if (!$this->checkAuthMode($table,$fN,$idOrRow[$fN],$fV['config']['authMode']))	{
								$this->errorMsg = 'ERROR: authMode "'.$fV['config']['authMode'].'" failed for field "'.$fN.'" with value "'.$idOrRow[$fN].'" evaluated';
								return FALSE;
							}
						}
					}
				}
			}

				// Checking "editlock" feature
			if ($TCA[$table]['ctrl']['editlock'] && $idOrRow[$TCA[$table]['ctrl']['editlock']])	{
				$this->errorMsg = 'ERROR: Record was locked for editing. Only admin users can change this state.';
				return FALSE;
			}

				// Checking record permissions
			// THIS is where we can include a check for "perms_" fields for other records than pages...

				// Finally, return true if all is well.
			return TRUE;
		}
	}

	/**
	 * Will check a type of permission against the compiled permission integer, $lCP, and in relation to table, $table
	 *
	 * @param	integer		$lCP could typically be the "compiled permissions" integer returned by ->calcPerms
	 * @param	string		$table is the tablename to check: If "pages" table then edit,new,delete and editcontent permissions can be checked. Other tables will be checked for "editcontent" only (and $type will be ignored)
	 * @param	string		For $table='pages' this can be 'edit' (2), 'new' (8 or 16), 'delete' (4), 'editcontent' (16). For all other tables this is ignored. (16 is used)
	 * @return	boolean
	 * @access private
	 */
	function isPSet($lCP,$table,$type='')	{
		if ($this->isAdmin())	return true;
		if ($table=='pages')	{
			if ($type=='edit')	return $lCP & 2;
			if ($type=='new')	return ($lCP & 8) || ($lCP & 16);	// Create new page OR pagecontent
			if ($type=='delete')	return $lCP & 4;
			if ($type=='editcontent')	return $lCP & 16;
		} else {
			return $lCP & 16;
		}
	}

	/**
	 * Returns true if the BE_USER is allowed to *create* shortcuts in the backend modules
	 *
	 * @return	boolean
	 */
	function mayMakeShortcut()	{
		return $this->getTSConfigVal('options.shortcutFrame') && !$this->getTSConfigVal('options.mayNotCreateEditShortcuts');
	}










	/*************************************
	 *
	 * Miscellaneous functions
	 *
	 *************************************/

	/**
	 * Returns the value/properties of a TS-object as given by $objectString, eg. 'options.dontMountAdminMounts'
	 * Nice (general!) function for returning a part of a TypoScript array!
	 *
	 * @param	string		Pointer to an "object" in the TypoScript array, fx. 'options.dontMountAdminMounts'
	 * @param	array		Optional TSconfig array: If array, then this is used and not $this->userTS. If not array, $this->userTS is used.
	 * @return	array		An array with two keys, "value" and "properties" where "value" is a string with the value of the objectsting and "properties" is an array with the properties of the objectstring.
	 * @params	array	An array with the TypoScript where the $objectString is located. If this argument is not an array, then internal ->userTS (User TSconfig for the current BE_USER) will be used instead.
	 */
	function getTSConfig($objectString,$config='')	{
		if (!is_array($config))	{
			$config=$this->userTS;	// Getting Root-ts if not sent
		}
		$TSConf=array();
		$parts = explode('.',$objectString,2);
		$key = $parts[0];
		if (trim($key))	{
			if (count($parts)>1 && trim($parts[1]))	{
				// Go on, get the next level
				if (is_array($config[$key.'.']))	$TSConf = $this->getTSConfig($parts[1],$config[$key.'.']);
			} else {
				$TSConf['value']=$config[$key];
				$TSConf['properties']=$config[$key.'.'];
			}
		}
		return $TSConf;
	}

	/**
	 * Returns the "value" of the $objectString from the BE_USERS "User TSconfig" array
	 *
	 * @param	string		Object string, eg. "somestring.someproperty.somesubproperty"
	 * @return	string		The value for that object string (object path)
	 * @see	getTSConfig()
	 */
	function getTSConfigVal($objectString)	{
		$TSConf = $this->getTSConfig($objectString);
		return $TSConf['value'];
	}

	/**
	 * Returns the "properties" of the $objectString from the BE_USERS "User TSconfig" array
	 *
	 * @param	string		Object string, eg. "somestring.someproperty.somesubproperty"
	 * @return	array		The properties for that object string (object path) - if any
	 * @see	getTSConfig()
	 */
	function getTSConfigProp($objectString)	{
		$TSConf = $this->getTSConfig($objectString);
		return $TSConf['properties'];
	}

	/**
	 * Returns true if $item is in $in_list
	 *
	 * @param	string		Comma list with items, no spaces between items!
	 * @param	string		The string to find in the list of items
	 * @return	string		Boolean
	 */
	function inList($in_list,$item)	{
		return strstr(','.$in_list.',', ','.$item.',');
	}

	/**
	 * Returns an array with the webmounts.
	 * If no webmounts, and empty array is returned.
	 * NOTICE: Deleted pages WILL NOT be filtered out! So if a mounted page has been deleted it is STILL coming out as a webmount. This is not checked due to performance.
	 *
	 * @return	array
	 */
	function returnWebmounts()	{
		return (string)($this->groupData['webmounts'])!='' ? explode(',',$this->groupData['webmounts']) : Array();
	}

	/**
	 * Returns an array with the filemounts for the user. Each filemount is represented with an array of a "name", "path" and "type".
	 * If no filemounts an empty array is returned.
	 *
	 * @return	array
	 */
	function returnFilemounts()	{
		return $this->groupData['filemounts'];
	}












	/*************************************
	 *
	 * Authentication methods
	 *
	 *************************************/


	/**
	 * Initializes a lot of stuff like the access-lists, database-mountpoints and filemountpoints
	 * This method is called by ->backendCheckLogin() (from extending class t3lib_beuserauth) if the backend user login has verified OK.
	 *
	 * @return	void
	 * @access private
	 * @see t3lib_TSparser
	 */
	function fetchGroupData()	{
		if ($this->user['uid'])	{

				// Get lists for the be_user record and set them as default/primary values.
			$this->dataLists['modList'] = $this->user['userMods'];					// Enabled Backend Modules
			$this->dataLists['allowed_languages'] = $this->user['allowed_languages'];					// Add Allowed Languages
			$this->dataLists['webmount_list'] = $this->user['db_mountpoints'];		// Database mountpoints
			$this->dataLists['filemount_list'] = $this->user['file_mountpoints'];	// File mountpoints

				// Setting default User TSconfig:
			$this->TSdataArray[]=$this->addTScomment('From $GLOBALS["TYPO3_CONF_VARS"]["BE"]["defaultUserTSconfig"]:').
									$GLOBALS['TYPO3_CONF_VARS']['BE']['defaultUserTSconfig'];

				// Default TSconfig for admin-users
			if ($this->isAdmin())	{
				$this->TSdataArray[]=$this->addTScomment('"admin" user presets:').'
					admPanel.enable.all = 1
					options.shortcutFrame = 1
				';
				if (t3lib_extMgm::isLoaded('tt_news'))	{
					$this->TSdataArray[]='
						// Setting defaults for tt_news author / email...
						TCAdefaults.tt_news.author = '.$this->user['realName'].'
						TCAdefaults.tt_news.author_email = '.$this->user['email'].'
					';
				}
				if (t3lib_extMgm::isLoaded('sys_note'))	{
					$this->TSdataArray[]='
						// Setting defaults for sys_note author / email...
						TCAdefaults.sys_note.author = '.$this->user['realName'].'
						TCAdefaults.sys_note.email = '.$this->user['email'].'
					';
				}
			}

				// FILE MOUNTS:
				// Admin users has the base fileadmin dir mounted
			if ($this->isAdmin() && $GLOBALS['TYPO3_CONF_VARS']['BE']['fileadminDir'])	{
				$this->addFileMount($GLOBALS['TYPO3_CONF_VARS']['BE']['fileadminDir'], '', PATH_site.$GLOBALS['TYPO3_CONF_VARS']['BE']['fileadminDir'], 0, '');
			}

				// If userHomePath is set, we attempt to mount it
			if ($GLOBALS['TYPO3_CONF_VARS']['BE']['userHomePath'])	{
					// First try and mount with [uid]_[username]
				$didMount=$this->addFileMount($this->user['username'], '',$GLOBALS['TYPO3_CONF_VARS']['BE']['userHomePath'].$this->user['uid'].'_'.$this->user['username'].$GLOBALS['TYPO3_CONF_VARS']['BE']['userUploadDir'], 0, 'user');
				if (!$didMount)	{
						// If that failed, try and mount with only [uid]
					$this->addFileMount($this->user['username'], '', $GLOBALS['TYPO3_CONF_VARS']['BE']['userHomePath'].$this->user['uid'].$GLOBALS['TYPO3_CONF_VARS']['BE']['userUploadDir'], 0, 'user');
				}
			}

				// BE_GROUPS:
				// Get the groups...
#			$grList = t3lib_BEfunc::getSQLselectableList($this->user[$this->usergroup_column],$this->usergroup_table,$this->usergroup_table);
			$grList = $GLOBALS['TYPO3_DB']->cleanIntList($this->user[$this->usergroup_column]);	// 240203: Since the group-field never contains any references to groups with a prepended table name we think it's safe to just intExplode and re-implode - which should be much faster than the other function call.
			if ($grList)	{
					// Fetch groups will add a lot of information to the internal arrays: modules, accesslists, TSconfig etc. Refer to fetchGroups() function.
				$this->fetchGroups($grList);
			}

				// Add the TSconfig for this specific user:
			$this->TSdataArray[] = $this->addTScomment('USER TSconfig field').$this->user['TSconfig'];
				// Check include lines.
			$this->TSdataArray = t3lib_TSparser::checkIncludeLines_array($this->TSdataArray);

				// Parsing the user TSconfig (or getting from cache)
			$this->userTS_text = implode(chr(10).'[GLOBAL]'.chr(10),$this->TSdataArray);	// Imploding with "[global]" will make sure that non-ended confinements with braces are ignored.
			$hash = md5('userTS:'.$this->userTS_text);
			$cachedContent = t3lib_BEfunc::getHash($hash,0);
			if (isset($cachedContent) && !$this->userTS_dontGetCached)	{
				$this->userTS = unserialize($cachedContent);
			} else {
				$parseObj = t3lib_div::makeInstance('t3lib_TSparser');
				$parseObj->parse($this->userTS_text);
				$this->userTS = $parseObj->setup;
				t3lib_BEfunc::storeHash($hash,serialize($this->userTS),'BE_USER_TSconfig');
					// Update UC:
				$this->userTSUpdated=1;
			}

				// Processing webmounts
			if ($this->isAdmin() && !$this->getTSConfigVal('options.dontMountAdminMounts'))	{	// Admin's always have the root mounted
				$this->dataLists['webmount_list']='0,'.$this->dataLists['webmount_list'];
			}

				// Processing filemounts
			$this->dataLists['filemount_list'] = t3lib_div::uniqueList($this->dataLists['filemount_list']);
			if ($this->dataLists['filemount_list'])	{
				$res = $GLOBALS['TYPO3_DB']->exec_SELECTquery('*', 'sys_filemounts', 'NOT deleted AND NOT hidden AND pid=0 AND uid IN ('.$this->dataLists['filemount_list'].')');
				while ($row = $GLOBALS['TYPO3_DB']->sql_fetch_assoc($res))	{
					$this->addFileMount($row['title'], $row['path'], $row['path'], $row['base']?1:0, '');
				}
			}

				// The lists are cleaned for duplicates
			$this->groupData['webmounts'] = t3lib_div::uniqueList($this->dataLists['webmount_list']);
			$this->groupData['pagetypes_select'] = t3lib_div::uniqueList($this->dataLists['pagetypes_select']);
			$this->groupData['tables_select'] = t3lib_div::uniqueList($this->dataLists['tables_modify'].','.$this->dataLists['tables_select']);
			$this->groupData['tables_modify'] = t3lib_div::uniqueList($this->dataLists['tables_modify']);
			$this->groupData['non_exclude_fields'] = t3lib_div::uniqueList($this->dataLists['non_exclude_fields']);
			$this->groupData['explicit_allowdeny'] = t3lib_div::uniqueList($this->dataLists['explicit_allowdeny']);
			$this->groupData['allowed_languages'] = t3lib_div::uniqueList($this->dataLists['allowed_languages']);
			$this->groupData['custom_options'] = t3lib_div::uniqueList($this->dataLists['custom_options']);
			$this->groupData['modules'] = t3lib_div::uniqueList($this->dataLists['modList']);

				// populating the $this->userGroupsUID -array with the groups in the order in which they were LAST included.!!
			$this->userGroupsUID = array_reverse(array_unique(array_reverse($this->includeGroupArray)));

				// Finally this is the list of group_uid's in the order they are parsed (including subgroups!) and without duplicates (duplicates are presented with their last entrance in the list, which thus reflects the order of the TypoScript in TSconfig)
			$this->groupList = implode(',',$this->userGroupsUID);
			$this->setCachedList($this->groupList);
		}
	}

	/**
	 * Fetches the group records, subgroups and fills internal arrays.
	 * Function is called recursively to fetch subgroups
	 *
	 * @param	string		Commalist of be_groups uid numbers
	 * @param	string		List of already processed be_groups-uids so the function will not fall into a eternal recursion.
	 * @return	void
	 * @access private
	 */
	function fetchGroups($grList,$idList='')	{

			// Fetching records of the groups in $grList (which are not blocked by lockedToDomain either):
		$lockToDomain_SQL = ' AND (lockToDomain="" OR lockToDomain="'.t3lib_div::getIndpEnv('HTTP_HOST').'")';
		$res = $GLOBALS['TYPO3_DB']->exec_SELECTquery('*', $this->usergroup_table, 'NOT deleted AND NOT hidden AND pid=0 AND uid IN ('.$grList.')'.$lockToDomain_SQL);

			// The userGroups array is filled
		while ($row = $GLOBALS['TYPO3_DB']->sql_fetch_assoc($res))	{
			$this->userGroups[$row['uid']] = $row;
		}

			// Traversing records in the correct order
		$include_staticArr = t3lib_div::intExplode(',',$grList);
		reset($include_staticArr);
		while(list(,$uid)=each($include_staticArr))	{	// traversing list

				// Get row:
			$row=$this->userGroups[$uid];
			if (is_array($row) && !t3lib_div::inList($idList,$uid))	{	// Must be an array and $uid should not be in the idList, because then it is somewhere previously in the grouplist

					// Include sub groups
				if (trim($row['subgroup']))	{
					$theList = implode(',',t3lib_div::intExplode(',',$row['subgroup']));	// Make integer list
					$this->fetchGroups($theList, $idList.','.$uid);		// Call recursively, pass along list of already processed groups so they are not recursed again.
				}
					// Add the group uid, current list, TSconfig to the internal arrays.
				$this->includeGroupArray[]=$uid;
				$this->includeHierarchy[]=$idList;
				$this->TSdataArray[] = $this->addTScomment('Group "'.$row['title'].'" ['.$row['uid'].'] TSconfig field:').$row['TSconfig'];

					// Mount group database-mounts
				if (($this->user['options']&1) == 1)	{	$this->dataLists['webmount_list'].= ','.$row['db_mountpoints'];	}

					// Mount group file-mounts
				if (($this->user['options']&2) == 2)	{	$this->dataLists['filemount_list'].= ','.$row['file_mountpoints'];	}

					// Mount group home-dirs
				if (($this->user['options']&2) == 2)	{
						// If groupHomePath is set, we attempt to mount it
					if ($GLOBALS['TYPO3_CONF_VARS']['BE']['groupHomePath'])	{
						$this->addFileMount($row['title'], '', $GLOBALS['TYPO3_CONF_VARS']['BE']['groupHomePath'].$row['uid'], 0, 'group');
					}
				}

					// The lists are made: groupMods, tables_select, tables_modify, pagetypes_select, non_exclude_fields, explicit_allowdeny, allowed_languages, custom_options
				if ($row['inc_access_lists']==1)	{
					$this->dataLists['modList'].= ','.$row['groupMods'];
					$this->dataLists['tables_select'].= ','.$row['tables_select'];
					$this->dataLists['tables_modify'].= ','.$row['tables_modify'];
					$this->dataLists['pagetypes_select'].= ','.$row['pagetypes_select'];
					$this->dataLists['non_exclude_fields'].= ','.$row['non_exclude_fields'];
					$this->dataLists['explicit_allowdeny'].= ','.$row['explicit_allowdeny'];
					$this->dataLists['allowed_languages'].= ','.$row['allowed_languages'];
					$this->dataLists['custom_options'].= ','.$row['custom_options'];
				}
					// If this function is processing the users OWN group-list (not subgroups) AND if the ->firstMainGroup is not set, then the ->firstMainGroup will be set.
				if (!strcmp($idList,'') && !$this->firstMainGroup)	{
					$this->firstMainGroup=$uid;
				}
			}
		}

	}

	/**
	 * Updates the field be_users.usergroup_cached_list if the groupList of the user has changed/is different from the current list.
	 * The field "usergroup_cached_list" contains the list of groups which the user is a member of. After authentication (where these functions are called...) one can depend on this list being a representation of the exact groups/subgroups which the BE_USER has membership with.
	 *
	 * @param	string		The newly compiled group-list which must be compared with the current list in the user record and possibly stored if a difference is detected.
	 * @return	void
	 * @access private
	 */
	function setCachedList($cList)	{
		if ((string)$cList != (string)$this->user['usergroup_cached_list'])	{
			$GLOBALS['TYPO3_DB']->exec_UPDATEquery('be_users', 'uid='.intval($this->user['uid']), array('usergroup_cached_list' => $cList));
		}
	}

	/**
	 * Adds a filemount to the users array of filemounts, $this->groupData['filemounts'][hash_key] = Array ('name'=>$name, 'path'=>$path, 'type'=>$type);
	 * Is a part of the authentication proces of the user.
	 * A final requirement for a path being mounted is that a) it MUST return true on is_dir(), b) must contain either PATH_site+'fileadminDir' OR 'lockRootPath' - if lockRootPath is set - as first part of string!
	 * Paths in the mounted information will always be absolute and have a trailing slash.
	 *
	 * @param	string		$title will be the (root)name of the filemount in the folder tree
	 * @param	string		$altTitle will be the (root)name of the filemount IF $title is not true (blank or zero)
	 * @param	string		$path is the path which should be mounted. Will accept backslash in paths on windows servers (will substituted with forward slash). The path should be 1) relative to TYPO3_CONF_VARS[BE][fileadminDir] if $webspace is set, otherwise absolute.
	 * @param	boolean		If $webspace is set, the $path is relative to 'fileadminDir' in TYPO3_CONF_VARS, otherwise $path is absolute. 'fileadminDir' must be set to allow mounting of relative paths.
	 * @param	string		Type of filemount; Can be blank (regular) or "user" / "group" (for user and group filemounts presumably). Probably sets the icon first and foremost.
	 * @return	boolean		Returns "1" if the requested filemount was mounted, otherwise no return value.
	 * @access private
	 */
	function addFileMount($title, $altTitle, $path, $webspace, $type)	{
			// Return false if fileadminDir is not set and we try to mount a relative path
		if ($webspace && !$GLOBALS['TYPO3_CONF_VARS']['BE']['fileadminDir'])	return false;

			// Trimming and pre-processing
		$path=trim($path);
		if ($this->OS=='WIN')	{		// with WINDOWS convert backslash to slash!!
			$path=str_replace('\\','/',$path);
		}
			// If the path is true and validates as a valid path string:
		if ($path && t3lib_div::validPathStr($path))	{
				// these lines remove all slashes and dots before and after the path
			$path=ereg_replace('^[\/\. ]*','',$path);
			$path=trim(ereg_replace('[\/\. ]*$','',$path));


			if ($path)	{	// there must be some chars in the path
				$fdir=PATH_site.$GLOBALS['TYPO3_CONF_VARS']['BE']['fileadminDir'];	// fileadmin dir, absolute
				if ($webspace)	{
					$path=$fdir.$path;	// PATH_site + fileadmin dir is prepended
				} else {
					if ($this->OS!='WIN')	{		// with WINDOWS no prepending!!
						$path='/'.$path;	// root-level is the start...
					}
				}
				$path.='/';

					// We now have a path with slash after and slash before (if unix)
				if (@is_dir($path) &&
					(($GLOBALS['TYPO3_CONF_VARS']['BE']['lockRootPath'] && t3lib_div::isFirstPartOfStr($path,$GLOBALS['TYPO3_CONF_VARS']['BE']['lockRootPath'])) || t3lib_div::isFirstPartOfStr($path,$fdir)))	{
							// Alternative title?
						$name = $title ? $title : $altTitle;
							// Adds the filemount. The same filemount with same name, type and path cannot be set up twice because of the hash string used as key.
						$this->groupData['filemounts'][md5($name.'|'.$path.'|'.$type)] = Array('name'=>$name, 'path'=>$path, 'type'=>$type);
							// Return true - went well, success!
						return 1;
				}
			}
		}
	}

	/**
	 * Creates a TypoScript comment with the string text inside.
	 *
	 * @param	string		The text to wrap in comment prefixes and delimiters.
	 * @return	string		TypoScript comment with the string text inside.
	 */
	function addTScomment($str)	{
		$delimiter = '# ***********************************************';

		$out = $delimiter.chr(10);
		$lines = t3lib_div::trimExplode(chr(10),$str);
		foreach($lines as $v)	{
			$out.= '# '.$v.chr(10);
		}
		$out.= $delimiter.chr(10);
		return $out;
	}












	/************************************
	 *
	 * Logging
	 *
	 ************************************/


	/**
	 * Writes an entry in the logfile
	 * ... Still missing documentation for syntax etc...
	 *
	 * @param	integer		$type: denotes which module that has submitted the entry. This is the current list:  1=tce_db; 2=tce_file; 3=system (eg. sys_history save); 4=modules; 254=Personal settings changed; 255=login / out action: 1=login, 2=logout, 3=failed login (+ errorcode 3), 4=failure_warning_email sent
	 * @param	integer		$action: denotes which specific operation that wrote the entry (eg. 'delete', 'upload', 'update' and so on...). Specific for each $type. Also used to trigger update of the interface. (see the log-module for the meaning of each number !!)
	 * @param	integer		$error: flag. 0 = message, 1 = error (user problem), 2 = System Error (which should not happen), 3 = security notice (admin)
	 * @param	integer		$details_nr: The message number. Specific for each $type and $action. in the future this will make it possible to translate errormessages to other languages
	 * @param	string		$details: Default text that follows the message
	 * @param	array		$data: Data that follows the log. Might be used to carry special information. If an array the first 5 entries (0-4) will be sprintf'ed the details-text...
	 * @param	string		$tablename: Special field used by tce_main.php. These ($tablename, $recuid, $recpid) holds the reference to the record which the log-entry is about. (Was used in attic status.php to update the interface.)
	 * @param	integer		$recuid: Special field used by tce_main.php. These ($tablename, $recuid, $recpid) holds the reference to the record which the log-entry is about. (Was used in attic status.php to update the interface.)
	 * @param	integer		$recpid: Special field used by tce_main.php. These ($tablename, $recuid, $recpid) holds the reference to the record which the log-entry is about. (Was used in attic status.php to update the interface.)
	 * @param	integer		$event_pid: The page_uid (pid) where the event occurred. Used to select log-content for specific pages.
	 * @param	string		$NEWid: NEWid string
	 * @return	void
	 */
	function writelog($type,$action,$error,$details_nr,$details,$data,$tablename='',$recuid='',$recpid='',$event_pid=-1,$NEWid='') {

		$fields_values = Array (
			'userid' => intval($this->user['uid']),
			'type' => intval($type),
			'action' => intval($action),
			'error' => intval($error),
			'details_nr' => intval($details_nr),
			'details' => $details,
			'log_data' => serialize($data),
			'tablename' => $tablename,
			'recuid' => intval($recuid),
			'recpid' => intval($recpid),
			'IP' => t3lib_div::getIndpEnv('REMOTE_ADDR'),
			'tstamp' => $GLOBALS['EXEC_TIME'],
			'event_pid' => intval($event_pid),
			'NEWid' => $NEWid
		);

		$GLOBALS['TYPO3_DB']->exec_INSERTquery('sys_log', $fields_values);
		return $GLOBALS['TYPO3_DB']->sql_insert_id();
	}

	/**
	 * Sends a warning to $email if there has been a certain amount of failed logins during a period.
	 * If a login fails, this function is called. It will look up the sys_log to see if there has been more than $max failed logins the last $secondsBack seconds (default 3600). If so, an email with a warning is sent to $email.
	 *
	 * @param	string		Email address
	 * @param	integer		Number of sections back in time to check. This is a kind of limit for how many failures an hour for instance.
	 * @param	integer		Max allowed failures before a warning mail is sent
	 * @return	void
	 * @access private
	 */
	function checkLogFailures($email, $secondsBack=3600, $max=3)	{
		if ($email)	{

				// get last flag set in the log for sending
			$theTimeBack = time()-$secondsBack;
			$res = $GLOBALS['TYPO3_DB']->exec_SELECTquery(
							'tstamp',
							'sys_log',
							'type=255 AND action=4 AND tstamp>'.intval($theTimeBack),
							'',
							'tstamp DESC',
							'1'
						);
			if ($testRow = $GLOBALS['TYPO3_DB']->sql_fetch_assoc($res))	{
				$theTimeBack = $testRow['tstamp'];
			}

				// Check for more than $max number of error failures with the last period.
			$res = $GLOBALS['TYPO3_DB']->exec_SELECTquery(
							'*',
							'sys_log',
							'type=255 AND action=3 AND error!=0 AND tstamp>'.intval($theTimeBack),
							'',
							'tstamp'
						);
			if ($GLOBALS['TYPO3_DB']->sql_num_rows($res) > $max)	{
					// OK, so there were more than the max allowed number of login failures - so we will send an email then.
				$subject = 'TYPO3 Login Failure Warning (at '.$GLOBALS['TYPO3_CONF_VARS']['SYS']['sitename'].')';
				$email_body = '
There has been numerous attempts ('.$GLOBALS['TYPO3_DB']->sql_num_rows($res).') to login at the TYPO3
site "'.$GLOBALS['TYPO3_CONF_VARS']['SYS']['sitename'].'" ('.t3lib_div::getIndpEnv('HTTP_HOST').').

This is a dump of the failures:

';
				while($testRows = $GLOBALS['TYPO3_DB']->sql_fetch_assoc($res))	{
					$theData = unserialize($testRows['log_data']);
					$email_body.=date($GLOBALS['TYPO3_CONF_VARS']['SYS']['ddmmyy'].' H:i',$testRows['tstamp']).':  '.@sprintf($testRows['details'],''.$theData[0],''.$theData[1],''.$theData[2]);
					$email_body.=chr(10);
				}
				mail(	$email,
						$subject,
						$email_body,
						'From: TYPO3 Login WARNING<>'
				);
				$this->writelog(255,4,0,3,'Failure warning (%s failures within %s seconds) sent by email to %s',Array($GLOBALS['TYPO3_DB']->sql_num_rows($res),$secondsBack,$email));	// Logout written to log
			}
		}
	}


	/************************************
	*
	* The following functions are from t3lib_userauth
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	* Borg
	 ************************************/


	/**
	 * Redirect to somewhere. Obsolete, depreciated etc.
	 *
	 * @return	void
	 * @ignore
	 */
	function redirect() {
		if (!$this->userid && $this->auth_url)	{	 // if no userid AND an include-document for login is given
			include ($this->auth_include);
			exit;
		}
	}



	/**
	 * Log out current user!
	 * Removes the current session record, sets the internal ->user array to a blank string; Thereby the current user (if any) is effectively logged out!
	 *
	 * @return	void
	 */
	function logoff() {

		$GLOBALS['TYPO3_DB']->exec_UPDATEquery('be_users', 'uid='.intval($GLOBALS['BE_USER']->user['uid']), array('tx_typoflash_status' => 0));


		$GLOBALS['TYPO3_DB']->exec_DELETEquery('be_sessions','ses_id = "'.$GLOBALS['TYPO3_DB']->quoteStr($this->id,'be_sessions').'" AND ses_name = "'.$GLOBALS['TYPO3_DB']->quoteStr($this->name,'be_sessions').'"');


/*
		$GLOBALS['TYPO3_DB']->exec_DELETEquery(
					$this->session_table,
					'ses_id = "'.$GLOBALS['TYPO3_DB']->quoteStr($this->id, $this->session_table).'"
						AND ses_name = "'.$GLOBALS['TYPO3_DB']->quoteStr($this->name, $this->session_table).'"'
				);*/

		$this->user = "";
		if(mysql_error()){
			$error = array("errortype"=>2,"errormsg"=>mysql_error()); 
			return $error;

		}else{
			return true;
		}
	}

	/**
	 * Garbage collector, removing old expired sessions.
	 *
	 * @return	void
	 * @internal
	 */
	function gc() {
		$GLOBALS['TYPO3_DB']->exec_DELETEquery('be_sessions','ses_tstamp < '.intval(time()-($this->gc_time*60*60)).' AND ses_name = "'.$GLOBALS['TYPO3_DB']->quoteStr($this->name, 'be_sessions').'"');
	}

	/**
	 * This returns the where-clause needed to select the user with respect flags like deleted, hidden, starttime, endtime
	 *
	 * @return	string
	 * @access private
	 */
	function user_where_clause()	{
		return  (($this->enablecolumns['rootLevel']) ? 'AND '.$this->user_table.'.pid=0 ' : '').
				(($this->enablecolumns['disabled']) ? ' AND NOT '.$this->user_table.'.'.$this->enablecolumns['disabled'] : '').
				(($this->enablecolumns['deleted']) ? ' AND NOT '.$this->user_table.'.'.$this->enablecolumns['deleted'] : '').
				(($this->enablecolumns['starttime']) ? ' AND ('.$this->user_table.'.'.$this->enablecolumns['starttime'].'<='.time().')' : '').
				(($this->enablecolumns['endtime']) ? ' AND ('.$this->user_table.'.'.$this->enablecolumns['endtime'].'=0 OR '.$this->user_table.'.'.$this->enablecolumns['endtime'].'>'.time().')' : '');
	}

	/**
	 * This returns the where-clause needed to lock a user to the IP address
	 *
	 * @return	string
	 * @access private
	 */
	function ipLockClause()	{
		if ($this->lockIP)	{
			$wherePart = 'AND (
				'.'be_sessions'.'.ses_iplock="'.$GLOBALS['TYPO3_DB']->quoteStr($this->ipLockClause_remoteIPNumber($this->lockIP),'be_sessions').'"
				OR '.'be_sessions'.'.ses_iplock="[DISABLED]"
				)';
			return $wherePart;
		}
	}

	/**
	 * Returns the IP address to lock to.
	 * The IP address may be partial based on $parts.
	 *
	 * @param	integer		1-4: Indicates how many parts of the IP address to return. 4 means all, 1 means only first number.
	 * @return	string		(Partial) IP address for REMOTE_ADDR
	 * @access private
	 */
	function ipLockClause_remoteIPNumber($parts)	{
		$IP = t3lib_div::getIndpEnv('REMOTE_ADDR');

		if ($parts>=4)	{
			return $IP;
		} else {
			$parts = t3lib_div::intInRange($parts,1,3);
			$IPparts = explode('.',$IP);
			for($a=4;$a>$parts;$a--)	{
				unset($IPparts[$a-1]);
			}
			return implode('.',$IPparts);
		}
	}

	/**
	 * This returns the where-clause needed to lock a user to a hash integer
	 *
	 * @return	string
	 * @access private
	 */
	function hashLockClause()	{
		$wherePart = 'AND '.'be_sessions'.'.ses_hashlock='.intval($this->hashLockClause_getHashInt());
		return $wherePart;
	}

	/**
	 * Creates hash integer to lock user to. Depends on configured keywords
	 *
	 * @return	integer		Hash integer
	 * @access private
	 */
	function hashLockClause_getHashInt()	{
		$hashStr = '';

		if (t3lib_div::inList($this->lockHashKeyWords,'useragent'))	$hashStr.=':'.t3lib_div::getIndpEnv('HTTP_USER_AGENT');

		return t3lib_div::md5int($hashStr);
	}

	/**
	 * This writes $variable to the user-record. This is a way of providing session-data.
	 * You can fetch the data again through $this->uc in this class!
	 * If $variable is not an array, $this->uc is saved!
	 *
	 * @param	array		An array you want to store for the user as session data. If $variable is not supplied (is blank string), the internal variable, ->uc, is stored by default
	 * @return	void
	 */
	function writeUC($variable='')	{
		if (is_array($this->user) && $this->user['uid'])	{
			if (!is_array($variable)) { $variable = $this->uc; }

			$GLOBALS['TYPO3_DB']->exec_UPDATEquery($this->user_table, 'uid='.intval($this->user['uid']), array('uc' => serialize($variable)));
		}
	}


	/**
	 * Sets $theUC as the internal variable ->uc IF $theUC is an array. If $theUC is false, the 'uc' content from the ->user array will be unserialized and restored in ->uc
	 *
	 * @param	mixed		If an array, then set as ->uc, otherwise load from user record
	 * @return	void
	 */
	function unpack_uc($theUC='') {
		if (!$theUC) 	$theUC=unserialize($this->user['uc']);
		if (is_array($theUC))	{
			$this->uc=$theUC;
		}
	}

	/**
	 * Stores data for a module.
	 * The data is stored with the session id so you can even check upon retrieval if the module data is from a previous session or from the current session.
	 *
	 * @param	string		$module is the name of the module ($MCONF['name'])
	 * @param	mixed		$data is the data you want to store for that module (array, string, ...)
	 * @param	boolean		If $noSave is set, then the ->uc array (which carries all kinds of user data) is NOT written immediately, but must be written by some subsequent call.
	 * @return	void
	 */
	function pushModuleData($module,$data,$noSave=0)	{
		$this->uc['moduleData'][$module] = $data;
		$this->uc['moduleSessionID'][$module] = $this->id;
		if (!$noSave) $this->writeUC();
	}

	/**
	 * Gets module data for a module (from a loaded ->uc array)
	 *
	 * @param	string		$module is the name of the module ($MCONF['name'])
	 * @param	string		If $type = 'ses' then module data is returned only if it was stored in the current session, otherwise data from a previous session will be returned (if available).
	 * @return	mixed		The module data if available: $this->uc['moduleData'][$module];
	 */
	function getModuleData($module,$type='')	{
		if ($type!='ses' || $this->uc['moduleSessionID'][$module]==$this->id) {
			return $this->uc['moduleData'][$module];
		}
	}

	/**
	 * Returns the session data stored for $key.
	 * The data will last only for this login session since it is stored in the session table.
	 *
	 * @param	string		Pointer to an associative key in the session data array which is stored serialized in the field "ses_data" of the session table.
	 * @return	mixed
	 */
	function getSessionData($key)	{
		$sesDat = unserialize($this->user['ses_data']);
		return $sesDat[$key];
	}

	/**
	 * Sets the session data ($data) for $key and writes all session data (from ->user['ses_data']) to the database.
	 * The data will last only for this login session since it is stored in the session table.
	 *
	 * @param	string		Pointer to an associative key in the session data array which is stored serialized in the field "ses_data" of the session table.
	 * @param	mixed		The variable to store in index $key
	 * @return	void
	 */
	function setAndSaveSessionData($key,$data)	{
		$sesDat = unserialize($this->user['ses_data']);
		$sesDat[$key] = $data;
		$this->user['ses_data'] = serialize($sesDat);

		$GLOBALS['TYPO3_DB']->exec_UPDATEquery('be_sessions', 'ses_id="'.$GLOBALS['TYPO3_DB']->quoteStr($this->user['ses_id'], 'be_sessions').'"', array('ses_data' => $this->user['ses_data']));
	}

	/**
	 * Raw initialization of the be_user with uid=$uid
	 * This will circumvent all login procedures and select a be_users record from the database and set the content of ->user to the record selected. Thus the BE_USER object will appear like if a user was authenticated - however without a session id and the fields from the session table of course.
	 * Will check the users for disabled, start/endtime, etc. ($this->user_where_clause())
	 *
	 * @param	integer		The UID of the backend user to set in ->user
	 * @return	void
	 * @params integer	'uid' of be_users record to select and set.
	 * @internal
	 * @see SC_mod_tools_be_user_index::compareUsers(), SC_mod_user_setup_index::simulateUser(), freesite_admin::startCreate()
	 */
	function setBeUserByUid($uid)	{
		$dbres = $GLOBALS['TYPO3_DB']->exec_SELECTquery('*', $this->user_table, 'uid="'.intval($uid).'" '.$this->user_where_clause());
		$this->user = $GLOBALS['TYPO3_DB']->sql_fetch_assoc($dbres);
	}

	/**
	 * Raw initialization of the be_user with username=$name
	 *
	 * @param	string		The username to look up.
	 * @return	void
	 * @see	t3lib_userAuth::setBeUserByUid()
	 * @internal
	 */
	function setBeUserByName($name)	{
		$dbres = $GLOBALS['TYPO3_DB']->exec_SELECTquery('*', $this->user_table, 'username="'.$GLOBALS['TYPO3_DB']->quoteStr($name, $this->user_table).'" '.$this->user_where_clause());
		$this->user = $GLOBALS['TYPO3_DB']->sql_fetch_assoc($dbres);
	}



	/************************************
	*
	* The following functions are from t3lib_tsfebeuserauth
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	*
	* Borg
	 ************************************/

	/*****************************************************
	 *
	 * TSFE BE user Access Functions
	 *
	 ****************************************************/

	/**
	 * Implementing the access checks that the typo3/init.php script does before a user is ever logged in.
	 * Used in the frontend.
	 *
	 * @return	boolean		Returns true if access is OK
	 * @see typo3/init.php, t3lib_beuserauth::backendCheckLogin()
	 */
	function checkBackendAccessSettingsFromInitPhp()	{
		global $TYPO3_CONF_VARS;

		// **********************
		// Check Hardcoded lock on BE:
		// **********************
		if ($TYPO3_CONF_VARS['BE']['adminOnly'] < 0)	{
			return FALSE;
		}

		// **********************
		// Check IP
		// **********************
		if (trim($TYPO3_CONF_VARS['BE']['IPmaskList']))	{
			if (!t3lib_div::cmpIP(t3lib_div::getIndpEnv('REMOTE_ADDR'), $TYPO3_CONF_VARS['BE']['IPmaskList']))	{
				return FALSE;
			}
		}


		// **********************
		// Check SSL (https)
		// **********************
		if (intval($TYPO3_CONF_VARS['BE']['lockSSL']))	{
			if (!t3lib_div::getIndpEnv('TYPO3_SSL'))	{
				return FALSE;
			}
		}

			// Finally a check from t3lib_beuserauth::backendCheckLogin()
		if (!$TYPO3_CONF_VARS['BE']['adminOnly'] || $this->isAdmin())	{
			return TRUE;
		} else return FALSE;
	 }

/********************************456*/

	/**
	 * Initialize the usage of Admin Panel.
	 * Called from index_ts.php if a backend users is correctly logged in.
	 * Sets $this->extAdminConfig to the "admPanel" config for the user and $this->extAdmEnabled = 1 IF access is enabled.
	 *
	 * @return	void
	 */
	function extInitFeAdmin()	{
		$this->extAdminConfig = $this->getTSConfigProp('admPanel');
		if (is_array($this->extAdminConfig['enable.']))	{
			reset($this->extAdminConfig['enable.']);
			while(list($k,$v)=each($this->extAdminConfig['enable.']))	{
				if ($v)	{
						// Enable panel
					$this->extAdmEnabled=1;

						// Init TSFE_EDIT variables:
					$this->TSFE_EDIT = t3lib_div::_POST('TSFE_EDIT');

					break;
				}
			}
		}
	}

	/**
	 * Creates and returns the HTML code for the Admin Panel in the TSFE frontend.
	 * Called from index_ts.php - in the end of the script
	 *
	 * @return	string		HTML for the Admin Panel
	 * @see index_ts.php
	 */
	function extPrintFeAdminDialog()	{

		if ($this->uc['TSFE_adminConfig']['display_top'])	{
			if ($this->extAdmModuleEnabled('preview'))	$out.= $this->extGetCategory_preview();
			if ($this->extAdmModuleEnabled('cache'))	$out.= $this->extGetCategory_cache();
			if ($this->extAdmModuleEnabled('publish'))	$out.= $this->extGetCategory_publish();
			if ($this->extAdmModuleEnabled('edit'))	$out.= $this->extGetCategory_edit();
			if ($this->extAdmModuleEnabled('tsdebug'))	$out.= $this->extGetCategory_tsdebug();
			if ($this->extAdmModuleEnabled('info'))	$out.= $this->extGetCategory_info();
		}

		$header.='
			<tr class="typo3-adminPanel-hRow" bgcolor="#9BA1A8">
				<td colspan="2" nowrap="nowrap">'.
					$this->extItemLink('top','<img src="t3lib/gfx/ol/'.($this->uc['TSFE_adminConfig']['display_top']?'minus':'plus').'bullet.gif" width="18" height="16" align="absmiddle" border="0" alt="" /><strong>'.$this->extFw($this->extGetLL('adminOptions')).'</strong>').
					$this->extFw(': '.$this->user['username']).
					'</td>
				<td><img src="clear.gif" width="10" height="1" alt="" /></td>
				<td><input type="hidden" name="TSFE_ADMIN_PANEL[display_top]" value="'.$this->uc['TSFE_adminConfig']['display_top'].'" />'.($this->extNeedUpdate?'<input type="submit" value="'.$this->extGetLL('update').'" />':'').'</td>
			</tr>';

		$out='
<!--
	ADMIN PANEL
-->
<a name="TSFE_ADMIN"></a>
<form name="TSFE_ADMIN_PANEL_FORM" action="'.htmlspecialchars(t3lib_div::getIndpEnv('REQUEST_URI')).'#TSFE_ADMIN" method="post" style="margin: 0 0 0 0;">
	<table border="0" cellpadding="0" cellspacing="0" class="typo3-adminPanel" bgcolor="#F6F2E6" style="border: 1px solid black; z-index:0; position:absolute;">'.
		$header.$out.'
	</table>
</form>';

		if ($this->uc['TSFE_adminConfig']['display_top'])	{
			$out.='<script type="text/javascript" src="t3lib/jsfunc.evalfield.js"></script>';
			$out.='
			<script type="text/javascript">
					/*<![CDATA[*/
				var evalFunc = new evalFunc();
					// TSFEtypo3FormFieldSet()
				function TSFEtypo3FormFieldSet(theField, evallist, is_in, checkbox, checkboxValue)	{	//
					var theFObj = new evalFunc_dummy (evallist,is_in, checkbox, checkboxValue);
					var theValue = document.TSFE_ADMIN_PANEL_FORM[theField].value;
					if (checkbox && theValue==checkboxValue)	{
						document.TSFE_ADMIN_PANEL_FORM[theField+"_hr"].value="";
						document.TSFE_ADMIN_PANEL_FORM[theField+"_cb"].checked = "";
					} else {
						document.TSFE_ADMIN_PANEL_FORM[theField+"_hr"].value = evalFunc.outputObjValue(theFObj, theValue);
						document.TSFE_ADMIN_PANEL_FORM[theField+"_cb"].checked = "on";
					}
				}
					// TSFEtypo3FormFieldGet()
				function TSFEtypo3FormFieldGet(theField, evallist, is_in, checkbox, checkboxValue, checkbox_off)	{	//
					var theFObj = new evalFunc_dummy (evallist,is_in, checkbox, checkboxValue);
					if (checkbox_off)	{
						document.TSFE_ADMIN_PANEL_FORM[theField].value=checkboxValue;
					}else{
						document.TSFE_ADMIN_PANEL_FORM[theField].value = evalFunc.evalObjValue(theFObj, document.TSFE_ADMIN_PANEL_FORM[theField+"_hr"].value);
					}
					TSFEtypo3FormFieldSet(theField, evallist, is_in, checkbox, checkboxValue);
				}
					/*]]>*/
			</script>
			<script language="javascript" type="text/javascript">'.$this->extJSCODE.'</script>';
		}
		return "\n\n\n\n".$out.'<br />';
	}
















	/*****************************************************
	 *
	 * Creating sections of the Admin Panel
	 *
	 ****************************************************/

	/**
	 * Creates the content for the "preview" section ("module") of the Admin Panel
	 *
	 * @param	string		Optional start-value; The generated content is added to this variable.
	 * @return	string		HTML content for the section. Consists of a string with table-rows with four columns.
	 * @see extPrintFeAdminDialog()
	 */
	function extGetCategory_preview($out='')	{
		$out.=$this->extGetHead('preview');
		if ($this->uc['TSFE_adminConfig']['display_preview'])	{
			$this->extNeedUpdate = 1;
			$out.= $this->extGetItem('preview_showHiddenPages', '<input type="hidden" name="TSFE_ADMIN_PANEL[preview_showHiddenPages]" value="0" /><input type="checkbox" name="TSFE_ADMIN_PANEL[preview_showHiddenPages]" value="1"'.($this->uc['TSFE_adminConfig']['preview_showHiddenPages']?' checked="checked"':'').' />');
			$out.= $this->extGetItem('preview_showHiddenRecords', '<input type="hidden" name="TSFE_ADMIN_PANEL[preview_showHiddenRecords]" value="0" /><input type="checkbox" name="TSFE_ADMIN_PANEL[preview_showHiddenRecords]" value="1"'.($this->uc['TSFE_adminConfig']['preview_showHiddenRecords']?' checked="checked"':'').' />');

				// Simulate data
			$out.= $this->extGetItem('preview_simulateDate', '<input type="checkbox" name="TSFE_ADMIN_PANEL[preview_simulateDate]_cb" onclick="TSFEtypo3FormFieldGet(\'TSFE_ADMIN_PANEL[preview_simulateDate]\', \'datetime\', \'\',1,0,1);" /><input type="text" name="TSFE_ADMIN_PANEL[preview_simulateDate]_hr" onchange="TSFEtypo3FormFieldGet(\'TSFE_ADMIN_PANEL[preview_simulateDate]\', \'datetime\', \'\', 1,0);" /><input type="hidden" name="TSFE_ADMIN_PANEL[preview_simulateDate]" value="'.$this->uc['TSFE_adminConfig']['preview_simulateDate'].'" />');
			$this->extJSCODE.= 'TSFEtypo3FormFieldSet("TSFE_ADMIN_PANEL[preview_simulateDate]", "datetime", "", 1,0);';

				// Simulate fe_user:
			$options = '<option value="0"></option>';
			$res = $GLOBALS['TYPO3_DB']->exec_SELECTquery(
						'fe_groups.uid, fe_groups.title',
						'fe_groups,pages',
						'pages.uid=fe_groups.pid AND NOT pages.deleted '.t3lib_BEfunc::deleteClause('fe_groups').' AND '.$this->getPagePermsClause(1)
					);
			while($row = $GLOBALS['TYPO3_DB']->sql_fetch_assoc($res))	{
				$options.= '<option value="'.$row['uid'].'"'.($this->uc['TSFE_adminConfig']['preview_simulateUserGroup']==$row['uid']?' selected="selected"':'').'>'.htmlspecialchars('['.$row['uid'].'] '.$row['title']).'</option>';
			}
			$out.= $this->extGetItem('preview_simulateUserGroup', '<select name="TSFE_ADMIN_PANEL[preview_simulateUserGroup]">'.$options.'</select>');
		}
		return $out;
	}

	/**
	 * Creates the content for the "cache" section ("module") of the Admin Panel
	 *
	 * @param	string		Optional start-value; The generated content is added to this variable.
	 * @return	string		HTML content for the section. Consists of a string with table-rows with four columns.
	 * @see extPrintFeAdminDialog()
	 */
	function extGetCategory_cache($out='')	{
		$out.=$this->extGetHead('cache');
		if ($this->uc['TSFE_adminConfig']['display_cache'])	{
			$this->extNeedUpdate=1;
			$out.=$this->extGetItem('cache_noCache', '<input type="hidden" name="TSFE_ADMIN_PANEL[cache_noCache]" value="0" /><input type="checkbox" name="TSFE_ADMIN_PANEL[cache_noCache]" value="1"'.($this->uc['TSFE_adminConfig']['cache_noCache']?' checked="checked"':'').' />');

			$options='';
			$options.='<option value="0"'.($this->uc['TSFE_adminConfig']['cache_clearCacheLevels']==0?' selected="selected"':'').'>'.$this->extGetLL('div_Levels_0').'</option>';
			$options.='<option value="1"'.($this->uc['TSFE_adminConfig']['cache_clearCacheLevels']==1?' selected="selected"':'').'>'.$this->extGetLL('div_Levels_1').'</option>';
			$options.='<option value="2"'.($this->uc['TSFE_adminConfig']['cache_clearCacheLevels']==2?' selected="selected"':'').'>'.$this->extGetLL('div_Levels_2').'</option>';
			$out.=$this->extGetItem('cache_clearLevels', '<select name="TSFE_ADMIN_PANEL[cache_clearCacheLevels]">'.$options.'</select>'.
					'<input type="hidden" name="TSFE_ADMIN_PANEL[cache_clearCacheId]" value="'.$GLOBALS['TSFE']->id.'" /><input type="submit" value="'.$this->extGetLL('update').'" />');

				// Generating tree:
			$depth=$this->extGetFeAdminValue('cache','clearCacheLevels');
			$outTable='';
			$this->extPageInTreeInfo=array();
			$this->extPageInTreeInfo[]=array($GLOBALS['TSFE']->page['uid'],$GLOBALS['TSFE']->page['title'],$depth+1);
			$this->extGetTreeList($GLOBALS['TSFE']->id, $depth,0,$this->getPagePermsClause(1));
			reset($this->extPageInTreeInfo);
			while(list(,$row)=each($this->extPageInTreeInfo))	{
				$outTable.='<tr><td nowrap="nowrap"><img src="clear.gif" width="'.(($depth+1-$row[2])*18).'" height="1" alt="" /><img src="t3lib/gfx/i/pages.gif" width="18" height="16" align="absmiddle" border="0" alt="" />'.$this->extFw($row[1]).'</td><td><img src="clear.gif" width="10" height="1" alt="" /></td><td>'.$this->extFw($this->extGetNumberOfCachedPages($row[0])).'</td></tr>';
			}
			$outTable='<br /><table border="0" cellpadding="0" cellspacing="0">'.$outTable.'</table>';
			$outTable.='<input type="submit" name="TSFE_ADMIN_PANEL[action][clearCache]" value="'.$this->extGetLL('cache_doit').'" />';
			$out.=$this->extGetItem('cache_cacheEntries', $outTable);

		}
		return $out;
	}

	/**
	 * Creates the content for the "publish" section ("module") of the Admin Panel
	 *
	 * @param	string		Optional start-value; The generated content is added to this variable.
	 * @return	string		HTML content for the section. Consists of a string with table-rows with four columns.
	 * @see extPrintFeAdminDialog()
	 */
	function extGetCategory_publish($out='')	{
		$out.=$this->extGetHead('publish');
		if ($this->uc['TSFE_adminConfig']['display_publish'])	{
			$this->extNeedUpdate=1;
			$options='';
			$options.='<option value="0"'.($this->uc['TSFE_adminConfig']['publish_levels']==0?' selected="selected"':'').'>'.$this->extGetLL('div_Levels_0').'</option>';
			$options.='<option value="1"'.($this->uc['TSFE_adminConfig']['publish_levels']==1?' selected="selected"':'').'>'.$this->extGetLL('div_Levels_1').'</option>';
			$options.='<option value="2"'.($this->uc['TSFE_adminConfig']['publish_levels']==2?' selected="selected"':'').'>'.$this->extGetLL('div_Levels_2').'</option>';
			$out.=$this->extGetItem('publish_levels', '<select name="TSFE_ADMIN_PANEL[publish_levels]">'.$options.'</select>'.
					'<input type="hidden" name="TSFE_ADMIN_PANEL[publish_id]" value="'.$GLOBALS['TSFE']->id.'" /><input type="submit" value="'.$this->extGetLL('update').'" />');

				// Generating tree:
			$depth=$this->extGetFeAdminValue('publish','levels');
			$outTable='';
			$this->extPageInTreeInfo=array();
			$this->extPageInTreeInfo[]=array($GLOBALS['TSFE']->page['uid'],$GLOBALS['TSFE']->page['title'],$depth+1);
			$this->extGetTreeList($GLOBALS['TSFE']->id, $depth,0,$this->getPagePermsClause(1));
			reset($this->extPageInTreeInfo);
			while(list(,$row)=each($this->extPageInTreeInfo))	{
				$outTable.='<tr><td nowrap="nowrap"><img src="clear.gif" width="'.(($depth+1-$row[2])*18).'" height="1" alt="" /><img src="t3lib/gfx/i/pages.gif" width="18" height="16" align="absmiddle" border="0" alt="" />'.$this->extFw($row[1]).'</td><td><img src="clear.gif" width="10" height="1" alt="" /></td><td>'.$this->extFw('...').'</td></tr>';
			}
			$outTable='<br /><table border="0" cellpadding="0" cellspacing="0">'.$outTable.'</table>';
			$outTable.='<input type="submit" name="TSFE_ADMIN_PANEL[action][publish]" value="'.$this->extGetLL('publish_doit').'" />';
			$out.=$this->extGetItem('publish_tree', $outTable);
		}
		return $out;
	}

	/**
	 * Creates the content for the "edit" section ("module") of the Admin Panel
	 *
	 * @param	string		Optional start-value; The generated content is added to this variable.
	 * @return	string		HTML content for the section. Consists of a string with table-rows with four columns.
	 * @see extPrintFeAdminDialog()
	 */
	function extGetCategory_edit($out='')	{
		$out.=$this->extGetHead('edit');
		if ($this->uc['TSFE_adminConfig']['display_edit'])	{

				// If another page module was specified, replace the default Page module with the new one
			$newPageModule = trim($GLOBALS['BE_USER']->getTSConfigVal('options.overridePageModule'));
			$pageModule = t3lib_BEfunc::isModuleSetInTBE_MODULES($newPageModule) ? $newPageModule : 'web_layout';

			$this->extNeedUpdate=1;
			$out.=$this->extGetItem('edit_displayFieldIcons', '<input type="hidden" name="TSFE_ADMIN_PANEL[edit_displayFieldIcons]" value="0" /><input type="checkbox" name="TSFE_ADMIN_PANEL[edit_displayFieldIcons]" value="1"'.($this->uc['TSFE_adminConfig']['edit_displayFieldIcons']?' checked="checked"':'').' />');
			$out.=$this->extGetItem('edit_displayIcons', '<input type="hidden" name="TSFE_ADMIN_PANEL[edit_displayIcons]" value="0" /><input type="checkbox" name="TSFE_ADMIN_PANEL[edit_displayIcons]" value="1"'.($this->uc['TSFE_adminConfig']['edit_displayIcons']?' checked="checked"':'').' />');
			$out.=$this->extGetItem('edit_editFormsOnPage', '<input type="hidden" name="TSFE_ADMIN_PANEL[edit_editFormsOnPage]" value="0" /><input type="checkbox" name="TSFE_ADMIN_PANEL[edit_editFormsOnPage]" value="1"'.($this->uc['TSFE_adminConfig']['edit_editFormsOnPage']?' checked="checked"':'').' />');
			$out.=$this->extGetItem('edit_editNoPopup', '<input type="hidden" name="TSFE_ADMIN_PANEL[edit_editNoPopup]" value="0" /><input type="checkbox" name="TSFE_ADMIN_PANEL[edit_editNoPopup]" value="1"'.($this->uc['TSFE_adminConfig']['edit_editNoPopup']?' checked="checked"':'').' />');

			$out.=$this->extGetItem('', $this->ext_makeToolBar());
			if (!t3lib_div::_GP('ADMCMD_view'))	{
				$out.=$this->extGetItem('', '<a href="#" onclick="'.
					htmlspecialchars('
						if (parent.opener && parent.opener.top && parent.opener.top.TS)	{
							parent.opener.top.fsMod.recentIds["web"]='.intval($GLOBALS['TSFE']->page['uid']).';
							if (parent.opener.top.content && parent.opener.top.content.nav_frame && parent.opener.top.content.nav_frame.refresh_nav)	{
								parent.opener.top.content.nav_frame.refresh_nav();
							}
							parent.opener.top.goToModule("'.$pageModule.'");
							parent.opener.top.focus();
						} else {
							vHWin=window.open(\''.TYPO3_mainDir.'alt_main.php\',\''.md5('Typo3Backend-'.$GLOBALS['TYPO3_CONF_VARS']['SYS']['sitename']).'\',\'status=1,menubar=1,scrollbars=1,resizable=1\');
							vHWin.focus();
						}
						return false;
						').
					'">'.$this->extFw($this->extGetLL('edit_openAB')).'</a>');
			}
		}
		return $out;
	}

	/**
	 * Creates the content for the "tsdebug" section ("module") of the Admin Panel
	 *
	 * @param	string		Optional start-value; The generated content is added to this variable.
	 * @return	string		HTML content for the section. Consists of a string with table-rows with four columns.
	 * @see extPrintFeAdminDialog()
	 */
	function extGetCategory_tsdebug($out='')	{
		$out.=$this->extGetHead('tsdebug');
		if ($this->uc['TSFE_adminConfig']['display_tsdebug'])	{
			$this->extNeedUpdate=1;
			$out.=$this->extGetItem('tsdebug_tree', '<input type="hidden" name="TSFE_ADMIN_PANEL[tsdebug_tree]" value="0" /><input type="checkbox" name="TSFE_ADMIN_PANEL[tsdebug_tree]" value="1"'.($this->uc['TSFE_adminConfig']['tsdebug_tree']?' checked="checked"':'').' />');
			$out.=$this->extGetItem('tsdebug_displayTimes', '<input type="hidden" name="TSFE_ADMIN_PANEL[tsdebug_displayTimes]" value="0" /><input type="checkbox" name="TSFE_ADMIN_PANEL[tsdebug_displayTimes]" value="1"'.($this->uc['TSFE_adminConfig']['tsdebug_displayTimes']?' checked="checked"':'').' />');
			$out.=$this->extGetItem('tsdebug_displayMessages', '<input type="hidden" name="TSFE_ADMIN_PANEL[tsdebug_displayMessages]" value="0" /><input type="checkbox" name="TSFE_ADMIN_PANEL[tsdebug_displayMessages]" value="1"'.($this->uc['TSFE_adminConfig']['tsdebug_displayMessages']?' checked="checked"':'').' />');
			$out.=$this->extGetItem('tsdebug_LR', '<input type="hidden" name="TSFE_ADMIN_PANEL[tsdebug_LR]" value="0" /><input type="checkbox" name="TSFE_ADMIN_PANEL[tsdebug_LR]" value="1"'.($this->uc['TSFE_adminConfig']['tsdebug_LR']?' checked="checked"':'').' />');
			$out.=$this->extGetItem('tsdebug_displayContent', '<input type="hidden" name="TSFE_ADMIN_PANEL[tsdebug_displayContent]" value="0" /><input type="checkbox" name="TSFE_ADMIN_PANEL[tsdebug_displayContent]" value="1"'.($this->uc['TSFE_adminConfig']['tsdebug_displayContent']?' checked="checked"':'').' />');
			$out.=$this->extGetItem('tsdebug_displayQueries', '<input type="hidden" name="TSFE_ADMIN_PANEL[tsdebug_displayQueries]" value="0" /><input type="checkbox" name="TSFE_ADMIN_PANEL[tsdebug_displayQueries]" value="1"'.($this->uc['TSFE_adminConfig']['tsdebug_displayQueries']?' checked="checked"':'').' />');

			$out.=$this->extGetItem('tsdebug_forceTemplateParsing', '<input type="hidden" name="TSFE_ADMIN_PANEL[tsdebug_forceTemplateParsing]" value="0" /><input type="checkbox" name="TSFE_ADMIN_PANEL[tsdebug_forceTemplateParsing]" value="1"'.($this->uc['TSFE_adminConfig']['tsdebug_forceTemplateParsing']?' checked="checked"':'').' />');

			$GLOBALS['TT']->printConf['flag_tree'] = $this->extGetFeAdminValue('tsdebug','tree');
			$GLOBALS['TT']->printConf['allTime'] = $this->extGetFeAdminValue('tsdebug','displayTimes');
			$GLOBALS['TT']->printConf['flag_messages'] = $this->extGetFeAdminValue('tsdebug','displayMessages');
			$GLOBALS['TT']->printConf['flag_content'] = $this->extGetFeAdminValue('tsdebug','displayContent');
			$GLOBALS['TT']->printConf['flag_queries'] = $this->extGetFeAdminValue('tsdebug','displayQueries');
			$out.='<tr><td><img src="clear.gif" width="50" height="1" alt="" /></td><td colspan="3">'.$GLOBALS['TT']->printTSlog().'</td></tr>';
		}
		return $out;
	}

	/**
	 * Creates the content for the "info" section ("module") of the Admin Panel
	 *
	 * @param	string		Optional start-value; The generated content is added to this variable.
	 * @return	string		HTML content for the section. Consists of a string with table-rows with four columns.
	 * @see extPrintFeAdminDialog()
	 */
	function extGetCategory_info($out='')	{
		$out.=$this->extGetHead('info');
		if ($this->uc['TSFE_adminConfig']['display_info'])	{

			if (is_array($GLOBALS['TSFE']->imagesOnPage) && $this->extGetFeAdminValue('cache','noCache'))	{
				reset($GLOBALS['TSFE']->imagesOnPage);
				$theBytes=0;
				$count=0;
				$fileTable='';
				while(list(,$file)=each($GLOBALS['TSFE']->imagesOnPage))	{
					$fs=@filesize($file);
					$fileTable.='<tr><td>'.$this->extFw($file).'</td><td align="right">'.$this->extFw(t3lib_div::formatSize($fs)).'</td></tr>';
					$theBytes+=$fs;
					$count++;
				}
				$fileTable.='<tr><td><strong>'.$this->extFw('Total number of images:').'</strong></td><td>'.$this->extFw($count).'</td></tr>';
				$fileTable.='<tr><td><strong>'.$this->extFw('Total image file sizes:').'</strong></td><td align="right">'.$this->extFw(t3lib_div::formatSize($theBytes)).'</td></tr>';
				$fileTable.='<tr><td><strong>'.$this->extFw('Document size:').'</strong></td><td align="right">'.$this->extFw(t3lib_div::formatSize(strlen($GLOBALS['TSFE']->content))).'</td></tr>';
				$fileTable.='<tr><td><strong>'.$this->extFw('Total page load:').'</strong></td><td align="right">'.$this->extFw(t3lib_div::formatSize(strlen($GLOBALS['TSFE']->content)+$theBytes)).'</td></tr>';
				$fileTable.='<tr><td>&nbsp;</td></tr>';
			}

			$fileTable.='<tr><td>'.$this->extFw('id:').'</td><td>'.$this->extFw($GLOBALS['TSFE']->id).'</td></tr>';
			$fileTable.='<tr><td>'.$this->extFw('type:').'</td><td>'.$this->extFw($GLOBALS['TSFE']->type).'</td></tr>';
			$fileTable.='<tr><td>'.$this->extFw('gr_list:').'</td><td>'.$this->extFw($GLOBALS['TSFE']->gr_list).'</td></tr>';
			$fileTable.='<tr><td>'.$this->extFw('no_cache:').'</td><td>'.$this->extFw($GLOBALS['TSFE']->no_cache).'</td></tr>';
			$fileTable.='<tr><td>'.$this->extFw('fe_user, name:').'</td><td>'.$this->extFw($GLOBALS['TSFE']->fe_user->user['username']).'</td></tr>';
			$fileTable.='<tr><td>'.$this->extFw('fe_user, uid:').'</td><td>'.$this->extFw($GLOBALS['TSFE']->fe_user->user['uid']).'</td></tr>';
			$fileTable.='<tr><td>&nbsp;</td></tr>';

				// parsetime:
			$fileTable.='<tr><td>'.$this->extFw('Total parsetime:').'</td><td>'.$this->extFw($GLOBALS['TSFE']->scriptParseTime.' ms').'</td></tr>';

			$fileTable='<table border="0" cellpadding="0" cellspacing="0">'.$fileTable.'</table>';

			$out.='<tr><td><img src="clear.gif" width="50" height="1" alt="" /></td><td colspan="3">'.$fileTable.'</td></tr>';
		}
		return $out;
	}


















	/*****************************************************
	 *
	 * Admin Panel Layout Helper functions
	 *
	 ****************************************************/

	/**
	 * Returns a row (with colspan=4) which is a header for a section in the Admin Panel.
	 * It will have a plus/minus icon and a label which is linked so that it submits the form which surrounds the whole Admin Panel when clicked, alterting the TSFE_ADMIN_PANEL[display_'.$pre.'] value
	 * See the functions extGetCategory_*
	 *
	 * @param	string		The suffix to the display_ label. Also selects the label from the LOCAL_LANG array.
	 * @return	string		HTML table row.
	 * @access private
	 * @see extGetItem()
	 */
	function extGetHead($pre)	{
		$out.='<img src="t3lib/gfx/ol/blank.gif" width="18" height="16" align="absmiddle" border="0" alt="" />';
		$out.='<img src="t3lib/gfx/ol/'.($this->uc['TSFE_adminConfig']['display_'.$pre]?'minus':'plus').'bullet.gif" width="18" height="16" align="absmiddle" border="0" alt="" />';
		$out.=$this->extFw($this->extGetLL($pre));
		$out=$this->extItemLink($pre,$out);
		return '
				<tr class="typo3-adminPanel-itemHRow" bgcolor="#ABBBB4">
					<td colspan="4" nowrap="nowrap">'.$out.'<input type="hidden" name="TSFE_ADMIN_PANEL[display_'.$pre.']" value="'.$this->uc['TSFE_adminConfig']['display_'.$pre].'" /></td>
				</tr>';
	}

	/**
	 * Wraps a string in a link which will open/close a certain part of the Admin Panel
	 *
	 * @param	string		The code for the display_ label/key
	 * @param	string		Input string
	 * @return	string		Linked input string
	 * @access private
	 * @see extGetHead()
	 */
	function extItemLink($pre,$str)	{
		return '<a href="#" onclick="'.
			htmlspecialchars('document.TSFE_ADMIN_PANEL_FORM[\'TSFE_ADMIN_PANEL[display_'.$pre.']\'].value='.($this->uc['TSFE_adminConfig']['display_'.$pre]?'0':'1').'; document.TSFE_ADMIN_PANEL_FORM.submit(); return false;').
			'">'.$str.'</a>';
	}

	/**
	 * Returns a row (with 4 columns) for content in a section of the Admin Panel.
	 * It will take $pre as a key to a label to display and $element as the content to put into the forth cell.
	 *
	 * @param	string		Key to label
	 * @param	string		The HTML content for the forth table cell.
	 * @return	string		HTML table row.
	 * @access private
	 * @see extGetHead()
	 */
	function extGetItem($pre,$element)	{
		return '
					<tr class="typo3-adminPanel-itemRow">
						<td><img src="clear.gif" width="50" height="1" alt="" /></td>
						<td nowrap="nowrap">'.($pre ? $this->extFw($this->extGetLL($pre)) : '&nbsp;').'</td>
						<td><img src="clear.gif" width="10" height="1" alt="" /></td>
						<td>'.$element.'</td>
					</tr>';

	}

	/**
	 * Wraps a string in a font-tag with verdana, size 1 and black
	 *
	 * @param	string		The string to wrap
	 * @return	string
	 */
	function extFw($str)	{
		return '<font face="verdana,arial" size="1" color="black">'.$str.'</font>';
	}

	/**
	 * Creates the tool bar links for the "edit" section of the Admin Panel.
	 *
	 * @return	string		A string containing images wrapped in <a>-tags linking them to proper functions.
	 */
	function ext_makeToolBar()	{
			//  If mod.web_list.newContentWiz.overrideWithExtension is set, use that extension's create new content wizard instead:
		$tmpTSc = t3lib_BEfunc::getModTSconfig($this->pageinfo['uid'],'mod.web_list');
		$tmpTSc = $tmpTSc ['properties']['newContentWiz.']['overrideWithExtension'];
		$newContentWizScriptPath = t3lib_extMgm::isLoaded($tmpTSc) ? (t3lib_extMgm::extRelPath($tmpTSc).'mod1/db_new_content_el.php') : (TYPO3_mainDir.'sysext/cms/layout/db_new_content_el.php');

		$toolBar='';
		$id = $GLOBALS['TSFE']->id;
		$toolBar.='<a href="'.htmlspecialchars(TYPO3_mainDir.'show_rechis.php?element='.rawurlencode('pages:'.$id).'&returnUrl='.rawurlencode(t3lib_div::getIndpEnv('REQUEST_URI'))).'#latest">'.
					'<img src="t3lib/gfx/history2.gif" width="13" height="12" hspace="2" border="0" align="top" title="'.$this->extGetLL('edit_recordHistory').'" alt="" /></a>';
		$toolBar.='<a href="'.htmlspecialchars($newContentWizScriptPath.'?id='.$id.'&returnUrl='.rawurlencode(t3lib_div::getIndpEnv('REQUEST_URI'))).'">'.
					'<img src="t3lib/gfx/new_record.gif" width="16" height="12" hspace="1" border="0" align="top" title="'.$this->extGetLL('edit_newContentElement').'" alt="" /></a>';
		$toolBar.='<a href="'.htmlspecialchars(TYPO3_mainDir.'move_el.php?table=pages&uid='.$id.'&returnUrl='.rawurlencode(t3lib_div::getIndpEnv('REQUEST_URI'))).'">'.
					'<img src="t3lib/gfx/move_page.gif" width="11" height="12" hspace="2" border="0" align="top" title="'.$this->extGetLL('edit_move_page').'" alt="" /></a>';
		$toolBar.='<a href="'.htmlspecialchars(TYPO3_mainDir.'db_new.php?id='.$id.'&pagesOnly=1&returnUrl='.rawurlencode(t3lib_div::getIndpEnv('REQUEST_URI'))).'">'.
					'<img src="t3lib/gfx/new_page.gif" width="13" height="12" hspace="0" border="0" align="top" title="'.$this->extGetLL('edit_newPage').'" alt="" /></a>';

		$params='&edit[pages]['.$id.']=edit';
		$toolBar.='<a href="'.htmlspecialchars(TYPO3_mainDir.'alt_doc.php?'.$params.'&noView=1&returnUrl='.rawurlencode(t3lib_div::getIndpEnv('REQUEST_URI'))).'">'.
					'<img src="t3lib/gfx/edit2.gif" width="11" height="12" hspace="2" border="0" align="top" title="'.$this->extGetLL('edit_editPageHeader').'" alt="" /></a>';
		if ($this->check('modules','web_list'))	{
			$toolBar.='<a href="'.htmlspecialchars(TYPO3_mainDir.'db_list.php?id='.$id.'&returnUrl='.rawurlencode(t3lib_div::getIndpEnv('REQUEST_URI'))).'">'.
					'<img src="t3lib/gfx/list.gif" width="11" height="11" hspace="2" border="0" align="top" title="'.$this->extGetLL('edit_db_list').'" alt="" /></a>';
		}
		return $toolBar;
	}



















	/*****************************************************
	 *
	 * TSFE BE user Access Functions
	 *
	 ****************************************************/

	

	/**
	 * Evaluates if the Backend User has read access to the input page record.
	 * The evaluation is based on both read-permission and whether the page is found in one of the users webmounts. Only if both conditions are true will the function return true.
	 * Read access means that previewing is allowed etc.
	 * Used in index_ts.php
	 *
	 * @param	array		The page record to evaluate for
	 * @return	boolean		True if read access
	 */
	function extPageReadAccess($pageRec)	{
		return $this->isInWebMount($pageRec['uid']) && $this->doesUserHaveAccess($pageRec,1);
	}

	/**
	 * Checks if a Admin Panel section ("module") is available for the user. If so, true is returned.
	 *
	 * @param	string		The module key, eg. "edit", "preview", "info" etc.
	 * @return	boolean
	 * @see extPrintFeAdminDialog()
	 */
	function extAdmModuleEnabled($key)	{
			// Returns true if the module checked is "preview" and the forcePreview flag is set.
		if ($key=="preview" && $this->ext_forcePreview)	return true;
			// If key is not set, only "all" is checked
		if ($this->extAdminConfig['enable.']['all'])	return true;
		if ($this->extAdminConfig['enable.'][$key])	{
			return true;
		}
	}

	/**
	 * Saves any change in settings made in the Admin Panel.
	 * Called from index_ts.php right after access check for the Admin Panel
	 *
	 * @return	void
	 */
	function extSaveFeAdminConfig()	{
		$input = t3lib_div::_POST('TSFE_ADMIN_PANEL');
		if (is_array($input))	{
				// Setting
			$this->uc['TSFE_adminConfig'] = array_merge(!is_array($this->uc['TSFE_adminConfig'])?array():$this->uc['TSFE_adminConfig'], $input);			// Candidate for t3lib_div::array_merge() if integer-keys will some day make trouble...
			unset($this->uc['TSFE_adminConfig']['action']);

				// Actions:
			if ($input['action']['clearCache'] && $this->extAdmModuleEnabled('cache'))	{
				$this->extPageInTreeInfo=array();
				$theStartId = intval($input['cache_clearCacheId']);
				$GLOBALS['TSFE']->clearPageCacheContent_pidList($this->extGetTreeList($theStartId, $this->extGetFeAdminValue('cache','clearCacheLevels'),0,$this->getPagePermsClause(1)).$theStartId);
			}
			if ($input['action']['publish'] && $this->extAdmModuleEnabled('publish'))	{
				$theStartId = intval($input['publish_id']);
				$this->extPublishList = $this->extGetTreeList($theStartId, $this->extGetFeAdminValue('publish','levels'),0,$this->getPagePermsClause(1)).$theStartId;
			}

				// Saving
			$this->writeUC();
		}
		$GLOBALS['TT']->LR = $this->extGetFeAdminValue('tsdebug','LR');
		if ($this->extGetFeAdminValue('cache','noCache'))	{$GLOBALS['TSFE']->set_no_cache();}
	}

	/**
	 * Returns the value for a Admin Panel setting. You must specify both the module-key and the internal setting key.
	 *
	 * @param	string		Module key
	 * @param	string		Setting key
	 * @return	string		The setting value
	 */
	function extGetFeAdminValue($pre,$val='')	{
		if ($this->extAdmModuleEnabled($pre))	{	// Check if module is enabled.
				// Exceptions where the values can be overridden from backend:
			if ($pre.'_'.$val == 'edit_displayIcons' && $this->extAdminConfig['module.']['edit.']['forceDisplayIcons'])	{
				return true;
			}
			if ($pre.'_'.$val == 'edit_displayFieldIcons' && $this->extAdminConfig['module.']['edit.']['forceDisplayFieldIcons'])	{
				return true;
			}

			$retVal = $val ? $this->uc['TSFE_adminConfig'][$pre.'_'.$val] : 1;

			if ($pre=='preview' && $this->ext_forcePreview)	{
				if (!$val)	{
					return true;
				} else {
					return $retVal;
				}
			}

				// regular check:
			if ($this->extIsAdmMenuOpen($pre))	{	// See if the menu is expanded!
				return $retVal;
			}
		}
	}

	/**
	 * Returns true if admin panel module is open
	 *
	 * @param	string		Module key
	 * @return	boolean		True, if the admin panel is open for the specified admin panel module key.
	 */
	function extIsAdmMenuOpen($pre)	{
		return $this->uc['TSFE_adminConfig']['display_top'] && $this->uc['TSFE_adminConfig']['display_'.$pre];
	}
















	/*****************************************************
	 *
	 * TSFE BE user Access Functions
	 *
	 ****************************************************/

	/**
	 * Generates a list of Page-uid's from $id. List does not include $id itself
	 * The only pages excluded from the list are deleted pages.
	 *
	 * @param	integer		Start page id
	 * @param	integer		Depth to traverse down the page tree.
	 * @param	integer		$begin is an optional integer that determines at which level in the tree to start collecting uid's. Zero means 'start right away', 1 = 'next level and out'
	 * @param	string		Perms clause
	 * @return	string		Returns the list with a comma in the end (if any pages selected!)
	 */
	function extGetTreeList($id,$depth,$begin=0,$perms_clause)	{
		$depth=intval($depth);
		$begin=intval($begin);
		$id=intval($id);
		$theList='';

		if ($id && $depth>0)	{
			$res = $GLOBALS['TYPO3_DB']->exec_SELECTquery(
						'uid,title',
						'pages',
						'pid='.$id.' AND doktype IN ('.$GLOBALS['TYPO3_CONF_VARS']['FE']['content_doktypes'].') AND NOT deleted AND '.$perms_clause
					);
			while ($row = $GLOBALS['TYPO3_DB']->sql_fetch_assoc($res))	{
				if ($begin<=0)	{
					$theList.=$row['uid'].',';
					$this->extPageInTreeInfo[]=array($row['uid'],$row['title'],$depth);
				}
				if ($depth>1)	{
					$theList.=$this->extGetTreeList($row['uid'], $depth-1,$begin-1,$perms_clause);
				}
			}
		}
		return $theList;
	}

	/**
	 * Returns the number of cached pages for a page id.
	 *
	 * @param	integer		The page id.
	 * @return	integer		The number of pages for this page in the table "cache_pages"
	 */
	function extGetNumberOfCachedPages($page_id)	{
		$res = $GLOBALS['TYPO3_DB']->exec_SELECTquery('count(*)', 'cache_pages', 'page_id='.intval($page_id));
		list($num) = $GLOBALS['TYPO3_DB']->sql_fetch_row($res);
		return $num;
	}





















	/*****************************************************
	 *
	 * Localization handling
	 *
	 ****************************************************/

	/**
	 * Returns the label for key, $key. If a translation for the language set in $this->uc['lang'] is found that is returned, otherwise the default value.
	 * IF the global variable $LOCAL_LANG is NOT an array (yet) then this function loads the global $LOCAL_LANG array with the content of "sysext/lang/locallang_tsfe.php" so that the values therein can be used for labels in the Admin Panel
	 *
	 * @param	string		Key for a label in the $LOCAL_LANG array of "sysext/lang/locallang_tsfe.php"
	 * @return	string		The value for the $key
	 */
	function extGetLL($key)	{
		global $LOCAL_LANG;
		if (!is_array($LOCAL_LANG))	{
			$GLOBALS['LANG']->includeLLFile('EXT:lang/locallang_tsfe.php');
			#include('./'.TYPO3_mainDir.'sysext/lang/locallang_tsfe.php');
			if (!is_array($LOCAL_LANG))		$LOCAL_LANG=array();
		}

		$labelStr = htmlspecialchars($GLOBALS['LANG']->getLL($key));	// Label string in the default backend output charset.

			// Convert to utf-8, then to entities:
		if ($GLOBALS['LANG']->charSet!='utf-8')	{
			$labelStr = $GLOBALS['LANG']->csConvObj->utf8_encode($labelStr,$GLOBALS['LANG']->charSet);
		}
		$labelStr = $GLOBALS['LANG']->csConvObj->utf8_to_entities($labelStr);

			// Return the result:
		return $labelStr;
	}













	/*****************************************************
	 *
	 * Frontend Editing
	 *
	 ****************************************************/

	/**
	 * Returns true in an edit-action is sent from the Admin Panel
	 *
	 * @return	boolean
	 * @see index_ts.php
	 */
	function extIsEditAction()	{
		if (is_array($this->TSFE_EDIT))	{
			if ($this->TSFE_EDIT['cancel'])	{
				unset($this->TSFE_EDIT['cmd']);
			} elseif (($cmd!='edit' || (is_array($this->TSFE_EDIT['data']) && ($this->TSFE_EDIT['update'] || $this->TSFE_EDIT['update_close']))) && $cmd!='new')	{
					// $cmd can be a command like "hide" or "move". If $cmd is "edit" or "new" it's an indication to show the formfields. But if data is sent with update-flag then $cmd = edit is accepted because edit may be sendt because of .keepGoing flag.
				return true;
			}
		}
	}

	/**
	 * Returns true if an edit form is shown on the page.
	 * Used from index_ts.php where a true return-value will result in classes etc. being included.
	 *
	 * @return	boolean
	 * @see index_ts.php
	 */
	function extIsFormShown()	{
		if (is_array($this->TSFE_EDIT))	{
			$cmd=(string)$this->TSFE_EDIT['cmd'];
			if ($cmd=='edit' || $cmd=='new')	{
				return true;
			}
		}
	}

	/**
	 * Management of the on-page frontend editing forms and edit panels.
	 * Basically taking in the data and commands and passes them on to the proper classes as they should be.
	 *
	 * @return	void
	 * @see index_ts.php
	 */
	function extEditAction()	{
		global $TCA;
			// Commands:
		list($table,$uid) = explode(':',$this->TSFE_EDIT['record']);
		if ($this->TSFE_EDIT['cmd'] && $table && $uid && isset($TCA[$table]))	{
			$tce = t3lib_div::makeInstance('t3lib_TCEmain');
			$tce->stripslashes_values=0;
			$recData=array();
			$cmdData=array();
			$cmd=$this->TSFE_EDIT['cmd'];
			switch($cmd)	{
				case 'hide':
				case 'unhide':
					$hideField = $TCA[$table]['ctrl']['enablecolumns']['disabled'];
					if ($hideField)	{
						$recData[$table][$uid][$hideField]=($cmd=='hide'?1:0);
						$tce->start($recData,Array());
						$tce->process_datamap();
					}
				break;
				case 'up':
				case 'down':
					$sortField = $TCA[$table]['ctrl']['sortby'];
					if ($sortField)	{
						if ($cmd=='up')	{
							$op= '<';
							$desc=' DESC';
						} else {
							$op= '>';
							$desc='';
						}
							// Get self:
						$fields = array_unique(t3lib_div::trimExplode(',',$TCA[$table]['ctrl']['copyAfterDuplFields'].',uid,pid,'.$sortField,1));
						$res = $GLOBALS['TYPO3_DB']->exec_SELECTquery(implode(',',$fields), $table, 'uid='.$uid);
						if ($row = $GLOBALS['TYPO3_DB']->sql_fetch_assoc($res))	{
								// record before or after
							$preview = $this->extGetFeAdminValue('preview');
							$copyAfterFieldsQuery = '';
							if ($preview)	{$ignore = array('starttime'=>1, 'endtime'=>1, 'disabled'=>1, 'fe_group'=>1);}
							if ($TCA[$table]['ctrl']['copyAfterDuplFields'])	{
								$cAFields = t3lib_div::trimExplode(',',$TCA[$table]['ctrl']['copyAfterDuplFields'],1);
								while(list(,$fN)=each($cAFields))	{
									$copyAfterFieldsQuery.=' AND '.$fN.'="'.$row[$fN].'"';
								}
							}

							$res = $GLOBALS['TYPO3_DB']->exec_SELECTquery(
										'uid,pid',
										$table,
										'pid='.intval($row['pid']).
											' AND '.$sortField.$op.intval($row[$sortField]).
											$copyAfterFieldsQuery.
											t3lib_pageSelect::enableFields($table,'',$ignore),
										'',
										$sortField.$desc,
										'2'
									);
							if ($row2 = $GLOBALS['TYPO3_DB']->sql_fetch_assoc($res))	{
								if($cmd=='down')	{
									$cmdData[$table][$uid]['move']= -$row2['uid'];
								} elseif ($row3 = $GLOBALS['TYPO3_DB']->sql_fetch_assoc($res)) {	// Must take the second record above...
									$cmdData[$table][$uid]['move']= -$row3['uid'];
								} else {	// ... and if that does not exist, use pid
									$cmdData[$table][$uid]['move']= $row['pid'];
								}
							} elseif ($cmd=='up') {
								$cmdData[$table][$uid]['move']= $row['pid'];
							}
						}
						if (count($cmdData))	{
							$tce->start(Array(),$cmdData);
							$tce->process_cmdmap();
						}
					}
				break;
				case 'delete':
					$cmdData[$table][$uid]['delete']= 1;
					if (count($cmdData))	{
						$tce->start(Array(),$cmdData);
						$tce->process_cmdmap();
					}
				break;
			}
		}
			// Data:
		if (($this->TSFE_EDIT['doSave'] || $this->TSFE_EDIT['update'] || $this->TSFE_EDIT['update_close']) && is_array($this->TSFE_EDIT['data']))	{
			$tce = t3lib_div::makeInstance('t3lib_TCEmain');
			$tce->stripslashes_values=0;
			$tce->start($this->TSFE_EDIT['data'],Array());
			$tce->process_uploads($_FILES);
			$tce->process_datamap();
		}
	}
}




if (defined('TYPO3_MODE') && $TYPO3_CONF_VARS[TYPO3_MODE]['XCLASS']['t3lib/class.t3lib_beuserauth.php'])	{
	include_once($TYPO3_CONF_VARS[TYPO3_MODE]['XCLASS']['t3lib/class.t3lib_beuserauth.php']);
}
?>
