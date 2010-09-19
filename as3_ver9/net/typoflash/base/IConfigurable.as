package net.typoflash.base 
{
	import net.typoflash.datastructures.TFConfig;
	import net.typoflash.Glue;
	
	/**
	 * ...
	 * @author Borg
	 */
	public interface IConfigurable	{
		
		function get TF_CONF():TFConfig;
		function get TF_GLUE():Glue;
		function destroy():void;
	}
	
}