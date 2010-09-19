package net.typoflash.base{
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author A. Borg
	 * 
	 * This is a collection of the additional properties that any configurable 
	 * object can store/edit other than the physical properties.
	 */
	public class ConfigurableProperties {
		private var _enabledList:Array;
		private var _list:Dictionary;
		
		public function ConfigurableProperties() 	{
			_enabledList = [];
			_list = new Dictionary(true);
		}
		
		public function addProperty(p:ConfigurableProperty) {
			_list[p.name] = p;
		}
		
		public function get enabledList():Array {
			return _enabledList;
		}
		
		public function get list():Dictionary { return _list; }
				
		public function enable(v:ConfigurableProperty) {
			if (_list[v.name] is ConfigurableProperty) {
				_list[v.name].enabled = true;
				updateList();
			}
		}

		public function disable(v:ConfigurableProperty) {
			if (_list[v.name] is ConfigurableProperty) {
				_list[v.name].enabled = false;
				updateList();
			}
		}		
		
		public function property(v:String):ConfigurableProperty {
			return _list[v];
		}
		
		
		protected function updateList() {
			_enabledList = [];
			for (var n in _list) {
				if (_list[n] is ConfigurableProperty) {
					if (_list[n].enabled) {
						_enabledList.push(_list[n]);
					}
				}
			}
		}		
	}
	
}