package net.typoflash.ui.forms{
	import flash.events.Event;



	public class FormEvent extends Event {
		public static const SELECTED:String = "onSelected";
		public static const PRE_CHANGED:String = "onPreChanged";
		public static const CHANGED:String = "onChanged";
		public static const CLOSED:String = "onClosed";
		
		public var data:*;
		


		
		public function FormEvent(type:String,d:*=''){
			data = d;
			super(type, true);
		
		}
		
		public override function clone():Event {
			return new FormEvent(type,data);
		}
	}
}