package net.typoflash.templates.menus 
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import net.typoflash.base.MenuBase;
	import net.typoflash.templates.menus.MenuItem;
	import net.typoflash.events.MenuItemEvent;
	import net.typoflash.events.RenderingEvent;
	import net.typoflash.ContentRendering;

	//import fl.transitions.Tween;	
	
	/**
	 * A single level vertical tab menu where active page pops out. Very simple.
	 * ...
	 * @author A. Borg
	 */
	public class VerticalTabMenu extends MenuBase{
		public var mainSymbol:Class;//MenuItem
		protected var _width:Number=30;
		protected var _totalHeight:Number = 500;
		protected var _itemHeight:Number = 70;
		
		public function VerticalTabMenu() {
			//since we are not using any other components no need to nest further
			view = this;
			fixedDimensions = false;//box can expand beyond total height by default
			_itemPadding = 8;
		}

		
		override public function render() {
			renderMenuBar();
		}
		
		public function renderMenuBar() {
			var mc:MenuItem;
			var oldY:int =0;
			if(fixedDimensions){
				var itemH = _totalHeight / menuXML.children().length();
			}
			for(var i=0;i<menuXML.children().length();i++){
				mc = new ItemClasses[0]();
				mc.skin = new ItemSkins[0]();

				//order is important sometimes since node sets label and thus width need to be set for textfield to be centered		
				//order these are set is important
				mc.menu = this;
				
				mc.y = oldY;
				
				mc.width = width;
				
				
				mc.padding = _itemPadding;
				mc.margin = _itemMargin;		
				
				//this sets text dimensions
				mc.node = menuXML.children()[i];
				if (fixedDimensions) {
					mc.height = itemH;
				}
				//now extract dimensions after text is set
				oldY += mc.height+_itemMargin;
				
				//mc.addEventListener(MenuItemEvent.ON_ROLL_OVER, openDropdownMenu);
				addChild(mc);
			}	
		}
		override public function set width(v:Number):void {
			_width = v;
		}
		override public function get width():Number {
			return _width;
		}
		override public function get height():Number { return _totalHeight; }
		
		override public function set height(value:Number):void{
			_totalHeight = value;
		}	
	}
	
}