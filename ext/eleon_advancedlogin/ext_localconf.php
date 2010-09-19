<?php
$_EXTCONF = unserialize($_EXTCONF);

$TYPO3_CONF_VARS[TYPO3_MODE]['XCLASS']['typo3/index.php'] = PATH_typo3conf."ext/eleon_advancedlogin/class.ux_SC_index.php";

if($_EXTCONF["timeout_minutes"] > 0) {
	$TYPO3_CONF_VARS['BE']['sessionTimeout'] = $_EXTCONF["timeout_minutes"] * 60;
}
else {
	$TYPO3_CONF_VARS['BE']['sessionTimeout'] = 3600;
}

?>