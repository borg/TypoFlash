
/*
*****************************

******************************
Andreas net.typoflash
(C) Elevated Ltd
2007
******************************

******************************/
package net.typoflash.ui.windows{


	import flash.display.*;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import net.typoflash.ui.DepthManager;
	import net.typoflash.ui.Controls;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import fl.controls.Button;
	import fl.controls.TextArea;
	import flash.events.MouseEvent;	
	import flash.geom.Rectangle;
	import fl.containers.ScrollPane;
	import fl.controls.TextArea;
	import fl.controls.DataGrid;
	import fl.controls.TileList;
	import flash.utils.*;
	import net.typoflash.events.ComponentEvent;

	public class Window  extends Sprite{
		
		public static const TYPE_SCROLLPANE:String = "ScrollPane";
		public static const TYPE_TEXTAREA:String = "TextArea";
		
		//For TextArea
		public var text:String;
		
		//For scrollpane
		public var view:*;
		private var _source:*;
		
		
		private var _title:String;
		public var resizeEnabled:Boolean = true;
		public var minimiseEnabled:Boolean = true;
		public var maximiseEnabled:Boolean = true;
		public var isMinimised:Boolean = false;
		public var isMaximised:Boolean = false;
		
		public var closeEnabled:Boolean;

		public var hScrollPolicy:String="auto";
		public var vScrollPolicy:String="auto";

		public var minW:Number = 34;
		public var minH:Number = 80;		
		
		//Content properties
		private var _type:String = '';//ScrollPane/TextArea/MovieClip/SWF - what does it contain? 
		
		var containerInitObj:Object;//Properties to be passes to ScrollPane or TextArea
		
		var initObj:Object={};//Properties to be sent to final destination
		
	
		private var _width:Number; 
		private var _height:Number;
		private var scrollDrag;
		private var shadowOldH;


		
		private var oldW:Number;//prior to maximise
		private var oldH:Number;//prior to minimise
		private var oldX:Number;//prior to minimise
		private var oldY:Number;//prior to minimise

		public var doubleClickDelay:int=300;//millisec
		private var doubleClickTimer:int=0;

		public function Window(){
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init(e:Event){


			
			title_txt.mouseEnabled = false;
			title_txt.autoSize= TextFieldAutoSize.LEFT;
			stage.addEventListener(Event.RESIZE, resizeStage);
			bg.addEventListener(MouseEvent.MOUSE_DOWN, startDragWindow);
			bg.addEventListener(MouseEvent.MOUSE_UP, stopDragWindow);

			bg.mouseChildren = false;//??????how to disable shadow
			titleBg.addEventListener(MouseEvent.MOUSE_DOWN, startDragWindow);
			titleBg.addEventListener(MouseEvent.MOUSE_UP, stopDragWindow);
			addEventListener(MouseEvent.MOUSE_UP, stopDragWindow);
			

			

			if(resizeEnabled){
				resizeBtn.addEventListener(MouseEvent.MOUSE_DOWN, startResizeWindow);
				resizeBtn.addEventListener(MouseEvent.MOUSE_UP, stopResizeWindow);



			}else{
				resizeBtn.visible = false;
			}

			
/*
			if(closeEnabled){
				closeBtn.x = titleBg.width - 16;
			}
			if(!closeEnabled){
				cascadeBtn.x = titleBg.width - 16;
			}else{
				cascadeBtn.x = titleBg.width - 30;
			}
			if(!closeEnabled){
				minimiseBtn.x = titleBg.width - 16;
			}else if(!maximiseEnabled){
				minimiseBtn.x = titleBg.width - 30;
			}else{
				minimiseBtn.x = titleBg.width - 44;
			}

*/


			if(closeEnabled){
				closeBtn.gotoAndStop("close");
				
				closeBtn.addEventListener(MouseEvent.CLICK, onCloseBtn);
				
			}else{
				closeBtn.visible = false;
			}
			
			/*titleBg.onRollOut = function() {
				if (this._xmouse>this._x && this._xmouse<this._x+this._width && this._ymouse>this._y && this._ymouse<this._y+this._height) {
					this.gotoAndStop("_over");
				}
			};*/		

			if(maximiseEnabled){
				if(!closeEnabled){
					cascadeBtn.x = closeBtn.x;
				}
				//cascadeBtn.gotoAndStop("cascade");
				cascadeBtn.gotoAndStop("maximise");	
				cascadeBtn.visible = true;
				cascadeBtn.addEventListener(MouseEvent.CLICK, onToggleMaximise);
				//titleBg.addEventListener(MouseEvent.DOUBLE_CLICK, onToggleMaximise);//the inbuilt one is crap
				titleBg.addEventListener(MouseEvent.MOUSE_DOWN, dblClkListener);
				titleBg.doubleClickEnabled = true;
				
			}else{
				
				cascadeBtn.visible = false;
			}


			if(minimiseEnabled){
				
				if(!maximiseEnabled){
					minimiseBtn.x = cascadeBtn.x;
				}
				
				if(!closeEnabled){
					minimiseBtn.x = closeBtn.x;
				}
				//cascadeBtn.gotoAndStop("cascade");
				minimiseBtn.gotoAndStop("minimise");	
				minimiseBtn.visible = true;
				minimiseBtn.addEventListener(MouseEvent.CLICK, onToggleMinimise);
				
			}else{
				
				minimiseBtn.visible = false;
			}
			
			
				
			




			if(type != Window.TYPE_SCROLLPANE){
				setSize(_width, _height)
			}
		}
		

		function startDragWindow(e:MouseEvent){
			Controls.focusWindow(this);
			startDrag(false, new Rectangle( -380, -400, 1500, 800));
		}
		
		function stopDragWindow(e:MouseEvent){
			stopDrag();
		}

		function startResizeWindow(e:MouseEvent){
			e.target.startDrag(false, new Rectangle( 100, 70, 700,800));
			addEventListener(Event.ENTER_FRAME , entreframeDragResize);
			setSize(e.target.x,e.target.y);
		}

		function stopResizeWindow(e:MouseEvent){
			e.target.stopDrag();
			removeEventListener(Event.ENTER_FRAME , entreframeDragResize);
			setSize(e.target.x,e.target.y);

		}
		function dblClkListener(e:MouseEvent){

			if((getTimer() - doubleClickTimer)<doubleClickDelay){
				toggleMaximise();
			}
			doubleClickTimer = getTimer();
			
		}

		function entreframeDragResize(e:Event){
			setSize(resizeBtn.x,resizeBtn.y);
		}

		function close () {
			dispatchEvent(new ComponentEvent(ComponentEvent.ON_CLOSED,this));
			parent.removeChild(this);
			try{
				view.content.closedByContainer()
			}
			catch(err){
			
			}
		};
		
		function onCloseBtn(e:MouseEvent){
			close();
		}
		
		function onChildClose(e:ComponentEvent){
			close();
		}

		function onToggleMaximise(e:MouseEvent){
			toggleMaximise();
			
		}

		function onToggleMinimise(e:MouseEvent){
			toggleMinimise();
		}

		public function setSize(w, h) {
			if(w<minW){
				 w=minW;
			}
			 if(h<minH){
				h=minH;
			 }
			
			title_txt.x = Math.round(w/2-title_txt.width/2);
			 //needs something to adjust too wide text
			titleBg.width = bg.width = w;
			shadow.width = w+30*bg.scaleX;
			resizeBtn.x = w;

			if(closeEnabled){
				closeBtn.x = titleBg.width - 16;
			}
			if(!closeEnabled){
				cascadeBtn.x = titleBg.width - 16;
			}else{
				cascadeBtn.x = titleBg.width - 30;
			}
			if(!closeEnabled){
				minimiseBtn.x = titleBg.width - 16;
			}else if(!maximiseEnabled){
				minimiseBtn.x = titleBg.width - 30;
			}else{
				minimiseBtn.x = titleBg.width - 44;
			}

			
			shadow.height = h+30*bg.scaleY/1.3;
			bg.height = h;
			resizeBtn.y = h;
			try{
				view.setSize(w-12,h-40);//scrollpane
			}
			catch (e:Error){
				//trace(e);
			}
			try{
				view.content.setSize(w-12,h-40);
			}
			catch (e:Error){
				//trace(e);
			}
			


		};
		function setText(msg){
			
			
		}
		
		function addText(msg){
			
			
		}
		
		function move(xn,yn){
			x =xn
			y=yn
				
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
				view.visible = true;
				resizeBtn.visible = resizeEnabled;
				bg.visible = true;
				shadow.height = shadowOldH;
			}else{
				minimiseBtn.gotoAndStop("cascade");	
				shadowOldH = shadow.height;
				shadow.height = 20;
				view.visible = false;
				resizeBtn.visible = false;
				bg.visible = false;
				
			}
			isMinimised = !isMinimised; 			
		}


		function toggleMaximise(){
				
			if(isMinimised){
				toggleMinimise();
			}

			if(!isMaximised){
				cascadeBtn.gotoAndStop("cascade");
				oldW = bg.width;
				oldH = bg.height;
				oldX = x;
				oldY = y;
				setSize(Controls.applicationWidth, Controls.applicationHeight);
				move(Controls.applicationLeft,Controls.applicationTop);
				//resizeBtn._visible = false;
			}else{
				cascadeBtn.gotoAndStop("maximise");	

				setSize(oldW, oldH);
				move(oldX,oldY);
				resizeBtn.visible = resizeEnabled;
			}
			isMaximised = !isMaximised; 
			stopDrag();



		}


		function focus(){
			
		}
		function blur(){
			
		}
		function resizeStage(event:Event):void{
			if(isMaximised){
				setSize(Controls.applicationWidth, Controls.applicationHeight);
				move(Controls.applicationLeft,Controls.applicationTop);
				//resizeBtn._visible = false;
			}
		}


		function progressHandler(event:ProgressEvent):void {
		    /*var bLoaded:int = int(event.bytesLoaded / conversion);
		    var bTotal:int = int(event.bytesTotal / conversion);
		    var pctLoaded:int = event.target.percentLoaded as int;
		    myLabel.text = bLoaded + " of " + bTotal + " (" + pctLoaded + "%)";*/
		}

		function completeHandler(event:Event):void {
		   trace("done complete loading window scrollpane")
		    
		    view.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
		    view.removeEventListener(Event.COMPLETE, completeHandler);

		   /* if(view.content.init != null){
			    view.content.init(initObj);
		    }*/

		    //removeChild(myLabel);

		    /*view.setSize(img.width, img.height);
		    var newX:uint = (stage.stageWidth - myScrollPane.width) / 2;
		    var newY:uint = (stage.stageHeight - myScrollPane.height) / 2;
		    myScrollPane.move(newX, newY);
		    addChild(myScrollPane);*/
		}
		
		public function get title():String { return _title; }
		
		public function set title(value:String):void {
			title_txt.text = value;
			_title = value;
		}
		
		override public function get width():Number { return _width; }
		
		override public function set width(value:Number):void {
			_width = int(Math.min(value, minW));
			setSize(_width, _height);
		}
		
		override public function get height():Number { return _height; }
		
		override public function set height(value:Number):void {
			_height = int(Math.min(value, minH));
			setSize(_width, _height);
		}
		
		public function get type():String { return _type; }
		
		public function set type(value:String):void{
			if(value==Window.TYPE_SCROLLPANE){
				//pass a class from library or a symbol string
				view = new ScrollPane();
				
				view.verticalScrollPolicy = vScrollPolicy;
				view.horizontalScrollPolicy = hScrollPolicy;
				view.addEventListener(ProgressEvent.PROGRESS, progressHandler);
				view.addEventListener(Event.COMPLETE, completeHandler);
				if(_source){
					view.source = _source;
				}
				//swap
				//removeEventListener(Event.ADDED_TO_STAGE, init);
				//view.addEventListener(Event.ADDED_TO_STAGE, init);
				//view.content.addEventListener(ComponentEvent.ON_CLOSED,onChildClose);
				content.addChild(view);
				//setSize(_width, _height);
				//view.update()
			}
			_type = value;
		}
		
		public function get source():* { return _source; }
		
		public function set source(value:*):void {
			_source = value;
			if (view is ScrollPane) {
				view.source = _source;
				
			}
		}


	};
}