package net.typoflash.base 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import net.typoflash.datastructures.TFConfig;
	import net.typoflash.ContentRendering;
	import net.typoflash.events.RenderingEvent;
	import net.typoflash.events.AuthEvent;
	import net.typoflash.events.CoreEvent;
	import net.typoflash.events.EditingEvent;
	import net.typoflash.Glue;
	import net.typoflash.components.Skinnable;
	import net.typoflash.utils.Debug;
	
	/**
	 * ...
	 * @author Borg
	 */
	public class Configurable extends Skinnable implements ITemplateObject {
				

		private var _TFglue:Glue;
		//private var _TFeditorClass:String;
		
		public function Configurable(){
			addEventListener(Event.ADDED_TO_STAGE, addListeners, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, removeListeners, false, 0, true);
			addEventListener(Event.UNLOAD, removeListeners, false, 0, true);
			//TFeditorClass = this;//set to template/menu/frame/component/template object
			
			/*
			  this._width = Math.round(this._width);
			  this._height = Math.round(this._height);
			  this._x = Math.round(this._x);
			  this._y = Math.round(this._y);
			  this._yscale = 100;
			  this._xscale = 100;
			  this._TFtweenFunc = net.typoflash.utils.TweenFunc.easeInOutQuad;
			  this._TFtweenTime = 0.7;*/
			try {
				//not sure this goes here
			/*if (TF_CONF.CURR_PAGE_STATE_STR.length > 0 && ContentRendering.pageState[TF_CONF.PID] == null) {
				TF_CONF.CORE.dispatchEvent(new CoreEvent(CoreEvent.ON_EXT_PAGE_STATE,TF_CONF.CURR_PAGE_STATE_STR));
				TF_CONF.CURR_PAGE_STATE_STR = null;
			}*/
			}
			catch(e){}
			_TFglue = new Glue(this);
			
			//this._TFglue.__set__disablePhysicalConfig(this._disablePhysicalConfig);
			
		}
		
		
		private function addListeners(e:Event) {
			ContentRendering.addEventListener(RenderingEvent.ON_GET_PAGE, onGetPage,false,0,true);
			ContentRendering.addEventListener(RenderingEvent.ON_PAGE_STATE, onPageState,false,0,true);
			ContentRendering.addEventListener(RenderingEvent.ON_GET_MOTHERLOAD,onGetMotherload,false,0,true);
			ContentRendering.addEventListener(RenderingEvent.ON_CLEAR_CACHE,onClearCache,false,0,true);
			ContentRendering.addEventListener(RenderingEvent.ON_SET_PAGE, onSetPage, false, 0, true);
			ContentRendering.addEventListener(RenderingEvent.ON_SET_LANGUAGE, onSetLanguage, false, 0, true);
			/*TF_CONF.FE_AUTH.addEventListener(AuthEvent.ON_LOGIN_STATUS, onLoginStatus, false, 0, true);*/
			stage.addEventListener(Event.RESIZE, onStageResize,false,0,true);
			
	
		}
		
		private function removeListeners(e:Event) {
			
			ContentRendering.removeEventListener(RenderingEvent.ON_GET_PAGE,onGetPage);
			ContentRendering.removeEventListener(RenderingEvent.ON_PAGE_STATE,onPageState);
			ContentRendering.removeEventListener(RenderingEvent.ON_GET_MOTHERLOAD, onGetMotherload);
			ContentRendering.removeEventListener(RenderingEvent.ON_CLEAR_CACHE,onClearCache);
			ContentRendering.removeEventListener(RenderingEvent.ON_SET_PAGE,onSetPage);
			ContentRendering.removeEventListener(RenderingEvent.ON_SET_LANGUAGE, onSetLanguage);
			
			try{
				stage.removeEventListener(Event.RESIZE, onStageResize);
			
				TF_CONF.FE_AUTH.removeEventListener(AuthEvent.ON_LOGIN_STATUS, onLoginStatus);
			}
			catch (e:Error) {
				Debug.output("Configurable.removeListeners error "+ e);
			}
			//_TFglue.destroy(new Event(Event.UNLOAD));
			_TFglue = null;
			destroy();
		}
		

		
		protected function onStageResize(e:Event) {
			positionChildren();
		}
		//override
		public function positionChildren() {}

		
		public function get TF_GLUE():Glue {
			return _TFglue;
		}		
		/*
		public function get TFeditorClass():String { return _TFeditorClass; }
		
		public function set TFeditorClass(c):void {
			if (this is MenuBase) {
				_TFeditorClass = EditingEvent.MODE_MENU;
			}else if (this is TemplateBase) {
				_TFeditorClass = EditingEvent.MODE_TEMPLATE;
			}else if (this is FrameBase) {
				_TFeditorClass = EditingEvent.MODE_FRAME;
			}else if (this is ComponentBase) {
				_TFeditorClass = EditingEvent.MODE_COMPONENT;
			}else if (this is Configurable) {
				//only one left
				_TFeditorClass = EditingEvent.MODE_TEMPLATE_OBJECT;
			}
			
			

        };*/



		
		protected function onGetPage(e:RenderingEvent) {}
		protected function onPageState(e:RenderingEvent) { }
		protected function onGetMotherload(e:RenderingEvent) { }
		protected function onClearCache(e:RenderingEvent) { }
		protected function onSetPage(e:RenderingEvent) { }
		protected function onLoginStatus(e:RenderingEvent) { }
		protected function onSetLanguage(e:RenderingEvent) { }
		
		
		
		public function destroy():void { 
			//throw new Error("You need to override the destroy method in the configurable " + this +" and make sure it cleans up after itself");
		}

	}
	
}