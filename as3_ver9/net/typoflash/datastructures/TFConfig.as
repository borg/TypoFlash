package net.typoflash.datastructures {
	import flash.display.Sprite;
	import flash.utils.*;
	import flash.ui.ContextMenu;
	import net.typoflash.fonts.FontManager;

	import net.typoflash.authentication.BEAuthentication;
	import net.typoflash.authentication.FEAuthentication;
	import net.typoflash.queueloader.QueueLoader;
	import net.typoflash.utils.Cookie;
	import net.typoflash.utils.Global;
	import net.typoflash.utils.HashMap;
	import flash.events.EventDispatcher
	
	/**
	 * ...
	 * @author Borg
	 */
	public class TFConfig extends Global{
		
		public var CORE:Sprite;
		public var EDITOR:Sprite;//cast as net.typoflash.editor.TypoFlash
	
		public var COOKIE:Cookie;
		public var LAYER:Object;//Could be a DepthManager as well
		
		public var CONTEXT:ContextMenu;
		
		public var LOAD_QUEUE:QueueLoader;
		
		
		private var _HOST_URL:String ='';//getter and setter useful for local development where all the other settings are standard
		public var HOST_DOMAIN:String ='';//HOST_URL without http://
		public var REMOTING_RELAY_SOCKET:String;
		public var REMOTING_RELAY_PORT:uint;
		public var REMOTING_GATEWAY:String='';
		public var RELAY_SERVER:String;
		public var SWX_GATEWAY:String;
		
		public var HTTP_USER_AGENT:String;
		public var TYPO3_OS:String;
		public var INIT_PAGE_TITLE:String;
		public var INIT_PAGE_ALIAS:String;
		public var SITE_TITLE:String;
		public var BG_COLOUR:int;
		
		public var QUERY_STRING:Object;
		public var QUERY_PARAMETERS:Object;//from SWFAddress
		public var CURR_TEMPLATE_STATE_STR:String;
		public var CURR_PAGE_STATE_STR:String;
		public var ONLY_TMPL_STATE:Boolean = false;
		public var USE_PARAMETERS_NAMESPACE:Boolean = false;//needed if more than one similar component is expecting variable on same page, this will use component key as namespace for external variables, else will use QUERY_PARAMETERS
		
		
		public var INIT_PAGE_REQUEST:TFPageRequest;
		public var INIT_PAGE_CALLED:Boolean = false;
		
		/*Browser and language change variables to keep of changes globally to compare with before reload*/
		public var PID:int=-1;
		public var ALIAS:String = '';
		public var DEEPLINK:String = '';
		//public var PARAMS:String='';
			
		public var HOST_PATH:String;
		public var ASSET_PATH:String;
		public var PRELOADER:String;
		public var TEMPLATE:String;//string to template.swf...use  TF_CONF.LAYER.template.getChildAt(0).content or TF_CONF.TEMPLATE_INSTANCE
		public var SWFS:Array;
		public var SWFS_SIZE:Array;
		public var DYNAMIC_FONTS:Array;
		public var SHARED_FONTS:Array;
		public var FONT_MANAGER:FontManager;
		
		
		
		
		
		public var HISTORY_ENABLED:Boolean = false;
		
		public var IS_LIVE:Boolean= false;
		public var PAGE_ID:uint;
		public var BE_USER_ID:uint;

		public var LANGUAGE:uint = 0;
		
		public var FE_AUTH:FEAuthentication;		
		public var FE_SECURITY_LEVEL:String = "challenged";//normal,challenged
		public var FE_USER:TFFrontEndUser;
		
		public var BE_AUTH:BEAuthentication;
		public var BE_SECURITY_LEVEL:String = "challenged";//normal,challenged
		public var BE_USER:TFBackEndUser;	
		
		
		public var USE_SWX:Boolean = false;
		
		//settings relating to what when how to render and load
		public var MENU:Object = {};
		public var MOTHERLOAD:TFMotherload = new TFMotherload();//using datastuctures for conf to get strong typing
		public var PAGE:Object = { };
		
		
		
		public var API_KEY:Object = {};//YOUTUBE_DEV_KEY,YAHOO,GOOGLE...whatever it may be
		
		
		private static var _instance:TFConfig;
		
		public function TFConfig()	{
			if (getQualifiedClassName(super) == "net.typoflash.datastructures::TFConfig" ) {
				if (!allowInstantiation) {
					throw new Error("Error: Instantiation failed: Use TFConfig.global instead of new TFConfig().");
				} else {
					setDefaults();
					globalRepository = new HashMap();
					dispatcher = new EventDispatcher(this);
				}
			}
			
			
		}
		private function setDefaults() {
			FONT_MANAGER = new FontManager();
			MOTHERLOAD.mode = TFMotherload.MODE_ON_GET_MENU;
			MOTHERLOAD.getRecords = true;
			QUERY_PARAMETERS = { };
			
		}
		
		public static function get global() : TFConfig {
			if ( TFConfig._instance == null ) {
		 		allowInstantiation = true;
		 		_instance = new TFConfig();
		 		allowInstantiation = false;
			}
			return TFConfig._instance;
		}
		
		public function get HOST_URL():String { return _HOST_URL; }
		
		/*
		 * By setting HOST_URL you are also setting all the other main default paths
		 */ 
		public function set HOST_URL(value:String):void {
			TFConfig.global;
			_HOST_URL = value;
			_instance.REMOTING_GATEWAY = _instance.HOST_URL + 'typo3conf/ext/flashremoting/amf.php';
			_instance.SWX_GATEWAY = _instance.HOST_URL + 'typo3conf/ext/flashremoting/swx.php';
			_instance.HOST_PATH = _instance.HOST_URL + 'uploads/tx_typoflash/';
			_instance.ASSET_PATH = _instance.HOST_URL + 'typo3conf/ext/typoflash/assets/';
			
			HOST_DOMAIN = _HOST_URL.split("://")[1];
		}
		/*
		 * Returns the template instance loaded by core
		 */ 
		public function get TEMPLATE_INSTANCE() {
			return LAYER.template.getChildAt(0).content;
		}
	}
	
}