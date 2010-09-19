package net.typoflash.datastructures 
{
	
	/**
	 * ...
	 * @author Borg
	 */
	public class TFMenuRequest{
		public var fields:Array;
		public var menuType:String;//FEmenu/BEmenu
		public var doktype:String;
		public var media_category:String;
		public var media:String;
		public var callback:String;
		
		public var showHiddenPage:Boolean;
		public var showDeletedPage:Boolean;
		public var showTimedPage:Boolean;
		public var no_cache:Boolean;
		public var loginstatus:Boolean;
		public var returnTree:Boolean;
		
		public var menuId:String;
		public var alias:String;
		public var id:uint;
		public var L:uint;
		
		
		public function TFMenuRequest(menuid:String,pid:int=0,lang:int=0,_alias:String=''){
			id = pid;
			L = lang;
			alias = _alias;
			menuId = menuid;
			
		}
		
	}
	
}