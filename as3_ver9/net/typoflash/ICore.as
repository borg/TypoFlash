package net.typoflash {
	
	/**
	 * Used in BEAuthentication
	 * ...
	 * @author A. Borg
	 */
	
	import net.typoflash.events.AuthEvent;
	
	public interface ICore 	{
		function onBELoginStatus(e:AuthEvent):void
		function registerFonts(_name:String, _fontClasses:Array,_size:int=0):void;		
	}
	
}