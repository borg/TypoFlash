/*
net.typoflash.queueloader.zip.ZipError
Copyright (C) 2007 David Chang (dchang@nochump.com)

This file is part of net.typoflash.queueloader.zip.

net.typoflash.queueloader.zip is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

net.typoflash.queueloader.zip is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
*/
package net.typoflash.queueloader.zip {
	
	import flash.errors.IOError;
	
	/**
	 * Thrown during the creation or input of a zip file.
	 */
	public class ZipError extends IOError {
		
		public function ZipError(message:String = "", id:int = 0) {
			super(message, id);
		}
		
	}
	
}
