package net.typoflash.components.mediagallery {
	
	/**
	 * Since media_category in Glue can contain all sorts of categories, eg. tt_news_cat it needs tob e retrieved here
	 * not in Glue
	 * ...
	 * @author A. Borg
	 */
	import net.typoflash.components.reader.AbstractReader;
	import net.typoflash.datastructures.TFMediaItem;
	import net.typoflash.events.GlueEvent;
	import net.typoflash.events.RenderingEvent;
	import net.typoflash.datastructures.TFLanguageObject;
	import net.typoflash.utils.Debug;
	import net.typoflash.ContentRendering;
	import net.typoflash.datastructures.TFMediaCategory;
	import net.typoflash.datastructures.TFMediaItem;
	import net.typoflash.datastructures.TFMenuRequest;
	
	public class MediaGallery extends AbstractReader{
		protected var _rawFlatlist:Array;//raw list from database
		public var localisedRootCategory:TFMediaCategory;
		public var flatlist:Array;//list on {data:categoryItem,level:depth}
		public var lookup:Object;//list on uid {data:categoryItem,level:depth}
		
		public function MediaGallery() {
			flatlist = [];
			lookup = { };
			TF_GLUE.addEventListener(GlueEvent.ON_DATA, onGlueData);
			ContentRendering.addEventListener(RenderingEvent.ON_GET_MEDIA, onGetMedia);		
			ContentRendering.addEventListener(RenderingEvent.ON_GET_MEDIA_FROM_CATEGORY, onGetMediaFromCategory);
			
	
		}
		/*
		 * Here the initial category is selected. It can be set in typo3 as the media category,
		 * or in the browser address as category
		 */ 
		protected function onGlueData(e:GlueEvent) {
			Debug.output("Mediagallery initid " + initItemId)
			/*if (initCategoryId >-1) {
			 * //this returns a subcategory as root category...not correct logic
				listCategories = "tx_dam_cat_" + initCategoryId;
				getMediaFromCategories()
			}else */
			if (TF_GLUE.data.CONTENT.media_category) {
				listCategories = TF_GLUE.data.CONTENT.media_category;
				getMediaFromCategories()
			}
			

			
			if (TF_GLUE.data.CONTENT.media) {
				var mr = new TFMenuRequest(TF_GLUE.key);
				mr.media = TF_GLUE.data.CONTENT.media;
				ContentRendering.getMedia(mr);
			}
			
			Debug.output("MediaGallery on data "+ TF_GLUE.data.CONTENT.media_category);
		}	
		
		
		public function getMediaFromCategories() {
			var mr:TFMenuRequest = new TFMenuRequest(TF_GLUE.key);
			mr.media_category = listCategories;
			mr.returnTree = true;
			ContentRendering.getMediaFromCategory(mr);
			Debug.output("getMediaFromCategories "+listCategories)
		}
		
		protected function onGetMediaFromCategory(e:RenderingEvent) {
			Debug.output(["onGetMediaFromCategories some response ",e.data]);
			try{
				if(e.data.result.menuId == TF_GLUE.key){
					//Debug.output(["onGetMediaFromCategories 0 ", e.data]);
					_rawFlatlist = e.data.result.flatlist;
					recordset = localiseFlatlist(_rawFlatlist);
					var catlist = [];//convert object to array
					for each (var nn in e.data.result.categories) {
						catlist.push(nn);
						
					}
					//what if more than one category?
					if(catlist.length>0){
						localisedRootCategory = localiseCategoryTree(catlist[0], 0)
						Debug.output("Setting localisedRootCategory in onGetMediaFromCategory "+ localisedRootCategory.uid)
					}

					
					if (initCategoryId > 0) {
						try{
							activeCategory =lookup[initCategoryId]
						}	
						catch (e:Error){
								
							Debug.output("MediaGallery was looking for initCategoryId: " + initCategoryId +" but did not find it in current recordset")
								//Debug.output(recordset);
						}
							
						initCategoryId = -1;//will not be checked again
							
					}		
					
					
					if (initItemId >0) {
				
							var found = false;
							var v = recordset.length;
							while(v-- && !found){
							//for each(var n in recordset) {
							//	if (n.uid == queryItem) {
							//		activeItem = n;
								if (recordset[v].uid == initItemId) {
									activeItemId = v;
									found = true;
								}
							}
							if (!found) {
								Debug.output("MediaGallery was looking for item: " + initItemId +" but did not find it in current recordset")
								//Debug.output(recordset);
							}
							
							initItemId = -1;//will not be checked again
							
					}else if (activeItem == null && recordset.length>0) {
						activeItem = recordset[0];
					}
					
					if (activeCategory == null && activeItem) {
						//if not found 
						trace(TFMediaItem(activeItem).category +"  " +TFMediaItem(activeItem))
						//activeCategory = lookup[TFMediaItem(activeItem).category.split(",")[0]]
					}	
					
					//pass on mine
					dispatchEvent(e);		
					//render();
				}
			}
			catch (e:Error)	{
				Debug.output("onGetMediaFromCategory "+e);
			}
		}		
		/*
		 * e.data=
		 * media,[object Object],[object Object]
			menuId,carousel
			callback,
		 * */

        protected function onGetMedia(e:RenderingEvent) {
			
		
			
			try{
				Debug.output("onGetMedia "+e.data)
				if(e.data.menuId != TF_GLUE.key){
					return;
				}
				recordset = localiseFlatlist(e.data.media);
				dispatchEvent(e);		
			}
			catch (e:Error){
				Debug.output("onGetMedia error "+e)
			}
			//render();
			//dispatchEvent(new RenderingEvent(RenderingEvent.ON_GET_MEDIA, e.data.result));
        };	
		
		
		/*
		 * The categories currently displayed by the list
		 */ 
		public function get listCategories():String { return _categories; }
		
		/*
		 * Accepts both format "1,3,4" and "tx_dam_cat_1,tx_dam_cat_13"
		 */
		public function set listCategories(value:String):void {
			var cats:Array = value.split(",");
			_catUids = [];
			//extract uids from "tt_news_cat_1,tt_news_cat_13"
			for each ( var s:String in cats ) {  
				if(s.indexOf("tx_dam_cat")>-1){
					_catUids.push(s.split("tx_dam_cat_")[1]);
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
		public function localiseFlatlist(value:Array=null):Array {
			var local = [];
			for each(var nestedItem:Object in value) {
				try {
					//the one to pass to the list, extracted current language
					var n = local.push(new TFMediaItem(new TFLanguageObject(nestedItem).lang[TF_CONF.LANGUAGE]));
							}
				catch (e:Error){
					//fuck knows
					Debug.output("MediaGallery.localiseFlatlist error "+e);
				}
			}
			
			return local;
		}
		
		public function localiseCategoryTree(value, level:int = -1) {
			try{
			var cat:TFMediaCategory = new TFMediaCategory(new TFLanguageObject(value).lang[TF_CONF.LANGUAGE]);
			
			
			cat.SUBCATEGORIES = [];
			if (value.subcat) {
				for each(var n in value.subcat){
					cat.SUBCATEGORIES.push(localiseCategoryTree(n,(level+1)));
				}
			}
			cat.ITEMS = localiseFlatlist(value.items);
			//make a flat list that both contains the item and the depth of nesting. Needed for sequential rendering.
			if (level >= 0) {
				flatlist.push( { data:cat, level:level })
				
			}
			lookup[cat.uid] = cat;
			
			//Debug.output("localiseCategoryTree catlist "+cat.title +" sub: " +cat.subtitle+ " desc: "+cat.description + " items: " + cat.ITEMS +  " subcat: " + cat.SUBCATEGORIES)
			
			}
			catch (e:Error)
			{
				trace("localiseCategoryTree " +e);
			}
			return cat;
			
		}	
	
		
		
		
		
		override public function destroy():void { 	
			Debug.output("MediaGallery destroyed")
			ContentRendering.removeEventListener(RenderingEvent.ON_GET_MEDIA, onGetMedia);
			ContentRendering.removeEventListener(RenderingEvent.ON_GET_MEDIA_FROM_CATEGORY, onGetMediaFromCategory);	
			_categories = null;
			_catUids = null;
			super.destroy();
		}
	}
	
}