package net.typoflash.events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Borg
	 */
	public class GlueEvent extends Event {
		public static const ON_DATA:String = "onData";
		
		public static const ON_GET_RECORDS:String = "onGetRecords";
		public static const ON_GET_RENDERED_CONTENT:String = "onGetRenderedContent";
		//public static const ON_GET_MEDIA:String = "onGetMedia";
		//public static const ON_GET_MEDIA_FROM_CATEGORY:String = "onGetMediaFromCategory";	
		

		
		public static const ON_SET_LANGUAGE:String = "onSetLanguage";

		

		public static const ON_GET_MOTHERLOAD:String = "onGetMotherload";
		public static const ON_GET_LANGUAGES:String = "onGetLanguages";
		
		public static const ON_TEMPLATE_STATE:String = "onTemplateState";
		public static const ON_PAGE_STATE:String = "onPageState";
		
		public static const ON_CLEAR_CACHE:String = "onClearCache";
		
		public var data:*;
		
		public function GlueEvent(type:String,d:*=undefined, bubbles:Boolean = false, cancelable:Boolean = false) { 
			data = d;
			super(type, bubbles, cancelable);
		}
		
		override public function clone() : Event {
			return new GlueEvent(this.type, this.data,this.bubbles, this.cancelable);
		}
		
	}
	
}