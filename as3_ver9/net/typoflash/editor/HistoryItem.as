package net.typoflash.editor 
{
	
	/**
	 * ...
	 * @author Borg
	 */
	public class HistoryItem {
		public var key:String;
		public var description:String;
		public var func:String;
		public var params:Array;
		public var index:uint;
		
		public function HistoryItem(_key:String,_desc:String,_func:String,_params:Array){
			key = _key;
			description = _desc;
			func = _func;
			params = _params;
		}
		
	}
	
}