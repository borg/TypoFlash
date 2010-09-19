<?php
/*


This script is copyright Andreas Borg. borg@elevated.to

This constitutes the "armlength" interface between my TypeFlash editor
and Typo3.

From GPL licence

I'd like to incorporate GPL-covered software in my proprietary system. Can I do this? 
You cannot incorporate GPL-covered software in a proprietary system. The goal of the GPL is to grant everyone the freedom to copy, redistribute, understand, and modify a program. If you could incorporate GPL-covered software into a non-free system, it would have the effect of making the GPL-covered software non-free too. 
A system incorporating a GPL-covered program is an extended version of that program. The GPL says that any extended version of the program must be released under the GPL if it is released at all. This is for two reasons: to make sure that users who get the software get the freedom they should have, and to encourage people to give back improvements that they make.

However, in many cases you can distribute the GPL-covered software alongside your proprietary system. To do this validly, you must make sure that the free and non-free programs communicate at arms length, that they are not combined in a way that would make them effectively a single program.

The difference between this and "incorporating" the GPL-covered software is partly a matter of substance and partly form. The substantive part is this: if the two programs are combined so that they become effectively two parts of one program, then you can't treat them as two separate programs. So the GPL has to cover the whole thing.

If the two programs remain well separated, like the compiler and the kernel, or like an editor and a shell, then you can treat them as two separate programs--but you have to do it properly. The issue is simply one of form: how you describe what you are doing. Why do we care about this? Because we want to make sure the users clearly understand the free status of the GPL-covered software in the collection.

If people were to distribute GPL-covered software calling it "part of" a system that users know is partly proprietary, users might be uncertain of their rights regarding the GPL-covered software. But if they know that what they have received is a free program plus another program, side by side, their rights will be clear. 




RE history
If history is to work with Typo3 undo it needs to patch into
TCEmain, and each call from TypoFlash history needs to have
one corresponding TCE command call.
 

*/

require_once(dirname(dirname(dirname(__FILE__))).'/flashremoting/lib/typo3/includes.php');		
require_once(PATH_t3lib.'class.t3lib_tstemplate.php');
require_once(PATH_t3lib.'class.t3lib_tcemain.php');



    class contentediting extends flashremoting_base{

    
        function contentediting() {
		
			//parent::flashremoting_base();//get method table and some globals etc
		
			/*
            $this->subMethodTable = array(
				 "storePageData" => array(
					"description" => "Store any data for a component with a page or template. Send an object with 'key', and properties appended to 'data'. If L (language) is sent a property the data will be appended to that array, else on [0] array. Remember that all data on that key will be overwritten. Returns new data structure.",
					"access" => "remote"
				),
				"deletePageData" => array(
					"description" => "Send an object with movieclip as 'key'. If L (language) is sent a property the data will be delete in that array. Returns new data structure.",
					"access" => "remote"
				),
				"getComponents" => array(
					"description" => "Returns an array of all available flash components for BE user. WIll limit listing to PID if id is sent.",
					"access" => "remote"
				),
				"saveContent" => array(
					"description" => "Save new flash content or edit existing one by sending uid as property.",
					"access" => "remote"
				),
				"deleteContent" => array(
					"description" => "Delete flash content by sending uid as property.",
					"access" => "remote"
				),
				"select" => array(
					"description" => "Using the typo3 exec_SELECT function. Uses the same arguments plus additional callback id. Adds check for BE access. Returns object with result and callback properties.",
					"access" => "remote"
				),
				"insert" => array(
					"description" => "Using the typo3 exec_INSERT function. Uses the same arguments plus additional callback id. Adds check for BE access. Returns object with result (new record and its uid) and callback properties.",
					"access" => "remote"
				),
				"insertMultiple" => array(
					"description" => "Using the typo3 exec_INSERT function. Uses the same arguments plus additional callback id. Adds check for BE access. Returns object with result (new record and its uid) and callback properties.",
					"access" => "remote"
				),					
				"update" => array(
					"description" => "Using the typo3 exec_UPDATE function. Uses the same arguments plus additional callback id. Adds check for BE access. Returns object with result and callback properties. Can be used to hide and delete as well.",
					"access" => "remote"
				),
				"exec_delete" => array(
					"description" => "Using the typo3 exec_DELETE function. Uses the same arguments plus additional callback id. Adds check for BE access. Returns object with result true and callback properties. Use to delete link tables etc without deleted property.",
					"access" => "remote"
				),
				"getRecords" => array(
					"description" => "Normal selelct plus field on which linked records to retrieve. Returns result as array of objects.",
					"access" => "remote"
				),
				"linkRecords" => array(
					"description" => "",
					"access" => "remote"
				),
				"unlinkRecords" => array(
					"description" => "",
					"access" => "remote"
				)



				
            );
			$this->methodTable = array_merge($this->methodTable, $this->subMethodTable);

			*/
			/*//Check if remoting is installed otherwise die
			if(!t3lib_extMgm::isLoaded('flashremoting')){
				$this->methodTable ='';
			}*/
	
			//charset issues...
			//this worked with $TYPO3_CONF_VARS['SYS']['setDBinit'] = 'SET NAMES utf8;'
			//amf.php set to
			//$gateway->setCharsetHandler( "none", "ISO-8859-1", "ISO-8859-1" );
			if($GLOBALS['TYPO3_CONF_VARS']['SYS']['setDBinit'] !=''){
				$GLOBALS['TYPO3_DB']->sql(TYPO3_db, $GLOBALS['TYPO3_CONF_VARS']['SYS']['setDBinit']);
			}
		}


		/*
		function _authenticate($role){
			return $role;
		}
        */

		

		function storePageData($pObj){
			
			global $BE_USER,$EXEC_TIME,$TYPO3_DB;


			/*
			Check BE user access

			06/05/2008

			$BE_USER->getPagePermsClause(1)
			only works if BE user is owner of page, not group access
			$BE_USER->fetchGroupData(); adds group access
			*/
			if($BE_USER->user['uid']>0){
				$BE_USER->fetchGroupData();
				$be_access = ' AND '.$BE_USER->getPagePermsClause(1);
			}else {
				$error = array('errortype'=>1,'errormsg'=>'You do not have access to storePageData function');
				return $error;
				die;
			}	

			/*
			Page id options
			*/
			if(!($pObj['id']>0) && !(strlen($pObj['id'])>0)){
				$error = array('errortype'=>1,'errormsg'=>'No pid sent');
				return $error;
				die;
			}else if($pObj['id']>0){
				$page = 'uid='.intval($pObj['id']);
			}else{
				//alias sent
				$page = 'alias="'.$pObj['id'].'"';
			}

			

			$where = $page .$be_access;

		
			$res = $TYPO3_DB->exec_SELECTquery('*', 'pages', $where, '', '');
			$row = $TYPO3_DB->sql_fetch_assoc($res);


			// *****************************************
			// We are passing L for language. 
			// *****************************************


			if(!($pObj['L']>0)){
				$pObj['L'] =0;
			}


			$all_data = unserialize($row['tx_typoflash_data']);
			/*
			We should store data in template namespace in case template is changed and data not updated
			*/

			$data = $all_data[$row['tx_typoflash_template']];


			if(is_array($data[$pObj['L']])){
				//If key exists overwrite with new data
				$data[$pObj['L']][$pObj['key']]= $pObj['data'] ;
			}else if(is_array($data)){
				//Create languag array
				$data[$pObj['L']] = array($pObj['key'] =>$pObj['data']);
			}else{
				//Create data array
				$data = array();
				$data[$pObj['L']] = array($pObj['key'] =>$pObj['data']);
			}

			$all_data[$row['tx_typoflash_template']] = $data;
			$sdata = serialize($all_data);
			
			//By using TCEmain we use typo3 history, thus making undo possible
			//need to add tx_typoflash_data to TCA first..not yet working
			
/*
			
			$tcedata['pages'][$row['uid']]['tx_typoflash_data'] = $sdata;
			
			$tce = t3lib_div::makeInstance('t3lib_TCEmain');
			$tce->stripslashes_values = 0;
			$tce->start($tcedata,array());
			$tce->process_datamap();
			return $tcedata;
	*/
		
			
			$TYPO3_DB->exec_UPDATEquery('pages',$page,array('tx_typoflash_data' => $sdata));
			//Clear out old cache
			$this->clearCache();
			$arr = array('data'=>$data,'pObj'=>$pObj);
			return $arr;

		}

		function deletePageData($pObj){
			
			global $BE_USER,$TYPO3_DB;


			/*
			Check BE user access
			*/
			if($BE_USER->user['uid']>0){
				$BE_USER->fetchGroupData();
				/* getPagePermsClause(1)
				 * 	 	2^0 = show (1)
				 * 		2^1 = edit (2)
				 * 		2^2 = delete (4)
				 * 		2^3 = new (8)
				*/
				$be_access = ' AND '.$BE_USER->getPagePermsClause(2);
			}else {
				$error = array('errortype'=>1,'errormsg'=>'You do not have access to deletePageData function');
				return $error;
				die;
			}	
			
			/*
			Page id options
			*/
			if(!($pObj['id']>0) && !(strlen($pObj['id'])>0)){
				$error = array('errortype'=>1,'errormsg'=>'No pid sent');
				return $error;
				die;
			}else if($pObj['id']>0){
				$page = 'uid='.intval($pObj['id']);
			}else{
				//alias sent
				$page = 'alias="'.$pObj['alias'].'"';
			}

			

			$where = $page .$be_access;
			
		
			$res = $TYPO3_DB->exec_SELECTquery('*', 'pages', $where, '', '');
			$row = $TYPO3_DB->sql_fetch_assoc($res);

				
			// *****************************************
			// We are passing L for language. 
			// *****************************************


			if(!($pObj['L']>0)){
				$pObj['L'] =0;
			}


			$all_data = unserialize($row['tx_typoflash_data']);
			/*
			We should store data in template namespace in case template is changed and data not updated
			*/

			$data = $all_data[$row['tx_typoflash_template']];

			if(is_array($data[$pObj['L']][$pObj['key']])){
				//If key exists delete
				unset($data[$pObj['L']][$pObj['key']]);
			}

			$all_data[$row['tx_typoflash_template']] = $data;
			$sdata = serialize($all_data);
			$TYPO3_DB->exec_UPDATEquery('pages',$page,array('tx_typoflash_data' => $sdata));

			//Clear out old cache
			$this->clearCache();
			
			$arr = array('data'=>$data,'pObj'=>$pObj);
			return $arr;


		}


		/*
		Store history
		*/
		
		

		function storeHistory($histArray){
			
			global $BE_USER,$EXEC_TIME,$TYPO3_DB;
			

			/*
			Check BE user access

			06/05/2008

			$BE_USER->getPagePermsClause(1)
			only works if BE user is owner of page, not group access
			$BE_USER->fetchGroupData(); adds group access
			*/
			if($BE_USER->user['uid']>0){
				$BE_USER->fetchGroupData();
				$be_access = ' AND '.$BE_USER->getPagePermsClause(1);
			}else {
				$error = array('errortype'=>1,'errormsg'=>'You do not have access to storeHistory function');
				return $error;
				die;
			}	

			
			foreach($histArray as $k => $v) {
				if ($v['func'] == 'storePageData') {
					//this is the php equivalent of apply
					
					//return $this->storePageData($v['params'][0]);
					
					$success = call_user_func_array(array($this,$v['func']) , $v['params'] );
					if (!$success) {
						$error = array('errortype'=>1,'errormsg'=>'storePageData didnt fuckin work','params'=>$histArray);
						return $error;
						die;
					}
					//$this->storePageData($pObj);
				}else {
					$error = array('errortype'=>1,'errormsg'=>'Not right func','params'=>$histArray);
					return $error;
					die;
				}
			}
		
			
			//Clear out old cache
			$this->clearCache();
			//$arr = array('data'=>$data,'pObj'=>$pObj);
			$error = array('errortype'=>0);
			return $error;

		}	
		
		
		
		
		
		
		
		/*
		Used to update or create new tt_content records linked to tx_typoflash_content as records.
		record - new record, with or without uid
		table - for new record
		uid - of tx_typoflash_content
		*/

		function storeLinkedRecord($pObj){
			
			global $BE_USER,$EXEC_TIME,$TYPO3_DB;

			
			/*
			Check BE user access
			*/
			if($BE_USER->user['uid']>0){
				$BE_USER->fetchGroupData();
				$be_access = ' AND '.$BE_USER->getPagePermsClause(2);
			}else {
				$error = array('errortype'=>1,'errormsg'=>'You do not have access to storeLinkedRecord function');
				return $error;
				die;
			}	
			
			if(!isset($pObj['record'])){
				$error = array('errortype'=>1,'errormsg'=>'No record defined for storeLinkedRecord');
				return $error;
				die;
			}

			if(!isset($pObj['uid'])){
				$error = array('errortype'=>1,'errormsg'=>'No uid of tx_typoflash_content in storeLinkedRecord');
				return $error;
				die;
			}

			if(!isset($pObj['table'])){
				$error = array('errortype'=>1,'errormsg'=>'No table name for linked record in storeLinkedRecord');
				return $error;
				die;
			}
			/*
			Page id options
			*/
			if(!($pObj['record']['pid']>0) && !(strlen($pObj['record']['pid'])>0)){
				$error = array('errortype'=>1,'errormsg'=>'No pid set for record');
				return $error;
				die;
			}else if($pObj['record']['pid']>0){
				$page = 'uid='.intval($pObj['record']['pid']);
			}
			

			$where = $page .$be_access;

		
			/*
			First get all accesible pages for current user
			
			*/			

			$res1 = $TYPO3_DB->exec_SELECTquery('*', 'pages', $where, '', '');
			$accesiblePages = array();
			while ($row = $GLOBALS['TYPO3_DB']->sql_fetch_assoc($res1))	{
				$accesiblePages[$row['uid']] = $row;
			}
			


			//if fine to insert
		
			if($accesiblePages[intval($pObj['record']['pid'])] != null){


				if(isset($pObj['record']['uid'])){
					//Updating existing record
					$pObj['record']['tstamp'] = time();
					$res = $TYPO3_DB->exec_UPDATEquery($pObj['table'],'uid='.intval($pObj['record']['uid']), $pObj['record']);
						
				}else{
					//clean to insert new content
					 $pObj['record']['tstamp'] = time();
					//$pObj['record']['cruser_id'] =  $BE_USER->user['uid'];
					$res = $TYPO3_DB->exec_INSERTquery($pObj['table'], $pObj['record']);
					$pObj['record']['uid'] = $TYPO3_DB->sql_insert_id();
					
					
				}

				
				$err = mysql_error(); 
				if($err==''){
					
				}else {
					$error = array('errortype'=>1,'errormsg'=>$err);
					return $error;
					die;
				}
				


				//get tx_typoflash_content and tweak it
				$res1 = $TYPO3_DB->exec_SELECTquery('*', 'tx_typoflash_content', 'uid='.$pObj['uid'], '', '');
				$content = $GLOBALS['TYPO3_DB']->sql_fetch_assoc($res1);
		
				if($content['records']!=''){
					$content['records'].= ','.$pObj['table'].'_'.$pObj['record']['uid'];
				}else{
					$content['records'].= $pObj['table'].'_'.$pObj['record']['uid'];
				}

				
					//Updating existing record
				$content['tstamp'] = time();
				$res2 = $TYPO3_DB->exec_UPDATEquery('tx_typoflash_content','uid='.intval($content['uid']), $content);
						
				
				$err =mysql_error(); 
				if($err==''){
					return array('result'=>$pObj);
				}else {
					$error = array('errortype'=>1,'errormsg'=>$err);
					return $error;
				}
				return $pObj;






			}else{
				
				$error = array('errortype'=>1,'errormsg'=>'Function storeLinkedRecord says you no have access to page '.$pObj['record']['pid']);
				return $error;
				die;
			
			}




		}


		/*
		Similar to pageData but main key is always 'htmlVars' and then nested below on glue.key as normal
		*/



		function storeHtmlVars($pObj){
			
			global $BE_USER,$EXEC_TIME,$TYPO3_DB;


			/*
			Check BE user access

			06/05/2008

			$BE_USER->getPagePermsClause(1)
			only works if BE user is owner of page, not group access
			$BE_USER->fetchGroupData(); adds group access
			*/
			if($BE_USER->user['uid']>0){
				$BE_USER->fetchGroupData();
				$be_access = ' AND '.$BE_USER->getPagePermsClause(1);
			}else {
				$error = array('errortype'=>1,'errormsg'=>'You do not have access to storeHtmlVars function');
				return $error;
				die;
			}	

			/*
			Page id options
			*/
			if(!($pObj['id']>0) && !(strlen($pObj['id'])>0)){
				$error = array('errortype'=>1,'errormsg'=>'No pid sent');
				return $error;
				die;
			}else if($pObj['id']>0){
				$page = 'uid='.intval($pObj['id']);
			}else{
				//alias sent
				$page = 'alias="'.$pObj['id'].'"';
			}

			

			$where = $page .$be_access;

		
			$res = $TYPO3_DB->exec_SELECTquery('*', 'pages', $where, '', '');
			$row = $TYPO3_DB->sql_fetch_assoc($res);


			// *****************************************
			// We are passing L for language. 
			// *****************************************


			if(!($pObj['L']>0)){
				$pObj['L'] =0;
			}


			$all_data = unserialize($row['tx_typoflash_data']);
			/*
			We should store data in template namespace in case template is changed and data not updated
			*/

			$data = $all_data[$row['tx_typoflash_template']];
			

			if(is_array($data['htmlVars'][$pObj['L']])){
				//If key exists overwrite with new data
				$data['htmlVars'][$pObj['L']][$pObj['key']]= $pObj['data'] ;
			}else if(is_array($data['htmlVars'])){
				//Create languag array
				$data['htmlVars'][$pObj['L']] = array($pObj['key'] =>$pObj['data']);
			}else{
				//Create data array
				$data['htmlVars'] = array();
				$data['htmlVars'][$pObj['L']] = array($pObj['key'] =>$pObj['data']);
			}

			$all_data[$row['tx_typoflash_template']] = $data;
			$sdata = serialize($all_data);
			$TYPO3_DB->exec_UPDATEquery('pages',$page,array('tx_typoflash_data' => $sdata));

			//Clear out old cache
			$this->clearCache();
			$arr = array('data'=>$data,'pObj'=>$pObj);
			return $arr;

		}
/*
doesUserHaveAccess($row,$perms) 
Checks if the permissions is granted based on a page-record ($row) and $perms (binary and'ed)

Bits for permissions, see $perms variable:

1 - Show: See/Copy page and the pagecontent.
16- Edit pagecontent: Change/Add/Delete/Move pagecontent.
2- Edit page: Change/Move the page, eg. change title, startdate, hidden.
4- Delete page: Delete the page and pagecontent.
8- New pages: Create new pages under the page.

*/




		function getComponents($pObj){
			
			global $BE_USER,$EXEC_TIME,$TYPO3_DB;


			/*
			Check BE user access
			*/
			if($BE_USER->user['uid']>0){
				$be_access = $BE_USER->getPagePermsClause(1);
			}else {
				$error = array('errortype'=>1,'errormsg'=>'You do not have access to storePageData function');
				return $error;
				die;
			}	

			/*
			Page id options
			*/
			if(!($pObj['id']>0) && !(strlen($pObj['id'])>0)){
				$page ='';
			}else if($pObj['id']>0){
				$page = 'pid='.intval($pObj['id']);
			}else{
				//alias sent
				$error = array('errortype'=>1,'errormsg'=>'Function getComponents does not accept alias as page id');
				return $error;
				die;
			}

			/*
			First get all accesible pages for current user
			
			*/			

			$where = $page . $be_access;
			$res1 = $TYPO3_DB->exec_SELECTquery('*', 'pages', $where, '', '');
			$accesiblePages = array();
			while ($row = $GLOBALS['TYPO3_DB']->sql_fetch_assoc($res1))	{
				$accesiblePages[$row['uid']] = $row;
			}

			/*
			Then check if records reside within any of these pages
			*/
			$res = $TYPO3_DB->exec_SELECTquery('*', 'tx_typoflash_component', $page, '', 'name');
			if(!$res){
				$error = array('errortype'=>1,'errormsg'=>'No accessible flash components found at all at all');
				return $error;
				die;
			
			}
			$flashRecs = array();
			while ($row = $GLOBALS['TYPO3_DB']->sql_fetch_assoc($res))	{
				/*
				Add BE access check...is done on pages not records...
				*/
				if($accesiblePages[$row['pid']]!=null){
					//Compensation for stupiud naming
					$row['target'] = $row['path'];
					$row['path'] = 'uploads/tx_typoflash/';
					$flashRecs[] = $row;
				}
			}

			return $flashRecs;

		}

		/*
		A flash content can have the following properties
		uid
		pid
		tstamp
		crdate
		cruser_id
		sorting
		deleted
		hidden           
		starttime             
		endtime             
		fe_group            
		name            
		language             
		component            
		records                
		storage_page              
		media              
		conf                
		data               
		xml_conf            
		title               
		body_text              
		target  

		*/

		function saveContent($pObj){
			
			global $BE_USER,$EXEC_TIME,$TYPO3_DB;


			/*
			Check BE user access
			Eg ((pages.perms_everybody & 1 = 1)OR(pages.perms_userid = 4 AND pages.perms_user & 1 = 1)OR(pages.perms_groupid in (1) AND pages.perms_group & 1 = 1))
			*/
			if($BE_USER->user['uid']>0){
				$be_access = $BE_USER->getPagePermsClause(2);
			}else {
				$error = array('errortype'=>1,'errormsg'=>'You do not have access to saveComponent function');
				return $error;
				die;
			}	

			/*
			Page id options
			*/
			if(!($pObj['pid']>0)){
				$error = array('errortype'=>1,'errormsg'=>'Function saveContent did not receive pid');
				return $error;
				die;
			}

			/*
			Check if BE user got access to this page
			*/
			$page = 'uid='.intval($pObj['pid']).' AND ';

			$where = $page .$be_access;


			/*
			First get all accesible pages for current user
			
			*/			

			$res1 = $TYPO3_DB->exec_SELECTquery('*', 'pages', $where, '', '');
			$accesiblePages = array();
			while ($row = $GLOBALS['TYPO3_DB']->sql_fetch_assoc($res1))	{
				$accesiblePages[$row['uid']] = $row;
			}



			//if fine to insert

			if($accesiblePages[intval($pObj['pid'])] != null){

				//important to unset all props that are not in database! else mysql error

				$fields = array('uid'=>1,'pid'=>1,'sorting'=>1,'deleted'=>1,'hidden'=>1,'starttime'=>1,'endtime'=>1,'fe_group'=>1,'name'=>1,'language'=>1,'component'=>1,'records'=>1,'storage_page'=>1,'media'=>1,'media_category'=>1,'conf'=>1,'xml_conf'=>1,'title'=>1,'body_text'=>1,'target'=>1);

				//filter out all variables that will go into the serialized data field
				$data = array();
				//you could use in_array function here instead
				foreach($pObj as $k=>$v ){
					if(!isset($fields[$k])){
						//not in accepted fields tranfer to data
						$data[$k] = $v;
						unset($pObj[$k]);
					
					}
				}
				if(count($data)>0){
					$pObj['data'] = serialize($data);
				}

				if(isset($pObj['uid'])){
					//Updating existing record
					$pObj['tstamp'] = time();
					$res = $TYPO3_DB->exec_UPDATEquery('tx_typoflash_content','uid='.intval($pObj['uid']), $pObj);
						
				}else{
					//clean to insert new content
					$pObj['crdate'] =  $pObj['tstamp'] = time();
					$pObj['cruser_id'] =  $BE_USER->user['uid'];
					$res = $TYPO3_DB->exec_INSERTquery('tx_typoflash_content', $pObj);
					$pObj['uid'] = $TYPO3_DB->sql_insert_id();
					
				}
				return $pObj;
			}else{
				$error = array('errortype'=>1,'errormsg'=>'Function saveContent says you no have access to dat page '.$pObj['pid']);
				return $error;
				die;
			
			}

		}



		function deleteContent($pObj){
			
			global $BE_USER,$EXEC_TIME,$TYPO3_DB;


			/*
			Check BE user access
			Eg ((pages.perms_everybody & 1 = 1)OR(pages.perms_userid = 4 AND pages.perms_user & 1 = 1)OR(pages.perms_groupid in (1) AND pages.perms_group & 1 = 1))
			*/
			if($BE_USER->user['uid']>0){
				$be_access = $BE_USER->getPagePermsClause(4);
			}else {
				$error = array('errortype'=>1,'errormsg'=>'You do not have access to deleteComponent function');
				return $error;
				die;
			}	

			/*
			Page id options
			*/
			if(!($pObj['pid']>0)){
				$error = array('errortype'=>1,'errormsg'=>'Function deleteContent did not receive pid');
				return $error;
				die;
			}

			/*
			Check if BE user got access to this page
			*/
			$page = 'uid='.intval($pObj['pid']).' AND ';

			$where = $page .$be_access;


			/*
			First get all accesible pages for current user
			
			*/			

			$res1 = $TYPO3_DB->exec_SELECTquery('*', 'pages', $where, '', '');
			$accesiblePages = array();
			while ($row = $GLOBALS['TYPO3_DB']->sql_fetch_assoc($res1))	{
				$accesiblePages[$row['uid']] = $row;
			}



			//if fine to insert

			if($accesiblePages[intval($pObj['pid'])] != null){

				//important to unset all props that are not in database! else mysql error

				$fields = array('uid'=>1,'pid'=>1,'sorting'=>1,'deleted'=>1,'hidden'=>1,'starttime'=>1,'endtime'=>1,'fe_group'=>1,'name'=>1,'language'=>1,'component'=>1,'records'=>1,'storage_page'=>1,'media'=>1,'conf'=>1,'xml_conf'=>1,'title'=>1,'body_text'=>1,'target'=>1);

				//filter out all variables that will go into the serialized data field
				$data = array();
				foreach($pObj as $k=>$v ){
					if(!isset($fields[$k])){
						//not in accepted fields tranfer to data
						$data[$k] = $v;
						unset($pObj[$k]);
					
					}
				}
				$pObj['data'] = serialize($data);

				if(isset($pObj['uid'])){
					//Updating existing record
					$pObj['tstamp'] = time();
					$pObj['deleted'] = 1;
					$res = $TYPO3_DB->exec_UPDATEquery('tx_typoflash_content','uid='.intval($pObj['uid']), $pObj);
					return array('msg'=>'Record uid:'.$pObj['uid'] .' deleted','uid'=>$pObj['uid']);
				}

			}else{
				$error = array('errortype'=>1,'errormsg'=>'Function deleteContent says you no have access to dat page '.$pObj['pid']);
				return $error;
				die;
			
			}

		}




		function select($fields='*',$table='',$where='',$group='',$order='',$limit='',$callback='',$showDeleted=false){
			
			global $BE_USER,$EXEC_TIME,$TYPO3_DB;


			/*
			Check BE user access
			*/
			if($BE_USER->user['uid']>0){
				$be_access = '';
			/*if($BE_USER->check('tables_select',$table)){
				$be_access = ' AND '.$BE_USER->getPagePermsClause(1);//fix this!!! At the moment it selects fields from tables that aren't selected in the from statement for non-admins*/
				
			}else {
				$error = array('errortype'=>1,'errormsg'=>'You do not have access to select function for "'.$table.'"');
				return $error;
				die;
			}	
			
		
			if(!$showDeleted){
				$where .= ' AND NOT deleted';
			}
			$where .= $be_access;
			$res = $TYPO3_DB->exec_SELECTquery('SQL_CALC_FOUND_ROWS '. $fields , $table, $where,$group,$order,$limit);
			
			//$res = 	$TYPO3_DB->sql_query('SELECT SQL_CALC_FOUND_ROWS FROM ' . $fields .' ' .$table . ' WHERE ' . $where .' ORDER BY ' .$order .' LIMIT ' . $limit);
			
			$rowRes = $TYPO3_DB->sql_query('SELECT FOUND_ROWS();');

			$rowCalc = $TYPO3_DB->sql_fetch_assoc($rowRes);

			$totalRows = $rowCalc['FOUND_ROWS()'];
		
			$err =mysql_error(); 
			if($err==''){
				return array('result'=>$res,'callback'=>$callback,'totalRows'=>$totalRows);
			}else {
				$error = array('errortype'=>1,'errormsg'=>$err);
				return $error;
			}
		}



		function insert($table='',$obj='',$callback=''){
			global $BE_USER,$EXEC_TIME,$TYPO3_DB;
	
			/*
			Check BE user access
			*/
			//fix this!!! At the moment it selects fields from tables that aren't selected in the from statement for non-admins*/
				
			//if(!$BE_USER->check('tables_modify',$table)){
			if(!($BE_USER->user['uid']>0)){
				$error = array('errortype'=>1,'errormsg'=>'You do not have access to insert function');
				return $error;
				die;			
			}/*else if(!($obj['pid']>0)){
				//not valid for link tables
				$error = array('errortype'=>1,'errormsg'=>'No pid supplied for new record');
				return $error;
				die;
			}*/
	
			$obj['tstamp'] = $obj['crdate'] = time();
			$obj['cruser_id'] = $BE_USER->user['uid'];
		   	     	  
			$res = $TYPO3_DB->exec_INSERTquery($table, $obj);
			

			 

			$err =mysql_error(); 
			$obj['uid'] = $TYPO3_DB->sql_insert_id($res);
			if($err==''){
				return array('result'=>$obj,'callback'=>$callback);
			}else {
				$error = array('errortype'=>1,'errormsg'=>$err);
				return $error;
			}
		}
		

		/*
		 INSERT statements that use VALUES syntax can insert multiple rows. To do this, include multiple lists of column values, each enclosed within parentheses and separated by commas. Example:

		INSERT INTO tbl_name (a,b,c) VALUES(1,2,3),(4,5,6),(7,8,9);

		*/


		function insertMultiple($table='',$cols='',$vals=array(),$callback=''){
			global $BE_USER,$EXEC_TIME,$TYPO3_DB;
	
			/*
			Check BE user access
			*/
			//fix this!!! At the moment it selects fields from tables that aren't selected in the from statement for non-admins*/
				
			//if(!$BE_USER->check('tables_modify',$table)){
			if(!($BE_USER->user['uid']>0)){
				$error = array('errortype'=>1,'errormsg'=>'You do not have access to insert function');
				return $error;
				die;			
			}
	
			$cols = '(tstamp,crdate,cruser_id,'.$cols.')';
			$t = time();
			$t = $t.','.$t;
			
			$valStr = '';
			$l = count($vals)-1;
			foreach($vals as $k=>$v){
				if($k < $l){
					$valStr .= '('.$t.','. $BE_USER->user['uid'].','.$v.'),';
				}else{
					$valStr .= '('.$t.','. $BE_USER->user['uid'].','.$v.')';
				}
			
			}
			
			$query = 'INSERT INTO '. $table .$cols .' VALUES '. $valStr;
			$res = $TYPO3_DB->sql($TYPO3_DB,$query);
			

			 

			$err =mysql_error(); 
			
			if($err==''){
				return array('result'=>array(),'callback'=>$callback);
			}else {
				$error = array('errortype'=>1,'errormsg'=>$err);
				return $error;
			}
		}








		function update($table='',$where='',$obj='',$callback=''){
			global $BE_USER,$EXEC_TIME,$TYPO3_DB;

			/*
			Check BE user access
			*/
			//if(!$BE_USER->check('tables_modify',$table)){
			if(!($BE_USER->user['uid']>0)){
				$error = array('errortype'=>1,'errormsg'=>'You do not have access to update function');
				return $error;
				die;
			}else{
				//$be_access = ' AND '.$BE_USER->getPagePermsClause(1);
				$be_access = '';//fixx!!!

			}		
			$where.= $be_access;
			$res = $TYPO3_DB->exec_UPDATEquery($table,$where,$obj);
			
			$err =mysql_error(); 
			
			//affected rows only returns a useless number...we need to know the records
			$rowRes = $TYPO3_DB->exec_SELECTquery('uid' , $table, $where);
			//$affRows = $TYPO3_DB->sql_fetch_assoc($rowRes);
			$affArr = array();

			while ($row =  $TYPO3_DB->sql_fetch_assoc($rowRes))	{
			//foreach($affRows as $k=>$v){
				$affArr[] = $row['uid'];
			}

			if($err==''){
				return array('result'=>$obj,'callback'=>$callback,'affectedrows'=>$affArr);
			}else {
				$error = array('errortype'=>1,'errormsg'=>$err);
				return $error;
			}
		}

		function exec_delete($table='',$where='',$callback=''){
			global $BE_USER,$EXEC_TIME,$TYPO3_DB;

			/*
			Check BE user access
			*/
			//if(!$BE_USER->check('tables_modify',$table)){
			if(!($BE_USER->user['uid']>0)){
				$error = array('errortype'=>1,'errormsg'=>'You do not have access to exec_delete function');
				return $error;
				die;
			}else{
				//$be_access = ' AND '.$BE_USER->getPagePermsClause(1);
				$be_access = '';
			}		
			$where.= $be_access;



			//affected rows only returns a useless number...we need to know the records
			$rowRes = $TYPO3_DB->exec_SELECTquery('uid' , $table, $where);
			$affArr = array();

			while ($row =  $TYPO3_DB->sql_fetch_assoc($rowRes))	{
					$affArr[] = $row['uid'];
			}

			$res = $TYPO3_DB->exec_DELETEquery($table,$where);
			
			$err =mysql_error(); 
			$obj = array();
			//02/08/2007 changed so it returns uid of deleted record..not tested
			//$obj['uid'] = $TYPO3_DB->sql_insert_id($res);

			if($err==''){
				return array('result'=>$obj,'callback'=>$callback,'affectedrows'=>$affArr);
			}else {
				$error = array('errortype'=>1,'errormsg'=>$err);
				return $error;
			}
		}



		/*
		$linkTableLocal= where the uid of found record is used as uid_local in link table
				array of:
				$v['link_field']//the field name in the local table (in typo3 only showing number of links, but will be overwritten with oj arr)
				$v['link_table']//the linking table
				$v['linked_table'] //the table of the linked records, eg. fe_users
		*/

		function getRecords($fields='*',$table='',$where='',$group='',$order='',$limit='',$callback='',$showDeleted=false,$linkTableLocal=array(),$linkTableForeign=array()){
			
			global $BE_USER,$EXEC_TIME,$TYPO3_DB;


			/*
			Check BE user access
			*/
			if($BE_USER->user['uid']>0){
				$be_access = '';
			}else {
				$error = array('errortype'=>1,'errormsg'=>'You do not have access to getRecords');
				return $error;
				die;
			}	
			
			$recsResult = $this->getRecordsAsObjectArr($fields,$table,$where,$order,$limit,$showDeleted);
			//shuld chekc sub error msg first
			if(is_array($recsResult['result'])){
				foreach($recsResult['result'] as $k=>$row){
						
						//extract fields where this record is owner
						
						foreach($linkTableLocal as $kk=>$lt){
								$localLinkedUIDs = $this->getLinkedRecordUidsArray($row['uid'],0,$lt['link_table']);
								foreach($localLinkedUIDs as $kkk=>$lUid){
									$row[$lt['link_field']]=$this->getRecordsAsObjectArr($lt['linked_table_fields'],$lt['linked_table'],'uid = '.$lUid);
								}
						}
						//extract fields where this field is a foreign link
						foreach($linkTableForeign as $kk=>$ft){
								$foreignLinkedUIDs = $this->getLinkedRecordUidsArray(0,$row['uid'],$ft['link_table']);
								foreach($foreignLinkedUIDs as $kkkk=>$fUid){
									$row[$ft['link_field']]=$this->getRecordsAsObjectArr($ft['linked_table_fields'],$ft['linked_table'],'uid = '.$fUid);
								}
						}

						
				}


			}

			$recsResult['callback'] = $callback;

			$err =mysql_error(); 
			if($err==''){
				return $recsResult;
			}else {
				$error = array('errortype'=>1,'errormsg'=>$err);
				return $error;
			}
		}


		
		function getRecordsAsObjectArr($fields='*',$table='',$where='',$order='',$limit='',$showDeleted=false){
			global $BE_USER,$EXEC_TIME,$TYPO3_DB;
		
			/*
			Check BE user access
			*/
			if($BE_USER->user['uid']>0){
				$be_access = '';
			}else {
				$error = array('errortype'=>1,'errormsg'=>'You do not have access to getRecords');
				return $error;
				die;
			}	
			
		
			if(!$showDeleted){
				$where .= ' AND NOT deleted';
			}
			$where .= $be_access;
			$res = $TYPO3_DB->exec_SELECTquery('SQL_CALC_FOUND_ROWS '. $fields , $table, $where,'',$order,$limit);
			
			$rowRes = $TYPO3_DB->sql_query('SELECT FOUND_ROWS();');

			$rowCalc = $TYPO3_DB->sql_fetch_assoc($rowRes);

			$totalRows = $rowCalc['FOUND_ROWS()'];


			$resArr = array();
			while ($row =  $TYPO3_DB->sql_fetch_assoc($res))	{
					$resArr[] = $row;
			}

		
			$err =mysql_error(); 
			if($err==''){
				return array('result'=>$resArr,'totalRows'=>$totalRows);
			}else {
				$error = array('errortype'=>1,'errormsg'=>$err);
				return $error;
			}
		
		
		}
	
		function getLinkedRecordUidsArray($uid_local=0,$uid_foreign=0,$link_table=''){
			global $BE_USER,$EXEC_TIME,$TYPO3_DB;	
			if($uid_local>0){
				$where = 'uid_local = '.$uid_local;
				$lRes = $TYPO3_DB->exec_SELECTquery('*' , $link_table, $where);
				
				$arr = array();
				while ($row =  $TYPO3_DB->sql_fetch_assoc($lres))	{
						$arr[] = $row['uid_foreign'];
				}
			}else if($uid_foreign>0){
				$where = 'uid_foreign = '.$uid_foreign;
				$lRes = $TYPO3_DB->exec_SELECTquery('*' , $link_table, $where);
				
				$arr = array();
				while ($row =  $TYPO3_DB->sql_fetch_assoc($lres))	{
						$arr[] = $row['uid_local'];
				}
			
			
			}			
			return $arr;


		}

		/*
				$v['main_table']
				$v['uid_local']
				
				$v['foreign_table']
				$v['uid_foreign']
				$v['link_table']


		*/

		function linkRecords($arr=array(),$callback=''){
			global $BE_USER,$EXEC_TIME,$TYPO3_DB;
			/*
			Check BE user access
			*/
			if($BE_USER->user['uid']>0){
				$be_access = '';
			
			}else {
				$error = array('errortype'=>1,'errormsg'=>'You do not have access to linkRecords function');
				return $error;
				die;
			}	
			
			
			$t = time();
			foreach($arr as $k=>$v){




				$c = array("uid_local"=>$v['uid_local'],"uid_foreign"=>$v['uid_foreign'],"crdate"=>$t); 
				$res = $GLOBALS['TYPO3_DB']->exec_INSERTquery($v['link_table'],$c);


				$err =mysql_error();
				if($err){
					$error = array("errortype"=>1,"errormsg"=>$err); 
					return $error; 
				}



				$query = "UPDATE ".$v['main_table']." SET ".$v['foreign_table']." = ".$v['foreign_table']."+1 WHERE uid =".$v['uid_local'].";";
				$res = $GLOBALS['TYPO3_DB']->sql(TYPO3_db, $query);
				$err =mysql_error();
				if($err){
					$error = array("errortype"=>1,"errormsg"=>$err); 
					return $error; 
				}

			}

			return array('result'=>true,'callback'=>$callback);

		}

		function unlinkRecords($arr=array(),$callback=''){
			global $BE_USER,$EXEC_TIME,$TYPO3_DB;

			/*
			Check BE user access
			*/
			if($BE_USER->user['uid']>0){
				$be_access = '';
			
			}else {
				$error = array('errortype'=>1,'errormsg'=>'You do not have access to unlinkRecords function');
				return $error;
				die;
			}	
			
			foreach($arr as $k=>$v){




				$where = "uid_local = ".$v['uid_local']. " AND uid_foreign = ".$v['uid_foreign']; 
				$res = $TYPO3_DB->exec_DELETEquery($v['link_table'],$where);


				$err =mysql_error();
				if($err){
					$error = array("errortype"=>1,"errormsg"=>$err); 
					return $error; 
				}



				$query = "UPDATE ".$v['main_table']." SET ".$v['foreign_table']." = ".$v['foreign_table']."-1 WHERE uid =".$v['uid_local'].";";
				$res = $GLOBALS['TYPO3_DB']->sql(TYPO3_db, $query);
				$err =mysql_error();
				if($err){
					$error = array("errortype"=>1,"errormsg"=>$err); 
					return $error; 
				}

			}

			return array('result'=>true,'callback'=>$callback);
		}

	

		/*
		DAM related
		*/


		//Returns a list of accessible categories 
		function getMediaCategories(){
			global $TSFE,$EXEC_TIME,$FE_USER,$BE_USER,$FLAT_LIST,$TYPO3_DB;



			/*
			Check BE user access
			*/
			if($BE_USER->user['uid']>0){
				$be_access = $BE_USER->getPagePermsClause(1);

			
			}else {
				$error = array('errortype'=>1,'errormsg'=>'You do not have access to getMediaCategories function');
				return $error;
				die;
			}	


		
			$where = $be_access;

		
			/*
			First get all accesible pages for current user
			
			*/			

			$res1 = $TYPO3_DB->exec_SELECTquery('*', 'pages', $where, '', '');
			$accesiblePages = array();
			while ($row = $GLOBALS['TYPO3_DB']->sql_fetch_assoc($res1))	{
				$accesiblePages[$row['uid']] = $row;
			}
				
		
	

			$FLAT_LIST = array();
			$res2 = $GLOBALS['TYPO3_DB']->exec_SELECTquery('*', 'tx_dam_cat', ' NOT tx_dam_cat.deleted AND NOT tx_dam_cat.hidden','','tx_dam_cat.sorting');

			while ($row = $GLOBALS['TYPO3_DB']->sql_fetch_assoc($res2))	{
				if($accesiblePages[$row['pid']]!= null){
					unset($row['l18n_diffsource']);
					$FLAT_LIST['tx_dam_cat_'.$row['uid']] = $row;
				}

			}
			
			$rootCat = array();

			//filter on structure and language
			foreach ($FLAT_LIST as $k=>$v){
				if(!($v['parent_id']>0 || $v['l18n_parent']>0)){
						//we add this node as lang 0
						$rootCat[] = array('subcat'=> $this->getSubCats($v['uid']),'lang'=> $this->getCatLO($v['uid']));
							
				}

			}
		

			return array('tree'=>$rootCat,'flatlist'=>$FLAT_LIST);
		}
		
		//arrange on language
		function getSubCats($uid){
			global $FLAT_LIST;
			
			$obj = array();
			
			foreach ($FLAT_LIST as $k=>$v){
				if($v['parent_id'] == $uid && !($v['l18n_parent']>0)){
						$obj[] = array('subcat'=> $this->getSubCats($v['uid']),'lang'=> $this->getCatLO($v['uid']));
				}

			}

			return $obj;
		}

		//langug overlay
		function getCatLO($uid){
			global $FLAT_LIST;
			$obj = array();

			
			foreach ($FLAT_LIST as $k=>$v){
				if($v['l18n_parent']==$uid){
						$obj[$v['sys_language_uid']] = $v;
				}else if($v['uid']==$uid){
						//this make sure it gets added as 0
						$obj[0] = $v;
				
				}

			}

			return $obj;
		}








	//string of cats. eg.  	tx_dam_cat_4,tx_dam_cat_1  	 
	function setMediaCategories($pObj=array()){
			global $BE_USER,$EXEC_TIME,$TYPO3_DB;

			/*
			Check BE user access
			*/
			if($BE_USER->user['uid']>0){
				$be_access = '';
			
			}else {
				$error = array('errortype'=>1,'errormsg'=>'You do not have access to unlinkMediaCategory function');
				return $error;
				die;
			}	

			if(!isset($pObj['uid'])){
				$error = array("errortype"=>1,"errormsg"=>'No uid of tx_typoflash_content in setMediaCategories'); 
				return $error; 
			}
			$TYPO3_DB->exec_UPDATEquery('tx_typoflash_content','uid='.$pObj['uid'],array('media_category' => $pObj['media_category']));

			$err =mysql_error();
			if($err){
				$error = array("errortype"=>1,"errormsg"=>$err); 
				return $error; 
			}


			return $pObj;
		}

		/*
		
		$BE_USER->getPagePermsClause(1)
			traces eg.
			((pages.perms_everybody & 1 = 1)OR(pages.perms_userid = 2 AND pages.perms_user & 1 = 1))
			for non-admin user

			hence need to add group permissions it seems

Pre " ((pages.perms_everybody & 1 = 1)OR(pages.perms_userid = 2 AND pages.perms_user & 1 = 1))" 
$BE_USER->fetchGroupData();

post  ((pages.perms_everybody & 1 = 1)OR(pages.perms_userid = 2 AND pages.perms_user & 1 = 1)OR(pages.perms_groupid in (1) AND pages.perms_group & 1 = 1))",

Although $BE_USER->fetchGroupData(); is called in initBEuser in remotingbase it doesn't seem to have done its job

		*/









	function getAccessiblePages($pObj=null){
		global $EXEC_TIME,$TCA,$TYPO3_DB,$BE_USER;

		
		if(!($BE_USER->user['uid']>0)){
			$error = array('errortype'=>1,'errormsg'=>'No BE user logged in. No access to funciton getAccessiblePages');
			return $error;
			die;
		}

		$pObj = (array) $pObj;//make sure swx objects are cast as array
		if(isset($pObj['fields']) || isset($pObj->fields)){
			$pObj['fields'] = (array) $pObj['fields'];	
		}
		


		/*
		Set to FE menu by default
		*/
		if($pObj['menuType']==null){
			$pObj['menuType'] = 'BEmenu';
		}
		
		
		/*
		Check BE user access
		*/

		$from_table = 'pages';
		$BE_USER->fetchGroupData();
		$delete_clause = t3lib_BEfunc::deleteClause($from_table);
		$perms_clause = '';
		if (!$BE_USER->isAdmin() && $GLOBALS['TYPO3_CONF_VARS']['BE']['lockBeUserToDBmounts']) {
			$webMounts = $BE_USER->returnWebmounts();
			$perms_clause = $BE_USER->getPagePermsClause(1);
			/*
			//not using this as it gets all subpages as well and we just want to sort them ourselves
			foreach($webMounts as $key => $val) {
				if ($webMountPageTree) {
					$webMountPageTreePrefix = ',';
				}
				$webMountPageTree .= $webMountPageTreePrefix.$this->getTreeList($val, 999, $begin = 0, $perms_clause);
			}*/

			$webMountPageTree = implode(',',$webMounts);

			if ($from_table == 'pages') {
				$delete_clause.=' AND '.$perms_clause;
			}
			$where_clause = 'pid IN ('.$webMountPageTree.') '.$delete_clause;

		} else {
			$where_clause = 'pid=0'.$delete_clause;
		}



		/*
		Field options
		*/
		if(!(is_array($pObj['fields']))){
			$pObj['fields'] =array('uid','pid','title','storage_pid','sys_language_uid','nav_title','subtitle','url','target','media','description','author','abstract','alias','doktype','shortcut','shortcut_mode');
			//$pObj['fields'] =array('uid','pid','title');	
		}
	
	

		//$access = $hide.$delete.$time.$be_access.$fe_access.$doktype;
		//$where = $page .$access;

		$menu = array();
		//return $where;
		$res = $TYPO3_DB->exec_SELECTquery('*', 'pages', $where_clause, '', 'sorting');

		while($row = $TYPO3_DB->sql_fetch_assoc($res)){


			

			$temp = array();
			$temp['media_path'] = 'uploads/media/';
			foreach($pObj['fields'] as $k=>$v){
				 $temp[$v] = $row[$v];
			}
		
			$temp['subpages'] = $this->getSubPages($row['uid'],$pObj['fields'],$delete_clause);

			$menu[] = $temp;
		}


		
		/*
		Return menuId so that flash can identify which menu is incoming
		*/
		$menu['menuId'] = $pObj['menuId'];

		
		
		unset($pObj['fields']);
		$menu['pObj'] = $pObj;
		return $menu;
	
	}
	
	function getSubPages($uid,$fields,$access){
		global $TYPO3_DB;
		if($uid == null){
			return array();
		}
		$where = 'pid='.$uid . $access;
		$menu = array();
		//$menu['associate']='array';
		
		$res = $TYPO3_DB->exec_SELECTquery('*', 'pages', $where, '', 'sorting');
		while ($row = $TYPO3_DB->sql_fetch_assoc($res))	{
			

			$temp = array();
			$temp['media_path'] = 'uploads/media/';
			foreach($fields as $k=>$v){
				 $temp[$v] = $row[$v];
			}
			
			$temp['subpages'] = $this->getSubPages($row['uid'],$fields,$access);

			if($temp['uid'] >0){
				//Only add if some content found
				$menu[] = $temp;
			}
			
		}
		return $menu;
	
	
	}



	function getTreeList($id, $depth, $begin = 0, $perms_clause)	{
		$depth = intval($depth);
		$begin = intval($begin);
		$id = intval($id);
		if ($begin == 0)	{
			$theList = $id;
		} else {
			$theList = '';
		}
		if ($id && $depth > 0)	{
			$res = $GLOBALS['TYPO3_DB']->exec_SELECTquery(
				'uid',
				'pages',
				'pid='.$id.' '.t3lib_BEfunc::deleteClause('pages').' AND '.$perms_clause
			);
			while ($row = $GLOBALS['TYPO3_DB']->sql_fetch_assoc($res))	{
				if ($begin <= 0)	{
					$theList .= ','.$row['uid'];
				}
				if ($depth > 1)	{
					$theList .= $this->getTreeList($row['uid'], $depth-1, $begin-1, $perms_clause);
				}
			}
		}
		return $theList;
	}






		function clearCache(){
			$GLOBALS['TYPO3_DB']->exec_DELETEquery('cache_hash', 'ident LIKE "REMOTING%"');
			return mysql_error();
		}

	}
?>
