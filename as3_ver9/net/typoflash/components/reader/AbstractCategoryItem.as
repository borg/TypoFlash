package net.typoflash.components.reader 
{
	import net.typoflash.components.Skinnable;
	import flash.display.Sprite;
	import net.typoflash.datastructures.TFCategory;
	import net.typoflash.events.ReaderEvent;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author A. Borg
	 */
	public class AbstractCategoryItem extends Skinnable{
		public var selector:AbstractCategorySelector;
		protected var _data:TFCategory;
		protected var _padding:int=0;//Passed on from NewsList.itemPadding
		protected var _margin:int=0;//Passed on from NewsList.itemMargin

		protected var _isActive:Boolean = false;
		protected var _isOpen:Boolean = false;
		protected var _holder:Sprite;//holder of nested items
		
		public function AbstractCategoryItem(_selector:AbstractCategorySelector,__data = null) {
			selector = _selector;
			_data = __data;
			selector.reader.addEventListener(ReaderEvent.ON_SET_ACTIVE_CATEGORY, onSetActive, false, 0, true);
		}
		
		public function render() {
			throw new Error("Override AbstractCategoryItem.render")
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
		public function get data():TFCategory { return _data; }
		
		public function set data(value:TFCategory):void {
			_data = value;
		}
		
		public function get holder():Sprite { return skin.holder; }
		

		protected function onSetActive(e:ReaderEvent) {
			if (e.data == _data) {
				_isActive = true;
			}else {
				_isActive = false;
			}
			
			activate();
			
		}	
		public function get isActive():Boolean { return _isActive; }
		
		public function set isActive(value:Boolean):void 
		{
			_isActive = value;
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
			selector.reader.activeCategory = data;
		}
	}
	
}