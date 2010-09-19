/*
Class: LoginBox

Author: A. net.typoflash
Email: net.typoflash@elevated.to
*/
package net.typoflash.ui{

	import net.typoflash.utils.Cookie;
	import flash.display.*;
	import flash.text.TextField;
	import net.typoflash.authentication.*;
	import flash.events.Event;
	

	import fl.controls.Button;
	import fl.controls.ButtonLabelPlacement;

	import fl.controls.TextArea;
	import flash.events.MouseEvent;	


	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import net.typoflash.events.AuthEvent;
	import net.typoflash.utils.Debug;
	import net.typoflash.datastructures.TFConfig;

	public class LoginBox  extends MovieClip{
		public static const MODE_BE:String= "BE";
		public static const MODE_FE:String= "FE";
		protected var TF_CONF:TFConfig = TFConfig.global;
		
		private var _authenticationSystem:Authentication;//reference to login system supporting login,logout,getActiveUser methods

		
		public var rememberMe:Boolean;
		public var autoCheck:Boolean=true;
	
		private var _mode:String = "FE";//FE/BE
	

		public function LoginBox(){
			addEventListener(Event.ADDED_TO_STAGE, init);
		}

		public function init(e:Event){
			submitBtn.addEventListener(MouseEvent.CLICK, loginFunction);
			//
			
			submitBtn.labelPlacement = ButtonLabelPlacement.RIGHT;
			submitBtn.setSize(32, 30);


			if(autoCheck){
				submitBtn.setStyle("icon", icon_pending);
				psw_txt.visible = usr_txt.visible = rememberMe_chk.visible= false;

			}else{
				submitBtn.setStyle("icon", icon_login);
				psw_txt.visible = usr_txt.visible = rememberMe_chk.visible= true;
			}


			usr_txt.type = psw_txt.type = TextFieldType.INPUT;
			psw_txt.displayAsPassword = true;
			
			rememberMe_chk.addEventListener(MouseEvent.CLICK, rememberMeListener);


			


		}
		
		function rememberMeListener(e:MouseEvent):void {
			var cb:CheckBox = CheckBox(e.target);
			if(cb.selected == true){
				Cookie.global.setData('store'+_mode+'userdataEnabled',cb.selected);
				//Debug.output("Cookie.global.data.store"+mode+"userdataEnabled " + Cookie.global.data["store"+mode+"userdataEnabled"])

			}
		}


		function onLoginStatus(e:AuthEvent){
				
			if(Cookie.global.data['store'+_mode+'userdataEnabled']){
				rememberMe_chk.selected = true;
				/*
				Only fill in details if nothing is written
				*/
				usr_txt.visible = psw_txt.visible = true;
				if(!(usr_txt.length>0)){
					var cookie_usr = Cookie.global.getData(_mode+'_USR');
					var cookie_psw = Cookie.global.getData(_mode+'_PSW');
					if(cookie_usr != null){
						usr_txt.text = cookie_usr;
					}else{
						Debug.output("No cookie user found");
					}
					if(cookie_psw != null){
						psw_txt.text = cookie_psw;
					}
					//Debug.output("psw_txt.text: " + psw_txt.text);
				}
			
			}else{
				rememberMe_chk.selected = false;
			}

			
			if(e.status == AuthEvent.TRUE){
				//true logged in
				
				submitBtn.setStyle("icon", icon_logout);
				submitBtn.removeEventListener(MouseEvent.CLICK, loginFunction);
				submitBtn.addEventListener(MouseEvent.CLICK, logoutFunction);

				//trace(this + " login box?? " + obj.currentTarget)
				gotoAndStop("logout");
				if(_mode == LoginBox.MODE_BE){
					try{
						status_txt.text = "WELCOME " + TF_CONF.BE_USER.realName.toLocaleUpperCase();
					}
					catch (e:Error) {}
						
				}
				if(_mode == LoginBox.MODE_FE){	
					try{
						status_txt.text = "WELCOME " + TF_CONF.FE_USER.realName.toLocaleUpperCase();
					}
					catch (e:Error){}
					
				}
				
				psw_txt.visible = usr_txt.visible = rememberMe_chk.visible= false;
			}else if(e.status == AuthEvent.PENDING){
				//pending answer

				submitBtn.setStyle("icon", icon_pending);
				//this is a hack because sometimes first login doesnt bite...shud really clear the login function
				//submitBtn.removeEventListener(MouseEvent.CLICK, loginFunction);
				submitBtn.removeEventListener(MouseEvent.CLICK, logoutFunction);
			
				usr_txt.type = psw_txt.type = TextFieldType.INPUT;
				
				status_txt.text = "";
				psw_txt.visible = usr_txt.visible = rememberMe_chk.visible= false;
				
				
			}else if(e.errortype >0 ){


				submitBtn.setStyle("icon", icon_login);
				submitBtn.addEventListener(MouseEvent.CLICK, loginFunction);
				submitBtn.removeEventListener(MouseEvent.CLICK, logoutFunction);
		
				gotoAndStop("login");
				usr_txt.type = psw_txt.type = TextFieldType.INPUT;
				psw_txt.displayAsPassword = true;
				psw_txt.visible = usr_txt.visible = rememberMe_chk.visible=true;
			}else{
				//not logged in
	
				submitBtn.setStyle("icon", icon_login);
				submitBtn.addEventListener(MouseEvent.CLICK, loginFunction);
				submitBtn.removeEventListener(MouseEvent.CLICK, logoutFunction);
	
				gotoAndStop("login");
				usr_txt.type = psw_txt.type = TextFieldType.INPUT;
				psw_txt.displayAsPassword = true;
				psw_txt.visible = usr_txt.visible = rememberMe_chk.visible = true;

			
			}
		
		}


		
		function loginFunction(e:MouseEvent){
			//Debug.output(this + " got loginFunction "+ mode)
			if(usr_txt.text.length>0 && psw_txt.text.length>0){
					/*
					If values not same as stored in cookie send new ones without salt
					*/
					if((Cookie.global.getData(_mode+'_USR')==usr_txt.text)&&(Cookie.global.getData(_mode+'_PSW')==psw_txt.text)){
						_authenticationSystem.login(usr_txt.text,psw_txt.text,Cookie.global.getData(_mode+'_SALT') );
					}else{
						Cookie.global.setData(_mode+'_SALT',null)
						_authenticationSystem.login(usr_txt.text,psw_txt.text);
					}
				}
		}
		
		function logoutFunction(e:MouseEvent){
			_authenticationSystem.logout();

		}

		
		public function get mode():String { return _mode; }
		
		public function set mode(value:String):void 	{
			if (value == LoginBox.MODE_BE) {
				_authenticationSystem = new BEAuthentication();
			}else if (value == LoginBox.MODE_FE) {
				_authenticationSystem = new FEAuthentication();
			}
			_authenticationSystem.addEventListener(AuthEvent.ON_LOGIN_STATUS, onLoginStatus);
			_mode = value;
			if(autoCheck){
				_authenticationSystem.getActiveUser();
			}
			if(Cookie.global.getData('store'+_mode+'userdataEnabled')){
				rememberMe_chk.selected = true;
			
			}
		}

		//public function setSize(w:int,h:int){
		//}
	}
}