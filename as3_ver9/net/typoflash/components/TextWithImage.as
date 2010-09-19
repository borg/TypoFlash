package net.typoflash.components {
	import flash.events.Event;
	import net.typoflash.base.ComponentBase;
	import net.typoflash.events.GlueEvent;
	import net.typoflash.utils.Debug;
	/**
	 * ...
	 * @author A. Borg
	 */
	public class TextWithImage extends ComponentBase{
		public var hasRendered:Boolean=false;//hack in Dubai. Not sure which data event to listen to.
		public function TextWithImage() {
			TF_GLUE.addEventListener(GlueEvent.ON_DATA, onGlueData);//fires two times, once when data arrived and when added to stage. 
			//addEventListener(Event.ADDED_TO_STAGE,init,false,-100,true)
		}
		
		protected function init(e:GlueEvent) {
			//Debug.output(TF_GLUE.data.CONTENT.records[0]);
			//render()
		}	
		protected function onGlueData(e:GlueEvent) {
			//Debug.output(TF_GLUE.data.CONTENT.records[0]);
			if(!hasRendered){
				render()
			}
			hasRendered = true;
		}
		
		/*
		 * Override.
		 * All data is in the TF_GLUE.data.CONTENT property, and individual records expanded in the array
		 */ 
		protected function render() {
			
		}
	}
	
}