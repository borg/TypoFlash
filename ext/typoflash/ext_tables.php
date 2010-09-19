<?php
if (!defined ("TYPO3_MODE")) 	die ("Access denied.");

if (TYPO3_MODE=="BE")	{
	//this adds the module	
	//t3lib_extMgm::addModule("web","txtypoflashM1","after:layout",t3lib_extMgm::extPath($_EXTKEY)."mod1/");
}




$tempColumns = Array (
	"tx_typoflash_template" => Array (		
		"exclude" => 1,		
		"label" => "LLL:EXT:typoflash/locallang_db.php:pages.tx_typoflash_template",		
		"config" => Array (
			"type" => "select",	
			"items" => Array (
				Array("",0),
			),
			"foreign_table" => "tx_typoflash_template",	
			"foreign_table_where" => "AND tx_typoflash_template.pid=###STORAGE_PID### ORDER BY tx_typoflash_template.uid",	
			"size" => 1,	
			"minitems" => 0,
			"maxitems" => 1,	
			"wizards" => Array(
				"_PADDING" => 2,
				"_VERTICAL" => 1,
				"edit" => Array(
					"type" => "popup",
					"title" => "Edit",
					"script" => "wizard_edit.php",
					"popup_onlyOpenIfSelected" => 1,
					"icon" => "edit2.gif",
					"JSopenParams" => "height=350,width=580,status=0,menubar=0,scrollbars=1",
				),
			),
		)
	),
	"tx_typoflash_conf" => Array (        
        "exclude" => 1,        
        "label" => "LLL:EXT:typoflash/locallang_db.php:pages.tx_typoflash_conf",        
        "config" => Array (
            "type" => "text",
            "cols" => "30",    
            "rows" => "5",
        )
    ),
	"tx_typoflash_data" => Array (        
        "exclude" => 1,        
        "label" => "LLL:EXT:typoflash/locallang_db.php:pages.tx_typoflash_data",        
        "config" => Array (
           'type' => 'passthrough',
        )
    ),
);
//23/08/2009 only added page data to TCA to test TCA main

t3lib_div::loadTCA("pages");
t3lib_extMgm::addTCAcolumns("pages",$tempColumns,1);
t3lib_extMgm::addToAllTCAtypes("pages","tx_typoflash_template;;;;1-1-1,tx_typoflash_conf;;;;1-1-1,tx_typoflash_data;;;;1-1-1");



t3lib_extMgm::allowTableOnStandardPages("tx_typoflash_template");


t3lib_extMgm::addToInsertRecords("tx_typoflash_template");

$TCA["tx_typoflash_template"] = Array (
	"ctrl" => Array (
		"title" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template",		
		"label" => "name",	
		"tstamp" => "tstamp",
		"crdate" => "crdate",
		"cruser_id" => "cruser_id",
		"sortby" => "sorting",	
		"delete" => "deleted",	
		"enablecolumns" => Array (		
			"disabled" => "hidden",	
			"starttime" => "starttime",	
			"endtime" => "endtime",	
			"fe_group" => "fe_group",
		),
		"dynamicConfigFile" => t3lib_extMgm::extPath($_EXTKEY)."tca.php",
		"iconfile" => t3lib_extMgm::extRelPath($_EXTKEY)."icon_tx_typoflash_template.gif",
	),
	"feInterface" => Array (
		"fe_admin_fieldList" => "hidden, starttime, endtime, fe_group, name, width, height, version,asversion, menu, bgcolour, movieid, historyframe, file, css, title, metakeyword, metadesc, searchengine, redirectpage, conf,language_file,preloader,dynamic_fonts,fonts, swfs, hosturl, relaysocket, relayport, relayserver, codepage, scalemode, align, windowmode,fullscreen",
	)
);


t3lib_extMgm::allowTableOnStandardPages("tx_typoflash_component");


t3lib_extMgm::addToInsertRecords("tx_typoflash_component");

$TCA["tx_typoflash_component"] = Array (
	"ctrl" => Array (
		"title" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_component",		
		"label" => "name",	
		"tstamp" => "tstamp",
		"crdate" => "crdate",
		"cruser_id" => "cruser_id",
		"sortby" => "sorting",	
		"delete" => "deleted",	
		"enablecolumns" => Array (		
			"disabled" => "hidden",	
			"starttime" => "starttime",	
			"endtime" => "endtime",	
			"fe_group" => "fe_group",
		),
		"dynamicConfigFile" => t3lib_extMgm::extPath($_EXTKEY)."tca.php",
		"iconfile" => t3lib_extMgm::extRelPath($_EXTKEY)."icon_tx_typoflash_component.gif",
	),
	"feInterface" => Array (
		"fe_admin_fieldList" => "hidden, starttime, endtime, fe_group, name, prop_x, prop_y, prop_alpha, file, path, initobj",
	)
);


t3lib_div::loadTCA("tt_content");
//flash components
$TCA["tt_content"]["types"]["list"]["subtypes_excludelist"][$_EXTKEY."_pi1"]="layout,select_key,pages";
$TCA['tt_content']['types']['list']['subtypes_addlist'][$_EXTKEY.'_pi1']='pi_flexform';
t3lib_extMgm::addPiFlexFormValue($_EXTKEY.'_pi1', 'FILE:EXT:typoflash/pi1/flexform_ds_pi1.xml');
t3lib_extMgm::addPlugin(Array("LLL:EXT:typoflash/locallang_db.php:tt_content.list_type_pi1", $_EXTKEY."_pi1"),"list_type");




if (TYPO3_MODE=="BE")	$TBE_MODULES_EXT["xMOD_db_new_content_el"]["addElClasses"]["tx_typoflash_pi1_wizicon"] = t3lib_extMgm::extPath($_EXTKEY)."pi1/class.tx_typoflash_pi1_wizicon.php";



t3lib_extMgm::addStaticFile($_EXTKEY, 'static/', 'TypoFlash setup example');


t3lib_extMgm::allowTableOnStandardPages("tx_typoflash_content");


t3lib_extMgm::addToInsertRecords("tx_typoflash_content");

$TCA["tx_typoflash_content"] = Array (
    "ctrl" => Array (
        "title" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_content",        
        "label" => "name",    
        "tstamp" => "tstamp",
        "crdate" => "crdate",
        "cruser_id" => "cruser_id",
        "sortby" => "sorting",
		"languageField" => "sys_language_uid",	
		"transOrigPointerField" => "l18n_parent",	
		"transOrigDiffSourceField" => "l18n_diffsource",			
		"delete" => "deleted",    
        "enablecolumns" => Array (        
            "disabled" => "hidden",    
            "starttime" => "starttime",    
            "endtime" => "endtime",    
            "fe_group" => "fe_group",
        ),
        "dynamicConfigFile" => t3lib_extMgm::extPath($_EXTKEY)."tca.php",
        "iconfile" => t3lib_extMgm::extRelPath($_EXTKEY)."icon_tx_typoflash_content.gif",
    ),
    "feInterface" => Array (
        "fe_admin_fieldList" => "sys_language_uid, l18n_parent, l18n_diffsource,hidden, starttime, endtime, fe_group, name, component, target, records, storage_page, media,media_category, conf, xml_conf, title, body_text",
    )
);



?>