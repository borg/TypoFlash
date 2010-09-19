package net.typoflash.components.news 
{
	import net.typoflash.components.reader.AbstractCategorySelector;
	import net.typoflash.ContentRendering;
	import net.typoflash.events.RenderingEvent;
	import net.typoflash.utils.Debug;
	import net.typoflash.datastructures.TFRecordRequest;
	import net.typoflash.datastructures.TFLanguageObject;
	import net.typoflash.datastructures.TFNewsCategory;
	import net.typoflash.datastructures.TFNewsItem;
	/**
	 * ...
	 * @author A. Borg
	 */
	public class NewsCategorySelector extends AbstractCategorySelector{
		protected var _categoryData:Object;//raw list from database
		protected var _nestedData:Object;//
		public var newsFlatlist:Array;//all news item in this list
	
		public function NewsCategorySelector(_reader){
			super(_reader);
			ContentRendering.addEventListener(RenderingEvent.ON_GET_NEWS_CATEGORIES, onGetNewsCategories);		
		}

		
		public function onGetNewsCategories(e:RenderingEvent) {
			if(e.data.callback == name){
				_categoryData = e.data.result;
				/*
				 * root [object Object]
				 * menuId null
				 * flatlist [object Object],[object Object],[object Object]
				 */

				newsFlatlist = localiseFlatlist(e.data.result.flatlist);
				
				
				_nestedData = _categoryData.root;
				/*
				 * lang [object Object],[object Object]
				 * subcat [object Object],[object Object],[object Object]
				 * items 
				 */
				
				localRootCategory = localiseCategoryTree(_nestedData);
				reader.addCategories(lookup);
				Debug.output(["onGetNewsCategories ", localRootCategory]);
				render();
			}
		}
		
		
		/*
		 * Can be called externally. Just set rootCategory first
		 * This assumes you are requesting the sub categories of ONE category
		 * with uid
		 */ 
		public function getNewsCategories() {
			if(_rootUid > 0){
				var req:TFRecordRequest = new TFRecordRequest();
				req.uid = _rootUid;
				req.callback = name;
				req.no_cache = true;
				ContentRendering.getNewsCategories(req);	
			}else {
				req = new TFRecordRequest();
				req.callback = name;
				req.no_cache = true;
				ContentRendering.getNewsCategories(req);
				Debug.output("News reader category selector getting ALL getNewsCategories");
			}
		}	
		/*
		 * "tt_news_cat_132"
		 */ 
		override public function set rootCategory(value:String):void {
			if(value.indexOf("tt_news_cat")>-1){
				_rootUid = value.split("tt_news_cat_")[1];
			}
			_rootCategory = value;	
		}

		/*
		 * Localise the data
		 */ 
		public function localiseFlatlist(value:Array=null):Array {
			var local = [];
			for each(var nestedItem:Object in value) {
				try {
					//the one to pass to the list, extracted current language
					local.push(new TFNewsItem(new TFLanguageObject(nestedItem).lang[TF_CONF.LANGUAGE]));
				}
				catch (e:Error){
					//fuck knows
					trace(e);
				}
			}
			
			return local;
		}
		
		public function localiseCategoryTree(value,level:int = -1):TFNewsCategory {
			var cat:TFNewsCategory = new TFNewsCategory(new TFLanguageObject(value).lang[TF_CONF.LANGUAGE]);
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
			return cat;
		}			
	}
	
}