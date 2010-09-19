/*
*****************************

******************************
Andreas Borg
(C) Elevated Ltd
2005
******************************
In globals.as
import borg.managers.DepthManager;
depth = {};
depth["bg"] = 0;
depth["main"] = 1;
depth["menu"] = 6;
depth["preloadBar"] = 5;
depth["historyController"] = 20;
depth["content"] = 2;
depth["subcontent"] = 10;
depth["topInterface"] =15;
depth["windows"] = 50;//required by controls
depth["mouseCapture"] = 100;//required by controls
depth["popups"] = 103;//required by controls

DepthManager.initialize(depth);



Usage:
import borg.userinterface.Controls;

//ScrolPane
var containerInitObj = {contentPath:"ChatWin", vScrollPolicy:"auto",hScrollPolicy:"auto"}
channels[channel] = Controls.newWindow({title:"ScrollPane",type:"ScrollPane", w:400,h:200, resizeEnabled:true,closeEnabled:true,minimiseEnabled:true, containerInitObj:containerInitObj, initObj:{channel:channel}})
Note: Attached Movieclip needs an init func. Not tested with loadMovie yet

//Textarea
var t="Setting a property of the TextArea class with ActionScript overrides the parameter of the same name set in the Property inspector or Component inspector.The TextArea component overrides the default Flash Player focus rectangle and draws a custom focus rectangle with rounded corners.he TextArea component supports CSS styles and any additional HTML styles supported by Flash Player. ach component class has a version property, which is a class property. Class properties are available only on the class itself. The version property returns a string that indicates the version of the component. To access this property, use the following code";
var containerInitObj = {vScrollPolicy:"auto",hScrollPolicy:"off",wordWrap:true,text:t}	
channels[channel] = Controls.newWindow({title:"Textarea",type:"TextArea",w:300,h:300, resizeEnabled:true,closeEnabled:true,minimiseEnabled:true, containerInitObj:containerInitObj})

//Movieclip
channels[channel] = Controls.newWindow({title:"CHAT",contentPath:"ChatWin",type:"MovieClip", w:400,h:300, resizeEnabled:true,closeEnabled:true,minimiseEnabled:true, initObj:{channel:channel}})


NOTE:
This class needs to be extended with fancy functions like TweenScaleTo, and TweenCentreTo

******************************/

import mx.events.EventDispatcher;
import net.typoflash.utils.Debug;
import mx.data.binding.ObjectDumper;
//import mx.managers.DepthManager;
import net.typoflash.userinterface.components.bTextArea;

class DebugWindow  extends MovieClip{
	var closeBtn:MovieClip;
	var cascadeBtn:MovieClip;
	var minimiseBtn:MovieClip;
	var titleBg:MovieClip;
	var bg:MovieClip;
	var resizeBtn:MovieClip;
	var title_txt:TextField;
	var shadow:MovieClip;
	var text;
	var view:bTextArea;
	var resizeEnabled:Boolean = true;
	var minimiseEnabled:Boolean = true;
	var maximiseEnabled:Boolean = true;
	var isMinimised:Boolean;
	var isMaximised:Boolean;
	
	var closeEnabled:Boolean = true;
	public var debugMsg:Function;
	//Content properties
	var type:String;//ScrollPane/TextArea/MovieClip/SWF - what does it contain? 
	var containerInitObj:Object;//Properties to be passes to ScrollPane or TextArea
	
	var initObj:Object;//Properties to be sent to final destination
	
	
	var count, title, contentPath,w,h,addEventListener,content,hScrollPolicy,vScrollPolicy,scrollDrag,shadowOldH;
	var minW:Number = 140;
	var minH:Number = 80;	


	
	var oldW:Number;//prior to maximise
	var oldH:Number;//prior to minimise
	var oldX:Number;//prior to minimise
	var oldY:Number;//prior to minimise

	function DebugWindow(){
		System.security.allowDomain("*");
		System.exactSettings = false;
	}
	
	function onLoad(){
		_global['TF']['DEBUG_WINDOW'] = this;
		//Stage.scaleMode = 'noScale';
		//Stage.align = 'TL';
		EventDispatcher.initialize(this);
		
		title ="DEBUG";

		var stageLister = {};
		stageLister.root = this;
		stageLister.onResize = function(){
			this.root.onStageResize();//now exposed to all components
		}
		Stage.addListener(stageLister)
				
		
		bg.onPress = function() {
			
			this._parent.startDrag(false, -380, -400, 1500, 800);
	
		};
		titleBg.onPress = function() {
			
			if((getTimer() - this.doubleClickTimer)<130){
				_parent.toggleMaximise();
			}else{
				_parent.bg.onPress();
			}
	
		}
		titleBg.onRelease = function() {
			this.doubleClickTimer = getTimer();
			stopDrag();
			//checkIfWithinBounds();
		}

		var mt = {};
		Mouse.addListener(mt);
		mt.onMouseUp = bg.onRelease = titleBg.onReleaseOutside=function () { 
			stopDrag();
		};
		/*this.bg.onRelease = function(){
			//by clicking on bg you can focus window
			this._parent.swapDepths(getNextDepth());
		}*/
		bg.useHandCursor = false;
		
		titleBg.onRollOver =  function() {
			//this could be a preference
			//this._parent.swapDepths(getNextDepth());
		};
		
		if(resizeEnabled){
			resizeBtn.onPress = function() {
				if(isMaximised){
					this._parent.isMaximised = false
					this._parent.cascadeBtn.gotoAndStop("maximise");
				}
				this.startDrag(false);
				this.updateAfterEvent()
				this.onEnterFrame = function() {
					
					this._parent.setSize(this._x,this._y);
					//this._parent.publicBroadcaster.broadcastMessage("setSize", this._x,this._y)
					//var o = {type:"setSize", w: this._x, h:this._y};
					//this._parent.dispatchEvent(o);
				};
			};
			resizeBtn.onRelease = resizeBtn.onReleaseOutside = function(){
				stopDrag();
				this._parent.setSize(this._x,this._y);
				//this._parent.publicBroadcaster.broadcastMessage("setSize", this._x,this._y)
				this.onEnterFrame=null;
			}
		}else{
			resizeBtn._visible = false;
		}
		

		if(closeEnabled){
			closeBtn.gotoAndStop("close");
		
			closeBtn.onRelease = function(){
				this._parent.close();
			}
		}else{
			closeBtn._visible = false;
		}
		
		titleBg.onRollOut = function() {
			if (this._xmouse>this._x && this._xmouse<this._x+this._width && this._ymouse>this._y && this._ymouse<this._y+this._height) {
				this.gotoAndStop("_over");
			}
		};		

		if(maximiseEnabled){
			if(!closeEnabled){
				cascadeBtn._x = closeBtn._x;
			}
			//cascadeBtn.gotoAndStop("cascade");
			cascadeBtn.gotoAndStop("maximise");	
			cascadeBtn._visible = true;
			cascadeBtn.onRelease = function(){
				this._parent.toggleMaximise();
			}
		}else{
			
			cascadeBtn._visible = false;
		}


		if(minimiseEnabled){
			
			if(!maximiseEnabled){
				minimiseBtn._x = cascadeBtn._x;
			}
			
			if(!closeEnabled){
				minimiseBtn._x = closeBtn._x;
			}
			//cascadeBtn.gotoAndStop("cascade");
			minimiseBtn.gotoAndStop("minimise");	
			minimiseBtn._visible = true;
			minimiseBtn.onRelease = function(){
				this._parent.toggleMinimise();
			}
		}else{
			
			minimiseBtn._visible = false;
		}
		
		
		
		count = 1;
		/*this.txt.onSetFocus = function() {
			this.dragMC.gotoAndStop("_over");
		};*/
		
		title_txt.autoSize="left";
		title_txt.text = title;
		title_txt._x = Math.round(bg._width/2-title_txt._width/2);
	
		//view.window = this;
		//this.initObj.debugMsg()
		w = 300;
		h=200;
		if(w!=null && h != null){
			//debugMsg("got w: " + w)
			//publicBroadcaster.broadcastMessage("setSize", w,h)
			setSize(w,h)
		}
		
		addText("Happy debugging!")

		view.addEventListener("change",this);
	}
	
	function change(o){
		setSize(w,h);
	}
	
	function close () {
		//view.close();
		//this in effect unloads the debugwindow in the core8...
		var o = {};
		o.type = "onDebugStatus";
		o.status = false;
		_global['TF']['CORE_EVENTS'].dispatchEvent(o);

		//....but these are added in case used in other context
		_global['TF']['COOKIE'].setData("debugEnabled",0);
		this.removeMovieClip();
	};
	
	 function setSize(w0, h0) {
		 if(w0<minW){
			 w=minW;
		}else{
			w = w0;
		}
		 if(h0<minH){
			h=minH;
		 }else{
			h = h0;
		 }
		
		title_txt._x = Math.round(w/2-title_txt._width/2);
		 //needs something to adjust too wide text
		titleBg._width = bg._width = w;
		shadow._width = w+30*bg._xscale/100;
		resizeBtn._x = w;

		if(closeEnabled){
			closeBtn._x = titleBg._width - 16;
		}
		if(!closeEnabled){
			cascadeBtn._x = titleBg._width - 16;
		}else{
			cascadeBtn._x = titleBg._width - 30;
		}
		if(!closeEnabled){
			minimiseBtn._x = titleBg._width - 16;
		}else if(!maximiseEnabled){
			minimiseBtn._x = titleBg._width - 30;
		}else{
			minimiseBtn._x = titleBg._width - 44;
		}
		//

		view.setSize(w-12,h-40);
		if(isMinimised){
			shadow._height = 20;
		}else{
			shadow._height = h+30*bg._yscale/130;
		}
		bg._height = h;
		resizeBtn._y = h;
		//trace("Window is resizing and view is " + view)


	};
	function setText(msg){
		view.text = msg;
		//view.refresh()
		
	}
	
	function addText(htmlMsg,plainMsg){
		view.text =view.text+ htmlMsg;
		//view.refresh()
		view.txt.scroll = view.txt.maxscroll;
		
	}
	
	function move(x,y){
		_x = x;
		_y = y;
			
	}
	
	function onFocus(){
		//function to make titlebar flash if not in focus
		
	}
	function toggleMinimise(){
		if(isMaximised){
			toggleMaximise();
		}
		if(isMinimised){
			minimiseBtn.gotoAndStop("minimise");	
			view._visible = true;
			resizeBtn._visible = resizeEnabled;
			bg._visible = true;
			shadow._height = shadowOldH;
		}else{
			minimiseBtn.gotoAndStop("cascade");	
			shadowOldH = shadow._height;
			shadow._height = 20;
			view._visible = false;
			resizeBtn._visible = false;
			bg._visible = false;
			
		}
		isMinimised = !isMinimised; 
	}


	function toggleMaximise(){
		if(isMinimised){
			toggleMinimise();
		}

		if(!isMaximised){
			cascadeBtn.gotoAndStop("cascade");
			oldW = bg._width;
			oldH = bg._height;
			oldX = _x;
			oldY = _y;
			setSize(getIfSet(_global['TF']['CONF']['APPLICATION_WIDTH'],Stage.width), getIfSet(_global['TF']['CONF']['APPLICATION_HEIGHT'],Stage.height));
			move(getIfSet(_global['TF']['CONF']['APPLICATION_LEFT'],0),getIfSet(_global['TF']['CONF']['APPLICATION_TOP'],0));
			//resizeBtn._visible = false;
		}else{
			cascadeBtn.gotoAndStop("maximise");	

			setSize(oldW, oldH);
			move(oldX,oldY);
			resizeBtn._visible = resizeEnabled;
		}
		isMaximised = !isMaximised; 


	}


	function focus(){
	}
	function blur(){
		this.swapDepths(1);//AS1
	}
	function onStageResize(){
		if(isMaximised){
			//adjust to new size by quickly redo it
			toggleMaximise();
			toggleMaximise();
		}
	}


	function getIfSet(x,y){
		if(!(Number(x)>0)){
			return y;
		}else{
			return Number(x);
		}
	}
};