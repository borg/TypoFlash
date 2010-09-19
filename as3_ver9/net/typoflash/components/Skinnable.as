package net.typoflash.components 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import net.typoflash.events.RenderingEvent;
	import net.typoflash.datastructures.TFConfig;
	/**
	 * ...
	 * @author A. Borg
	 */
	public class Skinnable extends Sprite{
		private var _skin:*;
		private var _TFconf:TFConfig  = TFConfig.global;	
		
		private var _w:Number;
		private var _h:Number;
		
	
		//public var SkinClass:Class;
	
		public function Skinnable() {
			addEventListener(RenderingEvent.ON_SET_SKIN, setUpSkin, false, 0, true);
		}
		
		protected function setUpSkin(e:RenderingEvent) {
			
		}		
		public function get skin():* { return _skin; }
		
		public function set skin(value:*):void 	{
			if (_skin) {
				removeChild(_skin);
			}
			addChild(value)
			_skin = value;
			dispatchEvent(new RenderingEvent(RenderingEvent.ON_SET_SKIN, this));
		}
			
		public function get TF_CONF():TFConfig {
			return _TFconf;
		}	
		
		override public function get width():Number { return _w; }
		
		override public function set width(value:Number):void {
			_w = value;
			setSize(_w, _h);
		}
		
		override public function get height():Number { return _h; }
		
		override public function set height(value:Number):void{
			_h = value;
			setSize(_w, _h);
		}
		
		public function setSize(w:int, h:int):void {
			//do not call width and height as that would cause infinite loop
			_w = w;
			_h = h;	
			dispatchEvent(new Event(Event.RESIZE));
		}	

	}
	
}