
package net.typoflash.ui.editorComponents{

	 import fl.controls.ButtonLabelPlacement;
	    import fl.controls.DataGrid;
	    import fl.controls.dataGridClasses.DataGridColumn;
	    import fl.controls.listClasses.ListData;
	    import fl.controls.listClasses.ICellRenderer;
	    import fl.controls.Button;
	    import fl.core.UIComponent;
	    import flash.events.Event;
	    import flash.events.MouseEvent;

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

	    public class ButtonCell extends Button implements ICellRenderer {
		    protected var _listData:ListData;
		    protected var _data:Object;
		    protected var _rowSelected:Boolean;
		    protected var _showLabel:Boolean = false; // Change this to true if you want the label to be shown

		    public function ButtonCell():void {
			super();
			focusEnabled = false;
			
		    }

		    private static var defaultStyles:Object = { icon:null,
			    upIcon:"",downIcon:"",overIcon:"",
			    disabledIcon:"CheckBox_disabledIcon",
			    selectedDisabledIcon:"CheckBox_selectedDisabledIcon",
			    focusRectSkin:null,
			    focusRectPadding:null,
			    selectedUpIcon:"CheckBox_selectedUpIcon",selectedDownIcon:"CheckBox_selectedDownIcon",selectedOverIcon:"CheckBox_selectedOverIcon",
			    upSkin:"Button_upSkin",downSkin:"Button_downSkin",overSkin:"CellRenderer_overSkin",
			    disabledSkin:"CellRenderer_disabledSkin",
			    selectedDisabledSkin:"CellRenderer_selectedDisabledSkin",
			    selectedUpSkin:"CellRenderer_selectedUpSkin",selectedDownSkin:"Button_selectedDownSkin",selectedOverSkin:"CellRenderer_selectedOverSkin",
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



			/*
			listData properties...but icon not used by datagrid
			label = label;
			icon = icon;
			owner = owner;
			index = index;
			row = row;
			column = col;
						*/
		    public function set listData(value:ListData):void {
			    _listData = value;
			    label = (_showLabel)? _listData.label : "";
			    
			    //setStyle("icon", _listData.icon);

				var dg:DataGrid = _listData.owner as DataGrid;
				if(dg.columns[_listData.column].icon != null ){

				    setStyle("upIcon", dg.columns[_listData.column].icon);
				    setStyle("downIcon", dg.columns[_listData.column].icon);
				    setStyle("overIcon", dg.columns[_listData.column].icon);
				}

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
			    // Make sure the proper boolean value is set
			    (_data[field_str]=="true" || _data[field_str]==1 || _data[field_str]==true)?
			    super.selected=true : super.selected=false;
			    _rowSelected = value;
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
	
	
