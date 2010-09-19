package net.typoflash.components.facebook 
{
	
	/**
	 * ...
	 * @author A. Borg
	 */
	
	import flash.events.Event;
	import net.typoflash.base.Configurable;
	import net.typoflash.components.reader.AbstractReader;
	import net.typoflash.events.RenderingEvent;
	import net.typoflash.events.GlueEvent;
	import net.typoflash.ContentRendering;
	import net.typoflash.utils.Debug;
	import flash.display.StageAlign;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.display.Sprite
	import net.typoflash.components.facebook.FacebookPostData;
	import flash.system.Security;
	
	public class FacebookDiscussionReader extends AbstractReader{
		public var GROUP_ID:Number;
		public var TOPIC_ID:Number;
		
		public function FacebookDiscussionReader() 	{

			addEventListener(Event.ADDED_TO_STAGE, addedToStage, false, 0, true);
		}
		protected function addedToStage(e:Event):void {
			if (GROUP_ID && TOPIC_ID) {
				getPosts();
			}

		}	
		
		protected function processDocXML(e:Event) {
			
			var raw:String = e.target.data;
			//trace(raw)
			var discussion = raw.split('<div class="UIWashFrame_Content">')[1];
			discussion = discussion.split('</div><div class="UIWashFrame_SidebarAds">')[0];
			var xmlDoc:XML = new XML(discussion);
			
			var posts = [];
			for each(var n:XML in xmlDoc..div.(attribute("id").toString().indexOf("post_data") == 0)) {
				posts.push(new FacebookPostData(n));
				trace(posts[posts.length-1].author)
			}
			recordset = posts;
			render();
		}	
		
		public function getPosts() {
			var fbURL = escape("topic.php?uid=" + GROUP_ID + "&topic=" + TOPIC_ID)
			
			var request = new URLRequest(TF_CONF['HOST_URL'] + "/typo3conf/ext/flashremoting/lib/facebook/proxy.php?path=" + fbURL);
			trace("Loading from "+TF_CONF['HOST_URL'] + "/typo3conf/ext/flashremoting/lib/facebook/proxy.php?path=" + fbURL)
			/*Security.allowDomain("www.facebook.com")
			var request = new URLRequest("http://www.facebook.com/topic.php?uid="+GROUP_ID+"&topic="+ TOPIC_ID);*/
			var myXML:XML; 
			var myLoader:URLLoader = new URLLoader();
			myLoader.load(request); 

			myLoader.addEventListener(Event.COMPLETE, processDocXML);					
		}
	
	}
	
}