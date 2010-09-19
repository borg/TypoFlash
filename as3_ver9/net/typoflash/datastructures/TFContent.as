package net.typoflash.datastructures {
	
	/**
	 * ...
	 * @author Borg
	 */

	import net.typoflash.utils.Debug;
	// TODO: Add sorting to Content 
	
	public dynamic class TFContent{
		public var target:String='';
		public var component_data:Object;
		public var path:String;
		public var component:TFComponent =  new TFComponent();
		public var media_category:String;
		public var name:String;
		public var pid:uint;
		public var sys_language_uid:uint;
		public var records:*;//TODO : Format for records??
		public var body_text:String;
		public var storage_page:String;
		public var title:String;
		public var xml_conf:String;//deprecated
		public var media:String;
		public var conf:Object;
		public var uid:uint;
		public var alpha:Number;
		public var x:uint;
		public var y:uint;
		public var z:uint;

		public function TFContent(o:Object) {
			//Debug.output(o);
			for (var n in o) {
				if (n == "component") {
					component = new TFComponent(o[n]);
				}else {
					this[n] = o[n];
				}
			}
			//Hand written component properties
			if (component.prop_x) {
				x = component.prop_x;
			}
			if (component.prop_y) {
				y = component.prop_y;
			}
			if (component.prop_alpha) {
				alpha = component.prop_alpha;
			}			

			//copy component initObj properties here
			for (n in component.initobj) {
				this[n] = component.initobj[n];
			}
		
			if(conf){
				//get conf values from Typo3 flash page content record. Hand written
				var valStr= conf.split('&');
				var valPair;
				var v = 0;
				while (v < valStr.length) {
					valPair = valStr[v].split('=');
					if (valPair[0] != '') {
						this[valPair[0]] = valPair[1];
					}
				++v;
				}
			}
			
			//data object stored via TypoFlash editor
			if(component_data is Object){
				for (n in component_data) {
					this[n] = component_data[n];
					Debug.output("TFContent parsing component data "+ n + ":"+component_data[n])
				}
			}
		}
		

		
	}
	
}