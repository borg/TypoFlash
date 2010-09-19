/************************************************
TYPOFLASH CORE8 AS2
************************************************
BASIC CONCEPT


One core.swf contains classes
-CoreEvents
-LoadQueue
-HistoryController
-Cookie

and super globals such as HOST_URL, REMOTING_RELAY_SOCKET, REMOTING_RELAY_PORT,PAGE_ID, QUERY_STRING that need to be set in
Typo3
(eg. core.swf?&HOST_URL=http://typo3.elevated.to/&REMOTING_RELAY_SOCKET=typo3.elevated.to&REMOTING_RELAY_PORT=8888&RELAY_SERVER=typo3.elevated.to_8888.php&PRELOADER=preloader.swf&SWFS=fonts.swf,assets.swf&SWFS_SIZE=67274,94372,&PAGE_ID=29&L=&CODE_PAGE=1&SCALE_MODE=noScale&ALIGN=TL&BG_COLOUR=#AAB4AC&IS_LIVE=1&HISTORY_ENABLED=1&BE_USER=1&QUERY_STRING=flash%3D1")
First it calls remoting server for page data, then
it loads 
1. preloader.swf into level depth["preloader"]
2.assets.swf into level depth["assets"]
3. fonts.swf into level depth["assets"]
4. template_x.swf into level depth["template"]

making sure all asets are safely in cache.

A template would normally contain some static content and one array with
menus and one array with frames. 


PRELOADER HINTS
If preloader wants to be in front of content place a simple swapdepth in the root of the preloader, eg.
_global['TF'].LAYER["preloader"].swapDepths(25);

To hide a preloader when a template is truely loaded call the function from the template class init function or in the first getPage response, eg.
_global['TF'].LAYER["preloader"].preloader.revealTemplate();



To pass HOST_URL etc you need to set them in the template like this

[globalVar = GP:flash> 0]
	# tt_content < lib.alt_plaintext.renderObj
	config.disableAllHeaderCode = 1
	# Default PAGE object:
	myObj = PAGE
	myObj.typeNum = 0
	myObj.10 =USER
	myObj.10.userFunc =tx_borgtypoflash_pi1->main_page
	myObj.10.HOST_URL= http://puertaandaluza.com/
	myObj.10.REMOTING_RELAY_SOCKET = puertaandaluza.com
	myObj.10.REMOTING_RELAY_PORT = 8800
	# Don't prepend with path. Flash will assume 'typo3conf/ext/borg_remoting_relay/'
	myObj.10.RELAY_SERVER = puertaandaluza.com_8800.php
	myObj.10.CODE_PAGE = true
	myObj.10.SCALE_MODE = noScale
	myObj.10.ALIGN = TL
[end]

The local_init files are just for local testing. When live HOST_URL etc comes from typo3. The content_rendering default interpreter should reside inside the 
template instance. 

To start remoting relay server, run this in mozilla
http//puertaandaluza.com/typo3conf/ext/borg_flashremoting/borg_remoting_relay/puertaandaluza.com_8800.php

or this in Putty

/www/vhtdocs/typo3.elevated.to/puertaandaluza.com/typo3conf/ext/borg_remoting_relay/puertaandaluza.com_8800.php

Make sure 
/www/vhtdocs/typo3.elevated.to/puertaandaluza.com/typo3conf/ext/borg_remoting_relay/config/puertaandaluza_conf.php is writable and set



 A note on typo3 configuration of templates.
 3 (!) sets of configuration variables will be sent back to flash
 i. from flash record
 ii. from page where root template resides
 iii. from page record (with or without flash template)

 In flash this is also the order in which they will be written into the loaded template movieclip.
 Hence, if same variable is set in all thee sets the page specific one will take precedence

************************************************
AUTHENTICATION

If sessions expire on refresh disable IP_LOCK on that BE user. For some reason
it isn't picked up by remoting (see be_session table). Maybe fix that?


************************************************
GLOBALS

Globals are accessible in all scopes, but within classes you need to prepend with _global['TF']["MY_GLOBAL"]


************************************************
FLASH LIBRARY STRUCTURE 

Keep folders tidy!! Especially when importing images.

Typical structure:

-My Component (Can have the same name as the component, since even if it didn't have a space you can have nested same name symbols)
	MyComponent (in upper case if it has a Class attached in external as file, this is the only object that should be needed)
	-Component skins (graphical stuff that make up the component)
		headerGraphics
		bodyGraphics
		


Note: Never give same name to a class as to a global,
eg never have a global SIDEMENU variable and a SideMenu
class for a symbol id.

************************************************
ASSETS

When building a new template, first drag the _defaultImport symbol from the assets.fla. Then delete all included symbols
you don't need for authoring time deployment. In assets.fla you only need to make sure that all symbols required will be
included in that _defaultImport symbol. This way you don't need to clutter the library with disjointed folders.

You can attach imported symbols from assets.swf in a template.swf ONLY if they are checked to be exported for both runtime
and actionscript sharing in assets.swf AND loaded in template.swf before being called. However, in order to be loaded they need
to be placed on stage or be included in a symbol placed on stage. The trick hence is to place the _defaultImport on stage in the 
first frame. After that all exported symbols (that are included in that symbol) will be available to the template.

*********************/






import net.typoflash.datahandling.Cookie;
import net.typoflash.managers.CoreEvents;
import net.typoflash.managers.LoadQueue;
import net.typoflash.managers.FontManager;



//TYPOFLASH NAMESPACE
var G = _global['TF'] = {};




G.LAYER = {};

//Controls layout 
//note that depth manager only really manages depth WITHIN a layer, ie it can be used to manage popups and alerts within an application (or several
//in the case where you consider the typoflash editor one applicatoin with its modal windows, and perhaps managing a standalone template RIA
depth = {};
depth["tf"] = 0;

depth["root"] = 1;
depth["fonts"] = 5;

depth["assets"] = 2;
depth["bg"] = 5;
depth["template"] = 10;
depth["preloader"] = 20;
depth["editor"] = 30;
depth["debug"] = 40;
depth["swx"] = 234840;



/*
Root level. Needed for nested fonts
*/

var tf = G.LAYER["tf"] = this.createEmptyMovieClip("tf", depth["tf"]);
var fonts = G.LAYER["fonts"] = tf.createEmptyMovieClip("fonts", depth["fonts"]);
var root = G.LAYER["root"] = tf.createEmptyMovieClip("root", depth["root"]);
/*
Create a cover all bg.
It will be tinted according to template bgcolour
*/
var bg = G.LAYER["bg"] = root.createEmptyMovieClip("bg", depth["bg"]);



//
/*
Make sure these are included after TYPOFLASH namespace set as they become global singltons

Reasons for accessing them in global namespace rather than as singletons
1. No needto/risk of of including the same class several times in different files
2. If class is modified or completely exchanged only need to do it in one place as long as the API is maintained.
3. Smaller file size

Only reason not to do it like this is the risk of overwriting the same instance in separate file...but even that is avoided 
by letting the global instance access the singleton only. At the end of the day its all a matter of consistent code practice.

Singleton schmingleton

*/
var E = G['CORE_EVENTS'] = CoreEvents.global;
var Q = G['LOAD_QUEUE'] = LoadQueue.global;
var C = G['COOKIE'] = Cookie.global;
var FM = G['FONT_MANAGER'] = FontManager.global;

G['CORE'] = this;//refence to _level0 now..but might change
/*
Extract QUERY_STRING and build an array of name/value pairs instead
makeing each variable accessible like _global['TF']['QUERY_STRING']['myVar']
*/

var qs = unescape(QUERY_STRING);
qs = qs.split("&");
var qv;
G.QUERY_STRING = {};
for (var i=0;i<qs.length;i++ ){
	qv = qs[i].split("=");
	if(qv[0] !=""){
		G.QUERY_STRING[qv[0]] = qv[1];
	}
}


//_global['TF'].HOST_URL = "http://projects.puertaandaluza.com/";
//PAGE_ID = 50;
//---

/*
All these values come from typo3 via HTML
*/
G.HISTORY_ENABLED = Boolean(unescape(HISTORY_ENABLED)==1);
G.HOST_URL = unescape(HOST_URL);
G.REMOTING_RELAY_SOCKET = unescape(REMOTING_RELAY_SOCKET);
G.REMOTING_RELAY_PORT = Number(REMOTING_RELAY_PORT);
G.IS_LIVE=1;
G.PAGE_ID=  PAGE_ID;
G.INIT_PAGE_TITLE = unescape(TITLE);
G.SITE_TITLE = unescape(SITE_TITLE);
G.BE_USER = BE_USER;

G.HTTP_USER_AGENT = unescape(HTTP_USER_AGENT);
G.TYPO3_OS = unescape(TYPO3_OS);
if(L==0 || Number(L)>0){
	G.LANGUAGE = L;
}else{
	G.LANGUAGE = 0;
}
G.RELAY_SERVER = G.HOST_URL + "typo3conf/ext/remoting_relay/" +RELAY_SERVER;


System.useCodepage = CODE_PAGE; 
Stage.scaleMode = SCALE_MODE;
Stage.align = ALIGN;



System.security.allowDomain("*");
System.exactSettings = false;

G.REMOTING_GATEWAY = G.HOST_URL + "typo3conf/ext/flashremoting/amf.php";
G.SWX_GATEWAY = G.HOST_URL + "typo3conf/ext/flashremoting/swx.php";//is there a way of making the cache that happens with loadmovie to correspond to a motherload version?


G.HOST_PATH = G.HOST_URL +"uploads/tx_typoflash/";

G.ASSET_PATH = G.HOST_URL +"typo3conf/ext/typoflash/assets/";
//G.ROOT= this;


//RemotingRelaySocket.global;
//RemotingRelaySocket.connectSocket(REMOTING_RELAY_SOCKET, REMOTING_RELAY_PORT);






bg.beginFill (0xFFFFFF,100);
bg._x = bg._y = -2000;
bg.lineStyle (0, 0xFFFFFF, 0);
bg.moveTo (0, 0);
bg.lineTo (Stage.width+5000, 0);
bg.lineTo (Stage.width+5000, Stage.height+5000);
bg.lineTo (0, Stage.height+5000);
bg.endFill();

if(BG_COLOUR.length>0){
	BG_COLOUR = unescape(BG_COLOUR);
	var nc = BG_COLOUR.split("#")[1]
	nc = parseInt('0x' +nc );
	var col = new Color(bg);
	col.setRGB(nc);
}
	
/*
LoadQueue

Queue events:
onQueueCleared
onQueueChanged
onQueueStart
onQueueProgress
onQueueStop
onItemStart
onItemComplete
onItemTimeout

Item events:
onStart
onComplete
onProgress
onTimeout

You pass them as the third argument to load!!


var q = net.typoflash.managers.LoadQueue.global;
o = {};
o.onQueueStart = function(obj){
trace(" onQueueStart " + obj.target.getUrl()  )	
}
o.onQueueStop = function(obj){
trace(" onQueueStop " + obj.target.getUrl()  )	
}

o.onItemStart = function(obj){
trace(" onItemStart " +obj.target.getUrl())	
}
q.addEventListener("onQueueStart",o);
q.addEventListener("onQueueStop",o);
q.addEventListener("onItemStart",o);

q.load("http://puertaandaluza.com/uploads/tx_typoflash/flamenco_school_sevilla.jpg",mc2)

o.onProgress = function(evt_obj:Object) {
	 trace(evt_obj.target.getBytesLoaded() + " of " + evt_obj.target.getBytesTotal() + " bytes loaded.");
};


*/	

//LOADQUEUE config
//minimum preload steps
Q.setMinSteps(4);
//roughly 100/min step
Q.setIntervalMs(30);//lowered to be able to gage swx call progress
//Timeout = 4sec
Q.setTimeoutMs(4000);	

//load queue arguments(url,target, listener, file size,post/get,name,{additional:args})


   //Preload
var p = G.LAYER["preloader"] = root.createEmptyMovieClip("preloader", depth["preloader"]);


/*
Load assets
*/


var as = G.LAYER["assets"] = root.createEmptyMovieClip("assets", depth["assets"]);
as._x = 2500;
as._y=3000;
as._visible = false;


var pre = G.HOST_PATH+unescape(PRELOADER);

SWFS_SIZE = unescape(SWFS_SIZE);
var fsList = SWFS_SIZE.split(",");//The filesize of preloader,fonts,...assets... template 

if(PRELOADER.length>0){
	var pObj = {url:pre,target:p,name:'Preloader',filesize:fsList[0]}
	Q.load(pObj)
	var p=1;//indicate if preloader size is first in file size list or not
}else{
	var p=0;
}


//If there is an external preloader it will be loaded first, then assets and templates etc. 
var lObj,fList,f;

if(DYNAMIC_FONTS != null){
	DYNAMIC_FONTS = unescape(DYNAMIC_FONTS);
	FM.addEventListener("onFontRegister",this);	
	if(SWFS_SIZE.length>0){
		fList = G.DYNAMIC_FONTS = DYNAMIC_FONTS.split(",");
		var lib;

		//normalListener.files = fList;
		for(f=0;f<fList.length;f++){
			if((fList[f].length>0) && (fList[f] != null)){
				/*fontHolder = _root.createEmpty
				//load lib files first
				lib = fList[f].split(".");
				lib = lib[0]+"_lib."+lib[1]
				lObj = {url:G.HOST_PATH+lib,target:as,name:'Dynamic Font Lib '+G.HOST_PATH+lib,filesize:fsList[p]}
				Q.load(lObj);
				//p++;

				//load font file
				lObj = {url:G.HOST_PATH+fList[f],target:as,name:'Dynamic Font ' +G.HOST_PATH+fList[f],filesize:fsList[p]}
				Q.load(lObj);*/
				p++;
				
				FM.loadFont(fList[f],(f==fList.length-1))
				
				
			}
		}
	}
}
G['FONT_LIST'] = [];//populate with references
function onFontRegister(o):Void {
	
	G['FONT_LIST'].push(o);
	var referenceName = o.font 
	
	//Debug.trace("Template loaded dynamic font: " + referenceName )
	
	
}

if(FONTS != null){
	FONTS = unescape(FONTS);
	
	if(SWFS_SIZE.length>0){
		fList = G.SHARED_FONTS = FONTS.split(",");
		//normalListener.files = fList;
		for(f=0;f<fList.length;f++){
			if((fList[f].length>0) && (fList[f] != null)){
				lObj = {url:G.HOST_PATH+fList[f],target:as,name:'Shared Fonts',filesize:fsList[p]}
				Q.load(lObj);
				p++;
				
			}
		}
	}
}


if(SWFS != null){
	SWFS = unescape(SWFS);
	SWFS_SIZE = unescape(SWFS_SIZE);
	if(SWFS_SIZE.length>0){
		fList = SWFS.split(",");
		//normalListener.files = fList;
		for(f=0;f<fList.length;f++){
			if((fList[f].length>0) && (fList[f] != null)){
				lObj = {url:G.HOST_PATH+fList[f],target:as,name:'Assets',filesize:fsList[p]}
				Q.load(lObj);
				p++;
			}
		}
	}
}




/*
Load template
*/

var tmp = G.LAYER["template"] = root.createEmptyMovieClip("templates", depth["template"]);
//DepthManager.initialize(G.LAYER["template"]);
var tObj = {url:G.HOST_PATH+TEMPLATE,target:tmp,name:'TypoFlash template',filesize:fsList[fsList.length-1]}
Q.load(tObj)



/*
*PREFERENCES
*/


if (C.data.soundEnabled == null) {
	C.setData("soundEnabled",1);
}
if (C.data.highQuality == null) {
	C.setData("highQuality",1);
}
if (C.data.debugEnabled == null) {
	C.setData("debugEnabled",0);
}
if (C.data.storeFEuserdataEnabled == null) {
	C.setData("storeFEuserdataEnabled",0);
}
if (C.data.storeBEuserdataEnabled == null) {
	C.setData("storeBEuserdataEnabled",0);
}
if (C.data.autologinEnabled == null) {
	C.setData("autologinEnabled",0);

}
var pObj = {};

for(var v in _global['TF']['QUERY_STRING']){
	//Extract viable fields from query string. 
	pObj[v] = _global['TF']['QUERY_STRING'][v];
}
pObj['id'] = PAGE_ID;
G.INIT_pOBJ = pObj;



   
   

/*
BROWSER HISTORY CONTROL
*/

import flash.external.*;

var methodName:String = "updateFlashHistory";
var instance:Object = null;
var method:Function = updateFlashHistory;
var wasSuccessful:Boolean = ExternalInterface.addCallback(methodName, instance, method);
/*
05/04/2007
Deeplink update

Normally an onBrowserHistory event is only broadcasted if a change in the string that describes the state is detected.
But there are two types of components that can use the state API, the page dependent ones and the template dependent ones, 
the latter 

Hence an internal state needs to be maintained, which can contain more info than page id and L. 

*/

function updateFlashHistory(loc){
	if (_global['TF']['HISTORY_ENABLED']) {
		//getURL("javascript:alert('Got JS page "+loc+"')");
		
		var q = loc.split("&");
		var qv;
		var pObj ={};
		for (var i=0;i<q.length;i++ ){
			qv = q[i].split("=");
			if(qv[0] !="" && qv[0]!= "pageState"  && qv[0]!= "tplState" ){
				pObj[qv[0]] = qv[1];
			}else if(qv[0]== "tplState"){
				var bbb = {type:"onExtTemplateState",state:qv[1]};//received and parsed by content rendering
				 _global['TF']['CORE_EVENTS'].dispatchEvent(bbb);
				_global['TF']['CURR_TEMPLATE_STATE_STR'] = qv[1];
			}else if(qv[0]== "pageState"){
				var bbb = {type:"onExtPageState",state:qv[1]};//received and parsed by content rendering
				 _global['TF']['CORE_EVENTS'].dispatchEvent(bbb);
				_global['TF']['CURR_PAGE_STATE_STR'] = qv[1];
			}
		}	


		//On back butten clicked and we now arrive back at startpage(which probably is htpp://xxx.com/), we might not have the org id in cache. Default to start page
		if(!(Number(pObj['id'])>0)){
			pObj['id'] = _global['TF']['INIT_pOBJ']['id'];
		}

		if((String(_global['TF']['PID'])!= String(pObj['id']))&&((_global['TF']['LANGUAGE'] !=null)||( String(_global['TF']['LANGUAGE']) != String(pObj['L']))) && !_global['TF']['ONLY_TMPL_STATE']){
			var bbb = {type:"onBrowserHistory",pObj:pObj};
			 _global['TF']['CORE_EVENTS'].dispatchEvent(bbb);
		}else if(pObj['id']==null && !_global['TF']['ONLY_TMPL_STATE']){
			//if no page is set..ie first run from root.eg mydomain.com/...set default
			var bbb = {type:"onBrowserHistory",pObj:_global['TF'].INIT_pOBJ};
			 _global['TF']['CORE_EVENTS'].dispatchEvent(bbb);
		}
	}
}


/*
Edit conf items
*/
methodName = "externalEdit";
method = externalEdit;
ExternalInterface.addCallback(methodName, instance, method);

function externalEdit(key){
	_global['TF']['CONTENT_EDITING'].externalEdit(key);
}
//check if in debug and edit mode

if(C.data.debugEnabled){
	loadDebug();

}


if(C.data.editEnabled){
	loadEditor();

}






if(C.data.editEnabled){

	setAuthContext();

}else{
	setNonAuthContext();
}

//TODO: Add sound off to context menu


function setAuthContext(){
	
	//Add context menu
	menu = new ContextMenu();
	//hide default items
	for(var n in menu.builtInItems) {
	    menu.builtInItems[n] = false;
	}

	menu.customItems.push(new ContextMenuItem("» Clear TypoFlash cache", clearCache));
	 
	if(C.data.editEnabled){
		editItem = new ContextMenuItem("» Turn off Edit mode", turnOffEdit);
		
	}else{
		editItem = new ContextMenuItem("» Turn on Edit mode", turnOnEdit);
	}
	
	menu.customItems.push(editItem);

	if(C.data.debugEnabled){
		debugItem = new ContextMenuItem("» Turn off Debug mode", turnOffDebug);
		
	}else{
		debugItem = new ContextMenuItem("» Turn on Debug mode", turnOnDebug);
	}
	menu.customItems.push(debugItem);

	lgt = new ContextMenuItem("» Log out of TypoFlash", logout);
	menu.customItems.push(lgt);

	if (C.data.soundEnabled != false) {
		snd = new ContextMenuItem("» Mute all sounds", toggleSound);
	}else{
		snd = new ContextMenuItem("» Turn on sounds", toggleSound);
	}

	menu.customItems.push(snd);

	var power = new ContextMenuItem("» Powered by TypoFlash", credit);
	power.separatorBefore = true;
	menu.customItems.push(power);


}




function setNonAuthContext(){
	//Add context menu
	menu = new ContextMenu();
	//hide default items
	for(var n in menu.builtInItems) {
	    menu.builtInItems[n] = false;
	}

	if(C.data.editEnabled){
		editItem = new ContextMenuItem("» Turn off Edit mode", turnOffEdit);
		menu.customItems.push(editItem);
		
	}
	
	

	lgn = new ContextMenuItem("» Login to TypoFlash", loadEditor);
	lgn.separatorBefore = true;
	menu.customItems.push(lgn);


	if (C.data.soundEnabled != false) {
		snd = new ContextMenuItem("» Mute all sounds", toggleSound);
	}else{
		snd = new ContextMenuItem("» Turn on sounds", toggleSound);
	}

	menu.customItems.push(snd);

	var power = new ContextMenuItem("» Powered by TypoFlash", credit);
	power.separatorBefore = true;
	menu.customItems.push(power);


}





function credit() {
    getURL("http://typoflash.net", "_blank");
}

function clearCache(){
	//content rendering is included with any template...by using the global the class doesn't need to be included yet
	_global['TF']['CONTENT_RENDERING'].clearCache();
}

function turnOffDebug(){
	_global['TF']['COOKIE'].setData("debugEnabled",0);
	_global['TF']['LAYER']["debug"].unloadMovie();
	debugItem.caption = "» Turn on Debug mode";
	debugItem.onSelect = turnOnDebug;

}
function turnOnDebug(){
	_global['TF']['COOKIE'].setData("debugEnabled",1);
	loadDebug();
	debugItem.caption = "» Turn off Debug mode";
	debugItem.onSelect = turnOffDebug;

}

function turnOffEdit(){
	_global['TF']['COOKIE'].setData("editEnabled",0);
	
	var o = {};
	o.type = "onEditStatus";
	o.status = false;
	E.dispatchEvent(o);
}
function turnOnEdit(){
	_global['TF']['COOKIE'].setData("editEnabled",1);


	if(_global['TF']['EDITOR'] == null){
		loadEditor();
	}
	
	var o = {};
	o.type = "onEditStatus";
	o.status = true;
	E.dispatchEvent(o);
}

function loadDebug(){
	var d = _global['TF']['LAYER']["debug"] = root.createEmptyMovieClip("debug", depth["debug"]);
	var dObj = {url:_global['TF']['HOST_URL'] + "typo3conf/ext/typoflash/pi1/debug8.swf",target:d,name:'Debug window'}
	_global['TF']['LOAD_QUEUE'].load(dObj)
}


function loadEditor(){
	//it would appear the dispatchEvent scope is a bit inconsistent here...using this instead of _level0 worked for the debug load but not for
	//the editor in spite the fact they are called in the exact parallel way
	var d = _global['TF']['LAYER']["editor"] = root.createEmptyMovieClip("editor", depth["editor"]);
	
	var dObj = {url:_global['TF']['HOST_URL'] + "typo3conf/ext/typoflash/pi1/editor8.swf",target:d,name:'TypoFlash Editor'}
	_global['TF']['LOAD_QUEUE'].load(dObj);

}

function unloadEditor(){
	_global['TF']['LAYER']["editor"].unloadMovie();
	_y = 0;
}

function toggleSound(){
	var o = {};
	o.type = "onSoundStatus";
	if (_global['TF']['COOKIE'].data["soundEnabled"] != false) {
		o.status = false;
	}else{
		o.status = true;
	}

	E.dispatchEvent(o);
}

function onSoundStatus(o){
	if (_global['TF']['COOKIE'].data["soundEnabled"] != false) {
		_global['TF']['COOKIE'].setData("soundEnabled",o.status)
		stopAllSounds();
		snd.caption = "» Turn on sounds";
	}else{
		_global['TF']['COOKIE'].setData("soundEnabled",1);
		snd.caption = "» Mute sounds";
	}
	
}

stop();

//listen to core events and update context menu accordingly
E.addEventListener("onBELoginStatus", this);
E.addEventListener("onDebugStatus", this);
E.addEventListener("onEditStatus", this);
E.addEventListener("onSoundStatus", this);

function onBELoginStatus(obj){
	if(obj["status"] == true){
		//true logged in
		setAuthContext();
	}else if(obj["status"] != "pending"){
		//still not sure
	//}else{
		setNonAuthContext()
		//turn off edit
		turnOffEdit()
		//turnOffDebug();
	
	}

}

function onDebugStatus(obj){
	if(obj["status"] == true){
		turnOnDebug();
	}else{
		turnOffDebug();
	}
}

function onEditStatus(obj){
	if(obj["status"] == true){
		editItem.caption = "» Turn off Edit mode";
		editItem.onSelect = turnOffEdit;
	}else{
		editItem.caption = "» Turn on Edit mode";
		editItem.onSelect = turnOnEdit;
	}
}

function logout(){
	_global['TF']['EDITOR'].logout();
}


delete Q,G;





