<?php
/***************************************************************
*  Copyright notice
*
*  (c) 1999-2005 Kasper Skaarhoj (kasperYYYY@typo3.com)
*  All rights reserved
*
*  This script is part of the TYPO3 project. The TYPO3 project is
*  free software; you can redistribute it and/or modify
*  it under the terms of the GNU General Public License as published by
*  the Free Software Foundation; either version 2 of the License, or
*  (at your option) any later version.
*
*  The GNU General Public License can be found at
*  http://www.gnu.org/copyleft/gpl.html.
*  A copy is found in the textfile GPL.txt and important notices to the license
*  from the author is found in LICENSE.txt distributed with these scripts.
*
*
*  This script is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*  GNU General Public License for more details.
*
*  This copyright notice MUST APPEAR in all copies of the script!
***************************************************************/
/**
 * Generates a thumbnail and returns an image stream, either GIF/PNG or JPG
 *
 * $Id: thumbs.php 1421 2006-04-10 09:27:15Z mundaun $
 *
 * @author		René Fritz <r.fritz@colorcube.de>
 */
//eg http://localhost:805/typo3conf/ext/typoflash/thumbs.php?dummy=1165955584&file=2Ffileadmin%2Ftemplates%2Fritmoflamenco.co.uk%2Fimages%2Fanglepattern.gif&size=600
//Size is one dimensional it seems
//Dummy I suppose is a noncache variable
// *******************************
// Set error reporting
// *******************************

error_reporting (E_ALL ^ E_NOTICE);


define('PATH_thisScript',str_replace('//','/', str_replace('\\','/', (php_sapi_name()=='cgi'||php_sapi_name()=='isapi' ||php_sapi_name()=='cgi-fcgi')&&($_SERVER['ORIG_PATH_TRANSLATED']?$_SERVER['ORIG_PATH_TRANSLATED']:$_SERVER['PATH_TRANSLATED'])? ($_SERVER['ORIG_PATH_TRANSLATED']?$_SERVER['ORIG_PATH_TRANSLATED']:$_SERVER['PATH_TRANSLATED']):($_SERVER['ORIG_SCRIPT_FILENAME']?$_SERVER['ORIG_SCRIPT_FILENAME']:$_SERVER['SCRIPT_FILENAME']))));
define('PATH_site', substr(dirname(PATH_thisScript).'/',0,-strlen('typo3conf/ext/typoflash/')));	// Abs. path to directory with the frontend (one above the admin-dir)
define('PATH_t3lib', PATH_site.'t3lib/');


// ******************
// include thumbs script
// ******************

require (PATH_t3lib.'thumbs.php');

?>