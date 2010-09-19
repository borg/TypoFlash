package net.typoflash.editor 
{
	import fl.controls.DataGrid;
	import fl.controls.List;
	import flash.display.Sprite;
	import flash.events.Event;
	import net.typoflash.base.ComponentBase;
	import net.typoflash.ContentRendering;
	import net.typoflash.ContentEditing;
	
	import net.typoflash.datastructures.TFConfData;
	import net.typoflash.datastructures.TFError;
	import net.typoflash.events.EditingEvent;
	import net.typoflash.events.ComponentEvent
	import fl.events.DataGridEvent;
	import fl.data.DataProvider;
	import fl.controls.Label;
	import fl.controls.Button;
	import flash.events.MouseEvent;
	import net.typoflash.utils.Debug;

	import flash.utils.Timer;
	import flash.events.TimerEvent;

	import net.typoflash.ui.editorComponents.CheckBoxCell;
	import net.typoflash.ui.editorComponents.CheckBoxCellEditor;
	import net.typoflash.ui.editorComponents.ButtonCell;
	import net.typoflash.ui.editorComponents.ButtonCellEditor;


	import net.typoflash.ui.editorComponents.CustomDataGridColumn;	
	import fl.controls.dataGridClasses.*;
	import fl.controls.listClasses.ListData;
	
	import net.typoflash.ui.Controls;
	import net.typoflash.events.RenderingEvent;
	
	/**
	 * ...
	 * @author A. Borg
	 */
	public class ConfigurationManager extends ComponentBase{
		
		public var list:DataGrid;
		public var metaData:DataGrid;
		public var physicalData:DataGrid;
		public var saveBtn:Button;
		public var toggleModeBtn:Button;
		
		private  var currRow:*;//hack hack..popups wont initiate without delays
		private var tempValue:*;
		private var currEntry:Object;
		
		
		public function ConfigurationManager(){
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event) {
			list = new DataGrid();
			list.x = 10;
			list.y = 40;
			list.setSize(200,200)
			list.addEventListener(Event.CHANGE, updateLists,false,200,true);
			list.columns = ["Components"];

			d = new CustomDataGridColumn("D");
			d.cellRenderer = ButtonCell;
			d.action = "delete";
			d.itemEditor = ButtonCellEditor;
			d.sortable = false
			d.editable = true;
			d.width = 24
			d.icon = ButtonCell_deleteIcon;
			list.addColumn(d);				
			list.allowMultipleSelection = false;
			list.editable = true;
			

			
			addChild(list);
			
			var metaDataLabel:Label = new Label();
			metaDataLabel.text = "Meta data";
			metaDataLabel.move(220, 20);		
			addChild(metaDataLabel);
			
			metaData = new DataGrid();
			metaData.columns = ["Name", "Value"];
			
			var d:CustomDataGridColumn = new CustomDataGridColumn("D");
			d.cellRenderer = ButtonCell;
			d.action = "delete";
			d.itemEditor = ButtonCellEditor;
			d.sortable = false
			d.editable = true;
			d.width = 24
			d.icon = ButtonCell_deleteIcon;
			metaData.addColumn(d);	
			
			metaData.x = 220;
			metaData.y = 40;
			metaData.editable = true;
			metaData.setSize(300,130)
			addChild(metaData);
			

			var physicalDataLabel:Label = new Label();
			physicalDataLabel.text = "Physical data";
			physicalDataLabel.move(220, 170);		
			addChild(physicalDataLabel);
			
			physicalData = new DataGrid();
			physicalData.columns = ["Name", "Value"];
			
			d = new CustomDataGridColumn("D");
			d.cellRenderer = ButtonCell;
			d.action = "delete";
			d.itemEditor = ButtonCellEditor;
			d.sortable = false
			d.editable = true;
			d.width = 24
			d.icon = ButtonCell_deleteIcon;
			physicalData.addColumn(d);		
			
			
			physicalData.x = 220;
			physicalData.y = 190;
			physicalData.editable = true;
			physicalData.setSize(300,140)
			addChild(physicalData);		
			

			physicalData.addEventListener(DataGridEvent.COLUMN_STRETCH, columnStretchHandler);			
			/*
			Datagrids seem to be planned for textfields, not check boxes. Text fields dont change value when loosing focus.
			A check box does. Gotta intercept the loss of focus and make sure value updated
			*/
			
			//datagrid.addEventListener(DataGridEvent.ITEM_FOCUS_OUT,onItemLostFocus)
			list.addEventListener(DataGridEvent.ITEM_EDIT_BEGIN,onItemEditBegin, false,100)		
			metaData.addEventListener(DataGridEvent.ITEM_EDIT_BEGIN,onItemEditBegin, false,100)		
			physicalData.addEventListener(DataGridEvent.ITEM_EDIT_BEGIN,onItemEditBegin, false,100)		
			//before change...editing by means of 
			physicalData.addEventListener(DataGridEvent.ITEM_EDIT_END, itemEditPreEnd, false, 100);
			//after change
			physicalData.addEventListener(DataGridEvent.ITEM_EDIT_END,itemEditPostEnd, false, -100);	

			

			//intercept the sorting action...we will sort in database instead
			//datagrid.sortableColumns = false
			physicalData.addEventListener(DataGridEvent.HEADER_RELEASE ,onSorting);
			
			
			
			
			saveBtn = new Button();
			saveBtn.setStyle("icon",icon_save)
			saveBtn.addEventListener(MouseEvent.CLICK, onSave);
			saveBtn.enabled = false;
			saveBtn.x = 10;
			saveBtn.setSize(22, 22);
			saveBtn.label = ""
			addChild(saveBtn);
					
			
			toggleModeBtn = new Button();
			toggleModeBtn.x = 40;
			toggleModeBtn.setSize(22, 22);
			if (TypoFlash(TF_CONF.EDITOR).pageEditMode) {
				toggleModeBtn.label = "P"
			}else {
				toggleModeBtn.label = "T"
			}
			addChild(toggleModeBtn);
			toggleModeBtn.addEventListener(MouseEvent.CLICK, togglePageEdit);
			
			//ContentEditing.addEventListener(EditingEvent.ON_STORE_PAGE_DATA, onStorePageData);
			ContentEditing.addEventListener(EditingEvent.ON_HISTORY_STORED, refresh);
			ContentRendering.addEventListener(RenderingEvent.ON_GET_MOTHERLOAD, refresh);
			ContentRendering.addEventListener(RenderingEvent.ON_GET_PAGE, refresh);
			
			HistoryManager.addEventListener(EditingEvent.ON_HISTORY_CHANGED, historyChanged);			
			refresh();
		}
		
		public function refresh(e:*=null) {
            var dp:Array = new Array();
           
			for (var n in ContentRendering.page.TEMPLATE.page_data[TF_CONF.LANGUAGE]) {
				var confData:TFConfData = new TFConfData();
				try{
					confData.meta = ContentRendering.page.TEMPLATE.page_data[TF_CONF.LANGUAGE][n].meta;
				}
				catch (b:Error) { }
				
				try{
					confData.physical = ContentRendering.page.TEMPLATE.page_data[TF_CONF.LANGUAGE][n].physical;
				}catch (b:Error) { }
				
				dp.push({Components:n, data:confData});
            }
            
            
            list.dataProvider = new DataProvider(dp);		
			metaData.dataProvider = new DataProvider();
			physicalData.dataProvider = new DataProvider();
			currEntry = null;
		}
		
		
		private function historyChanged(e:EditingEvent) {
			if (e.data is TFError) {
				//alert the fire dept
				Debug.output(e.data);
				saveBtn.enabled = false;
				return;
			}
			if (HistoryManager.unsavedHistory.length > 0) {
				saveBtn.enabled = true;
			}else {
				saveBtn.enabled = false;
			}
		}
		public function onSorting(event:DataGridEvent){
			/*var dg:DataGrid = event.target as DataGrid;
			trace("dataField:", event.dataField, "(columnIndex:" + event.columnIndex + ")");
 
			trace("sortIndex:", dg.sortIndex);
			trace("sortDescending:", dg.sortDescending);*/
			
			//refresh();

		}

		public function onChanged(e:ComponentEvent){
			Debug.output("onChanged " +e.data.oldValue +" " +e.data.newValue)
			refresh();
		}
		
		private function onStoredHistory(e:EditingEvent) {
			if (e.data is TFError) {
				saveBtn.setStyle("icon", icon_save);
				saveBtn.enabled = false;
				//tell HistoryManager how much of the commands were successfully stored and scrap the rest
			}else if(e.data == EditingEvent.TRUE){
				HistoryManager.makeHistory();
				saveBtn.setStyle("icon",icon_save)
			}else {
				saveBtn.setStyle("icon",icon_pending)
			}
		}	
		
		
		private function onStorePageData(e:EditingEvent) {
			
			if (e.data == EditingEvent.PENDING) {
				saveBtn.setStyle("icon",icon_pending)
			}else {
				saveBtn.setStyle("icon",icon_save)
			}
		}
		private function onSave(e:MouseEvent) {
			if(HistoryManager.unsavedHistory.length > 0){
				ContentEditing.storeHistory(HistoryManager.unsavedHistory);
			}
		}
		
		private function togglePageEdit(e:MouseEvent) {
			if (TypoFlash(TF_CONF.EDITOR).pageEditMode) {
				TypoFlash(TF_CONF.EDITOR).pageEditMode = false;
				toggleModeBtn.label = "T"
			}else {
				TypoFlash(TF_CONF.EDITOR).pageEditMode = true;
				toggleModeBtn.label = "P"
			}
			
		}
			
		
		
		
		
		
		
		
        private function updateLists(e:Event):void {
			if (list.selectedItem ) {
				var dp:Array = new Array();
				var confData:TFConfData = list.selectedItem.data;
				currEntry = {key:list.selectedItem.Components,data:confData};
				for (var n in confData.meta) {
					dp.push({Name:n, Value:confData.meta[n],Type:"meta"});
				}
				metaData.dataProvider = new DataProvider(dp);
				
				
				dp = [];
				for (n in confData.physical) {
					dp.push({Name:n, Value:confData.physical[n],Type:"physical"});
				}
				physicalData.dataProvider = new DataProvider(dp);
			}else {
				metaData.dataProvider = new DataProvider();
				physicalData.dataProvider = new DataProvider();
				currEntry = null;
			}
           
        }
	

		public function onDelete(e:MouseEvent) {
			Debug.output("onDelete "+e.target);
			//var s = getSelected();
			//promptDelete([]);
			//_global.TF.CONTENT_EDITING.deletePageData(glue.__get__key());
		}
		
		public function promptDelete(o:Object) {
			
			if(o == null){
				return;
			}else if(o.Name){
				var c = Controls.confirm("Do you wish to delete entry: '" +o.Name+"'?")
				c.accept = function() {
					deleteEntry(o);
				};
			}else if (o.Components) {
				var c = Controls.confirm("Do you wish to delete all configuration settings for " +currEntry.key+" on this page?")
				c.accept = function() {
					ContentEditing.deletePageData(currEntry.key,TF_CONF.PID);
				};
			}

		}
		
		public function deleteEntry(e) {
			
			var o = { };
			
			o.key = currEntry.key;
			o.L = TF_CONF.LANGUAGE;
			//Get the stored data (not the edited on scren as it is not saved yet)
			var d = ContentRendering.getData(currEntry.key);
			Debug.output(["deleteEntry ", currEntry.key , e.Name])
			Debug.output(d)
			
			//then delete the entry
			delete d[e.Type][e.Name];
			o.data = d;
			
			
			if (TypoFlash(TF_CONF.EDITOR).pageEditMode) {
				//store data on page
				o.id = TF_CONF.PID;
				HistoryManager.addItem(new HistoryItem(currEntry.key, currEntry.key, "storePageData", [o]));
			}else{
				//store data on template level...only applicable to non components, ie. template objects
				o.id = ContentRendering.page.TEMPLATE.template_pid;
				HistoryManager.addItem(new HistoryItem(currEntry.key, currEntry.key, "storeTemplateData", [o]));
			}	
			//HistoryManager.makeHistory();
			ContentEditing.storeHistory(HistoryManager.unsavedHistory);
		}

/*_______________________________________ EVENT LISTENERS _________________________________________*/
		public function columnStretchHandler(event:DataGridEvent):void {
		    var dg:DataGrid = event.target as DataGrid;
		    var column:DataGridColumn;
		    var columnArray:Array = dg.columns;
		    var dgColWidth:String;
		   // trace("resized column:", event.dataField);
		   // trace("columnIndex:", event.columnIndex);

		   var i=3;
		   while(i--){
			//keep the icon columns same width
			columnArray[i].width = 24;
		   }
		   // for each (column in columnArray) {

			//dgColWidth = Number(column.width / dg.width * 100).toFixed(1);
			//trace(column.dataField + ".width:", column.width + " pixels (" + dgColWidth + "%)");
		   // }
		   // trace("----------");
		}
		public function onItemEditEnd(e:DataGridEvent):void {
				var dg:DataGrid = e.target as DataGrid;
			    var cellEditor = dg.itemEditorInstance;
			    var listData:ListData = cellEditor.listData;
			  // listData.icon=ButtonCell_editIcon
			    trace("After Edit: " + cellEditor.text + " " + listData.row);
			   //if real edit update database
		}
		


		public function onItemEditBegin(event:DataGridEvent){

			var dg:DataGrid = event.target as DataGrid;
			var column:DataGridColumn;
			var columnArray:Array = dg.columns;
			var field:String = event.dataField;
			var row:Number = Number(event.rowIndex);

			//trace("onItemEditBegin: "+ dg.getItemAt(Number(event.rowIndex)).selected)


			try{
				var myTimer:Timer = new Timer(50, 1);
				if(columnArray[event.columnIndex].action =="select"){
					//trace("Shuld select item "+ event.rowIndex + " " + event.columnIndex)

					  
					   if (dg != null) {
					      // gets the value (post-edit) from the grid's dataprovider
					      var newValue:* = dg.getItemAt(row)[columnArray[event.columnIndex].dataField];
					     
					      
					}

				}else if(columnArray[event.columnIndex].action =="edit"){
					//trace("Shuld edit item  "+ event.rowIndex + " " + event.columnIndex)
					
					myTimer.addEventListener("timer", editDelay,false,0,true);
					currRow = dg.getItemAt(row)
					myTimer.start();
					

					//editRecords([dg.getItemAt(row).uid])

		
				}else if(columnArray[event.columnIndex].action =="delete"){
					//trace(this+" Shuld deleteRecords item  "+ event.rowIndex + " " + dg.getItemAt(row).uid)	
					
					//something fishy here!!!!!
					
					myTimer.addEventListener("timer", promptDelay,false,0,true);
					currRow = dg.getItemAt(row)
					myTimer.start();

					//promptDelete();
		
				}
			}
			catch(err){
		   
		   
			}
			
		}
		public function promptDelay(e){
			promptDelete(currRow);
			currRow = null
		}

		public function editDelay(e){
			//editRecords(currRow);
			//currRow = null
		}

		public function itemEditPreEnd(event:DataGridEvent):void{
		   // get a reference to the datagrid
		   var grid:DataGrid = event.target as DataGrid;
		   // get a reference to the name of the property in the
		   // underlying object corresponding to the cell that's being edited
		   var field:String = event.dataField;
		   // get a reference to the row number (the index in the
		   // dataprovider of the row that's being edited
		   var row:Number = Number(event.rowIndex);

		   if (grid != null){
		      // gets the value (pre-edit) from the grid's dataprovider
		      tempValue = grid.dataProvider.getItemAt(row)[field];
		      
		      //trace( "itemEditPreEnd: "+ tempValue)
		      // you could also use this line to get the value
		      // directly from the cellrenderer that's showing the value
		      // in the datagrid -- it's the same value.
		      // That way you wouldn't need a reference to the DataGrid.
		      //tempValue = event.itemRenderer.data[field];
		   }
		}





		
		public function itemEditPostEnd(event:DataGridEvent):void{
		   var grid:DataGrid = event.target as DataGrid;
		   var field:String = event.dataField;
		   var row:Number = Number(event.rowIndex);
		   if (grid != null){
		      // gets the value (post-edit) from the grid's dataprovider
		      var newValue:* = grid.dataProvider.getItemAt(row)[field];
			

		      /*alt approach with one listener
		      var row:Number = Number(event.rowIndex);
		   // get a reference to the column number of
		   // the cell that's being edited
		   var col:int = event.columnIndex;
		      
		      // get the value (post-edit) from the item editor
		   //   var newValue:Number = Number(grid.itemEditorInstance[grid.columns[col].editorDataField]);
		*/
		      // you could also use this line to get the value
		      // directly from the cellrenderer that's showing the value
		      // in the datagrid -- it's the same value.
		      // That way you wouldn't need a reference to the DataGrid.
		      //var newValue = event.itemRenderer.data[field];
// trace( "itemEditPostEnd: "+ newValue)
		      // check if the value has changed
		      if (newValue != tempValue){
		      //trace(field + " Is "+ newValue)


				// do actions that should happen when the data changes


				//datagrid.invalidateList();//this updates the view
				var col:int = event.columnIndex;
				var action = grid.columns[col].action; 
				if(action == null){
					//dont send selected
					var o = {};
					o.datagrid = grid;
					o.oldValue = tempValue
					o.row = row;
					o.field = field;
					o.newValue = newValue;

					dispatchEvent(new ComponentEvent(ComponentEvent.ON_CHANGED,o));
				}
		      }
		   }
		}

	
/*_______________________________________ EVENT LISTENERS END _________________________________________*/
	}
	
}