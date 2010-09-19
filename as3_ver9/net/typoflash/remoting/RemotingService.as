/*
        package    {

      import flash.net.Responder;

	  public class RemotingTest{
 
		private var rs:RemotingService;

		function RemotingTest(){

			init();

		}

		 private function init(){

		      rs = new RemotingService("http://your.domain.com/amfphp/gateway.php");
		      var responder:Responder = new Responder(onResult, onFault);
		      var params:Object = new Object();
		      params.arg1 = "something";
		      params.arg2 = "2";
		      rs.call("Class.method", responder, params);
		}

		private function onResult(result:Object):void{

			trace(result);

		}

		private function onFault(fault:Object):void{

			trace(fault);

		}

      }

}

*/




package net.typoflash.remoting{
	import flash.net.NetConnection;
	import flash.net.ObjectEncoding;
	
	
	public class RemotingService extends NetConnection{
	
	
		function RemotingService(url:String){

			// Set AMF version for AMFPHP
			objectEncoding = ObjectEncoding.AMF0;
			
			// Connect to gateway
			connect(url);

		}
		
		public function setCredentials (user:String, pass:String='') :void{
			super.addHeader("Credentials", false, {userid: user, password: pass});
		}


	}

}