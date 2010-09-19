package net.typoflash.components.mediagallery 
{
	import net.typoflash.components.reader.AbstractCategorySelector;
	import net.typoflash.ContentRendering;
	import net.typoflash.events.RenderingEvent;
	import net.typoflash.utils.Debug;
	import net.typoflash.datastructures.TFRecordRequest;
	import net.typoflash.datastructures.TFLanguageObject;
	import net.typoflash.datastructures.TFMediaCategory;
	import net.typoflash.datastructures.TFMediaItem;
	import net.typoflash.datastructures.TFMenuRequest;
	/**
	 * ...
	 * @author A. Borg
	 */
	public class MediaCategorySelector extends AbstractCategorySelector{
		protected var _categoryData:Object;//raw list from database
		protected var _nestedData:Object;//
		public var mediaFlatlist:Array;//all news item in this list
	
		public function MediaCategorySelector(_reader){
			super(_reader);
			//parent sorted categories already
			_reader.addEventListener(RenderingEvent.ON_GET_MEDIA_FROM_CATEGORY, onGetMediaCategories);		
		}

		
		public function onGetMediaCategories(e:RenderingEvent) {
			//maybe need to check	
			_categoryData = MediaGallery(reader).localisedRootCategory;
			render();
			
		}
		
		
		/*
		 * Can be called externally. Just set rootCategory first
		 * This assumes you are requesting the sub categories of ONE category
		 * with uid
		 
		public function getMediaCategories() {
			if(_rootCategory > 0){
				var mr:TFMenuRequest = new TFMenuRequest(reader.TF_GLUE.key);
				mr.media_category = _rootCategory;
				mr.returnTree = true;
				ContentRendering.getMediaFromCategory(mr);		
				
			}else {
				mr = new TFMenuRequest(reader.TF_GLUE.key);
				mr.returnTree = true;
				ContentRendering.getMediaFromCategory(mr);		
			}
		}*/ 	
		/*
		 * "tx_dam_cat_132"
		 */ 
		override public function set rootCategory(value:String):void {
			if(value.indexOf("tx_dam_cat")>-1){
				_rootUid = value.split("tx_dam_cat_")[1];
			}
			_rootCategory = value;	
		}
		
		public function get categoryData():Object { return _categoryData; }
		public function set categoryData(d:Object) { _categoryData=d }
		
	}
	
}