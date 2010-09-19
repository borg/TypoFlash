package net.typoflash.components.reader {

	
	/**
	 * A AbstractReader is an abstract control class with many records from which you display a current set depending on
	 * offset. 
	 * 
	 * It is event driven so you extend with relevant display classes with listeners and only call function 
	 * on the reader
	 * 
	 * By default the spirit of this renderer is animated. Funny as it sounds, it means things
	 * do not all appear at once, but animate in.
	 * 
	 * 
	 * 
	 * @author A. Borg
	 */
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextFormat;
	import net.typoflash.base.ComponentBase;
	import net.typoflash.base.Configurable;
	import net.typoflash.datastructures.TFCategory;
	import net.typoflash.events.RenderingEvent;
	import net.typoflash.events.ReaderEvent;
	import flash.display.StageAlign;
	import net.typoflash.components.reader.ReaderType;
	
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import net.typoflash.utils.Debug;
	
	public class AbstractReader extends ComponentBase{
		//protected var _offset:int = 0;
		protected var _currPage:int = 0;
		protected var _activeItemId:int = 0;//id from recordset on active item
		
		/*
		 * how many records can be held in total. For some lists that have no natural limit this is 
		 * the cut off point, else they get obese
		 */ 
		protected var _maxTotalRecords:int = 100;
		protected var _recordsPerPage:int = 10;
		protected var _recordset:Array;

		protected var _categories:String;//if used as a component comes from TF_GLUE.data.CONTENT.media_category
		protected var _catUids:Array;

		protected var _activeItem:*;//list or news item	
		protected var _activeCategory:*;//selected category	
		protected var _categoryLookup:Object;//lookup table of all categories retrieved
		
		
		protected var _renderDelay:int = 100;//for sequntial render
			
		public var renderingTimer:Timer;	
		

		public var item:AbstractItem;
		public var initItemId:int=-1;//from query string
		public var initCategoryId:int=-1;//from query string, careful with setting it to int as a null value will be cast a 0
		public var list:AbstractList;
		public var searchBox:AbstractSearchBox;
		
		public var textFormats:Array;
		public var colours:Array;//define pallette and use as you wish
		
		
		//public var categorySelector:AbstractCategorySelector;	
		
		
		/*
		 * Style and extend functionality by setting these
		 

		//Detail view of active item if used separately to the list view
		public var ItemClass:Class = AbstractItem;
		public var ItemSkin:Class;
		
	
		//public var CategorySelectorClass:Class = AbstractCategorySelector;
		//public var CategorySelectorSkin:Class;		
		public var SearchBoxClass:Class = AbstractSearchBox;
		public var SearchBoxSkin:Class;		
		*/ 
		
		
		
		public function AbstractReader() {
			textFormats = [];
			colours = [];
			_catUids = [];
			_recordset = [];
			_categoryLookup = {};
			renderDelay = _renderDelay;
			addEventListener(ReaderEvent.RENDERING_IMPULSE, onRenderingImpulse, false, 0, true);
			//first run, make sure null values aren't converted to 0
			if(TF_GLUE.getQueryParameter("item")){
				initItemId = TF_GLUE.getQueryParameter("item");
			}
			if( TF_GLUE.getQueryParameter("category")){
				initCategoryId = TF_GLUE.getQueryParameter("category");
			}
			Debug.output("AbstractReader initItemId " + initItemId + " initCategoryId " + initCategoryId)
			
			try{
				for (var i = 0;i < TF_CONF.FONT_MANAGER.fontList.length; i++) {
					textFormats.push(new TextFormat( TF_CONF.FONT_MANAGER.getFontById(i).fontName, 12, 0));
				}
			}
			catch (e:Error) {}

		}
		
		private function dispatchRenderingImpulse(e:TimerEvent) {
			dispatchEvent(new ReaderEvent(ReaderEvent.RENDERING_IMPULSE));
		}
		
		
		public function render(start:int = -1, length:int = -1, allAtOnce:Boolean = false ) {
			if(list){
				//list.data = recordset.slice(_currPage * recordsPerPage, _currPage * recordsPerPage + recordsPerPage);
				if ((list.renderStyle == ReaderType.RENDER_SEQUENTIALLY || list.renderStyle == ReaderType.RENDER_SEQUENTIALLY_NO_ACTIVATION)&& !allAtOnce) {
					nextItem()
					startTimer();
				}else if(list.renderStyle == ReaderType.RENDER_ALL_AT_ONCE || allAtOnce){
					if (list) {
						list.clear();
						list.render(start,length);
					}	
				}
			}
			//Debug.output("AbstractReader.render recordset length " + recordset.length )
			//caregorySelector.render();
		}
		
		protected function onRenderingImpulse(e:ReaderEvent) {
			nextItem();
		}
		
		public function nextItem() {
			try{
			if (list.lastListItemId<_recordset.length-1) {
				dispatchEvent(new ReaderEvent(ReaderEvent.ON_NEXT_ITEM));
				/*if (list.lastListItemId == _recordset.length - ) {
					dispatchEvent(new ReaderEvent(ReaderEvent.ON_LAST_ITEM));
				}*/
			}
			}
			catch (e:Error){
				Debug.output("AbstractReader.nextItem error. Is there a lastListItemId? Stopping timer");
				stopTimer();
			}
		}
		
		public function previousItem() {
			//trace(["previousItem",list.firstListItemId,list.lastListItemId])
			if (list.firstListItemId>0) {
				dispatchEvent(new ReaderEvent(ReaderEvent.ON_PREVIOUS_ITEM));
				
			}			
		}	
		
		public function nextPage() {
			//todo
			if (_recordset.length>0) {
				dispatchEvent(new ReaderEvent(ReaderEvent.ON_NEXT_PAGE));
			}
		}
		
		public function previousPage() {
			dispatchEvent(new ReaderEvent(ReaderEvent.ON_PREVIOUS_PAGE));
		}	
		
		public function get currentPage():uint { return _currPage; }
		
		public function set currentPage(value:uint):void {
			_currPage = value;
		}
		/*
		public function get offset():int { return _offset; }
		
		public function set offset(value:int):void {
			_offset = value;
		}	
		*/
		public function get recordset():Array { return _recordset; }
		
		public function set recordset(value:Array):void {
			_recordset = value;
			_currPage = 0;
			
			dispatchEvent(new ReaderEvent(ReaderEvent.ON_SET_RECORDSET));
			render()
		}
		
		public function get maxTotalRecords():int { return _maxTotalRecords; }
		
		public function set maxTotalRecords(value:int):void {
			_maxTotalRecords = value;
		}
		
		public function get recordsPerPage():int { return _recordsPerPage; }
		
		public function set recordsPerPage(value:int):void {
			_recordsPerPage = value;
		}
		public function addItem(_item:*) {
			dispatchEvent(new ReaderEvent(ReaderEvent.ON_ADD_ITEM));
			_recordset.push(_item);
		}
		public function addItemAt(_item:*, _id:uint) {
			dispatchEvent(new ReaderEvent(ReaderEvent.ON_ADD_ITEM));	
		}
		
		public function get activeItem():* { return _activeItem; }
		
		public function set activeItem(value:*):void {
			_activeItem = value;
			dispatchEvent(new ReaderEvent(ReaderEvent.ON_SET_ACTIVE_ITEM, value));
			if (!TF_CONF.HISTORY_ENABLED) {
				return;
			}
			if(value){
				if(_activeCategory){
					TF_GLUE.setQueryParameters( { "item": value.uid, "category": _activeCategory.uid } );
				//}else if(value.category){
				//does not contain uids!!
				//	TF_GLUE.setQueryParameters( { "item": value.uid, "category": value.category.split(",")[0] } );
				}else {
					TF_GLUE.setQueryParameters( { "item": value.uid } );
				}
			}else{
				//null
				TF_GLUE.setQueryParameters({ "item":""} );
			}

		}	
		
		public function get activeCategory():TFCategory { return _activeCategory; }
		
		public function set activeCategory(value:TFCategory):void {
			_activeCategory = value;
			recordset = value.ITEMS;
			dispatchEvent(new ReaderEvent(ReaderEvent.ON_SET_ACTIVE_CATEGORY, value));
			
			//should only be set on active item me thinks, else weird confusion will ensue
			//TF_GLUE.setQueryParameter("category", value.uid);
		}
		
		override protected function onPageState(e:RenderingEvent) {

			try{
				var queryCategory = TF_GLUE.getQueryParameter("category");
				
				if (_activeCategory.uid != queryCategory) {
					var found = false;
					for each(var c in _categoryLookup) {
						if (c.uid == queryCategory) {
							activeCategory = c;
							found = true;
							continue;
						}
					}
					if (!found) {
						if(queryCategory>0){
							Debug.output("Abstract reader should retrieve category " + queryCategory)
						}
					}
				}
			}
			catch (e:Error) { }
			try{
				var queryItem = TF_GLUE.getQueryParameter("item");
				if (_activeItem.uid != queryItem) {
				
				var v = recordset.length;
				while(v--){
				//for each(var n in recordset) {
				//	if (n.uid == queryItem) {
				//		activeItem = n;
					if (recordset[v].uid == queryItem) {
						activeItemId = v;
						v = 0;
					}
				}
				if(queryItem >0){
					Debug.output("Abstract reader should retrieve item " + queryItem)
				}
				}	
			}
			catch (e:Error) { }
		}

		
		public function get renderDelay():int { return _renderDelay; }
		
		public function set renderDelay(value:int):void {
			if(renderingTimer == null){
				renderingTimer = new Timer(value,0);
				renderingTimer.addEventListener(TimerEvent.TIMER, dispatchRenderingImpulse, false, 0, true);
			}else {
				renderingTimer.delay = value;
			}
			_renderDelay = value;
		}
		
		public function startTimer() {
			if (!renderingTimer.running) {
				renderingTimer.start();
				dispatchEvent(new ReaderEvent(ReaderEvent.ON_START_TIMER)) ;
			}	
		}
		public function stopTimer() {
			if (renderingTimer.running) {
				renderingTimer.stop();
				dispatchEvent(new ReaderEvent(ReaderEvent.ON_STOP_TIMER)) ;
			}	
		}	
		public function get activeItemId():int { return _activeItemId; }
		
		/*
		 * Id from recordset, not uid
		 */ 
		public function set activeItemId(value:int):void 
		{
			_activeItemId = value;
			//updated for Quintin
			try{
				activeItem = recordset[_activeItemId];
				trace("AbstractReader activeItem via activeItemId "+ activeItem)
			}
			catch (e:Error){
				Debug.output("AbstractReader.activeItemId error. Recordset probably not loaded yet, or old instgance not garbage collected.")
			}
		}
		/*
		 * The index of the category flatlist should be the uid from database, and the
		 * value whatever object describes the category in the current language
		 */ 
		public function get categoryLookup():Object { return _categoryLookup; }
		
		public function set categoryLookup(value:Object):void 
		{
			_categoryLookup = value;
		}
		/*
		 * The index of the category flatlist should be the uid from database, and the
		 * value whatever object describes the category in the current language
		 */ 
		public function addCategories(c:Object) {
			if (_categoryLookup == null) {
				_categoryLookup = { };
			}
			for(var n in c){
				_categoryLookup[n] = c[n];
			}
			
		}
		/*
		 * In sequential rendering this function will render the next item in the current
		 * set of items due to be displayed.
		 */ 
		public function renderNextListItem() {
			
		}
		/*
		 * Call any page, ie. offset
		 */ 
		public function renderPage(id:int) {
			
		}		
		
		override public function destroy():void { 
			if(renderingTimer){
				renderingTimer.removeEventListener(TimerEvent.TIMER, dispatchRenderingImpulse);
				renderingTimer.stop();
				renderingTimer = null;
			}
			_recordset = null;
			list = null;
			categoryLookup = null;
			
		}
		protected function onSetLanguage(e:RenderingEvent) {
			render();
		}		

	}
	
}