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


	import fl.controls.*;

	import flash.text.*;

	public class FormList extends FormElement implements iFormElement{

		
		public function FormList(){
		
			
			
		
			field.addEventListener(Event.CHANGE, changeHandler);
		
			
		}

		

		public function set dataProvider(d){
			
			field.dataProvider = new DataProvider(d) ;
			
		}

		public function get dataProvider(){
			return field.dataProvider;
		}

		public function set allowMultipleSelection(d:Boolean):void{
			field.allowMultipleSelection = d ;
			
		}

		public function get allowMultipleSelection():Boolean{
			return field.allowMultipleSelection;
		}

		
		public function setDataProvider(d:Array){
			field.dataProvider = new DataProvider(d) ;
			

		}	
		
			
		

		function resizeStage(event:Event):void{
			//bg.width = stage.stageWidth;
			//labelBg.width = stage.stageWidth;
		
		}



		


		public override function set value(s):void{
			_value = s;
			try{
				field.selectedIndex = getSelectedIndex(s)
			}
			

			catch(err){
				Controls.debugMsg("List problem. Setting value not in list? Value: "+s)
			}
		}

		
		public override function get value(){
			return getSelectedIndices(field)
			
		}
		
		function getSelectedIndices(f){
			var l  = f.selectedItems.length;
			var s = [];
			while(l--){
				s.push(f.selectedItems[l].data)
				
			}
			return s.toString();
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