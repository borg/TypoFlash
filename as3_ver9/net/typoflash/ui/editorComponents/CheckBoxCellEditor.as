package net.typoflash.ui.editorComponents{

    import fl.controls.ButtonLabelPlacement;
    import fl.controls.CheckBox;
    import fl.controls.DataGrid;
    import fl.controls.dataGridClasses.DataGridColumn;
    import fl.controls.LabelButton;
    import fl.controls.listClasses.CellRenderer;
    import fl.controls.listClasses.ListData;
    import fl.controls.listClasses.ICellRenderer;
    import fl.core.InvalidationType;
    import fl.core.UIComponent;
    import fl.data.DataProvider;
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.system.IME;

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

    public class CheckBoxCellEditor extends CheckBox implements ICellRenderer {
	    public var text:String;
	    protected var _listData:ListData;
	    protected var _data:Object;
	    protected var _rowSelected:Boolean = true;
	    protected var _showLabel:Boolean = false;
	    protected var item_dg:DataGrid;

	    public function CheckBoxCellEditor():void {
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
	    textPadding:5 };
	    public static function getStyleDefinition():Object { return defaultStyles; }

	    override public function setSize(width:Number,height:Number):void {
		super.setSize(width, height);
	    }

	    public function get listData():ListData {
		return _listData;
	    }

	    public function set listData(value:ListData):void {
		    _listData = value;
		    text = _listData.label;
		    label = (_showLabel)? _listData.label : "";
		   // setStyle("icon", _listData.icon);
		  // trace("set listData() CheckboxEditor at "+ _listData.row+" " + value)
	    }

	    public function get data():Object {
		return _data;
	    }

	    public function set data(value:Object):void {
		    _data = value;
		    swapValue();
		    drawNow();
	    }

	    public function get imeMode():String {
		 return _imeMode;
	    }

	    public function set imeMode(value:String):void {
		_imeMode = value;
	    }

	    override public function get selected():Boolean {
		return super.selected;
	    }

	    override public function set selected(value:Boolean):void {
		    swapValue();
		    _rowSelected = value;
	    }

	    private function swapValue():void {
		    var newValue:Boolean;
		    // Get the name of the field in the data provider item associated with
		    // the column being rendered
		    item_dg = this.parent.parent.parent as DataGrid;
		    var field_str:String = item_dg.getColumnAt(_listData.column).dataField;
		    // Make sure the proper boolean value is set
		    (_data[field_str]=="true" || _data[field_str]==1 || _data[field_str]==true)?
		    newValue = false : newValue = true;

		    // Update CellRenderer's appropriate values
		   

		   // trace( "swapValue()  CheckboxEditorEditor at " + _listData.row +" field_str " + field_str +" super.selected ="+ super.selected +" newValue " +newValue)
		    super.selected = newValue; // Status of the CheckBox
		    text = String(newValue); // text property required to act as a DataGridCellEditor
		    // The ListData object that handles the properties applied to the cell
		    _listData = new ListData(String(newValue),
		    _listData.icon,
		    _listData.owner,
		    _listData.index,
		    _listData.row,
		    _listData.column);
		
		   //the normal checkbox
			//var cr=item_dg.getCellRendererAt(_listData.row, _listData.column);
			//trace("Normal checkbx before edit " + cr.selected)
			//cr.selected = newValue;

		// The DataGrid.dataProvider's item associated to the cell
			item_dg.editField(_listData.row,field_str,newValue);
			//item_dg.editField(_listData.row,"name",newValue);//check when data updated
		     
			//trace(cr)
			//var dpi = item_dg.dataProvider.getItemAt(_listData.row);
			//dpi[field_str] = newValue;
			
			//trace(dpi + " _listData.row " + _listData.row + "  " +item_dg);

		// item_dg.invalidateList();//this updates the view
	    }

	    override protected function toggleSelected(event:MouseEvent):void {
		    // don't set selected or dispatch change event.
		    swapValue();
		    // Initiate an immediate draw operation
		    drawNow();
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
		    if (bg != null && bg != background) { removeChild(bg); }
	    }
    }
}