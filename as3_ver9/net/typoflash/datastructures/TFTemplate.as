package net.typoflash.datastructures {
	
	/**
	 * ...
	 * @author Borg
	 */
	public class TFTemplate{
		public var frames:Object;
		public var menus:Object;
		
		public var uid:uint;
		public var template_data:Object;
		public var page_data:Object;
		
		public var conf:String;//change these to be parsed into objects in the constructor
		public var template_conf:String;
		public var page_conf:String;

		public var crdate:uint;
		public var preloader:String;
		public var hidden:Boolean;
		public var tstamp:uint;
		public var redirectpage:String;
		public var hosturl:String;
		public var cruser_id:uint;
		public var language_file:String;
		
		public var title:String;
		public var base:String;
		public var endtime:uint;
		public var fullscreen:String;
		public var relaysocket:String;
		public var metadesc:String;
		public var metakeyword:String;
		public var searchengine:String;
		public var starttime:uint;
		public var relayserver:String;

		public var version:String;
		public var fonts:String;
		public var css:String;
		public var sorting:String;

		public var asversion:String;

		public var swfs:String;
		public var name:String;
		public var codepage:String;
		public var relayport:String;
		public var movieid:String;
		public var height:String;
		public var scalemode:String;
		public var pid:uint;
		public var bgcolour:String;
		public var windowmode:String;

		public var file:String;
		public var align:String;
		public var dynamic_fonts:String;
		public var fe_group:uint;
		public var width:String;
		public var historyframe:String;
		public var menu:String;
		public var deleted:Boolean;
		public var template_pid:uint;		
		
	
		public function TFTemplate(o:Object) {
			for (var n in o) {
				this[n] = o[n];
			}
			
			menus = { };
			frames = { };
			
		}
		
	}
	
}