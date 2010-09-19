<?PHP


require_once('contentrendering.php');	

    class fileupload extends contentrendering{


		/*
		File upload
		table = table
		field = field
		uid = uid of record
		m = multiple files allowed
		*/

		function registerUploadedFile(){
			set_time_limit(0); // This line sets the amount of time the script will execute for before it stops working. I've set this to 0 so there won't be any time-out errors.



			$table = t3lib_div::_GP('table');
			$field = t3lib_div::_GP('field');
			$rec = t3lib_div::_GP('uid');
			$multipleFilesAllowed = t3lib_div::_GP('multiple');
			$overwrite = t3lib_div::_GP('overwrite');

			if($multipleFilesAllowed == null){
				$multipleFilesAllowed = false;
			}
			
			if($overwrite == null){
				$overwrite = true;
			}

			if(!isset($table) || !isset($field) || !isset($rec)){
				die;
			}

			$uid = $GLOBALS['FE_USER']->user['uid'];
			$ug =  $GLOBALS['FE_USER']->user['usergroup'];
			

			//Check that we have someone logged in
			if(!($GLOBALS['BE_USER']->user['uid']>0 || $GLOBALS['FE_USER']->user['uid']>0)){
				$error = array('errortype'=>1,'errormsg'=>'You do not have access to upload function');
				return $error;
				die;			
			}
	



			//path to storage
			
			//if(preg_match('/tx_borgbusiness/',$table)){
			//	$storage = '../../../../uploads/tx_borgbusiness/';
			//}else{
				$storage = '../../../../uploads/tx_typoflash/';
			//}
			
			//check if old file is registered and need removing
			
			if($table != null && $rec != null){
				$res =  $GLOBALS['TYPO3_DB']->exec_SELECTquery($table,'uid=' .$rec);
				$row = $GLOBALS['TYPO3_DB']->sql_fetch_assoc($res);
				//since these records are wrappers for exclusive files we can remove them
				//else you need a db record that can be linked to several other recs
				if(!$multipleFilesAllowed && file_exists($storage . $row[$field])){
					unlink($storage . $row[$field]);

				}
			}
			//$filename = ereg_replace("[^A-Za-z0-9.]", "", $_FILES['Filedata']['name']);
			$fileName =basename( $_FILES['Filedata']['name'] );
			
				//path name of file for storage
			$uploadfile = $storage . $fileName;

			if(!$overwrite){
				$i=0;
				while (file_exists($uploadfile)) {
					$i++;
					$fileName = $i .'_'. basename( $_FILES['Filedata']['name']);
					$uploadfile = $storage . $fileName;
				} 
			}

			//if the file is moved successfully
			if ( move_uploaded_file( $_FILES['Filedata']['tmp_name'] , $uploadfile ) ) {
				
				chmod($uploadfile, 0777); 

				$pObj = array();
				$pObj['tstamp'] = time();
				if($multipleFilesAllowed && isset($row[$field])){
					$pObj[$field] = $row[$field] . ','.$fileName;//append this file to list if allowed
				}else{
					$pObj[$field] = $fileName;
				
				}
				if($table != null && $rec != null){
					$res =  $GLOBALS['TYPO3_DB']->exec_UPDATEquery($table,'uid=' .$rec,  $pObj);
				}

			}


			
		}	
	
	
	}


	fileupload::registerUploadedFile();
?>