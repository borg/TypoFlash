/*
bFileMenu Class

Copyright Andreas net.typoflash 2007
net.typoflash@elevated.to


*/

package net.typoflash.ui.forms{

	import net.typoflash.ui.Controls;
	import net.typoflash.ui.components.bButton;
	import net.typoflash.ui.components.bListItem;
	import net.typoflash.managers.DepthManager;
	import fl.data.DataProvider;
	
	import flash.display.*;

	import net.typoflash.ui.forms.FormEvent;
	
	import fl.controls.Label;
	import fl.events.ComponentEvent;


	import net.typoflash.ui.components.bComponentEvent;
	import flash.events.*;
	import flash.net.*;


	import net.typoflash.ui.components.bFileUpload;
	import flash.text.*;

	public class FormFileUpload extends FormElement implements iFormElement{

		
		public function FormFileUpload(){
			//field.addEventListener(ComponentEvent.ENTER, changeHandler);
			_label.autoSize = TextFieldAutoSize.LEFT;
		}

		
		
		
		

		
		function resizeStage(event:Event):void{
			
		}


		public override function set value(s):void{
			
			if(s==null){
				s = "";
			}
			//field.text = s

			_value = s;
		}
		public override function get value(){
			return "field.text";
		}		
		
		public function set uploadURL(s){
			field.uploadURL = s;
		}

		public function get uploadURL(){
			return field.uploadURL;
		}
		public function set path(s){
			field.path = s;
		}

		public function get path(){
			return field.path;
		}


		
	}
}