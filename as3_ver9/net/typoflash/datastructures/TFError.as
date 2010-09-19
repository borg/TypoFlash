package net.typoflash.datastructures 
{
	
	/**
	 * //errortypes 
	 * 0 = no error
	 * 1 = user input error, can proceed
	 * 2 = server error, try later
	 * 3 = serious server error, bloody stuck
	 * ...
	 * @author A. Borg
	 */
	public class TFError {
		
		
		public static const USER_ERROR:int = 1;
		public static const SERVER_ERROR:int = 2;
		public static const SEVERE_SERVER_ERROR:int = 3;
		
		public var type:int;
		public var msg:String;
		public var params:*;
		public var method:String;//a string to calling function unless we can store the remoting call object
		
		
		public function TFError(_errortype:int,_errormsg:String,_method:String='',_params:*=null) {
			type = _errortype;
			msg = _errormsg;
			params = _params;
			method = _method;

		}
		
	}
	
}