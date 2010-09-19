package {
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import gs.TweenLite;
	import gs.easing.*;
	import net.typoflash.events.ReaderEvent;
	import net.typoflash.events.RenderingEvent;
	import flash.display.Sprite;
	import flash.display.Loader;
	import net.typoflash.components.news.NewsReader;
	
	import flash.net.URLRequest;
	import net.typoflash.utils.Debug;
	import net.typoflash.components.Skinnable;	
	import flash.text.TextFormat;
	import flash.text.Font;
	import gs.plugins.*;
    import flash.net.navigateToURL;
    import flash.net.URLRequest;
	import fl.video.FLVPlayback;
	import fl.video.VideoEvent;

	import com.flashdynamix.data.YouTubeVideoInfo;
	import com.flashdynamix.display.FLV;
	import com.flashdynamix.display.Poller;
	import com.flashdynamix.events.FLVEvent;
	import com.flashdynamix.events.YouTubeEvent;
	import com.flashdynamix.services.YouTubeAPI;
	/**
	 * ...
	 * @author A. Borg
	 */
	public class HaveAVideoPlayer extends Skinnable{
		public var youTubeDataAPI : YouTubeAPI;
		public var reader:NewsReader;
		public var fullscreenBtn:MovieClip;
		public var videoHolder:Sprite;
		//public var seekBar:SeekBar;
		public var player:*;

		private var _playerState:int=0;//1: play, 2: pause,3:loading, 5:stop
		private var _prescrollState:int;
		private var videoInfo:YouTubeVideoInfo;
		//playList
		private var _playlist:Array;
		private var _autoplay:Boolean = false;
		private var _pausedAt:Number=0;
		public var handleMargin:int = 7;
		public var videoBrowser:Sprite;//contains buttns to load each video

		
		public function HaveAVideoPlayer(_reader) 	{
			reader = _reader;
			youTubeDataAPI = new YouTubeAPI();
			youTubeDataAPI.addEventListener(YouTubeEvent.COMPLETE, onVideoLoaded);
			youTubeDataAPI.addEventListener(YouTubeEvent.ERROR, onVideoError);
		}
		override protected function setUpSkin(e:RenderingEvent) {
			
				

			skin.playlistBtn.visible = false;	
			skin.playBtn.addEventListener(MouseEvent.CLICK, togglePause);
			skin.playBtn.buttonMode = true;
			skin.seekBar.handle.addEventListener(MouseEvent.MOUSE_DOWN, startScrub,false,0,true);

			//
			skin.seekBar.handle.buttonMode = true;
			videoHolder = new Sprite();
			videoHolder.addEventListener(MouseEvent.MOUSE_OVER, showControl,false,0,true);
			videoHolder.addEventListener(MouseEvent.MOUSE_OUT, hideControl,false,0,true);
			//videoHolder.y = 100;


	
			
			addChildAt(videoHolder,0)
		}	
		
		override public function setSize(w:int, h:int):void {

			skin.playBtn.width = 100;
			skin.playBtn.scaleY = skin.playBtn.scaleX;
			skin.playBtn.y = h / 2;
			skin.playBtn.x = w / 2;
			var seekMargin = 3;
			skin.seekBar.y = h-skin.seekBar.bg.height - seekMargin;
			skin.seekBar.x = seekMargin;
			skin.seekBar.bg.width = w - 2 * seekMargin;
			videoHolder.graphics.clear();
			videoHolder.graphics.beginFill (0xFFFFFF,1);
			videoHolder.graphics.lineStyle (0, 0x333333, .3);
			videoHolder.graphics.moveTo (0, 0);
			videoHolder.graphics.lineTo (w, 0);
			videoHolder.graphics.lineTo (w, h);
			videoHolder.graphics.lineTo (0, h);
			videoHolder.graphics.endFill();
			//videoHolder.mouseEnabled = false;			

			if(videoBrowser){
				videoBrowser.y = -videoBrowser.height - 2;
				videoBrowser.x = w - videoBrowser.width;
			}
			super.setSize(w, h);
		}
		
		public function togglePause(e:MouseEvent) {
			if (playerState == 2 || playerState == 5) {
				if (player is FLV && videoInfo) {
					Debug.output("is FLV position " + FLV(player).time)
					if (!FLV(player).playing && FLV(player).time>0) {
						FLV(player).resume();
					}else{	
						FLV(player).play(youTubeDataAPI.getVideoUrl(videoInfo.id, videoInfo.token));
					
					}
					//}
				}
				
				if (player is FLVPlayback) {
					player.play();
				}
				playerState = 1;

			}  else if (playerState == 1){
				if (player is FLV) {
					//if (!SkinlessPlayer(player).video.playing || SkinlessPlayer(player).video.finished) {
						_pausedAt = FLV(player).position;
						Debug.output("_pausedAt " +_pausedAt)
						FLV(player).pause();
					//}
				}  
			   
				if (player is FLVPlayback) {
					FLVPlayback(player).stop();
				}
				playerState = 2;
			}
		}
		
		private function showControl(e:MouseEvent) {
				skin.alpha = 1;
				TweenLite.killTweensOf(skin);
		}
		private function hideControl(e:MouseEvent) {
			if(_playerState == 1 && !videoHolder.hitTestPoint(e.stageX,e.stageY)){
				//skin.alpha = .2;
				TweenLite.to(skin, 1, {alpha:0});
				
			}
		}	
		
		private function startScrub(e:MouseEvent) {
			skin.seekBar.handle.startDrag(false, new Rectangle(0,0,skin.seekBar.bg.width,0));
			//addEventListener(Event.ENTER_FRAME, seekPosition, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopScrub);
			_prescrollState = _playerState;
			playerState = 4;
		}
		private function stopScrub(e:MouseEvent) {
			skin.seekBar.handle.stopDrag();
			//removeEventListener(Event.ENTER_FRAME, seekPosition);	
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopScrub);
			seekPosition(e);
			playerState = _prescrollState;
		}
		private function seekPosition(e:Event) {
			var fraction = skin.seekBar.handle.x / skin.seekBar.bg.width;
			var pos = fraction * duration;
			seekTo(pos);
		}
		private function updateScrubber(e:Event) {
			if (player is FLV) {
				var fraction = FLV(player).position;
				skin.seekBar.progressBar.width = FLV(player).progress*skin.seekBar.bg.width
			}else{
				fraction = position / duration;
			}
			skin.seekBar.handle.x = fraction * skin.seekBar.bg.width;
		}
		public function seekTo(pos:Number) {
			if (player is FLV) {
					//if (!SkinlessPlayer(player).video.playing || SkinlessPlayer(player).video.finished) {
						FLV(player).seekAndResume(pos)
						Debug.output("seekTo " +pos)
					//}
			}else if (player is FLVPlayback) {
				FLVPlayback(player).seek(pos);
			}
		}
		
		public function get duration():Number {
			if (player is FLV) {
				return FLV(player).duration;
			}else if(player is FLVPlayback) {
				return FLVPlayback(player).totalTime;
			}
			return 0;
		}
		public function get position():Number {
			if (player is FLV) {
				return FLV(player).time;
			}else if(player is FLVPlayback) {
				return FLVPlayback(player).playheadTime;
			}
			return 0;
		}
		/**
		 * Video link formats
		 * TED      	http://video.ted.com/talks/dynamic/BarrySchwartz_2005G-medium.flv
		 * Fora    		http://fora.tv/embedded_player?webhost=fora.tv&clipid=969&cliptype=full
		 * YouTube 		http://www.youtube.com/watch?v=_nNJM0kKrDQ
		 * Google		http://video.google.com/videoplay?docid=1122532358497501036	
		 * Google		http://video.google.com/googleplayer.swf?docid=" + token + "&hl=en&fs=true
		 * Vimeo		http://vimeo.com/moogaloop.swf?clip_id=6568699&amp;server=vimeo.com&amp;
		 * 				show_title=1&amp;show_byline=1&amp;show_portrait=0&amp;color=&amp;fullscreen=1
		 * Blip			http://blip.tv/play/Adb1EJDaNg
		 * 
If you go to Google Video, you can get a code that allows you to embed a video into your site. Although Google doesn't mention that, the Flash player used by Google Video (googleplayer.swf) lets you customize many parameters. In the code obtained from Google, you'll see in the src attribute: http://video.google.com/googleplayer.swf?docId=[number]&hl=en. You can add more parameters to the player, not just docId and hl. Here are some of the more interesting.

* playerMode lets you change the skin of the player.

playerMode=simple (a basic version of the player without progress bar and volume control, you can see it in the screenshot below)
playerMode=mini (even more basic)
playerMode=clickToPlay (the skin used for video ads)
playerMode=embedded (the standard skin)

* autoPlay lets you control if the video starts automatically.
autoPlay=true
autoPlay=false (by default)

* loop lets you repeat a video indefinitely.
loop=true
loop=false (by default)

* showShareButtons is useful if you want to add a button at the end of the video that says "Send link to a friend".
showShareButtons=true
showShareButtons=false (by default)

So here's one of example of customized player, that repeats a video and shows a simplified skin:
http://video.google.com/googleplayer.swf?docId=[number] &loop=true&playerMode=simple


		 */

		
		function loadVideo(vidId:int = 0) {
			
			destroyPlayer() 
			pattern = /\n|\s/g;
			_playlist[vidId] = _playlist[vidId].replace(pattern, '');//remove breaks
			var pattern:RegExp = /(\.flv|video.google.com\/videodownload)/;
			var result = pattern.exec(_playlist[vidId]);
			if( Boolean(result)){
				player = new FLVPlayback();
				//player.skinBackgroundColor = 0x666666;
				//player.skinBackgroundAlpha = 0.5;
				//player.width = playerWidth;
				//player.height=playerHeight;
				FLVPlayback(player).autoPlay = _autoplay;
				
				FLVPlayback(player).addEventListener(VideoEvent.READY, onVideoLoaded, false, 0, true);
				addEventListener(Event.ENTER_FRAME,checkFLVloadProgress, false, 0, true);
				FLVPlayback(player).addEventListener(VideoEvent.STATE_CHANGE, onFLVPlaybackState, false, 0, true);
				player.source = _playlist[vidId];
				
			}
			//change google url to embedded 
			pattern = /video.google.com\/videoplay\?docid=/;
			result = pattern.exec(_playlist[vidId]);
			if( Boolean(result)){
				_playlist[vidId] = _playlist[vidId].replace(pattern, "video.google.com/googleplayer.swf?docid=");
				_playlist[vidId] = _playlist[vidId] +	"&playerMode=mini&autoPlay=true&scaleMode=noScale&width=300&height=200";
			}
			pattern = /(\.swf\?)/;
			result = pattern.exec(_playlist[vidId]);
			if( Boolean(result)){
				var request:URLRequest = new URLRequest(_playlist[vidId]);
				player = new Loader();
			//splayer.width = playerWidth;
			//splayer.height=playerHeight;
				Loader(player).contentLoaderInfo.addEventListener(Event.COMPLETE, onVideoLoaded, false, 0, true);
				player.load(request);
			}
			pattern = /youtube.com\/watch\?v=[^&]*/;
			result = pattern.exec(_playlist[vidId]);
			if ( Boolean(result)) {
				var token = String(result).split("=")[1]
				player = new FLV(width,height);
				player.addEventListener(FLVEvent.META_LOADED, onYTMeta);
				player.addEventListener(FLVEvent.PLAY_START, onYTPlayStart);
				player.addEventListener(FLVEvent.PLAY_COMPLETE, onYTPlayComplete);
				player.addEventListener(FLVEvent.BUFFER_EMPTY, onYTBufferEmpty);
				player.addEventListener(FLVEvent.BUFFER_FULL, onYTBufferFull);
				youTubeDataAPI.getVideoToken(token);

				//player.setSize(width,height);
			}
			if (player) {
				
				videoHolder.addChild(player);
				TweenLite.to(videoHolder, 1, {dropShadowFilter:{blurX:5, blurY:5, distance:5, alpha:0.6}});

			}
			skin.playBtn.gotoAndStop("pending");
			Debug.output("Load video " +	_playlist[vidId]);
		}
		
		private function checkFLVloadProgress(e:*) {
			skin.seekBar.progressBar.width = FLVPlayback(player).bytesLoaded/FLVPlayback(player).bytesTotal*skin.seekBar.bg.width
		}
		private function onVideoLoaded(e:*) {
			Debug.output("onVideoLoaded " );
			/*for each(var n in e.target) {
				trace(n)
			}*/
			if (e is YouTubeEvent) {
				//player.setSize(width,height);
				videoInfo = e.data as YouTubeVideoInfo;
				//trace("_playerState YouTubeEvent start not? "+_playerState )
				//if (_playerState != 0) {
					//do no autoplay first load
					player.play(youTubeDataAPI.getVideoUrl(videoInfo.id, videoInfo.token));
					//playerState = 1;
				//}else {
					//playerState = 2;
				//}
			}else if(player is FLVPlayback){
				
				var prop = FLVPlayback(player).height / FLVPlayback(player).width;
				FLVPlayback(player).width = width;
				FLVPlayback(player).height = width*prop;
				setSize(width, width * prop);			
				removeEventListener(Event.ENTER_FRAME, checkFLVloadProgress);
				
				if (_playerState == 0) {
					//do no autoplay on first load
					_autoplay  = true;
				}

			}
			//player.width = playerWidth;
			//player.height = playerHeight;
			//videoHolder.x = 230 - player.width / 2;
			//videoHolder.x = 60 ;
			
			
			skin.seekBar.progressBar.width = skin.seekBar.bg.width
		}
		function loadVideoClick(e:MouseEvent) {
			loadVideo(e.target["video"])
		}		
		
		function onVideoError(e:Event) {
			Debug.output("onVideoError " +e);
		}
		
		public function destroy() {
			trace("videoplayer destroyed")
			try {
				playlist = [];
				destroyPlayer() 
				youTubeDataAPI = null;
			}
			catch (e:Error)
			{
				
			}

		}	
		
		public function destroyPlayer() {
			if (player) {
				_pausedAt = 0;
				youTubeDataAPI.stopAll();

				if (player is FLVPlayback) {
					
					FLVPlayback(player).stop();
					player.source = null;
				}
				
				if (player is Loader) {
					try{
						player["unloadAndStop"]();
					}catch (e:Error)
					{
						trace("destroyPlayer error unloadandstop"+e);
					}
					player.unload();
				}
				if (player is FLV) {
					FLV(player).destroy();
				}
				try{
					player.destroy();
				}
				catch (e:Error)	{
					trace("destroyPlayer error destroy" + e);
				}
				videoHolder.removeChild(player);
			
				player = null;
			}
		}		
		private function onFLVPlaybackState(e:VideoEvent) {
			//trace("onFLVPlaybackState " + e.state);
			if (e.state == "buffering" || e.state == "seeking") {
				playerState = 3;
			}else if (e.state == "playing") {
				playerState = 1;
			}else if (e.state == "stopped") {
				playerState = 5;
			}
		}
		public function get playlist():Array { return _playlist; }
		
		public function set playlist(value:Array):void {
			_playlist = value;
			var PlaylistBtnClass:Class = Object(skin.playlistBtn).constructor;
			if (_playlist.length > 1) {
				videoBrowser = new Sprite();
				var btn;
				var iw = 0
				for (var i = 0; i < _playlist.length;i++ ) {
					btn = new PlaylistBtnClass();
					btn.video = i;
					btn.buttonMode = true;
					btn.addEventListener(MouseEvent.CLICK, loadVideoClick, false, 0, true);
					btn.x = (btn.bg.width + 2) * i + iw;
					btn.label.text = String((i+1));
					
					if(reader.textFormats[1]){
						reader.textFormats[1].size = 10
						reader.textFormats[1].color = 0xFFFFFF;
						btn.label.setTextFormat(reader.textFormats[1]);
					}		
					
					btn.mouseChildren=false
					videoBrowser.addChild(btn);
				}
				videoBrowser.y = -videoBrowser.height - 2;
				videoBrowser.x = width - videoBrowser.width;
				addChild(videoBrowser);
				//skin.bodyTxt.y =height  ;
			}else if (videoBrowser) {
				removeChild(videoBrowser);
				videoBrowser = null;
				
			}
			
		}
		
		public function get playerState():int { return _playerState; }
		//1: play, 2: pause,3:loading,4:scrubbing, 5:stop
		public function set playerState(value:int):void {
			_playerState = value;
			if (_playerState == 1)      {
			   skin.playBtn.gotoAndStop("pause");
			   addEventListener(Event.ENTER_FRAME, updateScrubber, false, 0, true);
			} else if (_playerState == 3){
			   skin.playBtn.gotoAndStop("pending");
				if (hasEventListener(Event.ENTER_FRAME)) {
					removeEventListener(Event.ENTER_FRAME, updateScrubber);
				}   
			} else if (_playerState == 4){
			   skin.playBtn.gotoAndStop("pending");
				if (hasEventListener(Event.ENTER_FRAME)) {
					removeEventListener(Event.ENTER_FRAME, updateScrubber);
				}   		
			}else if (_playerState == 0 && duration > 0){
				skin.playBtn.gotoAndStop("pending");
				if (hasEventListener(Event.ENTER_FRAME)) {
					removeEventListener(Event.ENTER_FRAME, updateScrubber);
				}			
			}else {
				skin.playBtn.gotoAndStop("playing");
			}
		
			
		}
		private function onYTBufferEmpty(event : FLVEvent) : void {
			if (!player.playing || player.finished) return;
			//_prescrollState = _playerState;
			playerState = 3;
		}
		
		private function onYTBufferFull(event : FLVEvent) : void {
			//trace("onYTBufferFull")
			playerState = 1;
		}
		private function onYTPlayStart(event : FLVEvent) : void {
			playerState = 1;
		}
		private function onYTPlayComplete(event : FLVEvent) : void {
			playerState = 5;
		}
		private function onYTMeta(event : FLVEvent) : void {
			var prop = player.meta.height / player.meta.width;
			FLV(player).width = width;
			FLV(player).height = width*prop;
			setSize(width, width * prop);
			if (!_autoplay) {
				//do no autoplay first load
				FLV(player).seek(50);
				FLV(player).stop();
				playerState = 2;
				//do no autoplay on first load
				//but to load meta need to ask for some info
				_autoplay  = true;
			}
		}	
	}
	
}