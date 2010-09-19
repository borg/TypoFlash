/*
COOKIE by Borg

package {
    import flash.net.SharedObject;

    public class SharedObject_flush {
        private var hostName:String = "yourDomain";
        private var username:String = "yourUsername";

        public function SharedObject_flush() {
            var mySo:SharedObject = SharedObject.getLocal(hostName);
            mySo.data.username = username;
            var flushResult:Object = mySo.flush();
            trace("flushResult: " + flushResult);
            trace(mySo.data.username); // yourUsername
        }
    }
}


*/
package net.typoflash.utils{
	import flash.net.SharedObject;
	import flash.system.*;
	import flash.events.NetStatusEvent;


	public class Cookie{
		public var timeStamp:Number;
		public var name:String;
		public var _instance;
		private static var _globalInstance:Cookie;
		private static var g:Global = Global.getInstance();
		
		public function Cookie(name){
			_instance = SharedObject.getLocal(name)
		
			_instance.addEventListener(NetStatusEvent.NET_STATUS,flushStatus);
		};
		
		function flushStatus(e:NetStatusEvent){
			if (e.info == "SharedObject.Flush.Success") {
				
			} else if (e.info == "SharedObject.Flush.Failed") {
				
			}
			
		}
		//Set Flash cookie
		public function setCookie() {
			var cookieTime:Date = new Date();
			_instance.data.timeStamp = cookieTime.getTime();
		
			if (_instance.flush() == false) {
				Security.showSettings(SecurityPanel.LOCAL_STORAGE);
				trace("flush fail")
			}


			
		};
		
		public function clearCookie(){
			//clear the cookie
			for (var n in _instance.data){
				_instance.data[n] = null
		
			}
			this.setCookie();
		
		};
		/*
		There is a data get method but no set method. Because it doesnt work out.
		*/
		public function get data(){
			return _instance.data;
		}
		
		public function getData(v){
			return _instance.data[v];
		}
		/*
		You can use this function or 
		Cookie.global.data.highQuality = 1;
		Cookie.global.setCookie();
		*/
		public function setData(n,v){
			_instance.data[n] = v;
			setCookie()
		}

		public static function get global():Cookie {
	
			 if (_globalInstance == null) {
				if(g['HOST_URL']!=null){
				//need to strip // cause they not permitted

				 
				var str:String =escape(g['HOST_URL']);
				
				var pat1:RegExp = /\/\//; 
				str = str.replace(pat1, "_");
				var pat2:RegExp = /\//; 
				str = str.replace(pat2, "_");

				_globalInstance = new Cookie(str);
				}else{
					_globalInstance = new Cookie("IWishIKnewAUniqueNAmeHEre");
				}
			 }
			 return _globalInstance;
		}

	}	
}