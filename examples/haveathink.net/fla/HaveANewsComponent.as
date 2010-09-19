package  {
	
	/**
	 * ...
	 * @author Borg
	 */

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import Error;
	import flash.text.TextField;
	
	import net.typoflash.components.news.NewsReader;
	import net.typoflash.components.news.NewsList;

	import net.typoflash.Glue;
	import net.typoflash.events.GlueEvent;
	import net.typoflash.datastructures.TFData;
	import net.typoflash.utils.Debug;
	import net.typoflash.base.ComponentBase;
	import net.typoflash.events.RenderingEvent;
	import net.typoflash.datastructures.TFNewsItem;
	import net.typoflash.components.reader.ReaderType;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import net.typoflash.datastructures.TFConfig;
	import flash.system.Security;
	import flash.geom.Point;
	import flash.text.Font;
	import flash.display.Loader;
	import flash.net.URLRequest
	import gs.*;
	import gs.easing.*;
	import net.typoflash.events.ReaderEvent;
	import flash.text.TextFormat;
	import flash.text.Font;
	import flash.system.ApplicationDomain;
	import flash.text.TextFieldAutoSize;	
	import flash.text.AntiAliasType;
	
	public class HaveANewsComponent extends MovieClip{
		public var TF_CONF:TFConfig  = TFConfig.global;
		public var newsReader:NewsReader;
		/*public var newsList:NewsList;*/
		public var subjectSelector:HaveACategorySelector;
		public var thinkerSelector:HaveACategorySelector;
		public var sourceSelector:HaveACategorySelector;
		public var formatSelector:HaveACategorySelector;
		public var locationSelector:HaveACategorySelector;
		public var killMouse:MovieClip;
		public var activeSelector:HaveACategorySelector;
		
		public var subjectBtn:MovieClip;
		public var thinkerBtn:MovieClip;
		public var sourceBtn:MovieClip;
		public var locationBtn:MovieClip;
		public var formatBtn:MovieClip;
		public var bg:Sprite;
		public var catSelector:CatHeader;
		public var activeFilterSkin:FilterActiveSkin
		public var activeCatBtn:*;
		
		public function HaveANewsComponent() 	{
			if(!TF_CONF.IS_LIVE){
				TF_CONF.HOST_URL = "http://localhost:801";
				stage.scaleMode = "noScale"
				stage.align = "TL"
				TF_CONF.FONT_MANAGER.init(ApplicationDomain.currentDomain);
				loadFont("_Georgia.swf");
				loadFont("_PWExtended.swf");
				loadFont("_FFFAquarius.swf");
			}	
			
			Security.allowDomain("*");	
			addEventListener(Event.REMOVED_FROM_STAGE, destroy, false, 0, true);
			
			
			bg = new Sprite();
			bg.graphics.beginFill (0xFFFFFF,1);
			bg.graphics.lineStyle (0, 0xFFFFFF, 1);
			bg.graphics.moveTo (0, 0);
			bg.graphics.lineTo (965, 0);
			bg.graphics.lineTo (965, 520);
			bg.graphics.lineTo (0, 520);
			bg.graphics.endFill();
			//bg.x= 5
			//bg.y = 5
			bg.useHandCursor = false;	
			addChild(bg);

			var btnMargin = 60;
			var btnH = 55;
			newsReader = new NewsReader();
			
			try {
				newsReader.colours = TF_CONF.LAYER["template"].colours;
				newsReader.textFormats = TF_CONF.LAYER["template"].textFormats;
			}
			catch (e:Error)	{
				newsReader.colours = [0x333333, 0x76CBCF,0x00000,0x999999];
			}
			
			
			catSelector = new CatHeader(newsReader);
			catSelector.x = 490;
			catSelector.y = 10;
			
			if (newsReader.textFormats[0]) {
				catSelector.titleTxt.embedFonts = true;
				catSelector.titleTxt.antiAliasType = AntiAliasType.ADVANCED;  
				catSelector.titleTxt.defaultTextFormat = newsReader.textFormats[0];	
					
			}	
			catSelector.titleTxt.text = "Featured";	
			addChild(catSelector);
			
			
			newsReader.addEventListener(ReaderEvent.ON_SET_ACTIVE_CATEGORY, onActiveCatetory);
			
			subjectBtn = new FilterButtonSkin();
			subjectBtn.buttonMode = true;
			subjectBtn.addEventListener(MouseEvent.CLICK, showSelector, false, 0, true);		
			subjectBtn.addEventListener(MouseEvent.MOUSE_OVER, centreActiveSkin, false, 0, true);	
			subjectBtn.addEventListener(MouseEvent.MOUSE_OUT, restoreActiveSkin, false, 0, true);	
			subjectBtn.mouseChildren = false;
			subjectBtn.x = 110;
			subjectBtn.y = btnH
			
			if (newsReader.textFormats[2]) {
				newsReader.textFormats[2].color = newsReader.colours[3];
				newsReader.textFormats[2].size = 8;
				//newsReader.textFormats[2].color = newsReader.colours[1];
				subjectBtn.label.embedFonts = true;
				subjectBtn.label.antiAliasType = AntiAliasType.ADVANCED;  
				subjectBtn.label.defaultTextFormat = newsReader.textFormats[2];	
			}		
			subjectBtn.label.text = "Subject";
			catSelector.addChild(subjectBtn);
			
			thinkerBtn = new FilterButtonSkin();
			thinkerBtn.buttonMode = true;
			thinkerBtn.mouseChildren = false;
			thinkerBtn.addEventListener(MouseEvent.CLICK, showSelector, false, 0, true);
			thinkerBtn.addEventListener(MouseEvent.MOUSE_OVER, centreActiveSkin, false, 0, true);
			thinkerBtn.addEventListener(MouseEvent.MOUSE_OUT, restoreActiveSkin, false, 0, true);
			thinkerBtn.x = subjectBtn.x + btnMargin;
			thinkerBtn.y = btnH;
			
			if (newsReader.textFormats[2]) {
				newsReader.textFormats[2].color = newsReader.colours[1];
				thinkerBtn.label.embedFonts = true;
				thinkerBtn.label.antiAliasType = AntiAliasType.ADVANCED; 
				thinkerBtn.label.defaultTextFormat = newsReader.textFormats[2];
			}		
			thinkerBtn.label.text = "Thinker";
			catSelector.addChild(thinkerBtn);

			sourceBtn = new FilterButtonSkin();
			sourceBtn.buttonMode = true;
			sourceBtn.mouseChildren = false;
			sourceBtn.addEventListener(MouseEvent.CLICK, showSelector, false, 0, true);
			sourceBtn.addEventListener(MouseEvent.MOUSE_OVER, centreActiveSkin, false, 0, true);
			sourceBtn.addEventListener(MouseEvent.MOUSE_OUT, restoreActiveSkin, false, 0, true);
			sourceBtn.x = thinkerBtn.x + btnMargin;
			sourceBtn.y = btnH;
			

			if (newsReader.textFormats[2]) {
				newsReader.textFormats[2].color = newsReader.colours[3];
				sourceBtn.label.embedFonts = true;
				sourceBtn.label.antiAliasType = AntiAliasType.ADVANCED; 
				sourceBtn.label.defaultTextFormat = newsReader.textFormats[2];
			}	
			sourceBtn.label.text = "Source";
			catSelector.addChild(sourceBtn);
			
			formatBtn = new FilterButtonSkin();
			formatBtn.buttonMode = true;
			formatBtn.mouseChildren = false;
			formatBtn.addEventListener(MouseEvent.CLICK, showSelector, false, 0, true);
			formatBtn.addEventListener(MouseEvent.MOUSE_OVER, centreActiveSkin, false, 0, true);
			formatBtn.addEventListener(MouseEvent.MOUSE_OUT, restoreActiveSkin, false, 0, true);
			formatBtn.x = sourceBtn.x + btnMargin;
			formatBtn.y = btnH;
			if (newsReader.textFormats[2]) {	
				formatBtn.label.embedFonts = true;
				formatBtn.label.antiAliasType = AntiAliasType.ADVANCED; 
				formatBtn.label.defaultTextFormat = newsReader.textFormats[2];
			}
			formatBtn.label.text = "Format";
			catSelector.addChild(formatBtn);
			
			
			locationBtn = new FilterButtonSkin();
			locationBtn.buttonMode = true;
			locationBtn.mouseChildren = false;
			locationBtn.addEventListener(MouseEvent.CLICK, showSelector, false, 0, true);
			locationBtn.addEventListener(MouseEvent.MOUSE_OVER, centreActiveSkin, false, 0, true);
			locationBtn.addEventListener(MouseEvent.MOUSE_OUT, restoreActiveSkin, false, 0, true);
			locationBtn.x = formatBtn.x + btnMargin;
			locationBtn.y = btnH;
			if (newsReader.textFormats[2]) {	
				locationBtn.label.embedFonts = true;
				locationBtn.label.antiAliasType = AntiAliasType.ADVANCED; 
				locationBtn.label.defaultTextFormat = newsReader.textFormats[2];
			}	
			locationBtn.label.text = "Location";			
			catSelector.addChild(locationBtn);
			
			
			activeFilterSkin = new FilterActiveSkin();
			activeFilterSkin.x = 0;
			activeFilterSkin .y = btnH
			catSelector.addChild(activeFilterSkin);
			
			TweenLite.to(activeFilterSkin, .3, { x:thinkerBtn.x } );
			
			newsReader.y = 10;	
			newsReader.renderDelay = 200;
			newsReader.recordsPerPage = 10;
			
			
			//newsReader.addEventListener(RenderingEvent.ON_GET_NEWS_FROM_CATEGORY, onGetNewsFromCategory);
			newsReader.addEventListener(ReaderEvent.ON_SET_RECORDSET, hideSelector);
			//addEventListener(Event.ADDED_TO_STAGE, onGadded,false,-200,true);
			//newsReader.TF_GLUE.addEventListener(GlueEvent.ON_DATA, onMyGlueData);
			//addEventListener(ReaderEvent.ON_RENDER_LIST_ITEM, onAddedNews,false,0,true);			
			
			newsReader.list = new NewsList(newsReader);
			
			newsReader.list.ListItemSkin = HaveAListItemSkin;
			newsReader.list.ListItemClass = HaveAListItem;
			newsReader.list.x = 490;
			newsReader.list.y = btnH + 32;;
			newsReader.list.itemMargin = 5;
			newsReader.list.itemPadding = 10;
			newsReader.list.nesting = ReaderType.NEST_NEW_IN_OLD;
			newsReader.list.renderStyle =  ReaderType.RENDER_SEQUENTIALLY_NO_ACTIVATION;
			//not adding list in newsReader necessarily
			newsReader.addChild(newsReader.list);
			var topoffset = -20
			
			subjectSelector = new HaveACategorySelector(newsReader);
			subjectSelector.ItemClasses = [HaveACategoryItem];
			subjectSelector.ItemSkins = [HaveANewsCatSelectorSkin];
			//var point:Point = new Point(subjectBtn.x, subjectBtn.y);
			//point = subjectBtn.parent.localToGlobal(point);			
			subjectSelector.x = subjectBtn.x+catSelector.x;
			//subjectSelector.y = subjectBtn.y+subjectBtn.height+topoffset;
			subjectSelector.rootCategory = "tt_news_cat_38";
			subjectSelector.getNewsCategories();
			subjectBtn.selector = subjectSelector;
			
			thinkerSelector = new HaveACategorySelector(newsReader);
			thinkerSelector.ItemClasses = [HaveACategoryItem];
			thinkerSelector.ItemSkins = [HaveANewsCatSelectorSkin];
			//point = new Point(thinkerBtn.x, thinkerBtn.y);
			//point = thinkerBtn.parent.localToGlobal(point);
			thinkerSelector.x = thinkerBtn.x+catSelector.x;
			//thinkerSelector.y = thinkerBtn.y+thinkerBtn.height+topoffset;
			thinkerSelector.rootCategory = "tt_news_cat_39";
			thinkerSelector.getNewsCategories();
			thinkerBtn.selector = thinkerSelector;	
			
			sourceSelector = new HaveACategorySelector(newsReader);
			sourceSelector.ItemClasses = [HaveACategoryItem];
			sourceSelector.ItemSkins = [HaveANewsCatSelectorSkin];
			sourceSelector.x = sourceBtn.x+catSelector.x;;
			//sourceSelector.y = sourceBtn.y+sourceBtn.height+topoffset;
			sourceSelector.rootCategory = "tt_news_cat_20";
			sourceSelector.getNewsCategories();
			sourceBtn.selector = sourceSelector;	
			
			formatSelector = new HaveACategorySelector(newsReader);
			formatSelector.ItemClasses = [HaveACategoryItem];
			formatSelector.ItemSkins = [HaveANewsCatSelectorSkin];
			formatSelector.x = formatBtn.x+catSelector.x;;
			//formatSelector.y = formatBtn.y+formatBtn.height+topoffset;
			formatSelector.rootCategory = "tt_news_cat_14";
			formatSelector.getNewsCategories();		
			formatBtn.selector = formatSelector;
			
			locationSelector = new HaveACategorySelector(newsReader);
			locationSelector.ItemClasses = [HaveACategoryItem];
			locationSelector.ItemSkins = [HaveANewsCatSelectorSkin];
			locationSelector.x = locationBtn.x+catSelector.x;;
			//locationSelector.y = locationBtn.y+locationBtn.height+topoffset;
			locationSelector.rootCategory = "tt_news_cat_7";
			locationSelector.getNewsCategories();
			locationBtn.selector = locationSelector;	
			

			
			newsReader.item = new HaveANewsItem(newsReader);
			newsReader.item.skin = new HaveANewsItemSkin();
			newsReader.item.setDefaultTextFormat();
			newsReader.item.skin.titleTxt.text = "Loading...";
			newsReader.item.padding = 10;
			newsReader.item.x = 10;
			//newsReader.item.visible = false;
			newsReader.addChild(newsReader.item);
			
			if (!TF_CONF.IS_LIVE) {
				//I am faking TF configuration for this component since it is fixed as a template object
				newsReader.listCategories = "tt_news_cat_31";
				newsReader.getNewsFromCategories();
			}
			addChild(newsReader);

			//loadFont(TF_CONF.HOST_PATH + "_Palatino.swf");
		}
		private function onGadded(e:Event) {
			//TF_GLUE.key
	
		}	
		public function registerFonts(_name = 'Arial', _fontClasses = null, _size = 10) {
			TF_CONF.FONT_MANAGER.registerFonts(_name, _fontClasses, _size)
			/*var font = Font.enumerateFonts(false)[0];
			var tf:TextField = new TextField();  
			tf.defaultTextFormat = new TextFormat( font.fontName, 14, 0);  
			tf.embedFonts = true;  
			// tf.antiAliasType = AntiAliasType.ADVANCED;  
			tf.autoSize = TextFieldAutoSize.LEFT;  
			tf.border = true;  
			tf.text = "Font embedded in sub";  
			tf.x = 250
			tf.y = 250
			tf.rotation = 15;  
			addChild(tf);  */
		}
        private function loadFont(url:String):void {
			  trace("loadFont "+ url )
               var loader:Loader = new Loader();
             //  loader.contentLoaderInfo.addEventListener(Event.COMPLETE, fontLoaded);
               loader.load(new URLRequest(url));
			   addChild(loader);
          }

         private function fontLoaded(event:Event):void {
              // var FontLibrary:Class = event.target.applicationDomain.getDefinition("_Palatino") as Class;
			   // Debug.output("loadFont "+ url )
              // Font.registerFont(FontLibrary);
         
          }
		
		private function centreActiveSkin(e:MouseEvent) {
			TweenLite.killTweensOf(activeFilterSkin);
			TweenLite.to(activeFilterSkin, .3, { x:e.target.x } );
		}
		private function restoreActiveSkin(e:*=null) {
			if(killMouse == null){
				if (activeCatBtn) {
					TweenLite.killTweensOf(activeFilterSkin);
					TweenLite.to(activeFilterSkin, .9, { x:activeCatBtn.x } );
				}else {
					TweenLite.killTweensOf(activeFilterSkin);
					TweenLite.to(activeFilterSkin, .9, { x:thinkerBtn.x } );				
				}
			}
		}		 
		private function onActiveCatetory(e:ReaderEvent){
			
			var v = catSelector.numChildren;
			while (v--) {
				if (catSelector.getChildAt(v) is FilterButtonSkin) {
					if (MovieClip(catSelector.getChildAt(v)).selector.rootCategory == "tt_news_cat_" + e.data.parent_category) {
						activeCatBtn = catSelector.getChildAt(v);	
						TweenLite.killTweensOf(activeFilterSkin);
						TweenLite.to(activeFilterSkin, .3, { x:activeCatBtn.x } );
						if (newsReader.textFormats[2]) {
							newsReader.textFormats[2].color = newsReader.colours[1];
							activeCatBtn.label.setTextFormat(newsReader.textFormats[2]);		
						}	
					}else {
						if (newsReader.textFormats[2]) {
							newsReader.textFormats[2].color = newsReader.colours[3];
							MovieClip(catSelector.getChildAt(v)).label.setTextFormat(newsReader.textFormats[2]);		
						}	
					}
				}
				
			}
		}
		private function showSelector(e:Event) {
			onFadeOut();
			if (activeSelector) {
				try{
				TF_CONF.LAYER["template"].removeChild(activeSelector);
				}catch (e:Error)
				{
					removeChild(activeSelector);
				}
			}
			killMouse = new MovieClip();

			killMouse.graphics.beginFill (0x000000,.3);
			killMouse.graphics.lineStyle (0, 0xFF00FF, 0);
			killMouse.graphics.moveTo (0, 0);
			killMouse.graphics.lineTo (stage.stageWidth, 0);
			killMouse.graphics.lineTo (stage.stageWidth, stage.stageHeight);
			killMouse.graphics.lineTo (0, stage.stageHeight);
			killMouse.graphics.endFill();
			killMouse.useHandCursor = false;		
				
			killMouse.selector = e.target.selector;
			killMouse.alpha = 0;
			killMouse.mouseEnabled = true;	
			TweenLite.to(activeFilterSkin, .3, { x:e.target.x } );
			activeSelector = e.target.selector;
			try{
				TF_CONF.LAYER["template"].addChild(killMouse);
				TF_CONF.LAYER["template"].addChild(activeSelector);
			}catch (e:Error)
			{
				addChild(killMouse);
				addChild(activeSelector);
			}

			TweenLite.to(killMouse, .3, { alpha:1 } );
			var p = new Point(e.target.x, e.target.y);
			p = Sprite(e.target.parent).localToGlobal(p);
			var fy = 0;
			activeSelector.height = stage.stageHeight - fy;
			activeSelector.y = - activeSelector.height;
			activeSelector.x = p.x;
			TweenLite.to(activeSelector, .3, { y:fy, ease:Linear.easeOut, onComplete:activateKillMouse} );
			
			
		}
		private function activateKillMouse() {
			killMouse.addEventListener(MouseEvent.ROLL_OVER, hideSelector, false, 0, true);	
		}
		private function hideSelector(e:Event) {
			//&& !catSelector.hitTestPoint(mouseX,mouseY)
			if(activeSelector ){
				try{
					TF_CONF.LAYER["template"].removeChild(activeSelector);
				}
				catch (e:Error){
					removeChild(activeSelector);
				}
				activeSelector = null;
				killMouse.mouseEnabled = false;	
				
				TweenLite.to(killMouse, .3, { alpha:0, ease:Linear.easeOut, onComplete:onFadeOut} );
			}
		}		
		
		private function onFadeOut() {
			if(killMouse){
				TweenLite.killTweensOf(killMouse)
				try{
				TF_CONF.LAYER["template"].removeChild(killMouse);
				}
				catch (e:Error)
				{
					removeChild(killMouse);
				}
				killMouse = null;
				restoreActiveSkin()
			}
	
			
		}
		/*private function onGetNewsFromCategory(e:RenderingEvent) {
			//set first one active if none is
			var initItem = newsReader.TF_GLUE.getQueryParameter("item");
			if (initItem) {
				ContentRe
			}else if (newsReader.activeItem == null && newsReader.recordset.length>0) {
				newsReader.activeItem = newsReader.recordset[0];
			}
			var str = txt.text;
			str += "onGetNewsFromCategory \n";			
			for (var n in newsReader.recordset) {
				str += TFNewsItem(newsReader.recordset[n]).title + "\n";
			}
			txt.text = str;
		}
		*/
		private function onMyGlueData(e:GlueEvent) {
			//txt.text = "added? " + newsReader.TF_GLUE.toString();
			/*var str = txt.text;

			str += "onMyGlueData " +TFData(e.data).CONTENT.name;
			for (var n in TFData(e.data).CONTENT) {
				str += n + TFData(e.data).CONTENT[n] + "\n";
			}
			
			 * inside NewsReader already
			if(TFData(e.data).CONTENT.media_category){
				//categories = TFData(e.data).CONTENT.media_category;
				//getNewsFromCategories();
				str += TFData(e.data).CONTENT.media_category+ "\n";
			}
			txt.text = str;*/
			//Debug.output(e.data);
		}
		
		private function destroy(e:Event) {
			subjectSelector = null;
			newsReader = null;
			hideSelector(e);
		}

	}
	
}