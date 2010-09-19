package net.typoflash.events {
	import flash.events.Event;
	import net.typoflash.templates.menus.MenuItem;
	/**
	 * ...
	 * @author A. Borg
	 */
	public class MenuItemEvent extends Event	{
		
		public static const ON_ROLL_OVER:String = "over";
		public static const ON_ROLL_OUT:String = "out";
		
		public var item:MenuItem;
				
		public function MenuItemEvent(type:String,_item:MenuItem, bubbles:Boolean = false, cancelable:Boolean = false){
			item = _item;
			super(type, bubbles, cancelable);
		}
		override public function toString():String {
				return "[MenuItemEvent item: " + item.node.@label + "]"; 
		}	
	}
	
}