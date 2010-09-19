package net.typoflash.fonts 
{
	import flash.text.Font;
	
	/**
	 * ...
	 * @author A. Borg
	 */
	public dynamic class FontStyle{
		public var bold:Font;
		public var italic:Font;
		public var regular:Font;
		
		public var name:String;
		public var size:int;//pixel font need specific sizes
		
		
		public function FontStyle(_name:String,_size:int=0) {
			name = _name;
			size = _size
		}
		
	}
	
}