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
	public dynamic class TFPerson {
		
		protected var TF_CONF:TFConfig = TFConfig.global;
		
		public var username:String;
		public var password:String;
		public var gender:String;
		public var name:String;
		public var first_name:String;
		public var last_name:String;
		public var status:String;
		public var date_of_birth:String;
		public var address:String;
		public var city:String;
		public var zone:String;
		public var country:String;
		public var static_info_country:String;
		public var zip:String;
		public var telephone:String;
		public var fax:String;
		public var email:String;
		public var language:String;
		public var title:String;
		public var company:String;
		public var www:String;
		public var image:String;
		public var comments:String;



		public function TFPerson(o:Object) {
			for (var n in o) {
				trace("public var " +n)
				this[n] = o[n];
			}
			
		
		}
		
		public function unset(){
			for(var n in this){
				n = null;
			
			}
		}

	};

}