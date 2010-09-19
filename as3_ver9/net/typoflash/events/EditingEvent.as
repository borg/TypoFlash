package net.typoflash.events{
	
	/**
	 * ...
	 * @author Borg
	 */
	
	import flash.events.Event;
	 
	public class EditingEvent extends Event {
		public static const ON_EDIT:String = "onEdit";
		public static const ON_ERROR:String = "onError";
		
		public static const MODE_MENU:String = "TFMenu";
		public static const MODE_TEMPLATE:String = "TFTemplate";
		public static const MODE_FRAME:String = "TFFrame";
		public static const MODE_PRELOADER:String = "TFPreloader";
		public static const MODE_COMPONENT:String = "TFComponent";
		public static const MODE_TEMPLATE_OBJECT:String = "TFTemplateObject";
		
		
		public static const EDIT_MODE_TEXT:String = "editModeText";
		public static const EDIT_MODE_MOVE:String = "editModeMove";
		public static const ON_SET_EDIT_MODE:String = "onSetEditMode";
		
		public static const ON_STORE_PAGE_DATA:String = "onStorePageData";
		public static const ON_DELETE_PAGE_DATA:String = "onDeletePageData";
		public static const ON_HISTORY_CHANGED:String = "onHistoryChanged";
		public static const ON_HISTORY_STORED:String = "onHistoryStored";
		
		
		public static const ON_GLUE_SELECTED:String = "onGlueSelected";
		public static const ON_GLUE_UNSELECTED:String = "onGlueUnselected";
		public static const ON_GLUE_EDITABLE:String = "onGlueEditable";

		
		public static const TRUE:int = 1;
		public static const FALSE:int = 0;
		public static const PENDING:int = -1;
		
		public var data:*;
		

		
		public function EditingEvent(type:String,d:*=undefined, bubbles:Boolean = false, cancelable:Boolean = false) { 
			data = d;
			super(type, bubbles, cancelable);
		
		}
		
	
	}
	
}