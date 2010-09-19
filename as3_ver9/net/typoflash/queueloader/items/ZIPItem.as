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
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.system.LoaderContext;
	
	import net.typoflash.queueloader.AbstractItem;
	import net.typoflash.queueloader.ILoadable;
	
	import net.typoflash.queueloader.zip.ZipEntry;
	import net.typoflash.queueloader.zip.ZipFile;	
	/**
	 * @author Donovan Adams | Hydrotik | http://blog.hydrotik.com
	 * @version: 3.1.3
	 */
	public class ZIPItem extends AbstractItem implements ILoadable {
		
		protected var _zipFile:ZipFile;

		public function ZIPItem(path : URLRequest, container : *, info : Object, loaderContext : LoaderContext, fileType:int) {
			super(path, container, info, loaderContext, fileType);
			if(info["title"] != null) _title = _info.title;
		}

		public override function load() : void {
			_loader = new URLStream();
			configureListeners();
			_loader.load(_path);
		}

		public override function stop() : void {
			try{URLStream(_loader).close();}catch(e:Error){};
			deConfigureListeners();
		}

		public override function dispose() : void {
			stop();
			_progress = 0;
			_bytesLoaded = 0;
			_bytesTotal = 0;
			_target = null;
			_container = null;
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
		}

		public function deConfigureListeners() : void {
			if(_loader.hasEventListener(ProgressEvent.PROGRESS)) _loader.removeEventListener(ProgressEvent.PROGRESS, _progressFunction);
			if(_loader.hasEventListener(Event.COMPLETE)) _loader.removeEventListener(Event.COMPLETE, preCompleteProcess);
			if(_loader.hasEventListener(HTTPStatusEvent.HTTP_STATUS)) _loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, _httpStatusFunction);
			if(_loader.hasEventListener(IOErrorEvent.IO_ERROR)) _loader.removeEventListener(IOErrorEvent.IO_ERROR, _errorFunction);
			if(_loader.hasEventListener(Event.OPEN)) _loader.removeEventListener(Event.OPEN, _openFunction);
		}
		
		/******* PROTECTED ********/
		protected override function preCompleteProcess(event:Event):void {
			_target = URLStream(event.target);
			_zipFile = new ZipFile(_target);
			var output:Array = [];
			for(var i:int = 1; i < _zipFile.entries.length; i++) {
			    var entry:ZipEntry = _zipFile.entries[i];
			    if(entry.name.search(/(__MACOSX)|(\/._)/ig) == -1){
			    	output.push(entry);
			    }
			}
			_content = output;
			_zipFile = null;
			_completeFunction(event);
        }
        
		/******* PRIVATE ********/
		private function configureListeners() : void {
			_loader.addEventListener(Event.COMPLETE, preCompleteProcess);
			_loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, _httpStatusFunction);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, _errorFunction);
			_loader.addEventListener(Event.OPEN, _openFunction);
			_loader.addEventListener(ProgressEvent.PROGRESS, _progressFunction);
		}
	}
}
