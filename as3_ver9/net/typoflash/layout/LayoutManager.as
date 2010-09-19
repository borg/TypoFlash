package net.typoflash.layout {
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	/*
	 * Dispatched when any registered layout changes.
	 */
	[Event("change")] // [Event(name="change", type="flash.events.Event")]
	
	/**
	 * The LayoutManager class is used to help layout instances
	 * keep up to date. By registering a diaplay object with a 
	 * LayoutManager instance, a layout object is created and
	 * associated with that display object.  This layout object can
	 * then be recognized when a parent display object within the 
	 * display list with a layout is updated and update
	 * itself with that parent's changes.  Additionally, by using
	 * LayoutManager.initializeAutoUpdate(), with a reference to stage
	 * the RENDER event will be used to automatically update registered
	 * layouts at the end of a frame when they've changed. When
	 * registered layouts change, the LayoutManager will dispatch a
	 * CHANGE event.
	 * <br/><br/>
	 * The LayoutManager works through instances as well as a singleton.
	 * If you do not want to manage multiple instances of LayoutManager,
	 * you can call LayoutManager methods directly from the LayoutManager
	 * class (meaning the class has two sets of methods, one set for 
	 * instances and one set static).
	 * <br/><br/>
	 * Use of the LayoutManager is optional for layouts.  If you do not
	 * use the LayoutManager class, then you will need to make sure to
	 * call draw() for all of your layouts to make sure they are
	 * properly updated.
	 *
	 * @author Trevor McCauley, www.senocular.com
	 * @date August 22, 2008
	 * @version 1.0.1
	 */
	public class LayoutManager extends EventDispatcher {
		
		
		private static var _instance:LayoutManager = new LayoutManager();

		/**
		 * Returns the LayoutManager instance associated with
		 * the LayoutManager class if the LayoutManager is
		 * being used as a singleton.
		 */
		public static function getInstance():LayoutManager {
			return _instance;
		}
		
		/**
		 * Registers a display object with a layout. As a 
		 * registered layout, it will be available for updates
		 * if the Layout class is initialized with auto updates
		 * and for propagation of changes from parent layouts. If the
		 * target display object already has a registered layout
		 * for this same LayoutManager, that layout is returned. If the
		 * target is registered to another layout manager, it will 
		 * continue to be registered to that layout manager with a 
		 * separate layout instance.
		 * @param target The display object to get a layout for.
		 * @param changeHandler If a new Layout instance is created, this
		 * 		handler will be used to update the target during the CHANGE
		 * 		event [optional].
		 */
		public static function registerNewLayout(target:DisplayObject, useDefaultChangeHandler:Boolean = true):Layout {
			return _instance.registerNewLayout(target, useDefaultChangeHandler);
		}
		
		/**
		 * Returns the current layout object associated with 
		 * the passed display object.  If no layout has been
		 * registered for that object, null is returned.
		 * @param target The display object to get a layout for.
		 */
		public static function getLayout(target:DisplayObject):Layout {
			return _instance.getLayout(target);
		}
		
		/**
		 * Unregisters a display object's layout. As a 
		 * registered layout, it will be available for updates
		 * if the LayoutManager class is initialized with auto updates
		 * and for propagation of changes from parent layouts. When
		 * unregistered, updates will have to be made manually.
		 * @param target The display object to unregister from the manager.
		 */
		public static function unregisterLayout(target:DisplayObject):Layout {
			return _instance.unregisterLayout(target);
		}
		
		/**
		 * Determines if the display object has a registered layout.
		 * @param target A display object to check if registered
		 * 		to this LayoutManager instance.
		 */
		public static function isRegisteredLayout(target:DisplayObject):Boolean {
			return _instance.isRegisteredLayout(target);
		}
		
		/**
		 * Initializes the Layout class to perform automatic updates
		 * for all registered layouts.  Updates happen during the RENDER
		 * event and only occur if there was a change in a layout. If
		 * already initialized the Layout class for auto updates and
		 * want to stop the auto updates, call initializeAutoUpdate
		 * again but pass null instead of a reference to the stage.
		 * @param stage A reference to the stage to be used to 
		 * 		allow for updates in the RENDER event.
		 */
		public static function initializeAutoUpdate(stage:Stage):void {
			_instance.initializeAutoUpdate(stage);
		}
		
		/**
		 * Draws and updates all layouts in the layout manager
		 */
		public static function draw():void {
			_instance.validate(null);
		}
		
		/**
		 * @private
		 */
		internal var invalidList:Dictionary = new Dictionary(true);
		
		/**
		 * @private
		 */
		internal var registeredList:Dictionary = new Dictionary(true);
		
		private var stage:Stage;
		private var invalid:Boolean;
			
		/**
		 * Constructor. Creates a new LayoutManager instance from which
		 * you can register layouts for diaply objects.  As an alternative
		 * to making your own LayoutManager instances, you can also use
		 * the static methods from the LayoutManager class to handle all
		 * layouts.
		 */
		public function LayoutManager() {}
		
		/**
		 * Registers a display object with a layout. As a 
		 * registered layout, it will be available for updates
		 * if the Layout class is initialized with auto updates
		 * and for propagation of changes from parent layouts. If the
		 * target display object already has a registered layout
		 * for this same LayoutManager, that layout is returned. If the
		 * target is registered to another layout manager, it will 
		 * continue to be registered to that layout manager with a 
		 * separate layout instance.
		 * @param target The display object to get a layout for.
		 * @param changeHandler If a new Layout instance is created, this
		 * 		handler will be used to update the target during the CHANGE
		 * 		event [optional].
		 */
		public function registerNewLayout(target:DisplayObject, useDefaultChangeHandler:Boolean = true):Layout {
			// create new layout and associate with target
			// if doesn't already exist in registeredList
			if (!(target in registeredList)) {
				var layout:Layout = new Layout(target, useDefaultChangeHandler);
				layout._manager = this;
				registeredList[target] = layout;
			}
			
			return Layout(registeredList[target]);
		}
		
		/**
		 * Returns the current layout object associated with 
		 * the passed display object.  If no layout has been
		 * registered for that object, null is returned.
		 * @param target The display object to get a layout for.
		 */
		public function getLayout(target:DisplayObject):Layout {
			if (target in registeredList) {
				return Layout(registeredList[target]);
			}
			return null;
		}
		
		/**
		 * Unregisters a display object's layout. As a 
		 * registered layout, it will be available for updates
		 * if the LayoutManager class is initialized with auto updates
		 * and for propagation of changes from parent layouts. When
		 * unregistered, updates will have to be made manually.
		 * @param target The display object to unregister from the manager.
		 */
		public function unregisterLayout(target:DisplayObject):Layout {
			if (target in registeredList) {
				var layout:Layout = Layout(registeredList[target]);
				layout._manager = null;
				delete registeredList[target];
				return layout;
			}
			return null;
		}
		
		/**
		 * Determines if the display object has a registered layout.
		 * @param target A display object to check if registered
		 * 		to this LayoutManager instance.
		 */
		public function isRegisteredLayout(target:DisplayObject):Boolean {
			return Boolean(target in registeredList);
		}
		
		/**
		 * Initializes the Layout class to perform automatic updates
		 * for all registered layouts.  Updates happen during the RENDER
		 * event and only occur if there was a change in a layout. If
		 * already initialized the Layout class for auto updates and
		 * want to stop the auto updates, call initializeAutoUpdate
		 * again but pass null instead of a reference to the stage.
		 * @param stage A reference to the stage to be used to 
		 * 		allow for updates in the RENDER event.
		 */
		public function initializeAutoUpdate(stage:Stage):void {
			if (this.stage){
				this.stage.removeEventListener(Event.RENDER, validate, false);
			}
			this.stage = stage;
			if (this.stage){
				this.stage.addEventListener(Event.RENDER, validate, false, 1, true);
			}
		}
		
		/**
		 * Draws and updates all layouts in the layout manager
		 */
		public function draw():void {
			validate(null);
		}
		
		/**
		 * Adds the passed layout to the invalid list of the manager
		 * and invalidates the stage (if available) to ensure that
		 * validate will be called in the next RENDER event
		 * @private
		 */
		internal function invalidate(layout:Layout):void {
			invalidList[layout] = true;
			if (stage){
				if (!invalid) {
					stage.invalidate();
					invalid = true;
				}
				
				// WORKAROUND: needed to retain render listeners
				// in case another action uses
				// removeEventListener(Event.RENDER, ... )
				// which removes all RENDER listeners (bug)
				initializeAutoUpdate(stage);
			}
		}
		
		/*
		 * Called in the RENDER event, updates all invalid
		 * layouts in the manager
		 */
		private function validate(event:Event):void {
			removeInvalidRedundancies();
			
			// draw each layout in invalid list
			var changedList:Dictionary = new Dictionary(true);
			for (var element:* in invalidList) {
				Layout(element)._draw(changedList);
			}
			Layout.updateChanged(changedList);
			
			// dispatch manager CHANGE if
			// changedList has any layouts
			for (element in changedList) {
				dispatchEvent(new Event(Event.CHANGE));
				break;
			}
			
			invalid = false;
		}
		
		/*
		 * Each invalid layout will also update it's children to fit
		 * within its new contraints/bounds.  If these children are
		 * also invalid, they can be removed from the invalid list since
		 * they will automatically be drawn when their parent layout is
		 */
		private function removeInvalidRedundancies():void {
			for (var element:* in invalidList) {
				removeRedundantChildren(Layout(element));
			}	
		}
		private function removeRedundantChildren(layout:Layout):void {
			// first check any children within the childList
			for (var element:* in layout.childList){
				if (element in invalidList) {
					delete invalidList[element];
				}
			}
				
			// second check registered layouts in the target container
			if (layout._target is DisplayObjectContainer) {
				
				var targetContainer:DisplayObjectContainer = DisplayObjectContainer(layout._target);
				var i:int = targetContainer.numChildren;
				var child:DisplayObject;
				while(i--) {
					child = targetContainer.getChildAt(i);
					if (child in registeredList) {
						if (registeredList[child] in invalidList) {
							delete invalidList[registeredList[child]];
						}
					}	
				}
			}
		}
	}
}