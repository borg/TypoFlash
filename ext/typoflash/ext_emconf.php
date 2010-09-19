<?php

########################################################################
# Extension Manager/Repository config file for ext: "typoflash"
#
# Auto generated 22-07-2009 18:13
#
# Manual updates:
# Only the data in the array - anything else is removed by next write.
# "version" and "dependencies" must not be touched!
########################################################################

$EM_CONF[$_EXTKEY] = array(
	'title' => 'TypoFlash',
	'description' => 'Powers Typo3 with Flash Remoting (amf & swx), Flash CMS',
	'category' => 'module',
	'author' => 'Andreas Borg',
	'author_email' => 'borg@elevated.to',
	'shy' => '',
	'dependencies' => 'flashremoting',
	'conflicts' => '',
	'priority' => '',
	'module' => '',
	'state' => 'beta',
	'internal' => '',
	'uploadfolder' => 1,
	'createDirs' => 'uploads/tx_typoflash,typo3temp/tx_typoflash',
	'modify_tables' => '',
	'clearCacheOnLoad' => 0,
	'lockType' => '',
	'author_company' => '',
	'version' => '1.0.0',
	'constraints' => array(
		'depends' => array(
			'flashremoting' => '',
		),
		'conflicts' => array(
		),
		'suggests' => array(
		),
	),
	'_md5_values_when_last_written' => '',
	'suggests' => array(
	),
);

?>