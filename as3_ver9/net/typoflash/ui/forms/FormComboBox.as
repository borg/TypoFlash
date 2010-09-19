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


	import fl.controls.ComboBox;
	import flash.text.*;

	public class FormComboBox extends FormElement implements iFormElement{

		
		
		public function FormComboBox(){
			
			field.addEventListener(Event.CHANGE, changeHandler);
			//bug workaround...picks up wrong height in scrollpane etc...so gotta adapt until I know why
			//bg.height = height
			_label.autoSize = TextFieldAutoSize.LEFT;
		}

		public function set dataProvider(d){
			field.dataProvider = new DataProvider(d) ;
		}

		public function get dataProvider(){
			return field.dataProvider;
		}
		
		public function setDataProvider(d:Array){
			field.dataProvider = new DataProvider(d) ;
			

		}	
		
		

		function resizeStage(event:Event):void{
			//bg.width = stage.stageWidth;
			//labelBg.width = stage.stageWidth;
		
		}




		public override function set value(s):void{

			field.selectedIndex = getSelectedIndex(s)

			_value = s;
		}
		public override function get value(){
			return field.selectedItem.data;
		}
		
		function getSelectedIndex(v){
			var l  = field.dataProvider.length
			while(l--){
				if(field.dataProvider.getItemAt(l).data == v){
					return l;
				}
				
			}
		}




	}
}