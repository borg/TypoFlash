/*
Class: StandardBtn

Author: A. net.typoflash
Email: net.typoflash@elevated.to
*/
//import mx.events.EventDispatcher;
//import mx.controls.SimpleButton;
//import mx.core.UIObject;
//import mx.core.UIComponent;

package net.typoflash.ui{

	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import fl.controls.Button;

	public class StandardBtn  extends Button{
		
		var _selBegin;
		var _selEnd;
	
		public var data:*=Object;
		public var subdata:*=Array;		
		
		public function StandardBtn(){
			scaleX = scaleY=1;
			setSize(width,height);
		}

		function onRollOver(){
			highlite.gotoAndStop("over");
			icon.animation.gotoAndPlay("over");
			_selBegin = Selection.getBeginIndex();
			_selEnd = Selection.getEndIndex();
		}

		function onRollOut(){
			highlite.gotoAndPlay("out");
			icon.animation.gotoAndPlay("out");
		}
		
		public function setIcon(id){
			//icon.attachMovie(id,"animation",0);
			icon.scaleX = 1/ scaleX;
			icon.scaleY = 1/scaleY;		
		}
		
		/*
		Icon by default compensates btn resize, so as to remain at 100%. Should you wish to change size use this func.
		*/
		public function setIconSize(w,h){
			icon.width = w;
			icon.height = h;
			
		}
		
		public function setSound(id){
			//icon.attachMovie(id,"animation",0);
		}
		public function setState(state){
			//normally active/passive
			states.gotoAndStop(state);
			
		}

		public function setLabel(l){
			labelTxt.autoSize=TextFieldAutoSize.CENTER;
			labelTxt.text = l;
			setSize(labelTxt.width+10,height);
		}

		public function getLabel(){
			return labelTxt.text;
		}
		

		function setSize(w,h):void	{
			highlite.width = states.width = bg.width = w;
			highlite.height = states.height = bg.height = h;
			
			highlite.x = states.x = bg.x= w/2;
			highlite.y = states.y = bg.y= h/2;
			
		}	
		
	}

}