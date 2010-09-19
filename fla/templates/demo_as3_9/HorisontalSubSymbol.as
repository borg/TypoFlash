package 
{
	import flash.display.Sprite;
	import net.typoflash.templates.menus.MenuItem;
	import net.typoflash.events.MenuItemEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import net.typoflash.templates.menus.HorisontalDropDownMenu;
	/**
	 * ...
	 * @author A. Borg
	 */
	public class HorisontalSubSymbol extends MenuItem{
		
		public var arrow:Sprite;
		
		public function HorisontalSubSymbol() {
			_hitArea = bg;
			titleTxt.mouseEnabled = false;
		}
		override public function set label(value:String):void {
			TextField(titleTxt).autoSize = TextFieldAutoSize.LEFT;
			titleTxt.text = value;
			//titleTxt.x = bg.width / 2 - titleTxt.width / 2;
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
		}
		
		override public function over(e:MenuItemEvent) { 
			if(e.item == this){
				bg.hilite.gotoAndStop("over");

				if(node.children().length()>0){
					//this.mRoot.subInt = setInterval(this.mRoot,"attachSub",100,this.node,this._parent);
					HorisontalDropDownMenu(menu).attachSub(this);
				}
			}else if (String(e.item.node.@rootline).indexOf(String(node.@rootline)) != 0) {
				//if this is not a rollover on one of my kids is it?
				if (subholder.numChildren > 0) {
					for (var c = 0; c < subholder.numChildren; c++) {
						subholder.removeChildAt(c);
					}
				}
			}
			/*var m = {};
			m.type = "onOpened";
			m.node =this.node;
			this.mRoot.dispatchEvent(m);	*/
	
		}
		override public function out(e:MenuItemEvent) {
			if(e.item == this){
				bg.hilite.gotoAndPlay("out");
			}
		}	
		
		
	}
	
}