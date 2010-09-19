package net.typoflash.base 
{
	
	/**
	 * All objects that are fixed inside a template and that are to be configurable must implement
	 * ITemplateObject. This is just used so as to easily distinguish between display objects that
	 * live only on a page, such as components, or those that persist between many pages and therefore
	 * can be tweened etc. By default all Configurables implement ITempleteObject
	 * ...
	 * @author A. Borg
	 */
	public interface ITemplateObject {
		
	}
	
}