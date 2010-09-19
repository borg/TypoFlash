/*



*/
package net.typoflash.authentication {
	
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	import flash.utils.getTimer;
	import net.typoflash.events.AuthEvent;

	import net.typoflash.datastructures.TFConfig;
	import net.typoflash.datastructures.TFBackEndUser;
	import net.typoflash.datastructures.TFFrontEndUser;
	
	import net.typoflash.events.CoreEvent;
	import net.typoflash.events.RemotingEvent;
	import net.typoflash.events.RenderingEvent;

	import flash.net.Responder;
	import net.typoflash.remoting.RemotingService;

	import net.typoflash.crypto.MD5;
	import net.typoflash.utils.Debug;
	import net.typoflash.utils.Cookie;

	public class Authentication extends EventDispatcher{
		protected var TF_CONF:TFConfig = TFConfig.global;
		protected var _service:RemotingService;
		protected var _isLogged:Boolean;

		public var usr:String;
		public var psw:String;
		public var salt:String;
		
		protected var isLoggedButNotIdentified:Boolean = false;//multiuser server related
		
		

	// ===========================================================
	// - CONSTRUCTOR
	// ===========================================================
		public function Authentication() {
			//CoreEvents.addEventListener("onRelayConnectionStatus", this);
			_service = new RemotingService(TF_CONF.REMOTING_GATEWAY);
			
			
			
		}
		
		protected function call(func:String, params:Object, callback:Function) {
			//same fault function for all calls
			var responder:Responder = new Responder(callback, handleRemotingError);
			_service.call("typoflash.remoting.contentrendering." + func, responder, params);
		}
		

		
		protected function challengePsw(usr,psw,salt){
			/*var password = myMD5.encrypt(psw);	// this makes it superchallenged!!
			var str = usr+":"+password+":"+salt;*/
			var str = usr+":"+psw+":"+salt; // this makes it challenged
			var userident = MD5.hash(str);
			
			return userident;
			
		}
		
		protected function onRelayConnectionStatus(obj){
			////Controls.debugMsg("typo got onRelY")
			//send identifier to relay
			/*
			<request type="client_request">
				<node id="function" value="identifyClient" />
				<arg name="user" value="1"/>
			</request>
			
			*/

			//response = {type:"onRelayConnect",connectionActive:connectionActive};
			
		}


		 public function get isLogged() {
			 //fe log
			return _isLogged;
		 }

		protected function handleRemotingError(e):void 	{
			for (var n in e) {
				trace(n +"  "+ e[n])
			}
			Debug.output(e);
			//throw new Error(e.errormsg);
		}
		
		
		public function getActiveUser (){
			throw new Error("getActiveUser must be overridden")	
		}
		public  function login(usr:String,psw:String, oldsalt:String=''){
			throw new Error("login must be overridden")	
		}
		public function logout () {
			throw new Error("logout must be overridden")	
		
		}
	}
}