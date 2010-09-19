package net.typoflash.base{
	
	/**
	 * All load processes should send CoreEvents,
	 * this is how a frame does it
	 * TF_CONF.CORE.dispatchEvent(new CoreEvent(CoreEvent.ON_LOAD_COMPLETE, e, CoreEvent.LOAD_TYPE_COMPONENT )); 
	 * 
	 * Core sends these info types
	 * CoreEvent.LOAD_TYPE_ASSETS
	 * CoreEvent.LOAD_TYPE_TEMPLATE
	 * CoreEvent.LOAD_TYPE_ASSETS
	 * 
	 * And the data property is normally the QueueLoaderEvent
	 * e.data.bytesLoaded/ e.data.bytesTotal + " = "+e.data.queuepercentage
	 * ...
	 * @author Borg
	 */
	import net.typoflash.events.CoreEvent;
	public class PreloaderBase extends Configurable implements IPreloader{
		
		public function PreloaderBase() {
			TF_CONF.CORE.addEventListener(CoreEvent.ON_LOAD_COMPLETE, onComplete,false,0,true);
			TF_CONF.CORE.addEventListener(CoreEvent.ON_LOAD_PROGRESS, onProgress,false,0,true);
		}
		
		public function onProgress(e:*):void {
			throw new Error("Override onProgress in PreloaderBase")
		}
		public function onComplete(e:*):void {
			throw new Error("Override onComplete in PreloaderBase")
		}		
	}
	
}