package net.typoflash.ui.components 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	/**
	 * ...
	 * @author A. Borg
	 */
	public class ScrollList extends Sprite{
		private var _mask:Sprite;
		private var _frame:Sprite;
		private var _bg:Sprite;
		private var _holder:Sprite;
		private var _content:*;
		public var reactionDistance:uint=60;//the distance from the edge that is sensitive and cause scrolling
		public var itemHeight:uint = 20;//you only want final item to be fully visible even if cursor is not all the way at the end
		public var borderColour:int;//if set will render a border of 1 px around 
		public var bgColour:int;//if set will render a border of 1 px around 
		private var _overflow:uint;//the amount that sticks out on each side when content is centred
		
		private var _targetY:int;
		
		public function ScrollList() {

			
			_holder = new Sprite();
			addChild(_holder);	
			
			_mask = new Sprite();
			_mask.graphics.beginFill (0xFFFF00,0);
			_mask.graphics.lineStyle (0, 0xFF00FF, 0);
			_mask.graphics.moveTo (0, 0);
			_mask.graphics.lineTo (100, 0);
			_mask.graphics.lineTo (100, 100);
			_mask.graphics.lineTo (0, 100);
			_mask.graphics.endFill();
			_mask.mouseEnabled = false;		
			addChild(_mask);	
			_holder.mask = _mask;

			addEventListener(MouseEvent.MOUSE_OVER, activate, false, 0, true);
			addEventListener(Event.ADDED_TO_STAGE, onAdded, false, 0, true);
			//addEventListener(MouseEvent.MOUSE_OUT, deactivate, false, 0, true);
		}
		
		private function onAdded(e:Event) {
			_bg = new Sprite();
			if(bgColour){
				_bg.graphics.beginFill (bgColour,1);
				_bg.graphics.lineStyle (0, bgColour, 1);
			}else {
				_bg.graphics.beginFill (0,0);
				_bg.graphics.lineStyle (0, 0, 1);
			}
			_bg.graphics.moveTo (0, 0);
			_bg.graphics.lineTo (100, 0);
			_bg.graphics.lineTo (100, 100);
			_bg.graphics.lineTo (0, 100);
			_bg.graphics.endFill();
			_bg.mouseEnabled = true;		
			addChildAt(_bg,0);				

					
			if(borderColour){
				_frame = new Sprite();
				_frame.graphics.beginFill (borderColour,0);
				_frame.graphics.lineStyle (0, borderColour, 1);
				_frame.graphics.moveTo (0, 0);
				_frame.graphics.lineTo (100, 0);
				_frame.graphics.lineTo (100, 100);
				_frame.graphics.lineTo (0, 100);
				_frame.graphics.endFill();
				_frame.mouseEnabled = false;		
				addChild(_frame);				
			}	
			setSize(width, Math.min(_content.height,height));
		}
		
		private function activate(e:MouseEvent) {
			if (!visible || _content.height < _mask.height) {
				height = _content.height;
			}
			addEventListener(Event.ENTER_FRAME, update, false, 0, true);
		}
		private function deactivate(e:MouseEvent) {
			removeEventListener(Event.ENTER_FRAME, update);
		}
				
		private function update(e:Event) {
			if (!visible || _content.height < _mask.height) {
				removeEventListener(Event.ENTER_FRAME, update);
				return;
			}
			var fx:Number;//0-1
			var finY:Number;
			var dif:Number;
			_overflow = (_content.height - _mask.height) / 2;
			var _offset = itemHeight >> 1;//divide with 2 bitwise
			if(_overflow>0){
				if (mouseY < reactionDistance) {
					fx = Math.min(1, (reactionDistance-mouseY) / (reactionDistance-_offset));
					_targetY = -_overflow + _overflow * fx
				}else if (mouseY > (height - reactionDistance)) {
					var baseH = height - reactionDistance;
					fx =  Math.min(1, (mouseY - baseH) / (reactionDistance-_offset));
					_targetY =-_overflow - _overflow * fx;
				}
			}
			dif = -_holder.y + _targetY;
			_holder.y += dif/3;

		}
		
		override public function get height():Number{
			return _mask.height;
		}
		
		override public function set height(v:Number):void {
			_mask.height = v;
			if(_frame){
				_frame.height = v;
			}
			if(_bg){
				_bg.height = v;
			}		
		}		
		override public function get width():Number{
			return _mask.width;
		}
		
		override public function set width(v:Number):void {
			_mask.width = v;
			if(_frame){
				_frame.width = v;
			}
			if(_bg){
				_bg.width = v;
			}	
		}	
		
		public function get content():* { return _content; }
		
		public function set content(value:*):void {
			while (_holder.numChildren) {
				_holder.removeChildAt(_holder.numChildren-1);
			}
			_holder.addChild(value);
			_content = value;
			_content.y = 0;
			_content.x = 0;
			_holder.y = 0;
			
		}
		
		public function setSize(w:Number, h:Number) {
			height = h;
			width = w;
		}
	}
	
}