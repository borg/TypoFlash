/*
Class: Frame
Author: A. net.typoflash
Email: net.typoflash@elevated.to


Public events

onLoadStart
*target = the loading data, may be path or array
*frame = this


onLoadProgress
*target = loading object
*frame = this

onLoadComplete
*target = loading object
*frame = this
*/

import net.typoflash.managers.DepthManager;
import mx.events.EventDispatcher;
import net.typoflash.ui.Controls;
import mx.data.binding.ObjectDumper;
//import net.typoflash.managers.FrameManager;
import net.typoflash.typo3.pagecontrol.ContentRendering;
import net.typoflash.typo3.pagecontrol.ContentEditing;
//import mx.containers.ScrollPane;
import net.typoflash.managers.QueueLoader;
import flash.filters.BlurFilter;
import mx.transitions.Tween; 
import mx.transitions.easing.*;
import net.typoflash.managers.CoreEvents;

class net.typoflash.ui.windows.Frame  extends net.typoflash.typo3.typoflash.ComponentBase implements net.typoflash.typo3.typoflash.IComponentInterface{
	var menu:MovieClip;
	
	var holder,contentHolder,content,bg,editMenu:MovieClip;
	var loadListener:Object;
	//var scrollpane:ScrollPane;
	var _vScrollPolicy,_hScrollPolicy:String;
	var _contentPath:String;
	private var isDefaultFrame,showMenu:Boolean;
	var depth:Number = 1000000;
	var components:Array;
	
	var bId:String="Frame";

	/*
	showMenu
	backbtn
	deeplink
	printsend to friend
	email page
	translate
	default
	vScrollPolicy
	hScrollPolicy yes/no/auto
	transition fade/blur/none/
	*/
	function Frame (){
		//this._default = false;
		
		//CoreEvents.addEventListener("onBELoginStatus",this);//If conf dependent
		
		ContentEditing.addEventListener("onDeleteContent",this);

		CoreEvents.addEventListener("onComponentLoaded",this);
		
		holder.addEventListener("onLoad",this);
		loadListener = {};
		loadListener.frame = this;
		loadListener.onProgress = function(evt_obj:Object) {
			var o = {};
			o.type = "onLoadProgress";
			o.target = evt_obj;
			o.frame = this.frame;
			this.frame.dispatchEvent(o);
			var response = {type:"onQueueItemProgress",obj:evt_obj};
			CoreEvents.dispatchEvent(response);
			 //Controls.debugMsg(evt_obj.target.getBytesLoaded() + " of " + evt_obj.target.getBytesTotal() + " bytes loaded.");
		};
		loadListener.onComplete= function(evt_obj:Object) {
			var o = {};
			o.type = "onLoadComplete";
			o.target = evt_obj;
			o.frame = this.frame;
			this.frame.dispatchEvent(o);
		
			
		};
		
		components = [];
		transitionType = "fade";
		if(introDependent){
			introComplete = false;
		}

	}
	
	function init(){

		depth=1000000;
		this.bg._visible = false;
		var o = {};
		o.name = this._name;
		o.path = this;
		if(!showMenu){
			this.menu._visible = false;
		}
		
		ContentRendering.registerFrame(this);
		menu._alpha = 100;
		//this.editMenu._visible = false;
		setSize(orgW,orgH);
		setY(orgY);//this should send to frameBg, but it hasn't been added as listener yet..so it is ripping x and y when it does that...not ideal
		setX(orgX);
		holder.addEventListener("onComplete",loadListener);
		holder.addEventListener("onProgress",loadListener);

		/*//FrameManager.registerFrame(o);
		this.scrollpane = this.holder.createClassObject(ScrollPane, "contentHolder" ,0);
		//this.scrollpane = this.holder.attachMovie(ScrollPane, "scrollpane" + i,-i);
		this.setSize(this.orgW,this.orgH);
		
		this.scrollpane.setStyle("borderStyle", "solid");
		this.scrollpane.setStyle("borderColor ", 0xDFE4DE);
		this.scrollpane.contentPath = 'nullMC';*/
		//this.contentHolder = this.scrollpane.content;
		//ContentRendering.applyData(this);
		if(!introComplete){
			//_visible = false;
		}
		vScrollPolicy = _vScrollPolicy;	
		hScrollPolicy = _hScrollPolicy;	
		
	}

	function set vScrollPolicy(v){
		holder.vScrollPolicy = v;
	}

	function get vScrollPolicy(){
		return holder.vScrollPolicy;
	}


	function set hScrollPolicy(v){
		holder.hScrollPolicy = v;
	}

	function get hScrollPolicy(){
		return holder.hScrollPolicy;
	}	 
	function set transitionType(v){
		holder.transitionType = v;
	}

	function get transitionType(){
		return holder.transitionType;
	}	 
	 



	function refresh(){

		menu._visible = showMenu;
		sequentialXYresize(_x,_y,this.bg._width,this.bg._height);
		//Controls.debugMsg("Refreshing me " + this._name)
		/*var tx = new Tween(this, "setX", func,_x,x,t, true);
		var ty = new Tween(this, "setY", func,_y,y,t, true);
		var tw = new Tween(this, "setWidth", func,this.bg._width,width,t, true);
		var th = new Tween(this, "setHeight", func,this.bg._height,height,t, true);*/
		if(showMenu){
			var tm = new Tween(this, "setMenu", tweenFunc,this.holder._y,this.menu._height,tweenTime, true);
		}else{
			var tm = new Tween(this, "setMenu", tweenFunc,this.holder._y,0,tweenTime, true);			
		}
		//trace("refreshhh " + width + " h " + height)
		//setSize(width,height);
	}


	function setSize(w,h){
		height = h = Math.round(h);
		width= w = Math.round(w);
		if(showMenu){
			this.bg._height = h-this.menu._height;
			holder.setSize(w,h-this.menu._height)
			this.holder._y = this.bg._y =  this.menu._height;			
			
		}else{
			this.bg._height = h;
			holder.setSize(w,h)
			this.holder._y = this.bg._y = 0;			
		}
		this.bg._width = this.menu.bg._width = w;
		

		var o = {};
		o.type = "onResize";
		o.target = this;
		o.width = width;
		o.height = height;
		o.x = x;
		o.y = y;
		dispatchEvent(o);
		//trace("setSize w " + width + " h " + height)
	}	
	function set setWidth (w){
		width = w = Math.round(w);
		this.menu.bg._width = this.bg._width = w;
		holder.setSize(w,holder.height)
		var o = {};
		o.type = "onSetWidth";
		o.target = this;
		o.width = w;
		dispatchEvent(o);
		o = {};
		o.type = "onResize";
		o.target = this;
		o.width = width;
		o.height = height;
		o.x = x;
		o.y = y;
		dispatchEvent(o);
	}
	
	function set setHeight (h){
		h = Math.round(h)
		height = h;
		if(showMenu){
			this.bg._height= h-this.menu._height;
			holder.setSize(holder.width,h-this.menu._height)
		}else{
			this.bg._height= h;
			holder.setSize(holder.width,h)
		}
		var o = {};
		o.type = "onSetHeight";
		o.target = this;
		o.height = height;
		dispatchEvent(o);

		o.type = "onResize";
		o.width = width;
		o.height = height;
		o.x = x;
		o.y = y;
		dispatchEvent(o);
	}
	

	function set setMenu (h){
		this.holder._y = this.bg._y =  h;			
	}

	/*
	Returns an array of all configuration variables for this component that should be editable
	*/
	
	function getConfVars():Array{
		var l = net.typoflash.typo3.pagecontrol.LocalLang.global;
		var formElement = [];
		formElement.push({label:l.getLang("Frame_pid","Current page id"),name:"pid",value:ContentRendering.page.HEADER["uid"],type:"input",editable:false,tooltip:l.getLang("Frame_pid_tooltip","Current page")});
		formElement.push({label:l.getLang("Frame_name","Frame name"),name:"name",value:_name,type:"input",editable:false,tooltip:l.getLang("Frame_name_tooltip","Frame name to be used as target value for content")});
		formElement.push({label:l.getLang("Frame_showMenu","Show frame menu?"),name:"showMenu",value:showMenu,type:"checkbox",tooltip:l.getLang("Frame_showMenu_tooltip","Showmenu with frame options")});
		formElement.push({label:l.getLang("Frame_isDefaultFrame","Is default frame?"),name:"isDefaultFrame",value:isDefaultFrame,type:"checkbox",tooltip:l.getLang("Frame_isDefaultFrame_tooltip","If set any content without designated frame will be loaded in this frame.")});
		formElement.push({label:l.getLang("Frame_vScroll","Vertical scrollbar"),name:"vScrollPolicy",value:vScrollPolicy,type:"combo",tooltip:l.getLang("Frame_vScrollPolicy_tooltip","Vertical ScrollPolicy"),dataProvider : [{label:"auto", data :"auto"},{label:"yes", data :"yes"},{label:"no", data :"no"}]});
		formElement.push({label:l.getLang("Frame_hScroll","Horisontal scrollbar"),name:"hScrollPolicy",value:hScrollPolicy,type:"combo",tooltip:l.getLang("Frame_hScrollPolicy_tooltip","Horisontal ScrollPolicy"),dataProvider : [{label:"auto", data :"auto"},{label:"yes", data :"yes"},{label:"no", data :"no"}]});
		formElement.push({label:l.getLang("Frame_x","x position"),name:"x",value:x,type:"input",width:40,restrict:"0-9\\-",tooltip:l.getLang("Frame_x_tooltip","x position of frame")});
		formElement.push({label:l.getLang("Frame_y","y position"),name:"y",value:y,type:"input",width:40,restrict:"0-9\\-",tooltip:l.getLang("Frame_y_tooltip","y position of frame")});
		formElement.push({label:l.getLang("Frame_w","width"),name:"width",value:width,type:"input",width:40,restrict:"0-9\\-",tooltip:l.getLang("Frame_w_tooltip","Width of frame")});
		formElement.push({label:l.getLang("Frame_h","height"),name:"height",value:height,type:"input",width:40,restrict:"0-9\\-",tooltip:l.getLang("Frame_h_tooltip","Height of frame")});
		formElement.push({label:l.getLang("Frame_transitionType","Transition"),name:"transitionType",value:transitionType,type:"combo",tooltip:l.getLang("transitionType_tooltip",""),dataProvider : [{label:"fade", data : "fade"},{label:"none", data : "none"},{label: "blur", data : "blur"},{label: "burn", data : "burn"},{label: "tween", data : "tween"}]});
		return formElement;
	}


	
	function set contentPath(c){
		holder.contentPath = c;
		var o = {};
		o.type = "onLoadStart";
		o.frame = this;
		o.target = c;
		dispatchEvent(o);
		
	}
	
	function load(c){
		Controls.debugMsg(c)
		var iObj,mc;
		var arr = [];
		for (var i=0;i<c.length ;i++ ){
			iObj = parseComponentData(c[i]);
			if(_global.IS_LIVE==null){
				//this is left without host url since the idiots at Macromedia made it impossible to develop locallly and online at the same time. Make sure you have a local copy.
				arr.push({src:c[i].component.file,initObj:iObj,depth:iObj.depth})
			}else{
				arr.push({src:_global["HOST_URL"]+ c[i].path + c[i].component.file,initObj:iObj,depth:iObj.depth})
			}
		}
		
		holder.load(arr);
		var o = {};
		o.type = "onLoadStart";
		o.frame = this;
		o.target = c;
		dispatchEvent(o);
			
	}
	
	//function unloadOld(all){
		//for(var i = depth+20;i>(depth+1);i--){
			//remove old ones if someone has clicked too quickly
			//this.holder["content" + i].removeMovieClip();
		//}
			//var blur:BlurFilter = new BlurFilter(10, 10, 2);
		//var blur= new BlurFilter(10, 10, 2);
		/*var s = new Tween(blur, "blurX", Regular.easeOut,0,100,.2, true);
		s.blur = blur;*/
		//s.mc = this.holder["content"+(depth+1)];//only the penultimate
		// var mc = this.holder["content"+(depth+1)];//only the penultimate
		//s.frame = this;
		//var s = new Tween(mc, "_alpha", Regular.easeOut,mc._alpha,0,1, true);
		//trace("Blurring " + this.holder["content"+(depth+1)])
		/*s.onMotionChanged = function(){
			this.mc.filters = [this.blur];
		}
		s.onMotionFinished = function(){
			this.mc.removeMovieClip();
			
			var blur= new BlurFilter(10, 10, 2);
			var s = new Tween(blur, "blurX", Regular.easeIn,100,0,.2, true);
			s.blur = blur;
			s.mc = this.frame.content;
			this.frame.content._visible = true;
			s.frame = this;
			trace("Un blurring " + this.frame.content)
			s.onMotionChanged = function(){
				this.mc.filters = [this.blur];
			}
			s.onMotionFinished = function(){
				this.mc.filters = null;
			}
		}
		*/
		//if(all){
			//this.content.removeMovieClip();
		//}
	//}
	
	
	function onGetPage(ev){
		ContentRendering.applyData(this);
		/*
		errortype, errormsg, data
		*/
		//Check if content is meant for this frame,either as "page target" or "component path", or if this is default, take it
		//Page target is overriding component path if it is set.  Default only renders content if neither path nor target is set
		//var gotContent = false;
		components =[];
		for(var i=0;i<ev.data.CONTENT.length;i++){
			if(ev.data.CONTENT[i].target == this._name) {
				//Page target
				//this.load(ev.data.CONTENT[i]);
				components.push(ev.data.CONTENT[i]);
			}else if((ev.data.CONTENT[i].component.path == this._name)&& (ev.data.CONTENT[i].target == "")){
				//Component path
				//this.load(ev.data.CONTENT[i]);
				components.push(ev.data.CONTENT[i]);
			}else if((ev.data.CONTENT[i].target == "") && (ev.data.CONTENT[i].component.path=="") && isDefaultFrame ){
				//Default
				//this.load(ev.data.CONTENT[i]);
				components.push(ev.data.CONTENT[i]);
			}
		}
		if(components.length == 0){
			unload();

		}else{
			load(components);
		}
	
	}

	function unload(d){
		holder.contentPath ="";
		holder.unload(d);
		holder.holder._x = 0;
		holder.holder._y=0;
		holder.hScroll.scrollPosition = holder.totW;
		holder.vScroll.scrollPosition = 0;
		holder.refresh();
	}

	/*
	remove component from list if deleted
	*/
	function onDeleteContent(o){
		var c = [];
		for (var i=0;i<components.length ;i++ ){
			if(components.uid!=o.data.uid){
				c.push(components[i])
			}

		}
		components = c;
		Controls.debugMsg("Frame to delete content uid: "+o.data.uid);
		Controls.debugMsg(components);

	}
	/*
	The form needs to have both the meta data for a component and the component itself
	to furnish ContentEditingMenu with all properties. Meta data comes onGetPage but this
	function is called when component is actually loaded. This will add a reference key to the
	loaded movieclip which is used to obtain confVars.
	The meta data has already been transferred to the newly loaded component in the ComponentBase class.
	*/
	function onComponentLoaded(o){
		for (var i=0;i<components.length ;i++ ){
			if(components[i].uid == o.key.uid ){
				components[i].key = o.key;
			}
			
		}
	}


	function onTemplateIntroStart(o){
		//Controls.debugMsg("Just testing: " + this + " got onTemplateIntroStart")
		//net.typoflash.typo3.pagecontrol.ContentRendering.applyData(this);
	}

	function onSequentialXYresizeComplete(){
		if(!introComplete){
			introComplete = true;
			_visible = true;
		}
		//this event is broadcasted vie component base!!
	}
	
}