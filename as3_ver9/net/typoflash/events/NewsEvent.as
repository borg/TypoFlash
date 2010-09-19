package net.typoflash.events{
	import flash.events.Event;
	/**
	 * This event is passed around inside a NewsReader to keep children in the loop.
	 * The NewsReader listens to the RenderingEvent to get the data, but kids dont know that.
	 * ...
	 * @author A. Borg
	 */
	public class NewsEvent extends Event {
		//public static const ON_GET_RECORDS:String = "onGetRecords";
		public var data:*;
		
		public function NewsEvent(type:String, d:*= undefined, bubbles:Boolean = false, cancelable:Boolean = false){
			data = d;
			super(type, bubbles, cancelable);
		}
		override public function toString():String {
				return "[NewsEvent type : " + type + "]"; 
		}	
	}
	
}