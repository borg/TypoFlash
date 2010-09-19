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
	import com.flashdynamix.events.YouTubeEvent;

	import flash.events.*;
	import flash.net.*;
	import flash.utils.Dictionary;	
	import net.typoflash.datastructures.TFConfig;
	import net.typoflash.utils.Debug;
	
	public class YouTubeAPI extends EventDispatcher {
		public static var TF_CONF:TFConfig = TFConfig.global;
		private var calls : Dictionary;
		private var requests : Dictionary;
		private var parser : YouTubeXmlParser;

		// This is the You Tube developer key you can get your own here http://code.google.com/apis/youtube/overview.html
		public static var clientKey : String = TF_CONF.API_KEY["YOUTUBE_DEV_KEY"];

		public static var FLVUrl : String = "http://www.youtube.com/get_video?video_id=";
		public static var embeddedUrl : String = "http://www.youtube.com/watch?v=";
		public static var APIUrl : String = "http://gdata.youtube.com/feeds/api/";
		public static var servicesDomain : String = TF_CONF['HOST_URL']+"typo3conf/ext/flashremoting/lib/youtube/";

		public static var getTokenUrl : String = servicesDomain + "getToken.php";
		public static var streamUrl : String = servicesDomain + "streamFile.php";

		private static const VIDEOS_METHOD : String = "videos";
		private static const PLAYLIST_METHOD : String = "playlists";
		private static const USERS_METHOD : String = "users";
		private static const UPLOADS_METHOD : String = "uploads";
		private static const FAVOURITES_METHOD : String = "favorites";
		private static const SUBSCRIPTION_METHOD : String = "subscriptions";
		private static const CONTACTS_METHOD : String = "contacts";

		public static const USERS : String = "user";
		public static const SEARCH : String = "search";
		public static const PLAYLIST : String = "playlist";
		public static const FAVOURITES : String = "favorite";
		public static const SUBSCRIPTION : String = "subscription";
		public static const PROFILE : String = "profile";
		public static const CONTACTS : String = "contact";
		public static const VIDEOID : String = "videoId";

		public static const STANDARD : int = 0;
		public static const FL7V_448x336 : int = 1;
		public static const H264_480x360 : int = 2;
		public static const H264_720P_1280x720 : int = 3;

		
		public function YouTubeAPI() {
			parser = new YouTubeXmlParser();
			calls = new Dictionary();
			requests = new Dictionary();
		}

		private function onLoaded(e : Event) : void {
			try {
				var loader : URLLoader = e.currentTarget as URLLoader;
				var id : String = calls[loader];
				//
				//Debug.output(loader.data);
				try{
				var xml : XML = new XML(unescape(loader.data));
				}
				catch (e:Error)
				{
					Debug.output("YouTubeAPI.onLoaded server error. You Tube changed format?")
					Debug.output(loader.data);
				}
				var data : Object;
				
				switch(id) {
					case USERS :
						data = parser.userVideos(xml);
						break;
					case SEARCH :
						data = parser.searchVideos(xml);
						break;
					case PLAYLIST :
						data = parser.playlist(xml);
						break;
					case FAVOURITES :
						data = parser.userVideos(xml);
						break;
					case SUBSCRIPTION :
						data = parser.subscription(xml);
						break;
					case PROFILE :
						data = parser.profile(xml);
						break;
					case CONTACTS :
						data = parser.contacts(xml);
						break;
					case VIDEOID :
						data = parser.videoToken(xml);
						break;
					default :
						data = xml;
						break;
				}
				
				dispatchEvent(new YouTubeEvent(YouTubeEvent.COMPLETE, id, data));
			} catch (error : Error) {
				Debug.output("YouTubeAPI.onLoad error: " +error )
				dispatchEvent(new YouTubeEvent(YouTubeEvent.ERROR, id));
			}

			delete requests[loader];
			delete calls[loader];
		}

		private function onError(e : Event) : void {
			var loader : URLLoader = e.currentTarget as URLLoader;
			var id : String = calls[loader];
			
			dispatchEvent(new YouTubeEvent(YouTubeEvent.ERROR, id));
			
			delete requests[loader];
			delete calls[loader];
		}

		public function videosForTag(tag : String, category : String = null, startIndex : Number = 1,maxResults : Number = 20, orderBy : String = "relevance", author : String = null, lr : String = null, restriction : String = null, time : String = null, racy : String = "exclude") : void {
			var ur : URLRequest = urlRequest;
			ur.url += VIDEOS_METHOD;
			ur.url += (category == null) ? "" : "/-/" + escape(category) + "/";
			
			var uv : URLVariables = new URLVariables();
			uv["start-index"] = startIndex;
			uv["max-results"] = maxResults;
			uv.vq = tag;
			uv.client = clientKey;
			uv.alt = "rss";
			uv.format = 1;
			uv.racy = racy;
			uv.orderby = orderBy;
			if(author) uv.author = author;
			if(lr) uv.lr = lr;
			if(restriction) uv.restriction = restriction;
			if(time) uv.time = time;
			
			ur.method = URLRequestMethod.GET;
			ur.data = uv;
			
			loadRequest(ur, SEARCH);
		}

		public function videosForUser(userId : String = "default", startIndex : Number = 1,maxResults : Number = 20) : void {
			var ur : URLRequest = urlRequest;
			ur.url += USERS_METHOD + "/" + userId + "/" + UPLOADS_METHOD;
			
			var uv : URLVariables = new URLVariables();
			uv["start-index"] = startIndex;
			uv["max-results"] = maxResults;
			
			ur.method = URLRequestMethod.GET;
			ur.data = uv;
			
			loadRequest(ur, USERS);
		}

		public function videosForUserPlaylist(userId : String) : void {
			var ur : URLRequest = urlRequest;
			ur.url += USERS_METHOD + "/" + userId + "/" + PLAYLIST_METHOD;
			
			loadRequest(ur, PLAYLIST);
		}

		public function videosForUserFavourites(userId : String = "default") : void {
			var ur : URLRequest = urlRequest;
			ur.url += USERS_METHOD + "/" + userId + "/" + FAVOURITES_METHOD;
			
			loadRequest(ur, FAVOURITES);
		}

		public function videosForUserSubscription(userId : String = "default") : void {
			var ur : URLRequest = urlRequest;
			ur.url += USERS_METHOD + "/" + userId + "/" + SUBSCRIPTION_METHOD;
			
			loadRequest(ur, SUBSCRIPTION);
		}

		public function userProfile(userId : String = "default") : void {
			var ur : URLRequest = urlRequest;
			ur.url += USERS_METHOD + "/" + userId;
			
			loadRequest(ur, PROFILE);
		}

		public function userContacts(userId : String = "default") : void {
			var ur : URLRequest = urlRequest;
			ur.url += USERS_METHOD + "/" + userId + "/" + CONTACTS_METHOD;
			
			loadRequest(ur, CONTACTS);
		}

		public function getVideoToken(id : String) : void {
			Debug.output("gYouTubeAPI.getVideoToken id: "+id)
			//trace("getVideoToken getTokenUrl: "+getTokenUrl)
			var ur : URLRequest = new URLRequest(getTokenUrl);
			
			if(servicesDomain == "http://code.flashdynamix.com/YouTube/") {
				trace("If you want to play YouTube videos using a custom player skin then first read below :");
				trace("Custom skin modes are not covered by using the YouTube Player API http://code.google.com/apis/youtube/flash_api_reference.html");
				trace("-----------------------------------------");
				trace("You can not use  the domain code.flashdynamix.com set in the YouTubeAPI class!");
				trace("You will need to upload either the server side script getToken.php and streamFile.php onto your own domain server provided as part of the repository download.");
				trace("Then change the services domain variable 'servicesDomain' in the YouTubeAPI class to point to this server side script on your domain.");
			}
			
			ur.method = URLRequestMethod.GET;
			
			var uv : URLVariables = new URLVariables();
			uv.url = embeddedUrl + id;

			ur.data = uv;
			
			loadRequest(ur, VIDEOID);
		}

		public function getVideoUrl(id : String, token : String, resolution : int = 0) : String {
			var fmt : String;
			switch(resolution) {
				case STANDARD : 
					fmt = "";
					break;
				case FL7V_448x336 : 
					fmt = "&fmt=6";
					break;
				case H264_480x360 : 
					fmt = "&fmt=18";
					break;
				case H264_720P_1280x720 :
					fmt = "&fmt=22";
					break;
			}
			//http://localhost:801/typo3conf/ext/flashremoting/lib/youtube/streamFile.php?url=http%3A//www.youtube.com/get_video%3Fvideo_id%3DVt-FyuuWlWQ%26t%3DvjVQa1PpcFNYQWobSPYxTKoujf7NKkUNolBhEmxOqYg%3D
			return streamUrl + "?url=" + escape(FLVUrl + id + "&t=" + token + fmt);
		}

		public function stopAll(method : String = null) : void {
			for(var loader in calls) {
				if(method == null || calls[loader] == method) {
					try {
						loader.close();
					} catch(e : Error) {
					}
					
					delete calls[loader];
				}
			}
		}

		private function loadRequest(request : URLRequest, id : String) : void {
			var loader : URLLoader = new URLLoader();
			
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			
			calls[loader] = id;
			requests[loader] = request;
			
			addEvent(loader, Event.COMPLETE, onLoaded);
			addEvent(loader, ErrorEvent.ERROR, onError);
			addEvent(loader, IOErrorEvent.IO_ERROR, onError);
			
			loader.load(request);
		}

		private function get urlRequest() : URLRequest {
			var ur : URLRequest = new URLRequest(APIUrl);
			ur.method = URLRequestMethod.GET;
			
			return ur;
		}

		protected function addEvent(item : EventDispatcher, type : String, listener : Function) : void {
			item.addEventListener(type, listener, false, 0, true);
		}

		protected function removeEvent(item : EventDispatcher, type : String, listener : Function) : void {
			item.removeEventListener(type, listener);
		}
	}
}

import com.flashdynamix.data.*;

internal class YouTubeXmlParser {

	private static const GD_TAG : String = "gd";
	private static const GEO_RSS_TAG : String = "georss";
	private static const GML_TAG : String = "gml";
	private static const YT_TAG : String = "yt";
	private static const MEDIA_TAG : String = "media";
	private static const OPEN_SEARCH_TAG : String = "openSearch";

	public function profile(xml : XML) : YouTubeProfile {
		var yt : Namespace = xml.namespace(YT_TAG);
		var media : Namespace = xml.namespace(MEDIA_TAG);
			
		var profile : YouTubeProfile = new YouTubeProfile();
		profile.firstName = xml.yt::firstName;
		profile.lastName = xml.yt::lastName;
		profile.username = xml.yt::username;
		profile.company = xml.yt::company;
		profile.location = xml.yt::location;
		profile.thumbnail = xml.media::thumbnail.@url;
		profile.viewCount = xml.yt::statistics.@viewCount;
		profile.subscriberCount = xml.yt::statistics.@subscriberCount;
			
		return profile;
	}

	public function searchVideos(xml : XML) : YouTubeVideoList {
		var yt : Namespace = xml.namespace(YT_TAG);
		var media : Namespace = xml.namespace(MEDIA_TAG);
		var openSearch : Namespace = xml.namespace(OPEN_SEARCH_TAG);
		var gd : Namespace = xml.namespace(GD_TAG);
		var gml : Namespace = xml.namespace(GML_TAG);
		var geo_rss : Namespace = xml.namespace(GEO_RSS_TAG);
			
		var list : XMLList = xml.channel.item;

		var response : YouTubeVideoList = new YouTubeVideoList();
		response.totalResults = xml.channel.openSearch::totalResults;
		response.startIndex = xml.channel.openSearch::startIndex;
			
		var itemXml : XML;
		for(var i : int = 0;i < list.length(); i++) {
			itemXml = list[i];
			
			var mediaXml : XMLList = itemXml.media::group;
			try {
				var geoXml : XMLList = itemXml.geo_rss::where.gml::Point.gml::pos;
			} catch(error : Error) {
			}
			var categoryXml : XMLList = itemXml.category;
			var statsXml : XMLList = itemXml.yt::statistics;
			var ratingXml : XMLList = itemXml.gd::rating;
			var commentsXml : XMLList = itemXml.gd::comments;
			var feedLinkXml : XMLList = commentsXml.gd::feedLink;
			var thumbnailXml : XMLList = mediaXml.media::thumbnail;
				
			var videoData : YouTubeVideo = new YouTubeVideo();
			videoData.link = itemXml.link;
			videoData.id = videoData.link.replace(new RegExp("http://www.youtube.com/watch\\?v=", "g"), "");	
			videoData.guid = itemXml.guid;
			videoData.title = mediaXml.media::title;
			videoData.published = itemXml.pubDate;
			videoData.author = itemXml.author;
			
			videoData.description = mediaXml.media::description;
			videoData.duration = mediaXml.yt::duration.@seconds;
			videoData.keywords = mediaXml.media::keywords;
			
			for(var j : int = 0;j < thumbnailXml.length(); j++) {
				videoData.imgs.push(thumbnailXml[j].@url);
			}
			
			videoData.stats.favoriteCount = statsXml.@favoriteCount;
			videoData.stats.viewCount = statsXml.@viewCount;
			
			videoData.rating.average = ratingXml.@average;
			videoData.rating.max = ratingXml.@max;
			videoData.rating.min = ratingXml.@min;
			videoData.rating.numRaters = ratingXml.@numRaters;
			
			videoData.comments.countHit = feedLinkXml.@countHit;
			videoData.comments.href = feedLinkXml.@href;
			
			if(geoXml) videoData.geo = geoXml.toString().split(" ");
			
			for(j = 0;j < categoryXml.length(); j++) {
				if(String(categoryXml[j]).indexOf("http://") == -1) {
					videoData.category.push(categoryXml[j]);
				}
			}
				
			response.list.push(videoData);
		}
			
		return response;
	}

	public function userVideos(xml : XML) : YouTubeUserVideoList {
		var yt : Namespace = xml.namespace(YT_TAG);
		var media : Namespace = xml.namespace(MEDIA_TAG);
		var openSearch : Namespace = xml.namespace(OPEN_SEARCH_TAG);
		var gd : Namespace = xml.namespace(GD_TAG);
		var gml : Namespace = xml.namespace(GML_TAG);
		var geo_rss : Namespace = xml.namespace(GEO_RSS_TAG);
		
		var list : XMLList = xml.children();
		
		var response : YouTubeUserVideoList = new YouTubeUserVideoList();
		response.totalResults = xml.openSearch::totalResults;
		response.startIndex = xml.openSearch::startIndex;
			
		var itemXml : XML;
		for(var i : int = 0;i < list.length(); i++) {
			itemXml = list[i];
			var localName : String = itemXml.localName().toString();
				
			switch(localName) {
				case "entry" :
					
					var nodesList : XMLList = itemXml.children();
					var mediaXml : XMLList = itemXml.media::group;
					try {
						var geoXml : XMLList = itemXml.geo_rss::where.gml::Point.gml::pos;
					} catch(error : Error) {
					}
					var statsXml : XMLList = itemXml.yt::statistics;
					var ratingXml : XMLList = itemXml.gd::rating;
					var commentsXml : XMLList = itemXml.gd::comments;
					var feedLinkXml : XMLList = commentsXml.gd::feedLink;
					var thumbnailXml : XMLList = mediaXml.media::thumbnail;
					
					var videoData : YouTubeUserVideo = new YouTubeUserVideo();
					
					videoData.link = mediaXml.media::player.@url;
					videoData.id = videoData.link.replace(new RegExp("http://www.youtube.com/watch\\?v=", "g"), "");
					videoData.guid = nodesList.(localName() == "id");
					videoData.author = itemXml.author.name;
					videoData.title = mediaXml.media::title;
					videoData.published = nodesList.(localName() == "published");
					videoData.updated = nodesList.(localName() == "updated");
					videoData.recorded = itemXml.yt::recorded;
					
					videoData.description = mediaXml.media::description;
					videoData.duration = mediaXml.yt::duration.@seconds;
					videoData.keywords = mediaXml.media::keywords;
					
					for(var j : int = 0;j < thumbnailXml.length(); j++) {
						videoData.imgs.push(thumbnailXml[j].@url);
					}
			
					videoData.stats.favoriteCount = statsXml.@favoriteCount;
					videoData.stats.viewCount = statsXml.@viewCount;
			
					videoData.rating.average = ratingXml.@average;
					videoData.rating.max = ratingXml.@max;
					videoData.rating.min = ratingXml.@min;
					videoData.rating.numRaters = ratingXml.@numRaters;
			
					videoData.comments.countHit = feedLinkXml.@countHit;
					videoData.comments.href = feedLinkXml.@href;
					
					if(geoXml) videoData.geo = geoXml.toString().split(" ");
					videoData.geoLocation = itemXml.yt::location;
					
					for(j = 0;j < nodesList.(localName() == "category").length(); j++) {
						videoData.category.push(nodesList.(localName() == "category")[j].@term);
					}
				
					response.list.push(videoData);
					break;
					
				case "title":
					response.title = itemXml;
					break;
					
				case "author" :
					response.author = itemXml.children().(localName() == "name");
					break;
			}
		}
			
		return response;
	}

	public function subscription(xml : XML) : Array {
		var yt : Namespace = xml.namespace(YT_TAG);
		var gd : Namespace = xml.namespace(GD_TAG);
		var data : Array = new Array();
			
		var list : XMLList = xml.elements();
		var itemXml : XML;
		
		for(var i : int = 0;i < list.length(); i++) {
			
			itemXml = list[i];
			var localName : String = itemXml.localName().toString();
			
			switch(localName) {
				case "entry" :	
					var item : YouTubeSubscription = new YouTubeSubscription();
					item.username = list[i].yt::username;
					item.href = list[i].gd::feedLink.@href;
					item.countHint = list[i].gd::feedLink.@countHint;
					
					data.push(item);
					break;
			}
		}
			
		return data;
	}

	public function playlist(xml : XML) : YouTubeVideoList {
		var yt : Namespace = xml.namespace(YT_TAG);
		var gd : Namespace = xml.namespace(GD_TAG);
		var openSearch : Namespace = xml.namespace(OPEN_SEARCH_TAG);
			
		var list : XMLList = xml.elements();
			
		var response : YouTubeVideoList = new YouTubeVideoList();
		response.totalResults = xml.channel.openSearch::totalResults;
		response.startIndex = xml.channel.openSearch::startIndex;
			
		var itemXml : XML;
		for(var i : int = 0;i < list.length(); i++) {
			
			itemXml = list[i];
			var localName : String = itemXml.localName().toString();
			
			switch(localName) {
				case "entry" :
					var item : YouTubePlaylist = new YouTubePlaylist();
					item.description = itemXml.yt::description;
					item.feedLink = itemXml.gd::feedLink.@href;
					item.countHint = itemXml.gd::feedLink.@countHint;
					
					response.list.push(item);
					break;
			}
		}
			
		return response;
	}

	public function contacts(xml : XML) : Array {
		var yt : Namespace = xml.namespace(YT_TAG);
		var data : Array = new Array();
			
		var list : XMLList = xml.elements();
		var itemXml : XML;
		
		for(var i : int = 0;i < list.length(); i++) {
			
			itemXml = list[i];
			var localName : String = itemXml.localName().toString();
				
			switch(localName) {
				case "entry" :
					var contact : YouTubeContact = new YouTubeContact();
					contact.username = itemXml.yt::username;
					contact.status = itemXml.yt::status;
					
					data.push(contact);
					break;
			}
		}
			
		return data;
	}

	public function videoToken(xml : XML) : YouTubeVideoInfo {
		return new YouTubeVideoInfo(xml.id, xml.t);
	}
}