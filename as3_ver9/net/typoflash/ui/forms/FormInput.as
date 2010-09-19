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



	import fl.controls.TextInput;
	import flash.text.*;

	public class FormInput extends FormElement implements iFormElement{

		
		public function FormInput(){
			field.addEventListener(ComponentEvent.ENTER, changeHandler);
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


		/*public function set w(s){
			field.width= s
		}
		public function get w(){
			return field.width;
		

		
		public override function get label():String{
			return _label.text;
		}

		public override function set enabled(s:Boolean):void{
			if(_editable){
				field.enabled = s;
			}else{
				field.enabled = false
			}
		}
		public override function get enabled():Boolean{
			if(_editable){
				return field.enabled;
			}else{
				return false;
			}
		}

		public override function set editable(s:Boolean):void{
			_editable = s;
		}
		public override function get editable():Boolean{
			return _editable;
		}
}
		public function set obligatory(s){
			_obligatory.text = s
		}
*/
	}
}