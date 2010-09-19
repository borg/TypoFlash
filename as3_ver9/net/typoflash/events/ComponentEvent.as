package net.typoflash.events{
	import flash.events.Event;



	public class ComponentEvent extends Event {
		public static const ON_SELECTED:String = "onSelected";
		public static const ON_CHANGED:String = "onChanged";
		public static const ON_CLOSED:String = "onClosed";
		public static const ON_COMPLETED:String = "onComplete";
		
		
		public var data:*;
		


		
		public function ComponentEvent(type:String,d:*=''){
			data = d;
			super(type, true);
		
		}
		
		public override function clone():Event {
			return new ComponentEvent(type,data);
		}
	}
}