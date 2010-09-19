package net.typoflash.components.reader 
{
	
	/**
	 * ...
	 * @author A. Borg
	 */
	public class ReaderType{
		public static const NEST_NEW_IN_OLD:int = 0;//good when latest 
		public static const NEST_OLD_IN_NEW:int = 1;
		public static const NEST_OFF:int = -1;
		
		
		public static const RENDER_ALL_AT_ONCE:int = 0;
		public static const RENDER_SEQUENTIALLY:int = 1;
		public static const RENDER_SEQUENTIALLY_NO_ACTIVATION:int = 2;//with this option you can render the whole list, and before or after activate optional item, instead of having an item flashing as the list renders
		
		public function ReaderType() {
			
		}
		
	}
	
}