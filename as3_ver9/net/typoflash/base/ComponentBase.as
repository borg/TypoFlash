package net.typoflash.base{
	
	/**
	 * Offers some optional default settings for component swfs to be loaded into template frames
	 * ...
	 * @author Borg
	 */
	import flash.display.MovieClip;
	import net.typoflash.datastructures.TFConfig;
	import flash.events.Event;
	import net.typoflash.Glue;
	import net.typoflash.ContentRendering;
	import net.typoflash.events.RenderingEvent;
	
	public class ComponentBase extends MovieClip implements IComponent{
		public var TF_CONF:TFConfig  = TFConfig.global;
		private var _TFglue:Glue;
		public function ComponentBase()	{
			addEventListener(Event.REMOVED_FROM_STAGE, onRemoved, false, 0, true);
			ContentRendering.addEventListener(RenderingEvent.ON_PAGE_STATE, onPageState,false,0,true);
			_TFglue = new Glue(this);
		}
		private function onRemoved(e:Event):void { 
			ContentRendering.removeEventListener(RenderingEvent.ON_PAGE_STATE,onPageState);
			destroy()
		}
		public function destroy():void  {
			throw new Error("You need to override the destroy method in the component " + this +" and make sure it cleans up after itself");
		}
		public function get TF_GLUE():Glue {
			return _TFglue;
		}	
		protected function onPageState(e:RenderingEvent) { }
	}
	
}