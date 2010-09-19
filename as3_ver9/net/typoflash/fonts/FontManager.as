package net.typoflash.fonts{
	
	/**
	 * ...
	 * @author A. Borg
	 */
	
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.errors.*;
	import flash.system.*;
	import net.typoflash.utils.Debug;
	import flash.text.Font;
	import net.typoflash.datastructures.TFConfig;
	
	public class FontManager {
		private var _fontsDomain:ApplicationDomain;
		private var _styleSheet:StyleSheet;
		private var _fontList:Array;
		private var _fontLookup:Object;

		public function FontManager() 	{
		}

		public function init(fontsDomain:ApplicationDomain, styles:StyleSheet=null) 	{
			_fontsDomain = fontsDomain;
			_styleSheet = styles;
			_fontList = [];
			_fontLookup = { };
		}
		/*
		 * This function accepts a list of variants from ONE font family
		 */ 
		public function registerFonts(_name:String, fList:Array,_size:int=0):void {
			Debug.output("FontManager registerFonts "+ fList + " _name "+_name)
			for (var i:int = 0; i < fList.length; i++) {
				
				Font.registerFont(fList[i]);

			}
			
			
			
			//lists can be registered but not retrieved on class name, and classes in library have no names
			//need a better lookup table
			if(_fontLookup[_name] == null){
				_fontLookup[_name] = new FontStyle(_name,_size);
			}
			var embeddedFonts:Array = Font.enumerateFonts(false);
			for (var ii:Number = 0; ii < embeddedFonts.length; ii++) {
				var item:Font = embeddedFonts[ii];
				if (item.fontName == _name) {
					_fontLookup[_name][item.fontStyle] = item;
				}
				Debug.output("FontManager font " + item.fontName )
			}		
	
			_fontList.push(_name )
		}
 
		public function getFontClass(id:String):Class {
			return _fontsDomain.getDefinition(id)  as  Class;
		}
 
		public function getFontById(id:uint, style:String = 'regular'):Font {
			var f:Font;
			try {
				f = _fontLookup[_fontList[id]][style];
			}
			catch (e:Error)	{
				try{
					f = _fontLookup[_fontList[id]]['regular'];
				}
				catch (e:Error)	{
					if (TFConfig.global.IS_LIVE) {
						Debug.output("FontManager does not have font id: " + id +" style: " + style);
						return new Font();
					}
				}
			}
			return f;
		}
		
		public function getFontByName(name:String,style:String='regular'):Font{
			var f:Font;
			try {
				f = _fontLookup[name][style];
			}
			catch (e:Error)	{
				try{
					f = _fontLookup[name]['regular'];
				}
				catch (e:Error)	{
					if (TFConfig.global.IS_LIVE) {
						Debug.output("FontManager does not have font name: " + name +" style: " + style);
					}
				}
			}
			return f;
		}
		public function get styleSheet():StyleSheet { return _styleSheet; }
		
		public function set styleSheet(value:StyleSheet):void 	{
			_styleSheet = value;
		}
		
		public function get fontList():Array { return _fontList; }
		
		public function get fontLookup():Object { return _fontLookup; }
		

	
	}
	
}