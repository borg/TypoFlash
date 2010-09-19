package net.typoflash.datastructures {
	
	/**
	 * ...
	 * @author Borg
	 */
	import net.typoflash.utils.Debug;
	
	public class TFMotherload{
		private var _motherload:Array;//internal version of motherload
		
		public var pageRequest:TFPageRequest;
		//When should motherload be retrieved? Define in template config
		public static const MODE_DO_NOT_USE_MOTHERLOAD:int = -1;
		public static const MODE_ON_GET_MENU:uint = 1;
		public static const MODE_ON_PAGE_LOAD_COMPLETE:uint = 2;
		public static const MODE_3:uint = 3;
		
		public var mode:uint;
		public var getRecords:Boolean = true;
		private var pageNum:uint = 0;
		
		public function TFMotherload() 	{
			_motherload = [];
		}
		
		/*
		 * Accumulate data to local cache. Only wiped on ContenrRendering.clearCache
		 */
		public function toString():String {
			return "[TFMotherload total num pages in cache: " + pageNum +"]";
		}
		public function parsePages(pages:Array, L:uint):void {
			Debug.output("parsePages got:");
			
			if(_motherload[L] == null){
				_motherload[L] = { };
			}
			var i = pages.length;
			
			var np:TFPage;
			while (i--) {
				//Clean out empty slots
				if (pages[i] != null) {
					np = new TFPage(pages[i]);
					Debug.output(np.toString())
					_motherload[L][np.HEADER.uid] = np;
					if(np.HEADER.alias){
						_motherload[L][np.HEADER.alias] = np;
					}
					
					//recursive call for subpages
					if (np.subpages != null) {
						parsePages(np.subpages,L);
					}
					pageNum++;
				}
				
				
				
			}
			
		}
		
		public function getPage(pid:int, L:int = 0, alias:String=''):TFPage {

			try {
				if(_motherload[L][pid] is TFPage){
					return _motherload[L][pid];
				}
			}
			catch (e) { }
			if (alias != '') {
				try {
					if(_motherload[L][alias] is TFPage){
						return _motherload[L][alias];
					}
				}
				catch (e:Error){}
				
			}
			return null;
		}
		
	}
	
}