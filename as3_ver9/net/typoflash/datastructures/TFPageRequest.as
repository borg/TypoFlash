package net.typoflash.datastructures 
{
	
	/**
	 * ...
	 * @author Borg
	 */
	// TODO: Make real url compliant
	
	public dynamic class TFPageRequest {
		public var id:uint;//unique page id in Typo3
		public var L:uint;//system language id
		public var alias:String;//can be sent instead of id
		
		public var doktype:uint;
		public var fields:Array;
		public var getRecords:Boolean = true;
		
		public var wrap:String='';//wrap fdr links
		public var showHiddenPage:Boolean;
		public var showDeletedPage:Boolean;
		public var showTimedPage:Boolean;
		public var no_cache:Boolean;
		
		
		public function TFPageRequest(pid:uint=0,lang:uint=0,als:String=''){
			id = pid;
			L = lang;
			alias = als;
		}
		
		public function get deeplink():String {
			if (alias != '') {
				
				return '/' + alias + language
			}else {
				return '/' + id + language
			}
		}
		
		public function get language():String {
			if (L > 0) {
				return '/L/' + L;
			}else {
				return '';
			}
		}
		
		public function toString():String {
			return "[TFPageRequest id: "+ id + " L: "+ L +" alias: "+alias +"]";
		}
	}
	
}