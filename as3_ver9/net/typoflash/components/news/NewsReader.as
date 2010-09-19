package net.typoflash.components.news {
	import flash.events.Event;
	import net.typoflash.base.Configurable;
	import net.typoflash.components.reader.AbstractReader;
	import net.typoflash.datastructures.TFNewsItem;
	import net.typoflash.events.RenderingEvent;
	import net.typoflash.events.GlueEvent;
	import net.typoflash.ContentRendering;
	import net.typoflash.utils.Debug;
	import net.typoflash.datastructures.TFRecordRequest;
	import net.typoflash.datastructures.TFLanguageObject;
	import flash.display.StageAlign;
	import net.typoflash.components.reader.ReaderType;
	import net.typoflash.events.ReaderEvent;
	
	/**
	 * ...
	 * @author A. Borg
	 */
	public class NewsReader extends AbstractReader{
		
		


	
		protected var _newsData:Array;//raw list from database

		
		


		
		public function NewsReader() {
			
			//addEventListener(Event.ADDED_TO_STAGE, addedToStage, false, 0, true);
			
			TF_GLUE.addEventListener(GlueEvent.ON_DATA, onGlueData);

			ContentRendering.addEventListener(RenderingEvent.ON_GET_NEWS, onGetNews);
			ContentRendering.addEventListener(RenderingEvent.ON_GET_NEWS_FROM_CATEGORY, onGetNewsFromCategories);		
		}
		
		

		
		/*protected function addedToStage(e:Event) {
			Debug.output("News reader addedToStage");

		}*/
		/*
		 * Here the initial category is selected. It can be set in typo3 as the media category,
		 * or in the browser address as category
		 */ 
		public function onGlueData(e:GlueEvent) {
			if (initCategoryId >-1) {
				listCategories = "tt_news_cat_" + initCategoryId;
				getNewsFromCategories();
			}else if (TF_GLUE.data.CONTENT.media_category) {
				listCategories = TF_GLUE.data.CONTENT.media_category;
				//if glue setting?
				getNewsFromCategories();
				
				//getNewsCategories()
			}
			Debug.output("News reader on data "+ TF_GLUE.data.CONTENT.media_category);
		}

		/*
		 * Can be called externally
		 * Requests ALL news items wi
		 */ 
		public function getNewsFromCategories() {
			if(_catUids.length>0){
				var req:TFRecordRequest = new TFRecordRequest();
				req.categories = _catUids.join(",");
				req.callback = name;
				req.no_cache = true;
				ContentRendering.getNewsFromCategories(req);	
				Debug.output("News reader on data " + _categories);
			}
		}
		
		
			
		
		
		
		
		
		
		public function onGetNews(e:RenderingEvent) {
			if(e.data.callback == name){
				Debug.output(["onGetNews ", e.data]);
				recordset = e.data;
				//pass on
				dispatchEvent(e);		
			}
		}


		
		
		
		public function onGetNewsFromCategories(e:RenderingEvent) {
			try{
				if(e.data.callback == name){
					Debug.output(["onGetNewsFromCategories ", e.data]);
					_newsData = e.data.result;
					recordset = localiseData(_newsData);
					if (initItemId >0) {
				
							var found = false;
							for each(var n in recordset) {
								if (n.uid == initItemId) {
									activeItem = n;
									found = true;
									continue;
								}
							}	
							if (!found) {
								Debug.output("NewsReader was looking for item: " + initItemId +" but did not find it in current recordset")
							}
							
							initItemId = -1;//will not be checked again
							
					}else if (activeItem == null && recordset.length>0) {
						activeItem = recordset[0];
					}
					//pass on mine
					dispatchEvent(e);		
				}
			}
			catch (e:Error)	{
				
			}

		}
		/*
		 * The categories currently displayed by the list
		 */ 
		public function get listCategories():String { return _categories; }
		
		/*
		 * Accepts both format "1,3,4" and "tt_news_cat_1,tt_news_cat_13"
		 */
		public function set listCategories(value:String):void {
			var cats:Array = value.split(",");
			_catUids = [];
			//extract uids from "tt_news_cat_1,tt_news_cat_13"
			for each ( var s:String in cats ) {  
				if(s.indexOf("tt_news_cat")>-1){
					_catUids.push(s.split("tt_news_cat_")[1]);
				}else {
					//splitting and putting back together 
					_catUids.push(s);
				}
			}  
			_categories = value;

		}
		

		/*
		 * Localise the data
		 */ 
		public function localiseData(value:Array):Array {
			var local = [];
			for each(var nestedItem:Object in value) {
				try {
					//the one to pass to the list, extracted current language
					local.push(new TFNewsItem(new TFLanguageObject(nestedItem).lang[TF_CONF.LANGUAGE]));
				}
				catch (e:Error){
					//fuck knows
				}
			}
			
			return local;
		}
		
	
		
	
		
		override public function destroy():void { 	
			ContentRendering.removeEventListener(RenderingEvent.ON_GET_NEWS, onGetNews);
			ContentRendering.removeEventListener(RenderingEvent.ON_GET_NEWS_FROM_CATEGORY, onGetNewsFromCategories);	
			_newsData = null;
			_categories = null;
			_catUids = null;
			super.destroy();
		}
	}
	
}