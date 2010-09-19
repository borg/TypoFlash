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
	
	import net.typoflash.events.CoreEvent;
	import net.typoflash.events.RemotingEvent;
	import net.typoflash.events.RenderingEvent;

	import flash.net.Responder;
	import net.typoflash.remoting.RemotingService;

	import net.typoflash.crypto.MD5;

	import net.typoflash.utils.Cookie; 
	 
	 
	public class FEAuthentication extends Authentication{
		
		public function FEAuthentication() 	{
			TF_CONF.FE_AUTH = this;
		}
		override public  function login(usr:String,psw:String, oldsalt:String=''){
			/*
			If salt is passed from outside we assume that userdetails are already stored encrypted on the local machine
			*/
			
			
			if(TF_CONF.FE_SECURITY_LEVEL==null){
				TF_CONF.FE_SECURITY_LEVEL='challenged';
			}

			if((TF_CONF.FE_SECURITY_LEVEL=='challenged')&&!(oldsalt.length>0)){
				//generate random salt
				var rand = getTimer()/Math.random();
				salt = escape(rand);			
				
			}
			//Controls.debugMsg("Should go to supermode now");
			if(!(oldsalt.length>0) &&  TF_CONF.FE_SECURITY_LEVEL!='normal'){
				
				var opsw = psw;
				
				var chpsw = MD5.hash(psw);	// this makes it superchallenged!!
				psw = challengePsw(usr,chpsw,salt);
				//Controls.debugMsg("Psw was: "+opsw + " md5: " + chpsw+ " super: " + psw);
			}else{
				salt = oldsalt;
			}
			
			var responder:Responder = new Responder(loginResult, handleRemotingError);
			_service.call("typoflash.remoting.contentrendering.FElogin", responder, usr, psw,salt);
			
			

			if(Cookie.global.data.storeFEuserdataEnabled){
				Cookie.global.setData('FE_USR',usr);
				Cookie.global.setData('FE_PSW',psw);
				Cookie.global.setData('FE_SALT',salt);
			}else{
				Cookie.global.setData('FE_USR',"");
				Cookie.global.setData('FE_PSW',"");
				Cookie.global.setData('FE_SALT',"");
			
			}

			/*
			After this call you wish to act AS FEuser
			*/

			//loginbox

			dispatchEvent(new AuthEvent(AuthEvent.ON_LOGIN_STATUS,AuthEvent.PENDING));
		}

		private function loginResult(re:RemotingEvent){
		//Controls.debugMsg(data)
			  // implement onresult here
			if(re.data.errortype>0){
				//dispatchEvent(new TFErrorEvent(TFErrorEvent.ON_REMOTING_ERROR,re.data.errortype,re.data.errormsg,"Authentication.login"))
				dispatchEvent(new AuthEvent(AuthEvent.ON_LOGIN_STATUS,AuthEvent.FALSE));
			}else if(re.data){
				TF_CONF.FE_USER = new TFFrontEndUser(re.data);
			
				dispatchEvent(new AuthEvent(AuthEvent.ON_LOGIN_STATUS,AuthEvent.TRUE));
				_isLogged = true;
				
			}else{
				//loginbox
				dispatchEvent(new AuthEvent(AuthEvent.ON_LOGIN_STATUS,AuthEvent.FALSE));
				_isLogged = false;
			}
		}

		

		override public function logout (){
			call("FElogout", null, logoutResult);
			dispatchEvent(new AuthEvent(AuthEvent.ON_LOGIN_STATUS,AuthEvent.PENDING));
			
		}
		private function logoutResult(re:RemotingEvent){
			TF_CONF.FE_USER = null;
			dispatchEvent(new AuthEvent(AuthEvent.ON_LOGIN_STATUS,AuthEvent.FALSE));
			_isLogged = false;

		}
		
		override public function getActiveUser (){
			call("getActiveFEUser", null, getActiveResult);
			dispatchEvent(new AuthEvent(AuthEvent.ON_LOGIN_STATUS,AuthEvent.PENDING));
		}
		
		private function getActiveResult(re:RemotingEvent) {
			if(re.data.errortype>0){
				//dispatchEvent(new TFErrorEvent(TFErrorEvent.ON_REMOTING_ERROR,re.data.errortype,re.data.errormsg,"Authentication.getActiveUser"))
				dispatchEvent(new AuthEvent(AuthEvent.ON_LOGIN_STATUS,AuthEvent.FALSE));
			}else if(re.data['uid']>0){
				TF_CONF.FE_USER = new TFFrontEndUser(re.data);
				_isLogged = true;
				dispatchEvent(new AuthEvent(AuthEvent.ON_LOGIN_STATUS,AuthEvent.TRUE));
			}else{
				_isLogged = false;
				dispatchEvent(new AuthEvent(AuthEvent.ON_LOGIN_STATUS,AuthEvent.FALSE));
			}	
			
			
			
		}	
		
	}
	
}