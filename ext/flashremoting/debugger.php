<?php

/**
 * SWX Debugger
 * Author: Aral Balkan
 * Copyright (c) 2007 Aral Balkan. http://aralbalkan.com
 * 
 * Constants that define the bytecode for debug swfs.
 * (Creates a local connection to the SWX Debugger front-end.)
 *
 * http://swxformat.org
 * http://osflash.org/projects/swxformat
 */

define('DEBUG_START', '883B000700726573756C74006C63004C6F63616C436F6E6E656374696F6E00537778446562756767657200636F6E6E6563740064656275670073656E6400');	

define('DEBUG_END', '960D0008010600000000000000000802403C9609000803070100000008011C9602000804521796020008001C960500070100000042960B0008050803070300000008011C9602000806521700');

?>