/*
 * Copyright 2007-2008 (c) Donovan Adams, http://blog.hydrotik.com/
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */


package net.typoflash.queueloader.items {
	import flash.events.ProgressEvent;	
	import flash.net.URLRequest;	
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.system.LoaderContext;
	
	import net.typoflash.queueloader.AbstractItem;
	import net.typoflash.queueloader.ILoadable;	

	/**
	 * @author Donovan Adams | Hydrotik | http://blog.hydrotik.com
	 * @version: 3.1.3
	 */
	public class FLVItem extends AbstractItem implements ILoadable {

		protected var _connection : NetConnection;

		protected var _autoPlay : Boolean = false;

		protected var _asyncErrorFunction : Function = null;

		protected var _securityErrorFunction : Function = null;
		
		protected var _netStatusFunction : Function = null;
		
		protected var _client:Object;
		
		public function FLVItem(path : URLRequest, container : *, info : Object, loaderContext : LoaderContext, fileType : int) {
			super(path, container, info, loaderContext, fileType);
			if(info["title"] != null) _title = _info.title;
			if(info["autoPlay"] != null) _autoPlay = _info.autoPlay;
			if(info["asyncErrorFunction"] != null) _asyncErrorFunction = _info.asyncErrorFunction;
			if(info["securityErrorFunction"] != null) _securityErrorFunction = _info.securityErrorFunction;
			if(info["netStatusFunction"] != null) _netStatusFunction = _info.netStatusFunction;
			if(info["client"] != null) _client = _info.client;
		}

		public override function load() : void {
			if(_container == null) throw new Error("FLVItem requires a video container in the addItem() argument.");
			_connection = new NetConnection();
			_connection.addEventListener(NetStatusEvent.NET_STATUS, (_netStatusFunction != null) ? _netStatusFunction : netStatusHandler);
			if(_securityErrorFunction != null) _connection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, _securityErrorFunction);
			_connection.connect(null);
			_openFunction(new Event(Event.OPEN));
			_connection.client = this;
		}

		public override function stop() : void {
			NetStream(_loader).close();
			deConfigureListeners();
		}

		public override function dispose() : void {
			stop();
			_progress = 0;
			_bytesLoaded = 0;
			_bytesTotal = 0;
			_target = null;
			_container = null;
			_message = null;
			_path = null;
			_title = null;
			_index = 0;
			_isLoading = false;
			_fileType = 0;
			_loader = null;
			_openFunction = null;
			_httpStatusFunction = null;
			_errorFunction = null;
			_completeFunction = null;
			_progressFunction = null;
			_connection = null;
			_client = null;
			_info = null;
			_width = 0;
			_height = 0;
			_bitmap = null;
		}

		public function deConfigureListeners() : void {
			_loader.removeEventListener(NetStatusEvent.NET_STATUS, (_netStatusFunction != null) ? _netStatusFunction : netStatusHandler);
            if(_asyncErrorFunction != null) _loader.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, _asyncErrorFunction);
		}

		public function connectStream() : void {
			_content = _loader = new NetStream(_connection);
			_loader.client = (_client != null) ? _client : new Object();
			if(_asyncErrorFunction != null) _loader.addEventListener(AsyncErrorEvent.ASYNC_ERROR, _asyncErrorFunction);
			_loader.addEventListener(NetStatusEvent.NET_STATUS, (_netStatusFunction != null) ? _netStatusFunction : netStatusHandler);
			_container.attachNetStream(_loader);
			_loader.play(_path.url);
			_progressFunction(new ProgressEvent(ProgressEvent.PROGRESS, false, false, _loader.bytesTotal, _loader.bytesTotal));
			_completeFunction(new Event(Event.COMPLETE));
			if(!_autoPlay) NetStream(_loader).togglePause();
		}
		
		/******* PRIVATE ********/
		private function netStatusHandler(event : NetStatusEvent) : void {
			switch (event.info.code) {
				case "NetConnection.Connect.Success":
					trace("Connecting Stream: " + _path.url);
					connectStream();
					break;
				case "NetStream.Play.StreamNotFound":
					trace("Stream not found: " + _path.url);
					break;
			}
		}

		private function asyncErrorEventHandler(event : AsyncErrorEvent) : void {
			trace("Error = " + event.text);
		}

	}
}
