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


	public dynamic class TFBackEndUser extends TFUser{

		
		function TFBackEndUser(o:Object) {

			super(o);
			TF_CONF.BE_AUTH.addEventListener(AuthEvent.ON_LOGIN_STATUS, authHandler);
		}
	

		
				
	
	
		public function hasReadAccess(mod){
			if(tx_typoflash_data[mod]>=1){
				return true;
			}else{
				return false;
			}
			
		}
		public function hasWriteAccess(mod){
			if(tx_typoflash_data[mod]>=3){
				return true;
			}else{
				return false;
			}
			
		}
		public function hasTotalAccess(mod){
			if(tx_typoflash_data.access[mod]>=7){
				return true;
			}else{
				return false;
			}
			
		}
	};

}