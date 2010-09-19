package net.typoflash.datastructures 
{
	
	/**
	 * ...
	 * @author A. Borg
	 */
	public dynamic class TFCategory{
		public var uid:uint;
		public var title:String;				
		public var SUBCATEGORIES:Array;
		public var ITEMS:Array;
		
		public function TFCategory(o:Object) {
			for (var n in o) {
				this[n]  = o[n];
			}
		}
		
	}
	
}