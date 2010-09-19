package net.typoflash.events{
	import flash.events.Event;



	public class AuthEvent extends Event {
		public static const ON_LOGIN_STATUS:String = "onLoginStatus";
		
		public static const TRUE:int = 1;
		public static const FALSE:int = 0;
		public static const PENDING:int = -1;
		
		public var data:*;
		public var status:int;//true,false,pending
		public var errortype:uint;
		public var errormsg:String;



		
		public function AuthEvent(type:String,s:int,r:*='',et:String='',em:String='', bubbles:Boolean = false, cancelable:Boolean = false){
			data = r;
			status = s;
			super(type, bubbles, cancelable);
		}
		
		override public function toString():String {
				return "[AuthEvent status: " + status + "]"; 
		}
	}
}