/*
Class: ConfirmBox

Author: A. net.typoflash
Email: net.typoflash@elevated.to


Example usage:

var c = confirm(x.invitation._att["username"]+" has invited you to join a private chat. Accept?");
c.iUsername = x.invitation._att["username"];
c.cid = x.invitation._att["channelid"];
c.ctype = x.invitation._att["channeltype"];
c.accept = function() {
	//to do if accept
	Chat.joinChannel(this.cid)
	Chat.newChannelWin(this.cid, this.ctype);
	this.close();
};
c.decline = function() {
	//to do if decline
	alert("Declined "+this.iUsername+"'s invitation");
	this.close();
};
delete c;

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


	dynamic public class Confirm  extends MovieClip{
		public var acceptLabel:String="OK";
		public var rejectLabel:String="Cancel";
	
		public var accept:Function;
		public var decline:Function;

		function Confirm(m,acc,dec) {
			msg = m;
			accept = acc;
			decline = dec;
	
			//confirm buttons
			acceptBtn.label=acceptLabel;
			acceptBtn.addEventListener(MouseEvent.CLICK,_accept);
			
			rejectBtn.label=rejectLabel;
			rejectBtn.addEventListener(MouseEvent.CLICK,_decline);

			//a key listener wud be nice
			bg.addEventListener(MouseEvent.MOUSE_DOWN, startDragWindow);
			bg.addEventListener(MouseEvent.MOUSE_UP, stopDragWindow);
			titleBg.addEventListener(MouseEvent.MOUSE_DOWN, startDragWindow);
			titleBg.addEventListener(MouseEvent.MOUSE_UP, stopDragWindow);
			addEventListener(MouseEvent.MOUSE_UP, stopDragWindow);
		}


		function _accept(e:MouseEvent){
			accept();
			close()
		}
		function _decline(e:MouseEvent) {
			try{
				decline();
			}
			catch (e:Error)
			{
				
			}
			close()
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
}


