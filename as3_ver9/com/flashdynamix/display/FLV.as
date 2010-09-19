package com.flashdynamix.display {
	import com.flashdynamix.abstract.AbstractDisplay;
	import com.flashdynamix.events.FLVEvent;

	import flash.events.*;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.Timer;	

	/**
	 * @author FlashDynamix
	 */
	public class FLV extends AbstractDisplay {
		protected var preloadTimer : Timer;
		protected var seekCheckTimer : Timer;
		protected var progressTimer : Timer;
		protected var netStream : NetStream;
		protected var path : String = "";

		private var _connection : NetConnection;
		private var _playing : Boolean = false;
		private var _seekTimeStamp : Number = 0;
		private var _seekTime : Number = 0;
		private var _duration : Number = -1;
		private var _seeking : Boolean = false;
		private var _meta : Object;
		private var _width : Number;
		private var _height : Number;
		private var video : Video;

		public function FLV(width : int = 320, height : int = 240) {
			super();
			
			video = new Video(width, height);
			preloadTimer = new Timer(100);
			progressTimer = new Timer(100);
			seekCheckTimer = new Timer(100);
			connection = new NetConnection();
			
			this.width = _width = width;
			this.height = _height = height;
			video.smoothing = true;
			
			connection.connect(null);
			
			addEvent(preloadTimer, TimerEvent.TIMER, onLoadCheck);
			addEvent(seekCheckTimer, TimerEvent.TIMER, onSeekedCheck);
			addEvent(progressTimer, TimerEvent.TIMER, onProgressCheck);
			
			addChild(video);
		}

		override public function set width(pixels : Number) : void {
			super.width = pixels;
			_width = pixels;
		}

		override public function get width() : Number {
			return _width;
		}

		override public function set height(pixels : Number) : void {
			super.height = pixels;
			_height = pixels;
		}

		override public function get height() : Number {
			return _height;
		}

		public function get meta() : Object {
			return _meta;
		}

		public function set volume(amount : Number) : void {
			this.soundTransform = new SoundTransform(amount);
		}

		public function get volume() : Number {
			return this.soundTransform.volume;		
		}

		public function set connection(conn : NetConnection) : void {
			if(!conn.connected) conn.connect(null);
			
			netStream = new NetStream(conn);
			
			var client : Object = {};
			client.onMetaData = onMetaData;
			client.onPlayStatus = onPlayStatus;
			client.onBWCheck = onBWCheck;
			client.onBWDone = onBWDone;
			
			netStream.client = client;
			netStream.bufferTime = 4;
			
			_connection = conn;
		}

		public function get connection() : NetConnection {
			return _connection;
		}

		public function get seeking() : Boolean {
			return _seeking;
		}

		public function get time() : Number {
			if(netStream == null) return 0;
			return netStream.time;
		}

		public function get duration() : Number {
			return _duration;
		}

		public function get finished() : Boolean {
			return (duration > 0 && (Math.abs(duration - time) < 0.5 || time >= duration));
		}

		public function set position(value : Number) : void {
			seek(value * duration);
		}

		public function get position() : Number {
			return Math.max(0, Math.min(1, time / duration));
		}

		public function get progress() : Number {
			if(bytesLoaded < 10 || bytesTotal < 10) return 0;
			
			return bytesLoaded / bytesTotal;
		}

		public function get buffered() : Boolean {
			return ((bufferLength / bufferTime) == 1);
		}

		public function set bufferTime(secs : Number) : void {
			netStream.bufferTime = secs;
		}

		public function get bufferTime() : Number {
			return netStream.bufferTime;
		}

		public function get bufferLength() : Number {
			return netStream.bufferLength;
		}

		public function get bytesLoaded() : Number {
			return netStream.bytesLoaded;
		}

		public function get bytesTotal() : Number {
			return netStream.bytesTotal;
		}

		public function get loaded() : Boolean {
			return bytesLoaded == bytesTotal;
		}

		override public function set soundTransform(transform : SoundTransform) : void {
			netStream.soundTransform = transform;
		}

		override public function get soundTransform() : SoundTransform {
			return netStream.soundTransform;
		}

		public function get playing() : Boolean {
			return _playing;
		}

		public function preload(flvPath : String) : void {
			preloadTimer.start();
			
			play(flvPath);
			pause();
		}

		public function play(flvPath : String) : void {
			addListeners();
			
			attach();
			_seeking = false;
			_playing = true;
			_duration = -1;
			path = flvPath;
			
			netStream.play(flvPath);
		}

		public function pause() : void {
			if(!_playing) return;
			
			_playing = false;
			
			progressTimer.stop();
			
			netStream.pause();
		}

		public function resume() : void {
			if(_playing) return;
			
			_playing = true;
			
			progressTimer.start();
			
			netStream.resume();
		}

		public function seek(offset : Number) : void {
			_seekTimeStamp = this.time;
			_seekTime = offset;
			_seeking = (offset > 0);
			
			netStream.seek(offset);

			seekCheckTimer.start();
			
			addListeners();
		}

		public function seekAndResume(offset : Number) : void {
			resume();
			seek(offset);
		}

		public function dettach() : void {
			video.attachNetStream(null);
		}

		public function attach() : void {
			video.attachNetStream(netStream);
		}

		public function stop() : void {
			_playing = false;
			
			netStream.close();
			
			video.clear();
		}

		protected function onAsyncError(event : AsyncErrorEvent) : void {
		}

		protected function addListeners() : void {
			removeListeners();
			progressTimer.start();
			addEvent(netStream, NetStatusEvent.NET_STATUS, onNetStatus);
			addEvent(netStream, AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
		}

		protected function removeListeners() : void {
			progressTimer.stop();
			addEvent(netStream, NetStatusEvent.NET_STATUS, onNetStatus);
			addEvent(netStream, AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
		}

		protected function onNetStatus(event : NetStatusEvent) : void {
			switch(event.info.code) {
				case "NetStream.Play.StreamNotFound" :
					trace(event.info.code + " : " + path);
					break;
				case "NetStream.Buffer.Empty" :
					dispatchEvent(new FLVEvent(FLVEvent.BUFFER_EMPTY));
					break;
				case "NetStream.Buffer.Full" :
					dispatchEvent(new FLVEvent(FLVEvent.BUFFER_FULL));
					break;
				case "NetStream.Play.Stop" :
					break;
				case "NetStream.Play.Start" :
					dispatchEvent(new FLVEvent(FLVEvent.PLAY_START));
					break;
				case "NetStream.Seek.Notify" :
					break;
				case "NetStream.Seek.InvalidTime" :
					seek(event.info.details);
					break;
			}
		}

		protected function onSeekedCheck(event : TimerEvent) : void {
			if(this.time != _seekTimeStamp && this.time > _seekTime) {
				seekCheckTimer.stop();
				_seeking = false;
				dispatchEvent(new FLVEvent(FLVEvent.SEEKED));
			}
		}

		protected function onLoadCheck(event : TimerEvent) : void {
			if(loaded) {
				preloadTimer.stop();
				dispatchEvent(new FLVEvent(FLVEvent.LOADED));
			}
		}

		protected function onProgressCheck(event : TimerEvent) : void {
			if(finished) {
				removeListeners();
				dispatchEvent(new FLVEvent(FLVEvent.PLAY_COMPLETE));
			}
		}

		protected function onMetaData(info : Object) : void {
			_meta = info;
			
			_duration = info.duration;
			
			width = info.width;
			height = info.height;
			
			dispatchEvent(new FLVEvent(FLVEvent.META_LOADED));
		}

		protected function onPlayStatus(info : Object) : void {
		}

		protected function onBWCheck(bandwidth : Number) : void {
			_connection.client.bandwidth = bandwidth;
		}

		protected function onBWDone() : void {
		}

		override public function destroy() : void {
			if(destroyed) return;
			
			super.destroy();
			
			stop();
			
			removeEvent(netStream, NetStatusEvent.NET_STATUS, onNetStatus);
			removeEvent(netStream, AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
			removeEvent(preloadTimer, TimerEvent.TIMER, onLoadCheck);
			removeEvent(seekCheckTimer, TimerEvent.TIMER, onSeekedCheck);
			removeEvent(progressTimer, TimerEvent.TIMER, onProgressCheck);
			preloadTimer.stop();
			progressTimer.stop();
			seekCheckTimer.stop();
			
			netStream = null;
			_connection = null;
			preloadTimer = null;
			progressTimer = null;
			seekCheckTimer = null;
		}
	}
}	