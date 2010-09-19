package 
{
	import net.typoflash.templates.menus.MenuItem;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import net.typoflash.templates.menus.HorisontalDropDownMenu;
	import net.typoflash.events.MenuItemEvent;
	/**
	 * ...
	 * @author A. Borg
	 */
	public class HorisontalMainSymbol extends MenuItem{
		
		
		public function HorisontalMainSymbol() {
			_hitArea = bg;
			titleTxt.mouseEnabled = false;
		}
		override public function set label(value:String):void {
			TextField(titleTxt).autoSize = TextFieldAutoSize.CENTER;
			titleTxt.text = value;
			_label = value;
		}
		override public function set width(v:Number):void {
			bg.width = v;
		}
		override public function get width():Number {
			return bg.width;
		}	
		
		override public function set height(v:Number):void {
			titleTxt.y = v / 2 - titleTxt.height / 2;
			bg.height = v;
		}
		override public function get height():Number {
			return bg.height;
		}		
		
		override public function render() {
			if (isActive || isInActiveRootline) {
				bg.states.gotoAndStop("active")
			}else {
				bg.states.gotoAndStop("passive")
			}
			titleTxt.x = bg.width / 2 - titleTxt.width / 2;
		}
		
		override public function over(e:MenuItemEvent) { 
			if(e.item == this){
				bg.hilite.gotoAndStop("over");
				HorisontalDropDownMenu(menu).openDropdownMenu(this);
				
			}
		}
		override public function out(e:MenuItemEvent) {
			if(e.item == this){
				bg.hilite.gotoAndPlay("out");
			}
		}	
		
		
	}
	
}