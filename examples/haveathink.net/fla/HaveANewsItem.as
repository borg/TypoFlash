package  
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import net.typoflash.components.news.NewsItem;
	import net.typoflash.datastructures.TFNewsItem;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import gs.TweenLite;
	import gs.easing.*;
	import net.typoflash.events.ReaderEvent;
	import flash.display.Sprite;
	import flash.display.Loader;
	
	import flash.net.URLRequest;
	import net.typoflash.components.youtube.SkinlessPlayer;
	import net.typoflash.utils.Debug;
	import net.typoflash.components.reader.AbstractReader;	
	import flash.text.TextFormat;
	import flash.text.Font;
	import gs.plugins.*;
    import flash.net.navigateToURL;
    import flash.net.URLRequest;
	import fl.video.FLVPlayback;
	import com.flashdynamix.events.YouTubeEvent;
	import flash.text.AntiAliasType;
	/**
	 * Video link formats
	 * TED      	http://video.ted.com/talks/dynamic/BarrySchwartz_2005G-medium.flv
	 * Fora    		http://fora.tv/embedded_player?webhost=fora.tv&clipid=969&cliptype=full
	 * YouTube 		http://www.youtube.com/watch?v=_nNJM0kKrDQ
	 * Google		http://video.google.com/videoplay?docid=1122532358497501036		
	 * Vimeo		http://vimeo.com/moogaloop.swf?clip_id=6568699&amp;server=vimeo.com&amp;
	 * 				show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=&amp;fullscreen=1
	 * Blip			http://blip.tv/play/Adb1EJDaNg
	 * ...
	 * @author A. Borg
	 */
	public class HaveANewsItem extends NewsItem{
		protected var _finHeight;
		public var playerWidth:int = 460;
		public var playerHeight:int = 380;
		public var imageHeight:int = 120;
		public var imageWidth:int = 80;
		public var distance:int = 10;
		
		public var videoPlayer:HaveAVideoPlayer;

		
		
		public var sourceLink:String;
		public var videoList:Array;
		public var icons:Sprite;
		
		public function HaveANewsItem(_reader:AbstractReader,o:TFNewsItem = null) {
			super(_reader, o);
			videoList = [];
			//the detail always remains on stage so this wont run until whole swf unloads
			addEventListener(Event.REMOVED_FROM_STAGE, removed, false, 0, true)
			TweenPlugin.activate([DropShadowFilterPlugin]);	
		}
		
		override public function render() {
			try {
				destroy();
				//updateText();
				skin.titleTxt.text = TFNewsItem(data).title;
				
				skin.titleTxt.mouseEnabled = false;
				
				var str:String = "" ;
				var imgs = TFNewsItem(data).image.split(",");
				for each(var i in imgs) {
					//Debug.output(i)
					if(i != ''){
						str += '<br/><img src="' + TF_CONF.HOST_URL  +'typo3/thumbs.php?size='+imageWidth+'x'+imageHeight+'&file=../uploads/pics/' +i + '" />';

					}
				}	
				

				
				
				str += parseHTMLMarkers(TFNewsItem(data).bodytext);
				parseLinks(TFNewsItem(data).links);
				icons = new Sprite();
				icons.y = 50 + distance;
				skin.addChild(icons);
				if (sourceLink) {
					var linkBtn = new LinkBtn();
					linkBtn.buttonMode = true;
					linkBtn.addEventListener(MouseEvent.CLICK, gotoSource, false, 0, true);
					
					linkBtn.label.mouseEnabled = false;
					if(reader.textFormats[1]){
						reader.textFormats[1].size = 10
						reader.textFormats[1].color = 0x333333;
						linkBtn.label.embedFonts = true;
						linkBtn.label.defaultTextFormat = reader.textFormats[1];
						linkBtn.label.antiAliasType = AntiAliasType.ADVANCED;  
					}
					linkBtn.label.text = "Source";
					icons.addChild(linkBtn);
				}
				
		
				if (videoList.length > 0) {
					videoPlayer = new HaveAVideoPlayer(reader);
					videoPlayer.skin = new HaveAVideoPlayerSkin();
					videoPlayer.playlist = videoList;
					videoPlayer.addEventListener(Event.RESIZE, onVideoResize, false, 0, true);
					videoPlayer.setSize(playerWidth, playerHeight);
					skin.bodyTxt.y = videoPlayer.y+videoPlayer.height+distance;
					videoPlayer.y = icons.y + icons.height + distance*2;
					videoPlayer.loadVideo(0);
					skin.addChild(videoPlayer);
					
				}else{
					skin.bodyTxt.y = icons.y + icons.height + distance;
				}
				//Font.registerFont(TF_CONF.FONT_MANAGER.getFontClass("_Palatino"));
				//var tf:TextField = new TextField();
               
				
             // tf.antiAliasType = AntiAliasType.ADVANCED;
				//skin.bodyTxt.rotation = 15
			
				//var MyFontClass = TF_CONF.FONT_MANAGER.getFontClass("_Palatino");
				//skin.bodyTxt.defaultTextFormat = new MyFontClass()
				//skin.bodyTxt.defaultTextFormat.font
				/*tf.autoSize = TextFieldAutoSize.LEFT;
				tf.multiline = true;
				tf.width = 300;
				tf.htmlText =  str;
				
				skin.addChild(tf);*/
				//skin.bodyTxt.embedFonts = true;
				//skin.titleTxt.embedFonts = true;
				
				skin.bodyTxt.htmlText =  str;

				
				
				//tf.italic = true

				
				skin.bodyTxt.visible = false;
				_finHeight = skin.height + padding;
				height = 38;
				
				TweenLite.to(this, .5, { height:_finHeight, ease:Quad.easeInOut, onComplete:onFinishTween } );	

			}
			catch (e:Error){
				throw new Error("HaveANewsItem render error " +e);
				
			}
			
			
		}
		function gotoSource(e) {
			gotoURL(sourceLink);
		}
		
		public function gotoURL(url:String,targ:String="_blank") {
			var req:URLRequest = new URLRequest(url);
			navigateToURL(req, targ);
		}
		private function onRollIt(e:MouseEvent) {

		}
		private function onRollItOut(e:MouseEvent) {
			//reader.dispatchEvent(new ReaderEvent(ReaderEvent.ON_SET_ACTIVE,data))
		}
		private function onVideoResize(e:Event) {
			//trace("onVideoResize "+videoPlayer.height)
			skin.bodyTxt.y = videoPlayer.y+videoPlayer.height+distance;
		}
		override public function activate() {
			if (_isActive) {
				visible = true;
				render()
				//TweenLite.to(this, .5, { height:_finHeight, ease:Quad.easeInOut, onComplete:onFinishTween } );	
			}else {
				visible = false;
				destroy() 
				//TweenLite.to(this, .5, { height:38, ease:Quad.easeInOut} );	
			}
			
		}
		protected function onFinishTween() {
			skin.bodyTxt.visible = true;
		}
		
		override public function set height(v:Number):void {
			skin.holder.y = v + margin;
			skin.bg.height = v;
		}
		override public function get height():Number {
			return skin.bg.height;
		}	
		
		/*
		 * This function replaces special codes in the text with corresponding flash elements
		 * Actually, now only removes markers
		 */ 
		public function parseHTMLMarkers(txt:String):String {
			/*var image:Sprite = new Sprite();
			image.useHandCursor = image.buttonMode = image.mouseEnabled = true;
			//image.addEventListener(MouseEvent.CLICK, onClick);

			this.addChild(image);
			var loader:Loader = new Loader();
			var request:URLRequest = new URLRequest("http://gdata.youtube.com/apiplayer?key=" + TF_CONF.API_KEY["YOUTUBE_DEV_KEY"]);
			loader.load(request);
			image.addChild(loader);	*/	
			
			
			var youtubeTokens:Array = [];
			var pattern:RegExp = /(\[youtube [^\]]*\])/gm;//first filter out on any character but ], and then include it as closing bracket 
			var result:Array = pattern.exec(txt);
			txt = txt.replace(pattern,'')
			/*var tok:String;
			while (result != null) {
				tok = result[0].split(" ")[1];
				tok = tok.split("]")[0];//remove closing bracket if no space before
				youtubeTokens.push(tok);
				result = pattern.exec(txt);
			}
			
			player = new Sprite();
			player.x = distance;
			player.y = 60;
			for each(var token in youtubeTokens) {
				var splayer = new SkinlessPlayer();
				splayer.loadVideo(token);
				splayer.setSize(playerWidth,playerHeight);
				player.addChild(splayer);
				Debug.output("found youtube "+token)
			}*/
			
			var googleToken:Array = [];
			var gpattern:RegExp = /(\[google [^\]]*\])/gm;//first filter out on any character but ], and then include it as closing bracket 
			result = gpattern.exec(txt);
			txt = txt.replace(gpattern,'')
		/*	while (result != null) {
				tok = result[0].split(" ")[1];
				tok = tok.split("]")[0];//remove closing bracket if no space before
				googleToken.push(tok);
				result = gpattern.exec(txt);
			}
			
	
			for each(token in googleToken) {
			
				Debug.output("found googleToken " + token)
				splayer = new Loader();
				var request:URLRequest = new URLRequest("http://video.google.com/googleplayer.swf?docid=" + token + "&hl=en&fs=true");
				splayer.width = playerWidth;
				splayer.height=playerHeight;
				splayer.load(request);
				player.addChild(splayer);
			}		

			
			if (splayer) {
				skin.addChild(player)
				TweenLite.to(player, 1, {dropShadowFilter:{blurX:5, blurY:5, distance:5, alpha:0.6}});
			}*/
			
	/*		
	$this->codes['ted']	  = '<object width="###WIDTH###" height="###HEIGHT###"><param name="movie" value="http://video.ted.com/assets/player/swf/EmbedPlayer.swf"></param><param name="allowFullScreen" value="true" /><param name="wmode" value="transparent"></param><param name="bgColor" value="#ffffff"></param> <param name="flashvars" value="###VID###" /><embed src="http://video.ted.com/assets/player/swf/EmbedPlayer.swf" pluginspace="http://www.macromedia.com/go/getflashplayer" type="application/x-shockwave-flash" wmode="transparent" bgColor="#ffffff" width="###WIDTH###" height="###HEIGHT###" allowFullScreen="true" flashvars="###VID###"></embed></object>';

		$this->codes['fora']  = '<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=9,0,0,0" width="###WIDTH###" height="###HEIGHT###" ><param name="flashvars" value="webhost=fora.tv&clipid=###VID###&cliptype=clip" /><param name="allowScriptAccess" value="always"  /><param name="allowFullScreen" value="true" /><param name="movie" value="http://fora.tv/embedded_player" /><embed flashvars="webhost=fora.tv&clipid=###VID###&cliptype=clip" src="http://fora.tv/embedded_player" width="###WIDTH###" height="###HEIGHT###" allowScriptAccess="always" allowFullScreen="true" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer"></embed></object>';			
			
			
			*/
			
			
			
			
			
			
			return txt;
		}
		
		function getVideoCode(fUrl:String,propName:String):String  {
			fUrl = fUrl.split("?")[1];
			var _loc3 = unescape(fUrl);
			_loc3 = _loc3.split("&");
			var _loc2;
			var _loc4 = {};
			for (var _loc1 = 0; _loc1 < _loc3.length; ++_loc1)
			{
				_loc2 = _loc3[_loc1].split("=");
				if (_loc2[0] != "")
				{
					_loc4[_loc2[0]] = _loc2[1];
				} // end if
			} // end of for
			return (_loc4[propName]);
		} 	
		

		/*
		 * First link is assumed to be main source for article
		 */
		function parseLinks(txt:String) {
				Debug.output("--------------------links")
				Debug.output(txt);
				Debug.output("--------------------links end")
				var links = txt.split("\n");
				var isVid:Boolean;
				videoList = [];
				for each(var l in links) {
					if (l != '') {
						isVid = isVideo(l);
						if (sourceLink == null && !isVid) {
							sourceLink = String(l);//choose first one to be main link
						}else if (isVid) {
							videoList.push(l)
						}
						//str += '<br/><a href="' + l + '" target="_blank" >Link</a>';
					}
					
				}		
			
		}
		/*
		 *  Check if normal links or video links based on known types
		 */ 
		function isVideo(str:String):Boolean {
			var pattern:RegExp = /(video.ted.com(.*)flv|player\?webhost=fora|youtube.com\/watch\?v=|video.google.com\/videodownload|google.com\/videoplay\?docid|vimeo.com\/moogaloop\.swf\?clip_id|blip\.tv\/play|metacafe.com\/fplayer|swf\?pageToLoad=videoEmbed)/;
			var result = pattern.exec(str);
			return Boolean(result);
			
		}
		
		private function removed(e:Event) {
			destroy();
		}
		public function destroy() {
			trace("news item destroy")
			try {
				sourceLink = null;
				videoList = null;
				if(skin && icons){
					skin.removeChild(icons);	
				}
				if(skin && videoPlayer){
					videoPlayer.removeEventListener(Event.RESIZE, onVideoResize);
					videoPlayer.destroy() 
					skin.removeChild(videoPlayer);
					videoPlayer = null; 
				}
			}
			catch (e:Error)
			{
				Debug.output("HaveANewsItem error "+e)
			}

		}
		
		override public function setDefaultTextFormat() {
			if (reader.textFormats[0]) {
				TextField(skin.titleTxt).embedFonts = true;
				reader.textFormats[0].size = 22
				skin.titleTxt.defaultTextFormat = reader.textFormats[0];
				skin.titleTxt.antiAliasType = AntiAliasType.ADVANCED;  
				
			}
			if (reader.textFormats[1]) {
				/*TextField(skin.bodyTxt).embedFonts = true;
				reader.textFormats[1].size = 10
				reader.textFormats[1].color = reader.colours[0];
				skin.bodyTxt.defaultTextFormat = reader.textFormats[1];*/
				// TODO: Fix embed fonts in htmlText
				
				
			}
			TextField(skin.titleTxt).autoSize = TextFieldAutoSize.LEFT;
			TextField(skin.bodyTxt).autoSize = TextFieldAutoSize.LEFT;
		}
		
	}
	
}