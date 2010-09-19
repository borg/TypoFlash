<?php

	/*if (!extension_loaded('sockets.so') && TYPO3_OS !="WIN") {
	   //dl loads the extension at runtime
		if(!@dl('sockets.so')){
			return false;
		}
	}*/



    class flashremoting_base {
		

		function flashremoting_base(){
			//constructor
			/*
			These need to be set in typo3_remoting_config.php which need to be included in each class extending this one
			*/
			


			//if(isset(RELAY_HOST)){
				$this->relayHost = RELAY_HOST;
			/*
			}else{
				$this->relayHost = "localhost";
			}
			*/
			//if(isset(RELAY_PORT)){
				$this->relayPort = RELAY_PORT;
			/*
			}else{
				$this->relayPort = "8800";
			}
	*/
	/*
	Method table was removed in AMFPHP 1.9
			$this->methodTable = array(
				"getActiveFEUser" => array(
					"description" => "Returns all data on active FE user",
					"access" => "remote"
				),
				"getActiveBEUser" => array(
					"description" => "Returns all data on active BE user",
					"access" => "remote"
				),
				"BElogin" => array(
					"description" => "Returns object with prop username, first_name, uid,user_groups, relaySuccess (boolean if applicable) of currently logged in typo3 front end user. For functions with roles you must set setCredentials('BEuser') first!",
					"access" => "remote"
				),
				"FElogin" => array(
					"description" => "Returns object with prop username, first_name, uid,user_groups, relaySuccess (boolean if applicable) of currently logged in typo3 front end user. For functions with roles you must set setCredentials('FEuser') first!",
					"access" => "remote"
				),
				"BElogout" => array(
					"description" => "Logs user out of typo3 BE",
					"access" => "remote"
				),
				"FElogout" => array(
					"description" => "Logs user out of typo3 FE",
					"access" => "remote"
				),
				"remotingLogout" => array(
					"description" => "Logs user out of remoting authentication service",
					"access" => "remote"
				),
				"getCookie" => array(
					"description" => "Temp function. Delete!!!!",
					"access" => "remote"
				)
				
			);
			*/

/*
			//Check if remoting is installed otherwise die
			if(!t3lib_extMgm::isLoaded('flashremoting')){
				$this->methodTable ='';
			}*/
		} 
         
		/*

		This function will authenticate the client before return the value of method call. It is called with the autheticate method in Flash. It is sent on the headers first.

		The order is significant. We are assuming that all functions available to FE user is available to BE user.
		Specific template level configurations need to be implemented to deal with cases where FE user is doing BE stuff (like FE editing) and vice versa (BE chat).
		
		Changed: Now you have to send role you wish to appear as before calling access limited functions.
		*/

		/*

		20/03/2008
		Disabled in AMFPHP 1.9.
		Not really needed as long as strict checks are maintained inside the different functions themselves

		function _authenticate($role){ 
			if(($role = 'BEuser') && $GLOBALS["BE_USER"]->user['uid']>0){
				return "BEuser";
			}else if(($role = 'FEuser') && $GLOBALS["FE_USER"]->user['uid']>0){
				return "FEuser";
			} else {
				return false;
			}
		}*/


		function remotingLogout() {
			Authenticate::logout();
		}

		function BElogout() {

			$oldUid = $GLOBALS['BE_USER']->user['uid'];
			$oldLocation = $GLOBALS['BE_USER']->user['pid'];
			$err = $GLOBALS['BE_USER']->logoff();
			if (method_exists($this, '_onBElogout')) { 
					$this->_onBElogout($oldUid, $oldLocation);
			}
			return $err;
		}

		
		function FElogout() {

			$oldUid = $GLOBALS['FE_USER']->user['uid'];
			$oldLocation = $GLOBALS['FE_USER']->user['pid'];
			$err = $GLOBALS['FE_USER']->logoff();
			if (method_exists($this, '_onFElogout')) { 
					$this->_onFElogout($oldUid, $oldLocation);
			}
			return $err;
		}		
		
		
		function getActiveFEuser(){ 
			//return $GLOBALS['R_SQL'];
			//return 's  FE_loginstatus';
			if(is_array($GLOBALS['FE_USER']->user)){
				$GLOBALS['FE_USER']->user['remoting_session'] = session_id();
				$arr = $GLOBALS['FE_USER']->user;
				$arr["password"]="secret";
				return $arr;
			}else{
				return false; 
			}
		} 
	    
		function getActiveBEuser(){
			if($GLOBALS["BE_USER"]->user['uid']>0){
				if($GLOBALS['BE_loginstatus'] <0){
					//login error from tsfebeuserauth
					//errortype 1 usererror, 2 server error
					$error = array("errortype"=>2,"errormsg"=>"You have been logged out of BE. Status: ".$GLOBALS['BE_loginstatus']); 
					return $error; 
				
				}

				$GLOBALS["BE_USER"]->user['remoting_session'] = session_id();
				$GLOBALS['TYPO3_DB']->exec_UPDATEquery('be_sessions',
											'ses_id="'.$GLOBALS['TYPO3_DB']->quoteStr($GLOBALS["BE_USER"]->id, 'be_sessions').'"
												AND ses_name="'.$GLOBALS['TYPO3_DB']->quoteStr($GLOBALS["BE_USER"]->name, 'be_sessions').'"',
											array('ses_tstamp' => $GLOBALS['EXEC_TIME'])
										);

				$arr = $GLOBALS["BE_USER"]->user;
				 
				$t = explode(' ',$arr['realName']);

				if(strlen($t[0])>0){
					$arr["first_name"]=$t[0]; 
				}
				if(strlen($t[1])>0){
					$arr["last_name"]=$t[1]; 
				}
				
				$arr["password"]="secret"; 
				$arr["uc"] = unserialize($arr["uc"]);
				return $arr;
			}else{
				return false; 
			}
		
		}

		function FElogin($usr,$psw,$salt=null){
		


			//don't know why this breaks with remoting..but remember that 
			//all ordinary classes are included before flash starts due to tx_typoflash page rendering

			
			//$GLOBALS['FE_USER']->lockToDomain = false;//don't know why this breaks with remoting...fix later!
			
			if($salt != null){
				$security_level = 'challenged';
			}
			$this->initFEuser($usr,$psw,$salt,'login',$security_level);

			
			/*if (is_array($GLOBALS['FE_USER']->user))	{
				$GLOBALS['TYPO3_DB']->exec_UPDATEquery('fe_users', 'uid='.intval($GLOBALS['FE_USER']->user['uid']), array('is_online' => 1));
			}*/
			//return $GLOBALS['R_SQL'];
			if(is_array($GLOBALS['FE_USER']->user)){
				//set status available
				//$GLOBALS['TYPO3_DB']->exec_UPDATEquery('fe_users', 'uid='.intval($GLOBALS['FE_USER']->user['uid']), array('status' => 2));

				
				$arr = $this->getActiveFEUser();
				if (method_exists($this, '_onFELogin')) { 
					$arr['relaySuccess'] = $this->_onFELogin(true, $GLOBALS['FE_USER']->user);
				}
				return $arr;
			}else{
				if (method_exists($this, '_onFELogin')) { 
					$this->_onFELogin(false);
				}
				return false;
			}
			
		 	
		}
		 
		function BElogin($usr, $psw,$salt=null){

			//if($GLOBALS['BE_USER'] == null){
				
				require_once('class.flashremoting_beuserauth.php');
				$GLOBALS['BE_USER'] = t3lib_div::makeInstance('flashremoting_beuserauth');
			//}



	
			$GLOBALS['BE_USER']->formfield_status = "login";
			$GLOBALS['BE_USER']->remote_usr = $usr;
			$GLOBALS['BE_USER']->remote_psw = $psw;
			$GLOBALS['BE_USER']->remote_chalvalue = $salt;
			if($salt != null){
				$GLOBALS['BE_USER']->security_level = 'challenged';
			}

			$this->initBEuser();


			/*$GLOBALS["BE_USER"] = t3lib_div::makeInstance('flashremoting_beuserauth');	// New backend user object
			$GLOBALS["BE_USER"]->sendNoCacheHeaders = false;
			$GLOBALS["BE_USER"]->lockIP = false; 
			$GLOBALS["BE_USER"]->checkPid = 0;
			$GLOBALS["BE_USER"]->auth_timeout_field = 60000;
			$GLOBALS["BE_USER"]->formfield_status = "login";
			$GLOBALS["BE_USER"]->remote_usr = $usr;
			$GLOBALS["BE_USER"]->remote_psw = $psw;
			$GLOBALS["BE_USER"]->check_authentication();*/
			  
			  //return array("status:"=>$GLOBALS['BE_loginstatus'],"user id"=>$GLOBALS["BE_USER"]->user['uid'],"sql:"=> $GLOBALS['R_SQL']);
			if($GLOBALS["BE_USER"]->user['uid']>0){
				
				$arr = $this->getActiveBEUser();
				if (method_exists($this, '_onBELogin')) { 
					$arr['relaySuccess'] = $this->_onBELogin(true, $GLOBALS['BE_USER']->user);
				}
				return $arr;
			}else{
				if (method_exists($this, '_onBELogin')) { 
					$this->_onBELogin(false);
				}
				return false;
			}
			
		}
		
		function getCookie(){
		
			return $_COOKIE;
		}
		




		function initFEuser($usr=null,$psw=null,$salt=null,$formfield_status=null,$security_level=null){
			

			require_once('class.flashremoting_feuserauth.php');
			if($GLOBALS['FE_USER'] == null){
				$GLOBALS['FE_USER'] = t3lib_div::makeInstance('flashremoting_feuserauth');
			}
			global $FE_USER;
			$FE_USER->formfield_status = $formfield_status;
			$FE_USER->remote_usr = $usr;
			$FE_USER->remote_psw = $psw;
			$FE_USER->remote_chalvalue = $salt;
			$FE_USER->security_level = $security_level;

			//$FE_USER->lockIP = $GLOBALS['TSFE']->TYPO3_CONF_VARS['FE']['lockIP'];
			$FE_USER->checkPid = 0;//borg. disabled checking of pid for logins...dunno where I woudl get it
			/*$FE_USER->checkPid = $GLOBALS['TSFE']->TYPO3_CONF_VARS['FE']['checkFeUserPid'];
			$FE_USER->checkPid_value = $GLOBALS['TYPO3_DB']->cleanIntList(t3lib_div::_GP('pid'));	// List of pid's acceptable*/

				// Check if a session is transferred:
			if (t3lib_div::_GP('FE_SESSION_KEY'))	{
				$fe_sParts = explode('-',t3lib_div::_GP('FE_SESSION_KEY'));
				/*if (!strcmp(md5($fe_sParts[0].'/'.$this->TYPO3_CONF_VARS['SYS']['encryptionKey']), $fe_sParts[1]))	{	// If the session key hash check is OK:
					$GLOBALS['HTTP_COOKIE_VARS'][$GLOBALS['FE_USER']->name]=$fe_sParts[0];
					$FE_USER->forceSetCookie=1;
				}*/
			}

			/*if ($GLOBALS['TSFE']->TYPO3_CONF_VARS['FE']['dontSetCookie'])	{
				$FE_USER->dontSetCookie=1;
			}*/
			$FE_USER->auth_timeout_field = 60000;
			//$FE_USER->sendNoCacheHeaders = false; 
			//$FE_USER->lockIP = false; 
			$FE_USER->user['ses_tstamp'] = $GLOBALS['EXEC_TIME']; 
			$FE_USER->user['disableIPlock'] = true;
			$FE_USER->start();
			
			$FE_USER->unpack_uc('');
			$FE_USER->fetchSessionData();	// Gets session data
			$recs = t3lib_div::_GP('recs');
			if (is_array($recs))	{	// If any record registration is submitted, register the record.
				$FE_USER->record_registration($recs);
			}

				// For every 60 seconds the is_online timestamp is updated.
			if (is_array($FE_USER->user) && $FE_USER->user['is_online']<($GLOBALS['EXEC_TIME']-60))	{
				$GLOBALS['TYPO3_DB']->exec_UPDATEquery('fe_users', 'uid='.intval($FE_USER->user['uid']), array('is_online' => $GLOBALS['EXEC_TIME']));
			}
		
		
		}



		function initBEuser(){
			$TYPO3_MISC['microtime_BE_USER_start'] = microtime();

				
				global $BE_USER;
				//borg+
				//tricks,hacks and wild guesses
				$BE_USER->sendNoCacheHeaders = false; 
				$BE_USER->lockIP = false; 
				$BE_USER->checkPid = 0;
				//$BE_USER->dontSetCookie = true;
				$BE_USER->auth_timeout_field = 60000;
				$BE_USER->user['ses_tstamp'] = $GLOBALS['EXEC_TIME']; 
				
				$BE_USER->OS = TYPO3_OS; 
				$ERR = $BE_USER->start();			// Object is initialized
				return $ERR;
				$BE_USER->unpack_uc(''); 
			   
		//borg- 
				if ($BE_USER->user['uid'])	{
					$BE_USER->fetchGroupData();
					
					//$TSFE->beUserLogin = 1;
				}  
				if ($BE_USER->checkLockToIP() && $BE_USER->checkBackendAccessSettingsFromInitPhp())	{
				 	$BE_USER->extInitFeAdmin();
					if ($BE_USER->extAdmEnabled)	{
						//require_once(t3lib_extMgm::extPath('lang').'lang.php');
						//echo t3lib_extMgm::isLoaded('cms');
						//$LANG = t3lib_div::makeInstance('language');
						//$LANG->init($BE_USER->uc['lang']);
		 
						//$BE_USER->extSaveFeAdminConfig();
							// Setting some values based on the admin panel
						/*$TSFE->forceTemplateParsing = $BE_USER->extGetFeAdminValue('tsdebug', 'forceTemplateParsing');
						$TSFE->displayEditIcons = $BE_USER->extGetFeAdminValue('edit', 'displayIcons');
						$TSFE->displayFieldEditIcons = $BE_USER->extGetFeAdminValue('edit', 'displayFieldIcons');

						if (t3lib_div::_GP('ADMCMD_editIcons'))	{
							$TSFE->displayFieldEditIcons=1;
							$BE_USER->uc['TSFE_adminConfig']['edit_editNoPopup']=1;
						}
						if (t3lib_div::_GP('ADMCMD_simUser'))	{
							$BE_USER->uc['TSFE_adminConfig']['preview_simulateUserGroup']=intval(t3lib_div::_GP('ADMCMD_simUser'));
							$BE_USER->ext_forcePreview=1;
						}
						if (t3lib_div::_GP('ADMCMD_simTime'))	{
							$BE_USER->uc['TSFE_adminConfig']['preview_simulateDate']=intval(t3lib_div::_GP('ADMCMD_simTime'));
							$BE_USER->ext_forcePreview=1;
						}
						*/
							// Include classes for editing IF editing module in Admin Panel is open (it is assumed that $TSFE->displayEditIcons is set only if the Edit module is open in the Admin Panel)
						/*if ($BE_USER->extAdmModuleEnabled('edit') && $BE_USER->extIsAdmMenuOpen('edit'))	{
							$TSFE->includeTCA();
							if ($BE_USER->extIsEditAction())	{
								require_once (PATH_t3lib.'class.t3lib_tcemain.php');
								$BE_USER->extEditAction();
							}
							if ($BE_USER->extIsFormShown())	{
								require_once(PATH_t3lib.'class.t3lib_tceforms.php');
								require_once(PATH_t3lib.'class.t3lib_iconworks.php');
								require_once(PATH_t3lib.'class.t3lib_loaddbgroup.php');
								require_once(PATH_t3lib.'class.t3lib_transferdata.php');
							}
						}*/

						//if ($TSFE->forceTemplateParsing || $TSFE->displayEditIcons || $TSFE->displayFieldEditIcons)	{ $TSFE->set_no_cache(); }
					}

			//		$WEBMOUNTS = (string)($BE_USER->groupData['webmounts'])!='' ? explode(',',$BE_USER->groupData['webmounts']) : Array();
			//		$FILEMOUNTS = $BE_USER->groupData['filemounts'];
				} else {	// Unset the user initialization.
					$BE_USER='';
				} 

			$TYPO3_MISC['microtime_BE_USER_end'] = microtime();

		
		
		}







		/*
		This function will pass the result of a remoting call on to 
		the remoting relay server (xml socket) specified in host and port.

		*************
		REQUEST TYPES
		*************


		*************
		server_instruction: remoting server instucting relay server

		Example:
		<request type="server_instruction" client="remoting_server" authentication="k1k2j3h1k23h">
		  <node id="function" value="addUser"/>
		  <arg name="location" value="21"/>
		  <arg name="user" value="1"/>
		</request> 

		All args will be repackaged as an array and passed as second argument after clientId to function.

		*************
		server_broadcast: remoting server pushing data out via relay

		Example 1 - server_broadcast : Remoting server call to flash function

		<request type="server_broadcast" client="remoting_server" authentication="k1k2j3h1k23h">
			<node id="relay_destination" location="21"/>
			<node id="relay_data">
				<response type="server_broadcast" origin="remoting_server">
					<node id="function" value="onReceivedMsg"/>
					<arg name="msg" type="cdata" >
						<![CDATA[Nice and quiet today]]>
					</arg>
					<arg name="channel" value="0"/>
				</response>
			</node>
		</request>

		
		Example 2 - relayed_service_call:  Remoting server request of flash to make subsequent remoting callback

		<request type="server_broadcast" client="remoting_server" authentication="k1k2j3h1k23h">
			<node id="relay_destination" user="112"/>
			<node id="relay_data">
				<response type="relayed_service_call" origin="remoting_server">
					<node id="service" value="multiuser_server.mus_usermanagement"/>
					<node id="function" value="refreshUserlist"/>
					<arg name="channel" value="0"/>
				</response>
			</node>
		</request>  

		Example 3 - wddx: Remoting server sending WDDX data straight back to flash

		<request type="server_broadcast" client="remoting_server" authentication="k1k2j3h1k23h">
			<node id="relay_destination" user="112"/>
			<node id="relay_data">
				<response type="wddx" origin="remoting_server">
					//wddx serialized xml
				</response>
			</node>
		</request> 


		</response>

		*************
		client_request: requests directly from clients

		Example:
		<request type="client_request" client="flash" authentication="k1k2j3h1k23h">
			<node id="function" value="identifyClient" />
			<arg name="location" value="21" />
			<arg name="user" value="1" />
		</request>
		*/
	
		function relayBroadcast($type=null,$obj=null){

			

			$this->sock =	@socket_create( AF_INET, SOCK_STREAM, 0 );
			if( !$this->sock){
				return false;
			}
			
			//	bind the socket
			//possible to specify port as last argument, by which we could lock remoting server down to one port
			if( !@socket_bind( $this->sock,$this->relayHost) ){
				return false;
			
			}

			$xml_root = domxml_new_doc('1.0');
			$requestNode = $xml_root->append_child($xml_root->create_element('request'));
			$requestNode->set_attribute('type',$type);
			$requestNode->set_attribute('client','remoting_server');
			$requestNode->set_attribute('authentication','1234');//improve later
			
			switch( $type ){
				case "server_instruction":
					/*
					<request type="server_instruction" client="remoting_server" authentication="k1k2j3h1k23h">
						<node id="function" value="addUser"/>
						<arg name="location" value="21"/>
						<arg name="user" value="1"/>
					</request> 
					*/
					if(is_string($obj['func'])){
						$funcNode = $requestNode->append_child($xml_root->create_element('node'));
						$funcNode->set_attribute('id','function');
						$funcNode->set_attribute('value',$obj['func']);
					}
					if(is_array($obj['args'])){
						foreach ($obj['args'] as $key=>$value){
							$argNode = $requestNode->append_child($xml_root->create_element('arg'));
							$argNode->set_attribute('name',$key);
							$argNode->set_attribute('value',$value);
						
						}
					}

					break;
				case "server_broadcast":
					/*
					<request type="server_broadcast" client="remoting_server" authentication="k1k2j3h1k23h">
						<node id="relay_destination" user="112"/>
						<node id="relay_data">
							<response type="server_broadcast" origin="remoting_server">
								<node id="target" value="Chat"/>
								<node id="function" value="onMsgReceived"/>
								<arg name="channel" value="0"/>
								<arg name="msg" type="cdata">
									<![CDATA[Yippiew!!! Coolioiei! xxx ]]>
								</arg>
							</response>
						</node>
					</request> 
					*/
					$locNode = $requestNode->append_child($xml_root->create_element('node'));
					$locNode->set_attribute('id','relay_destination');
					if(isset($obj['location'])){
						$locNode->set_attribute('location',$obj['location']);
					}
					
					if(isset($obj['user'])){
						$locNode->set_attribute('user',$obj['user']);
					}

					if(isset($obj['channel'])){
						$locNode->set_attribute('channel',$obj['channel']);
					}

					//more than one
					if(isset($obj['users'])){
						$locNode->set_attribute('users',join(",",$obj['users']));
					}

					if(isset($obj['relay_data'])){
						$dataNode = $requestNode->append_child($xml_root->create_element('node'));
						$dataNode->set_attribute('id','relay_data');
						$encData = $this->encodeResponse("server_broadcast",$obj['relay_data']);
						$dataNode->append_child($encData->clone_node(true));
					}
					break;

				case "relayed_service_call":
					/*
					<request type="server_broadcast" client="remoting_server" authentication="k1k2j3h1k23h">
						<node id="relay_destination" user="112"/>
						<node id="relay_data">
							<response type="relayed_service_call" origin="remoting_server">
								<node id="service" value="multiuser_server.mus_usermanagement"/>
								<node id="function" value="refreshUserlist"/>
								<arg name="channel" value="0"/>
							</response>
						</node>
					</request> 
					*/
					$locNode = $requestNode->append_child($xml_root->create_element('node'));
					$locNode->set_attribute('id','relay_destination');
					if(isset($obj['location'])){
						$locNode->set_attribute('location',$obj['location']);
					}
					
					if(isset($obj['user'])){
						$locNode->set_attribute('user',$obj['user']);
					}

					if(isset($obj['relay_data'])){
						$dataNode = $requestNode->append_child($xml_root->create_element('node'));
						$dataNode->set_attribute('id','relay_data');
						$encData = $this->encodeResponse("relayed_service_call",$obj['relay_data']);
						$dataNode->append_child($encData->clone_node(true));
					}
					break;


				case "wddx":
					/*
					<request type="server_broadcast" client="remoting_server" authentication="k1k2j3h1k23h">
						<node id="relay_destination" user="112"/>
						<node id="relay_data">
							<response type="wddx" origin="remoting_server">
								//wddx serialized xml
							</response>
						</node>
					</request> 
					*/
					if(isset($obj['location'])){
						$locNode = $requestNode->append_child($xml_root->create_element('node'));
						$locNode->set_attribute('id','relay_destination');
						$locNode->set_attribute('location',$obj['location']);
					}
					
					if(isset($obj['user'])){
						$locNode = $requestNode->append_child($xml_root->create_element('node'));
						$locNode->set_attribute('id','relay_destination');
						$locNode->set_attribute('user',$obj['user']);
					}

					if(isset($obj['relay_data'])){
						$dataNode->append_child($xml_root->create_element('node'));
						$dataNode->set_attribute('id','relay_data');
						$encData = $this->encodeResponse("wddx",$obj['relay_data']);
						$dataNode->append_child($encData);
					}
					break;

				case	"fault":
					//	error management
					break;
			}

			
			
			
			
			if( !@socket_connect($this->sock,$this->relayHost,$this->relayPort)){
				return false;
			}else{
				socket_write($this->sock,$xml_root->dump_mem(true) ."\0");
				socket_close($this->sock);
				return true;
			}
		}
		


		function encodeResponse( $responseType, $obj = null ){

			$xml_root = domxml_new_doc('1.0');
			$responseNode = $xml_root->append_child($xml_root->create_element('response'));
			$responseNode->set_attribute('type',$responseType);
			$responseNode->set_attribute('origin','remoting_server');


				
				switch($responseType){
					case "server_broadcast" :
						$targNode = $responseNode->append_child($xml_root->create_element('node'));
						$targNode->set_attribute('id','target');
						$targNode->set_attribute('value',$obj['target']);

						$funcNode = $responseNode->append_child($xml_root->create_element('node'));
						$funcNode->set_attribute('id','function');
						$funcNode->set_attribute('value',$obj['func']);


						foreach( $obj['args'] as $n=>$v ){
							$argNode = $responseNode->append_child($xml_root->create_element('arg'));
							$argNode->set_attribute('name',$n);
							if(is_string($v)){
								$argNode->set_attribute('type','cdata');
								$argNode->append_child($xml_root->create_cdata_section($v));
							}else{
								$argNode->set_attribute('value',$v);
							}
						}

						return	$xml_root->root();
						break;
					case "relayed_service_call" :
						$servNode = $responseNode->append_child($xml_root->create_element('node'));
						$servNode->set_attribute('id','service');
						$servNode->set_attribute('value',$obj['serv']);
						
						$funcNode = $responseNode->append_child($xml_root->create_element('node'));
						$funcNode->set_attribute('id','function');
						$funcNode->set_attribute('value',$obj['func']);


						foreach( $obj['args'] as $n=>$v ){
							$argNode = $responseNode->append_child($xml_root->create_element('arg'));
							$argNode->set_attribute('name',$n);
							$argNode->set_attribute('value',$v);
						}

						return	$xml_root->root();
					break;

					default:
						return	$xml_root->root();	
					break;
				}

			}

    }



?>
