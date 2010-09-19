package com.flashdynamix.events {	import flash.events.Event;
	/**	 * @author FlashDynamix	 */	public class YouTubeChromelessPlayerErrorEvent extends Event {		public static const ERROR : String = "youtube_flv_error";		public var code : int = -1;
		public function YouTubeChromelessPlayerErrorEvent(type : String, code : int, bubbles : Boolean = false, cancelable : Boolean = false) {			super(type, bubbles, cancelable);						this.code = code;		}
		public override function clone() : Event {			return new YouTubeChromelessPlayerErrorEvent(type, code, bubbles, cancelable);		}
	}}