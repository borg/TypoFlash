package net.typoflash.datastructures 
{
	
	/**
	 * ...
	 * @author A. Borg
	 */
	import net.typoflash.datastructures.TFConfig;
	
	public class TFRecordRequest {
		public var pid:uint;//unique page id in Typo3 where records are stored
		public var uid:uint;//unique id of record
		public var L:uint;//system language id
		public var table:String;//database table
		public var callback:String;//reference to the caller, is returns from php
		public var limit:String;//number of records
		public var orderBy:String;//defaults to sorting
		public var categories:String;//a comma separated list of numbers, eg. 3,45,6
		public var where:String;//where in SQL statement. Can be used to retrieve records beginning with tt or tx, but nothing else
		public var fields:Array;
		public var no_cache:Boolean=false;
		public var showTimedPage:Boolean = false;
		
		public var TF_CONF:TFConfig  = TFConfig.global;
		
		public function TFRecordRequest() {
			L = TF_CONF.LANGUAGE;
			
		}
		
	}
	
}