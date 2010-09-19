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

	import fl.controls.ComboBox;
	import fl.controls.CheckBox;
	import fl.containers.ScrollPane
	
	import flash.events.MouseEvent;

	import net.typoflash.ui.editorComponents.CheckBoxCell;
	import net.typoflash.ui.editorComponents.CheckBoxCellEditor;
	import net.typoflash.ui.editorComponents.ButtonCell;
	import net.typoflash.ui.editorComponents.ButtonCellEditor;


	import net.typoflash.ui.editorComponents.CustomDataGridColumn;
	import net.typoflash.ui.components.bComponentEvent;
	import net.typoflash.ui.Controls;
	import net.typoflash.utils.Global;

	import net.typoflash.ui.components.bPageBrowser;
	import net.typoflash.ui.forms.Form;
	import net.typoflash.ui.forms.FormEvent;

	public class RecordEditor extends Sprite{

		public var form:Form;
		public var dp:DataProvider;
		public var saveBtn:Button;
		public var refreshBtn:Button;
		public var deleteBtn:Button;
		public var actionCombo:ComboBox;
		public var filterCombo:ComboBox;
		
		public var fieldNames:Array;//list of label, data properties

		public var topBarHeight:int=30;
		public var service:RemotingService;
		private var global:Global = Global.getInstance();

		public var _editable:Boolean=true;
		public var deletable:Boolean=true;
		public var softDelete:Boolean=true;//just sets the deleted flag in database

		public var table:String;
		public var hideField:String="hidden";//users have got disabled instead
		
		public var formPane:ScrollPane;

		public var data:*;
		//public var sortingField:String;
			
		var tempValue:*;


		public function RecordEditor(){
		
			service = new RemotingService(global.REMOTING_GATEWAY);
		
		}
		
	
		public function init(o:Object){
			
	
			form = new Form();
			

			form.addEventListener(FormEvent.CHANGED, changeHandler);

			try{


				refreshBtn = new Button();
				refreshBtn.addEventListener(MouseEvent.CLICK,onRefresh);
				refreshBtn.move(4,4);
				refreshBtn.setStyle("icon",RSE_refreshIcon)
				refreshBtn.label = "";
				refreshBtn.setSize(22,22)
				addChild(refreshBtn);


				if(editable){
					saveBtn = new Button();
					saveBtn.addEventListener(MouseEvent.CLICK,onSave);
					saveBtn.label = ""
					saveBtn.setStyle("icon",RSE_saveIcon)
					saveBtn.move(30,4)
					saveBtn.setSize(22,22)
					addChild(saveBtn);
				}
				if(deletable){
					deleteBtn = new Button();
					deleteBtn.addEventListener(MouseEvent.CLICK,onDelete);
					deleteBtn.move(56,4);
					deleteBtn.setStyle("icon",RSE_deleteIcon)
					deleteBtn.label = "";
					deleteBtn.setSize(22,22)
					addChild(deleteBtn);
				}


			
			}
			catch(err){}
		

			
			form.dataProvider = fieldNames;
			form.data = data;
			form.editable = true;
			form.enabled = true;

			formPane = new ScrollPane();
			//formPane.maxHorizontalScrollPosition ///can be used to fix the form height bug...or fix the bug
			//formPane.scrollDrag = true
			formPane.horizontalScrollPolicy = "off"

			
			formPane.move(0, topBarHeight);
			
			formPane.source = form
			
			
			
			addChild(formPane)
			

			//addEventListener(bComponentEvent.CHANGED,onChanged);
			

			//intercept the sorting action...we will sort in database instead
			//datagrid.sortableColumns = false
			
			addEventListener(RemotingEvent.REQUEST,onRequest)
			addEventListener(RemotingEvent.DATA,onData)
			
			//these listens to if external editors changed or deleted record
			global["CORE"].addEventListener(RemotingEvent.CHANGED_RECORD,onRecordChanged)
			global["CORE"].addEventListener(RemotingEvent.DELETED_RECORD,onRecordDeleted)

			//refresh();
		
		}


		public function onRecordChanged(e:RemotingEvent){
		
	
		
			if(e.data.table == table){
				try{
					//data contains array of modified uids
					if(e.data.affectedrows.indexOf(String(data.uid))>-1){	

						//this change concerns this record	
						refresh();
					}
				}
				catch(err){}
			}
		}

		public function onRecordDeleted(e:RemotingEvent){
			
			if(e.data.table == table){
				try{
					//data contains array of modified uids
					if(e.data.affectedrows.indexOf(String(data.uid))>-1){	

						//this change concerns this record	
						close();
					}
				}
				catch(err){
					trace(err)
				}
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
		
		public  function changeHandler(e){
			trace("Form changed")
		}
		public function refresh(){
		
			
			try{
			
					var responder:Responder = new Responder(getRecordSet, onFault);
					//select ($fields='*',$table='',$where='',$group='',$order='',$limit,$callback='',$showDeleted=false)
					service.call("net.typoflash_typoflash.remoting.contentediting.select", responder,"*",table,'uid='+data.uid,'','','','myCallBack',false);

					dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST));
			}
			catch(err){
			//new element? no data?
			}
		}
		
		public function set enabled(s:Boolean){
			refreshBtn.enabled = saveBtn.enabled = deleteBtn.enabled =form.enabled = s;
		}

		private function getRecordSet( data:*=false){
			var o,n;
			
			try{
				if(data.errortype>0){
					Controls.debugMsg(this + " remoting error " +data.errormsg);
					
					
				}


			}
			catch(err){
				Controls.debugMsg(this + " remoting error ")
				Controls.debugMsg(data);
				
				
			}
			Controls.debugMsg("getRecordSet");
			Controls.debugMsg(data.result);
			
			/*

			//we are trying to map the assigned column names to the received column names and extract that data into the shape of a dataprovider...actully just realized you don't need to extract..you can add as many hidden fields as you wish..columns are defined for the form
			*/
			var dp = {};
			var d = data.result.serverInfo.initialData;
			var c = data.result.serverInfo.columnNames;
			var i,ii,od= {};;
			for(i=0;i<d.length;i++){
				

				for(ii=0;ii<c.length;ii++){	
					od[c[ii]] = d[i][ii];
					
				}
			
			}

			
			
			form.data = od;

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
			for(i = 0; i<form.dataProvider.length;i++){
				//d = form.dataProvider.getItemAt(i);//shud be eq
				dd = form.dataProvider.getItemAt(i);

				if(dd["selected"]){
					s.push(dd);
				}
				
			
			}
			return s;
		}
		public function onRefresh(e:MouseEvent){
			refresh();
		}

		

		public function onChanged(e:bComponentEvent){
			trace("onChanged " +e.data.oldValue +" " +e.data.newValue)
			
		}





		public function onSave(ce:MouseEvent):void{
			saveRecord()
		}


		public function saveRecord(){
			var n = form.getValues();
			var responder:Responder = new Responder(onSavedRecord, onFault);
			try{
				if(data.uid>0){
					//if(Boolean(uint(data.uid))){
						service.call("net.typoflash_typoflash.remoting.contentediting.update", responder,table,"uid = " +data.uid,n);
				
					//}
					
				}
			}
			
			catch(err){
				service.call("net.typoflash_typoflash.remoting.contentediting.insert", responder,table,n);
		
			}
			

			dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST));

		
		}




		public function onSavedRecord(d){
			var o,n;
			
			try{
				if(d.errortype>0){
					Controls.debugMsg(this + " remoting error " +d.errormsg);
					
					
				}else{
					//Controls.debugMsg(d.result)
					//fucking cunt that u cant test undefined properties without throwing shitloads of errors
					if(data !=null){
						if(data.uid>0){
							
							global["CORE"].dispatchEvent(new RemotingEvent(RemotingEvent.CHANGED_RECORD,{table:table,affectedrows:d.affectedrows}));//since we use update it returns affectedrows
						}
					}else{
							global["CORE"].dispatchEvent(new RemotingEvent(RemotingEvent.NEW_RECORD,{table:table,data:d.result}));
							//refresh();//on record change refrensh event is routed through core
					
					}
					form.data = data = d.result;
				}
				
				//
				
			}
			catch(err){
				
				
			}
			
			dispatchEvent(new RemotingEvent(RemotingEvent.DATA,d.result));
			
		}



		public function deleteRecord(){
			var n = "uid ="+data.uid;
					
			var responder:Responder = new Responder(onDeletedRecord, onFault);

			if(softDelete){
				service.call("net.typoflash_typoflash.remoting.contentediting.update", responder,table,n,{deleted:1});
			}else{
				service.call("net.typoflash_typoflash.remoting.contentediting.exec_delete", responder,table,n);
			}
			dispatchEvent(new RemotingEvent(RemotingEvent.REQUEST));
		}




		public function onDeletedRecord(d){
		
			var o,n;
			
			try{
				if(d.errortype>0){
					Controls.debugMsg(this + " remoting error " +d.errormsg);
					
					
				}


			}
			catch(err){
				Controls.debugMsg(this + " remoting error ")
				
					Controls.debugMsg(d);
				
				
			}
			dispatchEvent(new RemotingEvent(RemotingEvent.DATA,d.result));
			global["CORE"].dispatchEvent(new RemotingEvent(RemotingEvent.DELETED_RECORD,{table:table,affectedrows:d.affectedrows}));
			//dispatch record has  changed to all listeners
			//close();

			//refresh();
			
		}

		public function onDelete(ce:MouseEvent){
			promptDelete();
			
		}
		
		public function promptDelete(){
			
			var c = Controls.confirm("Do you wish to delete record #"+data.uid+"?")
			c.ref = this;
			
			c.accept = function() {
				
				this.ref.deleteRecord();
				
				
			};
			c.decline = function() {
				//trace( this + " " + this.ref+" " + "decline")
			};
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
			
			

			

		}




		public function onSetPage(e:bComponentEvent){
			//trace("Set page to: " +e.target.currPage)
			refresh();
		}


	

		public function setSize(w:int,h:int){
		
			formPane.setSize(w,h-topBarHeight)
		
		}

		public function onFault(data:*):void{
			Controls.debugMsg("RecordSetError " + data);
			
			for (var n in data){
				trace(n + " : " + data[n] )
				}
			dispatchEvent(new RemotingEvent(RemotingEvent.FAULT,data));
		}
		
		public function set editable(s){
			form.editable = s
		}
		public function get editable(){
			return form.editable;
		}

		public function close(){


			removeEventListener(RemotingEvent.REQUEST,onRequest)
			removeEventListener(RemotingEvent.DATA,onData)
			
			//these listens to if external editors changed or deleted record
			global["CORE"].removeEventListener(RemotingEvent.CHANGED_RECORD,onRecordChanged)
			global["CORE"].removeEventListener(RemotingEvent.DELETED_RECORD,onRecordDeleted)



			dispatchEvent(new bComponentEvent(bComponentEvent.CLOSED,this));
		}
	}


}