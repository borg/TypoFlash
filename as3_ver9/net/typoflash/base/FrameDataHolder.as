package net.typoflash.base 
{
	import flash.display.Sprite;
	import net.typoflash.datastructures.TFContent;
	import net.typoflash.datastructures.TFData;
	
	/**
	 * ...
	 * @author Borg
	 */
	public class FrameDataHolder extends Sprite	{
		private var _TFdata:TFData;
		public var content:Sprite;
		public function FrameDataHolder(c:TFContent) {
			content = new Sprite();
			_TFdata = new TFData();
			_TFdata.CONTENT = c;
			addChild(content);
		}
		
		public function get data():TFData { return _TFdata; }
		
		public function set data(value:TFData):void 
		{
			_TFdata = value;
		}
		
	}
	
}