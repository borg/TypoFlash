package net.typoflash.transitions {
	
	/**
	 * ...
	 * @author A. Borg
	 */
	import flash.display.Sprite;
	import gs.TweenLite;
	import gs.easing.*;
	import flash.display.DisplayObject;
	import net.typoflash.events.RenderingEvent;
	
	public class TweenLiteTransition extends Sprite implements ITransition{
		
		public var tweenLite:TweenLite;
		public var tweenInProp:Object;
		public var tweenOutProp:Object;
		private var _duration:Number;
		public var oldSprite:DisplayObject;
		public var newSprite:DisplayObject;
		
		public function TweenLiteTransition(_old:DisplayObject, _new:DisplayObject) {
			oldSprite = _old;
			newSprite = _new;
			addChild(newSprite);
			newSprite.visible = false;
			addChild(oldSprite);
		}
		public function set inProperties(value:Object):void {
			tweenInProp = { };
			for (var n in value) {
				tweenInProp[n] = value[n];
			}
			
			
		}		
		public function set outProperties(value:Object):void {
			tweenOutProp = { };
			for (var n in value) {
				tweenOutProp[n] = value[n];
			}
			
			tweenOutProp.onComplete = onComplete;
		}			
		
		public function get duration():Number {
			return _duration;
		}
		public function set duration(s:Number):void {
			_duration = s;
		}

		
		/*
		 * Tween both clips equally so out tween begins with same values
		 */ 
		public function startTransition():void {
			TweenLite.to(oldSprite, duration / 2, tweenInProp);
			tweenInProp.onComplete = tweenOut;
			TweenLite.to(newSprite, duration / 2, tweenInProp);
		}
		
		protected function tweenOut() {
			newSprite.visible = true;
			try{
				removeChild(oldSprite);
			}
			catch (e:Error){
				
			}
			oldSprite = null;
			TweenLite.to(newSprite,duration/2,tweenOutProp);
		}
		
		protected function onComplete() {
			dispatchEvent(new RenderingEvent(RenderingEvent.ON_TRANSITION_COMPLETE));
			
		}
		public function stopTransition():void {
			TweenLite.killTweensOf(newSprite);
			TweenLite.killTweensOf(oldSprite);
		}
		public function destroy():void {
			TweenLite.killTweensOf(newSprite);
			TweenLite.killTweensOf(oldSprite);
			/*try{
				removeChild(oldSprite);
			}catch (e:Error){}
			try{
				removeChild(newSprite);
			}catch (e:Error){}
			newSprite = null;
			oldSprite = null;*/
		}
		public function get newSpriteInFront():Boolean {
			return false;
		}
	}
	
}