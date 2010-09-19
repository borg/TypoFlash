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


	import fl.controls.SelectableList;
	import flash.text.*;

	public class FormDoubleList extends FormElement implements iFormElement{

		var orgDataProvider:DataProvider;
		var optionalDataProvider:DataProvider;
		var selectedDataProvider:DataProvider;
		public var newRecordClass:Class;//the class to invoke to add new element to list
		public var newRecordInitObj:Object;//passed on to new record class
		
		public function FormDoubleList(){
			
			field.addEventListener(Event.CHANGE, fieldChangeHandler);
			options.addEventListener(Event.CHANGE, optionsChangeHandler);
	
			removeBtn.addEventListener(MouseEvent.CLICK,onRemove);
			removeBtn.label = ""
			removeBtn.setStyle("icon",Form_rightArrowsIcon)
			//deleteBtn.move(30,4)
			removeBtn.setSize(18,18)

			addBtn.addEventListener(MouseEvent.CLICK,onAdd);
			addBtn.label = ""
			addBtn.setStyle("icon",Form_leftArrowsIcon)
			//deleteBtn.move(30,4)
			addBtn.setSize(18,18)

			newBtn.visible = false
			
		}
		
		
		public override function init(o:Object):void{
			super.init(o);

			if(newRecordClass is Class){
				newBtn.addEventListener(MouseEvent.CLICK,onNew);
				newBtn.label = "+"
				newBtn.setSize(18,18)
				newBtn.visible = true
			}else{
				newBtn.visible = false
			}
		}


		function onAdd(ce:MouseEvent){
			var newSel = options.selectedItems;
			var i;
			for(i=0;i<newSel.length;i++){
				options.dataProvider.removeItem(newSel[i])
				field.dataProvider.addItem(newSel[i])
			
			}
			
			options.selectedIndex = -1;

			dispatchEvent(new FormEvent(FormEvent.CHANGED,{name:name,value:value,added:newSel}));//this will send an array since more than one could been added
		}


		function onRemove(ce:MouseEvent){
			var newSel = field.selectedItems;
			var i;
			for(i=0;i<newSel.length;i++){
				field.dataProvider.removeItem(newSel[i])
				options.dataProvider.addItem(newSel[i])
			
			}
			field.selectedIndex = -1;
			dispatchEvent(new FormEvent(FormEvent.CHANGED,{name:name,value:value,removed:newSel}));
		}


		function onNew(ce:MouseEvent){
			var p = Controls.newWindow({title:"New item ",type:"ScrollPane",contentPath:newRecordClass,initObj:newRecordInitObj,w:380,h:250, resizeEnabled:true,closeEnabled:true,minimiseEnabled:true,vScrollPolicy:"off",hScrollPolicy:"off"});
		}

		public function set dataProvider(d){
			orgDataProvider = new DataProvider(d) ;
			
			
		}

		public function get dataProvider(){
			return orgDataProvider;
		}
		
		public function setDataProvider(d:Array){
			dataProvider(d) ;
			

		}	
		
		public function set allowMultipleSelection(d:Boolean):void{
			field.allowMultipleSelection = options.allowMultipleSelection = d ;
			
		}

		public function get allowMultipleSelection():Boolean{
			return field.allowMultipleSelection;
		}

		
		function fieldChangeHandler(event:Event):void {
			options.selectedIndex = -1;
			//dispatchEvent(new FormEvent(FormEvent.CHANGED,{name:name,value:field.selectedItem.data}));
		}
		
		function optionsChangeHandler(event:Event):void {
			field.selectedIndex = -1;
			//dispatchEvent(new FormEvent(FormEvent.CHANGED,{name:name,value:field.selectedItem.data}));
		}
				

		function resizeStage(event:Event):void{
			//bg.width = stage.stageWidth;
			//labelBg.width = stage.stageWidth;
		
		}




		public override function set value(s):void{
			try{
				var splitDP = splitDataProvider(s.split(","),orgDataProvider);
				splitDP[0].sortOn("label");
				splitDP[1].sortOn("label");
				field.dataProvider = splitDP[0];
				options.dataProvider = splitDP[1];
			}
			catch(err){
				Controls.debugMsg("DoubleList problem. Setting value not in list? Value: "+s)
			}
			_value = s;
		}
		public override function get value(){
			return getSelectedIndices(field)
			
		}
		
		function getSelectedIndices(f){
			var l  = f.dataProvider.length;
			var s = [];
			while(l--){
				s.push(f.dataProvider.getItemAt(l).data)
				
			}
			return s.toString();
		}
		
		function splitDataProvider(v:Array,dp:DataProvider){
			var l  = dp.length;
			var i,item;
			var chosen = new DataProvider();
			var remainder = new DataProvider();
			for(i =0;i<l;i++){
				item=dp.getItemAt(i)
				
				if(v.indexOf(String(item.data))>-1){
					chosen.addItem(item);
				}else{
					remainder.addItem(item);
				}
				
			}

			return [chosen,remainder];//returns an array
		}

		public override function set enabled(s:Boolean):void{
			if(_editable){
				_enabled = field.enabled =options.enabled =addBtn.enabled =removeBtn.enabled =newBtn.enabled = s;
			}else{
				_enabled = field.enabled =options.enabled =addBtn.enabled =removeBtn.enabled =newBtn.enabled = false
			}
			
		}

	}
}