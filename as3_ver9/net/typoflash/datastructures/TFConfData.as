package net.typoflash.datastructures {
	
	/**
	 * From TypoFlash 1.0 data modified through the TypoFlash interface will be handled internally as TFConfData
	 * In the database it is stored as name/value pairs in an object with two properties - physical and meta -
	 * where the former contains properties built into the Flash Player and the later optional bespoke meta data 
	 * for a specific component.
	 * 
	 * This is the format it will arrive to Glue and ultimately the Configurable Object.
	 *  
	 * ...
	 * @author A. Borg
	 */
	public class TFConfData {
		public var physical:Object;//name/value pairs
		public var meta:Object;// name/value pairs
		
		public function TFConfData() {
			physical = {};
			meta = {};
		}
		
	}
	
}