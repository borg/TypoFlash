package net.typoflash.transitions 
{
	import flash.display.Sprite;
	
	/**
	 * Needs to fire ON_START and ON_COMPLETE events
	 * ...
	 * @author A. Borg
	 */
	public interface ITransition{
		function startTransition():void;
		function stopTransition():void;
		function destroy():void;
		//function get source():Sprite;
		//function set source(s:Sprite):void;
		//function get destination():Sprite;
		//function set destination(s:Sprite):void;
		function get newSpriteInFront():Boolean;
		function get duration():Number;
		function set duration(s:Number):void;
		//transfer all properties from this object to each new instance
		function set inProperties(s:Object):void;		
		function set outProperties(s:Object):void;		
	}
	
}