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
package com.flashdynamix.events {
	import flash.events.Event;	
	public class YouTubeFLVEvent extends Event {
		
		public static const WRAPPER_LOADED : String = "youtube_player_wrapper_loaded";		public static const PLAYER_LOADED : String = "youtube_player_player_loaded";
		public static const PROGRESS : String = "youtube_player_progress";
		public static const UNSTARTED : String = "youtube_player_unstarted";
		public static const STARTED : String = "youtube_player_started";
		public static const ENDED : String = "youtube_player_ended";
		public static const PLAYING : String = "youtube_player_playing";
		public static const PAUSED : String = "youtube_player_paused";
		public static const BUFFERING : String = "youtube_player_buffering";
		public static const QUEUED : String = "youtube_player_queued";
		public static const STATE_UPDATE : String = "youtube_player_state_update";
		public static const UNLOAD : String = "youtube_player_unload";
		public function YouTubeFLVEvent(type : String,bubbles : Boolean = false, cancelable : Boolean = false) {
			super(type, bubbles, cancelable);
		}
		public override function clone() : Event {
			return new YouTubeFLVEvent(type, bubbles, cancelable);
		}
	}
}