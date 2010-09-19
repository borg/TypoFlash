package net.typoflash.events {
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Borg
	 */
	public class TFErrorEvent extends Event {
		
		public static const ON_REMOTING_ERROR:String = "onRemotingError";
		public static const ON_USER_ERROR:String = "onUserError";
		
		public var errortype:String;
		public var errormsg:String;
		public var method:String;//a string to calling function unless we can store the remoting call object

		public function TFErrorEvent(type:String,et:String='',em:String='',meth:String='', bubbles:Boolean = false, cancelable:Boolean = false) { 
			errortype = et;
			errormsg = em;
			super(type, bubbles, cancelable);
			
		}
		
	}
	
}