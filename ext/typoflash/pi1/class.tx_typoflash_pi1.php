<?php
/***************************************************************
*  Copyright notice
*  
*  (c) 2004 Andreas Borg (borg@elevated.to)
*  All rights reserved
*
*  This script is part of the TYPO3 project. The TYPO3 project is 
*  free software; you can redistribute it and/or modify
*  it under the terms of the GNU General Public License as published by
*  the Free Software Foundation; either net.typoflash 2 of the License, or
*  (at your option) any later net.typoflash.
* 
*  The GNU General Public License can be found at
*  http://www.gnu.org/copyleft/gpl.html.
* 
*  This script is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*
*  This copyright notice MUST APPEAR in all copies of the script!
***************************************************************/
/** 
 * Plugin 'Flash component' for the 'typoflash' extension.
 *
 * @author	Andreas Borg <borg@elevated.to>








Affected database tables:
tx_typoflash_component
tx_typoflash_template
pages
tt_content

Flash:
Templates
	|					|
	|-Fixed objects		|-Dynamic objects
		|						|
		|-Menus					|-Template or page level components
		|
		|-Components in content holder
		|
		|-Frames
			|
			|-Components
	

Page/template data structure:

LANG[uid]
	|
	|-[movieclip]
			|
			|-name/value pairs
			|
			|-hidden
				|
				|-name/value pairs



Todo:
SEO and non flash content
Use expressinstall in flash


 */


require_once(PATH_tslib."class.tslib_pibase.php");

class tx_typoflash_pi1 extends tslib_pibase {
	var $prefixId = "tx_typoflash_pi1";		// Same as class name
	var $scriptRelPath = "pi1/class.tx_typoflash_pi1.php";	// Path to this script relative to the extension dir.
	var $extKey = "typoflash";	// The extension key.

	var $tmplTFdata;//template level data, mainly relevant for htmlVars to be output in html

	/**
	 * [Put your description here]
	 */
	function main($content,$conf)	{
		
		//$GLOBALS["TSFE"]->set_no_cache();//comment out later
		$GLOBALS['TSFE']->additionalHeaderData['credit'] = '
<!-- 
	TypoFlash is an extension developed by Andreas Borg @ Elevated. 
	It boosts Typo3 with Flash Remoting and a Flash CMS making it easy and fast to edit and update
	fully interactive multimedia websites. Nice eh!
	Visit http://typoflash.net for more info.
-->';
		$GLOBALS['TSFE']->additionalHeaderData['swfobject_script'] = '
<script type="text/javascript" src="typo3conf/ext/typoflash/pi1/js/swfobject.js"></script>
<script type="text/javascript" src="typo3conf/ext/typoflash/pi1/js/swfaddress.js"></script>';

		/*$GLOBALS['TSFE']->additionalHeaderData['flash_script'] = '
<script language="JavaScript" src="typo3conf/ext/typoflash/pi1/js/browserdet.js"></script>
<script language="JavaScript" src="typo3conf/ext/typoflash/pi1/js/flashdet.js"></script>
<script language="JavaScript" src="typo3conf/ext/typoflash/pi1/js/AC_RunActiveContent.js"></script>';*/

		$this->conf=$conf;		// Setting the TypoScript passed to this function in $this->conf
		$this->pi_setPiVarDefaults();

		$this->pi_loadLL();	
		$this->LLuid = $GLOBALS['TSFE']->config['config']['sys_language_uid'];
		if(!isset($this->LLuid)){
			$this->LLuid = 0;
		}


		// Init flexform configuration of the plugin
		$this->pi_initPIflexForm();
		
		// Get flexform informations
		$piFlexForm = $this->cObj->data['pi_flexform'];

		$this->tx_typoflash_template = $this->pi_getFFvalue($piFlexForm,'tx_typoflash_template');
		$this->tx_typoflash_target = $this->pi_getFFvalue($piFlexForm,'target');
		$this->tx_typoflash_conf = $this->pi_getFFvalue($piFlexForm,'conf');
		
		//flash content records
		$this->tx_typoflash_what_to_render = $this->pi_getFFvalue($piFlexForm,'what_to_render','content_records');
		$this->tx_typoflash_records = $this->pi_getFFvalue($piFlexForm,'records','content_records');
		$this->tx_typoflash_pages = $this->pi_getFFvalue($piFlexForm,'pages','content_records');
		$this->tx_typoflash_tables = $this->pi_getFFvalue($piFlexForm,'tables','content_records');
		$this->tx_typoflash_recordLimit = $this->pi_getFFvalue($piFlexForm,'recordLimit','content_records');
		$this->tx_typoflash_orderBy = $this->pi_getFFvalue($piFlexForm,'orderBy','content_records');
		
		//non flash content records
		$this->tx_typoflash_nf_what_to_render = $this->pi_getFFvalue($piFlexForm,'what_to_render','non_flash');
		$this->tx_typoflash_nf_records = $this->pi_getFFvalue($piFlexForm,'records','non_flash');
		$this->tx_typoflash_nf_pages = $this->pi_getFFvalue($piFlexForm,'pages','non_flash');
		$this->tx_typoflash_nf_showlink = $this->pi_getFFvalue($piFlexForm,'show_plugin_link','non_flash');
		

		//seo content records
		$this->tx_typoflash_seo_what_to_render = $this->pi_getFFvalue($piFlexForm,'what_to_render','seo');
		$this->tx_typoflash_seo_records = $this->pi_getFFvalue($piFlexForm,'records','seo');
		$this->tx_typoflash_seo_pages = $this->pi_getFFvalue($piFlexForm,'pages','seo');
		

/*
flex vars

tx_typoflash_component
target
conf


sheet: content_records
records
pages
tables
recordLimit
orderBy
*/

		return $this->pi_wrapInBaseClass($this->renderTemplateInline());
		
		/*switch((string)$conf["CMD"])	{
			case "singleView":
				list($t) = explode(":",$this->cObj->currentRecord);
				$this->internal["currentTable"]=$t;
				$this->internal["currentRow"]=$this->cObj->data;

				return $this->pi_wrapInBaseClass($this->singleView($content,$conf));
			break;
			default:
				if (strstr($this->cObj->currentRecord,"tt_content"))	{
					$conf["pidList"] = $this->cObj->data["pages"];
					$conf["recursive"] = $this->cObj->data["recursive"];
				}
				return $this->pi_wrapInBaseClass($this->listView($content,$conf));
			break;
		}*/
	}

	/**
	 * Main function for rendering of Page Templates of TypoFlash as fullpage alternative page renderer
	page = PAGE
	page.typeNum = 0
	page.10 = USER
	page.10.userFunc = tx_typoflash_pi1->main_page
	page.10.HOST_URL= http://inspira.tion.to/
	page.10.REMOTING_RELAY_SOCKET = inspira.tion.to
	page.10.REMOTING_RELAY_PORT = 8888
	page.10.RELAY_SERVER = projects.puertaandaluza.com_8888.php
	page.10.CODE_PAGE = true
	page.10.SCALE_MODE = noScale
	page.10.ALIGN = TL
	 */
    function main_page($content,$conf)    {
		$this->conf =$conf;

			// Current page record which we MIGHT manipulate a little:
		$pageRecord = $GLOBALS['TSFE']->page;
		$this->tmplTFdata = unserialize($pageRecord['tx_typoflash_data']);
		$this->tmplTFdata = $this->tmplTFdata[$pageRecord['tx_typoflash_template']];
		
			// Find Template in root line IF there is no Data Structure set for the current page:
		if (!$pageRecord['tx_typoflash_template'])	{
			
			foreach($GLOBALS['TSFE']->tmpl->rootLine as $pRec)	{
				
				if ($pageRecord['uid'] != $pRec['uid'])	{
					if ($pRec['tx_typoflash_template'])	{	// If there is a next-level DS:
						$pageRecord['tx_typoflash_template'] = $pRec['tx_typoflash_template'];
						$this->tmplTFdata = unserialize($pRec['tx_typoflash_data']);
						$this->tmplTFdata = $this->tmplTFdata[$pRec['uid']];
					} 
				} else break;
			}
		}

		
		
		return $this->renderElement($pageRecord, 'pages');

    }

	/**
	 * Main function for rendering of Page Templates of TypoFlash as inline objects
	lib.flash = USER
	lib.flash.userFunc =tx_typoflash_pi1->main_inline
	lib.flash.HOST_URL= http://inspira.tion.to/
	lib.flash.REMOTING_RELAY_SOCKET = inspira.tion.to
	#lib.flash.REMOTING_RELAY_PORT = 8888
	#lib.flash.RELAY_SERVER = projects.puertaandaluza.com_8888.php
	lib.flash.CODE_PAGE = true
	lib.flash.SCALE_MODE = noScale
	lib.flash.ALIGN = TL
	 */
    function main_inline($content,$conf)    {
		
		$this->conf =$conf;


		$this->LLuid = $GLOBALS['TSFE']->config['config']['sys_language_uid'];
		if(!isset($this->LLuid)){
			$this->LLuid = 0;
		}

		
		//flash content records
		$this->tx_typoflash_what_to_render = $this->conf['CONTENT_RECORDS.what_to_render'];
		$this->tx_typoflash_records = $this->conf['CONTENT_RECORDS.records'];
		$this->tx_typoflash_pages = $this->conf['CONTENT_RECORDS.pages'];
		$this->tx_typoflash_tables = $this->conf['CONTENT_RECORDS.tables'];
		$this->tx_typoflash_recordLimit = $this->conf['CONTENT_RECORDS.recordLimit'];
		$this->tx_typoflash_orderBy = $this->conf['CONTENT_RECORDS.orderBy'];
		
		//non flash content records
		$this->tx_typoflash_nf_what_to_render = $this->conf['NON_FLASH.what_to_render'];
		$this->tx_typoflash_nf_records = $this->conf['NON_FLASH.records'];
		$this->tx_typoflash_nf_pages = $this->conf['NON_FLASH.pages'];
		$this->tx_typoflash_nf_showlink = $this->conf['NON_FLASH.show_plugin_link'];
		


		//seo content records
		$this->tx_typoflash_seo_what_to_render = $this->conf['SEO.what_to_render'];
		$this->tx_typoflash_seo_records = $this->conf['SEO.records'];
		$this->tx_typoflash_seo_pages = $this->conf['SEO.pages'];

		$GLOBALS['TSFE']->additionalHeaderData['credit'] = '
<!-- 
	TypoFlash is an extension developed by Andreas Borg @ Elevated. 
	It boosts Typo3 with Flash Remoting and a Flash CMS making it easy and fast to edit and update
	fully interactive multimedia websites. Nice eh!
	Visit http://typoflash.net for more info.
-->';
		$GLOBALS['TSFE']->additionalHeaderData['swfobject_script'] = '
<script type="text/javascript" src="typo3conf/ext/typoflash/pi1/js/swfobject.js"></script>
<script type="text/javascript" src="typo3conf/ext/typoflash/pi1/js/swfaddress.js"></script>';





			// Current page record which we MIGHT manipulate a little:
		$pageRecord = $GLOBALS['TSFE']->page;
		$this->tmplTFdata = unserialize($pageRecord['tx_typoflash_data']);
		//it is nested on template uid so as to prevent mixups
		//NOTE 12/05/2008 double check this is actually properly stored on template level as it seemed to trace empty templ uid key
		
		$this->tmplTFdata = $this->tmplTFdata[$pageRecord['tx_typoflash_template']];
		
			// Find Template in root line IF there is no Data Structure set for the current page:
		if (!$pageRecord['tx_typoflash_template'])	{
			
			foreach($GLOBALS['TSFE']->tmpl->rootLine as $pRec)	{
				
				if ($pageRecord['uid'] != $pRec['uid'])	{
					if ($pRec['tx_typoflash_template'])	{	// If there is a next-level DS:
						$pageRecord['tx_typoflash_template'] = $pRec['tx_typoflash_template'];
						$this->tmplTFdata = unserialize($pRec['tx_typoflash_data']);
						$this->tmplTFdata = $this->tmplTFdata[$pRec['tx_typoflash_template']];
								
					} 
				} else break;
			}
		}
		
		return $this->renderInlineElement($pageRecord, 'pages');

    }

	function renderInlineElement($row,$table)	{
		global $TYPO3_CONF_VARS;


				// Get data structure:
			$srcPointer = $row['tx_typoflash_template'];
			if (t3lib_div::testInt($srcPointer))	{	// If integer, then its a record we will look up:
				$this->tx_typoflash_template = $GLOBALS['TSFE']->sys_page->checkRecord('tx_typoflash_template', $srcPointer);

			} 
			$content = '';

			/*
			//Deprecated with dhtmlHistory 09/11/2006
			if($this->tx_typoflash_template['historyframe']=='1'){

				$content .='<iframe style="left:-1000;top:-1000;position:absolute" name="historyframe" src="" width="50" height="50" frameborder="0" align="left" scrolling="no" ></iframe>';
			};
			*/
			$content .= $this->renderTemplateInline($this->tx_typoflash_template, true);
			//$content .=$this->tx_typoflash_template;
			return $content;

	}







	function renderElement($row,$table)	{
		global $TYPO3_CONF_VARS;


			// Get data structure:
		$srcPointer = $row['tx_typoflash_template'];
		if (t3lib_div::testInt($srcPointer))	{	// If integer, then its a record we will look up:
			$fTemplate = $GLOBALS['TSFE']->sys_page->checkRecord('tx_typoflash_template', $srcPointer);

		} else {	// Otherwise expect it to be a file:
			$file = t3lib_div::getFileAbsFileName($srcPointer);
			if ($file && @is_file($file))	{
				$DS = t3lib_div::xml2array(t3lib_div::getUrl($file));
			}
		}
		$content = '';
		if($fTemplate){
			

$content .='
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />

	<!-- 
	TypoFlash is an extension developed by Andreas Borg @ Elevated. 
	It boosts Typo3 with Flash Remoting and a Flash CMS making it easy and fast to edit and update
	fully interactive multimedia websites. Nice eh!
	Visit http://typoflash.net for more info.
	-->';

						
if(strlen($fTemplate['css'])>0){
$content .='
	<style type="text/css">
		\/*<![CDATA[*/
	<!--
	\/*  styles for extension "tx_typoflash_pi1" */
	'.
$fTemplate['css'] .'
	-->
		\/*]]>*/
	</style>';}

if(strlen($fTemplate['title'])>0){
	
$content .='
	<title>'.$fTemplate['title'].'</title>';
}

$content .='
	<meta http-equiv="content-type" content="text/html; charset=iso-8859-1" />
	<meta name="author" content="Elevated" />
	</head>
	<body marginheight="0" topmargin="0" leftmargin="0" marginwidth="0">
	';

		$GLOBALS['TSFE']->additionalHeaderData['swfobject_script'] = '
<script type="text/javascript" src="typo3conf/ext/typoflash/pi1/js/swfobject.js"></script>
<script type="text/javascript" src="typo3conf/ext/typoflash/pi1/js/swfaddress.js"></script>';
if($fTemplate['historyframe']=='1'){

		/*$GLOBALS['TSFE']->additionalHeaderData['dhtmlHistory_script'] = '
<script type="text/javascript" src="typo3conf/ext/typoflash/pi1/js/dhtmlHistory.js"></script>';
		$GLOBALS['TSFE']->additionalHeaderData['typoFlashHistory_script'] = '
<script type="text/javascript" src="typo3conf/ext/typoflash/pi1/js/typoFlashHistory.js"></script>';//this will generate error in IE if no frame loaded, ie history disabled

	$content .='<iframe style="left:-1000;top:-1000;position:absolute" name="historyframe" src="" width="50" height="50" frameborder="0" align="left" scrolling="no" ></iframe>';*/
};


$content .='<div id="flashContent"></div>
	<script language="JavaScript">
	<!--//';

if(strlen($fTemplate['redirectpage'])>0){
//We have a redirect page
$content .='
	requiredVersion = '.$fTemplate['version'].';

	//flash detection
	if (actualVersion < requiredVersion){
		self.location.href = "'.$fTemplate['redirectpage'].'";
	}';

}else{
//No redirect. Urge to install plugin
$content .='
	requiredVersion = '.$fTemplate['version'].';

	//flash detection
	if (actualVersion < requiredVersion){
		htmlStr = \'<p class="tx_typoflash_pi1">To view this site you need to install a current version of the Flash player. It is quick and free. Follow this <a href="https://www.macromedia.com/go/getflashplayer" target="_blank">link</a>. </p>\';
		document.write(htmlStr);
	}';

}


$requiredVersion = $fTemplate['version'];
$width = $fTemplate['width'];
$height = $fTemplate['height'];
$bgcolour = $fTemplate['bgcolour'];
//+
if($fTemplate['codepage']){
	$codepage = '&CODE_PAGE='.$fTemplate['codepage'];
}else if($this->conf['CODE_PAGE']){
	$codepage = '&CODE_PAGE='.$this->conf['CODE_PAGE'];
}else{
	$codepage = '&CODE_PAGE=0';
}

if($fTemplate['scalemode']){
	$scalemode = '&SCALE_MODE='.$fTemplate['scalemode'];
}else if($this->conf['SCALE_MODE']){
	$scalemode = '&SCALE_MODE='.$this->conf['SCALE_MODE'];
}else{
	$scalemode = '&SCALE_MODE=noScale';
}


if($fTemplate['align']){
	$align = '&ALIGN='.$fTemplate['align'];
}else{
	$align = '&ALIGN=TL';
}


if($fTemplate['windowmode']){
	$windowmode = $fTemplate['windowmode'];
}else{
	$windowmode = 'window';
}


if($fTemplate['hosturl']){
	$hosturl = '&HOST_URL='.$fTemplate['hosturl'];
}else if($this->conf['HOST_URL']){
	$hosturl = '&HOST_URL='.$this->conf['HOST_URL'];
}else{
	$hosturl = '&HOST_URL=http://'.$_SERVER['HTTP_HOST'].'/';
}

	

if($fTemplate['relaysocket']){
	$relaysocket = '&REMOTING_RELAY_SOCKET='.$fTemplate['relaysocket'];
}else if($this->conf['REMOTING_RELAY_SOCKET']){
	$relaysocket = '&REMOTING_RELAY_SOCKET='.$this->conf['REMOTING_RELAY_SOCKET'];
}else{
	$relaysocket = '';
}

if($fTemplate['relayport']){
	$relayport = '&REMOTING_RELAY_PORT='.$fTemplate['relayport'];
}else if($this->conf['REMOTING_RELAY_PORT']){
	$relayport = '&REMOTING_RELAY_PORT='.$this->conf['REMOTING_RELAY_PORT'];
}else{
	$relayport = '';
}

if($fTemplate['relayserver']){
	$relayserver = '&RELAY_SERVER='.$fTemplate['relayserver'];
}else if($this->conf['RELAY_SERVER']){
	$relayserver = '&RELAY_SERVER='.$this->conf['RELAY_SERVER'];
}else{
	$relayserver = '';
}

if($fTemplate['preloader']){
	$preloader = '&PRELOADER='.$fTemplate['preloader'];
	$file = t3lib_div::getFileAbsFileName('uploads/tx_typoflash/'.$fTemplate['preloader']);
	$fsize = round(filesize($file)/1024) . ',';
}else{
	$preloader = '';
	$fsize = '';
}


$swfs = $fTemplate['swfs'];
if(strlen($swfs)>1){
		//get files sizes
		$ff = explode(',',$swfs);
		foreach($ff as $k=>$v){
			$file = t3lib_div::getFileAbsFileName('uploads/tx_typoflash/'.$v);
			$fsize.= round(filesize($file)/1024) . ',';
		}
}		

if($fTemplate['dynamic_fonts']){
	$dynamic_fonts = '&DYNAMIC_FONTS=';

	$df = explode(',',$fTemplate['dynamic_fonts']);
	foreach($df as $k=>$v){


		//we need to copy font file and library to base directory...only way I got it to work as the link url in the library didn't have any effect even if absolute path..and I didn't want to make assets base directory
		//AS3 fonts begin with _ char
		if ($fTemplate['asversion'] == 'as3') {
			$v = '_' . $v;
		}
		$fontsToAdd .= $v .',';
		$font_file = t3lib_div::getFileAbsFileName('uploads/tx_typoflash/'.$v);

		if(!file_exists($font_file)){
			$font_scr = t3lib_div::getFileAbsFileName('typo3conf/ext/typoflash/assets/'.$v);
			copy($font_scr,PATH_site.'uploads/tx_typoflash/'.$v);

		}
		if ($fTemplate['asversion'] == 'as2') {
			//as2 version loads two files for each font
			$fontName = substr($v,0,-4);
			$font_lib_file = t3lib_div::getFileAbsFileName('uploads/tx_typoflash/'.$fontName.'_lib.swf');
			if(!file_exists($font_lib_file)){
				$font_lib_scr = t3lib_div::getFileAbsFileName('typo3conf/ext/typoflash/assets/'.$fontName.'_lib.swf');
				copy($font_lib_scr,PATH_site.'uploads/tx_typoflash/'.$fontName.'_lib.swf');
			}
		}

		$file = t3lib_div::getFileAbsFileName('typo3conf/ext/typoflash/assets/'.$v);
		$fsize.= round(filesize($file)/1024) . ',';
	}
	//remove trailing ,
	$fontsToAdd = substr($fontsToAdd, 0, -1);
	$dynamic_fonts = '&DYNAMIC_FONTS='.$fontsToAdd;
}else{
	$dynamic_fonts = '';
}

if($fTemplate['fonts']){
	$fonts = '&FONTS='.$fTemplate['fonts'];
	$file = t3lib_div::getFileAbsFileName('uploads/tx_typoflash/'.$fTemplate['fonts']);
	$fsize .= round(filesize($file)/1024) . ',';
}else{
	$fonts = '';
}

		//finally add the template filesize too
$file = t3lib_div::getFileAbsFileName('uploads/tx_typoflash/'.$fTemplate['file']);
if(strlen($fsize)>1){
	$fsize.= round(filesize($file)/1024);
}else{
	$fsize= round(filesize($file)/1024);
}

if($fTemplate['swfs']){
	$swfs = '&SWFS='.$fTemplate['swfs'];
	$swfSize = '&SWFS_SIZE='.$fsize;
}else{
	$swfs = '';
	$swfSize = '&SWFS_SIZE='.$fsize;//can only add template size
}


	//some conf data need to be passed directy into the html rather than on getPage...eg root pid of menus...by storing that
	//as a special template level conf data "htmlVars" we can pass it it

		$data = $this->tmplTFdata;

		$htmlVars = '';
		if(is_array($data['htmlVars'][$this->LLuid])){
			foreach($data['htmlVars'][$this->LLuid] as $key=>$obj){
				if(is_array($obj)){
					foreach($obj as $k=>$v){
						if($v!=''){
							$htmlVars .= '&'.$key .'|'.$k.'='.$v;
						}
					}
				}
			}
		}


/*
preloader 
swfs
hosturl
relaysocket
relayport
relayserver
codepage
scalemode
align
windowmode
*/


//-
$codebaseURL="https://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version='".$fTemplate['version'].",0,0,0'";
$pluginsURL='https://www.macromedia.com/go/getflashplayer';
$base = 'uploads/tx_typoflash/';
//$base = '/typo3conf/ext/typoflash/assets/';

$language =  t3lib_div::GPvar('L') ? t3lib_div::GPvar('L') : $GLOBALS['TSFE']->config['config']['sys_language_uid'];

if($GLOBALS['BE_USER']->user['uid']>0){
	$GLOBALS['TSFE']->set_no_cache();
	$beAccess = "&BE_USER=" .$GLOBALS['BE_USER']->user['uid'];
}else{
	$beAccess = "";
}

//Added 26/03/2008

$sitetitle = $GLOBALS['TSFE']->tmpl->sitetitle;
$sitetitle = "&SITE_TITLE=". $sitetitle;

$title = $GLOBALS['TSFE']->page['title'];
$title = "&TITLE=". $title;


$vars = $hosturl. $relaysocket. $relayport.$relayserver.$preloader.$swfs.'&TEMPLATE='.$fTemplate['file'].$fonts.$dynamic_fonts.$swfSize. '&PAGE_ALIAS='.$row['alias'] .'&PAGE_ID='.$row['uid'] .'&L='.$language .$htmlVars.$sitetitle.$title .$codepage.$scalemode.$align.'&BG_COLOUR='.$bgcolour.'&IS_LIVE=1&HISTORY_ENABLED='.$fTemplate['historyframe'].$beAccess.'&QUERY_STRING='. rawurlencode($_SERVER['QUERY_STRING']);//append pid and query string, if the page is cached already you must append &no_cache=1 to get latest version


//$movie = $base.$fTemplate['file'] .'?'. $fTemplate['conf'] . '&PAGE_ID='.$row['uid'] .'&IS_LIVE=1&HISTORY_ENABLED='.$fTemplate['historyframe'].'&'. $_SERVER['QUERY_STRING'];//append pid and query string
$movie = '/typo3conf/ext/typoflash/pi1/'.$this->getCoreVersion($fTemplate['version'],$fTemplate['asversion']).'?'. $vars;
$quality = 'high';
if($fTemplate['menu']){
	$menu = 'true';
}else{
	$menu = 'false';
}

if($fTemplate['fullscreen']){
	$fullscreen = 'true';
}else{
	$fullscreen = 'false';
}

if($fTemplate['historyframe']=='1'){
	$movieId = 'main';//this is needed by historyframe
}else{
	$movieId = $fTemplate['movieId'];
}

//Continue with real flash content
$content .='else{




			var fo = new SWFObject("'.$movie.'", "main", "'.$width.'", "'.$height.'", "'.$fTemplate['version'].'", "'.$bgcolour.'",true);
			fo.addParam("quality", "'.($conf['conf.']['quality'] ? 'low' : 'high').'");
			fo.addParam("allowScriptAccess", "always");
			fo.addParam("wmode", "window");
			fo.addParam("menu", "'.$menu.'");
			fo.addParam("allowFullScreen", "'.$fullscreen.'");

			fo.addParam("align", "middle");
			fo.addParam("scale", "showall");
			fo.addParam("base", "'.$base.'");';
			fo.addParam("bgcolor", "'.$bgcolor.'");';
			fo.write("flashContent");
		</script>

				//-->

';




$content .='	<noscript>
	<p>Please enable javascript</p>

	</noscript>
	</div>
	</body>
</html>';

		} else {
			$content = $this->formatError('	Couldn\'t find a TypoFlash template set for table/row "'.$table.':'.$row['uid'].'"	
			If you think there are templates in the rootline that aren\'t found, try adding this line to the end of typo3conf/localconf.php
 $TYPO3_CONF_VARS[\'FE\'][\'addRootLineFields\'] .= \',tx_typoflash_template,tx_typoflash_conf\';');
		}

		return $content;
	}










	function getCoreVersion($version,$asversion){
	
	
		switch ($version){
			case '5':
				return 'core5.swf';
				break;
			case '6':
				return 'core6.swf';
				break;
			case '7':
				return 'core7.swf';
				break;
			case '8':
				return 'core8.swf';
				break;				
			case '9':
				return 'core9_'.$asversion.'.swf';
				break;
			case '10':
				return 'core10_'.$asversion.'.swf';
				break;
			case 'lite1.0':
				return 'core_lite1_0.swf';
				break;
			case 'lite1.1':
				return 'core_lite1_1.swf';
				break;
			case 'lite2.0':
				return 'core_lite2_0.swf';
				break;	
			case 'lite2.1':
				return 'core_lite2_1.swf';
				break;					
			default:
				return 'core8.swf';
				break;


		}
	
	
	}





	function renderTemplateInline($fTemplate = false, $core = false)	{
		global $TYPO3_CONF_VARS;

		
			// Get data structure:

		if (t3lib_div::testInt($this->tx_typoflash_template) && !$fTemplate)	{	// If integer, then its a record we will look up:
			$fTemplate = $GLOBALS['TSFE']->sys_page->checkRecord('tx_typoflash_template', $this->tx_typoflash_template);

		} 

		
		$content = '';
		if($fTemplate){
			



/*
$content .='
	<script language="JavaScript">
	<!--//';


//No redirect. Urge to install plugin
$content .='
	requiredVersion = '.$fTemplate['version'].';

	//flash detection
	if (actualVersion < requiredVersion){
		htmlStr = \'<p class="tx_typoflash_pi1">To view this site you need to install a current version of the Flash player. It is quick and free. Follow this <a href="https://www.macromedia.com/go/getflashplayer" target="_blank">link</a>. </p>\';
		document.write(htmlStr);
	}';


*/

$requiredVersion = $fTemplate['version'];
$width = $fTemplate['width'];
$height = $fTemplate['height'];
$bgcolour = $fTemplate['bgcolour'];
//+
if($fTemplate['codepage']){
	$codepage = '&CODE_PAGE='.$fTemplate['codepage'];
}else if($this->conf['CODE_PAGE']){
	$codepage = '&CODE_PAGE='.$this->conf['CODE_PAGE'];
}else{
	$codepage = '&CODE_PAGE=0';
}

if($fTemplate['scalemode']){
	$scalemode = '&SCALE_MODE='.$fTemplate['scalemode'];
}else if($this->conf['SCALE_MODE']){
	$scalemode = '&SCALE_MODE='.$this->conf['SCALE_MODE'];
}else{
	$scalemode = '&SCALE_MODE=noScale';
}


if($fTemplate['align']){
	$align = '&ALIGN='.$fTemplate['align'];
}else{
	$align = '&ALIGN=TL';
}


if($fTemplate['windowmode']){
	$windowmode = $fTemplate['windowmode'];
}else{
	$windowmode = 'window';
}

if($fTemplate['historyframe']=='1'){
//this will generate error in IE if no frame loaded, ie history disabled
		/*$GLOBALS['TSFE']->additionalHeaderData['dhtmlHistory_script'] = '
<script type="text/javascript" src="typo3conf/ext/typoflash/pi1/js/dhtmlHistory.js"></script>';
		$GLOBALS['TSFE']->additionalHeaderData['typoFlashHistory_script'] = '
<script type="text/javascript" src="typo3conf/ext/typoflash/pi1/js/typoFlashHistory.js"></script>';*/
}



if($fTemplate['hosturl']){
	$hosturl = '&HOST_URL='.$fTemplate['hosturl'];
}else if($this->conf['HOST_URL']){
	$hosturl = '&HOST_URL='.$this->conf['HOST_URL'];
}else{
	$hosturl = '&HOST_URL=http://'.$_SERVER['HTTP_HOST'].'/';
}


if($fTemplate['relaysocket']){
	$relaysocket = '&REMOTING_RELAY_SOCKET='.$fTemplate['relaysocket'];
}else if($this->conf['REMOTING_RELAY_SOCKET']){
	$relaysocket = '&REMOTING_RELAY_SOCKET='.$this->conf['REMOTING_RELAY_SOCKET'];
}else{
	$relaysocket = '';
}

if($fTemplate['relayport']){
	$relayport = '&REMOTING_RELAY_PORT='.$fTemplate['relayport'];
}else if($this->conf['REMOTING_RELAY_PORT']){
	$relayport = '&REMOTING_RELAY_PORT='.$this->conf['REMOTING_RELAY_PORT'];
}else{
	$relayport = '';
}

if($fTemplate['relayserver']){
	$relayserver = '&RELAY_SERVER='.$fTemplate['relayserver'];
}else if($this->conf['RELAY_SERVER']){
	$relayserver = '&RELAY_SERVER='.$this->conf['RELAY_SERVER'];
}else{
	$relayserver = '';
}

if($fTemplate['preloader']){
	$preloader = '&PRELOADER='.$fTemplate['preloader'];
	$file = t3lib_div::getFileAbsFileName('uploads/tx_typoflash/'.$fTemplate['preloader']);
	$fsize = round(filesize($file)/1024) . ',';
}else{
	$preloader = '';
	$fsize = '';
}


if($fTemplate['dynamic_fonts']){
	

	$df = explode(',',$fTemplate['dynamic_fonts']);
	foreach($df as $k=>$v){


		//we need to copy font file and library to base directory...only way I got it to work as the link url in the library didn't have any effect even if absolute path..and I didn't want to make assets base directory
		//AS3 fonts begin with _ char
		if ($fTemplate['asversion'] == 'as3') {
			$v = '_' . $v;
		}
		$fontsToAdd .= $v .',';
		$font_file = t3lib_div::getFileAbsFileName('uploads/tx_typoflash/'.$v);

		if(!file_exists($font_file)){
			$font_scr = t3lib_div::getFileAbsFileName('typo3conf/ext/typoflash/assets/'.$v);
			copy($font_scr,PATH_site.'uploads/tx_typoflash/'.$v);

		}
		if ($fTemplate['asversion'] == 'as2') {
			//as2 version loads two files for each font
			$fontName = substr($v,0,-4);
			$font_lib_file = t3lib_div::getFileAbsFileName('uploads/tx_typoflash/'.$fontName.'_lib.swf');
			if(!file_exists($font_lib_file)){
				$font_lib_scr = t3lib_div::getFileAbsFileName('typo3conf/ext/typoflash/assets/'.$fontName.'_lib.swf');
				copy($font_lib_scr,PATH_site.'uploads/tx_typoflash/'.$fontName.'_lib.swf');
			}
		}
		$file = t3lib_div::getFileAbsFileName('uploads/tx_typoflash/'.$v);
		$fsize.= round(filesize($file)/1024) . ',';


	}
	//remove trailing ,
	$fontsToAdd = substr($fontsToAdd, 0, -1);
	$dynamic_fonts = '&DYNAMIC_FONTS='.$fontsToAdd;
}else{
	$dynamic_fonts = '';
}

if($fTemplate['fonts']){
	$fonts = '&FONTS='.$fTemplate['fonts'];
	$file = t3lib_div::getFileAbsFileName('uploads/tx_typoflash/'.$fTemplate['fonts']);
	$fsize .= round(filesize($file)/1024) . ',';
}else{
	$fonts = '';
}

$swfs = $fTemplate['swfs'];
if(strlen($swfs)>1){
		//get files sizes
		$ff = explode(',',$swfs);
		foreach($ff as $k=>$v){
			$file = t3lib_div::getFileAbsFileName('uploads/tx_typoflash/'.$v);
			$fsize.= round(filesize($file)/1024) . ',';
		}
}		
		//finally add the template filesize too
$file = t3lib_div::getFileAbsFileName('uploads/tx_typoflash/'.$fTemplate['file']);
if(strlen($fsize)>1){
	$fsize.= round(filesize($file)/1024);
}else{
	$fsize= round(filesize($file)/1024);
}

if($fTemplate['swfs']){
	$swfs = '&SWFS='.$fTemplate['swfs'];
	$swfSize = '&SWFS_SIZE='.$fsize;
}else{
	$swfs = '';
	$swfSize = '&SWFS_SIZE='.$fsize;//can only add template size
}



//some conf data need to be passed directy into the html rather than on getPage...eg root pid of menus...by storing that
//as a special template level conf data "htmlVars" we can pass it it

	$data = $this->tmplTFdata;

	$htmlVars = '';
	if(is_array($data['htmlVars'][$this->LLuid])){
			foreach($data['htmlVars'][$this->LLuid] as $key=>$obj){
				if(is_array($obj)){
					foreach($obj as $k=>$v){
						if($v!=''){
							$htmlVars .= '&'.$key .'|'.$k.'='.$v;
						}
					}
				}
			}
		}



/*
preloader 
swfs
hosturl
relaysocket
relayport
relayserver
codepage
scalemode
align
windowmode
*/


//-
$codebaseURL="https://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version='".$fTemplate['version'].",0,0,0'";
$pluginsURL='https://www.macromedia.com/go/getflashplayer';

$base = 'uploads/tx_typoflash/';

//$base = '/typo3conf/ext/typoflash/assets/';


$language =  t3lib_div::GPvar('L') ? t3lib_div::GPvar('L') : $GLOBALS['TSFE']->config['config']['sys_language_uid'];

if($GLOBALS['BE_USER']->user['uid']>0){
	$GLOBALS['TSFE']->set_no_cache();
	$beAccess = "&BE_USER=" .$GLOBALS['BE_USER']->user['uid'];
}else{
	$beAccess = "";
}






/*
Content rendering options.
We either choose 
1. all content records from same page,
2. else select specific records
3. else content from other page
4. or all content records from specified table and page

*/

//what page to get content from
if($this->tx_typoflash_what_to_render==1){
	//select all tt_content from this page
	$fPages = '&PAGES='.$GLOBALS['TSFE']->id;
}else{
	if($this->tx_typoflash_pages){
		$fPages = '&PAGES='.$this->tx_typoflash_pages;
	}else{
		$fPages = '';
	}
}


if($this->tx_typoflash_records){
	$fRecs = '&RECS='.$this->tx_typoflash_records;
}else{
	$fRecs = '';
}


if($this->tx_typoflash_tables){
	$fTables = '&TABLES='.$this->tx_typoflash_tables;
}else{
	$fTables = '';
}

if($this->tx_typoflash_recordLimit){
	$fLimit = '&LIMIT='.$this->tx_typoflash_recordLimit;
}else{
	$fLimit = '';
}

if($this->tx_typoflash_orderBy){
	$fOrder = '&ORDER_BY='.$this->tx_typoflash_orderBy;
}else{
	$fOrder = '';

}
;//append pid and query string, if the page is cached already you must append &no_cache=1 to get latest version

if($core){
	$addToCore = '&TEMPLATE='.$fTemplate['file'];
	$movie = '/typo3conf/ext/typoflash/pi1/'.$this->getCoreVersion($fTemplate['version'],$fTemplate['asversion']);
}else{
	$addToCore = '';
	$movie = '/uploads/tx_typoflash/'. $fTemplate['file'];
}

//Added 26/03/2008
$sitetitle = $GLOBALS['TSFE']->tmpl->sitetitle;
$sitetitle = "&SITE_TITLE=". $sitetitle;


$title = $GLOBALS['TSFE']->page['title'];
$title = "&TITLE=". $title;

//'&HTTP_USER_AGENT='.$_SERVER['HTTP_USER_AGENT']. //removed this since its getting cached and thus bit useless
$vars = $hosturl. $relaysocket. $relayport.$relayserver.$preloader.$fonts.$dynamic_fonts.$swfs.$swfSize. '&PAGE_ALIAS='.$row['alias']. '&PAGE_ID='.$GLOBALS['TSFE']->id .'&L='.$language  .$sitetitle.$title.$htmlVars.$codepage.$scalemode.$align.'&BG_COLOUR='.$bgcolour.'&IS_LIVE=1&IS_INLINE=1&HISTORY_ENABLED='.$fTemplate['historyframe'].'&'.$beAccess.'&QUERY_STRING='. rawurlencode($_SERVER['QUERY_STRING']).$fRecs.$fPages.$fTables.$fLimit.$fOrder.$fConf.$addToCore.'&TYPO3_OS='.TYPO3_OS;


//$movie = $base.$fTemplate['file'] .'?'. $fTemplate['conf'] . '&PAGE_ID='.$row['uid'] .'&IS_LIVE=1&HISTORY_ENABLED='.$fTemplate['historyframe'].'&'. $_SERVER['QUERY_STRING'];//append pid and query string


$quality = 'high';
if($fTemplate['menu']){
	$menu = 'true';
}else{
	$menu = 'false';
}

if($fTemplate['fullscreen']){
	$fullscreen = 'true';
}else{
	$fullscreen = 'false';
}

if($fTemplate['movieId']){
	$movieId = $fTemplate['movieId'];
}else{
	$movieId = 'movie_'.$this->cObj->data['uid'];
}

if(!isset($this->conf['DIV_TAG'])){

$content .='<div id="flashcontent_'.$this->cObj->data['uid'].'" class="typoflash_content" style="width:'.$width.',height:'.$height.',overflow:auto">';

}





/*****************************
Searchengine optimization
*****************************/

/*
if(stristr($HTTP_USER_AGENT,"Googlebot")) {
        $logtext = "Google";
} elseif (stristr($HTTP_USER_AGENT,"Slurp")) {
        $logtext = "Yahoo!";
} elseif (stristr($HTTP_USER_AGENT,"msnbot")) {
        $logtext = "MSN";
} elseif (stristr($HTTP_USER_AGENT,"Yandex")) {
        $logtext = "Yandex";
}

$ceoConf = array('table' => 'tt_content',
               'select.' => array('pidInList' => $GLOBALS['TSFE']->id,
			'orderBy' => 'sorting'));
	$content .='<div class="SEO" id="SEO_'.$this->cObj->data['uid'].'">';
	$content .= $this->cObj->CONTENT($ceoConf);
	$content .= '</div>';

}


		$this->tx_typoflash_seo_what_to_render = $this->pi_getFFvalue($piFlexForm,'what_to_render','seo');
		$this->tx_typoflash_seo_records = $this->pi_getFFvalue($piFlexForm,'records','seo');
		$this->tx_typoflash_seo_pages = $this->pi_getFFvalue($piFlexForm,'pages','seo');
*/
	

if(stristr($HTTP_USER_AGENT,"Googlebot") || stristr($HTTP_USER_AGENT,"Slurp") || stristr($HTTP_USER_AGENT,"msnbot") || stristr($HTTP_USER_AGENT,"Yandex") && ($this->tx_typoflash_seo_what_to_render>0)) {
	/*
	Content cloaked for search engines produced here
	*/

	$content .='<div class="SEO" id="SEO_'.$this->cObj->data['uid'].'">';

	if($this->tx_typoflash_seo_what_to_render==0){
		//content selected below
		if($this->tx_typoflash_nf_records){
			//extract records
			$content .= $this->cObj->RECORDS(array('source'=>$this->tx_typoflash_nf_records));
			/*$rr = explode(',',$this->tx_typoflash_nf_records);
			foreach($rr as $k=>$v){
				$tn = $this->getTableName($v);
				$ri = $this->getRecordId($v);

				$ceoConf = array('table' =>$tn,'select.' => array('where' =>'uid='. $ri));

				//output actual content
				$content .= $this->cObj->CONTENT($ceoConf);
			}*/

		}else if($this->tx_typoflash_nf_pages){
			//content from selected pages
			$rr = explode(',',$this->tx_typoflash_nf_pages);
			$pi='-10000';
			foreach($rr as $k=>$v){
				$pi .= ','.$this->getRecordId($v);
				
			}
			$ceoConf = array('table' => 'tt_content','select.' => array('pidInList' => $pi,'orderBy' => 'sorting'));
			//output actual content
			$content .= $this->cObj->CONTENT($ceoConf);
		}

	}else if($this->tx_typoflash_seo_what_to_render==1){
		//same as flash
		$ceoConf = array('table' => 'tt_content','select.' => array('pidInList' => $tt_pages_uid,'orderBy' => 'sorting'));
		//output actual content
		$content .= $this->cObj->CONTENT($ceoConf);	
	}else if($this->tx_typoflash_seo_what_to_render==2){
		//all content from this page
		$ceoConf = array('table' => 'tt_content','select.' => array('pidInList' => $GLOBALS['TSFE']->id,'orderBy' => 'sorting'));
	
	}

	$content .= $this->cObj->CONTENT($ceoConf);
	$content .='';
	$content .='</div>';
}else{

	/****************************
	Normal non flash content for all
	****************************/

	//wrap in special div tag with desired styling
	$content .='<div class="non_flash" id="non_flash_'.$this->cObj->data['uid'].'">';


	if($this->tx_typoflash_nf_what_to_render==0){
		//content selected below
		
		if($this->tx_typoflash_nf_records){
			//extract records
			$content .= $this->cObj->RECORDS(array('source'=>$this->tx_typoflash_nf_records));
			//untested http://typo3.org/documentation/document-library/references/doc_core_tsref/current/view/8/10/
			
			/*$rr = explode(',',$this->tx_typoflash_nf_records);
			foreach($rr as $k=>$v){
				$tn = $this->getTableName($v);
				$ri = $this->getRecordId($v);

				$ceoConf = array('table' =>$tn,'select.' => array('where' =>'uid='. $ri));
				
				//output actual content
				$content .= $this->cObj->CONTENT($ceoConf);

				
			}*/

		}else if($this->tx_typoflash_nf_pages){
			//content from selected pages
			$rr = explode(',',$this->tx_typoflash_nf_pages);
			$pi='-10000';
			foreach($rr as $k=>$v){
				$pi .= ','.$this->getRecordId($v);
				
			}
			$ceoConf = array('table' => 'tt_content','select.' => array('pidInList' => $pi,'orderBy' => 'sorting'));
			//output actual content
			$content .= $this->cObj->CONTENT($ceoConf);
		}

	}else if($this->tx_typoflash_nf_what_to_render==1){
		//same records as flash
		$ceoConf = array('table' => 'tt_content','select.' => array('pidInList' => $tt_pages_uid,'orderBy' => 'sorting'));
		//output actual content
		$content .= $this->cObj->CONTENT($ceoConf);
	}else if($this->tx_typoflash_nf_what_to_render==2){
		//all content from this page
		$ceoConf = array('table' => 'tt_content','select.' => array('pidInList' => $GLOBALS['TSFE']->id,'orderBy' => 'sorting'));
		//output actual content
		$content .= $this->cObj->CONTENT($ceoConf);
	}







	if($this->tx_typoflash_nf_showlink){
		$content .= '
		<a href="http://www.adobe.com/shockwave/download/index.cgi?P1_Prod_Version=ShockwaveFlash" target="_blank">Get Flash player here</a>'; 
	}
	$content .='</div>';
}

if(!isset($this->conf['DIV_TAG'])){
	//end normal flashcontent div
$content .='</div>
';
}
$content .='

		<script type="text/javascript">
			// <![CDATA[
';
/*
//23/08/2009 smarter to add style header than modify with javascript
if($this->conf['DIV_TAG']){
	//add styling to alternative div tag to make sure it sits nicely with w and h
$content .='

			var altTag = document.getElementById('.$this->conf['DIV_TAG'].');
			var browser=navigator.appName;
			var b_version=navigator.appVersion;
			var version=parseFloat(b_version);
			if (browser=="Microsoft Internet Explorer" && version>=6){
				altTag.style.setAttribute("cssText", "width:'.$width.',height:'.$height.',overflow:auto", 0);
			}else{
				//Non IE6
				altTag.setAttribute("style","width:'.$width.',height:'.$height.',min-height:'.$height.',overflow:auto");
			}

			
';
}
*/
$flashStyle = '
<style>
';

//23/08/2009 added min-height and html,body height 100% in to be able to fill entire height
if($height=='100%'){
	$flashStyle .=
'
	html,body{
		height:100%;
		margin:0;
		overflow:hidden;
	}
';
	if($this->conf['DIV_TAG']){
		$flashStyle .=
'
	#'.$this->conf['DIV_TAG'].'{
		width:'.$width.';
		height:'.$height.';
		min-height:'.$height.';
		overflow:hidden;
	}
';
		}
}else if($this->conf['DIV_TAG']){
	$flashStyle .=
'
	#'.$this->conf['DIV_TAG'].'{
		width:'.$width.';
		height:'.$height.';
		min-height:'.$height.';
		overflow:hidden;
	}
	';
}
$flashStyle .= '
</style>
';



$GLOBALS['TSFE']->additionalHeaderData['flashStyle'] = $flashStyle;

$content .='
			var fo = new SWFObject("'.$movie.'", "main", "'.$width.'", "'.$height.'", "'.$fTemplate['version'].'", "'.$bgcolour.'",true);
			fo.addParam("quality", "'.($conf['conf.']['quality'] ? 'low' : 'high').'");
			fo.addParam("allowScriptAccess", "always");
			fo.addParam("wmode", "'.$windowmode.'");
			fo.addParam("menu", "'.$menu.'");
			fo.addParam("base", "'.$base.'");
			fo.addParam("allowFullScreen", "'.$fullscreen.'");';

			if($vars){
				//break special variables up into Querystring format and url encode
				
				$qs = explode('&',$vars);
				foreach($qs as $ix=>$var){
					$qqs = explode('=',$var);
					if($qqs[0] != null){
					$content .='
			fo.addVariable("'.$qqs[0].'", "'.rawurlencode($qqs[1]).'");';

					}

				}
			}


			if($this->tx_typoflash_conf){
				//break special variables up into Querystring format and url encode
				
				$qs = explode('&',$this->tx_typoflash_conf);
				foreach($qs as $ix=>$var){
					$qqs = explode('=',$var);
					$content .='
				fo.addVariable("'.$qqs[0].'", "'.rawurlencode($qqs[1]).'");';

				}
			}
			//DIV_TAG is the alternative html tag to write the content into, if not into flashcontent_
			if($this->conf['DIV_TAG']){
			$content .='
			fo.write("'.$this->conf['DIV_TAG'].'");
			// ]]>
		</script>';

			}else{
			$content .='
			fo.write("flashcontent_'.$this->cObj->data['uid'].'");
			// ]]>
		</script>';
			
			}

$content .='	<noscript>
	<p>Please enable javascript</p>
	</noscript>
	';


/*
searchengine optimizatin
*/
//getTableName
//getRecordId
//if(eregi("googlebot",$HTTP_USER_AGENT)){}

/*
if(stristr($HTTP_USER_AGENT,"Googlebot")) {
        $logtext = "Google";
} elseif (stristr($HTTP_USER_AGENT,"Slurp")) {
        $logtext = "Yahoo!";
} elseif (stristr($HTTP_USER_AGENT,"msnbot")) {
        $logtext = "MSN";
} elseif (stristr($HTTP_USER_AGENT,"Yandex")) {
        $logtext = "Yandex";
}

if($fTemplate['searchengine'] && $this->tx_typoflash_records){
$ceoConf = array('table' => 'tt_content',
               'select.' => array('pidInList' => $GLOBALS['TSFE']->id,
			'orderBy' => 'sorting'));
	$content .='<div class="SEO" id="SEO_'.$this->cObj->data['uid'].'">';
	$content .= $this->cObj->CONTENT($ceoConf);
	$content .= '</div>';

}
*/
		} else {
			$content = $this->formatError('	Couldn\'t find a TypoFlash template set for table/row "'.$table.':'.$row['uid'].'"	
			If you think there are templates in the rootline that aren\'t found, try adding this line to the end of typo3conf/localconf.php
 $TYPO3_CONF_VARS[\'FE\'][\'addRootLineFields\'] .= \',tx_typoflash_template,tx_typoflash_conf\';');
		}

		return $content;
	}















   function init_typoflashHistory($content,$conf)    {
	   global $TYPO3_CONF_VARS;
		$this->conf =$conf;


			// Current page record which we MIGHT manipulate a little:
		$pageRecord = $GLOBALS['TSFE']->page;
		
			// Find Template in root line IF there is no Data Structure set for the current page:
		if (!$pageRecord['tx_typoflash_template'])	{
			
			foreach($GLOBALS['TSFE']->tmpl->rootLine as $pRec)	{
				
				if ($pageRecord['uid'] != $pRec['uid'])	{
					if ($pRec['tx_typoflash_template'])	{	// If there is a next-level DS:
						$pageRecord['tx_typoflash_template'] = $pRec['tx_typoflash_template'];
					} 
				} else break;
			}
		}


		


				// Get data structure:
			$srcPointer = $pageRecord['tx_typoflash_template'];
			if (t3lib_div::testInt($srcPointer))	{	// If integer, then its a record we will look up:
				$this->tx_typoflash_template = $GLOBALS['TSFE']->sys_page->checkRecord('tx_typoflash_template', $srcPointer);

			} 
			$content = '';

			if($this->tx_typoflash_template['historyframe']=='1'){
				$content .='<script type="text/javascript">initialize_typoflashHistory();</script>';
			}
			
		
		return $content;

    }










	/**
	 * Creates an error message for frontend output
	 *
	 * @param	[type]		$string: ...
	 * @return	string		Error message output
	 * @string	string		Error message input
	 */
	function formatError($string)	{

			// Set no-cache since the error message shouldn't be cached of course...
		$GLOBALS['TSFE']->set_no_cache();

			//
		$output = '
			<!-- TypoFlash ERROR message: -->
			<div class="tx_templavoila_pi1-error" style="
					border: 2px red solid;
					background-color: yellow;
					color: black;
					text-align: center;
					padding: 20px 20px 20px 20px;
					margin: 20px 20px 20px 20px;
					">'.
				'<strong>TypoFlash ERROR:</strong><br /><br />'.nl2br(htmlspecialchars(trim($string))).
				'</div>';
		return $output;
	}











	/**
	 * [Put your description here]
	 */
	function listView($content,$conf)	{
		$this->conf=$conf;		// Setting the TypoScript passed to this function in $this->conf
		$this->pi_setPiVarDefaults();
		$this->pi_loadLL();		// Loading the LOCAL_LANG values
		
		$lConf = $this->conf["listView."];	// Local settings for the listView function
		
		if ($this->piVars["showUid"])	{	// If a single element should be displayed:
			$this->internal["currentTable"] = "tx_typoflash_component";
			$this->internal["currentRow"] = $this->pi_getRecord("tx_typoflash_component",$this->piVars["showUid"]);
			
			$content = $this->singleView($content,$conf);
			return $content;
		} else {
			$items=array(
				"1"=> $this->pi_getLL("list_mode_1","Mode 1"),
				"2"=> $this->pi_getLL("list_mode_2","Mode 2"),
				"3"=> $this->pi_getLL("list_mode_3","Mode 3"),
			);
			if (!isset($this->piVars["pointer"]))	$this->piVars["pointer"]=0;
			if (!isset($this->piVars["mode"]))	$this->piVars["mode"]=1;
	
				// Initializing the query parameters:
			list($this->internal["orderBy"],$this->internal["descFlag"]) = explode(":",$this->piVars["sort"]);
			$this->internal["results_at_a_time"]=t3lib_div::intInRange($lConf["results_at_a_time"],0,1000,3);		// Number of results to show in a listing.
			$this->internal["maxPages"]=t3lib_div::intInRange($lConf["maxPages"],0,1000,2);;		// The maximum number of "pages" in the browse-box: "Page 1", "Page 2", etc.
			$this->internal["searchFieldList"]="name,prop_x,prop_y,prop_alpha,path,initobj";
			$this->internal["orderByList"]="uid,name,prop_x,prop_y,prop_alpha,path";
			
				// Get number of records:
			$res = $this->pi_exec_query("tx_typoflash_component",1);
			list($this->internal["res_count"]) = $GLOBALS['TYPO3_DB']->sql_fetch_row($res);
	
				// Make listing query, pass query to SQL database:
			$res = $this->pi_exec_query("tx_typoflash_component");
			$this->internal["currentTable"] = "tx_typoflash_component";
	
				// Put the whole list together:
			$fullTable="";	// Clear var;
		#	$fullTable.=t3lib_div::view_array($this->piVars);	// DEBUG: Output the content of $this->piVars for debug purposes. REMEMBER to comment out the IP-lock in the debug() function in t3lib/config_default.php if nothing happens when you un-comment this line!
				
				// Adds the mode selector.
			$fullTable.=$this->pi_list_modeSelector($items);	
			
				// Adds the whole list table
			$fullTable.=$this->pi_list_makelist($res);
			
				// Adds the search box:
			$fullTable.=$this->pi_list_searchBox();
				
				// Adds the result browser:
			$fullTable.=$this->pi_list_browseresults();
			
				// Returns the content from the plugin.
			return $fullTable;
		}
	}
	/**
	 * [Put your description here]
	 */
		function getTableName($str){
		//Find tableName as "tx_flashtemplate_content" in  "tx_flashtemplate_content_12"
		//$ditchMe = substr($str,-3,3);
		$ditchMe = strrchr($str,'_');
		if(strlen($ditchMe)>0){
			$arr = explode($ditchMe ,$str);
			return $arr[0];
		}else{
			return '';
		}
		
	//	return $tName;
	}
	
	function getRecordId($str){
		//Find recordId as last number of string, eg 12 in  "tx_flashtemplate_content_12"
		$arr = explode("_",$str);
		$recId = $arr[count($arr)-1];
		return $recId;
	}


	/**
	 * [Put your description here]
	 */
	function pi_list_row($c)	{
		$editPanel = $this->pi_getEditPanel();
		if ($editPanel)	$editPanel="<TD>".$editPanel."</TD>";
		
		return '<tr'.($c%2 ? $this->pi_classParam("listrow-odd") : "").'>
				<td><p>'.$this->getFieldContent("uid").'</p></td>
				<td valign="top"><p>'.$this->getFieldContent("name").'</p></td>
				<td valign="top"><p>'.$this->getFieldContent("prop_x").'</p></td>
				<td valign="top"><p>'.$this->getFieldContent("prop_y").'</p></td>
				<td valign="top"><p>'.$this->getFieldContent("prop_alpha").'</p></td>
				<td valign="top"><p>'.$this->getFieldContent("file").'</p></td>
				<td valign="top"><p>'.$this->getFieldContent("path").'</p></td>
				'.$editPanel.'
			</tr>';
	}
	/**
	 * [Put your description here]
	 */
	function pi_list_header()	{
		return '<tr'.$this->pi_classParam("listrow-header").'>
				<td><p>'.$this->getFieldHeader_sortLink("uid").'</p></td>
				<td><p>'.$this->getFieldHeader_sortLink("name").'</p></td>
				<td><p>'.$this->getFieldHeader_sortLink("prop_x").'</p></td>
				<td><p>'.$this->getFieldHeader_sortLink("prop_y").'</p></td>
				<td><p>'.$this->getFieldHeader_sortLink("prop_alpha").'</p></td>
				<td nowrap><p>'.$this->getFieldHeader("file").'</p></td>
				<td><p>'.$this->getFieldHeader_sortLink("path").'</p></td>
			</tr>';
	}
	/**
	 * [Put your description here]
	 */
	function getFieldContent($fN)	{
		switch($fN) {
			case "uid":
				return $this->pi_list_linkSingle($this->internal["currentRow"][$fN],$this->internal["currentRow"]["uid"],1);	// The "1" means that the display of single items is CACHED! Set to zero to disable caching.
			break;
			
			default:
				return $this->internal["currentRow"][$fN];
			break;
		}
	}
	/**
	 * [Put your description here]
	 */
	function getFieldHeader($fN)	{
		switch($fN) {
			
			default:
				return $this->pi_getLL("listFieldHeader_".$fN,"[".$fN."]");
			break;
		}
	}
	
	/**
	 * [Put your description here]
	 */
	function getFieldHeader_sortLink($fN)	{
		return $this->pi_linkTP_keepPIvars($this->getFieldHeader($fN),array("sort"=>$fN.":".($this->internal["descFlag"]?0:1)));
	}
}



if (defined("TYPO3_MODE") && $TYPO3_CONF_VARS[TYPO3_MODE]["XCLASS"]["ext/typoflash/pi1/class.tx_typoflash_pi1.php"])	{
	include_once($TYPO3_CONF_VARS[TYPO3_MODE]["XCLASS"]["ext/typoflash/pi1/class.tx_typoflash_pi1.php"]);
}

?>