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
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	import net.typoflash.queueloader.AbstractItem;
	import net.typoflash.queueloader.ILoadable;	

	/**
	 * @author Donovan Adams | Hydrotik | http://blog.hydrotik.com
	 * @version: 3.1.3
	 */
	public class MPSoundItem extends AbstractItem implements ILoadable {
		
		protected var _autoPlay : Boolean = false;

		public function MPSoundItem(path : URLRequest, container : *, info : Object, loaderContext : LoaderContext, fileType:int) {
			super(path, container, info, loaderContext, fileType);
			if(info["title"] != null) _title = _info.title;
			if(info["autoPlay"] != null) _autoPlay = _info.autoPlay;
		}

		public override function load() : void {
			_content = new Sound();
			configureListeners();
			_content.load(_path);
			if(_autoPlay) _container = SoundChannel(_content.play());
		}

		public override function stop() : void {
			if(_autoPlay) SoundChannel(_container).stop();
			try{Sound(_content).close();}catch(error:Error){};
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
			_info = null;
			_width = 0;
			_height = 0;
			_bitmap = null;
		}

		public function deConfigureListeners() : void {
			if(_content.hasEventListener(ProgressEvent.PROGRESS)) _content.removeEventListener(ProgressEvent.PROGRESS, _progressFunction);
			if(_content.hasEventListener(Event.COMPLETE)) _content.removeEventListener(Event.COMPLETE, preCompleteProcess);
			if(_content.hasEventListener(IOErrorEvent.IO_ERROR)) _content.removeEventListener(IOErrorEvent.IO_ERROR, _errorFunction);
			if(_content.hasEventListener(Event.OPEN)) _content.removeEventListener(Event.OPEN, _openFunction);
		}
		
		/******* PRIVATE ********/
		private function configureListeners() : void {
			_content.addEventListener(Event.OPEN, _openFunction);
			_content.addEventListener(Event.COMPLETE, preCompleteProcess);
			_content.addEventListener(IOErrorEvent.IO_ERROR, _errorFunction);
			_content.addEventListener(ProgressEvent.PROGRESS, _progressFunction);
		}
	}
}
