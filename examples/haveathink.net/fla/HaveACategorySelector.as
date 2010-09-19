package {
	import net.typoflash.ui.components.ScrollList;
	import net.typoflash.components.news.NewsCategorySelector;
	/**
	 * ...
	 * @author A. Borg
	 */
	public class HaveACategorySelector 	extends NewsCategorySelector{
		public var scrollList:ScrollList;
		public function HaveACategorySelector(_reader) {
			super(_reader);
		}
		override public function render(start:int=-1,length:int=-1) {
			super.render(start, length);
			scrollList = new ScrollList();
			scrollList.height = 400;
			scrollList.bgColour = 0x000000;
			//scrollList.borderColour = 0x00FF00;
			scrollList.width = 250;
			scrollList.itemHeight = 50;
			scrollList.reactionDistance = 100;
			scrollList.content = _holder;
			addChild(scrollList);
			
		}	
		override public function set height(v:Number):void {
			scrollList.height = v;
		}
		override public function get height():Number {
			return scrollList.height;
		}	
	}
	
}