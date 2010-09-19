package net.typoflash.authentication {
	
	/**
	 * ...
	 * @author Borg
	 */
	
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	import flash.utils.getTimer;
	import net.typoflash.events.AuthEvent;

	import net.typoflash.datastructures.TFConfig;
	import net.typoflash.datastructures.TFBackEndUser;
	import net.typoflash.datastructures.TFFrontEndUser;
	
	//import net.typoflash.events.CoreEvent;
	import net.typoflash.events.RemotingEvent;
	import net.typoflash.events.RenderingEvent;

	import flash.net.Responder;
	import net.typoflash.ICore;
	import net.typoflash.remoting.RemotingService;

	import net.typoflash.crypto.MD5;

	import net.typoflash.utils.Cookie;
	
	
	 
	public class BEAuthentication extends Authentication{
		
		public function BEAuthentication()	{
			TF_CONF.BE_AUTH = this;
			if (TF_CONF.CORE) {
				addEventListener(AuthEvent.ON_LOGIN_STATUS, ICore(TF_CONF.CORE).onBELoginStatus);
			}
		}


		override public  function login(usr:String,psw:String, oldsalt:String=''){
			////Controls.debugMsg("usr: " + usr + " psw: " + psw + " salt: " + salt + " oldsalt: " + oldsalt);
			/*
			If salt is passed from outside we assume that userdetails are already stored encrypted on the local machine
			*/
			

			if(TF_CONF.BE_SECURITY_LEVEL==null){
				TF_CONF.BE_SECURITY_LEVEL='challenged';
			}
			if((TF_CONF.BE_SECURITY_LEVEL=='challenged')&&!(oldsalt.length>0)){
				//generate random salt
				var rand = getTimer()/Math.random();
				salt = escape(rand);			
				
			}
			
			if(!(oldsalt.length>0)){
				psw = MD5.hash(psw);	// this makes it superchallenged!!
				psw= challengePsw(usr,psw,salt)
			}else{
				salt = oldsalt;
			}

			var responder:Responder = new Responder(loginResult, handleRemotingError);
			_service.call("typoflash.remoting.contentrendering.BElogin", responder, usr, psw, salt);
			
				
			if(Cookie.global.data.storeBEuserdataEnabled){
				Cookie.global.setData('BE_USR',usr);
				Cookie.global.setData('BE_PSW',psw);
				Cookie.global.setData('BE_SALT',salt);
			}else{
				Cookie.global.setData('BE_USR',"");
				Cookie.global.setData('BE_PSW',"");
				Cookie.global.setData('BE_SALT',"");
			
			}

			/*
			After this call you wish to act AS BEuser
			*/
			
			////Controls.debugMsg("If login successful you will be acting as a BEuser. Username: " + usr);
			//Controls.debugMsg("usr: " + usr + " psw: " + psw + " salt: " + salt + " oldsalt: " + oldsalt);
			//serv.connection.setCredentials("FEuser");
			//serv.connection.setCredentials(usr, psw);
			dispatchEvent(new AuthEvent(AuthEvent.ON_LOGIN_STATUS,AuthEvent.PENDING));
		}

		private function loginResult(e){
			//Controls.debugMsg(data);
			TF_CONF.BE_USER = null;
			if(Cookie.global.data.storeBEuserdataEnabled){
				Cookie.global.setData('BE_USER',null);
			}
			if (e == false) {
				dispatchEvent(new AuthEvent(AuthEvent.ON_LOGIN_STATUS,AuthEvent.FALSE));
				_isLogged = false;

			}else if(e.uid > 0){
				TF_CONF.BE_USER = new TFBackEndUser(e);
				//tell login box etc
				dispatchEvent(new AuthEvent(AuthEvent.ON_LOGIN_STATUS,AuthEvent.TRUE));
				_isLogged = true;
				
			}else if(e.errortype>0){
				////dispatchEvent(new TFErrorEvent(TFErrorEvent.ON_REMOTING_ERROR, e.errortype, e.errormsg, "Authentication.BElogin"))
				//var error = new TFError(e.errortype, e.errormsg, "Authentication.BElogin");
				//dispatchEvent(new AuthEvent(AuthEvent.ON_LOGIN_STATUS, error));
				
				dispatchEvent(new AuthEvent(AuthEvent.ON_LOGIN_STATUS, AuthEvent.FALSE));
			}
		}
		private function loginStatus( data ) {
		  // implement error handling
			////Controls.debugMsg(data)
		}
		
		
		override public function getActiveUser () {
			trace("BE getActive")
			call("getActiveBEUser", null, getActiveResult);
			dispatchEvent(new AuthEvent(AuthEvent.ON_LOGIN_STATUS,AuthEvent.PENDING));
			
		}
		
		private function getActiveResult(e) {
			if (e == false) {
				_isLogged = false;
				dispatchEvent(new AuthEvent(AuthEvent.ON_LOGIN_STATUS,AuthEvent.FALSE));
			}else if(e.uid>0){
				TF_CONF.BE_USER = new TFBackEndUser(e);
				_isLogged = true;
				dispatchEvent(new AuthEvent(AuthEvent.ON_LOGIN_STATUS,AuthEvent.TRUE));
			}else if(e.errortype>0){
				//dispatchEvent(new TFErrorEvent(TFErrorEvent.ON_REMOTING_ERROR,e.errortype,e.errormsg,"Authentication.getActiveBEUser"))
				dispatchEvent(new AuthEvent(AuthEvent.ON_LOGIN_STATUS,AuthEvent.FALSE));
			}	
		}

		override public function logout (){
			call("BElogout", null, logoutResult);
			//serv.connection.setCredentials("","");
			//RemotingRelaySocket.closeSocket();
			//loginbox
			dispatchEvent(new AuthEvent(AuthEvent.ON_LOGIN_STATUS,AuthEvent.PENDING));
			
		}
		private function logoutResult(e){
			////Controls.debugMsg("\n\n\nlogoutResult " + ObjectDumper.toString(data.result))
			//returns true on logout, hense status is false
			if(e){
				dispatchEvent(new AuthEvent(AuthEvent.ON_LOGIN_STATUS, AuthEvent.FALSE));
				_isLogged = false;
				TF_CONF.BE_USER = null;
			}else {
				////dispatchEvent(new TFErrorEvent(TFErrorEvent.ON_REMOTING_ERROR,re.data.errortype,re.data.errormsg,"Authentication.BElogout"))
			}
			//
		}
		
	}
	
}