/*
Class: Popup

Author: A. net.typoflash
Email: net.typoflash@elevated.to

***************





*/
package net.typoflash.ui.popups{


	import flash.display.MovieClip;
	import fl.controls.Label;
	import fl.controls.TextArea;
	import flash.events.MouseEvent;
	import fl.controls.Button;


	public class Popup  extends MovieClip{
		
		public var acceptLabel:String="OK";
		public var rejectLabel:String="Cancel";
		var bg:MovieClip;
		var titleBg:MovieClip;
		var txt:TextArea;
		
		public function Popup() {

			//a key listener wud be nice
			bg.addEventListener(MouseEvent.MOUSE_DOWN, startDragWindow);
			bg.addEventListener(MouseEvent.MOUSE_UP, stopDragWindow);
			titleBg.addEventListener(MouseEvent.MOUSE_DOWN, startDragWindow);
			titleBg.addEventListener(MouseEvent.MOUSE_UP, stopDragWindow);
			addEventListener(MouseEvent.MOUSE_UP, stopDragWindow);
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






