package net.typoflash.events {
	import flash.events.ErrorEvent;
	
	/**
	 * ...
	 * @author Borg
	 */
	public class ErrorEvent extends ErrorEvent {
		
		public static const ON_REMOTING_ERROR:String = "onRemotingError";
		
		public var errortype:String;
		public var errormsg:String;
		public var method:String;//a string to calling function unless we can store the remoting call object

		public function ErrorEvent(type:String,et:String='',em:String='',meth:String='', bubbles:Boolean = false, cancelable:Boolean = false) { 
			errortype = et;
			errormsg = em;
			super(type, bubbles, cancelable);
			
		}
		
	}
	
}