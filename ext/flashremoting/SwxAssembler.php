<?php

/**
 * SWX Assember class. 
 * 
 * Creates SWX SWF files.
 * Released under the GNU GPL license.
 * 
 * Author: Aral Balkan
 * Copyright (c) 2007 Aral Balkan.
 * http://aralbalkan.com
 * 
 * http://swxformat.org
 */






	/*
	Borg mod
	21/03/2008
	
	Casting of objects and associative arrays is a tricky thing, cause AMF and SWX behaves differently.


	AMF	
	send from flash		php gets	send from php	flash gets		
	obj					ass arr		ass arr			obj
									num arr			num arr
									obj				obj



	SWX
	send from flash		php gets	send from php	flash gets
	obj					obj			ass arr			num arr
	arr					num arr		obj				obj
									num arr			ass arr with numeric indices


c.args = [[0,1,2,3,4,5,6]]
return 
{0: 0, 1: 1, 2: 2, 3: 3, 4: 4, 5: 5, 6: 6}
It traces length, and accepts both for loops and for in loops, but it says its not an instanceof Array.
I think that might be due to bytecode not packaging it like a normal Array instance, which might confuse the trace (objectDumper).
That is a guess.

I think it appears the same when it is a php associative array, but you can't do the length etc. It traces the same with objectDumper that is.

	*/










// PHP 5 compatibility layer for PHP 4
require_once('lib/str_split.php');

// Constants
define ('LITTLE_ENDIAN', 'little-endian');
define ('BIG_ENDIAN', 'big-endian');
define ('BI_ENDIAN', 'bi-endian');

class SwxAssembler
{
	var $stack = '';
	var $endian = NULL;

	function SwxAssembler()
	{
		global $endian;
		
		// Determine endianness of the system that this is running under
		// Adapted from: http://phpfer.com/rn45re877.html
		$ab = 0x6162;

	 	// Convert $ab to a binary string containing 32 bits
		// Do the conversion the way that the system architecture wants to
		switch (pack ('L', $ab))
		{
		    // Compare the value to the same value converted in a Little-Endian fashion
		    case pack ('V', $ab):
		        $endian = LITTLE_ENDIAN;
		        break;

		    // Compare the value to the same value converted in a Big-Endian fashion
			// TODO: Test on a big-endian machine. Currently SWX is not supported on 
			// big endian machines.
		    case pack ('V', $ab):
		        $endian = BIG_ENDIAN;
		        break;

			// Bi-endian or middle endian. The biggest use case for this is 
			// PowerPC architectures. In fact, take this to mean PowerPC support.
		    default:
		        $endian = BI_ENDIAN;
		}
		
		if (LOG_ALL) error_log ('[SWX] INFO Running on a '.$endian.' system.');
	}

	// From http://de.php.net/var_dump
	function getVarDump($mixed = null) 
	{
	  ob_start();
	  var_dump($mixed);
	  $content = ob_get_contents();
	  ob_end_clean();
	  return $content;
	}

	/**
	 * Converts the passed object to arrays.
	 *
	 * @return void
	 * @author Aral Balkan
	 **/
	function objectToArray($data='') 
	{
		$arr = array();
		foreach ($data as $key => $value )
		{
			if (gettype($value) == 'object')
			{
				$arr[$key] = $this->objectToArray($value);
			}
			else
			{
				$arr[$key] = $value;
			}
		}
		return $arr;
	}

	/**
	 * Parses the given data structure (any type) and 
	 * returns SWF bytecode.
	 *
	 * @param	any		A PHP data structure	
	 * @return 	string	Swf bytecode representation of the data structure.
	 * @author Aral Balkan
	 **/
	function dataToBytecode ($data)
	{
		$type = gettype($data);
		
		switch($type)
		{
			case 'array':
				$bytecode = $this->arrayToBytecode($data);
				break;
			
			case 'object':
				// TODO: Handle objects natively without
				//       converting to an associative array.
				
				// Convert object to array
				$data = $this->objectToArray($data);
				
				// And then use the array encoder
				$bytecode = $this->arrayToBytecode($data);
				break;

			case 'string':
				$bytecode = $this->stringToBytecode($data);
				break;				
								
			case 'integer':
				$bytecode = $this->integerToBytecode($data);
				break;
				
			case 'double':
				$bytecode = $this->doubleToBytecode($data);
				break;

			case 'boolean':
				$bytecode = $this->booleanToBytecode($data);
				break;
				
			case 'NULL':
				$bytecode = DATA_TYPE_NULL;
				break;
						
			default:
				trigger_error('Unhandled data type ('.$type.')', E_USER_ERROR);
				//error_log('[SWX] ERROR dataToBytecode() Unhandled data type: ' . $type);
				//$bytecode = "ERROR";
		}
		
		return $bytecode;
	}
	
	
	/**
	 * Converts the passed array to SWF bytecode.
	 *
	 * @return string SWF bytecode.
	 * @author Aral Balkan
	 **/
	function arrayToBytecode($arr)
	{
		// Note: We are going to write the bytecode backwards,
		// starting from the end as it's easier that way. 
		
		//$bytecode = '';
		
		// To count number of elements in the array
		$arrCount = count($arr);

		$bytecode = $this->integerToBytecode($arrCount);// . $bytecode;
		
		// Determine array type
		$keys = array_keys($arr);
		
		if ($arrCount == 0 || $this->keyAreIntegers($keys))
		{
			// Reverse the array to mirror how they're stored in a SWF (this
			// won't affect associative arrays (objects in Flash) but it will
			// make regular arrays appear in the right order.
			// $arr = array_reverse($arr);
			$arrayType = ARRAY_TYPE_REGULAR;
			$bytecode .= ACTION_INIT_ARRAY; // . $bytecode;
		}
		else
		{
			$arrayType = ARRAY_TYPE_ASSOCIATIVE;
			$bytecode .= ACTION_INIT_OBJECT; // . $bytecode;
		}
	
		// Add the number of elements
		//
		// Optimized: 
		// DATA_TYPE_INTEGER . strtoupper(str_pad($this->makeLittleEndian(dechex($arrCount)), 8, '0')) . $bytecode;
		//
		// Clear: 
		// $this->integerToBytecode($arrCount) . $bytecode;
		//
		//$bytecode = $this->integerToBytecode($arrCount) . $bytecode;
		
		// Profiling: 
		//$forLoopStartTime = $this->microtime_float();
		
		foreach ($arr as $key => $value)
		{
			// Check if the current bytecode length is approaching
			// the 64K (65535 byte) limit that we can store in a single push
			// and, if so, create a new push.
			
			// TODO: Refactor - pull out
			$bytecodeLenInDec = strlen($bytecode)/2;
			if ($bytecodeLenInDec >= 65520) // For testing use >= 2)
			{
				// Calculate bytecode length *without* counting the 
				// init object or init array action
				$lastInstruction = substr($bytecode, -2);
				if ( $lastInstruction == ACTION_INIT_OBJECT || $lastInstruction == ACTION_INIT_ARRAY)
				{
					//error_log('(at end) IS COMPLEX - '.$lastInstruction);
					$bytecodeLenInDec -= 1;					
				}				

				// TODO: Refactor - pull out
				$bytecodeLenInHex = $this->getIntAsHex($bytecodeLenInDec, 2);
								
				$bytecode = $bytecodeLenInHex . $bytecode;
				$bytecode = '96' . $bytecode;	// Push. TODO: Replace w. constant
				
				// Store current instruction on the stack
				$this->stack = $bytecode . $this->stack;
				
				// Reset the bytecode
				$bytecode = '';		
			}
			
			// Convert objects to arrays.
			// TODO: Handle objects natively.
			if (gettype($value) == 'object')
			{
				$value = $this->objectToArray($value);
			}
			
			// Is this a simple data type or an array?
			if (gettype($value) == 'array')
			{
				// Element is an array, we need to *push* it on to
				// the stack separately. End the current push.
				// (Note: this produces bytecode that differs from
				// what the Adobe compiler in Flash produces but
				// it's easier.)
				
				$bytecodeLenInDec = strlen($bytecode)/2;
								
				// Calculate bytecode length *without* counting the 
				// init object or init array action
				$lastInstruction = substr($bytecode, -2);
				
				if ( $lastInstruction == ACTION_INIT_OBJECT || $lastInstruction == ACTION_INIT_ARRAY)
				{
					//error_log('IS COMPLEX - '.$lastInstruction);
					$bytecodeLenInDec -= 1;					
				}

				// If we haven't written any bytecode into the local
				// buffer yet (if it's empty), don't write a push statement. 
				if ($bytecodeLenInDec != -1 && $bytecodeLenInDec != 0)
				{
					// TODO: Refactor - pull out
					$bytecodeLenInHex = $this->getIntAsHex($bytecodeLenInDec, 2);
					$bytecode = $bytecodeLenInHex . $bytecode;
					$bytecode = '96' . $bytecode;	// Push. TODO: Replace w. constant
				}
				
				// Store current instruction on the stack
				$this->stack = $bytecode . $this->stack;
				
				// Reset the bytecode
				$bytecode = '';
				
				// Add the found array to the stack
				$this->arrayToBytecode($value);
				
				// If this is an element from an associative array, push the
				// key before you recurse:
				if ($arrayType == ARRAY_TYPE_ASSOCIATIVE)
				{
					$bytecode = $this->dataToBytecode($key) . $bytecode;
				}
				
			}
			else
			{
				// Simple data type

				// What type of array are we?
				if ($arrayType == ARRAY_TYPE_REGULAR)
				{
					// Regular
					$bytecode = $this->dataToBytecode($value).$bytecode;
				}
				else
				{
					// Associative (in Flash: object)
					$bytecode = $this->dataToBytecode($key)
								.$this->dataToBytecode($value) 
								.$bytecode;					
				}
			}
		}
		
		// Profiling:
		// error_log("For loop took" . (microtime_float()-$forLoopStartTime));
		
		
		if ($bytecode != '')
		{
			$bytecodeLenInDec = strlen($bytecode)/2;

			// TODO: Refactor - Pull out 

			// Calculate bytecode length *without* counting the 
			// init object or init array action
			$lastInstruction = substr($bytecode, -2);
			if ( $lastInstruction == ACTION_INIT_OBJECT || $lastInstruction == ACTION_INIT_ARRAY)
			{
				//error_log('(at end) IS COMPLEX - '.$lastInstruction);
				$bytecodeLenInDec -= 1;					
			}
			
			// TODO: Refactor - pull this out into its own method now that
			// it is being used at the start of the loop also.
			$bytecodeLenInHex = $this->getIntAsHex($bytecodeLenInDec, 2);
			$bytecode = $bytecodeLenInHex . $bytecode;
			$bytecode = '96' . $bytecode;	// Push. TODO: Replace w. constant
		
			// Store current instruction on the stack
			$this->stack = $bytecode . $this->stack;		
		}
		else
		{
			//error_log('Bytecode is empty, skipping...');
		}
		
		//error_log('Returning stack: ' . $this->stack);
		
		return $this->stack;
	}
	
	function keyAreIntegers($keys){
		if(!is_array($keys)){
			return false;
		}

		foreach($keys as $k=>$v){
			if(gettype($keys[$v]) != 'integer'){
				return false;
			}
		}

		return true;
	
	}

	/**
	 * Converts the passed string to hex and returns the correct SWF bytecode for it.
	 *
	 * @param 	string	The string to convert to bytecode.
	 * @return 	string	SWF bytecode for the passed string
	 * @author Aral Balkan
	 **/
	function stringToBytecode ($str)
	{
		$bytecode = strtoupper(DATA_TYPE_STRING . $this->strhex($str) . NULL_TERMINATOR);
		
		return $bytecode;
	}


	/**
	 * Converts the passed integer to bytecode, padding it to 
	 * $numBytes bytes in little-endian.
	 *
	 * @param integer 	Number to convert to hex byte representation.
	 * @param integer	Number of bytes to pad to.	
	 * @return string 	Integer as hex string.
	 * @author Aral Balkan
	 **/
	function integerToBytecode($int)
	{
		$bytecode = DATA_TYPE_INTEGER . $this->getIntAsHex($int, 4);
		return $bytecode;
	}


	/**
	 * Converts a double to its IEEE 754 representation (little-endian)
	 * 
	 * Modified from Chung Leong's function.
	 * (http://www.thescripts.com/forum/thread9237.html.)
	 * 
	 * TODO: Works on 5.1.2 for me (OS X 10.4.9, Intel Core Duo, MAMP 1.2.1) but
	 * waiting for report back from Alex Skinner for whom it is not working. Weird!
	 *
	 * @param 	double	A PHP double.
	 * @return 	string	Little-endian Flash double in hex (variation on IEEE 754).
	 * @author Aral Balkan
	 **/
	function doubleToBytecode($f) 
	{
		global $endian;
		
		$f = (double) $f;
		$b = pack("d", $f);
		$hex = "";
		
		// This test is here for PowerPC Macs which are bi-endian.
		if ($endian == BI_ENDIAN)
		{
			$b = strrev($b);
		}
			
		for($i = 0; $i < strlen($b); $i++) 
		{
			$c = ord($b{$i});
			
			$hex .= sprintf("%02X", $c);			
		} 
				
		$hex = substr($hex, 8, 8).substr($hex, 0, 8);
		
		return DATA_TYPE_DOUBLE . $hex;
	}


	/**
	 * Converts the passed boolean to SWF bytecode.
	 *
	 * @return string	Boolean as SWF bytecode.
	 * @author Aral Balkan
	 **/
	function booleanToBytecode ($bool)
	{
		$boolBytecode = DATA_TYPE_BOOLEAN . ($bool ? '01':'00');
		return $boolBytecode;
	}


	/**
	 * Wraps the SWF buffer in a doAction block, wraps that with 
	 * the SWF Header and the SWF footer (set variable, show frame, end SWF)
	 * and writes out the SWF.
	 *
	 *	@param 	Data to write out as a SWF.
	 *  @return void
	 * @author Aral Balkan
	 **/
	function writeSwf($data, $debug = false, $compressionLevel = 4, $url = '')
	{
		global $allowDomain;
			
		$pushTag = $this->datatoBytecode($data);
				
		if (gettype($data) != 'array' && gettype($data) != 'object')
		{
			// Not an array, add the push code and length:
			$bytecodeLenInDec = strlen($pushTag)/2;
			$bytecodeLenInHex = $this->getIntAsHex($bytecodeLenInDec, 2);
							
			$pushTag = '96' . $bytecodeLenInHex . $pushTag;				
		}
		
		// error_log("type of data: ".gettype($data));
		// error_log("pushTag: $pushTag");

		// Add the 'result' variable name -- either
		// using the constant table if in debug mode
		// or as a regular string otherwise
		if ($debug)
		{
			$pushTag = '9602000800' . $pushTag;
		}
		else
		{
			$pushTag = '96080000726573756C7400' . $pushTag;
		}

		// Create the DoAction tag
		$doActionBlock = $pushTag;
		
		$doActionBlock .= ACTION_SET_VARIABLE;
		
		// Allow domain? If so add allow domain statement to the SWF
		if ($allowDomain === true)
		{
			if (LOG_ALL) error_log("[SWX] INFO Allow domain is on.");

			$doActionBlock = $doActionBlock . $this->getAllowDomainBytecode($url); // ALLOW_DOMAIN;
		}

		// Debug? If so, add the analyzer connector to the SWF
		if ($debug)
		{
			if (LOG_ALL) error_log('[SWX] INFO Debug mode is on.');

			$doActionBlock = DEBUG_START . $doActionBlock . DEBUG_END;
		}
				
		$doActionBlockSizeInBytes = $this->getStringLengthInBytesHex($doActionBlock, 4);
		$doActionBlock = ACTION_DO_ACTION . $doActionBlockSizeInBytes . $doActionBlock;

		// Create the whole SWF
		
		$headerType = ($compressionLevel > 0) ? COMPRESSED_SWF : UNCOMPRESSED_SWF;
		
		$swf =  $headerType . HEADER . $doActionBlock . ACTION_SHOW_FRAME . ACTION_END_SWF;
		$swfSizeInBytes = $this->getStringLengthInBytesHex($swf, 4);
		$swf = str_replace('LLLLLLLL', $swfSizeInBytes, $swf);

		// Convert the SWF bytecode to a string (file)
		$swfFile = $this->hexstr ($swf);
		
		// Stats
		$uncompressedSize = strlen($swfFile);
		if (LOG_ALL) error_log('[SWX] INFO Uncompressed size of SWF: ' . $uncompressedSize . ' bytes.');
		
		// Compress the SWF if required
		// Profiling info: Performance impact of compression is negligible. 
		if ($compressionLevel > 0)
		{
			$compressionStartTime = $this->microtime_float();
			
			// The first eight bytes are uncompressed
			$uncompressedBytes = substr($swfFile, 0, 8);
			
			// Remove first eight bytes
			$swfFile = substr_replace($swfFile, '', 0, 8);
			
			// Compress the rest of the SWF
			$swfFile = gzcompress($swfFile, $compressionLevel);
			
			// Add the uncompressed header
			$swfFile = $uncompressedBytes . $swfFile;
			
			$compressionDuration = $this->microtime_float() - $compressionStartTime;
			if (LOG_ALL) error_log('[SWX] PROFILING: SWF compression took ' . $compressionDuration . ' seconds.'); 
			
			// Stats
			$compressedSize = strlen($swfFile);
			if (LOG_ALL) error_log('[SWX] INFO Compressed size of SWF: ' . $compressedSize . ' bytes.'); 
		}
		
		header("Content-Type: application/swf;");
		header('Content-Disposition: attachment; filename="data.swf"');
		header('Content-Length: ' . strlen($swfFile));
		echo $swfFile;

		// Enable the next line to write out a hex representation of
		// the SWF to the error log (helps with testing.)
		// error_log($this->prettyHex($swf));
	}
	
	function getAllowDomainBytecode($url)
	{
		if ($url === '')
		{
			// No URL passed -- possibly called by legacy code, use the old _parent._url version.
			if (LOG_ALL) error_log('[SWX] INFO: No URL passed from client. Defaulting to old behavior. You must call System.security.allowDomain on the dataHolder for cross domain data loading to work.');
			return ALLOW_DOMAIN;
		}
		
		if (LOG_ALL) error_log('[SWX] INFO: Data SWF will allow access from ' . $url);
		
		// URL is passed, write that into the returned code
		
		$allowDomainBytecode = $this->stringToBytecode($url); 
		
		// The -13 is to accomodate the other elements being pushed to the 
		// stack in the hard-coded part of the bytecode.
		$allowDomainBytecodeLengthDec = strlen($allowDomainBytecode)/2 + 13;
		
		$allowDomainBytecodeLength = $this->getIntAsHex($allowDomainBytecodeLengthDec, 2);
		$allowDomainBytecode = '96' . $allowDomainBytecodeLength . $allowDomainBytecode . SYSTEM_ALLOW_DOMAIN;
				
		return $allowDomainBytecode;
	}
	

	/**
	 * 	Helper methods. (For data type conversions, formatting, etc.)
	 */
	
	// Returns a string with the length of the passed hex string in bytes
	// padded to display in $numBytes bytes.
	function getStringLengthInBytesHex($strInHex, $numBytes)
	{
		// Divide length in chars by 2 to get length in bytes
		$bytecodeLenInDec = strlen($strInHex)/2;
				
		$bytecodeLenInHex = $this->getIntAsHex($bytecodeLenInDec, $numBytes);
		
		return $bytecodeLenInHex;
	}

	
	/**
	 * Returns the hexadecimal representation of the passed integer,
	 * padded to $numBytes bytes in little-endian.
	 *
	 * @param integer 	Number to convert to hex byte representation.
	 * @param integer	Number of bytes to pad to.	
	 * @return string 	Integer as hex string.
	 * @author Aral Balkan
	 **/
	function getIntAsHex($int, $numBytes=1)
	{
		$intAsHex = strtoupper(str_pad($this->makeLittleEndian(dechex($int)), $numBytes*2, '0'));
		return $intAsHex;
	}

	//////////////////////////////////////////////////////////////////////
	//
	// makeLittleEndian()
	//
	// Takes a hex string in big endian and coverts it to little endian
	//
	//////////////////////////////////////////////////////////////////////
	function makeLittleEndian($str)
	{
		$sLen = strlen($str);

		// Make sure that the string is padded to the byte boundary
		if ($sLen%2 == 1) 
		{
			$sLen++;
			$str = '0'.$str;
		}
		
		$sLenInBytes = $sLen/2;
		
		$strArr = str_split($str, 2);
		
		$strArr = array_reverse($strArr);
		$strLittleEndian = implode('', $strArr);
				
		return $strLittleEndian;
	}
	
	//////////////////////////////////////////////////////////////////////
	//
	// prettyHex()
	//
	// Pretty prints hex string in 1 bytes groups, 10 to a line
	// and show number of bytes in the string.
	//
	//////////////////////////////////////////////////////////////////////
	function prettyHex ($h)
	{
		$pretty = "\n\n      01 02 03 04 05 06 07 08 09 10\n      -----------------------------\n0001| ";
		$hArr = str_split($h, 2);

		$lineCount = 1;

		for ($i = 0; $i < count($hArr); $i++)
		{
			$pretty .= $hArr[$i] . ' ';
			if (($i+1)%10 == 0  )
			{
				$lineCount++;
				$pretty .= "\n".str_pad($lineCount, 4, "0", STR_PAD_LEFT).'| ';				
			}
		}
		$pretty .= "\n\n$h\n\nNum bytes: ".count($hArr)."\n";
				
		return $pretty;		
	}

	//////////////////////////////////////////////////////////////////////
	//
	// debug()
	//
	// Debug only displays debug messages if we
	// are not writing out a SWF.
	//
	//////////////////////////////////////////////////////////////////////
	function debug($str)
	{
		global $isPost;
		if ($isPost || isset($_GET['swf']))
		{
			return;
		}
		else
		{
			echo $str;
		}
	}


	/**
	 * Converts a string of hexadecimal values to a string of ASCII characters.
	 *
	 * @return string String with ASCII characters
	 * @author Paul Gregg <pgregg@pgregg.com>
	 * @link http://www.pgregg.com/projects/php/code/hexstr.phps
	 **/
	function hexstr($hexstr) 
	{
		$hexstr = str_replace(' ', '', $hexstr);
		$retstr = pack('H*', $hexstr);
		return $retstr;
	}


	/**
	 * Converts a string of ASCII characters to a string of hexadecimal byte values.
	 *
	 * @return string String with ASCII characters
	 * @author Paul Gregg <pgregg@pgregg.com>
	 * @author Aral Balkan (added PHP4 bug fix)
	 * @link http://www.pgregg.com/projects/php/code/hexstr.phps
	 **/
	function strhex($string) 
	{
		$hexstr = unpack('H*', $string);
		
		// Fix for unpack bug 
		// http://bugs.php.net/bug.php?id=36148
		// PHP 4 and 5 appear to give different results for the unpack
		// PHP 4.4.3+ exhibits same behavior as PHP 5.
		// PHP version 5.1.2 exhibits the same behavior as PHP 4.
		// Tested with: 4.4.2, 4.4.3, 4.4.4, 5.1.4, 5.1.6, 5.2.1.
		// Definitely *not* supported on 4.3.10 (or the 4.3 branch at all.)
		//
		// TODO: Look for a way to optimize this.
		
		$phpVer = phpversion(); 
		
		if ( (substr($phpVer,0,1) == '4' && intval(substr($phpVer,4, 1)) < 3)  || $phpVer == '5.1.2')
		{
			// PHP 4
			return substr($hexstr[1], 0, -1);
		}
		else
		{
			// PHP 4.4.3+ and 5.1.4+
	  		return array_shift($hexstr);
		}
	}
	
	// Profiling
	function microtime_float()
	{
	    list($usec, $sec) = explode(" ", microtime());
	    return ((float)$usec + (float)$sec);
	}
	
	
}

//
// SWF bytecode constants. Discovered through observation.
// 

// Header - FCS (uncompressed), version Flash 6
define('UNCOMPRESSED_SWF', '46');
define('COMPRESSED_SWF', '43');
define('HEADER', '575306LLLLLLLL300A00A0000101004302FFFFFF');

// Action bytecodes
define('ACTION_PUSH', '96LLLL');
define('ACTION_SHOW_FRAME', '4000');
define('ACTION_END_SWF', '0000');
define('ACTION_SET_VARIABLE', '1D');  // 00
define('ACTION_DO_ACTION', '3F03');
define('ACTION_INIT_ARRAY', '42');
define('ACTION_INIT_OBJECT', '43');

// Data type codes
define('DATA_TYPE_STRING',  '00');
define('DATA_TYPE_NULL',  '02');
define('DATA_TYPE_BOOLEAN', '05');
define('DATA_TYPE_DOUBLE', '06');
define('DATA_TYPE_INTEGER', '07');

// Misc
define('NULL_TERMINATOR', '00');

// Non-bytecode constants
define('ARRAY_TYPE_REGULAR', 'regular');
define('ARRAY_TYPE_ASSOCIATIVE', 'associative');

// Allow domain (*)
define('ALLOW_DOMAIN', '960900005F706172656E74001C960600005F75726C004E960D0007010000000053797374656D001C960A00007365637572697479004E960D0000616C6C6F77446F6D61696E005217');

define('SYSTEM_ALLOW_DOMAIN', '07010000000053797374656D001C960A00007365637572697479004E960D0000616C6C6F77446F6D61696E005217');

// Debug SWX bytecode. Creates a local connection to the SWX Debugger front-end.)

define('DEBUG_START','883C000700726573756C74006C63004C6F63616C436F6E6E656374696F6E005F737778446562756767657200636F6E6E6563740064656275670073656E6400');

define('DEBUG_END', '960D0008010600000000000000000802403C9609000803070100000008011C9602000804521796020008001C960500070100000042960B0008050803070300000008011C96020008065217');

?>