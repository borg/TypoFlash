package com.flashdynamix.events {	import flash.events.Event;
	/**	 * @author FlashDynamix	 */	public class YouTubeFLVErrorEvent extends Event {		public static const ERROR : String = "youtube_player_error";		public var code : int = -1;
		public function YouTubeFLVErrorEvent(type : String, code : int, bubbles : Boolean = false, cancelable : Boolean = false) {			super(type, bubbles, cancelable);						this.code = code;		}
		public override function clone() : Event {			return new YouTubeFLVErrorEvent(type, code, bubbles, cancelable);		}
	}}