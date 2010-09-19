package net.typoflash.datastructures{
	
	/**
	 * ...
	 * @author Borg
	 */
	public class TFPage {
		public var TEMPLATE:TFTemplate;
		public var HEADER:TFHeader;
		public var CONTENT:Array;
		
		public var subpages:Array;
		
		public function TFPage(o:Object) {

			TEMPLATE = new TFTemplate(o['TEMPLATE']);
			HEADER = new TFHeader(o['HEADER']);

			
			CONTENT = [];
			if(o['CONTENT']!=""){
				for ( var i = 0; i < o['CONTENT'].length;i++ ) {
					CONTENT.push(new TFContent(o['CONTENT'][i]));
				}
			}

		}
		public function toString():String {
			return "[TFPage uid: " + HEADER.uid +", title: "+HEADER.title+"]";
		}
	}
	
}