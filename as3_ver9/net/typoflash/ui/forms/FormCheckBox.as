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



	import fl.controls.CheckBox;
	import flash.text.*;

	public class FormCheckBox extends FormElement implements iFormElement{


		
		public function FormCheckBox(){
			field.addEventListener(Event.CHANGE, changeHandler);

			//bug workaround...picks up wrong height in scrollpane etc...so gotta adapt until I know why
			//bg.height = height
			
			
		}

		
		

		
		function resizeStage(event:Event):void{
			
		}

		public override function set value(s):void{
			
			field.selected = Boolean(s)

			_value = s;
		}
		public override function get value(){
			return field.selected;
		}
		




	}
}