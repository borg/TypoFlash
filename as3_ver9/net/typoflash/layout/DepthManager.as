/*

Class: DepthManager

Author: A. net.typoflash
Email: borg@elevated.to



DepthManager.initialize(target);

Depthmanager manages popup windows created with Controls. It makes sure popups and windows and content is layered adequately. 
It doesn't manage all types of depth and there is no point to for instance make it control the location of a preloader in front
of a template, seeing sometimes a preloader is in front and sometimes behind.

You do need to send the target level within which the popups will be layered. That is the application mc. It theory there could be 
several applications within one bigger app as long as it had the necessary assets in the root of each application. Practically not so
interesting though.



*/
//import mx.managers.DepthManager;

package net.typoflash.layout{
	import flash.display.*;
	import flash.events.MouseEvent;

	public class DepthManager{
		
		
			
		//counter for popup chat wins and alerts
		private static var _instance:DepthManager = null;
		private static var allowInstantiation:Boolean;

		static var appRoot:*;
		static var currDepth:int = 10;
		static var currPopX:int;
		static var currPos:int = 0;
		static var currPopY:int = 0;
		static var yCount:int = 0;
		static var _orgX:int = 0;
		static var depth:Array;
		static var mouse_capture_mc:Sprite,windows_mc:Sprite,popup_mc:Sprite,modal_windows_mc:Sprite,edit_mc:Sprite;
		
		public function DepthManager(){
			/*
			if (!allowInstantiation) {
				throw new Error("Error: Instantiation failed: Use DepthManager.instance instead of new.");
			}
			
			DEPTH LAYERING
			Defaults
			*/
			depth = ["assets","bg","preloader","template","historyController","editMenu","windows","palettes","mouseCapture","modalWindows","popups","tooltips"];

		}
		
		public static function init(ar:*):void{
			DepthManager.instance;
			DepthManager.appRoot = ar;

			currPopX = (DepthManager.appRoot.stage.stageWidth/2)-100;
			
			currPopY = 100;
			var s;
			for(var i=0;i<depth.length;i++){
				s = new Sprite();
				s.name = depth[i];
				DepthManager.appRoot.addChild(s);
			}
		
		}
		

		public static function getNextDepth():int{
			currDepth++;
			return currDepth;
		}
		
		public static function getNextX():int{
			var x= currPopX + currPos*10;
			if(x>((appRoot.stage.stageWidth/2)+100)){
				//reset
				currPopX = (DepthManager.appRoot.stage.stageWidth/2)-100;
			}

			return Math.round(x);
		}
		
		public static function getLayer(id:String):DisplayObject{
			DepthManager.instance;
			return DepthManager.appRoot.getChildByName(id);
		
		}
		public static function getNextY ():int{
			var y = currPopY + currPos*10 + 10*yCount;
			if(y>(appRoot.stage.stageHeight/2)){
				//reset
				currPopY = 100;
				yCount++;
				if(yCount>10){
					yCount = 0;
				}
			}
			currPos++;
			return Math.round(y);
		}
		
		public static function set orgX(v){
			
			_orgX = v;
		}
		

		public static function createKillMouseLayer():Shape{
			var k:Shape = new Shape();
			k.graphics.beginFill (0x00FFFF,0);
			k.graphics.lineStyle (0, 0xFF00FF, 0);
			k.graphics.moveTo (0, 0);
			k.graphics.lineTo (DepthManager.appRoot.stage.stageWidth, 0);
			k.graphics.lineTo (DepthManager.appRoot.stage.stageWidth, DepthManager.appRoot.stage.stageHeight);
			k.graphics.lineTo (0, DepthManager.appRoot.stage.stageHeight);
			k.graphics.endFill();
			
			k.addEventListener(MouseEvent.CLICK, DepthManager.mouseOverHandler);
			var m = DepthManager.appRoot.getChildByName("mouseCapture");
			m.addChild(k);
			return k;
		
		}

		public static function mouseOverHandler(){
			trace("killmouseS");//doesnt work
		}
		public static function removeKillMouseLayer():void{
			var m = DepthManager.appRoot.getChildByName("mouseCapture");
			m.removeChildAt(0);
		
		
		}
	// ===========================================================
	// - GET SINGLETON INSTANCE
	// ===========================================================
	     public static function get instance():DepthManager {

		if (_instance == null) {
			//allowInstantiation = true;
			_instance = new DepthManager();
			///allowInstantiation = false;
		     
		 }
		 return _instance;
	     }	

	}

}