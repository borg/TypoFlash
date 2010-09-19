package net.typoflash.fonts 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	//import net.typoflash.datastructures.TFConfig;
	import net.typoflash.utils.Debug;	
	import flash.display.Stage;
	//import net.typoflash.ICore;
	/**
	 * ...
	 * @author A. Borg
	 */
	public class FontAsset extends MovieClip {
		protected var _fontClasses:Array;
		protected var _name:String;//name as it is listed in global Font list
		protected var _size:int = 0;
		
		public function FontAsset() {
			
			addEventListener(Event.ADDED_TO_STAGE, init, false, 0, true);
	
		}
		function init(e) {
			try {
				stage.getChildAt(0)["registerFonts"](_name, _fontClasses,_size);
			}
			catch (e:Error)	{
				trace("Cannot call register function on stage")
			}	
		}
		
	}
	
}