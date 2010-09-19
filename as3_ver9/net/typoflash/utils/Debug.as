package net.typoflash.utils {
	
	/**
	 * 
	 * 
	 * Implement flash.utils.describeType()
	 * ...
	 * @author Borg
	 */
	import flash.utils.describeType;
	import flash.external.ExternalInterface;
	import net.typoflash.utils.Cookie;
	import net.typoflash.datastructures.TFConfig;
	
	
	public class Debug 
	{
		
		public function Debug() 
		{
			
		}
		public static function output(msg:*) {
			if (!Cookie.global.data.debugEnabled && TFConfig.global.IS_LIVE) {
				return;
			}
			//Send it out to firebug
			ExternalInterface.call("console.log", msg);
			trace(msg);
			return;
			var str = "";
			if (msg is Object) {
				str += describeType(msg);
			}else{
				str += String(msg);
			}
			
		}
		
		
		private static function object2string(o:Object, ind:String = ""):String {
			if(o.constructor != String){
				var str:String = ind + String(o.constructor) + "\n";
			}else {
				str = "";
			}

			for (var n in o) {
				/*if (o[n] is Array) {
					str +=  o.toString()+ "\n";
				}else 
				if (n == null) {
					//continue;
					trace("n is null")
				}*/
				if (o[n] is Object && o.constructor != String) {
					str += object2string(o[n], "     ")+ "\n";
				}else{
					str += ind + n + ":" + o[n] + "\n";
				}
				trace(ind + n + ":" + o[n] )
			}
			return str;
		}
	}
	
}