package net.typoflash {
	
	/**
	 * ...
	 * @author Borg
	 */

	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	import flash.events.Event;
	import net.typoflash.base.FrameBase;
	import net.typoflash.base.MenuBase;
	import net.typoflash.datastructures.TFConfig;
	import net.typoflash.datastructures.TFError;
	import net.typoflash.datastructures.TFMenu;
	import net.typoflash.datastructures.TFMotherload;
	import net.typoflash.datastructures.TFPage;
	import net.typoflash.datastructures.TFPageRequest;
	import net.typoflash.datastructures.TFMenuRequest;
	import net.typoflash.datastructures.TFTemplate;
	import net.typoflash.events.EditingEvent;
	
	import net.typoflash.events.CoreEvent;
	import net.typoflash.events.RemotingEvent;
	import net.typoflash.events.RenderingEvent;
	import flash.net.Responder;
	import net.typoflash.remoting.RemotingService;

	
	import net.typoflash.utils.Debug;
	import net.typoflash.deeplinking.SWFAddress;
	import net.typoflash.deeplinking.SWFAddressEvent;
	
	
	public class ContentEditing {
		
		
		private static var TF_CONF:TFConfig = TFConfig.global;
		private static var _service:RemotingService;
		
		private static var _coreListenerAdded:Boolean = false;
		private static var dispatcher:EventDispatcher;
		
		
		private static function addCoreListeners(){
			if (_coreListenerAdded) {
				return;
			}

			try {
				
			//This is fired from javascript. Check in core.as where it is used instead of including ContentRendering
			/*TF_CONF.CORE.addEventListener(CoreEvent.ON_BROWSER_HISTORY, onBrowserHistory);
			TF_CONF.CORE.addEventListener(CoreEvent.ON_EXT_PAGE_STATE, onExtPageState);
			TF_CONF.CORE.addEventListener(CoreEvent.ON_EXT_TEMPLATE_STATE, onExtTemplateState);
			*/
			//addEventListener(TFErrorEvent.ON_REMOTING_ERROR, handleRemotingError);
			}
			catch (e) {
			//core only when live	
			}
			_coreListenerAdded = true;

		}
		
		private static function call(func:String, params:Object, callback:Function) {
			if (_service == null && TF_CONF.REMOTING_GATEWAY != '' ) {
				_service = new RemotingService(TF_CONF.REMOTING_GATEWAY);
			}
			//same fault function for all calls
			
			if (TF_CONF.USE_SWX) {
               /*
				* Currently disabled
				
				var v5 = new net.typoflash.datahandling.SWX();
                v5.gateway = TF_CONF.SWX_GATEWAY + '?cmd=getPage&id=' + pObj.id + '&L=' + pObj.L;
                v5.encoding = 'POST';
                v5.result = [this, 'handleGetPage'];
                v5.error = [this, 'fallBack'];
                v5.name = 'Page data';
                var v6 = {};
                v6.serviceClass = 'typoflash.remoting.contentrendering';
                v6.method = 'getPage';
                v6.args = [pObj];
                Debug.output('Get page ' + TF_CONF.PID + ' in lang ' + TF_CONF.LANGUAGE + ' from server via SWX.');
                v5.call(v6);*/
			}	
				
			try{
				var responder:Responder = new Responder(callback, handleRemotingError);
				_service.call("typoflash.remoting.contentediting." + func, responder, params);
				Debug.output("typoflash.remoting.contentediting." + func);
				Debug.output(params);
			}
			catch (e:Error){
				trace("ContentRendering.call error. TF_CONF.REMOTING_GATEWAY set?" )
			
			
			}
			//Debug.output(params);
		}
					
		
	    /**
	    *   Event Dispatcher Functions
	    */
	    
	    public static function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			if (dispatcher == null) {
				dispatcher = new EventDispatcher();
				addCoreListeners();
			}
        	dispatcher.addEventListener(type, listener, useCapture, priority);
	    }
	           
	    public static function dispatchEvent(evt:Event):Boolean {
			if (dispatcher == null) {
				dispatcher = new EventDispatcher();
				addCoreListeners();
			}
	        return dispatcher.dispatchEvent(evt);
	    }
	    
	    public static function hasEventListener(type:String):Boolean {
			if (dispatcher == null) {
				dispatcher = new EventDispatcher();
				addCoreListeners();
			}
	        return dispatcher.hasEventListener(type);
	    }
	    
	    public static function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			if (dispatcher == null) {
				dispatcher = new EventDispatcher();
				addCoreListeners();
			}
	        dispatcher.removeEventListener(type, listener, useCapture);
	    }
	                   
	    public static function willTrigger(type:String):Boolean {
	        return dispatcher.willTrigger(type);
	    }
		
		
		
		
		
		
		
		
		
		
		

		public static function storePageData(key:String, data:Object, pid:int=-1, L:int=-1) {
          
			if (L == -1) {
				L = TF_CONF.LANGUAGE;
			}
			var o = { };
			o.data = data;
			o.key = key;
			o.L = L;
			
			if (pid > 0) {
				o.id = pid;
				call("storePageData",o, handleStorePageData);
			}else{
				o.id = ContentRendering.page.TEMPLATE.template_pid;
				call("storePageData",o, handleStoreTemplateData);
			}
			Debug.output('ContentEditing.StorePageData got...');
			Debug.output(o);
			dispatchEvent(new EditingEvent(EditingEvent.ON_STORE_PAGE_DATA,EditingEvent.PENDING));
  
        };

		private static function handleStorePageData(re:Object)	{
			if(re.errortype>0){
				var error = new TFError(re.errortype, re.errormsg, "storePageData");
				dispatchEvent(new EditingEvent(EditingEvent.ON_STORE_PAGE_DATA, error));
			}else if (re) {
				dispatchEvent(new EditingEvent(EditingEvent.ON_STORE_PAGE_DATA,re));
				clearCache();
			}
			Debug.output('ContentEditing.handleStorePageData got...');
			Debug.output(re);
        };

		private static function handleStoreTemplateData(re:Object)	{
			if (re.errortype > 0) {
				var error = new TFError(re.errortype, re.errormsg, "storeTemplateData");
				dispatchEvent(new EditingEvent(EditingEvent.ON_STORE_PAGE_DATA, error));
				
			}else if (re) {
				dispatchEvent(new EditingEvent(EditingEvent.ON_STORE_PAGE_DATA,re));
				clearCache();
			}
			Debug.output('ContentEditing.handleStoreTemplateData got...');
			Debug.output(re);
        };

		
		public static function storeHistory(unsavedHistory:Array) {
			call("storeHistory",unsavedHistory, handleStoreHistory);
			dispatchEvent(new EditingEvent(EditingEvent.ON_HISTORY_STORED,EditingEvent.PENDING));
  
        };
		
		private static function handleStoreHistory(re:Object)	{
			if (re.errortype > 0) {
				var error = new TFError(re.errortype, re.errormsg, "storeHistory", re.params);
				dispatchEvent(new EditingEvent(EditingEvent.ON_HISTORY_STORED, error));
			}else if (re) {
				dispatchEvent(new EditingEvent(EditingEvent.ON_HISTORY_STORED,EditingEvent.TRUE));
				clearCache();
			}
			Debug.output('ContentEditing.handleStoreHistory got...');
			Debug.output(re);
        };
	

		
       public static function deletePageData(key:String, pid:int=-1, L:int=-1) {
          var o = {};
          if (L != -1) {
            o.L = L;
          } else {
            o.L = TF_CONF.LANGUAGE;
          }
          o.key = key;
          if (pid != -1) {
            o.id = pid;
          } else {
            o.id = ContentRendering.page.TEMPLATE.template_pid;
          }
		  dispatchEvent(new EditingEvent(EditingEvent.ON_DELETE_PAGE_DATA,EditingEvent.PENDING));
		  call("deletePageData", o, handleDeletePageData);
        };

       private static function handleDeletePageData(re:Object) {
		   
		   
			if (re.errortype > 0) {
				var error = new TFError(re.errortype, re.errormsg, "storeHistory", re.params);
				dispatchEvent(new EditingEvent(EditingEvent.ON_HISTORY_STORED, error));
			}else if (re) {
				dispatchEvent(new EditingEvent(EditingEvent.ON_DELETE_PAGE_DATA,EditingEvent.TRUE));
				clearCache();
			}
			Debug.output('ContentEditing.handleDeletePageData got...');
			Debug.output(re);   
		   
       };	
		
		
		
		/*
		 
		public static function storeHtmlVars(key:String, data, pid, L:int=-1) {
          var v3 = {};
          if (L != null) {
            v3.L = L;
          } else {
            v3.L = TF_CONF.LANGUAGE;
          }
          v3.data = data;
          v3.key = key;
          if (pid != null) {
            v3.id = pid;
          } else {
            v3.id = ContentRendering.page.TEMPLATE.template_pid;
          }
          var v4 = this._service.storeHtmlVars(v3);
          v4.__set__responder(new mx.rpc.RelayResponder(this, 'handleStoreHtmlVars', 'handleRemotingError'));
          v3 = {};
          v3.type = 'onStoreHtmlVars';
          v3.status = 'pending';
          this.dispatchEvent(v3);
        };

       private static function handleStoreHtmlVars(re) {
          if ((re.__get__result()).errortype > 0) {
            var v3 = {};
            v3.type = 'onStoreHtmlVars';
            v3.status = false;
            v3.errortype = (re.__get__result()).errortype;
            v3.errormsg = (re.__get__result()).errormsg;
            this.dispatchEvent(v3);
          } else {
            var v3 = {};
            v3.type = 'onStoreHtmlVars';
            v3.status = true;
            v3.data = re.result;
            this.dispatchEvent(v3);
            this.clearCache();
            var v5 = TF_CONF.HOST_URL + '?no_cache=1&random=' + getTimer() + '#L=' + TF_CONF.LANGUAGE + '&id=' + TF_CONF.PID;
            getURL(v5, '_top');
          }
        };



       private static function externalEdit(rec) {
          var v2 = {};
          v2.type = 'onExternalEdit';
          v2.data = rec;
          this.dispatchEvent(v2);
        };

       public static function getComponents(pid) {
          var v2 = {};
          if (pid != null) {
            v2.id = pid;
          }
          var v3 = this._service.getComponents(v2);
          v3.__set__responder(new mx.rpc.RelayResponder(this, 'handleGetComponents', 'handleRemotingError'));
        };

       private static function handleGetComponents(re) {
          if ((re.__get__result()).errortype > 0) {
            var v5 = {};
            v5.type = 'onError';
            v5.errorfunction = 'handleGetComponents';
            v5.errortype = (re.__get__result()).errortype;
            v5.errormsg = (re.__get__result()).errormsg;
            TF_CONF.COREdispatchEvent(v5);
          } else {
            if (re.__get__result()) {
              var v5 = {};
              v5.type = 'onGetComponents';
              v5.status = true;
              v5.data = [];
              var v3 = 0;
              while (v3 < (re.__get__result()).length) {
                v5.data.push({'label': (re.__get__result())[v3].name, 'data': (re.__get__result())[v3]});
                ++v3;
              }
              TF_CONF.COMPONENT_LIST = v5.data;
              this.dispatchEvent(v5);
            } else {}
          }
          Debug.output('ContentEditing.GetComponents got ' + TF_CONF.COMPONENT_LIST.length + ' components');
        };

       public static function getAccessiblePages() {
          var v2 = {};
          var v3 = this._service.getAccessiblePages(v2);
          v3.__set__responder(new mx.rpc.RelayResponder(this, 'handleGetAccessiblePages', 'handleRemotingError'));
        };

       private static function handleGetAccessiblePages(re) {
          if ((re.__get__result()).errortype > 0) {
            var v6 = {};
            v6.type = 'onError';
            v6.errorfunction = 'handleGetAccessiblePages';
            v6.errortype = (re.__get__result()).errortype;
            v6.errormsg = (re.__get__result()).errormsg;
            TF_CONF.COREdispatchEvent(v6);
          } else {
            if (re.__get__result()) {
              var v6 = {};
              v6.type = 'onGetAccessiblePages';
              v6.status = true;
              var v5 = [];
              var v3 = 0;
              while (v3 < (re.__get__result()).length) {
                v5.push(this.getAccessiblePageDataProvider((re.__get__result())[v3]));
                ++v3;
              }
              TF_CONF.ACCESSIBLE_PAGES = re.result;
              TF_CONF.ACCESSIBLE_PAGES.dataProvider = v5;
              this.dispatchEvent(v6);
            } else {}
          }
          Debug.output('ContentEditing.handleGetAccessiblePages got ' + TF_CONF.ACCESSIBLE_PAGES.length + ' pages');
        };

       public static function getAccessiblePageDataProvider(o) {
          var v4 = {'label': o.title, 'data': o.uid, 'type': 'tick', 'func': 'setRootPage', 'subdata': []};
          var v2 = 0;
          while (v2 < o.subpages.length) {
            v4.subdata.push(this.getAccessiblePageDataProvider(o.subpages[v2]));
            ++v2;
          }
          return v4;
        };

       public static function getMediaCategories() {
          var v2 = this._service.getMediaCategories();
          v2.__set__responder(new mx.rpc.RelayResponder(this, 'handleGetMediaCategories', 'handleRemotingError'));
        };

       private static function handleGetMediaCategories(re) {
          if ((re.__get__result()).errortype > 0) {
            var v6 = {};
            v6.type = 'onError';
            v6.errorfunction = 'handleGetMediaCategories';
            v6.errortype = (re.__get__result()).errortype;
            v6.errormsg = (re.__get__result()).errormsg;
            TF_CONF.COREdispatchEvent(v6);
          } else {
            if (re.__get__result()) {
              var v6 = {};
              v6.type = 'onGetMediaCategories';
              v6.status = true;
              var v5 = [];
              var v3 = 0;
              while (v3 < (re.__get__result()).tree.length) {
                v5.push(this.getMediaCatProvider((re.__get__result()).tree[v3]));
                ++v3;
              }
              TF_CONF.MEDIA_CATEGORIES = re.result;
              TF_CONF.MEDIA_CATEGORIES.dataProvider = new net.typoflash.userinterface.components.bDataProvider(v5, true);
              this.dispatchEvent(v6);
            } else {}
          }
          Debug.output('Loaded _global[\'TF\'][\'MEDIA_CATEGORIES\']. Root cats num:' + (re.__get__result()).tree.length);
        };

       public static function getMediaCatProvider(o) {
          var v4 = {'label': o.lang[0].title, 'data': 'tx_dam_cat_' + o.lang[0].uid, 'type': 'tick', 'func': 'toggleMediaCategory', 'subdata': []};
          var v2 = 0;
          while (v2 < o.subcat.length) {
            v4.subdata.push(this.getMediaCatProvider(o.subcat[v2]));
            ++v2;
          }
          return v4;
        };

       public static function setMediaCategories(c) {
          var v2 = this._service.setMediaCategories(c);
          v2.__set__responder(new mx.rpc.RelayResponder(this, 'handleSetMediaCategories', 'handleRemotingError'));
        };

       private static function handleSetMediaCategories(re) {
          if (re.result.errortype > 0) {
            var v4 = {};
            v4.type = 'onError';
            v4.errorfunction = 'saveContent';
            v4.errortype = re.result.errortype;
            v4.errormsg = re.result.errormsg;
            TF_CONF.COREdispatchEvent(v4);
          } else {
            if (re.result) {
              var v4 = {};
              v4.type = re.result.callback;
              v4.data = re.result;
              this.dispatchEvent(v4);
            } else {}
          }
          Debug.output('ContentEditing.handleSetMediaCategories got...');
          Debug.output(re.result);
        };

       public static function saveContent(c) {
          if (c.pid == null) {
            c.pid = ContentRendering.page.HEADER.uid;
          }
          var v4 = this._service.saveContent(c);
          v4.__set__responder(new mx.rpc.RelayResponder(this, 'handleSaveContent', 'handleRemotingError'));
        };

       private static function handleSaveContent(re) {
          if ((re.__get__result()).errortype > 0) {
            var v4 = {};
            v4.type = 'onError';
            v4.errorfunction = 'saveContent';
            v4.errortype = (re.__get__result()).errortype;
            v4.errormsg = (re.__get__result()).errormsg;
            TF_CONF.COREdispatchEvent(v4);
          } else {
            if (re.__get__result()) {
              var v4 = {};
              v4.type = 'onSaveContent';
              v4.status = true;
              v4.data = re.result;
              TF_CONF.COMPONENT_LIST.push({'label': (re.__get__result()).name, 'data': re.__get__result()});
              this.clearCache();
              this.dispatchEvent(v4);
            } else {}
          }
          Debug.output('ContentEditing.GetComponents got...');
          Debug.output(re);
        };

       public static function deleteContent(c) {
          if (c.uid <= 0) {
            Debug.output('ContentEditing.deleteContent unhappy with the following...');
            Debug.output(c);
            return undefined;
          }
          var v3 = {};
          v3.pid = ContentRendering.page.HEADER.uid;
          v3.uid = c.uid;
          var v5 = this._service.deleteContent(v3);
          v5.__set__responder(new mx.rpc.RelayResponder(this, 'handleDeleteContent', 'handleRemotingError'));
        };

       private static function handleDeleteContent(re) {
          if ((re.__get__result()).errortype > 0) {
            var v3 = {};
            v3.type = 'onError';
            v3.errorfunction = 'deleteContent';
            v3.errortype = (re.__get__result()).errortype;
            v3.errormsg = (re.__get__result()).errormsg;
            TF_CONF.COREdispatchEvent(v3);
          } else {
            if (re.__get__result()) {
              var v3 = {};
              v3.type = 'onDeleteContent';
              v3.status = true;
              v3.data = re.result;
              this.clearCache();
              this.dispatchEvent(v3);
            } else {}
          }
          Debug.output('ContentEditing.deleteContent got...');
          Debug.output(re);
        };

       public static function storeLinkedRecord(c) {
          if (c.uid == null) {
            Debug.output('No component uid set for storeLinkedRecord');
            return undefined;
          }
          if (c.table == null) {
            Debug.output('No table set for storeLinkedRecord');
            return undefined;
          }
          if (c.record == null) {
            Debug.output('No record set for storeLinkedRecord');
            return undefined;
          }
          if (c.record.pid == null) {
            Debug.output('No record pid set for storeLinkedRecord');
            return undefined;
          }
          var v3 = this._service.storeLinkedRecord(c);
          v3.__set__responder(new mx.rpc.RelayResponder(this, 'handleStoreLinkedRecord', 'handleRemotingError'));
        };

       private static function handleStoreLinkedRecord(re) {
          if ((re.__get__result()).errortype > 0) {
            var v3 = {};
            v3.type = 'onError';
            v3.errorfunction = 'storeLinkedRecord';
            v3.errortype = (re.__get__result()).errortype;
            v3.errormsg = (re.__get__result()).errormsg;
            TF_CONF.COREdispatchEvent(v3);
          } else {
            if (re.__get__result()) {
              var v3 = {};
              v3.type = 'onStoreLinkedRecord';
              v3.status = true;
              v3.data = (re.__get__result()).result;
              this.dispatchEvent(v3);
            }
          }
        };

       public static function select(fields, table, where, group, order, callback, showHidden, showDeleted) {
          if (TF_CONF.BE_USER.uid <= 0) {
            Debug.output('You need to log in before calling \'ContentEditing.select\'');
            return undefined;
          }
          var v3 = this._service.select(fields, table, where, group, order, callback, showHidden, showDeleted);
          v3.__set__responder(new mx.rpc.RelayResponder(this, 'selectResult', 'handleRemotingError'));
        };

       private static function selectResult(re) {
          if ((re.__get__result()).errortype > 0) {
            var v4 = {};
            v4.type = 'onError';
            v4.errorfunction = 'select';
            v4.errortype = (re.__get__result()).errortype;
            v4.errormsg = (re.__get__result()).errormsg;
            TF_CONF.COREdispatchEvent(v4);
          } else {
            if (re.__get__result()) {
              var v4 = {};
              v4.type = (re.__get__result()).callback;
              v4.data = (re.__get__result()).result;
              this.dispatchEvent(v4);
            } else {}
          }
          Debug.output(re);
        };

       public static function insert(table, obj, callback) {
          if (TF_CONF.BE_USER.uid <= 0) {
            Debug.output('You need to log in before calling \'ContentEditing.insert\'');
            return undefined;
          }
          var v3 = this._service.insert(table, obj, callback);
          v3.__set__responder(new mx.rpc.RelayResponder(this, 'insertResult', 'handleRemotingError'));
        };

       private static function insertResult(re) {
          if ((re.__get__result()).errortype > 0) {
            var v4 = {};
            v4.type = 'onError';
            v4.errorfunction = 'select';
            v4.errortype = (re.__get__result()).errortype;
            v4.errormsg = (re.__get__result()).errormsg;
            TF_CONF.COREdispatchEvent(v4);
          } else {
            if (re.__get__result()) {
              var v4 = {};
              v4.type = (re.__get__result()).callback;
              v4.data = (re.__get__result()).result;
              this.dispatchEvent(v4);
            } else {}
          }
          Debug.output(re);
        };

       public static function update(table, where, obj, callback) {
          if (TF_CONF.BE_USER.uid <= 0) {
            Debug.output('You need to log in before calling \'ContentEditing.update\'');
            return undefined;
          }
          var v3 = this._service.update(table, where, obj, callback);
          v3.__set__responder(new mx.rpc.RelayResponder(this, 'updateResult', 'handleRemotingError'));
        };

       private static function updateResult(re) {
          if ((re.__get__result()).errortype > 0) {
            var v4 = {};
            v4.type = 'onError';
            v4.errorfunction = 'select';
            v4.errortype = (re.__get__result()).errortype;
            v4.errormsg = (re.__get__result()).errormsg;
            TF_CONF.COREdispatchEvent(v4);
          } else {
            if (re.__get__result()) {
              var v4 = {};
              v4.type = (re.__get__result()).callback;
              v4.data = (re.__get__result()).result;
              this.dispatchEvent(v4);
            } else {}
          }
          Debug.output(re);
        };

       public static function exec_delete(table, where, callback) {
          if (TF_CONF.BE_USER.uid <= 0) {
            Debug.output('You need to log in before calling \'ContentEditing.delete\'');
            return undefined;
          }
          var v3 = this._service.exec_delete(table, where, callback);
          v3.__set__responder(new mx.rpc.RelayResponder(this, 'deleteResult', 'handleRemotingError'));
        };

       private static function deleteResult(re) {
          if ((re.__get__result()).errortype > 0) {
            var v4 = {};
            v4.type = 'onError';
            v4.errorfunction = 'select';
            v4.errortype = (re.__get__result()).errortype;
            v4.errormsg = (re.__get__result()).errormsg;
            TF_CONF.COREdispatchEvent(v4);
          } else {
            if (re.__get__result()) {
              var v4 = {};
              v4.type = (re.__get__result()).callback;
              v4.data = (re.__get__result()).result;
              this.dispatchEvent(v4);
            } else {}
          }
          Debug.output(re);
        };*/
		private static function handleRemotingError( e):void 	{
			//var error = new TFError(TFError.SERVER_ERROR, e);
			//dispatchEvent(new EditingEvent(EditingEvent.ON_ERROR,error))
			Debug.output("ContentEditing remoting error");
			Debug.output(e);
		}
		
		public static function clearCache() {
			Debug.output('ContentEditing.clearCache called');
			ContentRendering.clearCache();
        };

       private static function onBELoginStatus(obj) {
          if (!obj.status) {
          }
        };


	}
	
}