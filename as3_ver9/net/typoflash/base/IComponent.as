package net.typoflash.base {
	
	/**
	 * ...
	 * @author A. Borg
	 */
	import flash.events.Event;
	public interface IComponent { 
		function destroy():void;//not sure about what fires the unload even, especially using loader queue
	}
}