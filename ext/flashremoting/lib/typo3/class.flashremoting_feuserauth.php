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



 

class flashremoting_feuserauth { 
	var $global_database = '';		// Which global database to connect to
	var $session_table = 'fe_sessions'; 		// Table to use for session data.
	var $name = 'fe_typo_user';                 // Session/Cookie name
	var $get_name = 'ftu';		                	 // Session/GET-var name

	var $user_table = 'fe_users'; 					// Table in database with userdata
	var $username_column = 'username'; 				// Column for login-name
	var $userident_column = 'password'; 			// Column for password
	var $userid_column = 'uid'; 					// Column for user-id
	var $lastLogin_column = 'lastlogin';

	var $enablecolumns = Array (
		'deleted' => 'deleted',
		'disabled' => 'disable',
		'starttime' => 'starttime',
		'endtime' => 'endtime'
	);
	var $formfield_uname = 'user'; 				// formfield with login-name
	var $formfield_uident = 'pass'; 			// formfield with password
	var $formfield_chalvalue = 'challenge';		// formfield with a unique value which is used to encrypt the password and username
	var $formfield_status = 'logintype'; 		// formfield with status: *'login', 'logout'
	var $security_level = '';					// sets the level of security. *'normal' = clear-text. 'challenged' = hashed password/username from form in $formfield_uident. 'superchallenged' = hashed password hashed again with username.

	var $auth_include = '';						// this is the name of the include-file containing the login form. If not set, login CAN be anonymous. If set login IS needed.

	var $auth_timeout_field = 60000;	  			// if > 0 : session-timeout in seconds. if false/<0 : no timeout. if string: The string is fieldname from the usertable where the timeout can be found.

	var $lifetime = 0;                  		// 0 = Session-cookies. If session-cookies, the browser will stop session when the browser is closed. Else it keeps the session for $lifetime seconds.
	var $gc_time  = 24;               	// GarbageCollection. Purge all session data older than $gc_time hours.
	var $gc_probability = 1;			// Possibility (in percent) for GarbageCollection to be run.
	var $writeStdLog = 0;					// Decides if the writelog() function is called at login and logout
	var $writeAttemptLog = 0;				// If the writelog() functions is called if a login-attempt has be tried without success
	var $sendNoCacheHeaders = 0;
	var $getFallBack = 1;						// If this is set, authentication is also accepted by the _GET. Notice that the identification is NOT 128bit MD5 hash but reduced. This is done in order to minimize the size for mobile-devices, such as WAP-phones
	var $hash_length = 10;
	var $getMethodEnabled = 1;					// Login may be supplied by url.
	var $lockIP = 4;					// If set, will lock the session to the users IP address (all four numbers. Reducing to 1-3 means that only first, second or third part of the IP address is used).
	var $lockHashKeyWords = 'useragent';	// Keyword list (commalist with no spaces!): "useragent". Each keyword indicates some information that can be included in a integer hash made to lock down usersessions.

	var $usergroup_column = 'usergroup';
	var $usergroup_table = 'fe_groups';
	var $groupData = Array(
		'title' =>Array(),
		'uid' =>Array(),
		'pid' =>Array()
	);
	var $TSdataArray=array();		// Used to accumulate the TSconfig data of the user
	var $userTS = array();
	var $userTSUpdated=0;
	var $showHiddenRecords=0;

		// Session and user data:
		/*
			There are two types of data that can be stored: UserData and Session-Data. Userdata is for the login-user, and session-data for anyone viewing the pages.
			'Keys' are keys in the internal dataarray of the data. When you get or set a key in one of the data-spaces (user or session) you decide the type of the variable (not object though)
			'Reserved' keys are:
				- 'recs': Array: Used to 'register' records, eg in a shopping basket. Structure: [recs][tablename][record_uid]=number
				- sys: Reserved for TypoScript standard code.
		*/
	var $sesData = Array();
	var $sesData_change = 0;
	var $userData_change = 0;

		// Internals
	var $id;							// Internal: Will contain session_id (MD5-hash)
	var $cookieId;						// Internal: Will contain the session_id gotten from cookie or GET method. This is used in statistics as a reliable cookie (one which is known to come from $_COOKIE).
	var $loginSessionStarted = 0;		// Will be set to 1 if the login session is actually written during auth-check.

	var $user;							// Internal: Will contain user- AND session-data from database (joined tables)
	var $get_URL_ID = '';				// Internal: Will will be set to the url--ready (eg. '&login=ab7ef8d...') GET-auth-var if getFallBack is true. Should be inserted in links!

	var $forceSetCookie=0;				// Will force the session cookie to be set everytime (liftime must be 0)
	var $dontSetCookie=0;				// Will prevent the setting of the session cookie (takes precedence over forceSetCookie)


	/**
	 * BORG MODIFICATION: Separated start functions for FE and BE. Starts a user session
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
		if ($mode=='get' && $this->getFallBack && $this->get_name)	{	// If fallback to get mode....
			$this->get_URL_ID = '&'.$this->get_name.'='.$id;
		}
		$this->user = '';				// Make certain that NO user is set initially

			// Setting cookies
        if (($new_id || $this->forceSetCookie) && $this->lifetime==0 ) {		// If new session and the cookie is a sessioncookie, we need to set it only once!
          if (!$this->dontSetCookie)	{
			  SetCookie($this->name, $id, 0, '/');		// Cookie is set
		  }
        }
        if ($this->lifetime > 0) {		// If it is NOT a session-cookie, we need to refresh it.
          if (!$this->dontSetCookie){	
			  SetCookie($this->name, $id, time()+$this->lifetime, '/');
			}
        }
		
			// Check to see if anyone has submitted login-information and if so register the user with the session. $this->user[uid] may be used to write log...
		if ($this->formfield_status)	{
			$this->check_authentication();
		}
		
		unset($this->user);				// Make certain that NO user is set initially. ->check_authentication may have set a session-record which will provide us with a user record in the next section:

		$FE_SQL =$this->session_table.'.ses_id = "'.$GLOBALS['TYPO3_DB']->quoteStr($this->id,$this->session_table).'" AND '.$this->session_table.'.ses_name = "'.$GLOBALS['TYPO3_DB']->quoteStr($this->name, $this->session_table).'" AND '.$this->session_table.'.ses_userid = '.$this->user_table.'.'.$this->userid_column.' '.$this->hashLockClause().' '.$this->user_where_clause();

			// The session_id is used to find user in the database. Two tables are joined: The session-table with user_id of the session and the usertable with its primary key
		$dbres = $GLOBALS['TYPO3_DB']->exec_SELECTquery('*',$this->session_table.','.$this->user_table,$FE_SQL);
			// The session_id is used to find user in the database. Two tables are joined: The session-table with user_id of the session and the usertable with its primary key

		if ($this->user = $GLOBALS['TYPO3_DB']->sql_fetch_assoc($dbres))	{

				// A user was found
			if (is_string($this->auth_timeout_field))	{
				$timeout = intval($this->user[$this->auth_timeout_field]);		// Get timeout-time from usertable
			} else {
				$timeout = intval($this->auth_timeout_field);					// Get timeout from object
			}
				// If timeout > 0 (true) and currenttime has not exceeded the latest sessions-time plus the timeout in seconds then accept user
				// Option later on: We could check that last update was at least x seconds ago in order not to update twice in a row if one script redirects to another...
			if ($timeout>0 && ($GLOBALS['EXEC_TIME'] < ($this->user['ses_tstamp']+$timeout)))	{
					$GLOBALS['TYPO3_DB']->exec_UPDATEquery(
											$this->session_table,
											'ses_id="'.$GLOBALS['TYPO3_DB']->quoteStr($this->id, $this->session_table).'"
												AND ses_name="'.$GLOBALS['TYPO3_DB']->quoteStr($this->name, $this->session_table).'"',
											array('ses_tstamp' => $GLOBALS['EXEC_TIME'])
										);
					$this->user['ses_tstamp'] = $GLOBALS['EXEC_TIME'];	// Make sure that the timestamp is also updated in the array
				
			} else {

				$this->user = '';

				$this->logoff();		// delete any user set...
			}
		} else if($this->formfield_status) {
			//If this is enabled it will kill sessions if 
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
	 * Will select all fe_groups records that the current fe_user is member of - and which groups are also allowed in the current domain.
	 * It also accumulates the TSconfig for the fe_user/fe_groups in ->TSdataArray
	 *
	 * @return	integer		Returns the number of usergroups for the frontend users (if the internal user record exists and the usergroup field contains a value)
	 */
	 
	function fetchGroupData()	{
		$this->TSdataArray = array();
		$this->userTS = array();
		$this->userTSUpdated = 0;

			// Setting default configuration:
		$this->TSdataArray[]=$GLOBALS['TYPO3_CONF_VARS']['FE']['defaultUserTSconfig'];

		if (is_array($this->user) && $this->user['usergroup'])	{
			$groups = t3lib_div::intExplode(',',$this->user['usergroup']);
			$list = implode($groups,',');
			$lockToDomain_SQL = ' AND (lockToDomain="" OR lockToDomain="'.t3lib_div::getIndpEnv('HTTP_HOST').'")';
			if (!$this->showHiddenRecords)	$hiddenP = 'AND NOT hidden ';

			$res = $GLOBALS['TYPO3_DB']->exec_SELECTquery('*', $this->usergroup_table, 'NOT deleted '.$hiddenP.'AND uid IN ('.$list.')'.$lockToDomain_SQL);
			while ($row = $GLOBALS['TYPO3_DB']->sql_fetch_assoc($res))	{
				$this->groupData['title'][$row['uid']] = $row['title'];
				$this->groupData['uid'][$row['uid']] = $row['uid'];
				$this->groupData['pid'][$row['uid']] = $row['pid'];
				$this->groupData['TSconfig'][$row['uid']] = $row['TSconfig'];
			}

			if ($GLOBALS['TYPO3_DB']->sql_num_rows($res))	{
				$GLOBALS['TYPO3_DB']->sql_free_result($res);
				// TSconfig:
				reset($groups);
				while(list(,$TSuid)=each($groups))	{
					$this->TSdataArray[]=$this->groupData['TSconfig'][$TSuid];
				}
				$this->TSdataArray[]=$this->user['TSconfig'];

				// Sort information
				ksort($this->groupData['title']);
				ksort($this->groupData['uid']);
				ksort($this->groupData['pid']);
				return count($this->groupData['uid']);
			} else {
				return 0;
			}
		}
	}

	/**
	 * Returns the parsed TSconfig for the fe_user
	 * First time this function is called it will parse the TSconfig and store it in $this->userTS. Subsequent requests will not re-parse the TSconfig but simply return what is already in $this->userTS
	 *
	 * @return	array		TSconfig array for the fe_user
	 */
	function getUserTSconf()	{
		if (!$this->userTSUpdated) {
				// Parsing the user TS (or getting from cache)
			$this->TSdataArray = t3lib_TSparser::checkIncludeLines_array($this->TSdataArray);
			$userTS = implode($this->TSdataArray,chr(10).'[GLOBAL]'.chr(10));
			$parseObj = t3lib_div::makeInstance('t3lib_TSparser');
			$parseObj->parse($userTS);
			$this->userTS = $parseObj->setup;

			$this->userTSUpdated=1;
		}
		return $this->userTS;
	}

















	/*****************************************
	 *
	 * Session data management functions
	 *
	 ****************************************/

	/**
	 * Fetches the session data for the user (from the fe_session_data table) based on the ->id of the current user-session.
	 * The session data is restored to $this->sesData
	 * 1/100 calls will also do a garbage collection.
	 *
	 * @return	void
	 * @access private
	 * @see storeSessionData()
	 */
	function fetchSessionData()	{
		// Gets SesData if any
		if ($this->id)	{
			$dbres = $GLOBALS['TYPO3_DB']->exec_SELECTquery('*', 'fe_session_data', 'hash="'.$GLOBALS['TYPO3_DB']->quoteStr($this->id, 'fe_session_data').'"');
			if ($sesDataRow = $GLOBALS['TYPO3_DB']->sql_fetch_assoc($dbres))	{
				$this->sesData = unserialize($sesDataRow['content']);
			}
		}
			// delete old data:
		if ((rand()%100) <= 1) {		// a possibility of 1 % for garbage collection.
			$GLOBALS['TYPO3_DB']->exec_DELETEquery('fe_session_data', 'tstamp < '.intval(time()-3600*24));		// all data older than 24 hours are deleted.
		}
	}

	/**
	 * Will write UC and session data.
	 * If the flag $this->userData_change has been set, the function ->writeUC is called (which will save persistent user session data)
	 * If the flag $this->sesData_change has been set, the fe_session_data table is updated with the content of $this->sesData (deleting any old record, inserting new)
	 *
	 * @return	void
	 * @see fetchSessionData(), getKey(), setKey()
	 */
	function storeSessionData()	{
			// Saves UC and SesData if changed.
		if ($this->userData_change)	{
			$this->writeUC('');
		}
		if ($this->sesData_change)	{
			if ($this->id)	{
				$insertFields = array (
					'hash' => $this->id,
					'content' => serialize($this->sesData),
					'tstamp' => time()
				);
				$GLOBALS['TYPO3_DB']->exec_DELETEquery('fe_session_data', 'hash="'.$GLOBALS['TYPO3_DB']->quoteStr($this->id, 'fe_session_data').'"');
				$GLOBALS['TYPO3_DB']->exec_INSERTquery('fe_session_data', $insertFields);
			}
		}
	}

	/**
	 * Returns session data for the fe_user; Either persistent data following the fe_users uid/profile (requires login) or current-session based (not available when browse is closed, but does not require login)
	 *
	 * @param	string		Session data type; Either "user" (persistent, bound to fe_users profile) or "ses" (temporary, bound to current session cookie)
	 * @param	string		Key from the data array to return; The session data (in either case) is an array ($this->uc / $this->sesData) and this value determines which key to return the value for.
	 * @return	mixed		Returns whatever value there was in the array for the key, $key
	 * @see setKey()
	 */
	function getKey($type,$key) {
		if ($key)	{
			switch($type)	{
				case 'user':
					return $this->uc[$key];
				break;
				case 'ses':
					return $this->sesData[$key];
				break;
			}
		}
	}

	/**
	 * Saves session data, either persistent or bound to current session cookie. Please see getKey() for more details.
	 * When a value is set the flags $this->userData_change or $this->sesData_change will be set so that the final call to ->storeSessionData() will know if a change has occurred and needs to be saved to the database.
	 * Notice: The key "recs" is already used by the function record_registration() which stores table/uid=value pairs in that key. This is used for the shopping basket among other things.
	 * Notice: Simply calling this function will not save the data to the database! The actual saving is done in storeSessionData() which is called as some of the last things in index_ts.php. So if you exit before this point, nothing gets saved of course! And the solution is to call $GLOBALS['TSFE']->storeSessionData(); before you exit.
	 *
	 * @param	string		Session data type; Either "user" (persistent, bound to fe_users profile) or "ses" (temporary, bound to current session cookie)
	 * @param	string		Key from the data array to store incoming data in; The session data (in either case) is an array ($this->uc / $this->sesData) and this value determines in which key the $data value will be stored.
	 * @param	mixed		The data value to store in $key
	 * @return	void
	 * @see setKey(), storeSessionData(), record_registration()
	 */
	function setKey($type,$key,$data)	{
		if ($key)	{
			switch($type)	{
				case 'user':
					if ($this->user['uid'])	{
						$this->uc[$key]=$data;
						$this->userData_change=1;
					}
				break;
				case 'ses':
					$this->sesData[$key]=$data;
					$this->sesData_change=1;
				break;
			}
		}
	}

	/**
	 * Registration of records/"shopping basket" in session data
	 * This will take the input array, $recs, and merge into the current "recs" array found in the session data.
	 * If a change in the recs storage happens (which it probably does) the function setKey() is called in order to store the array again.
	 *
	 * @param	array		The data array to merge into/override the current recs values. The $recs array is constructed as [table]][uid] = scalar-value (eg. string/integer).
	 * @return	void
	 */
	function record_registration($recs)	{
		if ($recs['clear_all'])	{
			$this->setKey('ses','recs','');
		}
		$change=0;
		$recs_array=$this->getKey('ses','recs');
		reset($recs);
		while(list($table,$data)=each($recs))	{
			if (is_array($data))	{
				reset($data);
				while(list($rec_id,$value)=each($data))	{
					if ($value != $recs_array[$table][$rec_id])	{
						$recs_array[$table][$rec_id] = $value;
						$change=1;
					}
				}
			}
		}
		if ($change)	{
			$this->setKey('ses','recs',$recs_array);
		}
	}
	
	
	
	/**
	 * Checks if a submission of username and password is made by flash remoting
	 *
	 * @return	string		Returns "login" if login, "logout" if logout, or empty if $F_status was none of these values.
	 * @internal
	 */
	function check_authentication() {

			// Values sent by Flash
		
			$F_status = $GLOBALS['FE_USER']->formfield_status;
			$F_uname =$GLOBALS['FE_USER']->remote_usr;
			$F_uident = $GLOBALS['FE_USER']->remote_psw;
			$F_chalvalue = $GLOBALS['FE_USER']->remote_chalvalue;
		
//$GLOBALS['R_SQL'] .= ' check_authentication';
		switch ($F_status)	{
			case 'login':
				
				$refInfo=parse_url(t3lib_div::getIndpEnv('HTTP_REFERER'));
				
				$httpHost = t3lib_div::getIndpEnv('TYPO3_HOST_ONLY');
				if (!$this->getMethodEnabled && ($httpHost!=$refInfo['host'] && !$GLOBALS['TYPO3_CONF_VARS']['SYS']['doNotCheckReferer']))	{
					return('Error: This host address ("'.$httpHost.'") and the referer host ("'.$refInfo['host'].'") mismatches!<br />
						It\'s possible that the environment variable HTTP_REFERER is not passed to the script because of a proxy.<br />
						The site administrator can disable this check in the configuration (flag: TYPO3_CONF_VARS[SYS][doNotCheckReferer]).');
				}
			
				if ($F_uident && $F_uname)	{
				
						// Reset this flag
					$loginFailure=0;

						// delete old user session if any
					$this->logoff();
						// Look up the new user by the username:
					$dbres = $GLOBALS['TYPO3_DB']->exec_SELECTquery(
									'*',
									$this->user_table,
									($this->checkPid ? 'pid IN ('.$GLOBALS['TYPO3_DB']->cleanIntList($this->checkPid_value).') AND ' : '').
										$this->username_column.'="'.$GLOBALS['TYPO3_DB']->quoteStr($F_uname, $this->user_table).'" '.
										$this->user_where_clause()
							);
				//return $GLOBALS['TYPO3_DB']->sql_fetch_assoc($dbres);
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
								/*strcmp = string compare 
								strcmp ( string str1, string str2 )
								Returns < 0 if str1 is less than str2; > 0 if str1 is greater than str2, and 0 if they are equal. 
								*/

								if (!strcmp($F_uident,md5($tempuser[$this->username_column].':'.$tempuser[$this->userident_column].':'.$F_chalvalue)))	{
									$OK = true;
								};
								//$GLOBALS['R_SQL'] ='security_level: '.$this->security_level.' chalvalue: '.$F_chalvalue . ' uident: '.$F_uident .' might be this username: ' .$tempuser[$this->username_column].' with this psw: '.$tempuser[$this->userident_column];
							break;
							default:	// normal
								if (!strcmp($F_uident,$tempuser[$this->userident_column]))	{
									$OK = true;
								};
							break;
						}

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
									'ses_iplock' => '[DISABLED]',
									'ses_hashlock' => $this->hashLockClause_getHashInt(),
									'ses_userid' => $tempuser[$this->userid_column],
									'ses_tstamp' => $GLOBALS['EXEC_TIME']
								);
								/*$GLOBALS['R_SQL'] .= ' disableIPlock '.$this->user['disableIPlock'];
								$insertFields = array(
									'ses_id' => $this->id,
									'ses_name' => $this->name,
									'ses_iplock' => $this->user['disableIPlock'] ? '[DISABLED]' : $this->ipLockClause_remoteIPNumber($this->lockIP),
									'ses_hashlock' => $this->hashLockClause_getHashInt(),
									'ses_userid' => $tempuser[$this->userid_column],
									'ses_tstamp' => $GLOBALS['EXEC_TIME']
								);*/
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
				$this->logoff();

					// Return "logout" - since this was the $F_status
				return 'logout';
			break;
		}
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
	 * Borg: resetting is_online to 0 also I can get an accurate userlist 
	 * @return	void
	 */
	function logoff() {
		$GLOBALS['TYPO3_DB']->exec_UPDATEquery('fe_users', 'uid='.intval($GLOBALS['FE_USER']->user['uid']), array('status' => 0));
	//$GLOBALS['R_SQL'] .= ' logoff';

		$GLOBALS['TYPO3_DB']->exec_DELETEquery('fe_sessions','ses_id = "'.$GLOBALS['TYPO3_DB']->quoteStr($this->id,'fe_sessions').'" AND ses_name = "'.$GLOBALS['TYPO3_DB']->quoteStr($this->name,'fe_sessions').'"');

		/*$query = "UPDATE fe_users SET is_online = 0 WHERE uid =".$GLOBALS['FE_USER']->user['uid'].";";
		$res = $GLOBALS['TYPO3_DB']->sql(TYPO3_db, $query);*/
		
		//$this->user = "";
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
		$GLOBALS['TYPO3_DB']->exec_DELETEquery('fe_sessions','ses_tstamp < '.intval(time()-($this->gc_time*60*60)).' AND ses_name = "'.$GLOBALS['TYPO3_DB']->quoteStr($this->name, 'fe_sessions').'"');
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
				'.'fe_sessions'.'.ses_iplock="'.$GLOBALS['TYPO3_DB']->quoteStr($this->ipLockClause_remoteIPNumber($this->lockIP),'fe_sessions').'"
				OR '.'fe_sessions'.'.ses_iplock="[DISABLED]"
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
		$wherePart = 'AND '.'fe_sessions'.'.ses_hashlock='.intval($this->hashLockClause_getHashInt());
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

		$GLOBALS['TYPO3_DB']->exec_UPDATEquery('fe_sessions', 'ses_id="'.$GLOBALS['TYPO3_DB']->quoteStr($this->user['ses_id'], 'fe_sessions').'"', array('ses_data' => $this->user['ses_data']));
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

}


if (defined('TYPO3_MODE') && $TYPO3_CONF_VARS[TYPO3_MODE]['XCLASS']['tslib/class.tslib_feuserauth.php'])	{
	include_once($TYPO3_CONF_VARS[TYPO3_MODE]['XCLASS']['tslib/class.tslib_feuserauth.php']);
}
?>
