package net.typoflash.editor 
{
	
	/**
	 * ...
	 * @author Borg
	 */
	import net.typoflash.Glue;
	
	public interface ITypoFlash{
		function get currentGlue():Glue;
		function set currentGlue(value:Glue):void;
		function registerGlue(g:Glue):void;
		function unregisterGlue(g:Glue):void;
		
	}
	
}