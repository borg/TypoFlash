package net.typoflash.datastructures 
{
	
	/**
	 * ...
	 * @author A. Borg
	 */
	public dynamic class TFNewsCategory extends TFCategory{

		public var title_lang_ol:String;
		public var image:String;
		public var starttime:Number;
		public var description:String;
		public var single_pid:uint;
		public var parent_category:uint;
		public var shortcut_target:String;
		public var fe_group:uint;
		public var sorting:uint;
		public var tstamp:Number;
		public var crdate:Number;
		public var path:String;
		public var hidden:String;
		public var pid:uint;
		public var shortcut:String;
		public var deleted:String;
		public var endtime:Number;

		public function TFNewsCategory(o:Object) {
			super(o);
			
		}
		public function toString():String {
			return "[TFNewsCategory " + title +", uid: "+uid +", parent_category: "+ parent_category +", ITEMS: "+ITEMS.length +", SUBCATS: "+SUBCATEGORIES.length+"]";
		}	
	}
	
}