<?php	
	class TestTO
	{
		var $prop1 = "A string";
		var $prop2 = 42;
	}
		
	/**
	 * Data type test service. Run the TestDataTypes.fla to run through all these tests using SWX RPC. 
	 *
	 * @package default
	 * @author Aral Balkan
	 **/
	class TestDataTypes
	{
		
		/**
		 * Returns the boolean true.
		 * @author Aral Balkan
		 **/
		function testTrue()
		{
			return true; 
		}
		
		/**
		 * Returns the boolean false.
		 * @author Aral Balkan
		 **/
		function testFalse()
		{
			return false;
		}
		
		/**
		 * Returns the array ['It', 'works']
		 * @author Aral Balkan
		 **/
		function testArray()
		{
			return array('It', 'works');
		}
		
		/**
		 * Returns the nested array ['It', ['also'], 'works]
		 * @author Aral Balkan
		 **/
		function testNestedArray()
		{
			return array('It', array('also'), 'works');
		}
		
		/**
		 * Returns the integer 42.
		 * @author Aral Balkan
		 **/
		function testInteger()
		{
			return 42;
		}
		
		/**
		 * Returns the float 42.12345.
		 * @author Aral Balkan
		 **/
		function testFloat()
		{
			return 42.12345;
		}
		
		/**
		 * Returns the string "It works!"
		 * @author Aral Balkan
		 **/
		function testString()
		{
			return "It works!";
		}
		
		/**
		 * Returns the associative array ['it' => 'works', 'number' => 42]
		 * @author Aral Balkan
		 **/
		function testAssociativeArray()
		{
			return array('it' => 'works', 'number' => 42);
		}

		/**
		 * Returns an instance of the TestTO class with properties prop1: "A string" and prop2: 42.
		 * @author Aral Balkan
		 **/
		function testObject()
		{
			return new TestTO();
		}
		
		/**
		 * Returns null.
		 * @author Aral Balkan
		 **/
		function testNull()
		{
			return NULL;
		}
	}


?>