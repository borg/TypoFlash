package  net.typoflash {
	
	
	
	 /**
	  * Glue does what it says, it glues the content and the config data to a configurable component.
	  * To make any component sensitive to configurable data and content create glue somewhere inside the
	  * loading swf.
	  * 
	  * You have many choices between how your component can communicate with the dynamic data
	  * but in essence all you need to do is to create a glue and pass the display object to the
	  * constructor function.
	  * 
	  * 
	  * How data is applied:
	  * How do you want the data to be applied? By default glue is smacking it right on to your display object
	  * and it better have the properties is says it has. 
	  * 
	  * If you want to process the data yourself inside the component and thus have some more flexibility
	  * you can set doNotApplyPhysical and/or doNotApplyMeta to true, but you will still have to provide getters 
	  * and setters for the configurable properties you declare your component has. 
	  * 
	  * The ON_DATA event is fired AFTER apply is run.
	  * 
	  * By default physical properties are tweened using a sequential tween that moves first in x direction
	  * and then in y. You can disable the sequential tween and get a single A to B tween setting useSequentialTween
	  * 
	  * You can also listen to the sequential tweener events so as to init your componet when in place.
	  * 
	  * You can also modify the tween function and tween time.
	  * 
	  * Physical propertias:
	  * Physical properties are all those display object properties that come out of the box, and are
	  * supported by the Flash Player
	  * 
	  * Additional configurable properties:
	  * You can declare additional bespoke properties, and provide a string reference to the editor
	  * class to deal with manipulating the values. To add a property you call glue.addProperty
	  * and pass a ConfigurableProperty as argument.
	  * 
	  * 
	  * Template Objects:
	  * Template Objects are all those Configurable objects that are fixed to the Template, such as
	  * Frames, Menus, and Configurable Sprites (TO).
	  * 
	  * Components
	  * Components are loaded into frames and only live on a page. This affects the editor options available, eg. components
	  * cannot store config data on template level since they have no use of it. But what if I want to fix a component in 
	  * a template so as to be able to move it around in different pages? All you need to do is to wack the component into
	  * your template and tell TypoFlash that it implements ITemplateObject interface and it will be treat like all the
	  * other TemplateObjects.
	  * 
	  * 
	  * Usage:
	  * Anywhere inside loaded swf create one glue and respective listeners.
	  * _TFglue = new Glue(this);
	  *	_TFglue.addEventListener(GlueEvent.ON_DATA, onData);
	  * _TFglue.disablePhysicalConfig = true;//fixes properties such as width and height and makes them unavailable to editor
	  * _TFglue.doNotApplyPhysical = false;//if true the stored data is not applied directly to component. Need a ON_DATA listener to access
	  * _TFglue.tweenPhysicalProperties = false;//if false will apply physical properties with brute force, in discrete values
	  * ...
	  * @author Borg
	  */
		
	 
	 
	import flash.events.Event;
	import flash.events.MouseEvent;
	import net.typoflash.base.ITemplateObject;
	import net.typoflash.base.ITemplate;
	import net.typoflash.base.IFrame;
	import net.typoflash.base.IMenu;
	import net.typoflash.base.IPreloader;
	import net.typoflash.datastructures.TFMenuRequest;

	import net.typoflash.crypto.MD5;
	import flash.events.EventDispatcher;
	import net.typoflash.base.ConfigurableProperties;
	import net.typoflash.base.ConfigurableProperty;
	import net.typoflash.base.IConfigurable;
	import net.typoflash.base.PhysicalProperties;
	import net.typoflash.ContentRendering;
	import net.typoflash.datastructures.TFContent;
	import net.typoflash.datastructures.TFData;
	import net.typoflash.events.GlueEvent;
	import net.typoflash.events.EditingEvent;
	import net.typoflash.events.RenderingEvent;
	import net.typoflash.utils.Debug;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import net.typoflash.datastructures.TFConfig;
	import net.typoflash.base.FrameDataHolder;
	import net.typoflash.editor.ITypoFlash;
	import net.typoflash.events.AuthEvent;
	

	public dynamic class Glue extends EventDispatcher{
		
		public var TF_CONF:TFConfig  = TFConfig.global;
		
		
		private var _TFkey:String;
		private var _TFdata:TFData;
		private var _TFconfigurable:DisplayObject;
		private var _TFfin:Object;
		private var _TFcurr:Object;
		private var _TForg:Object;//original values are used to restore template objects to some default value if none is set
		private var _rootline:String;//this is the only way I have found to generate a unique id for a clip in the swf based on the depth of itself and all its parents
		
		
		private var _physicalProps:PhysicalProperties;
		private var _configurableProps:ConfigurableProperties;
		
		
		private var _TFeditorClass:String;
		private var _disablePhysicalConfig:Boolean = false;
		private var _addedOnMouseDownListener:Boolean = false;
		private var _tweenPhysicalProps:Boolean = false;
		private var _tweenFunc:Function;
		private var _tweenTime:Number = 200;
		private var _useSequentialTween:Boolean = true;
		
		/*
		 * if true data is not applied from glue, but can only be accessed through the Glue.ON_DATA event. Normally 
		 * Glue applies data directly to configurable, either by means of a tween or brutal force.
		 */ 
		
		
		private var _doNotApplyPhysical:Boolean = false;
		private var _doNotApplyMeta:Boolean = false;
		private var _externallyEdited:Boolean;
		private var _cacheCleared:Boolean;
		private var _editable:Boolean;
		

		
		public function Glue(conf:DisplayObject) 	{
			_TFconfigurable = conf;

			_TFfin = { };
			_TFcurr = { };
			_TForg = { };
			_physicalProps = new PhysicalProperties();
			_configurableProps = new ConfigurableProperties();
			
			_TFdata = new TFData();
			
			//add or remove????
			//ContentRendering.addEventListener(RenderingEvent.ON_PRE_GET_PAGE,preparseGetPage,false,0,true);
			
			/*
			addEventListener('onData', _TFconfigurable);
			addEventListener('onGetMedia', _TFconfigurable);
			addEventListener('onGetMediaFromCategory', _TFconfigurable);
			
			  
			  _global.TF.CONTENT_EDITING.addEventListener(onExternalEdit,false,0,true);
			  
			  
			  */
			  

			  //check if teplate,menu,frame, tmlpobject or component. This is where the interfaces are most useful
			if (_TFconfigurable is ITemplateObject) {
				if (_TFconfigurable is IMenu) {
					editorClass = EditingEvent.MODE_MENU;
				}else if (_TFconfigurable is ITemplate) {
					editorClass = EditingEvent.MODE_TEMPLATE;
				}else if (_TFconfigurable is IFrame) {
					editorClass = EditingEvent.MODE_FRAME;
				}else if (_TFconfigurable is IPreloader) {
					editorClass = EditingEvent.MODE_PRELOADER;
				}else{
					//only one left
					editorClass = EditingEvent.MODE_TEMPLATE_OBJECT;
				}
				_TFconfigurable.addEventListener(RenderingEvent.ON_TEMPLATE_ADDED_TO_STAGE, onTemplateObjectAddedToStage, false, 0, true);
				_TFconfigurable.addEventListener(Event.REMOVED_FROM_STAGE,destroy, false, 0, true);
			}else{
				editorClass = EditingEvent.MODE_COMPONENT;
				_TFconfigurable.addEventListener(Event.ADDED_TO_STAGE, onComponentAddedToStage, false, 0, true);
				
				/* In reality mostly components get unloaded but in the event of a template change we need to unregister
				 * glue for template objects as well. In AS3 it is even more important to kill all timers and 
				 * enterframe listeners etc, and remove every listener. Otherwise they will keep on running in the 
				 * background and grind the browser to a halt in the end.
				 */ 
				//addEventListener(Event.UNLOAD, destroy);
				
				//made destroy a set page function in Jan 2010
				ContentRendering.addEventListener(RenderingEvent.ON_SET_PAGE, destroy, false, 0, true);
			
			} 
			
			Debug.output("Glue constructor says I am " +editorClass )				
			//make menus, frames and templates uneditable by default, else will capture everything else
			var defaultUneditable = [EditingEvent.MODE_TEMPLATE,EditingEvent.MODE_MENU,EditingEvent.MODE_FRAME];
			for each(var n in defaultUneditable){
				try {
					if (TF_CONF.COOKIE.data['TF' + n + 'Editable'] == null) {
						TF_CONF.COOKIE.setData('TF' + n + 'Editable',false)
					}
				}
				catch (e:Error)	{//ignore, cookie is created in core
					}
			}

			
			
			
			//This line fires even when not unloaded or removed. Quintin issue. Jan 2010
			//_TFconfigurable.addEventListener(Event.REMOVED_FROM_STATE,destroy);
			//_TFconfigurable.loaderInfo.addEventListener(Event.UNLOAD, destroy);
			/*
*/
			//by default only templates have this disabled but you can set it to true to avoid transform tool
			disablePhysicalConfig = false;
			
			
			if (TF_CONF.EDITOR) {
				TF_CONF.EDITOR.addEventListener(EditingEvent.ON_GLUE_EDITABLE,onEditable, false,0,true);
				//addConfListener();
				if (TF_CONF.COOKIE.data['TF' + editorClass+ 'Editable'] != false) {
					editable = true;
				}else {
					editable = false;
				}		
				
			}
			

		}
		

		
		public function get disablePhysicalConfig():Boolean { 
			return _disablePhysicalConfig; 
		}
		
		public function set disablePhysicalConfig(value:Boolean):void {
			_disablePhysicalConfig = value;
		}
		/*
		 * When adding glue to configurable you can disable 
		 * properties that should not be editable
		 */ 
		public function disablePhysicalProperty(v:String) {
			if(_physicalProps.property[v] is ConfigurableProperty){
				_physicalProps.disable(_physicalProps.property[v]);
			}
		}
		public function enablePhysicalProperty(v:String) {
			if(_physicalProps.property[v] is ConfigurableProperty){
				_physicalProps.enable(_physicalProps.property[v]);
			}
		}	
		
		/*
		 * These two functions extract the key and apply data for tempalte objects and page components respectively
		 */
		
		 /*
		 * This function intercepts the getPage call to be able to generate the config keys on the first call.
		 * The config key is dependent on the database id of the record and hence cannot be generated by flash alone.
		 * 
		 * The key for Menus are different. They are not dependent on the conf data as such, but on their
		 * location in the template, ie their name and parent. The reason for this is that they play a crucial
		 * role in retrieving the data for all the other pages, and for their rootPid to be editable it cannot
		 * be part of the data the menu itself is supposed to retrieve. That becomes a catch 22. Hence their
		 * key comes from their static name in the template. Make sure to give the menus unique names.
		 */
		
		private function preparseGetPage(e:RenderingEvent) {
			if (_TFkey == null && !(this is IMenu)) {
				var displayId = rootline;

				
				var hash:String = MD5.hash(String(configurable)+displayId);
				
				var key = _TFeditorClass + '_' + ContentRendering.page.TEMPLATE.uid + '_' + ContentRendering.page.TEMPLATE.template_pid + '_' + hash.substr(hash.length - 5, 5);
				key = key;
			}
			
			getPageData();
			apply();
	

        };
		
		private function onComponentAddedToStage(e:Event) {
			storeOriginalProperties();
			//Get data hand written into component record
			getComponentdata();
			Debug.output("onComponentAddedToStage")

			
			if (_TFkey == null) {
				
				var displayId = rootline;
				
				
				/*name.indexOf("instance") == 0){
					throw new Error("Glue: The parent of the Menu "+  configurable + " does not have a name set. Cannot generate unique key.")
				}*/
				
				var hash:String = MD5.hash(String(configurable)+displayId);
				Debug.output("Generating component key " + displayId + "  " + configurable +"  " + hash)
				try{
					key = _TFeditorClass + '_' + ContentRendering.page.TEMPLATE.uid + '_' + ContentRendering.page.TEMPLATE.template_pid + '_' + _TFdata.CONTENT.component.uid + '_' + _TFdata.CONTENT.uid + '_' + hash.substr(hash.length - 5, 5);
				}
				catch (e:Error)	{
					//not set during development
					return;
					
				}
			}
			ContentRendering.addEventListener(RenderingEvent.ON_CLEAR_CACHE,onClearCache,false,0,true);
			ContentRendering.addEventListener(RenderingEvent.ON_PARSE_PAGE_DATA,onParsePageData,false,100,true);		//append page specific data
			getPageData();
			apply();
			
			//
			/*	
			 * 
			 * //dispatchEvent(new GlueEvent(GlueEvent.ON_DATA, _TFdata));
			if (!_tweenPhysicalProps) { }			*/	
		}
		
		protected function onTemplateObjectAddedToStage(e:RenderingEvent) {
			if (_TFconfigurable is IMenu) {
				var hash = MD5.hash(configurable.parent.name + configurable.name);
				key = IMenu(configurable).menuId = editorClass + '_' + hash.substr(hash.length - 5, 5);
				
				try{
					if (uint(ContentRendering.getHtmlVar(key, 'rootPid')) > 0) {
						IMenu(configurable).rootPid = uint(ContentRendering.getHtmlVar(key, 'rootPid'));
						Debug.output('Root pid for menu ' + key + ' from html: ' + IMenu(configurable).rootPid);
					}
				}
				catch (e:Error)	{	}	
				
			}
			storeOriginalProperties();
		}

		public function get key():String { return _TFkey; }
		
		public function set key(value:String):void{
			_TFkey = value;
		}
		
		public function get configurable():DisplayObject { return _TFconfigurable; }
		
		public function set configurable(value:DisplayObject):void 
		{
			_TFconfigurable = value;
		}
		
		public function get data():TFData { return _TFdata; }
		
		public function set data(value:TFData):void {
			
			_TFdata = value;
			
		}
		
		
		
		
		
		public function getPageData() {
			var d = ContentRendering.getData(_TFkey);
			for (var n in d) {
				_TFdata.CONFIGURATION[n] = d[n];
			}
        };

        public function apply() {
			if (_TFdata == null) {
				Debug.output('Why is the _TFdata empty for ' + _TFconfigurable + " key: " +key);
				return;
			}
			
			
		
		

			/*
			 * Begin by applying physical data
			 */
			var v = _physicalProps.enabledList.length;
			var prop:ConfigurableProperty;
			var n:String;
			
			//Check if we should get physical
			if(!_disablePhysicalConfig && ! _doNotApplyPhysical){
				if (_tweenPhysicalProps) {
					_TFfin = {};
					_TFcurr = {};
					var isChanged = false;
					/*
					 * Loop through all physical props
					 */
					
					
					while (v--) {
						prop =  _physicalProps.enabledList[v] as ConfigurableProperty;
						n = prop.name;
						if (_TFdata.CONFIGURATION.physical[n] != null) {
							_TFfin[n] = _TFdata[n];
						} else {
							if (_TForg[n] != null) {
								_TFfin[n] = _TForg[n];
							} else {
								Debug.output('Error no org value for ' + n + ' in ' + _TFkey);
							}
						}
						_TFcurr[n] = _TFconfigurable[n];
						if (_TFcurr[n] != _TFfin[n]) {
							isChanged = true;
						}
					}
					if (isChanged) {
					  /*if (_seqTw == null) {
						_seqTw = new net.typoflash.utils.SequentialTween(_TFconfigurable);
						_seqTw.onMotionChanged = net.typoflash.utils.Proxy.create(this, tweenPhysicalProps);
						_seqTw.onMotionFinished = net.typoflash.utils.Proxy.create(this, tweenPhysicalPropsComplete);
					  }
					  _seqTw.stop();
					  _seqTw.start();*/
					}
				} else {
					
 
					while (v--) {
						prop =  _physicalProps.enabledList[v] as ConfigurableProperty;
						n = prop.name;
						
						if (!isNaN(_TFdata.CONFIGURATION.physical[n]) && _TFconfigurable[n] != _TFdata.CONFIGURATION.physical[n]) {
							_TFconfigurable[n] = _TFdata.CONFIGURATION.physical[n];
							Debug.output("Setting " + n + " to new "+_TFconfigurable[n]+" for " + toString()); 
						} else if (_TForg[n] != _TFconfigurable[n] && isNaN(_TFdata.CONFIGURATION.physical[n])) {
							/*
							 * If no config data is found for this page, restore to original value
							 */ 
							_TFconfigurable[n] = _TForg[n];
							Debug.output("Setting " + n + " back to org "+_TFconfigurable[n]+" for " + toString()); 
						}
						
					}
				}
				
			}

			if(!_doNotApplyMeta){
				/*
				 * Continue with meta data
				 */
				v = _configurableProps.enabledList.length;
				
				while (v--) {
					prop =  _configurableProps.enabledList[v] as ConfigurableProperty;
					n = prop.name;
					if (_TFdata.CONFIGURATION.meta[n] != null && _TFconfigurable[n] != _TFdata.CONFIGURATION.meta[n]) {
						_TFconfigurable[n] = _TFdata.CONFIGURATION.meta[n];
					} else if (_TForg[n] != _TFconfigurable[n] && _TFdata.CONFIGURATION.meta[n] == null) {
						/*
						 * If no config data is found for this page, restore to original value
						 */ 
						_TFconfigurable[n] = _TForg[n];
					}
				}
				
			}
			
			

								
			
			dispatchEvent(new GlueEvent(GlueEvent.ON_DATA,_TFdata));
        };
		
		
		
		
		
        private function getComponentdata() {
		

			try {
				_TFdata = FrameDataHolder(_TFconfigurable.root.parent.parent.parent).data;
				Debug.output("Found _TFdata for "+ _TFconfigurable);
			}
			catch (e:Error){
				Debug.output('No _TFdata found for ' + _TFconfigurable);
			}
		 // Debug.output(DisplayObject(conf.root)._TFdata);
		  /*
			if (DisplayObject(conf).root._TFdata) {
				
			}else {
				
			}
		  */
        };
		


		
		
		public function set editorClass(k:String) {
            _TFeditorClass = k;
    
        };
		/*
		 * Returns EditingEvent.MODE....
		 */ 
        public function get editorClass():String {
			return _TFeditorClass;
        };
		
		public function get physicalProperties():PhysicalProperties { return _physicalProps; }
		
		public function get configurableProperties():ConfigurableProperties { return _configurableProps; }
		
		public function get doNotApplyPhysical():Boolean { return _doNotApplyPhysical; }
		
		public function set doNotApplyPhysical(value:Boolean):void 
		{
			_doNotApplyPhysical = value;
		}
		
		public function get tweenPhysicalProperties():Boolean { return _tweenPhysicalProps; }
		
		public function set tweenPhysicalProperties(value:Boolean):void 
		{
			_tweenPhysicalProps = value;
		}
		
		public function get tweenFunction():Function { return _tweenFunc; }
		
		public function set tweenFunction(value:Function):void 
		{
			_tweenFunc = value;
		}
		
		public function get tweenTime():Number { return _tweenTime; }
		
		public function set tweenTime(value:Number):void 
		{
			_tweenTime = value;
		}
		
		public function get useSequentialTween():Boolean { return _useSequentialTween; }
		
		public function set useSequentialTween(value:Boolean):void 
		{
			_useSequentialTween = value;
		}
		
		public function get doNotApplyMeta():Boolean { return _doNotApplyMeta; }
		
		public function set doNotApplyMeta(value:Boolean):void 
		{
			_doNotApplyMeta = value;
		}
		
		public function get editable():Boolean { return _editable; }
		
		public function set editable(value:Boolean):void {
			if (value) {
				if (TF_CONF.EDITOR) {
					ITypoFlash(TF_CONF.EDITOR).registerGlue(this);
				}
			}else if (TF_CONF.EDITOR) {
				ITypoFlash(TF_CONF.EDITOR).unregisterGlue(this);
			}
			_editable = value;
		}
		
		public function get rootline():String { 
			_rootline = "";
			climbRootline(configurable);
			return _rootline; 
		}
		
		public function climbRootline(o:DisplayObject) {
			_rootline = o.parent.getChildIndex(o) + "_" + _rootline;
			if (o.parent.parent) {
				climbRootline(o.parent)
			}
		}

		private function onEditable(e:EditingEvent) {
			if(e.data == editorClass && editable != TF_CONF.COOKIE.data['TF' + editorClass+ 'Editable'] ){
				editable = TF_CONF.COOKIE.data['TF' + editorClass+ 'Editable'] 
				Debug.output(this + " onEditable event " + editable)
			}
		}
		
		
        public function refresh() {
			if (editorClass == EditingEvent.MODE_COMPONENT) {
				getComponentdata();
			}
			getPageData();
			apply();
			Debug.output(_TFkey + '  - refreshing');
        };		
		
		
	    private function onClearCache(e:RenderingEvent) {
          _cacheCleared = true;
        };

        private function onParsePageData(e:RenderingEvent) {
			if (_externallyEdited) {
				refresh();
			}
			_cacheCleared = false;
			_externallyEdited = false;
        };	
		
		
		private function storeOriginalProperties() {
			var v = _physicalProps.enabledList.length;
			var prop:ConfigurableProperty;
			var n:String;
			/*
			 * First log all physical properties origianl values
			 */ 
			if(!disablePhysicalConfig){
				while (v--) {
					try{
						prop =  _physicalProps.enabledList[v] as ConfigurableProperty;
						n = prop.name;
						_TForg[n] = _TFconfigurable[n];
					}
					catch (e:Error){
						Debug.output("Disabling physical value " + n + " for " + toString() + " since nothing returned");
						_physicalProps.disable(_physicalProps.enabledList[v]);
					}
				}
			}
			
			/*
			 * The any additional values. Since the configurable component has
			 * declared these properties it should have them or else this will cause
			 * errors.
			 */ 
			v = _configurableProps.enabledList.length;
			while (v--) {
				try{
					prop =  _configurableProps.enabledList[v] as ConfigurableProperty;
					n = prop.name;
					_TForg[n] = _TFconfigurable[n];
				}
				catch (e:Error)	{
					Debug.output("Disabling configurable value " + n + " for " + toString() + " since nothing returned");
						_configurableProps.disable(_physicalProps.enabledList[v]);
				}
			}
			
        };
		

		
		public function addProperty(p:ConfigurableProperty) {
			_configurableProps.addProperty(p);
		}
		
		/*
		 * Use these function to get/set parameters in the browser link
		 */ 
		public function setQueryParameter(_name:String, _value) {
			ContentRendering.setPageStateProperty(_TFkey, _name, String(_value));
		}
		/*
		 * Serialise more than one parameter at once
		 */ 
		public function setQueryParameters(_object:Object) {
			_object.key = _TFkey;
			ContentRendering.setPageState(_object);
		}

		public function getQueryParameter(_name:String) {
			try{
				return ContentRendering.getPageStateProperty(_TFkey, _name);
			}catch (e:Error){}
			return null;
		}	
		public function clearQueryParameters() {
			ContentRendering.clearQueryParameters();
		}		
		
		override public function toString():String {
			return "[Glue " + editorClass +", configurable: "+_TFconfigurable+", key: "+ key+"]";
		}
		
		public function destroy(e:Event) {
			Debug.output(this.toString() + " is removed from stage and Glue destroyed")
			
			ContentRendering.removeEventListener(RenderingEvent.ON_PRE_GET_PAGE,preparseGetPage);
			ContentRendering.removeEventListener(RenderingEvent.ON_CLEAR_CACHE,onClearCache);
			ContentRendering.removeEventListener(RenderingEvent.ON_PARSE_PAGE_DATA,onParsePageData);		
			_TFconfigurable.removeEventListener(RenderingEvent.ON_TEMPLATE_ADDED_TO_STAGE, onTemplateObjectAddedToStage);
			_TFconfigurable.removeEventListener(Event.ADDED_TO_STAGE, onComponentAddedToStage);	
			if (TF_CONF.EDITOR) {
				ITypoFlash(TF_CONF.EDITOR).unregisterGlue(this);
			}
			
		}
		
		/*
		 * Override to use weak reference by default. Easier to clean our from memory that way.
		 */ 
		override public function addEventListener(_type:String, _listener:Function, _useCapture:Boolean = false, _priority:int = 0, _useWeakReference:Boolean = true):void {
			super.addEventListener(_type, _listener, _useCapture, _priority, _useWeakReference)
		}
		
		/*
	

         

        net.typoflash.Glue = v1;
        var v2 = v1.prototype;
        v2.toString = function () {
          return 'Glue';
        };


        v2.__set__editor = function (k) {
          _TFeditor = k;
          return __get__editor();
        };

        v2.__get__editor = function () {
          return _TFeditor;
        };

        v2.__set__confEditor = function (k) {
          _TFconfigurable.confEditor = k;
          return __get__confEditor();
        };

        v2.__get__confEditor = function () {
          return _TFconfigurable.confEditor();
        };




        v2.__set__listIndex = function (k) {
          _TFlistIndex = k;
          return __get__listIndex();
        };

        v2.__get__listIndex = function () {
          return _TFlistIndex;
        };

        v2.__set__editableFields = function (o) {
          var v4 = {};
          var v2 = 0;
          while (v2 < o.length) {
            if (_allowedEditableFields[o[v2]] != 1) {
              net.typoflash.utils.Debug.trace('Glue error in editable fields. Field \'' + o[v2] + '\' not permitted.');
              delete o[v2];
            } else {
              v4[o[v2]] = true;
            }
            ++v2;
          }
          _editableFields = v4;
          return __get__editableFields();
        };

        v2.__get__editableFields = function () {
          return _editableFields;
        };





        v2.__set__enabled = function (k) {
          _TFenabled = k;
          if (!k) {
            _TFpen._alpha = 20;
            _TFpen.bg.useHandCursor = false;
          } else {
            _TFpen._alpha = 100;
            _TFpen.bg.useHandCursor = true;
          }
          return __get__enabled();
        };

        v2.__get__enabled = function () {
          return _TFenabled;
        };



        v2.onGetMotherload = function (m) {
          if (_externallyEdited) {
            refresh();
          }
          _externallyEdited = false;
        };

        v2.onExternalEdit = function (o) {
          if (o.data == _TFkey) {
            _externallyEdited = true;
          }
        };




        v2._onGetMediaFromCategory = function (o) {
          if (o.data.menuId != __get__key()) {
            return undefined;
          }
          net.typoflash.utils.Debug.trace('Glue onGetMediaFromCategory ' + __get__key() + ', cats: ' + _TFdata.media_category);
          _TFdata.mediaFromCategory = o.data.categories;
          _TFdata.mediaCategoryFlatlist = o.data.flatlist;
          _TFconfigurable.TFdata = _TFdata;
          o = {};
          o.type = 'onGetMediaFromCategory';
          o.target = this;
          o.data = _TFdata;
          dispatchEvent(o);
        };

        v2._onGetMedia = function (o) {
          if (o.data.menuId != __get__key()) {
            return undefined;
          }
          net.typoflash.utils.Debug.trace('Glue onGetMedia ' + __get__key() + ', media length: ' + o.data.media.length);
          _TFdata.mediaRecords = o.data.media;
          _TFconfigurable.TFdata = _TFdata;
          o = {};
          o.type = 'onGetMedia';
          o.target = this;
          o.data = _TFdata;
          dispatchEvent(o);
        };

        v2.__set__tween = function (s) {
          if (s) {
            addEventListener('onTweenChange', _TFconfigurable);
            addEventListener('onTweenComplete', _TFconfigurable);
          } else {
            removeEventListener('onTweenChange', _TFconfigurable);
            removeEventListener('onTweenComplete', _TFconfigurable);
          }
          _tweenPhysicalProps = s;
          return __get__tween();
        };

        v2.__get__tween = function () {
          return _tweenPhysicalProps;
        };

        v2.tweenPhysicalProps = function (o) {
          _TFconfigurable[_physicalProps._width] = _TFcurr._width + (_TFfin._width - _TFcurr._width) * o.width;
          _TFconfigurable[_physicalProps._height] = _TFcurr._height + (_TFfin._height - _TFcurr._height) * o.height;
          _TFconfigurable[_physicalProps._x] = _TFcurr._x + (_TFfin._x - _TFcurr._x) * o.x;
          _TFconfigurable[_physicalProps._y] = _TFcurr._y + (_TFfin._y - _TFcurr._y) * o.y;
          _TFconfigurable[_physicalProps._rotation] = _TFcurr._rotation + (_TFfin._rotation - _TFcurr._rotation) * o.y;
          var v3 = {};
          v3.type = 'onTweenChange';
          v3.target = this;
          v3.data = o.data;
          dispatchEvent(v3);
          v3.type = 'updatePenOnTweenChange';
          _global.TF.EDITOR.dispatchEvent(v3);
        };

        v2.tweenPhysicalPropsComplete = function (o) {
          var v3 = {};
          v3.type = 'onTweenComplete';
          v3.target = this;
          v3.data = o.data;
          dispatchEvent(v3);
          v3.type = 'updatePenOnTweenComplete';
          _global.TF.EDITOR.dispatchEvent(v3);
        };

        v2.unregister = function () {
          removeEventListener('onData', _TFconfigurable);
          removeEventListener('onGetMediaFromCategory', _TFconfigurable);
          removeEventListener('onGetMedia', _TFconfigurable);
          ContentRendering.removeEventListener('_onGetMedia', this);
          ContentRendering.removeEventListener('_onGetMediaFromCategory', this);
          ContentRendering.removeEventListener('onClearCache', this);
          ContentRendering.removeEventListener('onParsePageData', this);
          _global.TF.CONTENT_EDITING.removeEventListener('onStorePageData', this);
          _global.TF.CONTENT_EDITING.removeEventListener('onDeletePageData', this);
          _global.TF.CORE_EVENTS.removeEventListener('onBELoginStatus', this);
          _global.TF.EDITOR.unregisterObject(this);
          _oldOnUnload();
        };

        v2.onBELoginStatus = function (obj) {
          if (obj.status == true) {
            if (_global.TF.CONF.ASSOCIATIVE_LIST[_TFkey] != this) {
            }
          } else {
            if (obj.status != 'pending') {
            }
          }
        };


		*/
	}
	
}