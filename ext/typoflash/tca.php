<?php
if (!defined ("TYPO3_MODE")) 	die ("Access denied.");

$TCA["tx_typoflash_template"] = Array (
	"ctrl" => $TCA["tx_typoflash_template"]["ctrl"],
	"interface" => Array (
		"showRecordFieldList" => "hidden,starttime,endtime,fe_group,name,width,height,version,menu,bgcolour,movieid,historyframe,file,css,title,metakeyword,metadesc,searchengine,redirectpage,conf,preloader,dynamic_fonts,fonts,swfs,hosturl,relaysocket,relayport,relayserver,codepage,scalemode,align,windowmode,fullscren"
	),
	"feInterface" => $TCA["tx_typoflash_template"]["feInterface"],
	"columns" => Array (
		"hidden" => Array (		
			"exclude" => 1,	
			"label" => "LLL:EXT:lang/locallang_general.php:LGL.hidden",
			"config" => Array (
				"type" => "check",
				"default" => "0"
			)
		),
		"starttime" => Array (		
			"exclude" => 1,	
			"label" => "LLL:EXT:lang/locallang_general.php:LGL.starttime",
			"config" => Array (
				"type" => "input",
				"size" => "8",
				"max" => "20",
				"eval" => "date",
				"default" => "0",
				"checkbox" => "0"
			)
		),
		"endtime" => Array (		
			"exclude" => 1,	
			"label" => "LLL:EXT:lang/locallang_general.php:LGL.endtime",
			"config" => Array (
				"type" => "input",
				"size" => "8",
				"max" => "20",
				"eval" => "date",
				"checkbox" => "0",
				"default" => "0",
				"range" => Array (
					"upper" => mktime(0,0,0,12,31,2020),
					"lower" => mktime(0,0,0,date("m")-1,date("d"),date("Y"))
				)
			)
		),
		"fe_group" => Array (		
			"exclude" => 1,	
			"label" => "LLL:EXT:lang/locallang_general.php:LGL.fe_group",
			"config" => Array (
				"type" => "select",	
				"items" => Array (
					Array("", 0),
					Array("LLL:EXT:lang/locallang_general.php:LGL.hide_at_login", -1),
					Array("LLL:EXT:lang/locallang_general.php:LGL.any_login", -2),
					Array("LLL:EXT:lang/locallang_general.php:LGL.usergroups", "--div--")
				),
				"foreign_table" => "fe_groups"
			)
		),
		"name" => Array (		
			"exclude" => 1,		
			"label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.name",		
			"config" => Array (
				"type" => "input",	
				"size" => "30",
			)
		),
		"width" => Array (		
			"exclude" => 1,		
			"label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.width",		
			"config" => Array (
				"type" => "input",	
				"size" => "30",
			)
		),
		"height" => Array (		
			"exclude" => 1,		
			"label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.height",		
			"config" => Array (
				"type" => "input",	
				"size" => "30",
			)
		),
		"version" => Array (	
			"exclude" => 1,        
            "label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.version",        
            "config" => Array (
                "type" => "select",
                "items" => Array (
                    Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.version.I.0", "5"),
                    Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.version.I.1", "6"),
                    Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.version.I.2", "7"),
					Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.version.I.3", "8"),
					Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.version.I.4", "9"),
					Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.version.I.5", "10"),
					Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.version.I.6", "lite1.0"),
					Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.version.I.7", "lite1.1"),
					Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.version.I.8", "lite2.0"),
					Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.version.I.9", "lite2.1"),
                ),
                "size" => 1,    
                "maxitems" => 1,
				"default" => "8",
            )
		),
		"asversion" => Array (	
			"exclude" => 1,        
            "label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.asversion",        
            "config" => Array (
                "type" => "select",
                "items" => Array (
                    Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.asversion.I.0", "as1"),
                    Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.asversion.I.1", "as2"),
                    Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.asversion.I.2", "as3"),
                ),
                "size" => 1,    
                "maxitems" => 1,
				"default" => "as2",
            )
		),
		"menu" => Array (		
			"exclude" => 1,		
			"label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.menu",		
			"config" => Array (
				"type" => "check",
				"default" => 1,
			)
		),
		"bgcolour" => Array (		
			"exclude" => 1,		
			"label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.bgcolour",		
			"config" => Array (
				"type" => "input",	
				"size" => "30",	
				"wizards" => Array(
					"_PADDING" => 2,
					"color" => Array(
						"title" => "Color:",
						"type" => "colorbox",
						"dim" => "12x12",
						"tableStyle" => "border:solid 1px black;",
						"script" => "wizard_colorpicker.php",
						"JSopenParams" => "height=300,width=250,status=0,menubar=0,scrollbars=1",
					),
				),
			)
		),
		"movieid" => Array (		
			"exclude" => 1,		
			"label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.movieid",		
			"config" => Array (
				"type" => "input",	
				"size" => "30",
			)
		),
		"historyframe" => Array (		
			"exclude" => 1,		
			"label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.historyframe",		
			"config" => Array (
				"type" => "check",
				"default" => 1,
			)
		),
		"file" => Array (		
			"exclude" => 1,		
			"label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.file",		
			"config" => Array (
				"type" => "group",
				"internal_type" => "file",
				"allowed" => "",	
				"disallowed" => "php,php3",	
				"max_size" => 1000,	
				"uploadfolder" => "uploads/tx_typoflash",
				"size" => 1,	
				"minitems" => 0,
				"maxitems" => 1,
			)
		),
		"css" => Array (		
			"exclude" => 1,		
			"label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.css",		
			"config" => Array (
				"type" => "text",
				"cols" => "30",	
				"rows" => "5",
			)
		),
		"title" => Array (		
			"exclude" => 1,		
			"label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.title",		
			"config" => Array (
				"type" => "input",	
				"size" => "30",
			)
		),
		"metakeyword" => Array (		
			"exclude" => 1,		
			"label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.metakeyword",		
			"config" => Array (
				"type" => "text",
				"cols" => "30",	
				"rows" => "2",
			)
		),
		"metadesc" => Array (		
			"exclude" => 1,		
			"label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.metadesc",		
			"config" => Array (
				"type" => "text",
				"cols" => "30",	
				"rows" => "2",
			)
		),
		"searchengine" => Array (		
			"exclude" => 1,		
			"label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.searchengine",		
			"config" => Array (
				"type" => "check",
			)
		),
		"redirectpage" => Array (		
			"exclude" => 1,		
			"label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.redirectpage",		
			"config" => Array (
				"type" => "input",		
				"size" => "15",
				"max" => "255",
				"checkbox" => "",
				"eval" => "trim",
				"wizards" => Array(
					"_PADDING" => 2,
					"link" => Array(
						"type" => "popup",
						"title" => "Link",
						"icon" => "link_popup.gif",
						"script" => "browse_links.php?mode=wizard",
						"JSopenParams" => "height=300,width=500,status=0,menubar=0,scrollbars=1"
					)
				)
			)
		),
		"conf" => Array (		
			"exclude" => 1,		
			"label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.conf",		
			"config" => Array (
				"type" => "text",
				"cols" => "30",	
				"rows" => "5",
			)
		),
        "language_file" => Array (        
            "exclude" => 1,        
            "label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.language_file",        
            "config" => Array (
                "type" => "group",
                "internal_type" => "file",
                "allowed" => "",    
                "disallowed" => "php,php3",    
                "max_size" => 500,    
                "uploadfolder" => "uploads/tx_typoflash",
                "size" => 1,    
                "minitems" => 0,
                "maxitems" => 1,
            )
        ),
        "preloader" => Array (        
            "exclude" => 1,        
            "label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.preloader",        
            "config" => Array (
                "type" => "group",
                "internal_type" => "file",
                "allowed" => "",    
                "disallowed" => "php,php3",    
                "max_size" => 500,    
                "uploadfolder" => "uploads/tx_typoflash",
                "size" => 1,    
                "minitems" => 0,
                "maxitems" => 1,
            )
        ),
		 "dynamic_fonts" => Array (        
            "exclude" => 1,        
            "label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.dynamic_fonts",        
            "config" => Array (
                "type" => "select",
                "items" => Array (
                    Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.dynamic_fonts.I.0", "Arial.swf"),
                    Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.dynamic_fonts.I.1", "FFFAquarius.swf"),
                    Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.dynamic_fonts.I.2", "HelveticaNeue.swf"),
					Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.dynamic_fonts.I.3", "Verdana.swf"),
					Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.dynamic_fonts.I.4", "TrebuchetMS.swf"),
					Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.dynamic_fonts.I.5", "InfoTextRegular.swf"),
					Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.dynamic_fonts.I.6", "Palatino.swf"),
					Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.dynamic_fonts.I.7", "Georgia.swf"),
					Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.dynamic_fonts.I.8", "Caslon.swf"),
					Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.dynamic_fonts.I.9", "CaslonBold.swf"),
					Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.dynamic_fonts.I.10", "CaslonItalic.swf"),
					Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.dynamic_fonts.I.11", "PWExtended.swf"),
					Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.dynamic_fonts.I.12", "GrotesqueMT.swf"),
					Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.dynamic_fonts.I.13", "GrotesqueMTLight.swf"),
					Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.dynamic_fonts.I.14", "MunicaRegular.swf"),
					Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.dynamic_fonts.I.15", "MyriadPro.swf"),
                ),
                "size" => 7,    
                "maxitems" => 50,
            )
        ),
        "fonts" => Array (        
            "exclude" => 1,        
            "label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.fonts",        
            "config" => Array (
                "type" => "group",
                "internal_type" => "file",
                "allowed" => "",    
                "disallowed" => "php,php3",    
                "max_size" => 500,    
                "uploadfolder" => "uploads/tx_typoflash",
                "size" => 1,    
                "minitems" => 0,
                "maxitems" => 1,
            )
        ),
        "swfs" => Array (        
            "exclude" => 1,        
            "label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.swfs",        
            "config" => Array (
                "type" => "group",
                "internal_type" => "file",
                "allowed" => "",    
                "disallowed" => "php,php3",    
                "max_size" => 1000,    
                "uploadfolder" => "uploads/tx_typoflash",
                "size" => 14,    
                "minitems" => 0,
                "maxitems" => 20,
            )
        ),
        "hosturl" => Array (        
            "exclude" => 1,        
            "label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.hosturl",        
            "config" => Array (
                "type" => "input",    
                "size" => "30",
            )
        ),
        "relaysocket" => Array (        
            "exclude" => 1,        
            "label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.relaysocket",        
            "config" => Array (
                "type" => "input",    
                "size" => "30",
            )
        ),
        "relayport" => Array (        
            "exclude" => 1,        
            "label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.relayport",        
            "config" => Array (
                "type" => "input",    
                "size" => "30",
            )
        ),
        "relayserver" => Array (        
            "exclude" => 1,        
            "label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.relayserver",        
            "config" => Array (
                "type" => "input",    
                "size" => "30",
            )
        ),
        "codepage" => Array (        
            "exclude" => 1,        
            "label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.codepage",        
            "config" => Array (
                "type" => "check",
                "default" => 1,
            )
        ),
        "scalemode" => Array (        
            "exclude" => 1,        
            "label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.scalemode",        
            "config" => Array (
                "type" => "select",
                "items" => Array (
                    Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.scalemode.I.0", "noScale"),
                    Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.scalemode.I.1", "noborder"),
                    Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.scalemode.I.2", "exactfit"),
                ),
                "size" => 1,    
                "maxitems" => 1,
            )
        ),
        "align" => Array (        
            "exclude" => 1,        
            "label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.align",        
            "config" => Array (
                "type" => "select",
                "items" => Array (
                    Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.align.I.0", "TL"),
                    Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.align.I.1", "T"),
                    Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.align.I.2", "TR"),
                    Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.align.I.3", "L"),
                    Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.align.I.4", "R"),
                    Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.align.I.5", "BL"),
                    Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.align.I.6", "B"),
                    Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.align.I.7", "BR"),
                ),
                "size" => 1,    
                "maxitems" => 1,
            )
        ),
        "windowmode" => Array (        
            "exclude" => 1,        
            "label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.windowmode",        
            "config" => Array (
                "type" => "select",
                "items" => Array (
                    Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.windowmode.I.0", "0"),
                    Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.windowmode.I.1", "opaque"),
                    Array("LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.windowmode.I.2", "transparent"),
                ),
                "size" => 1,    
                "maxitems" => 1,
            )
        ),
		"fullscreen" => Array (		
			"exclude" => 1,		
			"label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_template.fullscreen",		
			"config" => Array (
				"type" => "check",
				"default" => 1,
			)
		),

	),
	"types" => Array (
		"0" => Array("showitem" => "hidden;;1;;1-1-1, name, width, height, version,asversion, menu, bgcolour, movieid, historyframe, file, css, title;;;;2-2-2, metakeyword;;;;3-3-3, metadesc, searchengine, redirectpage, conf, language_file,preloader,dynamic_fonts, fonts,swfs, hosturl, relaysocket, relayport, relayserver, codepage, scalemode, align, windowmode,fullscreen")
	),
	"palettes" => Array (
		"1" => Array("showitem" => "starttime, endtime, fe_group")
	)
);



$TCA["tx_typoflash_component"] = Array (
	"ctrl" => $TCA["tx_typoflash_component"]["ctrl"],
	"interface" => Array (
		"showRecordFieldList" => "hidden,starttime,endtime,fe_group,name,prop_x,prop_y,prop_alpha,file,path,initobj"
	),
	"feInterface" => $TCA["tx_typoflash_component"]["feInterface"],
	"columns" => Array (
		"hidden" => Array (		
			"exclude" => 1,	
			"label" => "LLL:EXT:lang/locallang_general.php:LGL.hidden",
			"config" => Array (
				"type" => "check",
				"default" => "0"
			)
		),
		"starttime" => Array (		
			"exclude" => 1,	
			"label" => "LLL:EXT:lang/locallang_general.php:LGL.starttime",
			"config" => Array (
				"type" => "input",
				"size" => "8",
				"max" => "20",
				"eval" => "date",
				"default" => "0",
				"checkbox" => "0"
			)
		),
		"endtime" => Array (		
			"exclude" => 1,	
			"label" => "LLL:EXT:lang/locallang_general.php:LGL.endtime",
			"config" => Array (
				"type" => "input",
				"size" => "8",
				"max" => "20",
				"eval" => "date",
				"checkbox" => "0",
				"default" => "0",
				"range" => Array (
					"upper" => mktime(0,0,0,12,31,2020),
					"lower" => mktime(0,0,0,date("m")-1,date("d"),date("Y"))
				)
			)
		),
		"fe_group" => Array (		
			"exclude" => 1,	
			"label" => "LLL:EXT:lang/locallang_general.php:LGL.fe_group",
			"config" => Array (
				"type" => "select",	
				"items" => Array (
					Array("", 0),
					Array("LLL:EXT:lang/locallang_general.php:LGL.hide_at_login", -1),
					Array("LLL:EXT:lang/locallang_general.php:LGL.any_login", -2),
					Array("LLL:EXT:lang/locallang_general.php:LGL.usergroups", "--div--")
				),
				"foreign_table" => "fe_groups"
			)
		),
		"name" => Array (		
			"exclude" => 1,		
			"label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_component.name",		
			"config" => Array (
				"type" => "input",	
				"size" => "30",
			)
		),
		"prop_x" => Array (		
			"exclude" => 1,		
			"label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_component.prop_x",		
			"config" => Array (
				"type" => "input",	
				"size" => "30",
			)
		),
		"prop_y" => Array (		
			"exclude" => 1,		
			"label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_component.prop_y",		
			"config" => Array (
				"type" => "input",	
				"size" => "30",
			)
		),
		"prop_alpha" => Array (		
			"exclude" => 1,		
			"label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_component.prop_alpha",		
			"config" => Array (
				"type" => "input",	
				"size" => "30",
			)
		),
		"file" => Array (		
			"exclude" => 1,		
			"label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_component.file",		
			"config" => Array (
				"type" => "group",
				"internal_type" => "file",
				"allowed" => "",	
				"disallowed" => "php,php3",	
				"max_size" => 1000,	
				"uploadfolder" => "uploads/tx_typoflash",
				"size" => 1,	
				"minitems" => 0,
				"maxitems" => 1,
			)
		),
		"path" => Array (		
			"exclude" => 1,		
			"label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_component.path",		
			"config" => Array (
				"type" => "input",	
				"size" => "30",
			)
		),
		"initobj" => Array (		
			"exclude" => 1,		
			"label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_component.initobj",		
			"config" => Array (
				"type" => "text",
				"cols" => "30",	
				"rows" => "5",
			)
		),
	),
	"types" => Array (
		"0" => Array("showitem" => "hidden;;1;;1-1-1, name, prop_x, prop_y, prop_alpha, file, path, initobj")
	),
	"palettes" => Array (
		"1" => Array("showitem" => "starttime, endtime, fe_group")
	)
);



$TCA["tx_typoflash_content"] = Array (
    "ctrl" => $TCA["tx_typoflash_content"]["ctrl"],
    "interface" => Array (
        "showRecordFieldList" => "sys_language_uid,l18n_parent,l18n_diffsource,hidden,starttime,endtime,fe_group,name,component,records,storage_page,media,conf,xml_conf,title,body_text"
    ),
    "feInterface" => $TCA["tx_typoflash_content"]["feInterface"],
    "columns" => Array (
		'sys_language_uid' => array (		
			'exclude' => 1,
			'label' => 'LLL:EXT:lang/locallang_general.xml:LGL.language',
			'config' => array (
				'type' => 'select',
				'foreign_table' => 'sys_language',
				'foreign_table_where' => 'ORDER BY sys_language.title',
				'items' => array(
					array('LLL:EXT:lang/locallang_general.xml:LGL.allLanguages',-1),
					array('LLL:EXT:lang/locallang_general.xml:LGL.default_value',0)
				)
			)
		),
		'l18n_parent' => Array (		
			'displayCond' => 'FIELD:sys_language_uid:>:0',
			'exclude' => 1,
			'label' => 'LLL:EXT:lang/locallang_general.xml:LGL.l18n_parent',
			'config' => Array (
				'type' => 'select',
				'items' => Array (
					Array('', 0),
				),
				'foreign_table' => 'tx_typoflash_content',
				'foreign_table_where' => 'AND tx_typoflash_content.pid=###CURRENT_PID### AND tx_typoflash_content.sys_language_uid IN (-1,0)',
			)
		),
		'l18n_diffsource' => Array (		
			'config' => Array (
				'type' => 'passthrough'
			)
		),
        "hidden" => Array (        
            "exclude" => 1,    
            "label" => "LLL:EXT:lang/locallang_general.php:LGL.hidden",
            "config" => Array (
                "type" => "check",
                "default" => "0"
            )
        ),
        "starttime" => Array (        
            "exclude" => 1,    
            "label" => "LLL:EXT:lang/locallang_general.php:LGL.starttime",
            "config" => Array (
                "type" => "input",
                "size" => "8",
                "max" => "20",
                "eval" => "date",
                "default" => "0",
                "checkbox" => "0"
            )
        ),
        "endtime" => Array (        
            "exclude" => 1,    
            "label" => "LLL:EXT:lang/locallang_general.php:LGL.endtime",
            "config" => Array (
                "type" => "input",
                "size" => "8",
                "max" => "20",
                "eval" => "date",
                "checkbox" => "0",
                "default" => "0",
                "range" => Array (
                    "upper" => mktime(0,0,0,12,31,2020),
                    "lower" => mktime(0,0,0,date("m")-1,date("d"),date("Y"))
                )
            )
        ),
        "fe_group" => Array (        
            "exclude" => 1,    
            "label" => "LLL:EXT:lang/locallang_general.php:LGL.fe_group",
            "config" => Array (
                "type" => "select",    
                "items" => Array (
                    Array("", 0),
                    Array("LLL:EXT:lang/locallang_general.php:LGL.hide_at_login", -1),
                    Array("LLL:EXT:lang/locallang_general.php:LGL.any_login", -2),
                    Array("LLL:EXT:lang/locallang_general.php:LGL.usergroups", "--div--")
                ),
                "foreign_table" => "fe_groups"
            )
        ),
        "name" => Array (        
            "exclude" => 1,        
            "label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_content.name",        
            "config" => Array (
                "type" => "input",    
                "size" => "30",    
                "eval" => "required",
            )
        ),
        "component" => Array (        
            "exclude" => 1,        
            "label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_content.component",        
            "config" => Array (
                "type" => "select",    
                "foreign_table" => "tx_typoflash_component",    
                "foreign_table_where" => "ORDER BY tx_typoflash_component.uid",    
                "size" => 1,    
                "minitems" => 0,
                "maxitems" => 1,
            )
        ),
        "target" => Array (        
            "exclude" => 1,        
            "label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_component.target",        
            "config" => Array (
                "type" => "input",    
                "size" => "30",
            )
        ),
        "records" => Array (        
            "exclude" => 1,        
            "label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_content.records",        
            "config" => Array (
                "type" => "group",    
                "internal_type" => "db",    
                "allowed" => "*",    
                "prepend_tname" => 1,    
                "size" => 5,    
                "minitems" => 0,
                "maxitems" => 50,
            )
        ),
        "storage_page" => Array (        
            "exclude" => 1,        
            "label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_content.storage_page",        
            "config" => Array (
                "type" => "group",    
                "internal_type" => "db",    
                "allowed" => "pages",    
                "size" => 1,    
                "minitems" => 0,
                "maxitems" => 1,
            )
        ),
        "media" => Array (        
            "exclude" => 1,        
            "label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_content.media",     
			"config" => Array (
                "type" => "group",    
                "internal_type" => "db",    
                "allowed" => "tx_dam",    
                "size" => 5,    
                "minitems" => 0,
                "maxitems" => 50,
            )
          /*  "config" => Array (
                "type" => "group",
                "internal_type" => "file",
                "allowed" => "",    
                "disallowed" => "php,php3",    
                "max_size" => 500,    
                "uploadfolder" => "uploads/tx_typoflash",
                "show_thumbs" => 1,    
                "size" => 5,    
                "minitems" => 0,
                "maxitems" => 50,
            )*/
        ),
        "media_category" => Array (        
            "exclude" => 1,        
            "label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_content.media_category",        
            "config" => Array (
                "type" => "group",    
                "internal_type" => "db",    
                "allowed" => "*",    
                "size" => 5,    
                "minitems" => 0,
                "maxitems" => 50,
            )
        ),
        "conf" => Array (        
            "exclude" => 1,        
            "label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_content.conf",        
            "config" => Array (
                "type" => "text",
                "cols" => "30",    
                "rows" => "5",
            )
        ),
        "xml_conf" => Array (        
            "exclude" => 1,        
            "label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_content.xml_conf",        
            "config" => Array (
                "type" => "group",
                "internal_type" => "file",
                "allowed" => "",    
                "disallowed" => "php,php3",    
                "max_size" => 500,    
                "uploadfolder" => "uploads/tx_typoflash",
                "size" => 1,    
                "minitems" => 0,
                "maxitems" => 1,
            )
        ),
        "title" => Array (        
            "exclude" => 1,        
            "label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_content.title",        
            "config" => Array (
                "type" => "input",    
                "size" => "30",
            )
        ),
        "body_text" => Array (        
            "exclude" => 1,        
            "label" => "LLL:EXT:typoflash/locallang_db.php:tx_typoflash_content.body_text",        
            "config" => Array (
                "type" => "text",
                "cols" => "30",    
                "rows" => "5",
            )
        ),
    ),
    "types" => Array (
        "0" => Array("showitem" => "hidden, name, component, target, records, storage_page, media, media_category, conf, xml_conf, title, body_text")
    ),
    "palettes" => Array (
        "1" => Array("showitem" => "starttime, endtime, fe_group")
    )
);





?>