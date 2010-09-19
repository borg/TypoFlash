package net.typoflash.components.news 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import net.typoflash.components.reader.AbstractItem;
	import net.typoflash.components.reader.AbstractReader;
	
	import net.typoflash.datastructures.TFNewsItem;
	import net.typoflash.events.RenderingEvent;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author A. Borg
	 */
	public class NewsItem extends AbstractItem	{

		

		
		public function NewsItem(_reader:AbstractReader,o:TFNewsItem = null){
			super(_reader,o);
		}

	
		
	}
	
}