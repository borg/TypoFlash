/*
Class: Controls

Author: A. net.typoflash
Email: net.typoflash@elevated.to

Example usage:

Controls.alert(unescape(x.error._att["data"]));

Singleton

*/

package net.typoflash.ui{
	
	import flash.display.*;
	import net.typoflash.ui.windows.*;
	import net.typoflash.ui.DepthManager;
	import net.typoflash.ui.popups.*;
	import net.typoflash.utils.Global;
	import net.typoflash.events.ComponentEvent;

	public class Controls{
		
		private static var _instance = null;
		private static var global:Global = Global.getInstance();
		static var debug_mc:MovieClip;
		static var beLogin_mc:MovieClip;
		static var debug_count:Number;
		static var debug_history:String;
		public static var applicationTop:Number=0;
		public static var applicationLeft:Number=0;
		static var _applicationWidth:Number;
		static var _applicationHeight:Number;
		public static var fixedAppliactionDimensions:Boolean;

		public static var windowInFocus:Window;
		public static var oldWindowInFocus:Window;

		

		public  function Controls () {
			
			
			
		}
		
		
		
		
		

		// ===========================================================
		// - DEBUG
		// ===========================================================	
				
			
		public static function debugMsg(msg:*):void{
			if(typeof(msg)=="object"){
			///play with is
				subTrace(msg)
			}else{
				trace(msg)
			}

		}
		
		static function subTrace(o:Object,prefix:String=""):void{
			for(var n in o){
				if(typeof(o[n])=="object"){
					trace(prefix+ n +"{");
					subTrace(o[n], prefix+"\t")
					trace(prefix+ "}");
				}else{
					trace(prefix+ n +" : " + o[n])
				}
			}
		}
	
		public static function set applicationWidth(s:int){
			_applicationWidth=s;
			
		}

		public static function get applicationWidth():int{
			if(fixedAppliactionDimensions){
				return _applicationWidth;
			}else{
				var l = DepthManager.getLayer("windows");
				return l.stage.stageWidth;
			}
			
		}

		public static function set applicationHeight(s:int){
			_applicationWidth=s;
			
		}

		public static function get applicationHeight():int{
			if(fixedAppliactionDimensions){
				return _applicationHeight;
			}else{
				var l = DepthManager.getLayer("windows");
				return l.stage.stageHeight-Controls.applicationTop;

			}
			
		}



		public static function newWindow (w:Window){
			
			var l = DepthManager.getLayer("windows");
			
			
			global['OLD_FOCUS'] = global['FOCUS'];
			global['FOCUS'] = w;

	
			if(w.x == 0){
				w.x = DepthManager.getNextX()
			}
			if(w.y == 0){
				w.y = DepthManager.getNextY();
			}
			l.addChild(w);
			//w.init(totInitObj);
			w.addEventListener(ComponentEvent.ON_CLOSED,onWindowClosed);
			return w;
		}
		
		//palettes are used for application tools, where windows are working sheets or canvases etc
		public static function newPalette (totInitObj){
			
			var w = new Window();
			var l = DepthManager.getLayer("palettes");
			l.addChild(w);
			w.init(totInitObj);
			if(totInitObj.w != null){
				w.minW = Math.min(totInitObj.w,w.minW);
			}		
			if(totInitObj.h != null){
				w.minH = Math.min(totInitObj.h,w.minH);
			}			
			if(totInitObj.x != null){
				w.x = totInitObj.x;
			}else{
				w.x = DepthManager.getNextX()
			}
			if(totInitObj.y != null){
				w.x = totInitObj.x;
			}else{
				w.y = DepthManager.getNextY();
			}
			w.addEventListener(ComponentEvent.ON_CLOSED,onPaletteClosed);
			l.addChild(w);
			return w;
		}
		

		
		public static function newModalWindows (totInitObj){
			
			var w = new Window();
			var l = DepthManager.getLayer("modalWindows");
			//need to add DepthManager.createKillMouseLayer()
			if(totInitObj.w != null){
				w.minW = Math.min(totInitObj.w,w.minW);
			}		
			if(totInitObj.h != null){
				w.minH = Math.min(totInitObj.h,w.minH);
			}			
			l.addChild(w);
			w.init(totInitObj);
			oldWindowInFocus = windowInFocus;
			windowInFocus = w;
			if(totInitObj.x != null){
				w.x = totInitObj.x;
			}else{
				w.x = DepthManager.getNextX()
			}
			if(totInitObj.y != null){
				w.x = totInitObj.x;
			}else{
				w.y = DepthManager.getNextY();
			}

			return w;
		}

		public static function focusWindow (w:Window){
			var l = DepthManager.getLayer("windows");
			try{
				l.setChildIndex(w, l.numChildren-1);
			}
			catch(err){}

			oldWindowInFocus = windowInFocus;
			windowInFocus = w;
		}
		

		private static function onWindowClosed(e:ComponentEvent){
			windowInFocus = oldWindowInFocus;
		}

		private static function onPaletteClosed(e:ComponentEvent){
			
		}
		
		public static function alert(msg,acc=null){
			
			var a = new Alert(msg,acc);
			var l = DepthManager.getLayer("popups");
			//need to add DepthManager.createKillMouseLayer()
			l.addChild(a);
			//global['FOCUS'] = a;//
			a.x = DepthManager.getNextX()
			a.y = DepthManager.getNextY()
			return a;
		}
		public static function confirm(msg:String,acc:Function=null,decl:Function=null){
			
			var c = new Confirm(msg,acc,decl);
			var l = DepthManager.getLayer("popups");
			//need to add DepthManager.createKillMouseLayer()
			l.addChild(c);


			
			
			c.x = DepthManager.getNextX()
			c.y = DepthManager.getNextY()
			return c;
		}

	};

}