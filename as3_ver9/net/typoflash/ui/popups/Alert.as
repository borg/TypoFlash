/*
Class: AlertBox

Author: A. net.typoflash
Email: net.typoflash@elevated.to

Example usage:

alert(unescape(x.error._att["data"]));

*/
package net.typoflash.ui.popups{
	import flash.display.MovieClip;	
	import fl.controls.Label;
	import flash.events.MouseEvent;
	import fl.controls.Button;
	import fl.controls.TextArea;
	import flash.geom.Rectangle;

	import flash.text.TextField;
	import flash.text.TextFieldType;	
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;


	dynamic public class Alert extends MovieClip{
		public var acceptLabel:String="OK";

		public var accept:Function;

		public function Alert(m,acc=null) {
			msg = m;
			acceptBtn.label=acceptLabel;
			accept = acc;
			acceptBtn.addEventListener(MouseEvent.CLICK,_accept);	

			//a key listener wud be nice
			bg.addEventListener(MouseEvent.MOUSE_DOWN, startDragWindow);
			bg.addEventListener(MouseEvent.MOUSE_UP, stopDragWindow);
			titleBg.addEventListener(MouseEvent.MOUSE_DOWN, startDragWindow);
			titleBg.addEventListener(MouseEvent.MOUSE_UP, stopDragWindow);
			addEventListener(MouseEvent.MOUSE_UP, stopDragWindow);			
		};

		public function _accept(e:MouseEvent){
			if(accept != null){
				accept();
			}

			close();
		}
		function close() {
			parent.removeChild(this);
		};

		public function set msg(msg:String) {
			txt.text = msg;
			
		};
		function startDragWindow(e:MouseEvent){
			startDrag(false, new Rectangle( -380, -400, 1500, 800));
		}
		
		function stopDragWindow(e:MouseEvent){
			stopDrag();
		}	
	}
};

