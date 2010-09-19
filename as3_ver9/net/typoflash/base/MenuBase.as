package net.typoflash.base{
	
	/**
	 * ...
	 * @author Borg
	 */
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import net.typoflash.crypto.MD5;
	import net.typoflash.events.CoreEvent;
	import net.typoflash.events.RenderingEvent;
	import net.typoflash.events.EditingEvent;
	import net.typoflash.ContentRendering;
	import net.typoflash.datastructures.TFPageRequest;
	import net.typoflash.datastructures.TFMenuRequest; 
	import net.typoflash.datastructures.TFMotherload;
	import net.typoflash.datastructures.TFMenuItem;
	import net.typoflash.templates.menus.MenuItem;
	import net.typoflash.utils.Debug;
    import flash.net.navigateToURL;
    import flash.net.URLRequest;
	import flash.display.StageAlign;
	
	
	public class MenuBase extends Configurable implements IMenu{
		public var _disablePhysicalConfig:Boolean = true;
        public var nodeFromRootline:Object;
        public var nodeFromUid:Object;
        public var nodeFromAlias:Object;
        public var target:String = '_flash';
        
        public var menuData = null;
		public var menuXML = XML;
        public var FEloginStatus:Boolean= false;

		public var activeNode:XML;
		public var retrievePage:Boolean = true;
		public var autoload:Boolean = true;
		
		protected var _cacheCleared = false;

		
		//visual menu object
		public var view:DisplayObject;
		
		
		protected var _rootPid:uint;
		protected var _rootAlias:String;
		protected var _menuId:String;
		
		// Some generic graphical properties, use as you please
		protected var _useMedia:Boolean = false;//Load icons from media attributes
		protected var _showIcons:Boolean = false;
		protected var _fixedDimensions:Boolean = true;//If true individual item dimensions will have to fit inside box, refers to WHOLE menu, not individual items. 
		protected var _fixedItemDimensions:Boolean = false;//Individual items. Used in conjunction with itemWidth
		protected var _itemPadding:int=0;//distance between text and border
		protected var _itemMargin:int = 0;//distance between menu items. If more specific settings required extend in subclass
		protected var _itemWidth:int = 100;//for fixed with items
		protected var _align:String = StageAlign.TOP_LEFT;
		
		public var ItemClasses:Array;//supply the classes that define the behaviour of items at every level. 
		public var ItemSkins:Array;
		public var dynamicFonts:Array;//if set must correspond to the index of the dynamic font to be used at each level
		
		
		protected var _currentLevel:uint=0;//the level in the hierarchical menu currently rendered
		
		public function MenuBase(){


			_menuId = name;
			//TFeditorClass = EditingEvent.MODE_MENU;
			//ContentRendering.addEventListener(RenderingEvent.ON_TEMPLATE_ADDED_TO_STAGE, _addedToStage);
			//Menu Item Activated event deals with calls from other menus
			ContentRendering.addEventListener(RenderingEvent.ON_MENU_ITEM_ACTIVATED, onMenuItemActivated);
			
			ContentRendering.addEventListener(RenderingEvent.ON_GET_MENU,onGetMenu);
			//ContentRendering.addEventListener(RenderingEvent.ON_SET_LANGUAGE,onSetLanguage);
			
        };
		/*
		 * Important to wait for template to have time to set configuration
		 * and glue to set key. Therefore this is called from glue.
		 */
		
		public function init() {
		
		
		}

        public function openRootline(node:XML) {};

  
		


        public function onClick(node:XML) {
			Debug.output("[MenuBase.onClick uid: " + node.@uid +" doktype: "+node.@doktype + " url: "+node.@url + " urltype: "+node.@urltype + " target: "+ node.@target+"]");
			
			/*Checks what page to retrieve if any*/

			/*Doktypes
			1= standard
			2 = advanced
			3 = external shortcut
			4 = internal shortcut
			5 = not in menu
			6 = 
			7 = mount point
			254 = sysfolder
			255 = trash
			
			shortcut points to other page
			shortcut_mode:
			0 = page itself
			1 = first subpage
			2 = random subpage (yeah right, very useful)
			
			mount_pid = replace with subpage from here
			mount_pid_ol = or with the page itself if this is set*/		
			
			
			if (int(node.@doktype) == 4) {
				  //this is a shortcut to internal page
				if (node.@shortcut > 0 && node.@shortcut_mode >= 1) {
					node = menuXML.elements().(@uid == node.@shortcut).children()[0];
				} else {
					if (int(node.@shortcut) > 0) {
						//replace with the page
						node = menuXML.elements().(@uid == node.@shortcut)[0];
					} else {
						if (int(node.@shortcut_mode) >= 1) {
							//Look to own subpages
							node = node.children()[0];
						} else {
							//Pretty much a mistake..a shortcut to itself. Will get id below	
						}
					}
				}
			}
			/*
			 * 		urltype 
			 * 		0 : blank
			 * 		1 : http
			 * 		2 : ftp
			 * 		3 : mailto
			 * 		4 : https
			 */
			if (retrievePage && int(node.@uid) > 0) {
				if (int(node.@doktype) != 3) {
					ContentRendering.getPage(new TFPageRequest(node.@uid,TF_CONF.LANGUAGE,node.@alias));
				} else if (int(node.@doktype) == 3 && String(node.@url).length > 0) {
					if (node.@target.length > 1) {
						//External url
						var targ = node.@target;
					} else {
						targ = '_blank';
					}
					var urltype = ["","http://","ftp://","mailto:","https://"]
					var request:URLRequest = new URLRequest(urltype[node.@urltype]+ node.@url);
					navigateToURL(request, targ);
					Debug.output("MenuBase.navigateToURL " + request);
				}
			}
			  
			if (target != '_flash') {
				request = new URLRequest(TF_CONF.HOST_URL + '?id=' + node.@uid + '&L=' + TF_CONF.LANGUAGE);
				navigateToURL(request, target);
			}
			activeNode = node;
			/*
			 * Send on to items. This intercepts the call first to check stuff.
			 */
			dispatchEvent(new RenderingEvent(RenderingEvent.ON_SET_ACTIVE, node));
			
			/*
			 * Then inform external listener to this menu
			 */		
			
			dispatchEvent(new RenderingEvent(RenderingEvent.ON_CHANGE, node));
			
			/*
			 * Finally this dispatch is to keep all menus synchronised if there are more than one
			 */ 
			ContentRendering.dispatchEvent(new RenderingEvent(RenderingEvent.ON_MENU_ITEM_ACTIVATED,node));
        };
		
		
		/*
		 * On set page is called in the ContentRendering.getPage. Confusing? Well, if a getPage call
		 * is sparked by browser history or other menu this menu doesn´t know what to show. It tries to
		 * find the corresponding page in the menu and display that.
		 */ 
		
		override protected function onSetPage(e:RenderingEvent) {
			var p:TFPageRequest = TFPageRequest(e.data);
			try{
				setPage(p);
			}
			catch (e:Error)	{
				trace("Menu not loaded yet, cannot call setPage")
			}
			
		}
		
		/*
		 * Call from outside (not menu hopefully, cause menus are more powerful and can send exact rootline)
		 * Probably browser history
		 */ 
		public function setPage(p:TFPageRequest) {
		   /*trace("MenuBase.setPage " +p.id + nodeFromAlias[p.alias].@label) 
			for (var n in nodeFromAlias) {
				trace(n +  " "+nodeFromAlias[n].@label)
			}*/
			//Need to check if we got the page and if so set to that rootline and activate it  
			if (nodeFromUid[p.id] == activeNode) {
				//does nothing...a page with this uid is already active..but reopens rootline
				dispatchEvent(new RenderingEvent(RenderingEvent.ON_SET_ACTIVE, activeNode));
				openRootline(activeNode);
				//trace("Case 1")
			} else if (nodeFromAlias[p.alias] == activeNode && p.id > 0 && activeNode != null) {
				//does nothing...a page with this uid is already active..but reopens rootline
				dispatchEvent(new RenderingEvent(RenderingEvent.ON_SET_ACTIVE, activeNode));
				openRootline(activeNode);
				//trace("Case 2")
            } else if (nodeFromUid[p.id] != null) {
				//If we can't find that try to find the page at least and activate the rootline to that
                activeNode = nodeFromUid[p.id];
                dispatchEvent(new RenderingEvent(RenderingEvent.ON_SET_ACTIVE, activeNode));
                openRootline(activeNode);
				//trace("Case 3")
           } else if (nodeFromAlias[p.alias] != null) {
				//If we can't find that try to find the page at least and activate the rootline to that
                activeNode = nodeFromUid[p.id];
                dispatchEvent(new RenderingEvent(RenderingEvent.ON_SET_ACTIVE, activeNode));
                openRootline(activeNode);
				//trace("Case 3")	
            } else {
				//If page not found in this menu, menu needs to be reset
                activeNode = null;
                dispatchEvent(new RenderingEvent(RenderingEvent.ON_SET_ACTIVE, activeNode));
                reset();
				//trace("Case 4")
            }
        };
		
		/*
		 * Calls from other menus are patched through contentrendering class
		 * The benefit in comparison to browser history or links in pages is
		 * that the event sends node as data that can be used to get exact rootline
		 * of page.
		 */ 
        public function onMenuItemActivated(e:RenderingEvent) {
			var node = XML(e.data);
			if (node.@menuId != menuId) {
				if (activeNode == null) {
					trace("no active node")
					return;
				}
				//Call from another menu
				//Need to check if we got the page and if so set to that rootline and activate it ..if not already active
				if (node.@rootline == activeNode.@rootline) {
					//does nothing...a page with this uid is already active..but reopens rootline		
					dispatchEvent(new RenderingEvent(RenderingEvent.ON_SET_ACTIVE, activeNode));
					openRootline(activeNode);
				} else if (nodeFromRootline[node.@rootline] != null) {
					//First try to find the exact rootline in this menu
					//We can't search for the same node, since if comes from another xml document, and wouldn't be the same				
					activeNode = nodeFromRootline[node.@rootline];
					dispatchEvent(new RenderingEvent(RenderingEvent.ON_SET_ACTIVE, activeNode));
					openRootline(activeNode);
				}else if (nodeFromUid[node.@uid] != null && nodeFromUid[node.@uid] != menuXML.firstChild) {
					//If we can't find that try to find the page at least and activate the rootline to that
					activeNode = nodeFromUid[node.@uid];
					dispatchEvent(new RenderingEvent(RenderingEvent.ON_SET_ACTIVE, activeNode));
					openRootline(activeNode);
                }else if (nodeFromAlias[node.@alias] != null && nodeFromUid[node.@uid] != menuXML.firstChild) {
                    activeNode = nodeFromAlias[node.@alias];
					dispatchEvent(new RenderingEvent(RenderingEvent.ON_SET_ACTIVE, activeNode));
                    openRootline(activeNode);
                }else {
				//If page not found in this menu, menu needs to be reset
                    activeNode = null;
					dispatchEvent(new RenderingEvent(RenderingEvent.ON_SET_ACTIVE, activeNode));
                    reset();
                  
                }
              
            }
        };

        public function onMenuItemOpened(obj) {};

        public function onMenuItemClosed(obj) {};

        public function onFELoginStatus(obj) {
          /*if (obj.status != FEloginStatus && obj.status != 'pending') {
            refresh();
            FEloginStatus = obj.status;
          }*/
        };

        public function refresh() {
			ContentRendering.getMenu(new TFMenuRequest(menuId,rootPid,TF_CONF.LANGUAGE,rootAlias));
        };

        override protected function onSetLanguage(e:RenderingEvent) {
          //close();
          refresh();
        };

        public function onGetMenu(e:RenderingEvent) {
			try {
				//Debug.output("menuId "+menuId+ "  " +e.data.menuId )	
				if (e.data.menuId != menuId) {
					//doesnt concern me.
					return;
				}
			}
			catch (e:Error)	{
				Debug.output("menuId not set " +this)	
			}
			ContentRendering.registerMenu(this);//register menu now when ContentRendering.page.TEMPLATE.menus is sure to be set
			
			menuData = e.data;
			nodeFromRootline = {};
			nodeFromUid = {};
			nodeFromAlias = { };
			try{
				menuXML = array2xml(menuData);
				Debug.output(menuXML.toXMLString())
			}
			catch (e:Error)	{
				Debug.output(e)
			}
			render();
		

			ContentRendering.dispatchEvent(new RenderingEvent(RenderingEvent.ON_MENU_PARSED));
			
			/*if (activeNode.@uid != ContentRendering.page.HEADER.uid && ContentRendering.page.HEADER.uid > 0) {
				setPage(new TFPageRequest(ContentRendering.page.HEADER.uid,TF_CONF.LANGUAGE));
			}else */
			
			try{
				if (ContentRendering.page.HEADER.uid > 0) {
					setPage(new TFPageRequest(ContentRendering.page.HEADER.uid,TF_CONF.LANGUAGE));
				} else {
					Debug.output('Menu doesnt know what to show. ContentRendering.page.HEADER.uid: ' + ContentRendering.page.HEADER.uid);
				}
				  
				if (TF_CONF.MOTHERLOAD.mode == TFMotherload.MODE_ON_GET_MENU) {
					Debug.output('MenuBase requesting motherload. TFMotherload.MODE_ON_GET_MENU');
					var pageRequest = new TFPageRequest(rootPid,TF_CONF.LANGUAGE);
					pageRequest.getRecords = TF_CONF.MOTHERLOAD.getRecords;
					pageRequest.wrap = TF_CONF.PAGE.wrap;
					ContentRendering.getMotherload(pageRequest);
				}
			}
			catch (e:Error){
				//in some testing situations not always set
			}
        };
		/*
		 * Why is menu listening to motherload??
		 */ 
       override protected function onGetMotherload(e:RenderingEvent) {
		   if (activeNode != null) {
				if (activeNode.@uid != ContentRendering.page.HEADER.uid && ContentRendering.page.HEADER.uid > 0) {
					var p:TFPageRequest = new TFPageRequest(ContentRendering.page.HEADER.uid, TF_CONF.LANGUAGE);
					setPage(p);
				}
		   }else {
				p = new TFPageRequest(ContentRendering.page.HEADER.uid, TF_CONF.LANGUAGE);
				setPage(p);
		   }
          if (_cacheCleared) {
            onClick(activeNode);
            _cacheCleared = false;
          }
        };
		
		/*
		 * 
		 */ 
        public function isInActiveRootline(node):Boolean {
			try {
				return activeNode.@rootline.indexOf(node.@rootline) == 0;
			}
			catch (e:Error){}
			return false;
        };

        public function render() {
			throw new Error("MenuBase.render must be overrided in extension class");
        };
		
		
		override public function get height():Number {
			//careful with there settings as they can cause infinite loops unless scrollpane is initialised
			return view.height;
		}
		override public function get width():Number {
			return view.width;
		}
		override public function set height(v:Number):void {
			view.height = v;
		}
		override public function set width(v:Number):void {
			view.width = v;
		}		
		
		public function get rootPid():uint { return _rootPid; }
		
		public function set rootPid(value:uint):void{
			_rootPid = value;
			var pageRequest = new TFPageRequest(rootPid,TF_CONF.LANGUAGE);
			pageRequest.getRecords = TF_CONF.MOTHERLOAD.getRecords;
			pageRequest.wrap = TF_CONF.PAGE.wrap;
			//TF_CONF.MOTHERLOAD.pageRequest  = pageRequest;
			if (autoload) {
				refresh();
			}	
			
		}
		public function get rootAlias():String { return _rootAlias; }
		
		public function set rootAlias(value:String):void {
			_rootAlias = value;
			try{
			trace(TF_CONF.LANGUAGE)
			}
			catch (e:Error)
			{
				trace("COnf not set?")
			}
			var pageRequest = new TFPageRequest(rootPid,TF_CONF.LANGUAGE,_rootAlias);
			pageRequest.getRecords = TF_CONF.MOTHERLOAD.getRecords;
			pageRequest.wrap = TF_CONF.PAGE.wrap;
			//TF_CONF.MOTHERLOAD.pageRequest  = pageRequest;
			if (autoload) {
				refresh();
			}		
			
		}
		
		
		public function get menuId():String { return _menuId; }
		
		public function set menuId(value:String):void {
			name = _menuId;
			_menuId = value;
		}
		
		public function get fixedDimensions():Boolean { return _fixedDimensions; }
		
		public function set fixedDimensions(value:Boolean):void 
		{
			_fixedDimensions = value;
		}
		
		public function get showIcons():Boolean { return _showIcons; }
		
		public function set showIcons(value:Boolean):void 
		{
			_showIcons = value;
		}
		
		public function get useMedia():Boolean { return _useMedia; }
		
		public function set useMedia(value:Boolean):void 
		{
			_useMedia = value;
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
		
		public function get itemWidth():int { return _itemWidth; }
		
		public function set itemWidth(value:int):void {
			_itemWidth = value;
		}
		
		public function get fixedItemDimensions():Boolean { return _fixedItemDimensions; }
		
		public function set fixedItemDimensions(value:Boolean):void {
			_fixedItemDimensions = value;
		}
		

		
        public function reset() {
			render();	
		};

        override protected function onClearCache(e:RenderingEvent) {
          Debug.output('Becuase you cleared cache menu is refreshing');
          _cacheCleared = true;
          refresh();
        };

        public function getMenuXML() {
          return menuXML;
        };

        public function setMenuXML(x) {
          menuXML = x;
        };

        public function array2xml(o:Object):XML {
			var temp:XML = <menuitem />;

           convertSubpages(o.subpages, temp);
			if(temp.children().length()>0){
				return temp.menuitem[0];
			}else {
				//empty menu
				return temp;
			}
        };

        public function convertSubpages(p:Array, x:XML, rLine:String = '') {
          var node:XML;
          var rl;
          var i = 0;
          while (i < p.length) {
             
			//Create lookup tables
            rl = rLine + '_' + p[i].uid;
			
			
			 if (p[i].subpages.length > 0) {
				node = convertSubpages(p[i].subpages, new XML(p[i].toString()), rl);
            }else {
				node = new XML(p[i].toString());	
			}
			
            if (p[i].label == null && p[i].title != null) {
              node.@label = p[i].title;
            }
            node.@rootline = rl;
			//Create lookup tables
            rl = node.@rootline;
            nodeFromRootline[rl] = node;
            if (nodeFromUid[p[i].uid] == null) {
              nodeFromUid[p[i].uid] = node;
            }
            if (nodeFromAlias[p[i].alias] == null && p[i].alias.length > 0) {
              nodeFromAlias[p[i].alias] = node;
            }
            node.@menuId = menuId;
            node.@mRoot = name;
           
            x.appendChild(node);
            /*addEventListener('onSetActive', node);
            node.onSetActive = function (n) {
              if (n.node == this) {
                @isActive = 1;
              } else {
                @isActive = 0;
                if (@mRoot.isInActiveRootline(this)) {
                  @isOpen = 1;
                }
              }
            };*/

            ++i;
          }
          return x;
        };

        public function getRealTarget(node):XMLList {
			


          var x:XMLList;
          if (node.@doktype == 4) {
            if (node.@shortcut > 0 && node.@shortcut_mode >= 1) {
              x = menuXML.elements().(@uid == node.@shortcut).children()[0];
              return x;
            }
            if (node.@shortcut > 0) {
              x = menuXML.elements().(@uid == node.@shortcut)[0];
              return x;
            }
            if (node.@shortcut_mode >= 1) {
              x = node.children()[0];
              return x;
            }
          }
          return x;
        };




	}
	
}