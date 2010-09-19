package net.typoflash.datastructures 
{
	
	/**
	 * Localised content comes back with the different language overlays in a nested object with a lang array
	 * indexed on language system uid
	 * ...
	 * @author A. Borg
	 */
	public dynamic class TFLanguageObject{
		public var lang:Array;
		public var TF_CONF:TFConfig = TFConfig.global;
		
		public function TFLanguageObject(o:Object){
			for (var n in o) {
				this[n] = o[n];
			}	
		}
		/*
		 * Utility function
		 */ 
		public function getLanguage(x:Object, field:String):String {
			if (x.lang[TF_CONF.LANGUAGE][field] != null) {
				return x.lang[TF_CONF.LANGUAGE][field];
			} else if (x.lang[0][field] != null) {
				return x.lang[0][field];
            } else {
				return '';
            }
        };		
			
	}
	
}