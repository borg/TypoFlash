package net.typoflash.datastructures {
	
	/**
	 * ...
	 * @author Borg
	 */
	import net.typoflash.utils.Debug;
	
	public dynamic class TFComponent {
		public var tstamp:String;
		public var prop_y:uint;
		public var pid:uint;
		public var sorting:int;
		public var prop_x:uint;
		public var cruser_id:uint;
		public var prop_alpha:Number;
		public var file:String;
		public var crdate:int;
		public var fe_group:uint;
		public var hidden:String;
		public var uid:uint;
		public var initobj:*;//the url encoded variables written by hand into typo3 I think
		public var deleted:String;
		public var endtime:int;
		public var name:String;
		public var starttime:int;
		public var path:String='';
		
		public function TFComponent(o:*=null) 	{
			//Debug.output(o);
			for (var n in o) {
				this[n] = o[n];
			}
			//extract initObject properties if exist
			initobj = { };
			try {
				
				var valStr= initobj.split('&');
				var valPair;
				var v = 0;
				while (v < valStr.length) {
					valPair = valStr[v].split('=');
					if (valPair[0] != '') {
						initobj[valPair[0]] = valPair[1];
					}
				++v;
				}
			}
			catch(e){}
		}
		
	}
	
}