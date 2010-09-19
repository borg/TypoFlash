package net.typoflash.components.facebook 
{
	
	/**
	 * ...
	 * @author A. Borg
	 * 
	 * 
	 * <div id="post_data42614" class="post_data clearfix">
  <div class="info">
    <div>
      <span>
        <img src="http://profile.ak.fbcdn.net/v230/1661/97/t541239879_7268.jpg" alt=""/>
      </span>
    </div>
    <div class="post_index">Post #2</div>
  </div>
  <div class="post_body">
    <div class="post_header clearfix">
      <span class="author_header">
        <strong>Andreas</strong>
        wrote
      </span>
      <span class="timestamp">16 hours ago</span>
    </div>
    <div class="post_message">Did it have anything to do with Elvis?</div>
  </div>
  <ul class="actionspro"/>
</div>

	 */
import net.typoflash.utils.Debug;

	public class FacebookPostData{
		public var author:String;
		public var timestamp:String;
		public var plainMsg:String;
		public var htmlMsg:String;
		public var image:String;
		public var index:String;
		public var uid:String;
			
		
		public function FacebookPostData(o:XML) {
			o.ignoreWhite = true;
			uid = o.(attribute("id").toString().indexOf("post_data") == 0).attribute("id").toString();
			image = o..div.span.img.attribute("src");
			author = o..div.span.(attribute("class") == "author_header").strong.toString();
			timestamp = o..span.(attribute("class") == "timestamp").toString();
			index = o..div.(attribute("class") == "post_index").toString();
			var msgNode:XMLList = o..div.(attribute("class") == "post_message");
			if (msgNode[0].hasComplexContent()) {
				//strip the <div class="post_message"> tag that is otherwise included in complex nodes
				plainMsg = htmlMsg = "";
				for each(var n in msgNode[0].children()){
					htmlMsg += n.toXMLString();	
					plainMsg += n.toString();
					
				}
			}else{
				plainMsg = htmlMsg = msgNode.toString();		
			}
			Debug.output(plainMsg) 
			//replace funny chars
			htmlMsg = htmlMsg.split("’").join("'");
			plainMsg = htmlMsg.split("’").join("'");
			htmlMsg = htmlMsg.split("â€™").join("'");
			plainMsg = htmlMsg.split("â€™").join("'");			
			
		}
		
		
	}
	
}