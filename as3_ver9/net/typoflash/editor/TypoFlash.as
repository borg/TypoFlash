/*******************************************
* Class: 
*
* Copyright A. Borg, borg@elevated.to
*
********************************************
* Example usage:
*
*
*
********************************************/

package net.typoflash.editor{
	import com.yahoo.astra.fl.events.MenuEvent;
	import flash.events.Event;
	import flash.ui.Mouse;
	import net.typoflash.base.TemplateBase;
	import net.typoflash.datastructures.TFError;
	import net.typoflash.ui.windows.Window;
	
	
	import net.typoflash.base.ITemplateObject;
	import net.typoflash.base.ITemplate;
	import net.typoflash.base.IFrame;
	import net.typoflash.base.IMenu;
	import net.typoflash.base.IPreloader;	
	import net.typoflash.base.ConfigurableProperty;
	import net.typoflash.base.PhysicalProperties;
	import net.typoflash.base.ConfigurableProperties;
	
	import net.typoflash.Core;
	import flash.display.*; 
	import net.typoflash.datastructures.TFBackEndUser;
	import net.typoflash.datastructures.TFConfData;
	import net.typoflash.datastructures.TFData;
	import net.typoflash.events.AuthEvent;
	import net.typoflash.datastructures.TFConfig;
	import net.typoflash.Glue;
	import net.typoflash.ui.LoginBox;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import net.typoflash.utils.Debug;
	import net.typoflash.events.EditingEvent;
	import net.typoflash.ContentEditing;
	import net.typoflash.ContentRendering;

	import com.yahoo.astra.fl.controls.MenuBar;
	import com.yahoo.astra.fl.data.XMLDataProvider;	
	
	import flash.text.TextField;
    import flash.net.navigateToURL;
    import flash.net.URLRequest;
	
	import fl.controls.Button;
	import fl.controls.TextArea;
	import flash.events.MouseEvent;	
	import flash.events.Event; 
	
	import net.typoflash.ui.DepthManager;
	import net.typoflash.ui.Controls;

	public class TypoFlash extends MovieClip implements ITypoFlash{

		public var TF_CONF:TFConfig  = TFConfig.global;
		public var fileMenu:MenuBar;
		public var fileMenuData:XML;
		public var transformTool:TransformTool;
		
		private var _currentGlue:Glue;
		
		private var _editMode:String;
		private var _pageEditMode:Boolean = true;//store data on page level if true, else on template/root level

		function  TypoFlash() {
			
			if(!TF_CONF.IS_LIVE){
				TF_CONF.HOST_URL = "http://localhost:801/";
				TF_CONF.REMOTING_GATEWAY = TF_CONF.HOST_URL + 'typo3conf/ext/flashremoting/amf.php';
			}
			TF_CONF.EDITOR = this;
			transformTool = new TransformTool();
			transformTool.raiseNewTargets = false;
			transformTool.moveNewTargets = true;
			transformTool.moveUnderObjects = false;

			transformTool.registrationEnabled = true;
			transformTool.rememberRegistration = true;

			transformTool.rotationEnabled = true;
			transformTool.constrainRotation = true;
			transformTool.constrainRotationAngle = 90/4;

			transformTool.constrainScale = true;
			transformTool.maxScaleX = 2;
			transformTool.maxScaleY = 2;

			transformTool.skewEnabled = false;
			
			addEventListener(Event.ADDED_TO_STAGE, init);
			
			
		}

		private function init(e:Event) {
			//Debug.output(TF_CONF);

			/**/
			stop()
			//setting mode creates BE_AUTH
			loginBox.mode = LoginBox.MODE_BE;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			TF_CONF.BE_AUTH.addEventListener(AuthEvent.ON_LOGIN_STATUS, onLoginStatus);
			Controls.applicationTop = topBg.height;
			DepthManager.init(this);
			
			addChild(transformTool);
			saveBtn.setStyle("icon",icon_save)
			saveBtn.addEventListener(MouseEvent.CLICK, onSave);
			saveBtn.enabled = false;
			
					
			toggleModeBtn.addEventListener(MouseEvent.CLICK, togglePageEdit);
			
			//ContentEditing.addEventListener(EditingEvent.ON_STORE_PAGE_DATA, onStorePageData);
			ContentEditing.addEventListener(EditingEvent.ON_HISTORY_STORED, onStoredHistory);

			
			HistoryManager.addEventListener(EditingEvent.ON_HISTORY_CHANGED, historyChanged);

			
		}
		
		private function historyChanged(e:EditingEvent) {
			if (e.data is TFError) {
				//alert the fire dept
				Debug.output(e.data);
				saveBtn.enabled = false;
				return;
			}
			if (HistoryManager.unsavedHistory.length > 0) {
				saveBtn.enabled = true;
			}else {
				saveBtn.enabled = false;
			}
		}
		
		private function onStoredHistory(e:EditingEvent) {
			if (e.data is TFError) {
				saveBtn.setStyle("icon", icon_save);
				saveBtn.enabled = false;
				//tell HistoryManager how much of the commands were successfully stored and scrap the rest
			}else if(e.data == EditingEvent.TRUE){
				HistoryManager.makeHistory();
				saveBtn.setStyle("icon",icon_save)
			}else {
				saveBtn.setStyle("icon",icon_pending)
			}
		}	
		
		
		private function stageMouseDown(e:MouseEvent) {
			try{
				if (!currentGlue.configurable.hitTestPoint(e.stageX,e.stageY,true)) {
					//Debug.output(e.target+' is not '+currentGlue.configurable)
					currentGlue = null;
				}
			}
			catch (e:Error)
			{
				
			}
			
		}
		
		private function onStorePageData(e:EditingEvent) {
			
			if (e.data == EditingEvent.PENDING) {
				saveBtn.setStyle("icon",icon_pending)
			}else {
				saveBtn.setStyle("icon",icon_save)
			}
		}
		private function onSave(e:MouseEvent) {
			if(HistoryManager.unsavedHistory.length > 0){
				ContentEditing.storeHistory(HistoryManager.unsavedHistory);
			}
		}
		
		private function togglePageEdit(e:MouseEvent) {
			if (_pageEditMode) {
				pageEditMode = false;
			}else {
				pageEditMode = true;
			}
			
		}
		
		private function onLoginStatus(e:AuthEvent) {
			
			if (e.status == AuthEvent.TRUE) {
				createFileMenu();
				try{
					stage.addEventListener(MouseEvent.MOUSE_DOWN, stageMouseDown,false,0,true);
				}
				catch (e:Error){}
			}else {
				destroyFileMenu();
				try{
					stage.removeEventListener(MouseEvent.MOUSE_DOWN, stageMouseDown);
				}
				catch (e:Error){}				
			}
		}
		
		private function destroyFileMenu() {
			if(fileMenu){
				removeChild(fileMenu);
				fileMenu = null;
			}
		}

		
		private function createFileMenu() {
			fileMenuData =
<menus>
	<menu label="File">
		<menuitem label="New">
			<menuitem label="Page" type="check" group="colors" />
			<menuitem label="Content" type="check" group="colors" />
			<menuitem label="Component" type="check" group="colors" />
			<menuitem label="News category" type="check" group="colors" />
			<menuitem label="News item" type="check" group="colors" />
		</menuitem> 
		<menuitem label="Template settings"/>
		<menuitem label="Save all"/>
		<menuitem label="Preferences"/>
	</menu>
	<menu label="Edit">
		<menuitem label="Cut"/>
		<menuitem label="Paste"/>
		<menuitem label="Clear cache" action="clearCache"/>
	</menu>
	<menu label="View">
		< menuitem label = "Template" type = "check" selected = {String(TF_CONF.COOKIE.data['TF' + EditingEvent.MODE_TEMPLATE + 'Editable'] != false)}  action="toggleEditable" editorClass={EditingEvent.MODE_TEMPLATE}/>
		<menuitem label="Menus" type="check" selected = {String(TF_CONF.COOKIE.data['TF' + EditingEvent.MODE_MENU + 'Editable'] != false)}  action="toggleEditable" editorClass={EditingEvent.MODE_MENU}/>
		<menuitem label="Frames" type="check" selected = {String(TF_CONF.COOKIE.data['TF' + EditingEvent.MODE_FRAME + 'Editable'] != false)}  action="toggleEditable" editorClass={EditingEvent.MODE_FRAME}/>
		<menuitem label="Components" type="check" selected = {String(TF_CONF.COOKIE.data['TF' + EditingEvent.MODE_COMPONENT + 'Editable'] != false)}  action="toggleEditable" editorClass={EditingEvent.MODE_COMPONENT}/>
		<menuitem label="Template Objects" type="check" selected = {String(TF_CONF.COOKIE.data['TF' + EditingEvent.MODE_TEMPLATE_OBJECT + 'Editable'] != false)}  action="toggleEditable" editorClass={EditingEvent.MODE_TEMPLATE_OBJECT}/>
	</menu>
	<menu label="Tools">
		<menuitem label="Configuration manager" action="confManager"/>
		<menuitem label="File manager"/>
		<menuitem label="Page tree" />
		<menuitem label="Goto Typo3 backend" action="gotoBackEnd"/>
	</menu>	
	<menu label="Select">
	</menu>		
	<menu label="Help">
		<menuitem label="Visit TypoFlash.net"/>
		<menuitem label="Go to Typo3.org"  />
		<menuitem label="About TypoFlash" />
	</menu>	
</menus>

		fileMenu = new MenuBar(Sprite(this));
		fileMenu.dataProvider = new XMLDataProvider(fileMenuData);
		fileMenu.x = 70;
		fileMenu.y = 10;
		fileMenu.addEventListener(MenuEvent.ITEM_CLICK, itemSelector);/**/
		EditingEvent
		//addChild(fileMenu);
			/*
			
          this.filemenuItem.push({'label': 'File', 'data': 'file', 'subdata': [{'label': 'New component', 'data': 'addComponent', 'separatorBefore': 'true'}, {'label': 'Save all settings...', 'data': 'saveSettings', 'separatorBefore': 'true', 'subdata': [{'label': 'for this page', 'data': 'globalStorePageData'}, {'label': 'for all pages', 'data': 'globalStoreTemplateData'}]}]});
          this.filemenuItem.push({'label': 'Edit', 'data': 'edit', 'subdata': [{'label': 'Revert all', 'data': 'globalRevert'}, {'label': 'Send to centre', 'data': 'sendToCentre'}, {'label': 'Clear cache', 'data': 'clearCache', 'separatorBefore': 'true'}]});
          this.filemenuItem.push({'label': 'View', 'data': 'view', 'subdata': [{'label': 'Template', 'data': 'Template', 'type': 'tick', 'func': 'toggleVisible', 'selected': this.trueIfNotSetFalse(_global.TF.COOKIE.data.TFTemplateEditable)}, {'label': 'Frames', 'data': 'Frame', 'type': 'tick', 'func': 'toggleVisible', 'selected': this.trueIfNotSetFalse(_global.TF.COOKIE.data.TFFrameEditable)}, {'label': 'Menus', 'data': 'Menu', 'type': 'tick', 'func': 'toggleVisible', 'selected': this.trueIfNotSetFalse(_global.TF.COOKIE.data.TFMenuEditable)}, {'label': 'MovieClips', 'data': 'MC', 'type': 'tick', 'func': 'toggleVisible', 'selected': this.trueIfNotSetFalse(_global.TF.COOKIE.data.TFMCEditable)}, {'label': 'Components', 'data': 'Component', 'type': 'tick', 'func': 'toggleVisible', 'selected': this.trueIfNotSetFalse(_global.TF.COOKIE.data.TFComponentEditable)}, {'label': 'Open html version', 'data': 'gotoHtml', 'separatorBefore': 'true'}]});
          this.filemenuItem.push({'label': 'Select', 'data': 'selectObject', 'subdata': _global.TF.CONF.LIST});
          this.filemenuItem.push({'label': 'Tools', 'data': 'tools', 'subdata': [{'label': 'Go to Typo3 backend', 'data': 'gotoT3be'}, {'label': 'Debug', 'data': 'debug', 'separatorBefore': 'true', 'subdata': [{'label': 'Trace Motherload', 'data': 'traceMotherLoad'}, {'label': 'Trace Current Page', 'data': 'traceCurrentPage'}, {'label': 'Clear debug history', 'data': 'clearDebug'}]}]});
          this.filemenuItem.push({'label': 'Help', 'data': 'help', 'subdata': [{'label': 'Visit TypoFlash.net', 'data': 'gotoTypoflash', 'separatorBefore': 'true'}, {'label': 'Go to Typo3.org', 'data': 'gotoT3'}, {'label': 'About TypoFlash', 'data': 'about', 'separatorBefore': 'true'}]});
          this.knowledgeBase = new net.typoflash.base.MenuBase();
          this.knowledgeBase.mainSymbol = this.filemenu;
          this.knowledgeBase.rootPid = 'menu';
          this.knowledgeBase.onGetMenu = function (o) {
            if (o.data.menuId == this.menuId) {
              var v4 = this.mainSymbol.dataProvider.xml.getNodeBy('attributes.data', 'help');
              var v3 = this.mainSymbol.dataProvider.xml.getNodeBy('attributes.data', 'knowledgebase');
              v3.removeNode();
              var v2 = this.mainSymbol.array2xml(o.data);
              v2.firstChild.attributes.label = 'Knowledge base';
              v2.firstChild.attributes.data = 'knowledgebase';
              v4.appendChild(v2.firstChild);
            }
          };

          var v4 = {};
          v4.change = function (c) {
            if (typeof _global.TF.EDITOR[c.node.attributes.data] == 'function') {
              _global.TF.EDITOR[c.node.attributes.data]();
            } else {
              if (c.node.parentNode.attributes.data == 'selectObject') {
                _global.TF.EDITOR.loadEditor(c.node.attributes.data);
              } else {
                if (c.node.attributes.func == 'toggleVisible') {
                  _global.TF.EDITOR.toggleVisible(c.node.attributes.data, c.node.attributes.selected);
                } else {
                  if (typeof _global.TF.EDITOR['open' + c.node.attributes.label] == 'function' && String(c.node.attributes.selected) == 'true' && c.node.attributes.type == 'tick') {
                  } else {
                    if (typeof _global.TF.EDITOR['close' + c.node.attributes.label] == 'function' && String(c.node.attributes.selected) == 'false' && c.node.attributes.type == 'tick') {
                    } else {
                      if (c.node.attributes.uid > 0) {
                        this.knowledgeBase.onClick(c.node);
                      } else {
                        _global.TF.EDITOR.depthManager.alert('To do: ' + c.node.attributes.label);
                      }
                    }
                  }
                }
              }
            }
          };*/
		}	
		
		private function itemSelector(e:MenuEvent) {
			Debug.output("itemSelector " + e.item.label);
			if (e.item.action == "gotoBackEnd") {
				var request:URLRequest = new URLRequest('/typo3');
				navigateToURL(request, '_blank');				
			}else if (e.item.action == "confManager"){
				openConfManager();
			}else if (e.item.action == "clearCache"){
				ContentRendering.clearCache();
			}else if (e.item.action == "toggleEditable") {
				toggleEditable(e.item.editorClass, Boolean(!e.item.selected));//it seems value has not yet been updated, why ! is used
			}
			

			//Controls.newWindow({title:"Promo codes", type:"ScrollPane", contentPath:null, initObj:{table:"tx_borgreferrals_promocodes", fieldNames:null, recordEditor:null, recordEditorFieldNames:null, softDelete:false}, w:380, h:250, resizeEnabled:true, closeEnabled:true, minimiseEnabled:true, vScrollPolicy:"off", hScrollPolicy:"off"});
		}
		
		public function openConfManager() {
			var w:Window = new Window();
			w.title = "Configuration manager"
			w.type = Window.TYPE_SCROLLPANE;
			w.closeEnabled = true;
			w.resizeEnabled = true;
			w.source = new ConfigurationManager();
			w.setSize(550,500)
			Controls.newWindow(w);	
			
		}
		public function get editMode():String { return _editMode; }
		
		public function set editMode(value:String):void {
			dispatchEvent(new EditingEvent(EditingEvent.ON_SET_EDIT_MODE,value));
			_editMode = value;
		}
		
		public function get currentGlue():Glue { return _currentGlue; }
		
		public function set currentGlue(value:Glue):void {
			if (!(TF_CONF.BE_USER is TFBackEndUser) || value == null) {
				dispatchEvent(new EditingEvent(EditingEvent.ON_GLUE_UNSELECTED, _currentGlue));
				transformTool.target = null;
				_currentGlue = null;
				//Debug.output("TypoFlash:Resetting currentGlue");
				return;
			}
			if (_editMode == EditingEvent.EDIT_MODE_MOVE) {
				if(transformTool.target != value.configurable && !value.disablePhysicalConfig){
					transformTool.target = DisplayObject(value.configurable);
					transformTool.registration = transformTool.boundsCenter;

				}
			}
			Debug.output("TypoFlash:currentGlue: "+value.key);
			_currentGlue = value;
			dispatchEvent(new EditingEvent(EditingEvent.ON_GLUE_SELECTED,_currentGlue));
		}
		
		public function get pageEditMode():Boolean { return _pageEditMode; }
		
		public function set pageEditMode(value:Boolean):void {
			_pageEditMode = value;
			if (_pageEditMode){					
				toggleModeBtn.label = "P";
			}else {
				toggleModeBtn.label = "T";
			}
		}
		
		
		/*
		 * Adding all dynamic functions dealing with editing. No need to keep them in Glue class, and more
		 * scalable letting Editor add new properties for new types of editing.
		 */
		
		public function registerGlue(glue:Glue):void {
			Debug.output('TF registering glue '+glue.configurable)
			
			glue._orgMouseChildren = MovieClip(glue.configurable).mouseChildren;
			glue._orgMouseEnabled = MovieClip(glue.configurable).mouseEnabled;
			
			
			

			glue.getNewConfData = function():TFConfData {
				var confData:TFConfData = new TFConfData();
				var v = glue.physicalProperties.enabledList.length;
				var prop:ConfigurableProperty;
				var n:String;
			
				while (v--) {
					prop =  glue.physicalProperties.enabledList[v] as ConfigurableProperty;
					n = prop.name;
					//check if value exists
					if (glue.data.CONFIGURATION.physical[n]) {
						//is it changed?
						if (glue.data.CONFIGURATION.physical[n] != glue.configurable[n]) {
							//if so save
							confData.physical[n] = glue.configurable[n];
						}
					}else {
						//if no previous entry create one
						confData.physical[n] = glue.configurable[n];
					}
				}
				
				v = glue.configurableProperties.enabledList.length;
				//store any 
				while (v--) {
					prop =  glue.configurableProperties.enabledList[v] as ConfigurableProperty;
					n = prop.name;
					//check if value exists
					if (glue.data.CONFIGURATION.meta[n]) {
						//is it changed?
						if (glue.data.CONFIGURATION.meta[n] != glue.configurable[n]) {
							//if so save
							confData.meta[n] = glue.configurable[n];
						}
					}else {
						//if no previous entry create one
						confData.meta[n] = glue.configurable[n];
					}
				}
				
				return confData;
			}
			
			/*
			 * Compare new values with stored data values to see if they have been changed
			 */ 
			glue.hasChanged = function():Boolean {
				
				
				try {
					var confData:TFConfData = new TFConfData();
					var v = glue.physicalProperties.enabledList.length;
					var prop:ConfigurableProperty;
					var n:String;
					Debug.output("Checking list "+ glue.physicalProperties.enabledList)
					while (v--) {
						prop =  glue.physicalProperties.enabledList[v] as ConfigurableProperty;
						n = prop.name;
						Debug.output('Check if changed '+ n + ' '+ glue.configurable[n])
						//check if value exists
						if (glue.data[n]) {
							//is it changed?
							if (glue.data[n] != glue.configurable[n]) {
								//if so save
								return true;
							}
						}else {
							//if no previous entry create one
							return true;
						}
					}
				}
				catch (e:Error)
				{
					Debug.output('First error')
				}
				
				try {
					v = glue.configurableProperties.enabledList.length;
					//check meta data
					while (v--) {
						prop =  glue.configurableProperties.enabledList[v] as ConfigurableProperty;
						n = prop.name;
						//check if value exists
						if (glue.data[n]) {
							//is it changed?
							if (glue.data[n] != glue.configurable[n]) {
								//if so save
								return true;
							}
						}else {
							//if no previous entry create one
							return true;
						}
					}
				}
				catch (e:Error)
				{
					Debug.output('Second error');
				}
				return false;		
			}			
			
			
			
			
			
			
			
			
			
			
			
			
			glue.onGlueSelected = function(e:EditingEvent) {
				if (currentGlue == glue) {
					MovieClip(glue.configurable).mouseChildren = MovieClip(glue.configurable).mouseEnabled = false;
				}else {
					
				}
				
			}
		
		
			glue.onGlueUnselected = function(e:EditingEvent) {
				if (e.data == glue) {
					MovieClip(glue.configurable).mouseEnabled = glue._orgMouseEnabled;
					MovieClip(glue.configurable).mouseChildren = glue._orgMouseChildren;
					try{
						if (glue.hasChanged()) {
							Debug.output(glue +' is unselected and has changes');
							//Debug.output(glue.getNewConfData());
							//Prepare database object. Stored on language
							var o = { };
							o.data = glue.getNewConfData();
							o.key = glue.key;
							o.L = TF_CONF.LANGUAGE;
							
							if (_pageEditMode) {
								//store data on page
								o.id = TF_CONF.PID;
								HistoryManager.addItem(new HistoryItem(glue.key, glue.toString(), "storePageData", [o]));
							}else if(glue.configurable is ITemplateObject) {
								//store data on template level...only applicable to non components, ie. template objects
								o.id = ContentRendering.page.TEMPLATE.template_pid;
								HistoryManager.addItem(new HistoryItem(glue.key, glue.toString(), "storeTemplateData", [o]));
		
							}
						}else {
							Debug.output(glue +' is unselected and has NO changes');
						}
					}
					catch (e:Error)
					{
						Debug.output("Error in hasChanged etc")
					}
				}else {
					//Debug.output('Some glue is unselected but aint me: '+glue);
				}
			}	
			glue.onSelectConfigurable = function(e:MouseEvent) {
				if (currentGlue != glue) {
					currentGlue = glue;
					e.stopImmediatePropagation();
				}
			}
			glue.configurable.addEventListener(MouseEvent.MOUSE_DOWN, glue.onSelectConfigurable, false, 0, true);
		
			DisplayObject(TF_CONF.EDITOR).addEventListener(EditingEvent.ON_GLUE_SELECTED, glue.onGlueSelected, false, 0, true);
			DisplayObject(TF_CONF.EDITOR).addEventListener(EditingEvent.ON_GLUE_UNSELECTED, glue.onGlueUnselected, false, 0, true);
		
			//DisplayObject(TF_CONF.CORE).addEventListener(AuthEvent.ON_LOGIN_STATUS, glue.onBELoginStatus,false,0,true);
				
		
			
				
				
			glue.onEnableGlue = function (o) {
			 
			};




			glue.revert = function () {
				glue.apply();
			};
			/*
			glue.storePageConf = function (o:Object) {
				glue.addToConfObject(o);
				glue.storePageData();
			};

			glue.storeTemplateConf = function (o:Object) {
				glue.addToConfObject(o);
				glue.storeTemplateData();
			};

			glue.addToConfObject = function (o:Object) {
				if (glue.data.conf == null) {
					glue.data.conf = {};
				}
				for (var n in o) {
					glue.data.conf[n] = o[n];
				}
			};

			glue.storePageData = function (o:Object = null) {
				var confData:TFConfData = new TFConfData();
				
				
				
				if (!glue.disablePhysicalConfig) {
					for (var n in glue.physicalProperties.enabledList) {
						if (Math.abs(o[n]) <= 0) {
							o[n] = glue.configurable[glue.physicalProps[n]];
						}
					}
				}
				if (glue.data.conf != null) {
						o.conf = glue.data.conf;
				}
				ContentEditing.storePageData(glue.key, o, TF_CONF.PID);
			};

			glue.storeTemplateData = function (o:Object=null) {
				if (o == null) {
					o = {};
				}
				if (!glue.disablePhysicalConfig) {
					for (var n in glue.physicalProps) {
						if (Math.abs(o[n]) <= 0) {
							o[n] = glue.configurable[glue.physicalProps[n]];
						}
					}
				}
				if (glue.data.conf != null) {
					o.conf = glue.data.conf;
				}
				ContentEditing.storePageData(glue.key, o);
			};
			*/
			
		}

		/*
		 * Remove all references made from Editor
		 */ 
				
		public function unregisterGlue(glue:Glue):void {
			Debug.output('TF unregistering glue ' + glue.configurable)
			try{
				glue.configurable.removeEventListener(MouseEvent.MOUSE_DOWN, glue.onSelectConfigurable);
				DisplayObject(TF_CONF.EDITOR).removeEventListener(EditingEvent.ON_GLUE_SELECTED, glue.onGlueSelected);
				DisplayObject(TF_CONF.EDITOR).removeEventListener(EditingEvent.ON_GLUE_UNSELECTED, glue.onGlueUnselected);		
			}
			catch (e:Error){}
			delete glue._orgMouseChildren;
			delete glue._orgMouseEnabled;
			delete glue.getNewConfData;
			delete glue.hasChanged;
			delete glue.onGlueSelected;
			delete glue.onGlueUnselected;
			delete glue.onSelectConfigurable;
			delete glue.onEnableGlue;
			delete glue.revert;
			
		

			
		}
		
		
		
		private function toggleEditable(itemType:String, status:Boolean)   {
			Debug.output("TypoFlash.toggleEditable " + itemType + " " +status)
			TF_CONF.COOKIE.setData("TF" + itemType + "Editable", status);
			dispatchEvent(new EditingEvent(EditingEvent.ON_GLUE_EDITABLE,itemType));
			
			
		} 		
		
		
	};

}