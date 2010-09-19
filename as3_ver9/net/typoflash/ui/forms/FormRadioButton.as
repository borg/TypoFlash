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


	import fl.controls.RadioButton;
	import fl.controls.RadioButtonGroup;
	import flash.text.*;

	public class FormRadioButton extends FormElement implements iFormElement{

		var group:RadioButtonGroup;
		var _dataProvider:DataProvider;


		public function FormRadioButton(){
			
			group = new RadioButtonGroup("group");
			//bug workaround...picks up wrong height in scrollpane etc...so gotta adapt until I know why
			//bg.height = height
			//_label.autoSize = TextFieldAutoSize.LEFT;

		}

		public function setDataProvider(d:Array){
			_dataProvider = new DataProvider(d) ;
			
			var r;
			

			for(var i=0;i<_dataProvider.length;i++){
				r = new RadioButton()
				r.x = 14 + 70*i
				r.y = 29
				r.group = group
				r.label = _dataProvider.getItemAt(i).label;
				r.value = _dataProvider.getItemAt(i).data;
				//r.addEventListener(MouseEvent.CLICK, changeHandler);
				r.addEventListener(Event.CHANGE, changeHandler);
				addChild(r)
			}

		}
		
		public function set dataProvider(d){
			setDataProvider(d)
		}
		
		public function get dataProvider(){
			return _dataProvider;
		}
		

		
		function resizeStage(event:Event):void{
			
		}

		public override function set value(s):void{
			
			group.selectedData  = s

			_value = s;
		}
		public override function get value(){
			return group.selectedData;
		}
		





	}
}