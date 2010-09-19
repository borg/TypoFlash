/*******************************************
* Class: 
*
* Copyright A. net.typoflash, net.typoflash@elevated.to
*
********************************************
* Example usage:
*
*
*
********************************************/

package net.typoflash.datastructures{
	import net.typoflash.events.AuthEvent;
	public dynamic class TFUser {
			
		
		public var TF_CONF:TFConfig = TFConfig.global;
		public var uid:uint;
		public var lastlogin:int;
		public var workspace_id:String;
		public var ses_name:int;
		public var email:String;
		public var usergroup:uint;
		public var ses_backuserid:uint;
		public var tstamp:uint;
		public var deleted:int;
		public var ses_hashlock:int;
		public var tt_news_categorymounts:String;
		public var tx_typoflash_data:Object;//the user specific access/preference storage
		public var fileoper_perms:String;
		public var endtime:int;
		public var realName:String;
		public var admin:String;
		public var options:String;
		public var remoting_session:String;
		public var cruser_id:String;
		public var TSconfig:String;
		public var tx_typoflash_status:String;
		public var ses_userid:String;
		public var ses_id:String;
		public var uc:String;
		public var allowed_languages:String;
		public var password:String;
		public var db_mountpoints:String;
		public var starttime:String;
		public var ses_data:String;
		public var disableIPlock:String;
		public var createdByAction:String;
		public var lang:String;
		public var crdate:String;
		public var workspace_perms:String;
		public var userMods:String;
		public var workspace_preview:String;
		public var ses_tstamp:int;
		public var file_mountpoints:String;
		public var username:String;
		public var ses_iplock:String;
		public var usergroup_cached_list:String;
		public var disable:String;
		public var pid:uint;
		public var lockToDomain:String;


		public function TFUser(o:Object) {
			for (var n in o) {
				this[n] = o[n];
			}
			
		
		}
	
		protected function authHandler(e:AuthEvent){
			if(!e.data){
				unset();
				//Controls.debugMsg("Authentication.getActiveBEResult: No active TFBackEndUser");
			}
		}
		public function unset(){
			for(var n in this){
				n = null;
			
			}
		}
	};

}