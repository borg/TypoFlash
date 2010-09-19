package net.typoflash.datastructures{
	
	/**
	 * ...
	 * @author Borg
	 */
	public class TFMenu {
		public var menuId:String;//the caller's id as bounced back from remoting 
		
		public var request:TFMenuRequest;
		public var subpages:Array;
		
		
		public function TFMenu(o:Object) {
			menuId = o['menuId'];
			request = new TFMenuRequest(o['menuId'], o['id'], o['L']);
			for (var n in o['pObj']) {
					request[n] = o['pObj'][n];
			}
			
			delete o['pObj'];
			
			subpages = [];
			for(n in o.subpages){
				subpages.push(new TFMenuItem(o));
			}

		}
		

		
	}
	
}