<?php
if (!defined ("TYPO3_MODE")) 	die ("Access denied.");
t3lib_extMgm::addUserTSConfig('
	options.saveDocNew.tx_typoflash_template=1
');
t3lib_extMgm::addUserTSConfig('
	options.saveDocNew.tx_typoflash_component=1
');

  ## Extending TypoScript from static template uid=43 to set up userdefined tag:
t3lib_extMgm::addTypoScript($_EXTKEY,"editorcfg","
	tt_content.CSS_editor.ch.tx_typoflash_pi1 = < plugin.tx_typoflash_pi1.CSS_editor
",43);

t3lib_extMgm::addPItoST43($_EXTKEY,"pi1/class.tx_typoflash_pi1.php","_pi1","list_type",1);


t3lib_extMgm::addTypoScript($_EXTKEY,"setup","
	tt_content.shortcut.20.0.conf.tx_typoflash_component = < plugin.".t3lib_extMgm::getCN($_EXTKEY)."_pi1
	tt_content.shortcut.20.0.conf.tx_typoflash_component.CMD = singleView
",43);

t3lib_extMgm::addUserTSConfig('
    options.saveDocNew.tx_typoflash_content=1
');

$TYPO3_CONF_VARS['FE']['addRootLineFields'] .= ',tx_typoflash_template,tx_typoflash_conf,tx_typoflash_data';

?>