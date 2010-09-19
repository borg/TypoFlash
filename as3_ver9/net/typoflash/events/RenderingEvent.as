package net.typoflash.events{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Borg
	 */
	public class RenderingEvent extends Event{
		
		public static const ON_PRE_SET_PAGE:String = "onPreSetPage";
		public static const ON_SET_PAGE:String = "onSetPage";
		//pre get page is used by glue to extract the config key
		public static const ON_PRE_GET_PAGE:String = "onPreGetPage";
		public static const ON_GET_PAGE:String = "onGetPage";
		
		
		public static const ON_SET_LANGUAGE:String = "onSetLanguage";

		

		public static const ON_GET_MOTHERLOAD:String = "onGetMotherload";
		public static const ON_GET_LANGUAGES:String = "onGetLanguages";

		
		
		
		
		public static const ON_REQUEST_MENU:String = "onRequestMenu";
		public static const ON_GET_MENU:String = "onGetMenu";
		
		public static const ON_TEMPLATE_STATE:String = "onTemplateState";
		public static const ON_PAGE_STATE:String = "onPageState";
		public static const ON_QUERY_PARAMETERS:String = "onQueryParameters";
		
		public static const ON_CLEAR_CACHE:String = "onClearCache";
		public static const ON_PARSE_PAGE_DATA:String = "onParsePageData";//TODO
		
		
		//Template events
		public static const ON_TEMPLATE_ADDED_TO_STAGE:String = "onTemplateAddedToStage";//listen to this and run init in template objects etc instead of onAddedToStage, since children can be added before super properties are set
	
		
		//Menu events
		public static const ON_MENU_ITEM_ACTIVATED:String = "onMenuItemActivated";//Communication between different menus	
		public static const ON_MENU_PARSED:String = "onMenuParsed";

		public static const ON_SET_ACTIVE:String = "onSetActive";
		public static const ON_CHANGE:String = "onChange";
		
		//Frame events
		public static const ON_FRAME_LOAD_BEGIN:String = "onFrameLoadBegin";
		public static const ON_FRAME_LOAD_PROGRESS:String = "onFrameLoadProgress";
		public static const ON_FRAME_LOAD_COMPLETE:String = "onFrameLoadComplete";
		public static const ON_PAGE_LOAD_COMPLETE:String = "onPageLoadComplete";
		
		public static const ON_TRANSITION_BEGIN:String = "onTransitionBegin";
		public static const ON_TRANSITION_COMPLETE:String = "onTransitionComplete";
		
		
		
		//Component events
		public static const ON_GET_RECORDS:String = "onGetRecords";
		public static const ON_GET_RENDERED_CONTENT:String = "onGetRenderedContent";
		public static const ON_GET_MEDIA:String = "onGetMedia";
		public static const ON_GET_MEDIA_FROM_CATEGORY:String = "onGetMediaFromCategory";	
		
		public static const ON_GET_NEWS:String = "onGetNews";
		public static const ON_GET_NEWS_FROM_CATEGORY:String = "onGetNewsFromCategory";			
		public static const ON_GET_NEWS_CATEGORIES:String = "onGetNewsCategories";			
		
		
		public static const ON_SET_SKIN:String = "onSetSkin";			
		public static const ON_RESIZE:String = "onResizeComponent";			
	
		public var data:*;
		public function RenderingEvent(type:String,d:*=undefined, bubbles:Boolean = false, cancelable:Boolean = false) { 
			data = d;
			super(type, bubbles, cancelable);
		}
		
		override public function clone() : Event {
			return new RenderingEvent(this.type, this.data,this.bubbles, this.cancelable);
		}
	}
	
}