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
	
	public dynamic class TFFrontEndUser extends TFUser{

		function TFFrontEndUser(o:Object) {

			super(o);
			TF_CONF.FE_AUTH.addEventListener(AuthEvent.ON_LOGIN_STATUS, authHandler);
		}
	

		


	};

}