package net.typoflash.components.facebook 
{
	
	/**
	 * ...
	 * @author A. Borg
	 */
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import net.typoflash.components.reader.AbstractListItem;
	import net.typoflash.components.reader.AbstractReader;
	
	import net.typoflash.datastructures.TFNewsItem;
	import net.typoflash.events.RenderingEvent;
	import flash.events.MouseEvent;
	
	public class FacebookPostItem extends AbstractListItem	{

		
		public function FacebookPostItem(_reader:AbstractReader,o:FacebookPostData){
			super(_reader,o);
		}
		/*
		 * Overrides
		 */
		
		 /*
		 * Check if isOpen and isActive to get right state
		 */ 
		override public function render() {
			_holder.y = _margin+height;
		}
		
	}
	
}