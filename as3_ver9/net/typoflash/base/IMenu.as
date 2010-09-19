package net.typoflash.base 
{
	
	/**
	 * ...
	 * @author A. Borg
	 */
	public interface IMenu{
		function get rootPid():uint;
		function set rootPid(value:uint):void;
		function get menuId():String;
		function set menuId(value:String):void;
	}
}