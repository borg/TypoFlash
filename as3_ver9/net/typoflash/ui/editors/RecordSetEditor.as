package net.typoflash.ui.editors{
	import flash.net.Responder;
	import net.typoflash.remoting.RemotingService;
	import net.typoflash.remoting.RemotingEvent;
	import fl.controls.DataGrid;
	import fl.controls.dataGridClasses.DataGridColumn;
	import fl.data.DataProvider;
	import fl.events.DataGridEvent;
	import fl.controls.dataGridClasses.DataGridCellEditor;
	import fl.controls.listClasses.ListData;
	import fl.controls.Button;
	import fl.managers.StyleManager;
	import flash.display.Sprite;
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.text.TextFieldType;	
	import flash.text.TextFieldAutoSize;



	import fl.controls.ComboBox;
	import fl.controls.CheckBox;
	
	import flash.events.*;

	import net.typoflash.ui.editorComponents.CheckBoxCell;
	import net.typoflash.ui.editorComponents.CheckBoxCellEditor;
	import net.typoflash.ui.editorComponents.ButtonCell;
	import net.typoflash.ui.editorComponents.ButtonCellEditor;


	import net.typoflash.ui.editorComponents.CustomDataGridColumn;
	import net.typoflash.ui.components.bComponentEvent;
	import net.typoflash.ui.Controls;
	import net.typoflash.datastructures.Global;

	import net.typoflash.ui.components.bPageBrowser;


	import flash.utils.Timer;
	import flash.events.TimerEvent;


	public class RecordSetEditor extends Sprite{

		public var datagrid:DataGrid;
		public var dp:DataProvider;
		public var selectAllBtn:CheckBox;
		public var refreshBtn:Button;
		public var deleteBtn:Button;
		public var actionCombo:ComboBox;
		public var filterCombo:ComboBox;
		public var pb:bPageBrowser;
		public var fieldNames:Array;//list of label, data properties

		public var topBarHeight:int=30;
		public var service:RemotingService;
		public var global:Global = Global.getInstance();
		public var selectable:Boolean=true;
		public var editable:Boolean=true;
		public var deletable:Boolean=true;
		public var softDelete:Boolean=true;//just sets the deleted flag in database

		public var table:String;
		public var sql:String="1=1";
		public var hideField:String="hidden";//users have got disabled instead

		
		
		public  var temp:*;//hack hack..popups wont initiate without delays
		public  var recsPerPage:TextField;
		//public var sortingField:String;
			
		public var tempValue:*;
		
				
		public var recordEditor:Class;//the editor to launch for each record
		public var recordEditorFieldNames:Array;


		public function RecordSetEditor(){
		
			service = new RemotingService(global.REMOTING_GATEWAY);
		
		}
		
		public function mlabelFunction(o:Object){
		
			return o.col1.label;
		}
	
		public function init(o:Object){
			
			

			


			


/*uid,pid,tstamp,username,password,usergroup,disable,starttime,endtime,name,address,telephone,fax,email,crdate,cruser_id,lockToDomain,deleted,uc,title,zip,city,country,www,company,image,TSconfig,fe_cruser_id,lastlogin,is_online,tx_t3m_country,tx_t3m_softbounces,tx_t3m_hardbounces,tx_t3m_categories,tx_t3m_salutation,static_info_country,zone,language,gender,first_name,last_name,status,date_of_birth,module_sys_dmail_category,module_sys_dmail_html,comments,friends,good_friends,converted_friends,promocode*/

			datagrid = new DataGrid();
			datagrid.editable = true;
			


			try{

		
				if(selectable){
					var s:CustomDataGridColumn = new CustomDataGridColumn("S");
					s.cellRenderer = CheckBoxCell;
					s.itemEditor = CheckBoxCellEditor;
					s.dataField = "selected"
					s.editField = "selected"
					s.editable = true;
					s.action = "select";
					s.width = 24
					datagrid.addColumn(s);
				}

				if(editable){
					var e:CustomDataGridColumn = new CustomDataGridColumn("E");
					e.cellRenderer = ButtonCell;
					e.action = "edit";
					e.itemEditor = ButtonCellEditor;
					e.sortable = false
					e.editable = true;
					e.width = 24
					e.icon = ButtonCell_editIcon;
					datagrid.addColumn(e);
				}

				if(deletable){

					var d:CustomDataGridColumn = new CustomDataGridColumn("D");
					d.cellRenderer = ButtonCell;
					d.action = "delete";
					d.itemEditor = ButtonCellEditor;
					d.sortable = false
					d.editable = true;
					d.width = 24
					d.icon = ButtonCell_deleteIcon;
					datagrid.addColumn(d);

				}

	    
				createColumns();


				refreshBtn = new Button();
				refreshBtn.addEventListener(MouseEvent.CLICK,onRefresh);
				refreshBtn.move(4,4);
				refreshBtn.setStyle("icon",RSE_refreshIcon)
				refreshBtn.label = "";
				refreshBtn.setSize(22,22)
				addChild(refreshBtn);



				selectAllBtn = new CheckBox();
				selectAllBtn.addEventListener(MouseEvent.CLICK,onToggleSelect);
				selectAllBtn.label = "Select all"
				selectAllBtn.move(30,4)
				addChild(selectAllBtn);


				deleteBtn = new Button();
				deleteBtn.addEventListener(MouseEvent.CLICK,onDelete);
				deleteBtn.move(110,4);
				deleteBtn.setStyle("icon",RSE_deleteIcon)
				deleteBtn.label = "";
				deleteBtn.setSize(22,22)
				addChild(deleteBtn);


				actionCombo = new ComboBox();
				actionCombo.addEventListener(Event.CHANGE,onActionSelect);
				//actionCombo.addEventListener(Event.CLOSE,onActionClose);//doesnt work
				actionCombo.move(145,4);
				var ad = new DataProvider();
				ad.addItem({label:"With selected...",data:"none"});
				//ad.addItem({label:"Delete",data:"delete"});
				//ad.addItem({label:"Cut",data:"cut"});
				actionCombo.dataProvider = ad;
				actionCombo.setSize(100,22)
				addChild(actionCombo);


				pb = new bPageBrowser();
				
				pb.itemsPerPage = 20;
				pb.move(260,4);
				pb.itemNum = 20
				pb.middlefix = " of ";
				pb.presentSpecificItems = true
				pb.addEventListener(bComponentEvent.SELECTED,onSetPage)
				addChild(pb);




				recsPerPage = new TextField();
				recsPerPage.height = 14;
				recsPerPage.autoSize = TextFieldAutoSize.LEFT;
				recsPerPage.type = TextFieldType.INPUT;
				recsPerPage.width = 70;
				//recsPerPage.embedFonts = true
				recsPerPage.selectable = false;

				var tf:TextFormat = new TextFormat();
				tf.bold = true;
				tf.color = 0x000000;
				tf.font = "font_body";

				recsPerPage.setTextFormat(tf) 
				addChild(recsPerPage);


				global["CORE"].addEventListener(RemotingEvent.NEW_RECORD,onRecordChanged)
				global["CORE"].addEventListener(RemotingEvent.CHANGED_RECORD,onRecordChanged)
				global["CORE"].addEventListener(RemotingEvent.DELETED_RECORD,onRecordChanged)

			
			}
			catch(err){}

			//datagrid.dataProvider = dp;
			//setSize(300, 200);
			datagrid.move(0, topBarHeight);
			datagrid.addEventListener(DataGridEvent.COLUMN_STRETCH, columnStretchHandler);
			
			
			/*
			Datagrids seem to be planned for textfields, not check boxes. Text fields dont change value when loosing focus.
			A check box does. Gotta intercept the loss of focus and make sure value updated
			*/
			
			//datagrid.addEventListener(DataGridEvent.ITEM_FOCUS_OUT,onItemLostFocus)
			datagrid.addEventListener(DataGridEvent.ITEM_EDIT_BEGIN,onItemEditBegin, false,100)
/*

//http://probertson.com/articles/2007/05/01/flash-cs3-datagrid-detecting-data-change/
...the DataGrid uses event priority to specify that it should be called after most of its event listeners — which is the reason why (in the normal case) the DataProvider contains the pre-edit data rather than the new value (if any). Specifically, when the DataGrid registers as a listener of its own itemEditEnd event, it does so using a priority of -50. 

When you register an event listener in ActionScript, you can optionally specify a priority for your listener (the default, which most listeners use, is 0). Listeners with a higher priority get called first, and listeners with a lower priority get called later. Since the default priority, that’s rarely changed, is 0, any listeners that are registered using the default will get called before the DataGrid’s internal itemEditEnd listener — so they’ll get access to the pre-change value.

However, there’s no reason that your event listener can’t register with a different priority. For that matter, you can register two different listener functions for the same event, with different priorities, which is exactly how this approach works.

You register two functions as listeners for the DataGrid’s itemEditEnd event. The first one should be called before the DataGrid updates the DataProvider, so it must be registered with a priority greater than -50 (I use 100 here):
*/			
			//before change...editing by means of 
			datagrid.addEventListener(DataGridEvent.ITEM_EDIT_END, itemEditPreEnd, false, 100);
			//after change
			datagrid.addEventListener(DataGridEvent.ITEM_EDIT_END,itemEditPostEnd, false, -100);
			addChild(datagrid)
			

			addEventListener(bComponentEvent.CHANGED,onChanged);
			

			//intercept the sorting action...we will sort in database instead
			//datagrid.sortableColumns = false
			datagrid.addEventListener(DataGridEvent.HEADER_RELEASE ,onSorting);
			addEventListener(RemotingEvent.REQUEST,onRequest)
			addEventListener(RemotingEvent.DATA,onData)


			refresh();
		
		}


		public function onRecordChanged(e:RemotingEvent){
			if(e.data.table == table){
				//this change concerns this table
				refresh();
			}
		}
		public function onRequest(e){
			refreshBtn.setStyle("icon",RSE_pendingIcon);
			enabled = false;
		}
		
		public function onData(e){
			refreshBtn.setStyle("icon",RSE_refreshIcon);
			enabled = true;
		}

		public function refresh(){
		

			

			var responder:Responder = new Responder(getRecordSet, onFault);
			var limit = pb.startItem +","+ pb.itemsPerPage;
			

			if(datagrid.sortIndex>0){
				var sorting = datagrid.columns[datagrid.sortIndex].dataField

				if(datagrid.sortDescending){
					sorting += " DESC";
				}else{
					sorting += " ASC";
				}
			}else{
				sorting = "";
			}
			
			
			


			//select ($fields='*',$table='',$where='',$group='',$order='',$limit,$callback='',$showDeleted=false)
			service.call("net.typoflash_typoflash.remoting.contentediting.select", responder,"*",table,sql,'',sorting,limit,'myCallBack',false);

			dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST));
		}
		
		public function set enabled(s:Boolean){
			refreshBtn.enabled = selectAllBtn.enabled = deleteBtn.enabled = actionCombo.enabled =  pb.enabled =datagrid.editable = s;
		}

		public  function getRecordSet( data:*=false){
			var o,n;
			
			try{
				if(data.errortype>0){
					Controls.debugMsg(this + " remoting error " +data.errormsg);
					
					
				}


			}
			catch(err){
				Controls.debugMsg(this + " remoting error ")
				for(n in data){
					Controls.debugMsg(n+" " + data[n]);
				}
				
			}
			/*Controls.debugMsg("getRecordSet");
			for(n in data.result.serverInfo){
				Controls.debugMsg(n+" " + data.result.serverInfo[n]);
			}*/
			

			//we are trying to map the assigned column names to the received column names and extract that data into the shape of a dataprovider...actully just realized you don't need to extract..you can add as many hidden fields as you wish..columns are defined for the datagrid
			var dp = new DataProvider();
			var d = data.result.serverInfo.initialData;
			var c = data.result.serverInfo.columnNames;
			var i,ii,od;
			for(i=0;i<d.length;i++){
				od = {};
				/*for(ii=0;ii<fieldNames.length;ii++){	
					od[fieldNames[ii].data] = d[i][getIndexFromFields(fieldNames[ii].data,c)];
					//trace(fieldNames[ii].data + " " + d[i])
				}*/

				for(ii=0;ii<c.length;ii++){	
					od[c[ii]] = d[i][ii];
					//trace(fieldNames[ii].data + " " + d[i])
				}
				dp.addItem(od);
			}

			
			pb.itemNum = data.totalRows;
			
			datagrid.dataProvider = dp;

			dispatchEvent(new RemotingEvent(RemotingEvent.DATA,data.result));

	
		
		}
		
		public function getIndexFromFields(name,fields){
			for(var i=0;i<fields.length;i++){
				if(fields[i]==name){
					return i;
				}
			
			}
			return false;
		}
		

		public function getSelected():Array{
			var i,d,dd,s = [];
			for(i = 0; i<datagrid.dataProvider.length;i++){
				//d = datagrid.dataProvider.getItemAt(i);//shud be eq
				dd = datagrid.getItemAt(i);

				if(dd["selected"]){
					s.push(dd);
				}
				
			
			}
			return s;
		}
		public function onRefresh(e:MouseEvent){
			refresh();
		}

		public function createColumns(){
			var c;
			for (var i=0;i<fieldNames.length ;i++ ){
				c = new CustomDataGridColumn(fieldNames[i].label);
				//c.labelFunction = mlabelFunction;
				c.editable = true;
				c.dataField = fieldNames[i].data
				if(fieldNames[i].data =="uid" || fieldNames[i].data =="pid"){
					c.width = 30;//make these typical columns narrower
				}
				datagrid.addColumn(c);
			}

		}

		public function onSorting(event:DataGridEvent){
			/*var dg:DataGrid = event.target as DataGrid;
			trace("dataField:", event.dataField, "(columnIndex:" + event.columnIndex + ")");
 
			trace("sortIndex:", dg.sortIndex);
			trace("sortDescending:", dg.sortDescending);*/
			
			refresh();

		}

		public function onChanged(e:bComponentEvent){
			trace("onChanged " +e.data.oldValue +" " +e.data.newValue)
			
		}





		public function onToggleSelect(ce:MouseEvent):void{
			var i = datagrid.dataProvider.length;
			while(i--){

				datagrid.editField(i,"selected",selectAllBtn.selected);
				//datagrid.dataProvider.getItemAt(i).selected =  selectAllBtn.selected;
			}
			/*var _data = datagrid.getItemAt(0);
			for (var n in _data){
				trace(n + " : " + _data[n] )
				}*/
			//datagrid.invalidateList();//this updates the view
		}


		public function onActionSelect(ce:Event){
			trace(actionCombo.selectedItem.data)
			actionCombo.selectedIndex = 0

		
		}
		public function onActionClose(ce:Event){
		
			actionCombo.selectedIndex = 0

		
		}


		public function deleteRecords(uidArr:Array){
			var l,n;
			l = uidArr.length;
			if(l==0){
				return;
			}
			n = "uid IN (";
			while(l--){
				if(l>0){
					n+= uidArr[l].uid +",";
				}else{
					n+= uidArr[l].uid +")";
				}

			}

			
			var responder:Responder = new Responder(onDeletedRecords, onFault);

			if(softDelete){
				service.call("net.typoflash_typoflash.remoting.contentediting.update", responder,table,n,{deleted:1});
			}else{
				service.call("net.typoflash_typoflash.remoting.contentediting.exec_delete", responder,table,n);
			}
			dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST));
		}




		public function onDeletedRecords(d){
			var o,n;
			
			try{
				if(d.errortype>0){
					Controls.debugMsg(this + " remoting error " +d.errormsg);
					
					
				}else{
				
					dispatchEvent(new RemotingEvent(RemotingEvent.DATA,d.result));
					//trace("record set sending on delete event")
					//Controls.debugMsg({table:table,affectedrows:d.affectedrows})
					global["CORE"].dispatchEvent(new RemotingEvent(RemotingEvent.DELETED_RECORD,{table:table,affectedrows:d.affectedrows}));
				}


			}
			catch(err){
				Controls.debugMsg(this + " remoting error ")
				Controls.debugMsg(d)
				
			}
			
			//refresh();
			
		}

		public function onDelete(ce:MouseEvent){
			var s = getSelected();
			promptDelete(s);
			
		}
		
		public function promptDelete(s:Array){
			if(s.length==0){
				return;
			}
			
			var c = Controls.confirm("Do you wish to delete the selected items?")
			c.ref = this;
			
			c.s = s;
			c.accept = function() {
				
				this.ref.deleteRecords(this.s);
				//trace("promptDelete  "+this.ref +" " + this.s[0])
				
				
			};
			c.decline = function() {
				trace( this + " " + this.ref+" " + "decline")
			};
			//trace("promptDelete  "+c.decline)
		}


		public function hideRecords(uidArr:Array){
			var l,n;
			l = uidArr.length;
			if(l==0){
				return;
			}
			n = "uid IN (";
			while(l--){
				if(l>0){
					n+= uidArr[l].uid +",";
				}else{
					n+= uidArr[l].uid +")";
				}

			}

			
			var responder:Responder = new Responder(onHiddenRecords, onFault);

			
			var d = {};
			d[hideField] = 1;
			service.call("net.typoflash_typoflash.remoting.contentediting.update", responder,table,n,d);
			
			dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST));
		}

		public function onHiddenRecords(data){
			var o,n;
			
			try{
				if(data.errortype>0){
					Controls.debugMsg(this + " remoting error " +data.errormsg);
					
					
				}


			}
			catch(err){
				Controls.debugMsg(this + " remoting error ")
				for(n in data){
					Controls.debugMsg(n+" " + data[n]);
				}
				
			}
			dispatchEvent(new RemotingEvent(RemotingEvent.DATA,data.result));
			refresh();
			
		}
		
		
		public function editRecords(arr:Array){
			
			var l = arr.length;
			if(l==0){
				return;
			}
			//trace("Shuld edit item  "+ l)
			while(l--){
				
				var p = Controls.newWindow({title:"Edit "+arr[l].uid ,type:"ScrollPane",contentPath:recordEditor,initObj:{table:table,fieldNames:recordEditorFieldNames,data:arr[l],softDelete:softDelete},w:380,h:250, resizeEnabled:true,closeEnabled:true,minimiseEnabled:true,vScrollPolicy:"off",hScrollPolicy:"off"});
			}

			

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
			    var cellEditor = datagrid.itemEditorInstance;
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
					
					myTimer.addEventListener("timer", editDelay);
					temp = [dg.getItemAt(row)]
					myTimer.start();
					

					//editRecords([dg.getItemAt(row).uid])

		
				}else if(columnArray[event.columnIndex].action =="delete"){
					//trace(this+" Shuld deleteRecords item  "+ event.rowIndex + " " + dg.getItemAt(row).uid)	
					
					//something fishy here!!!!!
					
					myTimer.addEventListener("timer", promptDelay);
					temp = [dg.getItemAt(row)]
					myTimer.start();

					//promptDelete();
		
				}
			}
			catch(err){
		   
		   
			}
			
		}
		public function promptDelay(e){
			promptDelete(temp);
			temp = null
		}

		public function editDelay(e){
			editRecords(temp);
			temp = null
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

					dispatchEvent(new bComponentEvent(bComponentEvent.CHANGED,o));
				}
		      }
		   }
		}

	
/*_______________________________________ EVENT LISTENERS END _________________________________________*/

		public  function getCustomFormat():TextFormat {
		    var tf:TextFormat = new TextFormat();
		    tf.bold = true;
		    tf.color = 0xFFFFFF;
		    return tf;
		}
		

		public function onSetPage(e:bComponentEvent){
			//trace("Set page to: " +e.target.currPage)
			refresh();
		}


		public  function getCustomEditor():DataGridCellEditor {
		    var dgce:DataGridCellEditor = new DataGridCellEditor();
		    dgce.textField.background = true;
		    dgce.textField.backgroundColor = 0xDDDDDD;
		    dgce.maxChars = 2;
		    dgce.restrict = "1234567890";
		    return dgce
		}


		public function setSize(w:int,h:int){
		
			datagrid.setSize(w,h-topBarHeight)
		
		}

		public function onFault(data:*):void{
			Controls.debugMsg("RecordSetError " + data);
			
			for (var n in data){
				trace(n + " : " + data[n] )
				}
			dispatchEvent(new RemotingEvent(RemotingEvent.FAULT,data));
		}
		

		public function closedByContainer(){
			removeEventListener(RemotingEvent.REQUEST,onRequest)
			removeEventListener(RemotingEvent.DATA,onData)
			global["CORE"].removeEventListener(RemotingEvent.NEW_RECORD,onRecordChanged)
			global["CORE"].removeEventListener(RemotingEvent.CHANGED_RECORD,onRecordChanged)
			global["CORE"].removeEventListener(RemotingEvent.DELETED_RECORD,onRecordChanged)
		}
	}


}