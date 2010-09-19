package {
	import flash.text.TextField;
	import net.typoflash.components.reader.AbstractCategoryItem;
	import net.typoflash.datastructures.TFNewsCategory;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import flash.text.Font;
	import flash.text.TextFieldAutoSize;
	import flash.text.AntiAliasType;
	/**
	 * ...
	 * @author A. Borg
	 */
	public class HaveACategoryItem extends AbstractCategoryItem	{
		
		public function HaveACategoryItem(_selector,_data) { 
			super(_selector, _data);
		}
		override public function render() {
			try{
				var tf:TextFormat = new TextFormat(TF_CONF.FONT_MANAGER.getFontById(0).fontName, 22,0xFFFFFF);
				skin.titleTxt.embedFonts = true
				skin.titleTxt.defaultTextFormat = tf;
			}catch (e:Error)	{
				//trace(e)
				tf =  new TextFormat("Verdana", 10, 0x333333);
			}
			//trace("HaveACategoryItem "+tf.font)
			if (isActive) {
				skin.bg.states.gotoAndStop("active")
			}else {
				skin.bg.states.gotoAndStop("passive")
			}
			

			   
			//titleTxt.x = bg.width / 2 - titleTxt.width / 2;
			skin.titleTxt.text = TFNewsCategory(data).title + " (" + TFNewsCategory(data).ITEMS.length +")";
			//skin.titleTxt.setTextFormat(tf);
			
			skin.titleTxt.mouseEnabled = false;
			skin.titleTxt.autoSize = TextFieldAutoSize.LEFT;
			skin.bg.addEventListener(MouseEvent.ROLL_OVER, onRollIt, false, 0, true);
			skin.bg.addEventListener(MouseEvent.ROLL_OUT, onRollItOut, false, 0, true);
			skin.bg.addEventListener(MouseEvent.CLICK, click, false, 0, true);
			skin.bg.buttonMode = true;
		
				
			
		}
		
		private function onRollIt(e:MouseEvent) {
			skin.bg.hilite.gotoAndStop("over")
			skin.titleTxt.textColor = 0x000000;
			//reader.stopTimer();
			//reader.dispatchEvent(new ReaderEvent(ReaderEvent.ON_SET_ACTIVE,data))
		}
		private function onRollItOut(e:MouseEvent) {
			skin.bg.hilite.gotoAndPlay("out");
			skin.titleTxt.textColor = 0xFFFFFF;
			//reader.dispatchEvent(new ReaderEvent(ReaderEvent.ON_SET_ACTIVE,data))
		}
		
		override public function activate() {
			if (isActive) {
				skin.bg.states.gotoAndStop("active")
			}else {
				skin.bg.states.gotoAndStop("passive")
			}
			
		}
		protected function onFinishTween() {
			skin.bodyTxt.visible = true;
		}
		
		override public function set height(v:Number):void {
			skin.holder.y = v + margin;
			skin.bg.height = v;
		}
		override public function get height():Number {
			return skin.bg.height;
		}		
	}
	
}