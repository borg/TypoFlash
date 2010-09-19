
package net.typoflash.ui.editorComponents{
	import fl.controls.DataGrid;
	import fl.controls.listClasses.ICellRenderer;
	import fl.core.InvalidationType;
	import fl.controls.dataGridClasses.DataGridCellEditor;
	import fl.controls.dataGridClasses.DataGridColumn;

	dynamic public class CustomDataGridColumn extends DataGridColumn{



		private var _icon:Class;
		public var type:String;//perhaps its a summary column
		public var action:String;//eg. edit,delete,select



		public function CustomDataGridColumn(columnName:String = null) {
			super(columnName);
		}


		public  function set icon(s:Class):void{
		
			_icon = s;
		}
		
		public  function get icon():Class{
		
			return _icon;
		
		}





	}


}