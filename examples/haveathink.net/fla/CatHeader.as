package {
	import flash.display.Sprite;
	import net.typoflash.components.news.NewsReader;
	import net.typoflash.events.ReaderEvent;
	import net.typoflash.datastructures.TFConfig;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.text.AntiAliasType;
	/**
	 * ...
	 * @author A. Borg
	 */
	
	public class CatHeader extends Sprite{
		var reader:NewsReader;
		public var TF_CONF:TFConfig  = TFConfig.global;		
		
		public function CatHeader(_reader) 	{
			reader = _reader;
			reader.addEventListener(ReaderEvent.ON_SET_ACTIVE_CATEGORY, onActiveCatetory);
			setDefaultTextFormat()
			titleTxt.text = "";
			currentCatTxt.text = "Current category"		
			selectCatTxt.text = "Select category"		
		

		}
		function onActiveCatetory(e) {
			//setDefaultTextFormat()
			titleTxt.text = reader.activeCategory.title;
			currentCatTxt.text = "Current category"
			
			
		}

		function setDefaultTextFormat() {
			if (reader.textFormats[0]) {
				reader.textFormats[0].size = 22
				titleTxt.defaultTextFormat = new TextFormat(reader.textFormats[0].font,22,reader.colours[0]);
				titleTxt.embedFonts = true;
				titleTxt.antiAliasType = AntiAliasType.ADVANCED;  
				
			}
			if(reader.textFormats[2]){
				reader.textFormats[2].size = 8
				reader.textFormats[2].color = reader.colours[1];
				currentCatTxt.defaultTextFormat = new TextFormat(reader.textFormats[2].font,8,reader.colours[1]);
				currentCatTxt.embedFonts = true;
				currentCatTxt.antiAliasType = AntiAliasType.ADVANCED;  
				selectCatTxt.defaultTextFormat = currentCatTxt.defaultTextFormat;
				selectCatTxt.embedFonts = true;
				selectCatTxt.antiAliasType = AntiAliasType.ADVANCED;  
			}
		}
	}
	
}