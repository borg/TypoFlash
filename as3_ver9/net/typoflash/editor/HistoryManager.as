package net.typoflash.editor {
	
	/**
	 * This class handles all editing history, i.e. undo/redo etc. It communicates with TCEmain in Typo3
	 * so as to make the TypoFlash edits appear in the undo history of the system. 
	 * 
	 * When saving the unsaved history the entire list is passed on to contentediting, and thus processed
	 * one by one in the backend instead of by making many calls. On success the unsaved history is cleared.
	 * This approach is faster but more error prone, therefore we must listen to any errors thrown by php
	 * and only clear that part of the queue that has successfully been processed.
	 * ...
	 * @author Borg
	 */
	import flash.events.EventDispatcher;
	import net.typoflash.events.EditingEvent;	
	import net.typoflash.utils.Debug;
		
	public class HistoryManager{
		private static var _history:Array;//total saved history
		private static var _unsavedHistory:Array;//history not yet saved, added to history on makeHistory
		private static var _keyList:Object;//keeps track of what objects are contained in history, so as not replicate many version of same object
		
		private static var dispatcher:EventDispatcher;	
		/*
		 * Checks if calls to same function already exists, if so overwrites
		 */ 
		
		public static function addItem(o:HistoryItem) {
			if (!(_unsavedHistory is Array)) {
				_unsavedHistory = [];
				_keyList = {};
			}
			

			if (_keyList[o.key]) {
				//delete old entry
				if(HistoryItem(_keyList[o.key]).func == o.func){
					_unsavedHistory.splice(HistoryItem(_keyList[o.key]).index, 1);
					updateIndex();
				}
				
				
			}
			
			
			
			o.index = _unsavedHistory.length;
			_keyList[o.key] = o;
			_unsavedHistory.push(o);
			Debug.output("New History item " + o);
			dispatchEvent(new EditingEvent(EditingEvent.ON_HISTORY_CHANGED,o));
		}
		
		public static function getItem(key:String):HistoryItem {
			return _keyList[key];
		}
		
		/*
		 * This function is called from TypoFlash editor when it receives a success from
		 * ContentEditing.storeHistory. This is what makes unsaved history real history
		 */ 
		
		public static function makeHistory() {
			if (_history == null) {
				_history = [];
			}
			_history.concat(_unsavedHistory);
			_unsavedHistory = [];
			updateIndex();
			dispatchEvent(new EditingEvent(EditingEvent.ON_HISTORY_CHANGED));
		}
		
		/*
		 * Makes sure index is intact after swapping order
		 */
		
		private static function updateIndex() {
			var v = _unsavedHistory.length;
			while (v--) {
				HistoryItem(_unsavedHistory[v]).index = v;
			}
			
		}
		
		
		public static function clear() {
			_history = [];
			_unsavedHistory = [];
			_keyList = { };
			dispatchEvent(new EditingEvent(EditingEvent.ON_HISTORY_CHANGED));
		}
		
		static public function get queue():Array { return _history; }
		
		static public function get unsavedHistory():Array { 
			if (!(_unsavedHistory is Array)) {
				_unsavedHistory = [];
			}
			return _unsavedHistory; 
		}
		
		static public function get history():Array { 
			if (!(_history is Array)) {
				_history = [];
			}
			return _history; 
		}

		
	    /**
	    *   Event Dispatcher Functions
	    */
	    
	    public static function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			if (dispatcher == null) {
				dispatcher = new EventDispatcher();
			}
        	dispatcher.addEventListener(type, listener, useCapture, priority);
	    }
	      		
	    public static function dispatchEvent(evt:EditingEvent):Boolean {
			if (dispatcher == null) {
				dispatcher = new EventDispatcher();
			}
	        return dispatcher.dispatchEvent(evt);
	    }
	    
	    public static function hasEventListener(type:String):Boolean {
			if (dispatcher == null) {
				dispatcher = new EventDispatcher();
			}
	        return dispatcher.hasEventListener(type);
	    }
	    
	    public static function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			if (dispatcher == null) {
				dispatcher = new EventDispatcher();
			}
	        dispatcher.removeEventListener(type, listener, useCapture);
	    }
	                   
	    public static function willTrigger(type:String):Boolean {
	        return dispatcher.willTrigger(type);
	    }
		
				
		
	}
	
}