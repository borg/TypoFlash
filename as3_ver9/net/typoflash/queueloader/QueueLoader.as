﻿/*
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
	import flash.display.DisplayObject;	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.system.LoaderContext;
	import flash.utils.Timer;
	
	import net.typoflash.queueloader.QueueLoaderEvent;		

	/*[Event(name="ITEM_START", type="net.typoflash.queueloader.QueueLoaderEvent")]

	[Event(name="ITEM_PROGRESS", type="net.typoflash.queueloader.QueueLoaderEvent")]

	[Event(name="ITEM_COMPLETE", type="net.typoflash.queueloader.QueueLoaderEvent")]

	[Event(name="ITEM_ERROR", type="net.typoflash.queueloader.QueueLoaderEvent")]

	[Event(name="QUEUE_START", type="net.typoflash.queueloader.QueueLoaderEvent")]

	[Event(name="QUEUE_PROGRESS", type="net.typoflash.queueloader.QueueLoaderEvent")]

	[Event(name="QUEUE_COMPLETE", type="net.typoflash.queueloader.QueueLoaderEvent")]*/
	
	public class QueueLoader implements IEventDispatcher {
		
		public static const VERSION : String = "QueueLoader 3.1.3";

		public static const AUTHOR : String = "Donovan Adams - donovan[(replace at)]hydrotik.com";

		public static var VERBOSE : Boolean = false;
		
		public static var VERBOSE_BANDWITH : Boolean = false;
		
		
		/***************************************
		******	 LOADABLE ITEM LIST   **********
		***************************************/
		
		public static const FILE_IMAGE : int = 1;

		public static const FILE_SWF : int = 2;
		
		public static const FILE_XML : int = 3;
		
		public static const FILE_CSS : int = 4;
		
		public static const FILE_MP3 : int = 5;
		
		public static const FILE_ZIP : int = 6;

		public static const FILE_WAV : int = 7;

		public static const FILE_FLV : int = 8;

		public static const FILE_GENERIC : int = 9;
		
		// See ItemList for respective Item Types
		/**************************************/
		
		
		protected static var _init:Boolean = false;

		protected var dispatcher : EventDispatcher;

		protected var _ignoreErrors : Boolean;

		protected var _loaderContext : LoaderContext;

		protected var debug : Function;
		
		protected var _index:int;
		
		protected var _loadingQueue : Array;
		
		protected var _currItem:*;

		protected var _isLoading:Boolean;
		
		protected var _queuepercentage : Number;
		
		protected var _currBytes : int;
		
		protected var _totalBytes : int;
		
		protected var _isComplete : Boolean;
		
		protected var _bandwidth : Number;

		protected var _prevBytes : Number;

		protected var _bwTimer : Timer;
		
		protected var _bwChecking : Boolean;

		protected var _packetRec : Array;
		
		protected var _id : String = "";

		/**
		 * QueueLoader AS 3
		 *
		 * @author: Donovan Adams, E-Mail: donovan[(replace at)]hydrotik.com, url: http://blog.hydrotik.com/
		 * @author: Project home: <a href="http://code.google.com/p/queueloader-as3/" target="blank">QueueLoader on Google Code</a><br><br>
		 * @version: 3.1.3
		 *
		 * @description QueueLoader is an open source linear asset loading tool with progress monitoring. Please contact me if you make additions, updates, or enhancements to the package. If you use QueueLoader, I'd love to hear about it. Please contact me if you find any errors or bugs in the class or documentation or if you would like to contribute.
		 *
		 * @history <a href="http://code.google.com/p/queueloader-as3/wiki/ChangeLog" target="blank">Up-To-Date Change Log Information here</a>
		 *
		 * @example Go to <a href="http://code.google.com/p/queueloader-as3/wiki/QueueLoaderGuide" target="blank">QueueLoader Guide on Google Code</a> for more usage info. This example shows how to use QueueLoader in a basic application:
		<code>
		</code>
		 */  
		/**
		 * @param	ignoreErrors: Boolean false for stopping the queue on an error, true for ignoring errors.
		 * @param	loaderContext: Allows access of a loaded SWF's class references
		 * @param	bandwidthMonitoring: Turns on bandwidth monitoring, returning a continious KB/S value to the bandwidth property in the event handler.
		 * @return	void
		 * @description Contructor for QueueLoader
		 */
		public function QueueLoader(ignoreErrors : Boolean = false, loaderContext : LoaderContext = null, bandwidthMonitoring : Boolean = false, id:String = "") {
			if(!_init) _init = ItemList.initItems();
			dispatcher = new EventDispatcher(this);
			debug = trace;
			debug("\n\n========== new QueueLoader() version:"+VERSION + " - publish: "+(new Date()).toString()+"==========\n\n");
			init();
			_isComplete  = false;
			_loaderContext = loaderContext;
			_ignoreErrors = ignoreErrors;
			_bwChecking = bandwidthMonitoring;
			if(_bwChecking) _bwTimer = new Timer(100);
			_id = id;
			if(_id != "") QLManager.addQueue(_id, this);
		}

		/**
		 * @param	src:String - asset file path
		 * @param	container:* - container location
		 * @param	info:Object - data
		 * @return	void
		 * @description Adds an item to the loading queue
		 */
		public function addItem(src : String, container : * = null, info : Object = null) : void {
			if (VERBOSE) debug(">> addItem() args:" + [src, container, info, info.mimeType, info.cacheKiller]);
			_isComplete  = false;
			addItemAt(_loadingQueue.length, src, container, (info != null) ? info : {});
		}
		
		/**
		 * @param	index:Number - insertion index
		 * @param	src:String - asset file path
		 * @param	container:* - container location
		 * @param	info:Object - data to be stored and retrieved later
		 * @return	void
		 * @description Adds an item to the loading queue at a specific position
		 */
		public function addItemAt(index : Number, src : String, container : *, info : Object) : void {
			if(VERBOSE) debug(">> addItemAt() args:" + [index, src, container, info]);
			var fileType:int; var i:String;
			var strip:Array = src.split("?");
			var urlVars:String = "?";
			if(strip.length > 1){
				var hash:Array = strip[1].split("&");
				for(var v:int = 0; v<hash.length; v++){
					var pairs:Array = hash[v].split("=");
					urlVars = urlVars + pairs[0] + "=" + pairs[1] + "&";
				}
			}
			if(info.cacheKiller != null) urlVars = urlVars + "cache=" + (new Date()).getTime().toString();
			if(info.mimeType == null){
				for(i in ItemList.itemArray) if(strip[0].search(ItemList.itemArray[int(i)].regEx) != -1) fileType = int(i);
			}else{
				fileType = info.mimeType;
			}
			var urlReq:URLRequest = new URLRequest(strip[0] + ((getMode() && urlVars.length > 1) ? urlVars : ""));
			for(i in ItemList.itemArray) if(int(i)==fileType) _loadingQueue.splice(index, 0, new (ItemList.itemArray[int(i)].classRef)(urlReq, container, info, _loaderContext, int(i)) as ILoadable);
			
		}
		
		/**
		 * @param	index:Number - removal index
		 * @param	...rest:Array - Items to be added
		 * @return	void
		 * @description Adds a group of items to the loading queue at a specific position
		 */
		public function loadXML(xml:XML, scope:* = null) : void {
			if(VERBOSE) debug(">> loadXML() args:" + [xml]);
			var xmlList:XMLList = xml..queueloader.item;
			var prefix:String = xml..queueloader.@prefix;
			for (var i : Number = 0; i < xmlList.length(); i++) {
				var src:String = ((prefix != "") ? prefix : "") + xmlList[i].@src;
				var info:Object = {};
				var container:DisplayObject = (scope != null) ? ((scope[xmlList[i].@container] != null) ? scope[xmlList[i].@container] : ((xmlList[i].@container == "this") ? scope : null)) : null;
				if(VERBOSE) debug(xmlList[i].@container, container);
				if(xmlList[i].info != null){
					var infoList:XMLList =  xmlList[i].info.children();
					for (var j : int = 0; j < infoList.length(); j++) info[infoList[j].name()] = infoList[j];
				}
				addItem(src, container, info);
			}
		}
		
		/**
		 * @param	index:Number - removal index
		 * @return	Array
		 * @description Removes an item to the loading queue at a specific position
		 */
		public function removeItemAt(index : Number) : Array {
			if(VERBOSE) debug(">> removeItem() args:" + [index]);
			return _loadingQueue.splice(index, 1);
		}
		
		/**
		 * @param	... args: sortOn() Arguments
		 * @return	void
		 * @description allows input of a sort function for sorting the array see Array.sortOn(); sortOn() will provide sorting accessing the public methods of the Item's class.
		 */
		public function sortOn(... args) : void {
			if(VERBOSE) debug(">> sortOn() args:" + [args]);
			_loadingQueue.sortOn(args);
		}
		
		/**
		 * @param	index:int - Beginning index point where items are pulled from
		 * @param	len:int - Length of items to be pulled
		 * @param	insertAt:int - Insertion index of where items are placed back in the queue
		 * @return	void
		 * @description This method simply pulls any number of items from a specific index and inserts them into another place in the queue. Provides on the fly prioritization of items before and during load.
		 */
		public function shuffle(index:int, len:int, insertAt:int) : void {
			if(VERBOSE) debug(">> shuffle() args:" + [index, len, insertAt]);
			var temp:Array = _loadingQueue.splice(index, len);
			for(var i:int = 0;i<temp.length;i++) _loadingQueue.splice(insertAt + i, 0, temp[i]);
		}
		
		/**
		 * @param	index:Number - index of returned item
		 * @return	Object
		 * @description Returns an item in the loading queue at a specific index
		 */
		public function getItemAt(index : Number) : Object {
			if(VERBOSE) debug(">> getItemAt() args:" + [index]);
			return _loadingQueue[index];
		}
		
		/**
		 * @param	title:String - title of returned item
		 * @return	Object
		 * @description Returns an item in the loading queue by searching the title.
		 */
		public function getItemByTitle(title : String) : Object {
			if(VERBOSE) debug(">> getItemByTitle() args:" + [title]);
			for (var i:int = 0; i<_loadingQueue.length;i++) if (_loadingQueue[i].title == title) return _loadingQueue[i];
			return false;
		}
		
		/**
		 * @return	Array - Array of items that have been succesfully loaded
		 * @description Returns an array of items that have been succesfully loaded.
		 */
		public function getLoadedItems() : Array {
			if(VERBOSE) debug(">> getLoadedItems() args:" + []);
			var temp:Array = [];
			for (var i:int = 0; i<_loadingQueue.length;i++) if (_loadingQueue[i].isLoaded) temp.push(_loadingQueue[i]);
			return temp;
		}
		
		/**
		 * @return	Array - Array of items that have NOT been loaded yet
		 * @description Returns an array of items that have NOT been loaded yet and are still in the queue.
		 */
		public function getQueuedItems() : Array {
			if(VERBOSE) debug(">> getQueuedItems() args:" + []);
			var temp:Array = [];
			for (var i:int = 0; i<_loadingQueue.length;i++) if (!_loadingQueue[i].isLoaded) temp.push(_loadingQueue[i]);
			return temp;
		}
		
		/**
		 * @description Executes the loading sequence
		 * @return	void
		 */
		public function execute() : void {
			if(VERBOSE) debug(">> execute() "+[_isLoading, _bwTimer]);
			if(!_isLoading){
				_isLoading = true;	
				if(_bwChecking ) _bwTimer.addEventListener(TimerEvent.TIMER, checkBandwidth);
				_isComplete = false;	
				
				_index = 0;
				_currItem = null;
				_queuepercentage = 0;
				_currBytes = 0;
				_totalBytes = 0;
				_bandwidth = 0;
				_prevBytes = 0;
				
				
				loadNextItem();
			}
		}
		
		/**
		 * @description Stops Loading
		 * @return	void
		 */
		public function stop() : void {
			if(VERBOSE) debug(">> stop()");
			if(_isLoading && !_isComplete){
				//_loadingQueue[_index].stop();
				_currItem.stop();
				_isLoading = false;
			}
		}

		/**
		 * @description Resumes Loading
		 * @return	void
		 */
		public function resume() : void {
			if(VERBOSE) debug(">> stop()");
			if(!_isLoading && !_isComplete){
				//_loadingQueue[_index].stop();
				_isLoading = true;
				loadNextItem();
			}
		}
		
		/**
		 * @description Returns loading status
		 * @return	Boolean
		 */
		public function get loading() : Boolean {
			return _isLoading;
		}
		
		/**
		 * @description Removes Items Loaded from memory for Garbage Collection
		 * @return	void
		 */
		public function dispose() : void {
			if(VERBOSE) debug(">> dispose()");
			
			_currItem.deConfigureListeners();
			
			while(_loadingQueue.length > 0) {
				var item:* = _loadingQueue.pop();
				if(item.isLoaded) item.dispose();
				item = null;
			}
			if(_bwChecking ){
				_bwTimer.removeEventListener(TimerEvent.TIMER, checkBandwidth);
				_bwTimer = null;
			}
			if(_id != ""){
				var removed:Boolean = QLManager.removeQueue(_id);
				if(VERBOSE) debug("QueueRemoved: "+_id, removed);
			}
			init();
		};
		
		/**
		 * @description Removes Items Loaded from memory for Garbage Collection
		 * @return	void
		 */
		public function isLoading() : Boolean {
			if(VERBOSE) debug(">> isLoading() index: "+_isLoading);
			return _isLoading;
		};
		
		
		
		// --== Implemented interface methods ==--
		public function addEventListener(type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = true) : void {
			dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		public function dispatchEvent(evt : Event) : Boolean {
			return dispatcher.dispatchEvent(evt);
		}

		public function hasEventListener(type : String) : Boolean {
			return dispatcher.hasEventListener(type);
		}

		public function removeEventListener(type : String, listener : Function, useCapture : Boolean = false) : void {
			dispatcher.removeEventListener(type, listener, useCapture);
		}

		public function willTrigger(type : String) : Boolean {
			return dispatcher.willTrigger(type);
		}
		
        public function httpStatusHandler(event:HTTPStatusEvent):void {
        	_currItem.message = event.status;
			dispatchEvent(new QueueLoaderEvent(QueueLoaderEvent.ITEM_HTTP_STATUS, _currItem,  _queuepercentage, _index, _loadingQueue.length, _bandwidth));
        }

        public function ioErrorHandler(event:IOErrorEvent):void {
        	_currItem.message = event.text;
			dispatchEvent(new QueueLoaderEvent(QueueLoaderEvent.ITEM_ERROR, _currItem,  _queuepercentage, _index, _loadingQueue.length, _bandwidth));
        	if(_ignoreErrors){
        		_index++;
        		loadNextItem();
        	}else{
        		if(!hasEventListener(QueueLoaderEvent.ITEM_ERROR)) throw new Error(_currItem.message);
        	}
        }

        public function openHandler(event:Event):void {
			if(_index == 0) dispatchEvent(new QueueLoaderEvent(QueueLoaderEvent.QUEUE_START, _currItem,  _queuepercentage, _index, _loadingQueue.length, _bandwidth));
			if(_bwChecking ) _bwTimer.start();
			dispatchEvent(new QueueLoaderEvent(QueueLoaderEvent.ITEM_START, _currItem,  _queuepercentage, _index, _loadingQueue.length, _bandwidth));
        }

        public function progressHandler(event:ProgressEvent):void {
			_queuepercentage = (event.bytesLoaded * 100 / event.bytesTotal) / _loadingQueue.length + (_index * 100 / _loadingQueue.length);
			_queuepercentage /= 100; 
			_currBytes = event.bytesLoaded + _totalBytes;
			
			_currItem.bytesLoaded = event.bytesLoaded;
			_currItem.bytesTotal = event.bytesTotal;
			_currItem.progress = _currItem.bytesLoaded/_currItem.bytesTotal;
			
            dispatchEvent(new QueueLoaderEvent(QueueLoaderEvent.ITEM_PROGRESS, _currItem,  _queuepercentage, _index, _loadingQueue.length, _bandwidth));
			dispatchEvent(new QueueLoaderEvent(QueueLoaderEvent.QUEUE_PROGRESS, _currItem,  _queuepercentage, _index, _loadingQueue.length, _bandwidth));
            
            if(event.bytesLoaded / event.bytesTotal == 1) _totalBytes += event.bytesLoaded;
        }

		public function completeHandler(event:Event):void {
			_currItem.isLoaded = true;
			dispatchEvent(new QueueLoaderEvent(QueueLoaderEvent.ITEM_COMPLETE, _currItem,  _queuepercentage, _index, _loadingQueue.length, _bandwidth));
            _index++;
			_currItem.deConfigureListeners();
            if(_index == _loadingQueue.length){
	            _isLoading = false;
	            if(_bwChecking ) _bwTimer.stop();
				dispatchEvent(new QueueLoaderEvent(QueueLoaderEvent.QUEUE_COMPLETE, _currItem,  _queuepercentage, _index, _loadingQueue.length, _bandwidth));
            	_isComplete = true;
            }else{
				loadNextItem();
            }
        }



		/*****************************************************************************************************
		
		
		
		******************************************************************************************************/
		
		protected function init():void{
			_loadingQueue = [];
			_ignoreErrors  = false;
			_loaderContext = null;
			_index = 0;
			_currItem = null;
			_isLoading = false;
			_queuepercentage = 0;
			_currBytes = 0;
			_totalBytes = 0;
			_bandwidth = 0;
			_prevBytes = 0;
			_bwChecking  = false;
			_packetRec = [];
		}
		
		protected function loadNextItem() : void {
			if(_isLoading && !_isComplete){
				_currItem = _loadingQueue[_index];
				_currItem.registerItem(this);
				_currItem.load();
			}
		}
		   
		protected function getMode():Boolean {
			if (Capabilities.playerType == "External" || Capabilities.playerType == "StandAlone") {
				return false;
			} else {
				return true;
			}
		}
		
		protected function checkBandwidth(event : TimerEvent) : void {
			var bw:Number = (_currBytes - _prevBytes)/1024;
			_packetRec.push(bw);
			if(_packetRec.length == 100) _packetRec.shift();
			var buffer:Number = 0;
			for (var i:int = 0; i < _packetRec.length; i++) buffer = buffer + _packetRec[i];  
			_bandwidth = round((((buffer)/_packetRec.length)*(_bwTimer.delay))*(80/1000), 3);
			_prevBytes = _currBytes;
		}
		
		protected function round(num : Number, decimal : Number = 1) : Number {
			return Math.round(num * Math.pow(10, decimal))/Math.pow(10, decimal);
		}
	}
}