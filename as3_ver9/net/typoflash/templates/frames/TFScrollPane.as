package net.typoflash.templates.frames{
	
	/**
	 * ...
	 * @author Borg
	 */
	import flash.display.Sprite;
	import net.typoflash.base.FrameBase;
	import fl.containers.ScrollPane;
    import fl.events.ScrollEvent;
	import flash.events.Event;
	import net.typoflash.events.RenderingEvent;
	import net.typoflash.utils.Debug;
	import fl.controls.ScrollPolicy;
	import flash.events.ProgressEvent;
	import net.typoflash.events.CoreEvent;
	import net.typoflash.events.RenderingEvent;

	public class TFScrollPane extends FrameBase{
		private var _sp:ScrollPane;
		
		
		
		public function TFScrollPane(){

		}
		override protected function setUpSkin(e:RenderingEvent) {
			
			_sp = skin as ScrollPane;
			_sp.setSize(800, 500);
			_sp.horizontalScrollPolicy = ScrollPolicy.OFF;
			_sp.verticalScrollPolicy = ScrollPolicy.AUTO;
			//_sp.useHandCursor = false;
			//_sp.buttonMode = false;
            //_sp.source = sampleImagePath;
            _sp.addEventListener(Event.COMPLETE,onLoadComplete);
            _sp.addEventListener(ProgressEvent.PROGRESS, onProgressHandler);

            //_sp.addEventListener(ScrollEvent.SCROLL,repositionPreview);
            _sp.scrollDrag = false;		
		}
		
		override public function render(c:Sprite) {
			
			_sp.source = c;

		}
		
		override public function unload() {
			_sp.source = null;
		}
		override public function get height():Number {
			//careful with there settings as they can cause infinite loops unless scrollpane is initialised
			return _sp.height;
		}
		override public function get width():Number {
			return _sp.width;
		}
		override public function set height(v:Number):void {
			_sp.height = v;
		}
		override public function set width(v:Number):void {
			_sp.width = v;
		}		
		
		override public function setSize(w:int,h:int):void {
			_sp.setSize(w,h);
		}			
		
		protected function onLoadComplete(e:Event) {
			TF_CONF.CORE.dispatchEvent(new CoreEvent(CoreEvent.ON_LOAD_COMPLETE, e, CoreEvent.LOAD_TYPE_COMPONENT ));
		}
		protected function onProgressHandler(e:ProgressEvent) {
			TF_CONF.CORE.dispatchEvent(new CoreEvent(CoreEvent.ON_LOAD_PROGRESS, e, CoreEvent.LOAD_TYPE_COMPONENT ));
		}	
	}
	
}