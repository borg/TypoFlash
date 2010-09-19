package net.typoflash.components.twitter {
	import flash.events.Event;
	import net.typoflash.base.Configurable;
	import net.typoflash.components.news.NewsReader;
	import net.typoflash.components.reader.AbstractReader;
	import net.typoflash.datastructures.TFNewsItem;
	import net.typoflash.events.RenderingEvent;
	import net.typoflash.events.GlueEvent;
	import net.typoflash.ContentRendering;
	import net.typoflash.utils.Debug;
	import net.typoflash.datastructures.TFRecordRequest;
	import net.typoflash.datastructures.TFLanguageObject;
	import flash.display.StageAlign;
	
	
	import twitter.api.data.TwitterStatus;
	import twitter.api.Twitter;
	import twitter.api.events.TwitterEvent;
	import twitter.api.TwitterSearch;
	import twitter.api.data.TwitterUser;

	/**
	 * ...
	 * @author A. Borg
	 */
	public class TwitterReader extends AbstractReader{

		public var TWITTER_USER:String = "stephenfry";

		private var _twitter:Twitter;
		
		protected var _twitterData:Array;//raw list from database
		protected var _userQueue:Array;//raw list of users without location, to be identified, since search doesnt return location
		
		public function TwitterReader() {
			_twitter = new Twitter();
			//_twitterSearch = new TwitterSearch();
			_twitter.addEventListener(TwitterEvent.ON_USER_TIMELINE_RESULT, userTimelineResult)
			_twitter.addEventListener(TwitterEvent.ON_SEARCH, onSearchResults)
			_twitter.addEventListener(TwitterEvent.ON_SHOW_INFO, onGetUserInfo)
			_twitter.addEventListener(TwitterEvent.ON_FOLLOWERS, onLoadFollowers)
			list = new TwitterList(this);
			addChild(list);
			//addEventListener(Event.ADDED_TO_STAGE, addedToStage, false, 0, true);
			
			
		}
		
		

	
		public function getUserFeed(){
			_twitter.loadUserTimeline(TWITTER_USER)
		}
		

				
		
		private function userTimelineResult(e:TwitterEvent):void {
			trace(["userTimelineResult ", e.data]);
			_twitterData = [];
			for (var i in e.data) {
				_twitterData.push(e.data[i] as TwitterStatus);
			}
			recordset = _twitterData;
			render();
			//pass on event to external listeners
			var te = new TwitterEvent(e.type);
			te.data = e.data;
			dispatchEvent(te);
		}
		
		/*
		public function addItem(s:TwitterStatus) {
			if(!(_twitterData is Array)){
				_twitterData = [];
			}
			_twitterData.unshift(s);
			list.data = _twitterData;
			list.render();
			pass on event to external listeners
			var te = new TwitterEvent(e.type);
			te.data = e.data;
			dispatchEvent(te);
		}
	*/
		

		
		public function get feed():Twitter { return _twitter; }
		
		
		public function loadInfo(id:String){
			_twitter.loadInfo(id);
		}
		
		private function onGetUserInfo(e:TwitterEvent) {
			if(_userQueue == null){
				_userQueue = [];
			}else{
				//another user identified
				//immediately look for next one, thing is only one call at a time is allowed
				_userQueue.shift();
				if(_userQueue.length>0){
					loadInfo(TwitterUser(_userQueue[0]).screen_name);
				}
			}
			
			recordset.push(TwitterUser(e.data).status);
			render();
			//pass on event to external listeners
			var te = new TwitterEvent(e.type);
			te.data = e.data;
			dispatchEvent(te);
		}

		public function loadFollowers(lite:Boolean=true):void{
			_twitter.loadFollowers(lite);
		}
		
		private function onLoadFollowers(e:TwitterEvent) {
			//pass on event to external listeners
			var te = new TwitterEvent(e.type);
			te.data = e.data;
			dispatchEvent(te);
		}
		
		
		public function search(s:TwitterSearch) { 
			_twitter.search(s);
		}
		

		private function onSearchResults(e:TwitterEvent):void {
			trace(["onSearchResults ", e.data]);
			if(_userQueue == null){
				_userQueue = [];
			}
			
			for (var i in e.data) {
				_userQueue.push(e.data[i]);
			}
			trace("onSearchResults num: " + _userQueue.length)
			if(_userQueue.length>0){
				loadInfo(TwitterUser(_userQueue[0]).screen_name);
			}
			//pass on event to external listeners
			var te = new TwitterEvent(e.type);
			te.data = e.data;
			dispatchEvent(te);
		}

	}
	
}