package net.typoflash.components.twitter 
{
	import flash.display.MovieClip;
	import net.typoflash.components.reader.AbstractItem;
	import net.typoflash.components.reader.AbstractReader;	
	import net.typoflash.datastructures.TFNewsItem;
	import net.typoflash.events.RenderingEvent;
	import flash.events.MouseEvent;
	import twitter.api.data.TwitterStatus;
	import flash.display.Sprite;

	
	/**
	 * ...
	 * @author A. Borg
	 */
	public class TwitterItem extends AbstractItem	{

		
		public function TwitterItem(_reader:AbstractReader,o) {
			super(_reader,o);
			for (var n in o) {
				trace("public var " + n + ":String;")
			}

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