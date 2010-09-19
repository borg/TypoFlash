package net.typoflash.components.reader 
{
	
	/**
	 * A category selector 
	 * How to populate the selector? With all categories, or only the ones with items in them?
	 * Can you have several selectors for separate subcategories, or should all be in one?
	 * You should have the flexibility to design the application as you please. To make this possible
	 * each category selector must have its own recordset, and not the one of the reader. 
	 * 
	 * To be able to do sequential rendering of nested items they need to be in a flat array
	 * which contains both item and the level of nesting it is on.
	 * ...
	 * @author A. Borg
	 */
	import flash.display.MovieClip;
	import net.typoflash.components.Skinnable;	

	import net.typoflash.events.ReaderEvent;	
	public class AbstractCategorySelector extends AbstractList{
		protected var _rootCategory:String;//for category selector
		protected var _rootUid:uint;//uid
		public var localRootCategory:*;//nested tree data
		public var flatlist:Array;//list on {data:categoryItem,level:depth}
		public var lookup:Object;//list on uid {data:categoryItem,level:depth}
		
			
		public var ItemClasses:Array = [AbstractCategoryItem];
		public var ItemSkins:Array;	
		

		
		public function AbstractCategorySelector(_reader:AbstractReader){
			super(_reader);
			flatlist = [];
			lookup = { };
			
		}

		
		override public function render(start:int=-1,length:int=-1) {
			var listItem:AbstractCategoryItem;
			
			if (flatlist is Array) {
				
				
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
						
						listItem = new ItemClasses[Math.min(ItemClasses.length-1,flatlist[v].level)](this, flatlist[v].data);
						listItem.skin = new ItemSkins[Math.min(ItemSkins.length-1,flatlist[v].level)]();
						listItem.padding = _itemPadding;
						listItem.margin = _itemMargin;//just thought it might want to know
						
						if (nesting != ReaderType.NEST_OFF) {
							
							if (nesting == ReaderType.NEST_OLD_IN_NEW) {
								//lift the old display list out of old clip and into new
								
								if (displayItems[displayItems.length-1] is AbstractCategoryItem) {//return
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
								if (displayItems[displayItems.length-1] is AbstractCategoryItem) {
									try {
										//nesting
										displayItems[displayItems.length-1].skin.holder.addChild(listItem);
									}
									catch (e:Error)	{
										trace("No holder in AbstractCategoryItem skin item?")
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
						//reader.dispatchEvent(new ReaderEvent(ReaderEvent.ON_RENDER_LIST_ITEM,listItem));
						v++;
						displayItems.push(listItem);	
					}
					
					//trace([reader.name,"render _lastListItemId",_lastListItemId]);
					
					
				}else {
					//render all at once
					clear();
					
					for (var i = 0; i < flatlist.length; i++) {
						
							
						
						listItem = new ItemClasses[Math.min(ItemClasses.length-1,flatlist[i].level)](this, flatlist[i].data);
						listItem.skin = new ItemSkins[Math.min(ItemSkins.length - 1, flatlist[i].level)]();
						
						listItem.padding = _itemPadding;
						listItem.margin = _itemMargin;//just thought it might want to know
						
						
						if (nesting != ReaderType.NEST_OFF) {
							if (nesting == ReaderType.NEST_OLD_IN_NEW) {
								//lift the old display list out of old clip and into new
								
								if (displayItems[displayItems.length-1] is AbstractCategoryItem) {
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
								if (displayItems[displayItems.length-1] is AbstractCategoryItem) {
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
						
					}

					displayItems.push(listItem);
				}	
				
		
			}
			
		}
		
		override protected function addReaderListeners() {
			//reader.addEventListener(ReaderEvent.RENDERING_IMPULSE, renderNextItem, false, 0, true);
			
		}
		override protected function renderNextItem(e:ReaderEvent) {
			//Debug.output([reader.name,"renderNextItem",_lastListItemId,reader.recordset.length]);
			if(_lastListItemId<flatlist.length-1){
				render(_lastListItemId + 1, 1);
				//reader.dispatchEvent(new ReaderEvent(ReaderEvent.ON_SET_ACTIVE,flatlist[_lastListItemId]));
			}else if (reader.renderingTimer.running) {
				//stop timer when reach end
				//reader.stopTimer();
			}
		}
		override protected function renderPrevItem(e:ReaderEvent) {
			//trace(["renderPrevItem",_firstListItemId,_lastListItemId])
			if (_firstListItemId > 0) {
				clear();//fix this..this is shotycut
				render(_firstListItemId - 1, 1);
				//reader.dispatchEvent(new ReaderEvent(ReaderEvent.ON_SET_ACTIVE,reader.recordset[_lastListItemId]));
			}else if (reader.renderingTimer.running) {
				//stop timer when reach end
				reader.stopTimer();
			}
		}		
		/*
		 * Category selector root
		 */ 
		public function get rootCategory():String { return _rootCategory; }
		
		public function set rootCategory(value:String):void {
			_rootCategory = value;
		}

		
	}
	
}