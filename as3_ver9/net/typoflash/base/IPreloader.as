package net.typoflash.base 
{
	
	/**
	 * All load processes should send CoreEvents,
	 * this is how a frame does it
	 * TF_CONF.CORE.dispatchEvent(new CoreEvent(CoreEvent.ON_LOAD_COMPLETE, e, CoreEvent.LOAD_TYPE_COMPONENT ));
	 * ...
	 * @author A. Borg
	 */
	import flash.display.MovieClip;
	import net.typoflash.events.CoreEvent;
	
	public interface IPreloader {
		
	
		function onProgress(e:*):void;
		function onComplete(e:*):void;
	}
	
}