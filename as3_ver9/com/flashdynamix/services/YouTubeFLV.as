/*	
.__       _____   ____    ______      ______   __  __     
/\ \     /\  __`\/\  _`\ /\__  _\    /\__  _\ /\ \/\ \    
\ \ \    \ \ \/\ \ \,\L\_\/_/\ \/    \/_/\ \/ \ \ `\\ \   
.\ \ \  __\ \ \ \ \/_\__ \  \ \ \       \ \ \  \ \ , ` \  
..\ \ \L\ \\ \ \_\ \/\ \L\ \ \ \ \       \_\ \__\ \ \`\ \ 
...\ \____/ \ \_____\ `\____\ \ \_\      /\_____\\ \_\ \_\
....\/___/   \/_____/\/_____/  \/_/      \/_____/ \/_/\/_/
	                                                          
	                                                          
.______  ____    ______  ______   _____   __  __  ____    ____     ____    ______   ____    ______   
/\  _  \/\  _`\ /\__  _\/\__  _\ /\  __`\/\ \/\ \/\  _`\ /\  _`\  /\  _`\ /\__  _\ /\  _`\ /\__  _\  
\ \ \L\ \ \ \/\_\/_/\ \/\/_/\ \/ \ \ \/\ \ \ `\\ \ \,\L\_\ \ \/\_\\ \ \L\ \/_/\ \/ \ \ \L\ \/_/\ \/  
.\ \  __ \ \ \/_/_ \ \ \   \ \ \  \ \ \ \ \ \ , ` \/_\__ \\ \ \/_/_\ \ ,  /  \ \ \  \ \ ,__/  \ \ \  
..\ \ \/\ \ \ \L\ \ \ \ \   \_\ \__\ \ \_\ \ \ \`\ \/\ \L\ \ \ \L\ \\ \ \\ \  \_\ \__\ \ \/    \ \ \ 
...\ \_\ \_\ \____/  \ \_\  /\_____\\ \_____\ \_\ \_\ `\____\ \____/ \ \_\ \_\/\_____\\ \_\     \ \_\
....\/_/\/_/\/___/    \/_/  \/_____/ \/_____/\/_/\/_/\/_____/\/___/   \/_/\/ /\/_____/ \/_/      \/_/

    
Copyright (c) 2008 Lost In Actionscript - Shane McCartney

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

 */
package com.flashdynamix.services {
	import com.flashdynamix.data.YouTubePlayerErrorCode;
	import com.flashdynamix.data.YouTubePlayerStateCode;
	import com.flashdynamix.events.*;

	import flash.display.BlendMode;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.media.SoundTransform;
	import flash.net.LocalConnection;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.system.Security;
	import flash.utils.setTimeout;	

	public class YouTubeFLV extends Sprite {

		private static const PLAYER_LOADED : String = "onYouTubePlayerLoaded";
		private static const ON_STATE_CHANGE : String = "onStateChange";
		private static const ON_ERROR : String = "onError";
		private static const MOVIE_STATE_UPDATE : String = "onMovieStateUpdate";
		private static const MOVIE_PROGRESS : String = "onMovieProgress";

		private static var count : int = 0;

		private var playerId : String = "";
		private var localConn : LocalConnection;
		private var loader : Loader;
		private var inBrowser : Boolean;
		private var hasJavascript : Boolean;

		private var _chromeless : Boolean = false;
		private var _width : Number = 320;
		private var _height : Number = 240;
		private var _videoBytesLoaded : Number = 0;
		private var _videoBytesTotal : Number = 0;
		private var _videoStartBytes : Number = 0;
		private var _muted : Boolean = false;
		private var _paused : Boolean = false;
		private var _volume : Number = 100;
		private var _playerState : int = -1;
		private var _currentTime : Number = 0;
		private var _duration : Number = 0;
		private var _videoUrl : String = "";
		private var _videoEmbedCode : String;
		private var _videoId : String = "";
		private var _seeking : Boolean = false;
		private var _ready : Boolean = false;
		private var _enabled : Boolean = false;
		private var _started : Boolean = false;
		private var seekTime : Number;
		private var playerWrapperUrl : String = "youTubePlayerBridge.swf";

		public function YouTubeFLV(videoId : String = "", chromeless : Boolean = true) {
			Security.allowDomain("*");
			
			inBrowser = (Capabilities.playerType == "PlugIn" || Capabilities.playerType == "ActiveX");
			if(ExternalInterface.available) hasJavascript = ExternalInterface.call("isExternalAvailable") == true;
			
			this.blendMode = BlendMode.LAYER;
			_videoId = videoId;
			_chromeless = chromeless;
			_width = width;
			_height = height;
			
			if(inBrowser && hasJavascript) {
				ExternalInterface.addCallback("recieveAS3", onConnectionEvent);			
			} else {
				hasJavascript = inBrowser = false;
				
				localConn = new LocalConnection();
				localConn.client = this;
				localConn.allowDomain("*");
				localConn.addEventListener(StatusEvent.STATUS, onConnectionStatus);
				localConn.connect("ytas3");
			}
			
			initPlayer();
		}

		public function seek(secs : Number, allowSeekAhead : Boolean = true) : void {
			var event : Object = {
				seconds:secs, allowSeekAhead:allowSeekAhead
			};
			_seeking = true;
			seekTime = _currentTime;
			callAS2Method("seekTo", event);
		}

		public function seekAndResume(secs : Number, allowSeekAhead : Boolean = true) : void {
			play();
			seek(secs, allowSeekAhead);
		}

		public function unMute() : void {
			_volume = 1;
			this.soundTransform = new SoundTransform(_volume);
			
			callAS2Method("unMute");
		}

		public function mute() : void {
			_volume = 0;
			this.soundTransform = new SoundTransform(_volume);
			
			callAS2Method("mute");
		}

		public function clear() : void {
			callAS2Method("clear");
		}

		public function setSize(width : Number, height : Number) : void {
			var event : Object = {
				width:width, height:height
			};
			_width = width;
			_height = height;
			
			callAS2Method("setSize", event);
		}

		public function loadById(videoId : String, startSeconds : Number = 0) : void {
			_videoId = videoId;
			_paused = false;
			_started = false;
			
			var event : Object = {
				videoId:videoId, startSeconds:startSeconds, chromeless:_chromeless
			};

			callAS2Method("loadById", event);
		}

		public function cueById(videoId : String, startSeconds : Number = 0) : void {
			_videoId = videoId;
			_paused = false;
			
			var event : Object = {
				videoId:videoId, startSeconds:startSeconds
			};
			
			callAS2Method("cueById", event);
		}

		public function stop() : void {
			callAS2Method("stop");
		}

		public function play() : void {
			_paused = false;
			callAS2Method("play");
		}

		public function resume() : void {
			play();
		}

		public function pause() : void {
			_paused = true;
			callAS2Method("pause");
		}

		public function togglePause() : void {
			if(_paused) {
				play();
			} else {
				pause();
			}
		}

		public function set enabled(flag : Boolean) : void {
			_enabled = flag;
			this.mouseEnabled = this.mouseChildren = flag;
		}

		public function get enabled() : Boolean {
			return _enabled;
		}

		public function get ready() : Boolean {
			return _ready;
		}

		public function set position(amount : Number) : void {
			seek(_duration * amount);
		}

		public function get position() : Number {
			if(_duration <= 0) return 0;
			return _currentTime / _duration;
		}

		public function set volume(amount : Number) : void {
			var event : Object = {
				volume:int(amount * 100)
			};
			_volume = amount;
			
			this.soundTransform = new SoundTransform(amount);
			
			callAS2Method("setVolume", event);
		}

		override public function set width(pixels : Number) : void {
			_width = pixels;
			setSize(_width, _height);
		}

		override public function get width() : Number {
			return _width;
		}

		override public function set height(pixels : Number) : void {
			_height = pixels;
			setSize(_width, _height);
		}

		override public function get height() : Number {
			return _height;
		}

		public function get volume() : Number {
			return _volume;
		}

		public function get currentTime() : Number {
			return _currentTime;
		}

		public function get duration() : Number {
			return _duration;
		}

		public function get videoUrl() : String {
			return _videoUrl;
		}

		public function get videoEmbedCode() : String {
			return _videoEmbedCode;
		}
		public function get playerState() : int {			return _playerState;
		}
		public function get videoBytesLoaded() : Number {			return _videoStartBytes + _videoBytesLoaded;		}
		public function get videoBytesTotal() : Number {			return _videoBytesTotal;		}
		public function get muted() : Boolean {			return _muted;		}
		public function get videoId() : String {			return _videoId;		}

		public function get progress() : Number {
			if(_videoBytesTotal <= 0) return 0;
			
			return ((_videoStartBytes + _videoBytesLoaded) / _videoBytesTotal);		}

		public function get paused() : Boolean {
			return _paused;
		}

		public function get loaded() : Boolean {
			return (progress == 1);
		}

		public function get ratio() : Number {
			return (_width / _height);
		}

		public function get buffering() : Boolean {
			return (playerState == YouTubePlayerStateCode.BUFFERING);
		}

		public function get seeking() : Boolean {
			return _seeking;
		}

		public function onConnectionEvent(event : Object) : void {
			if(event.playerId != playerId) return;
			
			switch(event.eventName) {
				case PLAYER_LOADED:
					setTimeout(onPlayerLoaded, 50);
					break;
				case ON_ERROR:
					onError(event);
					break;
				case ON_STATE_CHANGE:
					onStateChange(event);
					break;
				case MOVIE_PROGRESS:
					onProgress(event);
					break;
				case MOVIE_STATE_UPDATE:
					onStateUpdate(event);
					break;
			}
		}
		
		private function onConnectionStatus(event : StatusEvent) : void {
		}

		private function initPlayer() : void {
			if(loader && contains(loader)) removeChild(loader);
			
			loader = new Loader();
			
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onWrapperIOError);
			loader.contentLoaderInfo.addEventListener(Event.INIT, onWrapperLoaded);
			
			loader.load(new URLRequest(playerWrapperUrl));
		}

		private function onWrapperLoaded(event : Event) : void {
			if(_videoId != "") setTimeout(loadById, 50, _videoId);
			
			dispatchEvent(new YouTubeFLVEvent(YouTubeFLVEvent.WRAPPER_LOADED));
		}

		private function onWrapperIOError(event : IOErrorEvent) : void {
			dispatchEvent(new YouTubeFLVErrorEvent(YouTubeFLVErrorEvent.ERROR, YouTubePlayerErrorCode.PLAYER_WRAPPER_NOT_FOUND));
		}

		private function onPlayerLoaded() : void {
			_ready = true;

			playerId = new Date().time.toString() + (count++).toString();
			callAS2Method("setPlayerId");
			
			setSize(_width, _height);
			dispatchEvent(new YouTubeFLVEvent(YouTubeFLVEvent.PLAYER_LOADED));
			
			addChild(loader);
			
			if(_chromeless && _videoId != "") loadById(_videoId);
		}

		private function onStateChange(event : Object) : void {
			_playerState = event.state;
			
			switch(event.state) {
				case YouTubePlayerStateCode.BUFFERING:
					dispatchEvent(new YouTubeFLVEvent(YouTubeFLVEvent.BUFFERING));
					break;
				case YouTubePlayerStateCode.ENDED:
					_videoBytesLoaded = _videoBytesTotal;
					_currentTime = _duration;
					dispatchEvent(new YouTubeFLVEvent(YouTubeFLVEvent.ENDED));
					break;
				case YouTubePlayerStateCode.PAUSED:
					dispatchEvent(new YouTubeFLVEvent(YouTubeFLVEvent.PAUSED));
					break;
				case YouTubePlayerStateCode.PLAYING:
					dispatchEvent(new YouTubeFLVEvent(YouTubeFLVEvent.PLAYING));
					break;
				case YouTubePlayerStateCode.QUEUED:
					dispatchEvent(new YouTubeFLVEvent(YouTubeFLVEvent.QUEUED));
					break;
				case YouTubePlayerStateCode.UNSTARTED:
					dispatchEvent(new YouTubeFLVEvent(YouTubeFLVEvent.UNSTARTED));
					break;
			}
		}

		private function onStateUpdate(event : Object) : void {
			_videoBytesLoaded = event.videoBytesLoaded;
			_videoBytesTotal = event.videoBytesTotal;
			_videoStartBytes = event.videoStartBytes;
			_muted = event.muted;
			_volume = event.volume / 100;
			_playerState = event.playerState;
			_currentTime = event.currentTime;
			_duration = event.duration;
			_videoUrl = event.videoUrl;
			_videoEmbedCode = event.videoEmbedCode;
					
			dispatchEvent(new YouTubeFLVEvent(YouTubeFLVEvent.STATE_UPDATE));
		}

		private function onProgress(event : Object) : void {
			_currentTime = event.currentTime;
			
			if(!_started && _currentTime > 0) {
				_started = true;
				dispatchEvent(new YouTubeFLVEvent(YouTubeFLVEvent.STARTED));
			}
			
			if(_seeking && Math.abs(_currentTime - seekTime) > 0.1) _seeking = false;
			
			dispatchEvent(new YouTubeFLVEvent(YouTubeFLVEvent.PROGRESS));
		}

		private function onError(event : Object) : void {
			dispatchEvent(new YouTubeFLVErrorEvent(YouTubeFLVErrorEvent.ERROR, event.code));
		}

		private function callAS2Method(name : String, event : Object = null) : void {
			event = (event != null) ? event : {};
			event.playerId = playerId;
			event.eventName = name;
			
			if(inBrowser) {
				ExternalInterface.call("sendToAS2", event);
			} else {
				localConn.send("ytas2", "onConnectionEvent", event);
			}
		}

		private function unloadPlayerSWF() : void {
			callAS2Method("destroy");
			
			loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onWrapperIOError);			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onWrapperLoaded);
			if(localConn) localConn.close();
			loader.unload();
		}
		
		public function destroy() : void {
			stop();
			unloadPlayerSWF();
		}
	}
}