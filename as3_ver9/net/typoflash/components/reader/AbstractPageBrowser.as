package net.typoflash.components.reader 
{
	import net.typoflash.components.Skinnable;	
	import net.typoflash.base.Configurable;
	
	/**
	 * A page browser is that thing at the bottom of a recordset reader that shows how many pages there are in total
	 * and has a back and forward arrow.
	 * ...
	 * @author A. Borg
	 */
	public class AbstractPageBrowser extends Skinnable{
		public var reader;

		
		public function AbstractPageBrowser(_reader) {
			reader = _reader;
			
		}
		

	}
	
}