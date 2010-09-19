package net.typoflash.datastructures 
{
	
	/**
	 * ...
	 * @author Borg
	 */
	public class TFHeader {
		public var url:String;
		public var description:String;
		public var media:String;
		public var subtitle:String;
		public var pid:uint;
		public var uid:uint;
		public var shortcut_mode:uint;
		public var sys_language_uid:uint;
		public var abstract:String;
		public var target:uint;
		public var storage_pid:uint;
		public var alias:String;
		public var author:String;
		public var nav_title:String;
		public var title:String;
		public var doktype:uint;
		public var shortcut:uint;
		
		
		public function TFHeader(o:Object) {
			for (var n in o) {
				this[n] = o[n];
			}
			
		}
		
	}
	
}