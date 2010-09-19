/*
 Copyright (c) 2007 Paulius Uza  <paulius@uza.lt>
 All rights reserved.
  
 Permission is hereby granted, free of charge, to any person obtaining a copy 
 of this software and associated documentation files (the "Software"), to deal 
 in the Software without restriction, including without limitation the rights 
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished 
 to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all 
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
 INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
 PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
 SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

@ignore
*/

package net.typoflash.events{
	import flash.events.Event;

	public class GlobalEvent extends Event
	{
		public var property:*;
		public static const PROPERTY_CHANGED:String = "globalPropertyChanged";
	
		public function GlobalEvent(type:String, property:*, bubbles:Boolean = false, cancelable:Boolean = false) {
			this.property = property;
			super(type, bubbles, cancelable);
		}
	
		override public function clone():Event {
			return new GlobalEvent(type, property, bubbles, cancelable);
		}
	}
}