package net.typoflash.datastructures{
	
	/**
	 * ...
	 * @author Borg
	 */
	public class TFMenuItem {
		public var url:String;
		public var urltype:uint;
		public var nav_title:String;
		public var sys_language_uid:String;
		public var media_path:String;
		public var media:String;
		public var target:String ="_flash";
		public var author:String;
		public var uid:uint;
		public var pid:uint;
		public var menuId:String;
		public var abstract:String;
		public var storage_pid:uint;
		public var shortcut:uint;
		public var subtitle:String;
		public var description:String;
		public var shortcut_mode:uint;
		public var title:String;
		public var label:String;
		public var alias:String;
		public var doktype:uint;
		
		public var subpages:Array;
		
		//for some reason properties are not enumerable by default
		private var _enumerables:Array;
		
		public function TFMenuItem(o:Object) {
			_enumerables = [];
			for (var n in o) {
				if (n == 'subpages') {
					subpages = getSubPages(o[n]);
				}else{
					this[n] = o[n];
					_enumerables.push(n);
					
				}
			}
		}
		
		public function getSubPages(o:Array):Array {
			var pages = [];
			for (var i = 0; i < o.length; i++) {
				pages[i] = new TFMenuItem(o[i]);
			}
			return pages;
		}
		
		public function toString() {
			var node:XML = <menuitem />
			var v = _enumerables.length;
			while(v--) {
				node.@[_enumerables[v]] = this[_enumerables[v]]
			}
			return node.toXMLString();
		}
		
	}
	
}