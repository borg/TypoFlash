package net.typoflash.datastructures 
{
	
	/**
	 * ...
	 * @author A. Borg
	 */
	public dynamic class TFMediaCategory extends TFCategory	{
		public var description:String;
		public var pid:uint;
		public var cruser_id:uint;
		public var tstamp:int;
		public var keywords:String;
		public var hidden:String;
		public var image:String;
		public var fe_group:String;
		public var parent_id:String;
		public var deleted:String;
		public var sorting:String;
		public var crdate:String;
		public var l18n_parent:uint;
		public var nav_title:String;
		public var subtitle:String;
		public var sys_language_uid:String;
		public var path:String;
		
		public function TFMediaCategory(o:Object) {
			super(o);
		}
		
	}
	
}