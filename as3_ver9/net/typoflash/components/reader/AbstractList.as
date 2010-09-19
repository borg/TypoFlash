package net.typoflash.components.reader{

	
	/**
	 * 
	 * 
	 * What do I do when I want to gradually keep adding items to list?
	 * I could unshift the reader.recordset list and rerender the whole list, but that
	 * does not work with nicely animated items. Instead you just add to the
	 * existing reader.recordset set and keep on rendering next item with the modification
	 * that the rendering function removes items from the display list if
	 * there are too many. Hence the new item would stay in the dataset
	 * but dissapear off the display list. This way one can also scroll
	 * backwards through the list.
	 * ...
	 * @author A. Borg
	 */
	
	import flash.display.Sprite;
	import flash.events.Event;
	import net.typoflash.events.ReaderEvent;
	import net.typoflash.utils.Debug;
	import flash.display.StageAlign;
	import net.typoflash.components.reader.ReaderType;
	import net.typoflash.components.Skinnable;	
	
	public class AbstractList extends Skinnable {
		public var reader:AbstractReader;
		protected var _itemPadding:int=0;//distance between text and border
		protected var _itemMargin:int=0;//distance between menu items. If more specific settings required extend in subclass
		protected var _align:String = StageAlign.TOP_LEFT;
		protected var _nesting:int = ReaderType.NEST_OFF;
		
		protected var _renderStyle:int = ReaderType.RENDER_SEQUENTIALLY;
	
		//Items in list of active recordset
		public var ListItemClass:Class = AbstractListItem;
		public var ListItemSkin:Class;
				
		/*
		 * old in new or vice versa //nested items site inside each other, good for 
		 * accordion style displays 
		 */
		
		public var tween:Boolean = true;// 
		public var displayItems:Array;//contains reference to all rendered objects irrespective of nesting
		
		protected var _lastListItemId:int = -1;//id of last rendered item
		protected var _firstListItemId:int = -1;//
		
		protected var _holder:Sprite;
		
		protected var _oldY:int = 0;
		protected var _oldX:int = 0;
		
		public function AbstractList(_reader:AbstractReader){
			reader = _reader;
			
			displayItems = [];
			
			addEventListener(Event.ADDED_TO_STAGE, onAbstractListAdded, false, 0, true);
			addEventListener(Event.REMOVED_FROM_STAGE, onAbstractListRemoved, false, 0, true);
		}
		
		protected function onAbstractListAdded(e) {
			_holder = new Sprite();
			addChild(_holder);	
			
			addReaderListeners();
		}
		protected function onAbstractListRemoved(e) {
			removeReaderListeners();
			
		}
		public function render(start:int=-1,length:int=-1) {
			var listItem:AbstractListItem;
			
			if (reader.recordset is Array) {
				
				
				//partial rendering
				if (start > -1) {
					var v = start;
					if (length > 1) {
						clear();//what else to do?
						
					}
					_firstListItemId = start;//only update if previous one
					//length = Math.min(length, reader.recordsPerPage-displayItems.length);//make sure no overshoot
					var end = start + length;
					while (v < end) {
						
						listItem = new ListItemClass(reader, reader.recordset[v]);
						//listItem.SkinClass = reader.ListItemSkin;
						listItem.skin = new ListItemSkin();
						listItem.setDefaultTextFormat();
						listItem.padding = _itemPadding;
						listItem.margin = _itemMargin;//just thought it might want to know
						
						if (nesting != ReaderType.NEST_OFF) {
							
							if (nesting == ReaderType.NEST_OLD_IN_NEW) {
								//lift the old display list out of old clip and into new
								
								if (displayItems[displayItems.length-1] is ListItemClass) {//return
									try {
										//moving old symbol into new
										listItem.skin.holder.addChild(displayItems[displayItems.length-1] );
										_holder.addChild(listItem);
									}
									catch (e:Error)	{
										trace("No holder in newslist item?")
									}
								}else {
									//first time
									
									_holder.addChild(listItem);
								}
							}else if (nesting == ReaderType.NEST_NEW_IN_OLD) {
								if (displayItems[displayItems.length-1] is ListItemClass) {
									try {
										//nesting
										displayItems[displayItems.length-1].skin.holder.addChild(listItem);
									}
									catch (e:Error)	{
										trace("No holder in newslist skin item?")
									}
								}else {
									//first time
									_holder.addChild(listItem);
								}
								
							}
							
							
						}else{
							_holder.addChild(listItem);
							listItem.render();
							listItem.y = _oldY;
							_oldY += listItem.height + _itemMargin;
						}
						_lastListItemId = v;
						listItem.render();
						reader.dispatchEvent(new ReaderEvent(ReaderEvent.ON_RENDER_LIST_ITEM,listItem));
						v++;
						displayItems.push(listItem);	
					}
					
					//trace([reader.name,"render _lastListItemId",_lastListItemId]);
					
					
				}else {
					//render all at once
					clear();
					for (var i = (reader.recordsPerPage * reader.currentPage); i < reader.recordsPerPage * reader.currentPage + reader.recordsPerPage;i++) {
						listItem = new ListItemClass(reader, reader.recordset[i]);
						listItem.skin = new ListItemSkin();
						listItem.padding = _itemPadding;
						listItem.margin = _itemMargin;//just thought it might want to know
						
						
						if (nesting != ReaderType.NEST_OFF) {
							if (nesting == ReaderType.NEST_OLD_IN_NEW) {
								//lift the old display list out of old clip and into new
								
								if (displayItems[displayItems.length-1] is ListItemClass) {
									try {
										//moving old symbol into new
										listItem.skin.holder.addChild(displayItems[displayItems.length-1] );
										_holder.addChild(listItem);
									}
									catch (e:Error)	{
										trace("No holder in newslist skin item?")
									}
								}else {
									//first time
									_holder.addChild(listItem);
								}
							}else if (nesting == ReaderType.NEST_NEW_IN_OLD) {
								if (displayItems[displayItems.length-1] is ListItemClass) {
									try {
										//nesting
										displayItems[displayItems.length-1].skin.holder.addChild(listItem);
									}
									catch (e:Error)	{
										trace("No holder in newslist item?")
									}
								}else {
									//first time
									_holder.addChild(listItem);
								}
								
							}
							
							listItem.render();
							//trace("news list render")
						}else{
							_holder.addChild(listItem);
							listItem.render();
							listItem.y = _oldY;
							_oldY += listItem.height + _itemMargin;
						}
						
						reader.dispatchEvent(new ReaderEvent(ReaderEvent.ON_RENDER_LIST_ITEM,listItem));
					}
					_firstListItemId = 0;
					_lastListItemId = reader.recordset.length - 1;
					displayItems.push(listItem);
				}	
				
				
				//check if there are too many items in list and if so remove old one
				removeOvershoot() 
			}
			
		}
		
		
		
		protected function renderNextItem(e:ReaderEvent) {
			//Debug.output([reader.name,"renderNextItem",_lastListItemId,reader.recordset.length]);
			if(_lastListItemId<reader.recordset.length-1){
				render(_lastListItemId + 1, 1);
				if(renderStyle != ReaderType.RENDER_SEQUENTIALLY_NO_ACTIVATION){
					reader.activeItem = reader.recordset[_lastListItemId];
				}
			}else if (reader.renderingTimer.running) {
				//stop timer when reach end
				//reader.stopTimer();
			}
		}
		protected function renderPrevItem(e:ReaderEvent) {
			//trace(["renderPrevItem",_firstListItemId,_lastListItemId])
			if (_firstListItemId > 0) {
				clear();//fix this..this is shotycut
				render(_firstListItemId - 1, 1);
				if(renderStyle != ReaderType.RENDER_SEQUENTIALLY_NO_ACTIVATION){
					reader.activeItem = reader.recordset[_lastListItemId];
				}
			}else if (reader.renderingTimer.running) {
				//stop timer when reach end
				//reader.stopTimer();
			}
		}	
		/*
		 * Page functions developed for Q, whose list does not have a set number of recordsPerPage
		 * but which varies depending on image sizes. If rendered does not render all recordsPerPage
		 * the layout of items will not be symmetrical when going forwardws and back
		 */ 
		protected function renderNextPage(e:ReaderEvent) { 
		
			if (_lastListItemId < reader.recordset.length - 2) {
				reader.currentPage++;
				render(reader.currentPage*reader.recordsPerPage, reader.recordsPerPage);
			}
		}
		protected function renderPrevPage(e:ReaderEvent) { 

			if (reader.currentPage > 0) {
				reader.currentPage--;
				render(reader.currentPage*reader.recordsPerPage, reader.recordsPerPage);
			}
		}
		
		
		protected function addReaderListeners() {
			reader.addEventListener(ReaderEvent.ON_NEXT_ITEM, renderNextItem, false, 0, true);
			reader.addEventListener(ReaderEvent.ON_PREVIOUS_ITEM, renderPrevItem, false, 0, true);
			reader.addEventListener(ReaderEvent.ON_NEXT_PAGE, renderNextPage, false, 0, true);
			reader.addEventListener(ReaderEvent.ON_PREVIOUS_PAGE, renderPrevPage, false, 0, true);
			reader.addEventListener(ReaderEvent.ON_SET_RECORDSET, onNewRecordSet, false, 0, true);
			
		}
		
		protected function removeReaderListeners() {
			reader.removeEventListener(ReaderEvent.ON_NEXT_ITEM, renderNextItem);
			reader.removeEventListener(ReaderEvent.ON_PREVIOUS_ITEM, renderPrevItem);
			reader.removeEventListener(ReaderEvent.ON_NEXT_PAGE, renderNextPage);
			reader.removeEventListener(ReaderEvent.ON_PREVIOUS_PAGE, renderPrevPage);
			reader.removeEventListener(ReaderEvent.ON_SET_RECORDSET, onNewRecordSet);
			
		}
		
		public function clear() {
			var v = _holder.numChildren;
			while (v--) {
				_holder.removeChildAt(v);
				//trace("clear  "+v)
			}
			
			_oldY = 0;

			displayItems = [];
		}		
		public function reset() {
			 clear();
			_oldX = 0;
			_lastListItemId = -1;//id of last rendered item
			_firstListItemId = -1;//			 
		}
		
		protected function onNewRecordSet(e:ReaderEvent) {
			reset();

		}
		
		public function get itemPadding():int { return _itemPadding; }
		
		public function set itemPadding(value:int):void 
		{
			_itemPadding = value;
		}
		
		public function get itemMargin():int { return _itemMargin; }
		
		public function set itemMargin(value:int):void 
		{
			_itemMargin = value;
		}
		
		public function get align():String { return _align; }
		
		public function set align(value:String):void 
		{
			_align = value;
		}
		
		public function get nesting():int { return _nesting; }
		
		public function set nesting(value:int):void 
		{
			_nesting = value;
		}
		
		public function removeOvershoot() {
			if (displayItems.length > reader.recordsPerPage) {
				for (var i = 0; i < displayItems.length - reader.recordsPerPage;i++){
					displayItems[0].parent.removeChild(displayItems[0]);
					displayItems.shift();
				}
			}		
		}
		/*
		 * This decides the way items are rendered
		 * RENDER_SEQUENTIALLY
		 */ 
		public function get renderStyle():int { return _renderStyle; }
		
		public function set renderStyle(value:int):void 
		{
			_renderStyle = value;
		}
		
		public function get holder():Sprite { return _holder; }
		
		public function get firstListItemId():int { return _firstListItemId; }
		
		public function get lastListItemId():int { return _lastListItemId; }
		public function destroy():void { }
	}
	
}