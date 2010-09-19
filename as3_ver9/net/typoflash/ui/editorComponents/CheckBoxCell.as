
package net.typoflash.ui.editorComponents{

	 import fl.controls.ButtonLabelPlacement;
	    import fl.controls.DataGrid;
	    import fl.controls.dataGridClasses.DataGridColumn;
	    import fl.events.DataGridEvent;
	    import fl.controls.listClasses.ListData;
	    import fl.controls.listClasses.ICellRenderer;
	    import fl.controls.LabelButton;
	    import fl.core.UIComponent;
	    import flash.events.Event;
	    import flash.events.MouseEvent;
	    import fl.controls.CheckBox;
	    import fl.controls.listClasses.CellRenderer;
	    import flash.display.DisplayObject;

	    [Style(name="icon", type="Class")]
	    [Style(name="upIcon", type="Class")]
	    [Style(name="downIcon", type="Class")]
	    [Style(name="overIcon", type="Class")]
	    [Style(name="disabledIcon", type="Class")]
	    [Style(name="selectedDisabledIcon", type="Class")]
	    [Style(name="selectedUpIcon", type="Class")]
	    [Style(name="selectedDownIcon", type="Class")]
	    [Style(name="selectedOverIcon", type="Class")]
	    [Style(name="upSkin", type="Class")]
	    [Style(name="downSkin", type="Class")]
	    [Style(name="overSkin", type="Class")]
	    [Style(name="disabledSkin", type="Class")]
	    [Style(name="selectedDisabledSkin", type="Class")]
	    [Style(name="selectedUpSkin", type="Class")]
	    [Style(name="selectedDownSkin", type="Class")]
	    [Style(name="selectedOverSkin", type="Class")]
	    [Style(name="textFormat", type="flash.text.TextFormat")]
	    [Style(name="disabledTextFormat", type="flash.text.TextFormat")]
	    [Style(name="textPadding", type="Number", format="Length")]

	    public class CheckBoxCell extends CheckBox implements ICellRenderer {
		    protected var _listData:ListData;
		    protected var _data:Object;
		    protected var _rowSelected:Boolean;
		    protected var _showLabel:Boolean = false; // Change this to true if you want the label to be shown
		    protected var item_dg:DataGrid;

		    public function CheckBoxCell():void {
			super();
			focusEnabled = false;

			
		    }

		    private static var defaultStyles:Object = { icon:null,
			    upIcon:"CheckBox_upIcon",downIcon:"CheckBox_downIcon",overIcon:"CheckBox_overIcon",
			    disabledIcon:"CheckBox_disabledIcon",
			    selectedDisabledIcon:"CheckBox_selectedDisabledIcon",
			    focusRectSkin:null,
			    focusRectPadding:null,
			    selectedUpIcon:"CheckBox_selectedUpIcon",selectedDownIcon:"CheckBox_selectedDownIcon",selectedOverIcon:"CheckBox_selectedOverIcon",
			    upSkin:"CellRenderer_upSkin",downSkin:"CellRenderer_downSkin",overSkin:"CellRenderer_overSkin",
			    disabledSkin:"CellRenderer_disabledSkin",
			    selectedDisabledSkin:"CellRenderer_selectedDisabledSkin",
			    selectedUpSkin:"CellRenderer_selectedUpSkin",selectedDownSkin:"CellRenderer_selectedDownSkin",selectedOverSkin:"CellRenderer_selectedOverSkin",
			    textFormat:null,
			    disabledTextFormat:null,
			    embedFonts:null,
			    textPadding:5 
			};
		    public static function getStyleDefinition():Object { return defaultStyles; }

		    override public function setSize(width:Number,height:Number):void {
			super.setSize(width, height);
		    }

		    public function get listData():ListData {
			return _listData;
		    }

		    public function set listData(value:ListData):void {
			    _listData = value;
			    label = (_showLabel)? _listData.label : "";

			    item_dg = this.parent.parent.parent as DataGrid;
			/*
			Datagrids seem to be planned for textfields, not check boxes. Text fields dont change value when loosing focus.
			A check box does. Gotta intercept the loss of focus and make sure value updated
			*/
			
				item_dg.addEventListener(DataGridEvent.ITEM_FOCUS_OUT,onItemLostFocus)
			
			  // super.selected = value
			//trace("set listData() Checkbox at "+ _listData.row+" " + value)
			   // setStyle("icon", _listData.icon);


		    }

		function onItemLostFocus(event:DataGridEvent){
			try{
				var dg:DataGrid = event.target as DataGrid;
				var field_str:String = dg.getColumnAt(_listData.column).dataField;
				var row:int = Number(event.rowIndex);
				var col:int = Number(event.columnIndex);
				//var column:DataGridColumn;
				//var columnArray:Array = dg.columns;
				if((_listData.row == row) && (_listData.column == col) ){
		
			
					//trace("onItemLostFocus: I am selected:  " + selected + " and in dg:  "+ dg.getItemAt(row)[field_str] +" and in event " )
					selected = dg.getItemAt(row)[field_str]
					//dg.editField(row,field_str,dg.getItemAt(row)[field_str]);
				}else{
					//trace("onItemLostFocus: "+ dg.getItemAt(Number(event.rowIndex)).selected)
				}
			}
			catch(err){}
		}			
		    public function get data():Object {
			return _data;
		    }

		    public function set data(value:Object):void {
			_data = value;
		    }

		    override public function get selected():Boolean {
			return super.selected;
		    }

		    override public function set selected(value:Boolean):void {
			    // Get the name of the field in the data provider item associated with
			    // the column being rendered
			    var item_dg:DataGrid = this.parent.parent.parent as DataGrid;
			    var field_str:String = item_dg.getColumnAt(_listData.column).dataField;

			/*try{
				for (var n in _data){
				trace(n + " : " + _data[n] )
				}
			   trace(field_str);
			}
			catch(err){}*/
			
			    // Make sure the proper boolean value is set
			 (_data[field_str]=="true" || _data[field_str]==1 || _data[field_str]==true)?
			 super.selected=true : super.selected=false;
			//  super.selected=value
			_data[field_str] = super.selected;
			_rowSelected = value;
				
			  //  trace("set selected() : Checkbox at " +_listData.row+ " set to " + value +" _data[" +field_str +"] "+_data[field_str])
				// item_dg.invalidateList();//this updates the view
		    }

		    override protected function toggleSelected(event:MouseEvent):void {
			 // don't set selected or dispatch change event.
		    }

		    override protected function drawLayout():void {
			    var textPadding:Number = Number(getStyleValue("textPadding"));
			    var textFieldX:Number = 0;
			    // Align icon
			    if (icon != null) {
			    icon.x = textPadding;
			    icon.y = Math.round((height-icon.height)>>1);
			    textFieldX = icon.width + textPadding;
			    }
			    // Align text
			    if (label.length > 0) {
			    textField.visible = true;
			    var textWidth:Number = Math.max(0, width - textFieldX - textPadding*2);
			    textField.width = textWidth;
			    textField.height = textField.textHeight + 4;
			    textField.x = textFieldX + textPadding
			    textField.y = Math.round((height-textField.height)>>1);
			    } else {
			    textField.visible = false;
			    }
			    // Size background
			    background.width = width;
			    background.height = height;
		    }

		    override protected function drawBackground():void{
			    var styleName:String = (enabled) ? mouseState : "disabled";
			    if (_rowSelected) {
			    styleName = "selected"+styleName.substr(0,1).toUpperCase()+styleName.substr(1);
			    }
			    styleName += "Skin";
			    var bg:DisplayObject = background;
			    background = getDisplayObjectInstance(getStyleValue(styleName));
			    addChildAt(background, 0);
			    if (bg != null && bg != background) { removeChild(bg); 
		}
	    }
	    
	}
}
	
	
