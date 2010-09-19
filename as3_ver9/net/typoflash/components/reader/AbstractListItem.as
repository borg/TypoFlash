package net.typoflash.components.reader {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import net.typoflash.events.ReaderEvent;
	import net.typoflash.components.Skinnable;	
	/**
	 * ...
	 * @author A. Borg
	 */
	public class AbstractListItem extends Skinnable	{
		public var reader:AbstractReader;
		protected var _data:*;
		protected var _padding:int=0;//Passed on from NewsList.itemPadding
		protected var _margin:int=0;//Passed on from NewsList.itemMargin

		protected var _isActive:Boolean = false;
		protected var _isOpen:Boolean = false;
		protected var _holder:Sprite;//holder of nested items
		
		
		public function AbstractListItem(_reader:AbstractReader,__data = null) {
			_data = __data;
			reader = _reader;
			reader.addEventListener(ReaderEvent.ON_SET_ACTIVE_ITEM, onSetActive, false, 0, true);
			
			
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
		
		public function get holder():Sprite { return skin._holder; }
		

		protected function onSetActive(e:ReaderEvent) {
			if (e.data == _data) {
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
		
		public function setDefaultTextFormat() {
			//override to set dynamic fonts
		}
	}
	
}