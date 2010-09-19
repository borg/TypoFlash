package net.typoflash.events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Borg
	 */
	public class ReaderEvent extends Event{
		public static const ON_NEXT_PAGE:String = "nxt";
		public static const ON_PREVIOUS_PAGE:String = "prev";
		
		public static const ON_NEXT_ITEM:String = "nxtItm";
		public static const ON_PREVIOUS_ITEM:String = "prevItm";		
		
		public static const ON_RECORDSET_TRUNCATED:String = "trunc";//fired if more items in set than maximum allowed
		public static const ON_ADD_ITEM:String = "addItem";//to recordset
		public static const ON_SET_RECORDSET:String = "onRec";//
		public static const ON_SET_ACTIVE_ITEM:String = "onCurrItm";//
		public static const ON_SET_ACTIVE_CATEGORY:String = "onCurrCat";//
		
		public static const RENDERING_IMPULSE:String = "impulse";//

		public static const ON_ROLL_OVER:String = "over";
		public static const ON_ROLL_OUT:String = "out";
		
		//images
		public static const ON_LOAD_PROGRESS:String = "onProg";
		public static const ON_LOAD_COMPLETE:String = "onLoaComp";
		public static const ON_LOAD_ERROR:String = "onLoaErr";
		
		public static const ON_RENDER_ITEM:String = "onRenderItem";
		public static const ON_RENDER_LIST_ITEM:String = "onRenderListItem";
		
		public static const ON_START_TIMER:String = "onStartTimer";
		public static const ON_STOP_TIMER:String = "onStopTimer";
		
		
		
		public var data:*;
		public function ReaderEvent(type:String,d:*=undefined, bubbles:Boolean = false, cancelable:Boolean = false) { 
			data = d;
			super(type, bubbles, cancelable);
		}
		override public function toString():String {
				return "[ReaderEvent type : " + type + "]"; 
		}	
	}
	
}