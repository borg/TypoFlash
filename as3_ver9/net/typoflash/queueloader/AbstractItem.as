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


package net.typoflash.queueloader {
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;

	import net.typoflash.queueloader.ILoadable;		

	/**
	 * @author Donovan Adams | Hydrotik | http://blog.hydrotik.com
	 * @version: 3.1.3
	 */
	public class AbstractItem implements ILoadable {

		protected var _progress : Number;

		protected var _bytesLoaded : Number;

		protected var _bytesTotal : Number;

		protected var _container : *;

		protected var _target : *;

		protected var _content : *;

		protected var _message : String;

		protected var _path : URLRequest;

		protected var _title : String;

		protected var _index : int;

		protected var _isLoading : Boolean;

		protected var _fileType : int;

		protected var _loader : *;

		protected var _loaderContext : LoaderContext;

		protected var _openFunction : Function;

		protected var _httpStatusFunction : Function;

		protected var _errorFunction : Function;

		protected var _completeFunction : Function;

		protected var _progressFunction : Function;

		protected var _info : Object;

		protected var _width : Number;

		protected var _height : Number;

		protected var _bitmap : Bitmap;

		protected var _bmArray : Array;

		protected var _isLoaded : Boolean = false;

		public function AbstractItem(path : URLRequest, container : *, info : Object, loaderContext : LoaderContext, fileType : int) {
			_path = path;
			_container = container;
			_info = info;
			_fileType = fileType;
			_loaderContext = loaderContext;
			_bmArray = [];
		}

		public function registerItem(core : QueueLoader) : void {
			_openFunction = core.openHandler;
			_httpStatusFunction = core.httpStatusHandler;
			_errorFunction = core.ioErrorHandler;
			_completeFunction = core.completeHandler;
			_progressFunction = core.progressHandler;
		}

		public function stop() : void {
			throw new Error("Abstract stop() method must be overriden.");
		}

		public function load() : void {
			throw new Error("Abstract load() method must be overriden.");
		}

		public function dispose() : void {
			throw new Error("Abstract dispose() method must be overriden.");
		}

		public function get progress() : Number {
			return _progress;
		}

		public function get bytesLoaded() : Number {
			return _bytesLoaded;
		}

		public function get bytesTotal() : Number {
			return _bytesTotal;
		}

		public function get target() : * {
			return _target;
		}

		public function get container() : * {
			return _container;
		}

		public function get message() : String {
			return _message;
		}

		public function get path() : URLRequest {
			return _path;
		}

		public function get title() : String {
			return _title;
		}

		public function get index() : int {
			return _index;
		}

		public function set index(i : int) : void {
			_index = i;
		}

		public function get isLoading() : Boolean {
			return _isLoading;
		}

		public function set isLoading(b : Boolean) : void {
			_isLoading = b;
		}

		public function get fileType() : int {
			return _fileType;
		}

		public function set fileType(fileType : int) : void {
			_fileType = fileType;
		}

		public function get info() : Object {
			return _info;
		}

		public function set info(info : Object) : void {
			_info = info;
		}

		public function set bytesTotal(bytesTotal : Number) : void {
			_bytesTotal = bytesTotal;
		}

		public function set bytesLoaded(bytesLoaded : Number) : void {
			_bytesLoaded = bytesLoaded;
		}

		public function set progress(progress : Number) : void {
			_progress = progress;
		}

		public function get loader() : * {
			return _loader;
		}

		public function get width() : Number {
			return _width;
		}

		public function get height() : Number {
			return _height;
		}

		public function get bitmap() : Bitmap {
			return _bitmap;
		}

		protected function preCompleteProcess(event : Event) : void {
			if(QueueLoader.VERBOSE) trace("This item has no pre complete method. Override item class to enable");
			_completeFunction(event);
		}

		public function set message(message : String) : void {
			_message = message;
		}

		public function get bmArray() : Array {
			return _bmArray;
		}

		public function get content() : * {
			return _content;
		}

		public function get isLoaded() : Boolean {
			return _isLoaded;
		}

		public function set isLoaded(isLoaded : Boolean) : void {
			_isLoaded = isLoaded;
		}
	}
}
