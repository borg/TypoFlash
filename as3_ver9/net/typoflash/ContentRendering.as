/**
 * Class borg_typoflash.remoting.contentrendering
 * by A. Borg borg@elevated.to
 * All rights reserved.






Deeplinks
19/06/2007
The process of getting the default values from the browser hash is started by the template call 
ExternalInterface.call("callExternalInterface");
that gets the current hash value from the browser and that is passed to the core.as function updateFlashHistory
That function analyses the hash and weeds out tmplState, pageState from L id and other variables. First the tmplState is 
passed on then pageState and last the remaining query string with L and id as browserHistory. Ie if history is enable the
_global.INIT_pOBJ only used as a fallback if the hash does not contain any id or L info. Hence the first time the 
getPage is called there is no TF_CONF.PID only the _global['PAGE_ID'] from html.

If you do a RIA linked to the root domain, you may not wish to use L and id variables at all, you can disable them
and still use template history by settign _global['ONLY_TMPL_STATE'] in your template_init file.

There is a bug though, or at least it appeared that way in totaljobs where every 5th reload the template seemed to be unloaded.
The evaluation of an equivalent hash is poor and the order of the variables are tossed around, and it seemed the getPage
got confused and sometimes unloaded or replace template or something. Might need more thinking here.

Actually if getPage is only called via callExternalInterface and is thus disabled with ONLY_TMPL_STATE how come the template is
loaded...well it is loaded via core as a swf..but without page date and page content. 


Todo:




 */
package net.typoflash{
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	import flash.events.Event;
	import net.typoflash.base.FrameBase;
	import net.typoflash.base.MenuBase;
	import net.typoflash.datastructures.TFConfig;
	import net.typoflash.datastructures.TFMenu;
	import net.typoflash.datastructures.TFMotherload;
	import net.typoflash.datastructures.TFPage;
	import net.typoflash.datastructures.TFPageRequest;
	import net.typoflash.datastructures.TFMenuRequest;
	import net.typoflash.datastructures.TFRecordRequest;
	import net.typoflash.datastructures.TFTemplate;
	import net.typoflash.datastructures.TFError;
	
	import net.typoflash.events.CoreEvent;
	import net.typoflash.events.RemotingEvent;
	import net.typoflash.events.RenderingEvent;
	import flash.net.Responder;
	import net.typoflash.remoting.RemotingService;

	
	import net.typoflash.utils.Debug;
	import net.typoflash.deeplinking.SWFAddress;
	import net.typoflash.deeplinking.SWFAddressEvent;
	import net.typoflash.crypto.MD5;
	
	public class ContentRendering{

		
		private static var TF_CONF:TFConfig = TFConfig.global;
		private static var _service:RemotingService;
		//private static var _instance:ContentRendering = null;
		//private static var _allowInstantiation:Boolean = false;		
		
		private static var _coreListenerAdded:Boolean = false;
		
		
		private static var _page:TFPage;
		private static var _motherload:TFMotherload  = new TFMotherload();//Store all page data in uid indexed array..should be vector if player 10+
		private static var _conf:Object;
		private static var _data:Object;
		

		private static var _frames:Object;
		private static var _menus:Object;
		
		private static var dispatcher:EventDispatcher;

		
		public static var OLD_TEMPLATE_ID:Number;
		public static var TEMPLATE_ID:Number;		
		public static var tplState:Array = [];
		public static var pageState:Array = [];;//store the serialised states like strings in arrays
		public static var currTplState:Object = {};
		public static var currPageState:Object = {};//these hold the current unserialised data
		public static var currPageDeeplink:String='';//the L=0&id=4 of the deeplink


		
		private static function addCoreListeners(){
			if (_coreListenerAdded) {
				return;
			}

			try {
				
			//This is fired from javascript. Check in core.as where it is used instead of including ContentRendering
			TF_CONF.CORE.addEventListener(CoreEvent.ON_BROWSER_HISTORY, onBrowserHistory);
			TF_CONF.CORE.addEventListener(CoreEvent.ON_EXT_PAGE_STATE, onExtPageState);
			TF_CONF.CORE.addEventListener(CoreEvent.ON_EXT_TEMPLATE_STATE, onExtTemplateState);
			
			//addEventListener(TFErrorEvent.ON_REMOTING_ERROR, handleRemotingerror));
			}
			catch (e) {
			//core only when live	
			}
			//listen to frame loads. These events are fired on ContentRendering from within the loading frames themselves
			//addEventListener(RenderingEvent.ON_FRAME_LOAD_BEGIN, onFrameLoadBegin);
			addEventListener(RenderingEvent.ON_FRAME_LOAD_COMPLETE, onFrameLoadComplete);
			_coreListenerAdded = true;
			_menus = {};
			_frames = { };
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
                v5.gateway = _global.TF.SWX_GATEWAY + '?cmd=getPage&id=' + pObj.id + '&L=' + pObj.L;
                v5.encoding = 'POST';
                v5.result = [this, 'handleGetPage'];
                v5.error = [this, 'fallBack'];
                v5.name = 'Page data';
                var v6 = {};
                v6.serviceClass = 'typoflash.remoting.contentrendering';
                v6.method = 'getPage';
                v6.args = [pObj];
                Debug.output('Get page ' + _global.TF.PID + ' in lang ' + _global.TF.LANGUAGE + ' from server via SWX.');
                v5.call(v6);*/
			}	
				
			try{
				var responder:Responder = new Responder(callback, handleRemotingError);
				_service.call("typoflash.remoting.contentrendering." + func, responder, params);
				Debug.output("typoflash.remoting.contentrendering." + func);
				Debug.output(params);
			}
			catch (e:Error){
				trace("ContentRendering.call error. TF_CONF.REMOTING_GATEWAY set?" )
			
			
			}
			//Debug.output(params);
		}
		
		
		private static function onBrowserHistory(e:CoreEvent){
			//Controls.debugMsg('onBrowserHistory')
			//Controls.debugMsg(p)
			getPage(e.data,true)

		}
		
		
		
		/*
		 * PUBLIC RENDERING FUNCTIONS
		 */ 
		
		//Returns all flash components and their records if user has page access	
		public static function getPage(pObj:TFPageRequest,nostalgic:Boolean = false)	{
			Debug.output("ContentRendering.getPage: "+pObj)
			
			/*
			Available variables
			$pObj.id,

			$pObj.L //language
			

			//Additional params
			showTimedPage
			showDeletedPage
			showHiddenPage
			fields

			*/
					
			
			
			
			if (pObj.id > 0 || pObj.alias != '') {
				
				/* since browser sends same page back into flash need to check it is not 
				 * simple rebound and it is already set
				 * && TF_CONF.PID == -1 means first call
				 */
				
				if (pObj.alias!='' && pObj.alias == TF_CONF.ALIAS && pObj.L == TF_CONF.LANGUAGE && TF_CONF.PID>-1) {
					return;
				}
				if (pObj.id == TF_CONF.PID && pObj.L == TF_CONF.LANGUAGE && TF_CONF.PID>-1) {
					return;
				}
				
				if(!(pObj.L>-1)){
					if(TF_CONF.LANGUAGE>0){
						pObj.L = TF_CONF.LANGUAGE;
					}else{
						pObj.L = 0;
					}
				}else{
					 TF_CONF.LANGUAGE=pObj.L;
				}
				
				if (pObj.wrap == null && TF_CONF.PAGE.wrap != null) {
					pObj.wrap = TF_CONF.PAGE.wrap;
				}
				
				//If you change page you loose the state of the previous page
				currPageState = null;
				pageState[TF_CONF.PID] = null;
			

				
				//storing this here since we have uid already but not alias always. Is again overwritten on dispatchPage 
				//since both are set then...still needed to check browser rebound for page id
				TF_CONF.PID = pObj.id;
				/*
				This can be used to save CPU and clear loadqueue etc
				*/
				dispatchEvent(new RenderingEvent(RenderingEvent.ON_PRE_SET_PAGE,pObj));
				
				if(pObj.id>0 || pObj.alias !=''){
					//Is this page already in motherload?
					var cachedPage:TFPage = getCachedPage(pObj.id, pObj.L,pObj.alias);
					

				}
				if (cachedPage) {
					
					//Dispatch preloaded paged
					_page = cachedPage;//Access this to get current page data!
					TEMPLATE_ID = _page.TEMPLATE.uid;
					//transfer registered frames and menus if still same template id
					if(OLD_TEMPLATE_ID == TEMPLATE_ID){
						_page.TEMPLATE.menus = _menus;
						_page.TEMPLATE.frames = _frames;
					
					}else {
						//otherwise clean them out
						_menus = {};
						_frames = { };
					}
					parseConf();//Parse string based conf values
					parsePageData();//
					//applyData();
					dispatchPage();
					OLD_TEMPLATE_ID = _page.TEMPLATE.uid;
					var title = _page.HEADER.title

				}else{
					Debug.output("Page ["+ pObj.id +" : "+ pObj.alias +"] not in cached motherload")
					if (pObj.alias != '') {
						pObj.id = 0;
					}
					call("getPage", pObj, handleGetPage);
					
					try{
						title = TF_CONF.INIT_PAGE_TITLE;//we use init page title seeing propably only first time we dont know title from motherload	
					}
					catch (e) {
						
					}
				}
				//Controls.debugMsg("Get page "+TF_CONF.PID + " in lang: " +TF_CONF.LANGUAGE);
			
				/*
				Tell menus etc whats up
				*/
				
				dispatchEvent(new RenderingEvent(RenderingEvent.ON_SET_PAGE,pObj));

				/*
				Update history frame
				if we are not walking down memory lane
				*/
				TF_CONF.DEEPLINK = pObj.deeplink

				if(TF_CONF.HISTORY_ENABLED && !nostalgic ){
					try{

						/*if(instance.pageState[TF_CONF.PID].length>0){
							str+="&pageState="+instance.pageState[TF_CONF.PID];
						}*/
						//If not same PID wipe all STATE and querystring info, only keep tmpl if exists
						
						var tmpl = SWFAddress.getParameter("tmpl");;
						if (tmpl) {
							tmpl = "?"+tmpl;
						}else {
							tmpl = "";
						}
						//But you keep the state of the template until you change template config/file in templateBase
						/*if(tplState[_page.TEMPLATE.uid]){
							str+="tplState="+tplState[_page.TEMPLATE.uid];
						}*/
						// TODO: Reinstate deeplink call
						//ExternalInterface.call("setDeepLink",str,title);
						if(TF_CONF.DEEPLINK && TF_CONF.INIT_PAGE_CALLED){
							SWFAddress.setValue(TF_CONF.DEEPLINK+tmpl);
							SWFAddress.setTitle(TF_CONF.SITE_TITLE + ': ' + title);
						}
						
					}
					catch (e:Error)
					{
						Debug.output("History error "+e)
					}
					//getURL("/typo3conf/ext/borg_typoflash/pi1/goto.php?"+str, "historyframe");
				}else if (TF_CONF.IS_LIVE){

					//But you keep the state of the template until you hange template config/file in templateBase
					/*if(tplState[_page.TEMPLATE.uid]){
						str+="tplState="+tplState[_page.TEMPLATE.uid];
					}*/
					
					//trace(title+" - " + str)
					
					
				}
			}else{
				//Controls.debugMsg("Not getting page since id was null");
			}
		}
			

		private static function handleGetPage(re:Object)	{
			

			if(re.errortype>0){
				var error = new TFError(re.errortype, re.errormsg, "getPage");
				dispatchEvent(new RenderingEvent(RenderingEvent.ON_GET_PAGE, error));	
			}else if(re){
				//just returned true
				//Controls.debugMsg(re);
				_page = new TFPage(re);//Access this to get current page data!
				
				// TODO: Addd each single retrieved page to a local cached motherload
				
				TEMPLATE_ID = _page.TEMPLATE.uid;
				Debug.output(_page)
			
				//transfer registered frames and menus if still same template id
				if(OLD_TEMPLATE_ID == TEMPLATE_ID){
					_page.TEMPLATE.menus = _menus;
					_page.TEMPLATE.frames = _frames;
				
				}

				parseConf();//Parse string based conf values
				// TODO : Reinstate and fix bug, move into TFPage
				parsePageData();//				
				
				dispatchPage();
				OLD_TEMPLATE_ID = _page.TEMPLATE['uid'];
			}else{
				
			}
		}

		public static function dispatchPage() {
			/*not sending page data with event now. Maybe reinstate if a need for page requests that will not become
			 * _page should arise. Until then access pages throgh page function below instead of event.data
			 */ 
			TF_CONF.PID = _page.HEADER.uid;//save PID to be able to swithc language for same page
			TF_CONF.ALIAS = _page.HEADER.alias;
			//first dispatch to glue to set key if not set
			dispatchEvent(new RenderingEvent(RenderingEvent.ON_PRE_GET_PAGE));
			//then inform all the others of the glorious news
			dispatchEvent(new RenderingEvent(RenderingEvent.ON_GET_PAGE));
			
		}
		/*
		Access this to get current page data.
		Use instead of any global variables.
		Eg. page.TEMPLATE.template_pid
		*/
		public static function get page():TFPage{
			return _page;
		}
		

		/*
		Use this to access pages from the motherload without dispatching a new getPage call nor to actually set the current pid.
		Useful for rendering parts of a sites motherload when retrieved
		PID or alias!!
		*/
		public static function getCachedPage(pid:int,l:int=-1,alias:String=''):TFPage{
			if(!(l>-1)){
				if(TF_CONF.LANGUAGE>0){
					l = TF_CONF.LANGUAGE;
				}else{
					l = 0;
				}
			}
			return _motherload.getPage(pid, l,alias);
			
		}





		/*
		 * This converts template and page data which have been set by individual Components.
		 * Because it can be done on page level as well as template level, and because the template
		 * is just another page, it makes sense to call it pageData.
		 * 
		 * ApplyData is called automatically onGetPage. 
		 * 
		 * If called with modified TEMPLATE data send the whole TEMPLATE array containing page_data and template_data
		 * properties as argument. Else current page will be used. 
		 * 
		 * In case any duplicate data keys (originally movieclip paths) are found, the page level data will 
		 * take precedence.
		 * 
		 * Data is arranged on language. Unless L is passed on current language will be used.
		 * 
		 * It will send all data as an object to the onData function of respective Component
		 */
		static function parsePageData(o:TFTemplate=null, L:int=-1){
			_data = { };
			
			if(o==null){
				o = _page.TEMPLATE;
			}
			if((L == -1)&& (TF_CONF.LANGUAGE >0)){
				L = TF_CONF.LANGUAGE;
			}else if (L == -1){
				L = 0;
			}

			var d = {};
			//Merge template with page data
			try{
				for (var n in o.template_data[L]){
					d[n] = o.template_data[L][n];
					trace("parsePageData "+ o.template_data[L][n])
				}
			}
			catch (e:Error){
				trace("No template data for lang")
			}
			try{
			for (n in o.page_data[L]){
				d[n] = o.page_data[L][n];
			}
			}
			catch (e:Error)
			{
				
			}
			/*Controls.debugMsg("Running parse data " + L + " LANGUAGE " + TF_CONF.LANGUAGE)
			Controls.debugMsg(d)*/

			for (n in d){
				_data[unescape(n)] = d[n];
				//Debug.output("Running parse data " + unescape(n) + " " + d[n])
			}
			
		}
		/*
		 * A movieclip can call this to apply all data directly to itself
		 * If no argumetn is sent it get applied to all mcs
		*/

		public static function applyData(mc=null){
			
			//Controls.debugMsg(instance._data[mc])
			if(mc!=null){
				parsePageData()
				//Controls.debugMsg("applyData called by " + mc)
				mc.onData(_data[mc]);
				/*for (var n in instance._data[mc]){
					mc[n] = instance._data[mc][n];
				}*/

			}else{
				//Dish it out to movieclips
				/*for (var n in instance._data){
					eval(n).onData(instance._data[n]);
					Controls.debugMsg("Sending onData to " + n)
				}*/
			}
		
		
		}
		/*
		 * Functions to retrieve data on component level
		*/
		public static function getPageData(key,L){
			var o:TFTemplate = _page.TEMPLATE;
			if((L == null)&& (TF_CONF.LANGUAGE >0)){
				L = TF_CONF.LANGUAGE;
			}else if (L == null){
				L = 0;
			}

			return o.page_data[L][escape(key)];

		}
		
		public static function getTemplateData(key,L){
			var o:TFTemplate = _page.TEMPLATE;
			if((L == null)&& (TF_CONF.LANGUAGE >0)){
				L = TF_CONF.LANGUAGE;
			}else if (L == null){
				L = 0;
			}

			return o.template_data[L][escape(key)];
		
		}
		
		public static function getHtmlVar(key, name):String {
          return TF_CONF.CORE.loaderInfo.parameters[key + '|' + name];
        };
		
		//TODO: move parseConf to TFTemplate
		
		public static function parseConf(){
			var c:TFTemplate = _page.TEMPLATE;
			_conf = {};//Create the conf lookup object
			try{
				var q = c.conf.split("&");
				var qv;

				for (var i=0;i<q.length;i++ ){
					qv = q[i].split("=");
					if(qv[0] !=""){
						_conf[qv[0]] = qv[1];
					}
				}
				//Transfer all template specific configuration to conf
				q = c.template_conf.split("&");

				for (i=0;i<q.length;i++ ){
					qv = q[i].split("=");
					if(qv[0] !=""){
						_conf[qv[0]] = qv[1];
					}
				}
				//Transfer all page specific configuration to conf
				q = c.page_conf.split("&");

				for (i=0;i<q.length;i++ ){
					qv = q[i].split("=");
					if(qv[0] !=""){
						_conf[qv[0]] = qv[1];
					}
				}
			}
			catch (e:Error)
			{
				
			}
		
		}
		/*
		This returns a value for the name if there is one
		*/
		public static function getConf(name){
			try{	
				return _conf[name];
			}
			catch (e:Error){}
			return { };
		}


		/*
		 * This returns an object with all the data for the movieclip with the path=key
		 */

		public static function getData(key:String) {
			try{
				return _data[key];
			}
			catch (e:Error){}
			return { };
		}



		//Returns a menu object having x as parent id.	
		
		public static function getMenu(pObj:TFMenuRequest)	{
			// TODO: How does showHiddenPage affect TFPageRequest?
			/*
			You can pass fields to this function, all fields of pages table
			Returns a menu object having x as parent id. Accepts type=FEmenu or BEmenu, L, 
			no_cache, doktype SQL clause starting with AND.., showHiddenPage, showDeletedPage, 
			showTimedPage, menuId and array of fields"
			*/
			
			if(TF_CONF.LANGUAGE>0){
				pObj.L = TF_CONF.LANGUAGE;
			}else{
				pObj.L = 0;
			}
			TF_CONF.PID = pObj.id;//save PID to be able to swithc language for same page
			
			call("getMenu", pObj, handleGetMenu);
			dispatchEvent(new RenderingEvent(RenderingEvent.ON_REQUEST_MENU,pObj));
	
		}
			
		/*
		 * Menu is parsed and sent with event since a template can contain many menus, a listener needs to know 
		 * which to render
		 */ 
			
		
		private static function handleGetMenu(re:Object)	{
			
			if(re.errortype>0){
				var error = new TFError(re.errortype, re.errormsg, "onGetMenu");
				dispatchEvent(new RenderingEvent(RenderingEvent.ON_GET_MENU, error));
			}else if(re){
				var tfMenu:TFMenu = new TFMenu(re);
				Debug.output(tfMenu)
				dispatchEvent(new RenderingEvent(RenderingEvent.ON_GET_MENU,tfMenu));
			}else{
				
			}
			
		}


		/* Returns an array of all subpages of page with id x. Use to retrieve a whole website in one go, 
		 * instead of doing getPage calls everytime. This is normally done in the template_init.as file 
		 * by means of a getMenu listener that gets every motherload for every getMenu call. 
		*/
		public static function getMotherload(pObj:TFPageRequest){
			if(TF_CONF.LANGUAGE>0){
				pObj.L = TF_CONF.LANGUAGE;
			}else{
				pObj.L = 0;
			}
			TF_CONF.PID = pObj.id;//save PID to be able to swithc language for same page
			call("getMotherload", pObj, handleGetMotherload);
		}
			
		private static function handleGetMotherload(re:Object)	{
			//Controls.debugMsg("Got motherload for language " + re.data['pObj']['L']+ ". Result: " +re.data.pages.length +" pages");
			//Controls.debugMsg(re.data['pObj']['L']);
			Debug.output("got motherload response");
			if (re.errortype > 0) {
				var error = new TFError(re.errortype, re.errormsg, "getMotherload");
				dispatchEvent(new RenderingEvent(RenderingEvent.ON_GET_MOTHERLOAD, error));
			}else if(re){
				//Save data on language. Accumulative function
				_motherload.parsePages(re['pages'], re['pObj']['L']);
				Debug.output(_motherload.toString());
				dispatchEvent(new RenderingEvent(RenderingEvent.ON_GET_MOTHERLOAD));
			}else{
				
			}
		}


		public static function getLanguages()	{
			call("getLanguages", null, handleGetLanguages);
		}
			

		private static function handleGetLanguages(re:Object)	{
			if (re.errortype > 0) {
				var error = new TFError(re.errortype, re.errormsg, "getLanguages");
				dispatchEvent(new RenderingEvent(RenderingEvent.ON_GET_LANGUAGES, error));		
			}else if(re){
				dispatchEvent(new RenderingEvent(RenderingEvent.ON_GET_LANGUAGES,re));
			}else{
				
			}
		}
		
		
		
		public static function setTemplateStateProperty(key:String,property:String,value:*){

			//first update internal object
			if(key ==null){
				throw new Error("setTemplateState no key set");
				return;
			}	
			
			var o = {}
			o.key = key;
			o[property] = value;
			setTemplateState(o);
		}

		public static function getTemplateStateProperty(key,property){
			return currTplState[key][property];
		}

		public static function getTemplateState(key){
			return currTplState[key];
		}
		/*
		These functions assume that you are passing an object with properties, eg.
		 and {o.key:projectViewer;o.state:true,o.id:3} or 3 strings
		*/

		 public static function setTemplateState(o){
			//first update internal object
		
			if(o.key ==null){
				throw new Error("setTemplateState no key set");
				return;
			}

			if(currTplState == null){
					currTplState = {};
			}
			
			if(currTplState[o.key] == null){
				currTplState[o.key]= {};
			}
			
			if(o is Object){
				for(var n in o){
					if(n != "key"){
						currTplState[o.key][n] = o[n];
					}
				}
			}else{
				//Controls.debugMsg("setTemplateState no object sent");
				return;
			}
			
			if(tplState == null){
				tplState = [];
			}
			//then serialise to update browser state
			tplState[_page.TEMPLATE.uid] = serialiseState(currTplState);

			if(TF_CONF.DEEPLINK != ''){
				var str = TF_CONF.DEEPLINK;
			}else{
				str = "";
			}
			
			if(pageState[TF_CONF.PID].length>0){
				str+="pageState="+pageState[TF_CONF.PID]+"&";
			}
			if(tplState[_page.TEMPLATE.uid].length>0){
				str+="tplState="+tplState[_page.TEMPLATE['uid']];
			}
			
			//trace(page.HEADER['title']+" - " + str)
			
			var currDp = unserialiseState(TF_CONF.DEEPLINK)
			var newDp = unserialiseState(str)
			if(!objectsAreEqual(newDp,currDp)){
				SWFAddress.setValue(str);
				SWFAddress.setTitle(TF_CONF.SITE_TITLE + ': ' + _page.HEADER.title);					
			}
		}
		
		

		public static function setPageStateProperty(key,property,value){
			//first update internal object
			if(key ==null){
				throw new Error("setPageStateProperty no key set");
				return;
			}	
			
			var o = {}
			o.key = key;
			o[property] = value;
			setPageState(o);
		}

		public static function getPageStateProperty(key, property) {
			if(TF_CONF.USE_PARAMETERS_NAMESPACE){
				return currPageState[key][property];
			}else{
				return SWFAddress.getParameter(property);
			}		
					
			
		}


		public static function setPageState(o){
			

			//first update internal object
			if(currPageState == null){
				currPageState = {};
			}
			if(currPageState[o.key] == null){
				currPageState[o.key]= {};
			}

			if(o is Object){
				for(var n in o){
					if(n != "key"){
						currPageState[o.key][n] = o[n];
					}
				}
			}else{
				throw new Error("setPageState no object sent");
				return;
			}


			//then serialise to update browser state
			if(pageState == null){
				pageState = [];
			
			}
			try {
				//get page id, alias and language
				if(TF_CONF.DEEPLINK != ''){
					var str = TF_CONF.DEEPLINK+"?";
				}else{
					str = "?";
				}			
				if (TF_CONF.USE_PARAMETERS_NAMESPACE) {
					//use namespace nesting
					pageState[TF_CONF.PID] = serialiseState(currPageState);
					if(pageState[TF_CONF.PID].length>0){
						str+="page="+pageState[TF_CONF.PID]+"&";
					}
					if(tplState[page.TEMPLATE['uid']]){
						str+="tmpl="+tplState[page.TEMPLATE.uid];
					}
				}else {
					//use plain url encoded parameters
					pageState[TF_CONF.PID] = urlEncode(currPageState[o.key]);
					if(pageState[TF_CONF.PID].length>0){
						str+=pageState[TF_CONF.PID];
					}
					if(tplState[page.TEMPLATE['uid']]){
						str+=tplState[page.TEMPLATE.uid];
					}
				}
			}
			catch (e:Error)
			{
				//Debug.output("ContentRendering.setPageState " + e);
			}
			

			//var title = page.HEADER['title'];//we got title from motherload

			var currDp = urlDecode(SWFAddress.getQueryString())
			var newDp = urlDecode(str)
			if(!objectsAreEqual(newDp,currDp)){
				SWFAddress.setValue(str);
				//SWFAddress.setTitle(TF_CONF.SITE_TITLE + ': ' + title);					
			}
			
			
		}
		/*
		 * Clear SWFAddress parameters
		 */ 
		public static function clearQueryParameters() {
			SWFAddress.setValue(SWFAddress.getPath());
		}
	//tmpl = projectViewer|id:3;accounts|id:4;accounts|state:open;

		private static function onExtTemplateState(e:CoreEvent){
			
			if(!objectsAreEqual(e.data,tplState[page.TEMPLATE.uid])){
				currTplState = unserialiseState(e.data);
				tplState[page.TEMPLATE.uid] = e.data;
				/*
				Send on to current template
				*/
				dispatchEvent(new RenderingEvent(RenderingEvent.ON_TEMPLATE_STATE));
				
				
			}
		}
		
		private static function onExtPageState(e:CoreEvent){
			if(TF_CONF.USE_PARAMETERS_NAMESPACE){
				if(!objectsAreEqual(e.data, pageState[TF_CONF.PID])){
					currPageState = unserialiseState(e.data);
					pageState[TF_CONF.PID] = e.data;
					dispatchEvent(new RenderingEvent(RenderingEvent.ON_PAGE_STATE));
				}
			}else{
				var params = SWFAddress.getParameterNames();
				TF_CONF.QUERY_PARAMETERS = { };
				for each( var n in params) {
					TF_CONF.QUERY_PARAMETERS[n] = SWFAddress.getParameter(n);
				}
				dispatchEvent(new RenderingEvent(RenderingEvent.ON_PAGE_STATE));
			}
		}

		
		private static function objectsAreEqual(a,b){
			if(!(a is Object) || !(b is Object) ){
				return false;
			}
			//checks if all props in a have eq in b and vice versa

			for(var n in a){
				if(String(a[n]) != String(b[n])){
					return false;
				}
			}
		
			for(n in b){
				if(String(a[n]) != String(b[n])){
					return false;
				}
			}
				
			return true;
		}

		private static function unserialiseState(o){
			o = unescape(o);
			var q = o.split(";");
			var qv;
			var pObj ={};
			var s;
			for (var i=0;i<q.length;i++ ){
				qv = q[i].split(":");
				if(qv[0] !=""){
					//split like projectViewer|id:3
					//and crate projectViewer key if doesnt exist
					s = qv[0].split("|");
					if(pObj[s[0]] == null){
						pObj[s[0]]={};
					}
					pObj[s[0]][s[1]] = qv[1];
				}

			}	
			
			return pObj;

		}
		

		/*
		Serialises an object of 2 levels of depth
		o.projectViewer.id = 2;
		becomes 
		projectViewer|id:2;
		*/
		private static function serialiseState(o){
			var str="";

			for(var n in o){
				//if(n != "key"){
					for(var k in o[n]){
						str+=n+"|"+k +":"+o[n][k]+";";
					}
				//}
			}
			
			return str;

		}

		public static function urlEncode(o:Object){
			var str="";

			for(var n in o){
				str+=n+"="+o[n]+"&";
			}
			
			return str;

		}

	
		public static function urlDecode(str:String):Object {
			var qs = str.split('&');
			var qv;
			var o = {};
			var i = 0;
			while (i < qs.length) {
			  qv = qs[i].split('=');
			  if (qv[0] != '') {
				o[qv[0]] = qv[1];
			  }
			  ++i;
			}
			return o;
		}

		
		/*Returns all flash components and their records if user has page access
		pass object with properties
		-records=tt_content_11,tt_content_12
		-orderBy=name
		*/
		// TODO: TFRecordObject
		public static function getRecords(o)	{
			call("getRecords", o, getRecordsResult);

		}
			

		private static function getRecordsResult(re:Object)	{
		
			if(re.errortype>0){
				var error = new TFError(re.errortype, re.errormsg, "getRecords");
				dispatchEvent(new RenderingEvent(RenderingEvent.ON_GET_RECORDS, error));		
			}else if(re){
				dispatchEvent(new RenderingEvent(RenderingEvent.ON_GET_RECORDS,re));
			}else{
				
			}
		}
		/*
		 * Returns a result set and a callback function name
		 */ 
		// TODO: Format??
		public static function getRenderedContent(o){
			call("getRenderedContent",o,getRenderedContentResult);
		}

		private static function getRenderedContentResult(re:Object)	{
			if(re.errortype>0){
				var error = new TFError(re.errortype, re.errormsg, "getRenderedContent");
				dispatchEvent(new RenderingEvent(RenderingEvent.ON_GET_RENDERED_CONTENT, error));		
			}else if(re){
				//just returned true
				/*var o = {};
				o.type = re.data.callback;
				o.data = re.data.result;
				*/
				dispatchEvent(new RenderingEvent(RenderingEvent.ON_GET_RENDERED_CONTENT,re));
			}else{
				
			}
			//Controls.debugMsg(re);
		}






		public static function getMedia(o:TFMenuRequest) {
			call("getMedia", o, getMediaResult);
		}

		private static function getMediaResult(re:Object)	{
			if(re.errortype>0){
				var error = new TFError(re.errortype, re.errormsg, "getMedia");
				dispatchEvent(new RenderingEvent(RenderingEvent.ON_GET_MEDIA, error));		
			}else if(re){
				/*var o = {};
				o.type = re.data.callback;
				o.data = re.data.result;
				*/
				dispatchEvent(new RenderingEvent(RenderingEvent.ON_GET_MEDIA,re));
			}else{
				
			}
			//Controls.debugMsg(re);
		}




		public static function getMediaFromCategory(o:TFMenuRequest) {
			call("getMediaFromCategory",o,getMediaFromCategoryResult);
		}

		private static function getMediaFromCategoryResult(re:Object)	{
			if(re.errortype>0){
				var error = new TFError(re.errortype, re.errormsg, "getMediaFromCategory");
				dispatchEvent(new RenderingEvent(RenderingEvent.ON_GET_MEDIA_FROM_CATEGORY, error));	
			}else if(re){
				/*var o = {};
				o.type = re.data.callback;
				o.data = re.data.result;
				*/
				dispatchEvent(new RenderingEvent(RenderingEvent.ON_GET_MEDIA_FROM_CATEGORY,re));
			}else{
				
			}
			//Debug.output(["getMediaFromCategory",re]);
			//Controls.debugMsg(re);
		}


		



		//Cleans out cached files.	
		public static function clearCache()	{
			_motherload = new TFMotherload();
			call("clearCache",null,handleClearCache);
		}




		
		private static function handleClearCache(re:Object)	{
			if(re){
				dispatchEvent(new RenderingEvent(RenderingEvent.ON_CLEAR_CACHE));
			}else{
				
			}
			//Controls.debugMsg("handleClearCache")
		}
		




		private static function handleRemotingError( e):void 	{
			//throw new Error(e);
			Debug.output(["handleRemotingError",e]);
			for(var n in e){
			trace([n,e[n]]);
			}
		}
		

		/*
		 * Create an associative array of frames that actually exist in the moviecliip.
		 * They are registering themselves. This array should be used in configuration menus.
		*/
		
		public static function registerFrame(f:FrameBase){
			_frames[f.name] = f;
        };

       // public static function onFrameLoadBegin(e:RenderingEvent) {};

        public static function onFrameLoadComplete(e:RenderingEvent){
			var allLoaded = true;
			for (var n in _page.TEMPLATE.frames) {
				if (!_page.TEMPLATE.frames[n].allContentLoaded) {
					allLoaded = false;
				}
			}
			
			if (allLoaded) {
				dispatchEvent(new RenderingEvent(RenderingEvent.ON_PAGE_LOAD_COMPLETE));
			}
        };

		/*
		 * Create an associative array of menus that actually exist in the template.
		 * They are registering themselves. This array should be used in configuration menus.
		 */
		
		public static function registerMenu(m:MenuBase) {
			_menus[m.name] = m;

		}

		
		/*****************************************************************
		 *				NEWS FUNCTIONS
		 ******************************************************************/
		
		/*
		 * This function can retrieve either individual news items (uid) or all items in a specific page (pid)
		 */ 
		public static function getNews(o:TFRecordRequest ) { 
			if (!(o.uid > 0) && !(o.pid)) {
				Debug.output("Not getting news items since no uid or pid supplied")
			}
			call("getNews",o,getNewsResult);
		}

		private static function getNewsResult(re:Object)	{
			if(re.errortype>0){
				var error = new TFError(re.errortype, re.errormsg, "getNewsResult");
				dispatchEvent(new RenderingEvent(RenderingEvent.ON_GET_NEWS, error));	
			}else if (re) {
				//returns an object with both result and callback properties
				dispatchEvent(new RenderingEvent(RenderingEvent.ON_GET_NEWS,re));
			}else{
				
			}
			//Controls.debugMsg(re);
		}
	
		public static function getNewsFromCategories(o:TFRecordRequest) {			
			if (o.categories) {
				call("getNewsFromCategories", o, getNewsFromCategoriesResult);
			}else {
				Debug.output("Not getting news from categories since no categories supplied")
			}
		}

		private static function getNewsFromCategoriesResult(re:Object)	{
			if(re.errortype>0){
				var error = new TFError(re.errortype, re.errormsg, "getNewsFromCategories");
				dispatchEvent(new RenderingEvent(RenderingEvent.ON_GET_NEWS_FROM_CATEGORY, error));	
			}else if (re) {
				//returns an object with both result and callback properties
				dispatchEvent(new RenderingEvent(RenderingEvent.ON_GET_NEWS_FROM_CATEGORY,re));
			}else{
				
			}
			//Controls.debugMsg(re);
		}	
		
		/*
		 * Give ONE uid to retrieve all subcatecories
		 */ 
		public static function getNewsCategories(o:TFRecordRequest) {
			call("getNewsCategories",o,getNewsCategoriesResult);
			
		}

		private static function getNewsCategoriesResult(re:Object)	{
			if(re.errortype>0){
				var error = new TFError(re.errortype, re.errormsg, "getNewsCategoriesResult");
				dispatchEvent(new RenderingEvent(RenderingEvent.ON_GET_NEWS_CATEGORIES, error));	
			}else if (re) {
				//returns an object with both result and callback properties
				dispatchEvent(new RenderingEvent(RenderingEvent.ON_GET_NEWS_CATEGORIES,re));
			}else{
				
			}
			//Controls.debugMsg(re);
		}
		
		
		
		
		
	    /**
	    *   Event Dispatcher Functions
	    */
	    
	    public static function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = true):void {
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
		/*
		 * //localhost:806/typo3conf/ext/typoflash/remoting/imageprocessing.php?file=http://localhost:806/uploads/pics/P1010289.JPG&size=x500
		 * See size for options on non-distorting resizing:
		 * http://www.imagemagick.org/script/command-line-options.php#size
		 * eg. size=x500 sets height to 500 and width in proportion 
		 */ 
		public static function execImageResize(file:String, size:String):String {
			var md5sum = MD5.hash(file + "545"+size+ file);
			var url = TF_CONF.HOST_URL + "typo3conf/ext/typoflash/remoting/imageprocessing.php?";
			url += "file=" + file;
			url += "&size=" + size;
			url += "&md5sum=" + md5sum;
			return url;
		}
		
		public static function resizedImage(file:String, size:String):String {
			var md5sum = MD5.hash(file + "545"+size+ file);
			var url =  TF_CONF.HOST_URL + "uploads/pics/" + md5sum + file.substr( -4);
			//Debug.output("Contemtrend img "+ url)
			return url;
		}		
	}
}


/*
 * 
 * later version compare!
 * 
  movieClip 64 __Packages.net.typoflash.ContentRendering {

    #initclip
      if (!_global.net) {
        _global.net = new Object();
      }
      if (!_global.net.typoflash) {
        _global.net.typoflash = new Object();
      }
      if (!_global.net.typoflash.ContentRendering) {
        var v1 = function () {
          if (!net.typoflash.ContentRendering._allowInstantiation) {
            trace('Error: Instantiation failed: Use _global[\'TF\'][\'CONTENT_RENDERING\'] = ContentRendering.global instead of new ContentRendering().');
          }
          mx.events.EventDispatcher.initialize(this);
          this._motherload = {};
          _global.TF.CORE_EVENTS.addEventListener('onBrowserHistory', this);
          _global.TF.CORE_EVENTS.addEventListener('onExtPageState', this);
          _global.TF.CORE_EVENTS.addEventListener('onExtTemplateState', this);
          if (this.pageState == null) {
            this.pageState = [];
          }
        };

        net.typoflash.ContentRendering = v1;
        var v2 = v1.prototype;
        v2.__get__service = function () {
          if (this._service == null) {
            this._service = new mx.remoting.Service(_global.TF.REMOTING_GATEWAY, null, 'typoflash.remoting.contentrendering', null, null);
          }
          if (_global.TF.REMOTING_GATEWAY == null) {
            net.typoflash.utils.Debug.trace('_global[\'TF\'][\'REMOTING_GATEWAY\'] not set!!');
          }
          return this._service;
        };

        v2.onBrowserHistory = function (p) {
          net.typoflash.utils.Debug.trace('onBrowserHistory');
          net.typoflash.utils.Debug.trace(p);
          this.getPage(p.pObj, true);
        };


        v2.getCachedPage = function (pid, l) {
          if (l <= -1) {
            if (_global.TF.LANGUAGE > 0) {
              l = _global.TF.LANGUAGE;
            } else {
              l = 0;
            }
          }
          if (this._motherload[l][pid] != null) {
            return this._motherload[l][pid];
          } else {
            return false;
          }
        };

        v2.parsePageData = function (o, L) {
          this._data = {};
          if (o == null) {
            o = (this.__get__page()).TEMPLATE;
          }
          if (L == null && _global.TF.LANGUAGE > 0) {
            L = _global.TF.LANGUAGE;
          } else {
            if (L == null) {
              L = 0;
            }
          }
          var v4 = {};
          for (var v6 in o.template_data[L]) {
            v4[v6] = o.template_data[L][v6];
          }
          for (v6 in o.page_data[L]) {
            v4[v6] = o.page_data[L][v6];
          }
          for (v6 in v4) {
            this._data[v6] = v4[v6];
          }
          var v7 = {};
          v7.type = 'onParsePageData';
          v7.data = this._data;
          this.dispatchEvent(v7);
        };

        v2.applyData = function (mc) {
          if (mc != null) {
            this.parsePageData();
            mc.onData(this._data[mc]);
          } else {}
        };

        v2.getPageData = function (key, L) {
          var v4 = (this.__get__page()).TEMPLATE;
          if (L == null && _global.TF.LANGUAGE > 0) {
            L = _global.TF.LANGUAGE;
            return v4.page_data[L][key];
          }
          if (L == null) {
            L = 0;
          }
          return v4.page_data[L][key];
        };

        v2.getTemplateData = function (key, L) {
          var v4 = (this.__get__page()).TEMPLATE;
          if (L == null && _global.TF.LANGUAGE > 0) {
            L = _global.TF.LANGUAGE;
            return v4.template_data[L][key];
          }
          if (L == null) {
            L = 0;
          }
          return v4.template_data[L][key];
        };

        v2.parseConf = function () {
          var v5 = (this.__get__page()).TEMPLATE;
          this._conf = {};
          var v4 = v5.conf.split('&');
          var v3;
          var v2 = 0;
          while (v2 < v4.length) {
            v3 = v4[v2].split('=');
            if (v3[0] != '') {
              this._conf[v3[0]] = v3[1];
            }
            ++v2;
          }
          v4 = v5.template_conf.split('&');
          v2 = 0;
          while (v2 < v4.length) {
            v3 = v4[v2].split('=');
            if (v3[0] != '') {
              this._conf[v3[0]] = v3[1];
            }
            ++v2;
          }
          v4 = v5.page_conf.split('&');
          v2 = 0;
          while (v2 < v4.length) {
            v3 = v4[v2].split('=');
            if (v3[0] != '') {
              this._conf[v3[0]] = v3[1];
            }
            ++v2;
          }
        };

        v2.getConf = function (name) {
          return this._conf[name];
        };

        v2.getData = function (key) {
          return this._data[key];
        };

        v2.getHtmlVar = function (key, name) {
          return _level0[key + '|' + name];
        };



        v2.getLanguages = function () {
          var v2 = (this.__get__service()).getLanguages();
          v2.__set__responder(new mx.rpc.RelayResponder(this, 'handleGetLanguages', 'handleRemotingError'));
        };

        v2.handleGetLanguages = function (re) {
          if ((re.__get__result()).errortype > 0) {
            var v2 = {};
            v2.type = 'onGetLanguages';
            v2.status = false;
            v2.errortype = (re.__get__result()).errortype;
            v2.errormsg = (re.__get__result()).errormsg;
            this.dispatchEvent(v2);
          } else {
            if (re.__get__result()) {
              var v2 = {};
              v2.type = 'onGetLanguages';
              v2.status = true;
              v2.data = re.result;
              this.dispatchEvent(v2);
            } else {}
          }
        };

        v2.setTemplateStateProperty = function (key, property, value) {
          if (key == null) {
            net.typoflash.utils.Debug.trace('setTemplateState no key set');
            return undefined;
          }
          var v2 = {};
          v2.key = key;
          v2[property] = value;
          this.setTemplateState(v2);
        };

        v2.getTemplateStateProperty = function (key, property) {
          return this.currTplState[key][property];
        };

        v2.getTemplateState = function (key) {
          return this.currTplState[key];
        };

        v2.setTemplateState = function (o) {
          if (o.key == null) {
            net.typoflash.utils.Debug.trace('setTemplateState no key set');
            return undefined;
          }
          if (this.currTplState == null) {
            this.currTplState = {};
          }
          if (this.currTplState[o.key] == null) {
            this.currTplState[o.key] = {};
          }
          if (typeof o == 'object') {
            for (var v5 in o) {
              if (v5 != 'key') {
                this.currTplState[o.key][v5] = o[v5];
              }
            }
          } else {
            net.typoflash.utils.Debug.trace('setTemplateState no object sent');
            return undefined;
          }
          if (this.tplState == null) {
            this.tplState = [];
          }
          var v7 = this.tplState[(this.__get__page()).TEMPLATE.uid];
          this.tplState[(this.__get__page()).TEMPLATE.uid] = this.serialiseState(this.currTplState);
          if (this.currPageDeeplink != null) {
            var v4 = this.currPageDeeplink;
          } else {
            var v4 = '';
          }
          if (this.pageState[_global.TF.PID].length > 0) {
            v4 += 'pageState=' + this.pageState[_global.TF.PID] + '&';
          }
          if (this.tplState[(this.__get__page()).TEMPLATE.uid].length > 0) {
            v4 += 'tplState=' + this.tplState[(this.__get__page()).TEMPLATE.uid];
          }
          var v8 = this.unserialiseState(this.currPageDeeplink + 'pageState=' + this.pageState[_global.TF.PID] + '&' + v7);
          var v9 = this.unserialiseState(v4);
          if (!this.objectsAreEqual(v9, v8)) {
            var v6 = _global.TF.SITE_TITLE + ': ' + (this.__get__page()).HEADER.title;
            flash.external.ExternalInterface.call('setDeepLink', v4, v6);
          }
        };

        v2.setPageStateProperty = function (key, property, value) {
          if (key == null) {
            net.typoflash.utils.Debug.trace('setPageStateProperty no key set');
            return undefined;
          }
          var v2 = {};
          v2.key = key;
          v2[property] = value;
          this.setPageState(v2);
        };

        v2.getPageStateProperty = function (key, property) {
          return this.currPageState[key][property];
        };

        v2.setPageState = function (o) {
          if (this.currPageState == null) {
            this.currPageState = {};
          }
          if (this.currPageState[o.key] == null) {
            this.currPageState[o.key] = {};
          }
          if (typeof o == 'object') {
            for (var v5 in o) {
              if (v5 != 'key') {
                this.currPageState[o.key][v5] = o[v5];
              }
            }
          } else {
            net.typoflash.utils.Debug.trace('setPageState no object sent');
            return undefined;
          }
          if (this.pageState == null) {
            this.pageState = [];
          }
          var v6 = 'pageState=' + this.pageState[_global.TF.PID] + '&';
          this.pageState[_global.TF.PID] = this.serialiseState(this.currPageState);
          if (this.currPageDeeplink != null) {
            var v4 = this.currPageDeeplink;
          } else {
            var v4 = '';
          }
          if (this.pageState[_global.TF.PID].length > 0) {
            v4 += 'pageState=' + this.pageState[_global.TF.PID] + '&';
          }
          if (this.tplState[(this.__get__page()).TEMPLATE.uid].length > 0) {
            v4 += 'tplState=' + this.tplState[(this.__get__page()).TEMPLATE.uid];
          }
          var v7 = (this.__get__page()).HEADER.title;
          var v8 = this.unserialiseState(this.currPageDeeplink + v6 + 'tplState=' + this.tplState[(this.__get__page()).TEMPLATE.uid]);
          var v9 = this.unserialiseState(v4);
          if (!this.objectsAreEqual(v9, v8)) {
            v7 = _global.TF.SITE_TITLE + ': ' + (this.__get__page()).HEADER.title;
            flash.external.ExternalInterface.call('setDeepLink', v4, v7);
          }
        };

        v2.onExtTemplateState = function (o) {
          net.typoflash.utils.Debug.trace('onExtTemplateState');
          net.typoflash.utils.Debug.trace(o);
          if (!this.objectsAreEqual(o.state, this.tplState[(this.__get__page()).TEMPLATE.uid])) {
            this.currTplState = this.unserialiseState(o.state);
            this.tplState[(this.__get__page()).TEMPLATE.uid] = o.state;
            o = {};
            o.type = 'onTemplateState';
            o.state = this.currTplState;
            this.dispatchEvent(o);
          }
        };

        v2.onExtPageState = function (o) {
          net.typoflash.utils.Debug.trace('onExtPageState');
          net.typoflash.utils.Debug.trace(o);
          if (!this.objectsAreEqual(o.state, this.pageState[_global.TF.PID])) {
            this.currPageState = this.unserialiseState(o.state);
            this.pageState[_global.TF.PID] = o.state;
            o = {};
            o.type = 'onPageState';
            o.state = this.currPageState;
            this.dispatchEvent(o);
          }
        };

        v2.setLanguage = function (L) {
          if (L == _global.TF.LANGUAGE) {
            return undefined;
          }
          net.typoflash.utils.Debug.trace('Content rendering setLanguage ' + L);
          this._motherload = {};
          var v4 = {};
          v4.id = _global.TF.PID;
          _global.TF.LANGUAGE = L;
          v4.L = _global.TF.LANGUAGE;
          this.getPage(v4);
          _global.TF.COOKIE.setData('language', L);
          var v3 = {};
          v3.type = 'onSetLanguage';
          v3.target = this;
          this.dispatchEvent(v3);
        };

        v2.objectsAreEqual = function (a, b) {
          if (typeof a != 'object' || typeof b != 'object') {
            return false;
          }
          for (var v3 in a) {
            if (String(a[v3]) != String(b[v3])) {
                            return false;
            }
          }
          for (v3 in b) {
            if (String(a[v3]) != String(b[v3])) {
                            return false;
            }
          }
          return true;
        };

        v2.unserialiseState = function (o) {
          o = unescape(o);
          var v5 = o.split(';');
          var v3;
          var v4 = {};
          var v1;
          var v2 = 0;
          while (v2 < v5.length) {
            v3 = v5[v2].split(':');
            if (v3[0] != '') {
              v1 = v3[0].split('|');
              if (v4[v1[0]] == null) {
                v4[v1[0]] = {};
              }
              v4[v1[0]][v1[1]] = v3[1];
            }
            ++v2;
          }
          return v4;
        };

        v2.serialiseState = function (o) {
          var v2 = '';
          for (var v4 in o) {
            for (var v3 in o[v4]) {
              if (v4 != null && v3 != null && o[v4][v3] != null) {
                v2 += v4 + '|' + v3 + ':' + o[v4][v3] + ';';
              }
            }
          }
          return v2;
        };

        v2.getRecords = function (o) {
          var v2 = (this.__get__service()).getRecords(o);
          v2.__set__responder(new mx.rpc.RelayResponder(this, 'getRecordsResult', 'handleRemotingError'));
        };

        v2.getRecordsResult = function (re) {
          net.typoflash.utils.Debug.trace(re);
          if ((re.__get__result()).errortype > 0) {
            var v2 = {};
            v2.type = 'onGetRecords';
            v2.status = false;
            v2.errortype = (re.__get__result()).errortype;
            v2.errormsg = (re.__get__result()).errormsg;
            this.dispatchEvent(v2);
          } else {
            if (re.__get__result()) {
              var v2 = {};
              v2.type = 'onGetRecords';
              v2.status = true;
              v2.records = re.result;
              this.dispatchEvent(v2);
            } else {}
          }
        };

        v2.getRenderedContent = function (o) {
          var v2 = (this.__get__service()).getRenderedContent(o);
          v2.__set__responder(new mx.rpc.RelayResponder(this, 'getRenderedContentResult', 'handleRemotingError'));
        };

        v2.getRenderedContentResult = function (re) {
          if ((re.__get__result()).errortype > 0) {
            var v4 = {};
            v4.type = 'onError';
            v4.errorfunction = 'select';
            v4.errortype = (re.__get__result()).errortype;
            v4.errormsg = (re.__get__result()).errormsg;
            _global.TF.CORE_EVENTS.dispatchEvent(v4);
          } else {
            if (re.__get__result()) {
              var v4 = {};
              v4.type = (re.__get__result()).callback;
              v4.data = (re.__get__result()).result;
              this.dispatchEvent(v4);
            } else {}
          }
          net.typoflash.utils.Debug.trace(re);
        };

        v2.getMedia = function (o) {
          net.typoflash.utils.Debug.trace('ContentRendering call getMedia');
          net.typoflash.utils.Debug.trace(o);
          var v2 = (this.__get__service()).getMedia(o);
          v2.__set__responder(new mx.rpc.RelayResponder(this, 'getMediaResult', 'handleRemotingError'));
        };

        v2.getMediaResult = function (re) {
          if ((re.__get__result()).errortype > 0) {
            var v3 = {};
            v3.type = 'onError';
            v3.errorfunction = 'select';
            v3.errortype = (re.__get__result()).errortype;
            v3.errormsg = (re.__get__result()).errormsg;
            _global.TF.CORE_EVENTS.dispatchEvent(v3);
          } else {
            if (re.__get__result()) {
              var v3 = {};
              v3.type = (re.__get__result()).callback;
              v3.data = re.result;
              v3.target = this;
              this.dispatchEvent(v3);
            } else {}
          }
        };

        v2.getMediaFromCategory = function (o) {
          net.typoflash.utils.Debug.trace('ContentRendering call getMediaFromCategory');
          net.typoflash.utils.Debug.trace(o);
          var v2 = (this.__get__service()).getMediaFromCategory(o);
          v2.__set__responder(new mx.rpc.RelayResponder(this, 'getMediaFromCategoryResult', 'handleRemotingError'));
        };

        v2.getMediaFromCategoryResult = function (re) {
          if ((re.__get__result()).errortype > 0) {
            var v3 = {};
            v3.type = 'onError';
            v3.errorfunction = 'select';
            v3.errortype = (re.__get__result()).errortype;
            v3.errormsg = (re.__get__result()).errormsg;
            _global.TF.CORE_EVENTS.dispatchEvent(v3);
          } else {
            if (re.__get__result()) {
              var v3 = {};
              v3.type = (re.__get__result()).callback;
              v3.data = (re.__get__result()).result;
              v3.target = this;
              this.dispatchEvent(v3);
            } else {}
          }
        };

        v2.clearCache = function () {
          var v2 = (this.__get__service()).clearCache();
          v2.__set__responder(new mx.rpc.RelayResponder(this, 'handleClearCache', 'handleRemotingError'));
        };

        v2.handleClearCache = function (re) {
          if ((re.__get__result()).errortype > 0) {
          } else {
            var v2 = {};
            v2.type = 'onClearCache';
            v2.status = true;
            v2.data = re;
            net.typoflash.utils.Debug.trace('ConternRendering.handleClearCache cleared motherload');
            this._motherload = {};
            this.dispatchEvent(v2);
          }
        };

        v2.handleRemotingError = function (fault) {
          var v2 = {};
          v2.type = 'onRemotingError';
          v2.errormsg = (fault.__get__fault()).faultstring;
          _global.TF.CORE_EVENTS.dispatchEvent(v2);
        };

        v2.registerFrame = function (f) {
          if ((this.__get__page()).TEMPLATE.frames == null) {
            (this.__get__page()).TEMPLATE.frames = {};
            this._frames = (this.__get__page()).TEMPLATE.frames;
          }
          (this.__get__page()).TEMPLATE.frames[f._name] = f;
          this._frames[f._name] = (this.__get__page()).TEMPLATE.frames[f._name];
          f.addEventListener('onFrameLoadBegin', net.typoflash.ContentRendering.__get__global());
          f.addEventListener('onFrameLoadComplete', net.typoflash.ContentRendering.__get__global());
        };

        v2.onFrameLoadBegin = function (o) {};

        v2.onFrameLoadComplete = function (o) {
          var v2 = true;
          for (var v3 in this._frames) {
            if (!this._frames[v3].allContentLoaded) {
              v2 = false;
            }
          }
          if (v2) {
            o = {};
            o.type = 'onPageLoadComlete';
            this.dispatchEvent(o);
          }
        };

        v2.registerMenu = function (m) {
          if ((this.__get__page()).TEMPLATE.menus == null) {
            (this.__get__page()).TEMPLATE.menus = {};
            this._menus = (this.__get__page()).TEMPLATE.menus;
          }
          (this.__get__page()).TEMPLATE.menus[m._name] = m;
          this._menus[m._name] = (this.__get__page()).TEMPLATE.menus[m._name];
        };

        v1.__get__global = function () {
          if (net.typoflash.ContentRendering._instance == null) {
            net.typoflash.ContentRendering._allowInstantiation = true;
            net.typoflash.ContentRendering._instance = new net.typoflash.ContentRendering();
            net.typoflash.ContentRendering._allowInstantiation = false;
          }
          return net.typoflash.ContentRendering._instance;
        };

        v1._instance = null;
        v1._allowInstantiation = false;
        v1.addProperty('global', v1.__get__global, function () {});
        v2.addProperty('motherload', v2.__get__motherload, function () {});
        v2.addProperty('page', v2.__get__page, function () {});
        v2.addProperty('service', v2.__get__service, function () {});
        ASSetPropFlags(net.typoflash.ContentRendering.prototype, null, 1);
      }
    #endinitclip
  }
*/