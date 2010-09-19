package net.typoflash.datastructures 
{
	//import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Borg
	 */
	public dynamic class TFNewsItem{
		public var cruser_id:uint;
		public var pid:uint;
		public var imagecaption:String;
		public var crdate:uint;
		public var type:String;
		public var sys_language_uid:uint;
		public var related:String;
		public var tstamp:uint;
		public var short:String;
		public var bodytext:String;
		public var ext_url:String;
		public var news_files:String;
		public var author_email:String;
		public var imagealttext:String;
		public var datetime:uint;
		public var image:String;
		public var l18n_parent:uint;
		public var keywords:String;
		public var page:String;
		public var imagetitletext:String;
		public var category:String;
		public var archivedate:String;
		public var uid:uint;
		public var links:String;
		public var author:String;
		public var title:String;

		
		public function TFNewsItem(o:Object) {
			for (var n in o) {
				this[n]  = o[n];
			}
			
		}
		public function toString():String {
			return "[TFNewsItem " + title +", uid: "+uid+"]";
		}		
	}
	
}