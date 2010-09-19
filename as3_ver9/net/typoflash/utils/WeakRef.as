/*
 * Author: Richard Lord
 * Copyright (c) Big Room Ventures Ltd. 2007-2008
 * Version: 1.0.0
 * 
 * Licence Agreement
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package net.typoflash.utils 
{
    import flash.utils.Dictionary;
	/**
	 * Class to create a weak reference to an object. A weak reference
	 * is a reference that does not prevent the object from being
	 * garbage collected. If the object has been garbage collected
	 * then the get method will return null.
	 */
    public class WeakRef
    {
        private var dic:Dictionary;
		
		/**
		 * The constructor - creates a weak reference.
		 * 
		 * @param obj the object to create a weak reference to
		 */
        public function WeakRef( obj:* )
        {
            dic = new Dictionary( true );
            dic[obj] = 1;
        }
		
		/**
		 * To get a strong reference to the object.
		 * 
		 * @return a strong reference to the object or null if the
		 * object has been garbage collected
		 */
        public function get():*
        {
            for ( var item:* in dic )
            {
                return item;
            }
            return null;
        }
    }
}