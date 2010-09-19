package net.typoflash.templates.frames {

	import flash.display.Sprite;
	import net.typoflash.base.FrameBase;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import net.typoflash.events.RenderingEvent;
	import net.typoflash.transitions.ITransition;
	import net.typoflash.utils.Debug;
	import flash.events.ProgressEvent;
	import net.typoflash.events.CoreEvent;
	import net.typoflash.events.RenderingEvent;	
	import gs.*;
	import gs.plugins.*;
	
	import net.typoflash.transitions.Pixelation;
	/**
	 * A basic frame can either be a simple sprite that loads content in a stack.
	 * It can be masked and/or scale content to fit a specific size.
	 * Between the old and new content there can be a transition of choice, a fade in,
	 * pixelation or whatever. 
	 * ...
	 * @author A. Borg
	 */
	public class TFBasicFrame extends FrameBase{
		public var holder:Sprite;
		private var _scaleMode:String = StageScaleMode.NO_SCALE;
		
		public static const RESIZE_NONE:String = "resizeNone";
		public static const RESIZE_HORISONTALLY:String = "horisontal";
		public static const RESIZE_VERTICALLY:String = "vertical";
		public static const RESIZE_BOTH:String = "both";
		private var _resizeToFitContent:String = TFBasicFrame.RESIZE_NONE;
		
		private var _masked:Boolean;
		public var maskLayer:Sprite;
		
		private var _w:int=400;
		private var _h:int=300;
		private var _waitCount:uint=0;
		private var _waitMax:uint=5;
		
		public function TFBasicFrame(){
			holder = new Sprite();
			addChild(holder);
		}
		
		override public function render(c:Sprite) {
			/*
			
			var mySprite:Sprite = new Sprite();
			var bData:BitmapData = new BitmapData(mySprite.width, mySprite.height, true);
		    bData.draw(mySprite);
			var bmap:Bitmap = new Bitmap(bData); */
			newSprite = c;
			if (!(newSprite.width > 0)) {
				addEventListener(Event.ENTER_FRAME, waitForContent, false, 0, true);
				return;
			}
			
			
			if (oldSprite == null) {
				oldSprite = new Sprite();
				oldSprite.graphics.beginFill (0xFFFF00,0);
				oldSprite.graphics.lineStyle (0, 0xFF00FF, 0);
				oldSprite.graphics.moveTo (0, 0);
				oldSprite.graphics.lineTo (newSprite.width, 0);
				oldSprite.graphics.lineTo (newSprite.width, newSprite.height);
				oldSprite.graphics.lineTo (0, newSprite.height);
				oldSprite.graphics.endFill();
				oldSprite.useHandCursor = false;		
				holder.addChild(oldSprite);
				Debug.output("Oldsprite null so adding fake one.")
			}
			oldSprite.cacheAsBitmap = true;
			oldSprite.mouseEnabled = false;
			oldSprite.mouseChildren = false;
			try {
				oldSprite.removeEventListener(RenderingEvent.ON_RESIZE, onChildResize);
			}
			catch (e:Error){}
			//if transition, move old and new sprite into it and add it as it is a sprite
			if (Transition is Class) {
				transition = new Transition(oldSprite, newSprite);
				transition.inProperties = transitionInProperties;
				transition.outProperties = transitionOutProperties;
				transition.duration = transitionDuration;
				Sprite(transition).addEventListener(RenderingEvent.ON_TRANSITION_COMPLETE, onTransitionComplete);
				if(transition.newSpriteInFront){
					holder.addChild(newSprite);	
				}else {
					holder.addChildAt(newSprite, 0);	
				}
				transition.startTransition(); 
				dispatchEvent(new RenderingEvent(RenderingEvent.ON_TRANSITION_BEGIN));
				
			}else {
				//if no transition
				onTransitionComplete();
			}
			//transition = new Pixelation(oldSprite, newSprite);
			//Sprite(transition).addEventListener(Pixelation.PIXEL_TRANSITION_COMPLETE, onTransitionComplete);
			//transition.properties ={duration:Pixelation.PIXELATION_FAST};// SLOWEST, SLOW, MEDIUM, FAST & FASTEST;
			
			


			

		}	
		/*
		 * Wait to see if newSprite gets a width in the next 5 frames else nothing much to animate, better
		 * slab it on.
		 */ 
		protected function waitForContent(e:Event) {
			if (_waitCount < _waitMax) {
				if (newSprite.width > 0) {
					removeEventListener(Event.ENTER_FRAME, waitForContent);
					render(newSprite);
					_waitCount = 0;
				}
			}else {
				removeEventListener(Event.ENTER_FRAME, waitForContent);
				newSprite.visible = true;
				holder.addChildAt(newSprite, 0);
				try{
					holder.removeChild(oldSprite);
					oldSprite["unloadAndStop"]()
				}
				catch (e:Error){}
				oldSprite = newSprite;	
			}
			
			_waitCount++;
			
			
		}
		
		protected function onTransitionComplete(e:RenderingEvent=null) {
			if(transition){
				transition.destroy();
				try{
				holder.removeChild(oldSprite);
				}
				catch (e:Error){
					Debug.output("onTransitionComplete could not remove old sprite")
				}
				transition = null;
			}else{
				newSprite.visible = true;
				holder.addChildAt(newSprite, 0);
			}

			
			newSprite.addEventListener(RenderingEvent.ON_RESIZE, onChildResize, false, 0, true);
			oldSprite = newSprite;		
			
			try{
				//oldSprite.loaderInfo.loader.unload();	
			}
			catch (e:Error)
			{
				
			}
			dispatchEvent(new RenderingEvent(RenderingEvent.ON_TRANSITION_COMPLETE));
		}
		
		
		protected function onChildResize(e:RenderingEvent) {
			switch (_resizeToFitContent) {
					case TFBasicFrame.RESIZE_HORISONTALLY:
						TweenLite.to(this, 1, {width:newSprite.width});
					break;
					case TFBasicFrame.RESIZE_VERTICALLY:
						TweenLite.to(this, 1, {height:newSprite.height});
					break;
					case TFBasicFrame.RESIZE_BOTH:
						//TweenLite.to(this, 1, {height:newSprite.height});
					break;			
				}
		}
		override public function unload() {
			var v = holder.numChildren;
			while (v--) {
				holder.removeChildAt(v);
			}
		}
		override public function get height():Number {

			return _h;
		}
		override public function get width():Number {
			
			return _w;
		}
		override public function set height(v:Number):void {
			_h = v;
			if (maskLayer) {
				maskLayer.height = v;
			}		
			if(scaleMode == StageScaleMode.EXACT_FIT){
				holder.width = v;
			}
		}
		override public function set width(v:Number):void {
			_w = v;
			
			if (maskLayer) {
				maskLayer.width = v;
			}		
			if(scaleMode == StageScaleMode.EXACT_FIT){
				holder.width = v;
			}
		}		
		
		public function get masked():Boolean { return _masked; }
		
		public function set masked(value:Boolean):void 	{
			if(value){
			maskLayer = new Sprite();
			maskLayer.graphics.beginFill (0xFFFF00,0);
			maskLayer.graphics.lineStyle (0, 0xFF00FF, 0);
			maskLayer.graphics.moveTo (0, 0);
			maskLayer.graphics.lineTo (_w, 0);
			maskLayer.graphics.lineTo (_w, _h);
			maskLayer.graphics.lineTo (0, _h);
			maskLayer.graphics.endFill();
			maskLayer.useHandCursor = false;			
			addChildAt(maskLayer,1);		
			holder.mask = maskLayer;
			}else if(maskLayer){
				removeChild(maskLayer);
			}
			_masked = value;
		}
		
		public function get scaleMode():String { return _scaleMode; }
		
		public function set scaleMode(value:String):void 
		{
			_scaleMode = value;
			setSize(_w, _h)
		}
		
		public function get resizeToFitContent():String { return _resizeToFitContent; }
		
		public function set resizeToFitContent(value:String):void 
		{
			_resizeToFitContent = value;
		}
		
		override public function setSize(w:int, h:int):void {
			if (maskLayer) {
				maskLayer.width = w;
				maskLayer.height = h;
			}
			if(scaleMode == StageScaleMode.EXACT_FIT){
				holder.width = w;
				holder.height = h;
			}
			_w = w;
			_h = h;
		}			
	
	}
	
}