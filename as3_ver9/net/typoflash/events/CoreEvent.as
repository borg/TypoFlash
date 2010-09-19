package net.typoflash.events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Borg
	 */
	public class CoreEvent extends Event{
		public static const ON_BROWSER_HISTORY:String = "onBrowserHistory";
		public static const ON_EXT_TEMPLATE_STATE:String = "onExtTemplateState";
		public static const ON_EXT_PAGE_STATE:String = "onExtPageState";
		public static const ON_EDIT_STATUS:String = "onEditStatus";
		public static const ON_SOUND_STATUS:String = "onSoundStatus";
		
		/*
		 * By letting any loader fire the core events we can keep the whole
		 * application aware of whether some loading processes are underway
		 */ 
		public static const ON_LOAD_PROGRESS:String = "onProg";
		public static const ON_LOAD_COMPLETE:String = "onLoaComp";
		public static const ON_LOAD_ERROR:String = "onLoaErr";
		
		/*
		 * What type of load process? Will be stored on info
		 * Where as the loader info object if there is one will be stored on data
		 */ 
		public static const LOAD_TYPE_ASSETS:String = "typeAssets";//fired by core and global load queue
		public static const LOAD_TYPE_TEMPLATE:String = "typeTemplate";//this is fired by core and global load queue. TempalteBase too?
		public static const LOAD_TYPE_COMPONENT:String = "typeComponent";//this is fired by frames
		public static const LOAD_TYPE_COMPONENT_ASSETS:String = "typeCopmponentAsset";//is hopefully fired by wellbehaving components
		public static const LOAD_TYPE_RPC:String = "typeRPC";//remoting calls
		
		
	    public static var ON_FONT_LOADED = "onFontLoaded";
	    public static var ON_FONT_REGISTER = "onFontRegister";
	    public static var ON_LAST_FONT_REGISTER = "onLastFontRegister";
			
		public var data:*;
		public var info:String;
		public function CoreEvent(type:String,_data:*=undefined,_info:String='', bubbles:Boolean = false, cancelable:Boolean = false) { 
			data = _data;
			info = _info;
			super(type, bubbles, cancelable);
		}
		
	}
	
}