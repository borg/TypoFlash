/*******************************************
* Class: 
*
* Copyright A. net.typoflash, net.typoflash@elevated.to
*
********************************************
* Example usage:
*
* Remember that inside all loded swfs to access core call stage.getChildAt(0)
*
********************************************/


package net.typoflash{

	import flash.text.TextField;
    import flash.ui.ContextMenu;
    import flash.ui.ContextMenuItem;
    import flash.ui.ContextMenuBuiltInItems;
    import flash.events.ContextMenuEvent;
	import net.typoflash.datastructures.TFPageRequest;
	
	import flash.geom.ColorTransform;

	import net.typoflash.events.CoreEvent;
	import flash.display.*;
	
	import flash.system.ApplicationDomain;
	import net.typoflash.datastructures.TFConfig;
	import net.typoflash.events.EditingEvent;
	import net.typoflash.queueloader.QueueLoader;
	import flash.system.LoaderContext;
	
	import flash.external.ExternalInterface;

	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.system.System;
	import flash.system.Security;
	
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	
	import net.typoflash.utils.Cookie;
	
	//import net.typoflash.ui.Controls;
	import fl.motion.Color;
	import flash.events.MouseEvent;	

	
	import flash.net.Responder;
	import net.typoflash.remoting.RemotingService;
	import net.typoflash.events.AuthEvent;
	
	import net.typoflash.utils.Global;
	import net.typoflash.authentication.BEAuthentication;
	
	import net.typoflash.datastructures.TFPageRequest;
	
	import net.typoflash.deeplinking.SWFAddress;
	import net.typoflash.deeplinking.SWFAddressEvent;
	
	import net.typoflash.utils.Debug;
    import flash.net.navigateToURL;
    import flash.net.URLRequest;
	
	import flash.events.IOErrorEvent;
	import flash.errors.IOError;
	import net.typoflash.queueloader.QueueLoaderEvent;
	import flash.text.TextFormat;
	
	import flash.events.FullScreenEvent;
	import flash.display.StageDisplayState;
	import flash.utils.getDefinitionByName;
	
	import net.typoflash.fonts.FontAsset;

	import flash.display.Stage;
	
	public class Core extends Sprite implements ICore{
		private var TF_CONF:TFConfig = TFConfig.global;

		public var service:RemotingService;
		public var Q:QueueLoader;
		public var C:Cookie;
		//public const FM:FontManager;
		
		public var debugTxtField:TextField;
		public var defaultPreloader:TypoFlashPreloader;

		//private var _fontId:uint = 0;
		
		public function  Core() {
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	
		public function init(e:Event){

			//Debug.output((stage.getChildAt(0)) +"?  " + registerFonts); 
			//to not have to rewrite much for Player 9,10...we can refer to CORE
			TF_CONF.CORE = this;
			
			//TF_CONF.BE_AUTH = new BEAuthentication();
			//TF_CONF.BE_AUTH.addEventListener(AuthEvent.ON_LOGIN_STATUS, authHandler);		
			/*
			 * Make a root tf Sprite and layer other sprites inside
			 */
			var l = TF_CONF.LAYER = {};
			var tf = TF_CONF.LAYER.tf =  new Sprite();
			addChild(tf);
			
			var depth = ['assets','bg','template','preloader','editor','swx','debug'];
			
			for (var i = 0; i < depth.length; i++) {
				l[depth[i]] = new Sprite();
				addChild(l[depth[i]]);
				
			}
			TF_CONF.LAYER.assets.x = 10000
			
			/*LOADER QUEUE*/

			
			var addedDefinitions : LoaderContext = new LoaderContext();
			addedDefinitions.applicationDomain = ApplicationDomain.currentDomain;
			Q = TF_CONF.LOAD_QUEUE = new QueueLoader(false, addedDefinitions, true, "GlobalQueue");
			Q.addEventListener(QueueLoaderEvent.ITEM_ERROR, ioErrorHandler);
			

			TF_CONF.FONT_MANAGER.init(ApplicationDomain.currentDomain);
			
			
			
			
			
			C = TF_CONF.COOKIE = Cookie.global;
			
			//FM = TF_CONF.FONT_MANAGER = FontManager.global;
			
			
			if (loaderInfo.parameters['IS_LIVE']) {
				var qs = unescape(loaderInfo.parameters['QUERY_STRING']);
				qs = qs.split('&');
				var qv;
				TF_CONF.QUERY_STRING = {};
				i = 0;
				while (i < qs.length) {
				  qv = qs[i].split('=');
				  if (qv[0] != '') {
					TF_CONF.QUERY_STRING[qv[0]] = qv[1];
				  }
				  ++i;
				}
				TF_CONF.HISTORY_ENABLED = Boolean(unescape(loaderInfo.parameters.HISTORY_ENABLED) == "1");
				TF_CONF.HOST_URL = unescape(loaderInfo.parameters.HOST_URL);
				TF_CONF.REMOTING_RELAY_SOCKET = unescape(loaderInfo.parameters.REMOTING_RELAY_SOCKET);
				TF_CONF.REMOTING_RELAY_PORT = Number(loaderInfo.parameters.REMOTING_RELAY_PORT);
				TF_CONF.IS_LIVE = true;
				TF_CONF.PAGE_ID = loaderInfo.parameters.PAGE_ID;
				TF_CONF.INIT_PAGE_TITLE = unescape(loaderInfo.parameters.TITLE);
				TF_CONF.SITE_TITLE = unescape(loaderInfo.parameters.SITE_TITLE);
				TF_CONF.INIT_PAGE_ALIAS = unescape(loaderInfo.parameters.PAGE_ALIAS);
				TF_CONF.BE_USER_ID = loaderInfo.parameters.BE_USER;
				TF_CONF.HTTP_USER_AGENT = unescape(loaderInfo.parameters.HTTP_USER_AGENT);
				TF_CONF.TYPO3_OS = unescape(loaderInfo.parameters.TYPO3_OS);
				if (loaderInfo.parameters.L == 0 || Number(loaderInfo.parameters.L) > 0) {
				  TF_CONF.LANGUAGE = loaderInfo.parameters.L;
				} else {
				  TF_CONF.LANGUAGE = 0;
				}
				TF_CONF.INIT_PAGE_REQUEST = new TFPageRequest(TF_CONF.PAGE_ID, TF_CONF.LANGUAGE,TF_CONF.INIT_PAGE_ALIAS);//the call for this page is made in Template base
				TF_CONF.RELAY_SERVER = TF_CONF.HOST_URL + 'typo3conf/ext/remoting_relay/' + loaderInfo.parameters.RELAY_SERVER;
				
				// ExternalInterface.call("alert",'host url: '+TF_CONF.HOST_URL);
				
				/*
				 * Now set inside TF_CONF.HOST_URL setter. Only use these if different than default
				TF_CONF.REMOTING_GATEWAY = TF_CONF.HOST_URL + 'typo3conf/ext/flashremoting/amf.php';
				TF_CONF.SWX_GATEWAY = TF_CONF.HOST_URL + 'typo3conf/ext/flashremoting/swx.php';
				TF_CONF.HOST_PATH = TF_CONF.HOST_URL + 'uploads/tx_typoflash/';
				TF_CONF.ASSET_PATH = TF_CONF.HOST_URL + 'typo3conf/ext/typoflash/assets/';
				*/
				//External assets
				TF_CONF.PRELOADER = TF_CONF.HOST_PATH  + unescape(loaderInfo.parameters.PRELOADER);
				TF_CONF.TEMPLATE = TF_CONF.HOST_PATH  + unescape(loaderInfo.parameters.TEMPLATE);
				TF_CONF.SWFS = unescape(loaderInfo.parameters.SWFS).split(',');
				TF_CONF.SWFS_SIZE = unescape(loaderInfo.parameters.SWFS_SIZE).split(',');
				TF_CONF.DYNAMIC_FONTS = unescape(loaderInfo.parameters.DYNAMIC_FONTS).split(',');
				TF_CONF.SHARED_FONTS = unescape(loaderInfo.parameters.FONTS).split(',');

				
			
				
				

				System.useCodePage = Boolean(loaderInfo.parameters.CODE_PAGE);
				//System.exactSettings = false;
				
				/*Should this be final?*/
				if (TF_CONF.IS_LIVE) {
					Security.allowDomain(TF_CONF.HOST_DOMAIN );	
				}else{		
					Security.allowDomain('*');
				}
				
				if(loaderInfo.parameters.SCALE_MODE){
					stage.scaleMode = loaderInfo.parameters.SCALE_MODE;
					stage.align = loaderInfo.parameters.ALIGN;
				}
				
				
				
				//create filled background
				var bg:Sprite = TF_CONF.LAYER.bg;
				bg.graphics.beginFill(0xFFFFFF, 1);
				bg.graphics.lineStyle(0, 0xFFFFFF, 0);
				bg.graphics.moveTo(0, 0);
				bg.graphics.lineTo(stage.stageWidth, 0);
				bg.graphics.lineTo(stage.stageWidth, stage.stageHeight);
				bg.graphics.lineTo(0, stage.stageHeight);
				bg.graphics.endFill();
				
				if (loaderInfo.parameters.BG_COLOUR.length > 0) {
				  var bgCol  = unescape(loaderInfo.parameters.BG_COLOUR);
				  bgCol = (bgCol.split('#'))[1];
				  TF_CONF.BG_COLOUR = parseInt('0x' + bgCol);
				  //var col = new Color(TF_CONF.BG_COLOUR);
				  //col.setRGB(nc);
				  var ct:ColorTransform = new ColorTransform();
				  ct.color = TF_CONF.BG_COLOUR;
				  bg.transform.colorTransform = ct;
				}		
				
				Q.addEventListener(QueueLoaderEvent.ITEM_PROGRESS, loadProgress);
				Q.addEventListener(QueueLoaderEvent.ITEM_COMPLETE, itemLoadComplete);
				Q.addEventListener(QueueLoaderEvent.QUEUE_COMPLETE, loadComplete);	
				Q.addEventListener(QueueLoaderEvent.ITEM_ERROR, loadError);	
				
				if (loaderInfo.parameters.PRELOADER==null) {
					

					//ExternalInterface.call("alert", "no preloader");
					
					defaultPreloader = new TypoFlashPreloader();
					defaultPreloader.x = 400;
					defaultPreloader.y = 250;
					addChild(defaultPreloader);
					
					/*
					debugTxtField =  new TextField()
					addChild(debugTxtField);
					*/
	
				}
				
				
				loadAssets();
				setCookieDefaults();
				addExternalInterfaces();				
				
				

			}

			
			


			//Cookie.global.getData('storeBEuserdataEnabled')
			
			stage.addEventListener(Event.RESIZE, resizeStage);
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, onDisplayStateChange);
			
			
			

			
			if (C.data.debugEnabled) {
				loadDebug();
			}
			if (C.data.editEnabled) {
				loadEditor();
			}
			
			
			
           
		
			setContextMenu();


			/*
			E.addEventListener('onBELoginStatus', this);
			E.addEventListener('onDebugStatus', this);
			E.addEventListener('onEditStatus', this);
			E.addEventListener('onSoundStatus', this);
			*/
			
			repositionChildren()
		}
		

		private function authHandler(e:AuthEvent){

		}

		function resizeStage(event:Event):void{
			repositionChildren()
		}
		
		public function repositionChildren(){
			TF_CONF.LAYER.bg.width = stage.stageWidth;
			TF_CONF.LAYER.bg.height = stage.stageHeight;
			if (defaultPreloader) {
				
				defaultPreloader.x =  stage.stageWidth / 2;
				
			}
		}
		
		
		
		/*
		 * LOAD ASSETS, FONTS, PRELOADER, TEMPLATE ETC. INTO RESPECTIVE LAYER
		 * 
		 */ 
		public function loadAssets() {
					
			var p:int = 0;
			if (loaderInfo.parameters.PRELOADER) {
				Q.addItem(TF_CONF.PRELOADER,TF_CONF.LAYER.preloader, {'name': 'Preloader', 'filesize': TF_CONF.SWFS_SIZE[0]})
				p++;
			} 
			
			var lObj;
			var fList;
			var f;
			var sprite:Sprite;
			if (TF_CONF.DYNAMIC_FONTS.length>0) {
			  if (TF_CONF.SWFS_SIZE.length > 0) {
				f = 0;
				while (f < TF_CONF.DYNAMIC_FONTS.length) {
				  if (TF_CONF.DYNAMIC_FONTS[f].length > 0 && TF_CONF.DYNAMIC_FONTS[f] != null) {
					  sprite = new Sprite();
					  TF_CONF.LAYER.assets.addChild(sprite)
					  Q.addItem(TF_CONF.HOST_PATH + TF_CONF.DYNAMIC_FONTS[f], sprite, { 'name': 'Dynamic Fonts', 'filesize': TF_CONF.SWFS_SIZE[p] } );
					  
					p++;
				  }
				  ++f;
				}
			  }
			}
			
			if (TF_CONF.SHARED_FONTS.length > 0) {
			  if (TF_CONF.SWFS_SIZE.length > 0) {
				fList = TF_CONF.SHARED_FONTS;
				f = 0;
				while (f < fList.length) {
				  if (fList[f].length > 0 && fList[f] != null) {
					   sprite = new Sprite();
					  TF_CONF.LAYER.assets.addChild(sprite)
					   Q.addItem(TF_CONF.HOST_PATH + fList[f],sprite,{'name': 'Shared Fonts', 'filesize': TF_CONF.SWFS_SIZE[p]} );
					p++;
				  }
				  ++f;
				}
			  }
			}
			if (TF_CONF.SWFS != null) {
			  if (TF_CONF.SWFS_SIZE.length > 0) {
				f = 0;
				while (f < TF_CONF.SWFS.length) {
					if (TF_CONF.SWFS[f].length > 0 && TF_CONF.SWFS[f] != null) {
						sprite = new Sprite();
					  TF_CONF.LAYER.assets.addChild(sprite)
						Q.addItem(TF_CONF.HOST_PATH + TF_CONF.SWFS[f],sprite,{'name': 'Assets', 'filesize': TF_CONF.SWFS_SIZE[p]} );
						p++;
					}
					++f;
				}
			  }
			}
			
			/*
			 * LOAD TEMPLATE
			 */ 
			Q.addItem(TF_CONF.TEMPLATE, TF_CONF.LAYER.template, { 'name': 'TypoFlash template', 'filesize': TF_CONF.SWFS_SIZE[TF_CONF.SWFS_SIZE.length - 1]} );
			
			
			/*
			 * Kick off loading
			 */ 
			Q.execute();	
			
			
		}
		
		private function addExternalInterfaces() {
			
			//var methodName = 'updateFlashHistory';
			//var method = updateFlashHistory;
			//var wasSuccessful = ExternalInterface.addCallback(methodName, method);
			var methodName = 'externalEdit';
			var method = externalEdit;
			ExternalInterface.addCallback(methodName, method);	
			
			SWFAddress.addEventListener(SWFAddressEvent.CHANGE, updateFlashHistory);
			
		}
		
		
		
		
		private function setCookieDefaults() {
			
					
			if (C.data.soundEnabled == null) {
				C.setData('soundEnabled', 1);
			}
			if (C.data.highQuality == null) {
				C.setData('highQuality', 1);
			}
			if (C.data.debugEnabled == null) {
				C.setData('debugEnabled', 0);
			}
			if (C.data.storeFEuserdataEnabled == null) {
				C.setData('storeFEuserdataEnabled', 0);
			}
			if (C.data.storeBEuserdataEnabled == null) {
				C.setData('storeBEuserdataEnabled', 0);
			}
			if (C.data.autologinEnabled == null) {
				C.setData('autologinEnabled', 0);
			}	
		}

/*

		private function getActiveBEresult(data:*):void{
			if(data){
				BE_USER = BEuser.init(data.result);
			
				//Controls.debugMsg("Typo3Login.getActiveBEResult: Active BE user is " +BE_USER['username'] );

		
				dispatchEvent(new AuthEvent(AuthEvent.BE_AUTH,"true",data.result));
				
			}else{
				dispatchEvent(new AuthEvent(AuthEvent.BE_AUTH,"false"));

			}
		}
*/

		
		/*
		 * This function is called from browser
		 */ 
			

		private function updateFlashHistory(e:SWFAddressEvent) {
			var loc = e.pathNames;
			//Debug.output("updateFlashHistory: "+loc[0])
			
			if (TF_CONF.HISTORY_ENABLED) {
				
				if (loc[0]) {
					var id:uint,alias:String,L:uint;
					//check is passed an alias or a numeric id
					if(isNaN(loc[0])) {
						id = 0;
						alias = loc[0];
					}else{	
						id = uint(loc[0]);
						alias = '';
					}

					if (!isNaN(loc[1])) {
						L = uint(loc[1]);
					}else {
						L = TF_CONF.LANGUAGE;
					}
					
					var pObj:TFPageRequest = new TFPageRequest(id, L, alias);
					
					/*
					 * This is only for first page call in case SWFaddress passes alternative page values in 
					 * different from the html ones. It is nullified after first call in templatebase.
					 * Not sure this is final solution
					 */
					if (!TF_CONF.INIT_PAGE_CALLED) {
						TF_CONF.INIT_PAGE_REQUEST = pObj;
					}					
					
				}else if (TF_CONF.DEEPLINK != '') {
					//this is not the first call but deeplink has been unset, therefore needs to restore to original page
					pObj = TF_CONF.INIT_PAGE_REQUEST;
				}
				
				if(TF_CONF.USE_PARAMETERS_NAMESPACE){
					//#news?category=4&newsitem=5&tmpl=projectViewer|id:3;accounts|id:4;accounts|state:open;
					TF_CONF.CURR_TEMPLATE_STATE_STR = SWFAddress.getParameter('tmpl');
					if (TF_CONF.CURR_TEMPLATE_STATE_STR) {
						dispatchEvent(new CoreEvent(CoreEvent.ON_EXT_TEMPLATE_STATE,TF_CONF.CURR_TEMPLATE_STATE_STR));
					}
					//this is using the component key namespace nesting
					TF_CONF.CURR_PAGE_STATE_STR = SWFAddress.getParameter('page');
					if (TF_CONF.CURR_PAGE_STATE_STR) {
						dispatchEvent(new CoreEvent(CoreEvent.ON_EXT_PAGE_STATE,TF_CONF.CURR_PAGE_STATE_STR));
					}		
				}else{
					//this is using plain vanilla parameter names. Work fine if not more than one component per page using same variable names
					//when not using namespace cannot separate template state from page state, ie all becomes page state
					var qrystr = SWFAddress.getQueryString();
					if (qrystr != TF_CONF.CURR_PAGE_STATE_STR ) {
						dispatchEvent(new CoreEvent(CoreEvent.ON_EXT_PAGE_STATE));
						TF_CONF.CURR_PAGE_STATE_STR = SWFAddress.getQueryString();//storing it on pagestatestr, not used in this mode right?
					}
				}
				

				/*
				 * different entry point examples
Debug.output(["Core.swfaddress call " , TF_CONF.PID , pObj.id , TF_CONF.ALIAS , pObj.alias , TF_CONF.LANGUAGE , pObj.L, TF_CONF.ONLY_TMPL_STATE])
http://haveathink.net/#/5?category=3&item=32&
["Core.swfaddress call ", -1, 5, "", "", 0, 0, false]
["Core.swfaddress call ", 0, 5, "frontpage", "", 0, 0, false]



http://haveathink.net/#/frontpage?item=24&category=6&
["Core.swfaddress call ", -1, 0, "", "frontpage", 0, 0, false]
["Core.swfaddress call ", 0, 0, "frontpage", "frontpage", 0, 0, false]
				*/
				
				if (pObj) {
					if (TF_CONF.PID > 0 && pObj.id > 0)  {
						//normal page check, no point checking alias
						if((TF_CONF.PID != pObj.id || TF_CONF.LANGUAGE != pObj.L) && !TF_CONF.ONLY_TMPL_STATE){
							dispatchEvent(new CoreEvent(CoreEvent.ON_BROWSER_HISTORY, pObj));
						}
					}else if (!TF_CONF.INIT_PAGE_CALLED && (TF_CONF.ALIAS != pObj.alias || TF_CONF.LANGUAGE != pObj.L) && !TF_CONF.ONLY_TMPL_STATE) {
						dispatchEvent(new CoreEvent(CoreEvent.ON_BROWSER_HISTORY, pObj));
					} else if (!TF_CONF.ONLY_TMPL_STATE) {
						//dispatchEvent(new CoreEvent(CoreEvent.ON_BROWSER_HISTORY,TF_CONF.INIT_PAGE_REQUEST));
					}
				}
			}
		}

		private function externalEdit(key) {
			//TF_CONF.CONTENT_EDITING.externalEdit(key);
		}

		private function setContextMenu() {
			TF_CONF.CONTEXT = new ContextMenu();
			TF_CONF.CONTEXT.hideBuiltInItems();
            var defaultItems:ContextMenuBuiltInItems = TF_CONF.CONTEXT.builtInItems;
            defaultItems.print = true;

			if (TF_CONF.BE_USER) {
				var log = new ContextMenuItem('» Log out of TypoFlash');//TF_CONF.BE_AUTH.logout
				TF_CONF.CONTEXT.customItems.push(log);
				//lgt.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, toggleSound);	
				
				if (C.data.debugEnabled) {
					var debugItem = new ContextMenuItem('» Turn off Debug mode');//turnOffDebug
					debugItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, turnOffDebug);
				} else {
					debugItem = new ContextMenuItem('» Turn on Debug mode');//turnOnDebug
					debugItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, turnOnDebug);
				}	
				TF_CONF.CONTEXT.customItems.push(debugItem);

				
				if (C.data.editEnabled) {
					var editItem = new ContextMenuItem('» Turn off Edit mode');//turnOffEdit
					
				} else {
					editItem = new ContextMenuItem('» Turn on Edit mode');//turnOnEdit
					//editItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, turnOnEdit);
				}
				editItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, toggleEdit);
				TF_CONF.CONTEXT.customItems.push(editItem);	
				
				
			} else {
				var lgn = new ContextMenuItem('» Login to TypoFlash');//loadEditor
				lgn.separatorBefore = true;
				lgn.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, loadEditor);
				TF_CONF.CONTEXT.customItems.push(lgn);
				if (C.data.editEnabled) {
					editItem = new ContextMenuItem('» Turn off Edit mode');//turnOffEdit
					editItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, toggleEdit);
					TF_CONF.CONTEXT.customItems.push(editItem);	
				}

			}	
			

		  
		  
		  
		  
			if (stage.displayState == StageDisplayState.FULL_SCREEN) {
				var scr = new ContextMenuItem('» Exit full screen');
			} else {
				scr = new ContextMenuItem('» Turn on full screen');
			}
			scr.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, toggleFullScreen);
			TF_CONF.CONTEXT.customItems.push(scr);
		  
			
			
			
			if (C.data.soundEnabled != false) {
				var snd = new ContextMenuItem('» Mute all sounds');//toggleSound
			} else {
				snd = new ContextMenuItem('» Turn on sounds');//toggleSound
			}
			snd.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, toggleSound);
			TF_CONF.CONTEXT.customItems.push(snd);
		  
			
			
			var pwr = new ContextMenuItem('» Powered by TypoFlash');//credit
			pwr.separatorBefore = true;
			TF_CONF.CONTEXT.customItems.push(pwr);
			pwr.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, credit);
			
			contextMenu = TF_CONF.CONTEXT;
		}

		
		function credit(e:ContextMenuEvent) {
			var request:URLRequest = new URLRequest('http://typoflash.net');
			navigateToURL(request, '_blank');

		}

		function clearCache(e:ContextMenuEvent) {
			//TF_CONF.CONTENT_RENDERING.clearCache();
			//this way no need to embed in core
			//var ContentRenderingRef:Class = getDefinitionByName("net.typoflash.ContentRendering") as Class;
            //ContentRenderingRef.clearCache();

		}

		function turnOffDebug(e:ContextMenuEvent){
			TF_CONF.COOKIE.setData('debugEnabled', 0);
			/*TF_CONF.LAYER.debug.unloadMovie();
			debugItem.caption = '» Turn on Debug mode';
			debugItem.onSelect = turnOnDebug;
			*/
			setContextMenu();
		}

		function turnOnDebug(e:ContextMenuEvent) {
			TF_CONF.COOKIE.setData('debugEnabled', 1);
			/*loadDebug();
			debugItem.caption = '» Turn off Debug mode';
			debugItem.onSelect = turnOffDebug;
			*/
			setContextMenu();
		}


		function toggleEdit(e:ContextMenuEvent) {
			if(C.data.editEnabled){	
				unloadEditor();
			}else {
				loadEditor();
			}
				
	
			setContextMenu();
		}

		function loadDebug() {
		  /*TF_CONF.LAYER.debug = root.createEmptyMovieClip('debug', depth.debug);
		  var v2 = TF_CONF.LAYER.debug;
		  var v3 = {'url': TF_CONF.HOST_URL + 'typo3conf/ext/typoflash/pi1/debug8.swf', 'target': v2, 'name': 'Debug window'};
		  TF_CONF.LOAD_QUEUE.load(v3);*/
		
		 }

		function loadEditor(e:*= null) {
			
			var ldr:Loader = new Loader();
			var url:String = TF_CONF.HOST_URL + '/typo3conf/ext/typoflash/pi1/editor9.swf';
			
			var urlReq:URLRequest = new URLRequest(url);
			var context:LoaderContext = new LoaderContext( false, ApplicationDomain.currentDomain);
			ldr.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			ldr.load(urlReq,context);
			TF_CONF.LAYER.editor.addChild(ldr);
			TF_CONF.LAYER.template.y = 55;
			C.setData("editEnabled", true);
			dispatchEvent(new CoreEvent(CoreEvent.ON_EDIT_STATUS, EditingEvent.TRUE));
		}


		function ioErrorHandler(event:*):void {
			Debug.output(String(event));
			 //  debugTxtField.text = event 

		}
		function unloadEditor(e:*= null) {		
			if(TF_CONF.LAYER.editor.numChildren>0){
				TF_CONF.LAYER.editor.removeChildAt(0);
				TF_CONF.LAYER.template.y = 0;
			}
			C.setData("editEnabled", false);
			dispatchEvent(new CoreEvent(CoreEvent.ON_EDIT_STATUS, EditingEvent.FALSE));
		}

		function toggleSound(e:ContextMenuEvent) {
			dispatchEvent(new CoreEvent(CoreEvent.ON_SOUND_STATUS,!C.data.soundEnabled));
		}

		function onSoundStatus(e:CoreEvent) {
		  if (C.data.soundEnabled != false) {
			C.setData('soundEnabled', e.data);
			//stopAllSounds();
			//snd.caption = '» Turn on sounds';
		  } else {
			C.setData('soundEnabled', 1);
			//snd.caption = '» Mute sounds';
		  }
		  setContextMenu();
		}
		
		
		private function toggleFullScreen(e:ContextMenuEvent) {
			if (stage.displayState == StageDisplayState.FULL_SCREEN) {
				stage.displayState = StageDisplayState.NORMAL;
			}else {
				stage.displayState = StageDisplayState.FULL_SCREEN;
			}
		}	
		
		private function onDisplayStateChange(e:FullScreenEvent) {
			setContextMenu();
		}
		
		/*
		 * This function is added when BEAuth is instantiated
		 * More secure not to include BEAuth class in Core.
		 */
		
		public function onBELoginStatus(e:AuthEvent):void {
			if (e.status == AuthEvent.FALSE) {
				//unloadEditor();
			}
			setContextMenu();
		}

		function onDebugStatus(obj) {
		  /*if (obj.status == true) {
			turnOnDebug();
		  } else {
			turnOffDebug();
		  }*/
		  setContextMenu();
		}

		function onEditStatus(e:EditingEvent) {
			setContextMenu();
		}


		
		
		private function loadProgress(e:QueueLoaderEvent) {
			if(defaultPreloader){
				defaultPreloader.infoTxt.text = "Loading " + e.info.name ;
				defaultPreloader.loadbar.width = e.queuepercentage * defaultPreloader.loadbarBg.width;
			}
			
			//Debug.output("CoreLoadprogress " +e.bytesLoaded/ e.bytesTotal + " = "+e.queuepercentage)
			
			if(e.info.name == "Assets"){
				dispatchEvent(new CoreEvent(CoreEvent.ON_LOAD_PROGRESS, e,CoreEvent.LOAD_TYPE_ASSETS ));	
			}else if (e.info.name == "TypoFlash template") {
				dispatchEvent(new CoreEvent(CoreEvent.ON_LOAD_PROGRESS, e,CoreEvent.LOAD_TYPE_TEMPLATE));
			}else if (e.info.name == "Dynamic Fonts") {
				dispatchEvent(new CoreEvent(CoreEvent.ON_LOAD_PROGRESS, e,CoreEvent.LOAD_TYPE_ASSETS));
			}else if (e.info.name == "Shared Fonts") {
				dispatchEvent(new CoreEvent(CoreEvent.ON_LOAD_PROGRESS, e,CoreEvent.LOAD_TYPE_ASSETS));
			}			
				
		}
		
	
	
		private function itemLoadComplete(e:QueueLoaderEvent) {
			if(e.info.name == "Assets"){
				dispatchEvent(new CoreEvent(CoreEvent.ON_LOAD_COMPLETE, e,CoreEvent.LOAD_TYPE_ASSETS ));	
			}else if (e.info.name == "TypoFlash template") {
				dispatchEvent(new CoreEvent(CoreEvent.ON_LOAD_COMPLETE, e,CoreEvent.LOAD_TYPE_TEMPLATE));
			}else if (e.info.name == "Dynamic Fonts") {
				//var loaderInfo:LoaderInfo = e.targ. as LoaderInfo;.root['fontClasses']
				//Debug.output("Dynamic Fonts "+ MovieClip(e.content).getChildAt(0)['text'])
				dispatchEvent(new CoreEvent(CoreEvent.ON_LOAD_PROGRESS, e,CoreEvent.LOAD_TYPE_ASSETS));
			}else if (e.info.name == "Shared Fonts") {
				dispatchEvent(new CoreEvent(CoreEvent.ON_LOAD_PROGRESS, e,CoreEvent.LOAD_TYPE_ASSETS));
			}	
						
		}
		
		public function registerFonts(_name:String,_fontClasses:Array,_size:int=0):void {
			TF_CONF.FONT_MANAGER.registerFonts(_name,_fontClasses,_size)
		}
		
		/*
		 * Whole queue done
		 */ 
		private function loadComplete(e:QueueLoaderEvent) {
			if(defaultPreloader){
				removeChild(defaultPreloader);
			}

		}	
	

		
		private function loadError(e:QueueLoaderEvent) {
			if(e.info.name == "Assets"){
				dispatchEvent(new CoreEvent(CoreEvent.ON_LOAD_ERROR, e,CoreEvent.LOAD_TYPE_ASSETS ));				
			}else if (e.info.name == "TypoFlash template") {
				dispatchEvent(new CoreEvent(CoreEvent.ON_LOAD_ERROR, e,CoreEvent.LOAD_TYPE_TEMPLATE));
			}			
		}	
	};

}






