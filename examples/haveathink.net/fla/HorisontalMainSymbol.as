package 
{
	import flash.events.Event;
	import net.typoflash.templates.menus.MenuItem;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import net.typoflash.templates.menus.HorisontalDropDownMenu;
	import net.typoflash.events.MenuItemEvent;
	import net.typoflash.events.RenderingEvent;
	/**
	 * ...
	 * @author A. Borg
	 */
	public class HorisontalMainSymbol extends MenuItem{
		
		
		public function HorisontalMainSymbol(_level:int=0){
			level = _level;
			
		}
		override protected function setUpSkin(e:RenderingEvent) {
			_hitArea = skin.bg;
			skin.titleTxt.mouseEnabled = false;			
		}
		override public function set label(value:String):void {
			TextField(skin.titleTxt).autoSize = TextFieldAutoSize.LEFT;
			skin.titleTxt.text = value;
			_label = value;
		}
		override public function set width(v:Number):void {
			skin.bg.width = v;
		}
		override public function get width():Number {
			return skin.bg.width;
		}	
		
		override public function set height(v:Number):void {
			skin.titleTxt.y = v - skin.titleTxt.height ;
			skin.bg.height = v;
		}
		override public function get height():Number {
			return skin.bg.height;
		}		
		
		override public function render() {
			if (isActive || isInActiveRootline) {
				skin.bg.states.gotoAndStop("active")
			}else {
				skin.bg.states.gotoAndStop("passive")
			}
			//titleTxt.x = bg.width / 2 - titleTxt.width / 2;
		}
		
		override public function over(e:MenuItemEvent) { 
			if(e.item == this){
				skin.bg.hilite.gotoAndStop("over");
				HorisontalDropDownMenu(menu).openDropdownMenu(this);
				
			}
		}
		override public function out(e:MenuItemEvent) {
			if(e.item == this){
				skin.bg.hilite.gotoAndPlay("out");
			}
		}	
		
		
	}
	
}