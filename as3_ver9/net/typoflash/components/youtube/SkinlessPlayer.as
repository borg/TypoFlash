package net.typoflash.components.youtube 
{
	
	/**
	 * ...
	 * @author FlashDynamix
	 */

	import com.flashdynamix.data.YouTubeVideoInfo;
	import com.flashdynamix.display.FLV;
	import com.flashdynamix.display.Poller;
	import com.flashdynamix.events.FLVEvent;
	import com.flashdynamix.events.YouTubeEvent;
	import com.flashdynamix.services.YouTubeAPI;

	import flash.display.Sprite;	

	public class SkinlessPlayer extends Sprite {

		public var youTubeDataAPI : YouTubeAPI;
		public var video : FLV;
		public var poller : Poller;

		public function SkinlessPlayer() {
			youTubeDataAPI = new YouTubeAPI();
			video = new FLV(320, 240);
			poller = new Poller();
			
			
			
			youTubeDataAPI.addEventListener(YouTubeEvent.COMPLETE, onLoaded);
			youTubeDataAPI.addEventListener(YouTubeEvent.ERROR, onError);
			video.addEventListener(FLVEvent.META_LOADED, onMeta);
			video.addEventListener(FLVEvent.PLAY_START, onPlayStart);
			video.addEventListener(FLVEvent.PLAY_COMPLETE, omPlayComplete);
			video.addEventListener(FLVEvent.BUFFER_EMPTY, onBufferEmpty);
			video.addEventListener(FLVEvent.BUFFER_FULL, onBufferFull);
			
			showPoller();
			setSize(320, 240)
			
		}
		public function loadVideo(token:String) {
			youTubeDataAPI.getVideoToken(token);
		}
		public function setSize(w:int, h:int) {
			video.width = w;
			video.height = h;
			poller.x = w / 2;
			poller.y = h / 2;			
		}
		private function onBufferEmpty(event : FLVEvent) : void {
			if(!video.playing || video.finished) return;
			showPoller();
		}
		
		private function onBufferFull(event : FLVEvent) : void {
			removePoller();
		}
		
		private function omPlayComplete(event : FLVEvent) : void {
			removePoller();
		}

		private function onMeta(event : FLVEvent) : void {
			video.width = video.meta.width;
			video.height = video.meta.height;
		}

		private function onPlayStart(event : FLVEvent) : void {
			addChild(video);
			if(contains(poller)) removeChild(poller);
		}

		private function onLoaded(event : YouTubeEvent) : void {
			var videoInfo : YouTubeVideoInfo = event.data as YouTubeVideoInfo;
			
			video.play(youTubeDataAPI.getVideoUrl(videoInfo.id, videoInfo.token));
		}

		private function onError(event : YouTubeEvent) : void {
		}
		
		private function showPoller():void{
			addChild(poller);
		}
		
		private function removePoller():void{
			if(contains(poller)) removeChild(poller);
		}
		
		public function destroy() {
			video.destroy()
			removePoller();
			youTubeDataAPI = null;
		}
	}
}

