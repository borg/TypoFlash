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
	import flash.events.Event;
	import flash.events.MouseEvent;


	import fl.controls.TextArea;
	import flash.text.*;


	public class FormTextArea extends FormElement implements iFormElement{

		
		
		public function FormTextArea(){
			
			field.addEventListener(ComponentEvent.ENTER, changeHandler);
			//bug workaround...picks up wrong height in scrollpane etc...so gotta adapt until I know why
			//bg.height = height
			_label.autoSize = TextFieldAutoSize.LEFT;

		}
	

		
		function resizeStage(event:Event):void{
			
		}


		public override function set value(s):void{
			if(s==null){
				s = "";
			}
			field.text = s

			_value = s;
		}
		public override function get value(){
			return field.text;
		}		





	}
}