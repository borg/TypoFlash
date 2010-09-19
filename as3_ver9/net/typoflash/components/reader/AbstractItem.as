package net.typoflash.components.reader {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import net.typoflash.events.ReaderEvent;
	import net.typoflash.components.Skinnable;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextField;
	import flash.text.AntiAliasType;
	import flash.text.TextFormat;
	import net.typoflash.utils.Debug;
	import  net.typoflash.utils.WeakRef;
	/**
	 * ...
	 * @author A. Borg
	 */
	public class AbstractItem extends Skinnable	{
		public var reader:AbstractReader;
		protected var _data:*;
		protected var _padding:int=0;//Passed on from NewsList.itemPadding
		protected var _margin:int=0;//Passed on from NewsList.itemMargin

		protected var _isActive:Boolean = false;
		protected var _isOpen:Boolean = false;
		protected var _holder:Sprite;//holder of nested items
		
		
		public function AbstractItem(_reader:AbstractReader, __data = null) {
			if(__data){
			var d = new WeakRef(__data);
			_data = d.get();
			}
			var r = new WeakRef(_reader);
			reader = r.get() as AbstractReader;
			//this is NOT enough to enable garbage collection!
			reader.addEventListener(ReaderEvent.ON_SET_ACTIVE_ITEM, onSetActive, false, 0, true);
			//should this be a settings option?
			//reader.addEventListener(ReaderEvent.ON_SET_RECORDSET, onSetActive, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, abstractRemoved, false, 0, true);

		}
		public function abstractRemoved(e=null) {
			reader.removeEventListener(ReaderEvent.ON_SET_ACTIVE_ITEM, onSetActive);
		}
		
		public function render() {
			throw new Error("Override AbstractItem.render")
		}
		public function over() { }
		public function out() { }
		public function activate() { }
		
		public function get padding():int { return _padding; }
		
		public function set padding(value:int):void 
		{
			_padding = value;
		}
		
		public function get margin():int { return _margin; }
		
		public function set margin(value:int):void 
		{
			_margin = value;
		}	
		public function get data():* { return _data; }
		
		public function set data(value:*):void {
			_data = value;
		}
		
		public function get holder():Sprite { return skin.holder; }
		
	
		protected function onSetActive(e:ReaderEvent) {
			_data = e.data;
			if (e.data ) {
				_isActive = true;
			}else {
				_isActive = false;
			}
			
			activate();
			
		}	
		
		protected function rollOver(e:MouseEvent) {
			over();
			dispatchEvent(new ReaderEvent(ReaderEvent.ON_ROLL_OVER, this));
		}
		protected function rollOut(e:MouseEvent) {
			out();
			dispatchEvent(new ReaderEvent(ReaderEvent.ON_ROLL_OUT, this));
		}
		
		protected function click(e:MouseEvent) {
			//_menu.onClick(node);
		}
		public function setDefaultTextFormat(tf:TextField, size:int = 12, colour:int = 0, fontId:int = -1, autoSize:String = TextFieldAutoSize.LEFT) {
			//override to set dynamic fonts
			try{
				if(TF_CONF.FONT_MANAGER.fontList.length>0){
					tf.embedFonts = true;
					tf.antiAliasType = AntiAliasType.ADVANCED;  
					tf.autoSize = autoSize;
					tf.defaultTextFormat = new TextFormat( TF_CONF.FONT_MANAGER.getFontById(fontId).fontName, size, colour);
				}
			}
			catch (e:Error)	{
				Debug.output("Abstract item setDefaultFont error")
			}			
		}	
	}
	
}