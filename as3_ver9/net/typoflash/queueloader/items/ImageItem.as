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
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	import net.typoflash.queueloader.AbstractItem;
	import net.typoflash.queueloader.ILoadable;		

	/**
	 * @author Donovan Adams | Hydrotik | http://blog.hydrotik.com
	 * @version: 3.1.3
	 */
	public class ImageItem extends AbstractItem implements ILoadable {

		protected var _smoothing : Boolean = false;
		
		protected var _center : Boolean = false;
		
		public function ImageItem(path : URLRequest, container : *, info : Object, loaderContext : LoaderContext, fileType:int) {
			super(path, container, info, loaderContext, fileType);
			if(info["title"] != null) _title = _info.title;
			if(info["smoothing"] != null) _smoothing = _info.smoothing;
			if(info["center"] != null) _center = _info.center;
		}

		public override function load() : void {
			_loader = new Loader();
			configureListeners();
			_loader.load(_path, _loaderContext);
			//event.target.loader.content
			
		}

		public override function stop() : void {
			deConfigureListeners();
			try{Loader(_loader).close();}catch(e:Error){};
		}

		public override function dispose() : void {
			stop();
			Loader(_loader).unload();
			_progress = 0;
			_bytesLoaded = 0;
			_bytesTotal = 0;
			_container = null;
			_target = null;
			_content = null;
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
			_info = null;
			_width = 0;
			_height = 0;
			_bitmap = null;
			_smoothing = false;
		}

		public function deConfigureListeners() : void {
			if(_loader.contentLoaderInfo.hasEventListener(ProgressEvent.PROGRESS)) _loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, _progressFunction);
			if(_loader.contentLoaderInfo.hasEventListener(Event.COMPLETE)) _loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, preCompleteProcess);
			if(_loader.contentLoaderInfo.hasEventListener(HTTPStatusEvent.HTTP_STATUS)) _loader.contentLoaderInfo.removeEventListener(HTTPStatusEvent.HTTP_STATUS, _httpStatusFunction);
			if(_loader.contentLoaderInfo.hasEventListener(IOErrorEvent.IO_ERROR)) _loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, _errorFunction);
			if(_loader.contentLoaderInfo.hasEventListener(Event.OPEN)) _loader.contentLoaderInfo.removeEventListener(Event.OPEN, _openFunction);
		}
		
		protected override function preCompleteProcess(event:Event):void{
			_target = event.target.loader;
			_content = event.target.loader.content;
			_content.smoothing = _smoothing;
			_width = _target.width;
			_height = _target.height;
			if(_center){
				_target.x = -(_width/2);
				_target.y = -(_height/2);
			}
			if(_container != null) _container.addChild(_target);
			_completeFunction(event);
		}
		
		/******* PRIVATE ********/
		private function configureListeners() : void {
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, preCompleteProcess);
			_loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, _httpStatusFunction);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _errorFunction);
			_loader.contentLoaderInfo.addEventListener(Event.OPEN, _openFunction);
			_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, _progressFunction);
		}
	}
}
